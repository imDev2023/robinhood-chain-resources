// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

/// @notice One pool's trading fees, paid out to that token's holders.
///
/// @dev    Adapted from `SimpleRewardTreasury` in the hood10-lite repo, which is the same
///         contract family already running the HOOD10 index in production — the deployment at
///         0x9f3edbfAE8014d55E328b6Dd966C6C95E75f6210 has settled twenty-two periods. What is
///         kept is the part that has been exercised: the period lifecycle, the Merkle
///         entitlement, the reservation ledger, the per-period clamp, idempotent claims, and
///         soft-failing payouts.
///
///         THREE THINGS ARE DELIBERATELY DIFFERENT, and each removes a hazard the launchpad
///         has that the index does not.
///
///         1. NO BASKET, NO ROUTES. The index buys ten reward tokens through owner-supplied
///            router calldata. Here the reward IS the pool's quote asset, already in hand, so
///            `openClaims` books the balance and no swap happens at all. That deletes the
///            arbitrary-call primitive: there is no `router.call(data)` anywhere in this file.
///            On the index that primitive is guarded and acceptable; replicated across one
///            immutable contract per launch, behind a single operator key, it would mean one
///            key compromise drains every treasury at once. It is not here to be compromised.
///
///         2. NO PROTOCOL-FEE LEG. The index splits each pot and transfers the protocol share
///            on the way through. Because that share is fixed at zero it still executes
///            `safeTransfer(recipient, 0)` on every buy, and OpenZeppelin does not short-circuit
///            a zero value — so a quote token that reverts on a zero-value transfer would brick
///            the treasury permanently, on a contract with no proxy and no pause. The launchpad
///            accepts effectively any ERC-20 as a quote, so that is a live risk here and was not
///            one for WETH. The platform cut and the keeper's gas are taken UPSTREAM, before
///            funding, so this contract never performs a zero-value transfer.
///
///         3. TWO KEYS, NOT ONE. The index collapses every role onto the owner. Here the owner
///            is cold — it can move ownership, retune the threshold, and sweep — while a
///            separate keeper runs the periods and can do nothing else. The keeper is the key
///            that has to sit in a server process; it must not also be the key that can walk
///            away with the balance.
///
///         WHAT THE OWNER AND KEEPER CAN STILL DO, stated plainly rather than buried: the
///         keeper commits the Merkle root, and nothing on chain checks that the root reflects
///         real balances. A dishonest root can direct a period's pot anywhere. The bound is the
///         per-period clamp — a period can never pay out more than it took in, and can never
///         reach another period's backing — so the damage is confined to the pot the keeper was
///         already trusted with. The owner can sweep anything not backing an open claim. Both
///         are the same trust model the index has run under, and the same one every rival on
///         this chain uses; it is not trustless and should not be described as such.
contract LaunchDividendTreasury is Ownable2Step, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice How long a period stays claimable before the owner may release the remainder.
    ///         Matches the index's window, for one operational calendar across both products.
    uint64 public constant CLAIM_WINDOW = 180 days;

    enum Status {
        Collecting,
        Closed,
        RootCommitted,
        Claimable,
        Settled
    }

    struct Period {
        Status status;
        uint64 openedAt;
        bytes32 root;
        uint256 eligibleWeight;
        /// @dev The quote booked into this period. Fixed at `openClaims` and never revised —
        ///      later inflow belongs to later periods, which is what makes the clamp below a
        ///      real bound rather than an accounting convention.
        uint256 purchased;
        uint256 distributed;
    }

    error InvalidState();
    error UnknownPeriod();
    error InvalidRoot();
    error InvalidProof();
    error NothingToClaim();
    error BelowMinimum(uint256 available, uint256 required);
    error ClaimWindowStillOpen();
    error ZeroAddress();
    error ArrayMismatch();
    error NotKeeper();
    error RenounceDisabled();
    error SweepExceedsUnreserved();

    /// @notice The asset holders are paid in: the pool's quote currency. A natively-quoted pool
    ///         is served by its splitter wrapping to WETH first — this contract is ERC-20 only
    ///         and has no `receive()`, so ether cannot arrive here and cannot be stranded here.
    IERC20 public immutable quote;

    /// @notice Runs periods. Cannot move funds, cannot change configuration, cannot take
    ///         ownership. Held by the crank process.
    address public keeper;

    /// @notice The floor a period must clear before it may open for claims, in `quote` base
    ///         units. Distributing less than this costs more in gas and attention than it moves.
    ///
    /// @dev    Denominated in the quote rather than in ether because the two are not
    ///         convertible on chain without an oracle, and an oracle is a dependency this
    ///         contract does not need: the keeper knows the ether price of every quote asset
    ///         already and sets this to match. Owner-settable, because a pad-wide number cannot
    ///         be right for both a WETH pool and one quoted in a token worth 0.0000008 ETH.
    uint256 public minDistribution;

    uint256 public currentPeriodId = 1;

    /// @notice Quote owed to open claims across every unsettled period. `sweep` can never reach
    ///         it, which is what stops the owner spending a holder's booked entitlement.
    uint256 public reserved;

    mapping(uint256 => Period) private _periods;
    /// @notice periodId => account => quote already paid. The idempotence of both payout paths.
    mapping(uint256 => mapping(address => uint256)) public paidOut;

    event KeeperSet(address indexed keeper);
    event MinDistributionSet(uint256 amount);
    event PeriodClosed(uint256 indexed id);
    event RootCommitted(uint256 indexed id, bytes32 root, uint256 eligibleWeight);
    event ClaimsOpened(uint256 indexed id, uint256 amount);
    event Paid(uint256 indexed id, address indexed account, uint256 amount, bool pushed);
    event PeriodSettled(uint256 indexed id, uint256 released);
    event Swept(address indexed token, address indexed to, uint256 amount);

    modifier onlyKeeper() {
        if (msg.sender != keeper) revert NotKeeper();
        _;
    }

    constructor(address initialOwner, IERC20 quote_, address keeper_, uint256 minDistribution_)
        Ownable(initialOwner)
    {
        if (address(quote_) == address(0) || keeper_ == address(0)) revert ZeroAddress();
        quote = quote_;
        keeper = keeper_;
        minDistribution = minDistribution_;
        emit KeeperSet(keeper_);
        emit MinDistributionSet(minDistribution_);
    }

    // ─────────────────────────────── lifecycle ───────────────────────────────

    /// @notice Draw a line under what has accrued. Everything arriving after this belongs to
    ///         the next period.
    function closePeriod() external onlyKeeper returns (uint256 id) {
        id = currentPeriodId;
        if (_periods[id].status != Status.Collecting) revert InvalidState();
        _periods[id].status = Status.Closed;
        unchecked {
            currentPeriodId = id + 1;
        }
        emit PeriodClosed(id);
    }

    /// @notice Commit the Merkle root over (account, weight) leaves, and the weight total.
    ///
    /// @dev    One-shot: a period whose root is committed cannot have it replaced, so a root
    ///         that survived review cannot be swapped afterwards. Zero eligible weight settles
    ///         immediately rather than leaving a period that can never open — which happens
    ///         genuinely often here, because a fresh pool's float can be entirely the pool.
    function commitRoot(uint256 id, bytes32 root, uint256 eligibleWeight) external onlyKeeper {
        Period storage p = _period(id);
        if (p.status != Status.Closed) revert InvalidState();
        if (eligibleWeight == 0) {
            p.status = Status.Settled;
            emit PeriodSettled(id, 0);
            return;
        }
        if (root == bytes32(0)) revert InvalidRoot();
        p.root = root;
        p.eligibleWeight = eligibleWeight;
        p.status = Status.RootCommitted;
        emit RootCommitted(id, root, eligibleWeight);
    }

    /// @notice Void a committed root before any quote is booked against it. Terminal, and the
    ///         owner's rather than the keeper's: it is the correction for a root the keeper got
    ///         wrong, so the key that produced the mistake should not be the one that erases it.
    function abortRoot(uint256 id) external onlyOwner {
        Period storage p = _period(id);
        if (p.status != Status.RootCommitted) revert InvalidState();
        p.status = Status.Settled;
        emit PeriodSettled(id, 0);
    }

    /// @notice Book the accrued quote against the committed root and open the period for
    ///         payout. This is where `SimpleRewardTreasury` would buy a basket; there is
    ///         nothing to buy, because the reward is the asset already sitting here.
    ///
    /// @param  maxIn Cap on what this period may take, so a period opened against a root
    ///         computed at block N cannot absorb fees that arrived at N+1 and belong to the
    ///         holders of the next period. Pass the balance observed when the root was built.
    function openClaims(uint256 id, uint256 maxIn) external onlyKeeper nonReentrant {
        Period storage p = _period(id);
        if (p.status != Status.RootCommitted) revert InvalidState();

        uint256 balance = quote.balanceOf(address(this));
        uint256 res = reserved;
        uint256 liquid = balance > res ? balance - res : 0;
        if (liquid > maxIn) liquid = maxIn;
        if (liquid < minDistribution || liquid == 0) revert BelowMinimum(liquid, minDistribution);

        p.status = Status.Claimable;
        p.openedAt = uint64(block.timestamp);
        p.purchased = liquid;
        reserved = res + liquid;
        emit ClaimsOpened(id, liquid);
    }

    /// @notice After the claim window, release whatever nobody took and end the period.
    ///         The quote stays here, unreserved, and rolls into the next period's pot.
    function settleExpired(uint256 id) external onlyOwner {
        Period storage p = _period(id);
        if (p.status != Status.Claimable) revert InvalidState();
        if (block.timestamp < uint256(p.openedAt) + CLAIM_WINDOW) revert ClaimWindowStillOpen();
        uint256 remaining = p.purchased - p.distributed;
        if (remaining != 0) reserved -= remaining;
        p.status = Status.Settled;
        emit PeriodSettled(id, remaining);
    }

    // ──────────────────────────────── payout ────────────────────────────────

    /// @notice Push payouts to holders. The airdrop: holders do nothing and receive.
    ///
    /// @dev    Proofs are required even though the keeper committed the root, and that is not
    ///         redundant. Without them the keeper could pay any address it liked up to the
    ///         pot; with them, a push can only ever land on an account the committed root
    ///         actually names, for no more than that account's proven share. It is the same
    ///         entitlement path `claim` runs, so there is one set of arithmetic to be wrong.
    ///
    ///         Per-recipient failure isolation matters more here than in a claim: one holder
    ///         that cannot receive the quote must not abort the other ninety-nine in the batch.
    ///         Measured on the index, a push run completes between 48% and 99.99% of its
    ///         recipients — never assume one pass finishes, and never let one failure revert
    ///         the pass.
    function pushBatch(
        uint256 id,
        address[] calldata accounts,
        uint256[] calldata weights,
        bytes32[][] calldata proofs
    ) external onlyKeeper nonReentrant returns (uint256 paidCount) {
        if (accounts.length != weights.length || accounts.length != proofs.length) revert ArrayMismatch();
        Period storage p = _period(id);
        if (p.status != Status.Claimable) revert InvalidState();
        for (uint256 i; i < accounts.length; ++i) {
            if (_payOut(p, id, accounts[i], weights[i], proofs[i], true)) ++paidCount;
        }
    }

    /// @notice Pull a holder's share. The fallback for anyone a push could not reach, and the
    ///         reason an undeliverable balance is never simply lost. Callable by anyone; the
    ///         quote always goes to `account`, so a third party can pay the gas for a holder.
    function claim(uint256 id, address account, uint256 weight, bytes32[] calldata proof)
        external
        nonReentrant
    {
        Period storage p = _period(id);
        if (p.status != Status.Claimable) revert InvalidState();
        if (!_payOut(p, id, account, weight, proof, false)) revert NothingToClaim();
    }

    /// @dev The single entitlement path. Returns false rather than reverting when there is
    ///      nothing to pay or the transfer refuses, so a batch can carry on.
    function _payOut(
        Period storage p,
        uint256 id,
        address account,
        uint256 weight,
        bytes32[] calldata proof,
        bool pushed
    ) private returns (bool) {
        if (account == address(0) || account == address(this) || weight == 0) {
            if (pushed) return false;
            revert InvalidProof();
        }
        // OZ StandardMerkleTree leaf: double-hashed abi.encode, which closes the
        // second-preimage trick where an internal node is passed off as a leaf.
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, weight))));
        if (!MerkleProof.verifyCalldata(proof, p.root, leaf)) {
            if (pushed) return false;
            revert InvalidProof();
        }

        uint256 entitlement = Math.mulDiv(p.purchased, weight, p.eligibleWeight);
        uint256 already = paidOut[id][account];
        if (entitlement <= already) return false;
        uint256 owed = entitlement - already;
        // Clamp to this period's own remainder. A wrong `eligibleWeight` can therefore
        // overpay early claimants WITHIN a period, but can never spend another period's
        // backing out of the shared reserve. This is the bound that makes an unverifiable
        // root survivable rather than catastrophic.
        uint256 remaining = p.purchased - p.distributed;
        if (owed > remaining) owed = remaining;
        if (owed == 0) return false;

        // Book before paying: the transfer is the last thing that happens, and the guard plus
        // this ordering means a re-entrant token cannot be paid twice for one entitlement.
        paidOut[id][account] = already + owed;
        p.distributed += owed;
        reserved -= owed;

        if (!_tryTransfer(account, owed)) {
            // Unwind. The holder stays owed and can be paid by a later push or their own
            // claim; a quote that refuses one recipient must not consume their entitlement.
            paidOut[id][account] = already;
            p.distributed -= owed;
            reserved += owed;
            return false;
        }
        emit Paid(id, account, owed, pushed);
        return true;
    }

    /// @dev A transfer that reports failure instead of propagating it. A revert, an explicit
    ///      `false`, or malformed return data all read as "could not pay this one".
    ///
    ///      Not gas-bounded, deliberately: a stipend that is too small silently converts a
    ///      solvent holder into an unpayable one, and the launchpad's quote assets are chosen
    ///      by creators rather than by us, so no stipend is right for all of them. The residual
    ///      is that a quote which burns all forwarded gas aborts the whole call — with a single
    ///      reward asset that can only ever block its own holders, which is the same set of
    ///      people the token was already failing.
    function _tryTransfer(address to, uint256 amount) private returns (bool) {
        (bool ok, bytes memory ret) = address(quote).call(abi.encodeCall(IERC20.transfer, (to, amount)));
        if (!ok) return false;
        if (ret.length == 0) return address(quote).code.length != 0;
        return ret.length == 32 && abi.decode(ret, (bool));
    }

    // ───────────────────────────── configuration ─────────────────────────────

    function setKeeper(address newKeeper) external onlyOwner {
        if (newKeeper == address(0)) revert ZeroAddress();
        keeper = newKeeper;
        emit KeeperSet(newKeeper);
    }

    function setMinDistribution(uint256 amount) external onlyOwner {
        minDistribution = amount;
        emit MinDistributionSet(amount);
    }

    /// @notice Move anything not backing an open claim.
    ///
    /// @dev    For the quote this is bounded by the reservation ledger, so a holder's booked
    ///         entitlement is unreachable. Any other token here arrived by accident — a
    ///         mistaken transfer, an airdrop — and is owed to nobody, so it is swept freely.
    function sweep(address token, address to, uint256 amount) external onlyOwner {
        if (to == address(0)) revert ZeroAddress();
        uint256 balance = IERC20(token).balanceOf(address(this));
        uint256 free = balance;
        if (token == address(quote)) {
            uint256 res = reserved;
            free = balance > res ? balance - res : 0;
        }
        if (amount > free) revert SweepExceedsUnreserved();
        IERC20(token).safeTransfer(to, amount);
        emit Swept(token, to, amount);
    }

    /// @notice Renouncing would freeze every unsettled period in a contract with no proxy and
    ///         no pause, and strand the reserve for good.
    function renounceOwnership() public view override onlyOwner {
        revert RenounceDisabled();
    }

    // ─────────────────────────────── views ───────────────────────────────

    function getPeriod(uint256 id) external view returns (Period memory) {
        return _periods[id];
    }

    /// @notice What `account` could take from period `id` right now, given its proven weight.
    ///         Mirrors `_payOut`'s arithmetic exactly, clamp included, so the UI and the
    ///         contract cannot disagree about what is owed.
    function previewClaim(uint256 id, address account, uint256 weight) external view returns (uint256) {
        Period storage p = _periods[id];
        if (p.status != Status.Claimable || p.eligibleWeight == 0) return 0;
        uint256 entitlement = Math.mulDiv(p.purchased, weight, p.eligibleWeight);
        uint256 already = paidOut[id][account];
        if (entitlement <= already) return 0;
        uint256 owed = entitlement - already;
        uint256 remaining = p.purchased - p.distributed;
        return owed > remaining ? remaining : owed;
    }

    /// @notice Quote sitting here that no open claim is entitled to — what the next period
    ///         would book if it opened now.
    function unreserved() external view returns (uint256) {
        uint256 balance = quote.balanceOf(address(this));
        uint256 res = reserved;
        return balance > res ? balance - res : 0;
    }

    function _period(uint256 id) private view returns (Period storage p) {
        if (id == 0 || id > currentPeriodId) revert UnknownPeriod();
        p = _periods[id];
    }
}
