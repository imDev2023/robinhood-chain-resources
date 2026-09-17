// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {IQuoteRegistry, QuoteTier} from "./interfaces/IQuoteRegistry.sol";
import {LaunchDividendTreasury} from "./LaunchDividendTreasury.sol";
import {CreatorFeeSplitter, ILaunchHookCreatorLane, SplitterConfig, MAX_CUT_BPS} from "./CreatorFeeSplitter.sol";

interface ILaunchFactoryLaunches {
    function launches(bytes32 poolId)
        external
        view
        returns (
            address token,
            address creator,
            address quote,
            bytes32 poolId_,
            int24 tickLower,
            int24 tickUpper,
            int24 tickSpacing,
            uint128 liquidity,
            uint64 launchedAt
        );
}

/// @notice Deploys a pool's dividend pair — treasury and splitter — in one transaction.
///
/// @dev    The point of routing this through a contract rather than two scripted deploys is
///         that the pair is DERIVED, not asserted. Token and quote are read from
///         `LaunchFactory.launches(poolId)`, so a caller cannot point a splitter at one pool
///         and a treasury at another token's asset, and cannot nominate themselves as the
///         metadata admin for somebody else's launch. Everything a caller supplies is either
///         checked against the factory or bounded by a constant.
///
///         Deployment is permissionless but the RESULT is not a claim on anything: deploying a
///         pair for a pool you do not own gets you two contracts that can never be funded,
///         because only the pool's real creator can call `transferCreator`. That is why this
///         needs no access control and why the registry below records the first pair per pool
///         rather than letting anyone overwrite it.
contract DividendDeployer is Ownable2Step {
    error UnknownPool();
    error AlreadyDeployed(address treasury);
    error NotPoolCreator(address creator);
    error ZeroAddress();
    error CapTooLarge();
    error QuoteNotSupported(address quote);
    error RenounceDisabled();

    ILaunchFactoryLaunches public immutable launchFactory;
    ILaunchHookCreatorLane public immutable hook;
    address public immutable weth;
    IQuoteRegistry public immutable quotes;

    /// @notice Where the pad's cut and the keeper's recovered gas land. Owner-settable because
    ///         it is an operational address, not a promise to holders.
    address public feeRecipient;
    /// @notice The hot key that runs every treasury's periods and calls `push`.
    address public keeper;

    struct Pair {
        address treasury;
        address splitter;
    }

    mapping(bytes32 => Pair) public pairOf;

    event PairDeployed(
        bytes32 indexed poolId, address indexed token, address treasury, address splitter, address creator
    );
    event FeeRecipientSet(address indexed recipient);
    event KeeperSet(address indexed keeper);

    constructor(
        ILaunchFactoryLaunches launchFactory_,
        ILaunchHookCreatorLane hook_,
        IQuoteRegistry quotes_,
        address weth_,
        address initialOwner,
        address feeRecipient_,
        address keeper_
    ) Ownable(initialOwner) {
        if (
            address(launchFactory_) == address(0) || address(hook_) == address(0) || weth_ == address(0)
                || feeRecipient_ == address(0) || keeper_ == address(0)
        ) revert ZeroAddress();
        launchFactory = launchFactory_;
        hook = hook_;
        quotes = quotes_;
        weth = weth_;
        feeRecipient = feeRecipient_;
        keeper = keeper_;
    }

    /// @notice Deploy the treasury and splitter for `poolId`.
    ///
    /// @dev    Callable only by the pool's current creator. Not for gatekeeping — a stranger's
    ///         pair would be inert anyway — but because the splitter records a permanent
    ///         `metadataAdmin`, and that has to be the person who will still want to edit the
    ///         token's links after the handover. Deriving it from the caller and checking the
    ///         caller against the factory is the only way to get that right without trusting an
    ///         argument.
    ///
    /// @param  minDistribution Floor a period must clear before it opens, in the quote's own
    ///         base units. The site computes the ether-equivalent default; the treasury owner
    ///         can retune it later.
    /// @param  maxCutBps Ceiling on what the pad may divert per push, agreed here by the
    ///         creator and immutable afterwards. Bounded by `MAX_CUT_BPS`.
    function deployFor(bytes32 poolId, uint256 minDistribution, uint256 maxCutBps)
        external
        returns (address treasury, address splitter)
    {
        Pair memory existing = pairOf[poolId];
        if (existing.treasury != address(0)) revert AlreadyDeployed(existing.treasury);

        (address token,, address quote,,,,,,) = launchFactory.launches(poolId);
        if (token == address(0)) revert UnknownPool();
        // ONLY the hook's current creator. The factory's record is the original launcher and
        // never changes, so accepting it too let a creator who had already SOLD the project
        // come back, deploy the pair first, and write themselves in as `metadataAdmin`
        // permanently -- while `pairOf` is first-come with no overwrite, so the real owner
        // could never deploy their own. The hook is the only source that tracks a handover.
        address current = hook.creatorOf(poolId);
        if (msg.sender != current) revert NotPoolCreator(current);
        // Checked here as well as in the splitter's own constructor: failing before two
        // contracts are deployed is cheaper than failing after one of them is.
        if (maxCutBps > MAX_CUT_BPS) revert CapTooLarge();

        // Refuse a quote whose balances move on their own.
        //
        // The treasury books `purchased` once and holds `reserved` as a fixed number. A stock
        // token's balance scales with its ERC-8056 multiplier, so a downward move leaves the
        // real balance below what is reserved -- every transfer then soft-fails and the whole
        // period strands until it expires. "Rebasing quotes are unsupported" has to be
        // ENFORCED, not merely written down, because the launch form offers ten of them.
        if (quote != address(0) && quotes.policyFor(Currency.wrap(quote)).tier == QuoteTier.STOCK) {
            revert QuoteNotSupported(quote);
        }

        // A natively-quoted pool is paid in ether and wrapped by the splitter, so the treasury
        // always deals in an ERC-20 and never needs a `receive()`.
        address payout = quote == address(0) ? weth : quote;

        LaunchDividendTreasury t = new LaunchDividendTreasury(owner(), IERC20(payout), keeper, minDistribution);
        CreatorFeeSplitter s = new CreatorFeeSplitter(
            SplitterConfig({
                hook: hook,
                poolId: poolId,
                token: token,
                quote: quote,
                weth: weth,
                treasury: address(t),
                feeRecipient: feeRecipient,
                keeper: keeper,
                metadataAdmin: msg.sender,
                maxCutBps: maxCutBps
            })
        );

        pairOf[poolId] = Pair({treasury: address(t), splitter: address(s)});
        emit PairDeployed(poolId, token, address(t), address(s), msg.sender);
        return (address(t), address(s));
    }

    /// @notice Renouncing would zero `owner()`, and `deployFor` constructs every treasury with
    ///         it -- so the next call reverts and no pair can ever be created again, with no
    ///         way to set a fee recipient or keeper either.
    function renounceOwnership() public view override onlyOwner {
        revert RenounceDisabled();
    }

    function setFeeRecipient(address recipient) external onlyOwner {
        if (recipient == address(0)) revert ZeroAddress();
        feeRecipient = recipient;
        emit FeeRecipientSet(recipient);
    }

    /// @dev Changes the keeper for FUTURE pairs only. Existing splitters hold theirs
    ///      immutably, and existing treasuries are retuned through their own `setKeeper` by
    ///      their owner — which is deliberate: rotating one key must not silently rewire every
    ///      contract already promising holders something.
    function setKeeper(address newKeeper) external onlyOwner {
        if (newKeeper == address(0)) revert ZeroAddress();
        keeper = newKeeper;
        emit KeeperSet(newKeeper);
    }
}
