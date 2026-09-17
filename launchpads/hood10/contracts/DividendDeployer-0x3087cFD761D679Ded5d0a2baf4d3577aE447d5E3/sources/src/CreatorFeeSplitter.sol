// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface ILaunchHookCreatorLane {
    function claim(bytes32 poolId, address to) external returns (uint256);
    function acceptCreator(bytes32 poolId) external;
    function creatorOf(bytes32 poolId) external view returns (address);
}

interface ILaunchTokenMetadata {
    function setMetadataURI(string calldata newURI) external;
}

interface IWETH9 {
    function deposit() external payable;
}

// Ceiling on what any splitter may ever divert to the pad, in basis points.
//
// File-level so the deployer can enforce it before deploying anything, rather than duplicating
// the number and letting the two drift. A pad that could take an unbounded cut would make the
// treasury decorative.
uint256 constant MAX_CUT_BPS = 3_000;

/// Everything a splitter is, fixed at construction.
///
/// Passed as one struct rather than ten arguments because the deployer builds a treasury and a
/// splitter in the same frame, and ten stack slots on top of that is `Stack too deep` — which
/// this repo cannot answer with `via_ir`, since that fails on the factory's own Yul.
struct SplitterConfig {
    ILaunchHookCreatorLane hook;
    bytes32 poolId;
    address token;
    address quote;
    address weth;
    address treasury;
    address feeRecipient;
    address keeper;
    address metadataAdmin;
    uint256 maxCutBps;
}

/// @notice The piece between a pool's creator fee and its holders' treasury.
///
/// @dev    It exists because `LaunchDividendTreasury` cannot do two things the fee lane needs,
///         and neither is fixable in the treasury:
///
///         It cannot HOLD THE CREATOR ROLE. `LaunchHook.acceptCreator` must be called BY the
///         nominee, and the treasury has no path to make an arbitrary external call — that
///         path was deliberately removed. So something else has to be the creator, and that
///         something has to be a contract, or the payout promise is only as good as a person
///         remembering to forward money.
///
///         It cannot RECEIVE ETHER. A natively-quoted pool is paid by `LaunchHook._pay` with a
///         raw `call{value:}`, and the treasury has no `receive()` — on purpose, since ether
///         arriving there could never be distributed. This contract takes the ether and wraps
///         it, so a native pool and a WETH pool converge on the same treasury shape.
///
///         Everything here is immutable and set at construction. There is no owner, no
///         upgrade, and nothing that can redirect the stream once the creator has handed it
///         over — which is the whole point. A creator who routes their fee lane here is making
///         a promise their holders can verify rather than trust.
///
///         THE ONE DISCRETIONARY INPUT is `cut` on `push`, which is how the pad recovers the
///         keeper's gas and takes its platform share. It is bounded on chain by `maxCutBps`,
///         fixed at construction, so the keeper decides the amount off chain but can never
///         exceed the share the creator agreed to when the splitter was deployed.
contract CreatorFeeSplitter {
    using SafeERC20 for IERC20;

    error NotKeeper();
    error NotCreator();
    error CutTooLarge(uint256 cut, uint256 max);
    error NothingToPush();
    error ZeroAddress();
    error CapTooLarge();
    error WrapFailed();
    error NotNative();
    error StillKeepersTurn(uint64 openAt);

    uint256 public constant BPS = 10_000;
    /// @notice Mirror of the file-level ceiling, so integrators can read it off the contract.
    uint256 public constant MAX_CUT = MAX_CUT_BPS;

    ILaunchHookCreatorLane public immutable hook;
    bytes32 public immutable poolId;
    /// @notice The launched token, so metadata control can be forwarded back to its creator.
    address public immutable token;
    /// @notice The pool's quote asset, or address(0) for a natively-quoted pool. Payouts are
    ///         always made in `payoutToken`, which is WETH when this is zero.
    address public immutable quote;
    address public immutable payoutToken;
    address public immutable weth;
    address public immutable treasury;
    address public immutable feeRecipient;
    address public immutable keeper;
    /// @notice The address that may still edit the token's metadata after the handover.
    ///         Recorded at construction, because `LaunchToken.setMetadataURI` reads
    ///         `hook.creatorOf(poolId)` and that becomes this contract the moment the handover
    ///         completes — without this forwarder, routing the fee lane would silently cost the
    ///         creator the ability to fix their own website link.
    address public immutable metadataAdmin;
    uint256 public immutable maxCutBps;

    /// @notice When the keeper last swept. `pushAll` opens to everyone once the grace window
    ///         past this has elapsed.
    uint64 public lastPushAt;

    /// @notice How long the keeper gets the fee lane to itself before anyone may sweep it.
    ///
    /// @dev    Without this, `pushAll` was a free griefing tool: it forces `cut = 0`, so any
    ///         address could front-run the keeper for the price of gas, zero the pad's share,
    ///         and leave the keeper's own `push` reverting `NothingToPush` -- which aborted
    ///         that pool's entire distribution pass, not just its cut. Repeating it stopped a
    ///         pool paying its holders indefinitely.
    ///
    ///         The window is short because the escape hatch is the point: if the keeper dies,
    ///         holders must still be able to force the fees through. Six hours is long enough
    ///         that a crank on any sane schedule is never raced, and short enough that a dead
    ///         keeper is routed around the same day.
    uint64 public constant PUSH_GRACE = 6 hours;

    event CreatorAccepted(bytes32 indexed poolId);
    event Pushed(uint256 claimed, uint256 cut, uint256 toTreasury);

    constructor(SplitterConfig memory c) {
        if (
            address(c.hook) == address(0) || c.token == address(0) || c.weth == address(0)
                || c.treasury == address(0) || c.feeRecipient == address(0) || c.keeper == address(0)
                || c.metadataAdmin == address(0)
        ) revert ZeroAddress();
        if (c.maxCutBps > MAX_CUT_BPS) revert CapTooLarge();
        hook = c.hook;
        poolId = c.poolId;
        token = c.token;
        quote = c.quote;
        weth = c.weth;
        // A natively-quoted pool pays ether; everything downstream deals in an ERC-20.
        payoutToken = c.quote == address(0) ? c.weth : c.quote;
        treasury = c.treasury;
        feeRecipient = c.feeRecipient;
        keeper = c.keeper;
        metadataAdmin = c.metadataAdmin;
        maxCutBps = c.maxCutBps;
    }

    /// @notice Ether from `LaunchHook._pay` on a natively-quoted pool.
    ///
    /// @dev    Refused outright on an ERC-20-quoted splitter. `_push` only wraps when the pool
    ///         is natively quoted, so ether arriving at a WETH-quoted splitter would sit in a
    ///         contract with no owner, no sweep and no rescue -- gone for good. Better to
    ///         bounce the transfer than to accept money we cannot ever move.
    receive() external payable {
        if (quote != address(0)) revert NotNative();
    }

    /// @notice Complete the handover the creator started with `transferCreator(poolId, this)`.
    ///         Permissionless: the hook already checks this contract is the nominee, so there
    ///         is nothing left to authorise and no reason to make the creator wait on us.
    function acceptCreator() external {
        hook.acceptCreator(poolId);
        emit CreatorAccepted(poolId);
    }

    /// @notice Pull the accrued creator fee, take the pad's cut, and fund the treasury.
    ///
    /// @param  cut What the pad keeps from this push, in `payoutToken` units — the keeper's
    ///         measured gas for the epoch plus the platform share. Computed off chain, because
    ///         gas is not knowable on chain, and bounded here by `maxCutBps` of what actually
    ///         arrived so the freedom to measure is not a freedom to take.
    function push(uint256 cut) external returns (uint256 claimed, uint256 sent) {
        if (msg.sender != keeper) revert NotKeeper();
        return _push(cut);
    }

    /// @notice Push everything, taking nothing.
    ///
    /// @dev    Permissionless and uncapped in reach, which is the liveness guarantee: if the
    ///         keeper key is lost, compromised, or simply switched off, any holder can still
    ///         force the fees through to the treasury where the claim path can reach them.
    ///         The pad forgoes its cut in that case, which is the correct incentive — the cut
    ///         is payment for running the crank, and nobody ran it.
    function pushAll() external returns (uint256 claimed, uint256 sent) {
        // The keeper's own window. Before it elapses this would be a way to zero the pad's
        // cut and revert the keeper's pass; after it, it is the liveness guarantee.
        uint64 openAt = lastPushAt + PUSH_GRACE;
        if (lastPushAt != 0 && block.timestamp < openAt) revert StillKeepersTurn(openAt);
        return _push(0);
    }

    function _push(uint256 cut) private returns (uint256 claimed, uint256 sent) {
        // Only claim once the handover has completed. Before that `hook.claim` reverts
        // `NotCreator`, which would take the whole call with it -- including the sweep of
        // anything mistakenly sent here while the pair was half set up.
        if (hook.creatorOf(poolId) == address(this)) {
            // Settles internally and pays regardless, so this books pending fees too.
            claimed = hook.claim(poolId, address(this));
        }

        if (quote == address(0)) {
            uint256 bal = address(this).balance;
            if (bal != 0) {
                IWETH9(weth).deposit{value: bal}();
                if (address(this).balance != 0) revert WrapFailed();
            }
        }

        // Measured from the balance rather than from `claimed`, so anything left behind by an
        // earlier failed push, or sent here directly, is swept along rather than stranded in a
        // contract with no owner and no rescue.
        uint256 amount = IERC20(payoutToken).balanceOf(address(this));
        if (amount == 0) revert NothingToPush();

        uint256 max = (amount * maxCutBps) / BPS;
        if (cut > max) revert CutTooLarge(cut, max);

        lastPushAt = uint64(block.timestamp);
        if (cut != 0) IERC20(payoutToken).safeTransfer(feeRecipient, cut);
        sent = amount - cut;
        // A bare transfer is all the treasury needs: it sizes each period from its own balance.
        if (sent != 0) IERC20(payoutToken).safeTransfer(treasury, sent);
        emit Pushed(claimed, cut, sent);
    }

    /// @notice Edit the launched token's metadata — website, X, Telegram, description, icon.
    ///
    /// @dev    Restricted to the creator who deployed this splitter. `LaunchToken` gates on
    ///         `hook.creatorOf(poolId)`, which is this contract after the handover, so without
    ///         this forwarder the creator would lose metadata control as a side effect of
    ///         routing their fees. That would be a bad trade to spring on them.
    function setMetadataURI(string calldata newURI) external {
        if (msg.sender != metadataAdmin) revert NotCreator();
        ILaunchTokenMetadata(token).setMetadataURI(newURI);
    }

    /// @notice Whether the handover has completed and this contract now owns the fee lane.
    function isWired() external view returns (bool) {
        return hook.creatorOf(poolId) == address(this);
    }
}
