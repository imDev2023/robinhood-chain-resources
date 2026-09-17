// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ExactTransfer} from "./lib/ExactTransfer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IFeeSource {
    /// @dev The one-argument overload, selector 0xbd66528a, which pays the
    ///      caller. This is the one every deployed hook implements; the
    ///      two-argument `claim(bytes32,address)` is not universally present, so
    ///      it must not be called from here.
    function claim(bytes32 poolId) external returns (uint256 amount);
}

/// @title CashCatLaunchSplitter
/// @notice Receives one launch's creator fee stream and divides it between up
///         to four recipients on shares fixed at launch.
///
/// @dev    Deployed once and cloned per launch, so a clone's code is whatever
///         this file compiled to on the day the factory was pointed at it. A
///         clone cannot be upgraded, and that is the property being bought
///         rather than a limitation being tolerated: the shares are the promise
///         the launch made, and a promise that can be edited is not one.
///
///         Deliberately not `CashCatRevenueSplitter`. That contract runs the
///         platform's own treasury and its owner can move both the split and
///         the funds, which is right for a treasury and wrong for a per-token
///         commitment. Nothing here has an owner.
///
///         Trust model — the shares cannot change, ever, by any caller. The
///         payout addresses can be rotated, but only by the recipient that
///         holds one, and only over their own slot. Nobody can redirect
///         somebody else's share, and there is no admin who can redirect any
///         of them. A creator who splits fees with a charity cannot later take
///         the charity's share back.
///
///         The stream is fixed for the life of the launch. A clone cannot hand
///         it on, so the address the hook pays is the address it will always
///         pay, and there is nothing that can move it — including if a quote
///         asset freezes this address, in which case the balance held here
///         stops being reachable. Rotation moves where a recipient's share is
///         sent; it does not move the splitter.
contract CashCatLaunchSplitter is ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice Which generation of splitter master this is. See
    ///         `CashCatTokenV2.GENERATION`.
    uint256 public constant GENERATION = 2;
    uint256 public constant BPS_DENOMINATOR = 10_000;
    /// @dev Four is a product decision, enforced here so it cannot be widened
    ///      by a factory that thinks otherwise. Every extra recipient is gas on
    ///      every distribution, paid by whoever pokes it.
    uint256 public constant MAX_RECIPIENTS = 4;

    error AlreadyInitialized();
    /// @dev The master is a template, not a splitter. Only clones initialize.
    error MasterCannotBeInitialized();
    error NotInitialized();
    error InvalidRecipientCount();
    error SharesMustSumToDenominator();
    error ZeroShare();
    error ZeroAddress();
    error DuplicateRecipient();
    error SelfReference();
    error NotARecipient();
    error NothingOwed();
    /// @dev The slot holds a balance and the amount asked for is not part of it.
    error AmountNotOwed(uint256 requested, uint256 owed);
    error EthTransferFailed();
    error UnexpectedEth();

    event Initialized(address indexed feeSource, bytes32 indexed poolId, address quote, address[] recipients, uint16[] shares);
    event Distributed(uint256 amount, uint256 dust);
    event ClaimFailed(bytes32 indexed poolId);
    event Collected(address indexed recipient, address indexed to, uint256 amount);
    event PayoutAddressRotated(uint256 indexed slot, address indexed from, address indexed to);

    /// @notice The hook this splitter claims from.
    address public feeSource;
    /// @notice The pool whose creator stream lands here.
    bytes32 public poolId;
    /// @notice Payout asset. `address(0)` means native ETH.
    address public quote;

    /// @notice Payout addresses, by slot. Rotatable by the holder of the slot.
    address[] public recipients;
    /// @notice Shares in bps, by slot. Never changes.
    uint16[] public shares;

    /// @notice Allocated and unclaimed, by current payout address.
    mapping(address => uint256) public owed;
    /// @dev Slot index plus one, so zero reads as "not a recipient".
    mapping(address => uint256) private _slotOf;

    /// @notice Total ever allocated to recipients, and total ever collected.
    ///         Kept for the conservation property rather than for logic.
    uint256 public totalAllocated;
    uint256 public totalCollected;

    /// @notice True only on the master. A clone reads false.
    ///
    /// @dev    Storage rather than `immutable`: an EIP-1167 clone executes the
    ///         master's code, so an immutable baked into that code would read
    ///         true from every clone. Storage is per-clone and starts empty.
    ///
    ///         Set in the constructor, which clones never run, so the master
    ///         cannot be initialized and publication can identify one
    ///         positively rather than inferring it from an unset `feeSource`.
    bool public isMaster;

    /// @dev Locks the master. Clones never run this.
    constructor() {
        isMaster = true;
    }

    /// @notice Sets the split. Callable once, by the factory, at launch.
    /// @dev    No owner and no second call: after this returns the shares are
    ///         final for the life of the clone.
    function initialize(
        address feeSource_,
        bytes32 poolId_,
        address quote_,
        address[] memory recipients_,
        uint16[] memory shares_
    ) external {
        if (isMaster) revert MasterCannotBeInitialized();
        if (feeSource != address(0)) revert AlreadyInitialized();
        if (feeSource_ == address(0)) revert ZeroAddress();
        if (recipients_.length == 0 || recipients_.length > MAX_RECIPIENTS) revert InvalidRecipientCount();
        if (recipients_.length != shares_.length) revert InvalidRecipientCount();

        uint256 total;
        for (uint256 i; i < recipients_.length; ++i) {
            address r = recipients_[i];
            if (r == address(0)) revert ZeroAddress();
            // A zero share is a recipient who can never collect. It is always a
            // mistake at the call site, so it is rejected rather than stored.
            if (shares_[i] == 0) revert ZeroShare();
            // Two slots for one address would still pay correctly, because
            // `owed` accumulates. It is rejected anyway: rotation is per-slot,
            // so a duplicate makes "rotate my slot" ambiguous to the holder.
            if (_slotOf[r] != 0) revert DuplicateRecipient();
            // This clone's own address is derivable before the launch, so a
            // creator can name it here. That slot would accrue forever and
            // reach nobody, because nothing ever calls `collect` on its own
            // behalf. There is no use for it, and the mistake is silent.
            if (r == address(this)) revert SelfReference();

            _slotOf[r] = i + 1;
            recipients.push(r);
            shares.push(shares_[i]);
            total += shares_[i];
        }
        if (total != BPS_DENOMINATOR) revert SharesMustSumToDenominator();

        feeSource = feeSource_;
        poolId = poolId_;
        quote = quote_;

        emit Initialized(feeSource_, poolId_, quote_, recipients_, shares_);
    }

    /// @notice Pulls whatever the hook owes this launch and allocates it.
    ///         Permissionless, because sweeping already is and there is no
    ///         reason for the division to be gated when the shares are fixed.
    /// @dev    Claims first, then allocates the contract's whole balance rather
    ///         than the claimed amount. Anything sent here directly, and any
    ///         dust left by a previous rounding, is therefore picked up on the
    ///         next pass instead of being stranded.
    function distribute() external nonReentrant returns (uint256 amount) {
        if (feeSource == address(0)) revert NotInitialized();

        // A claim with nothing behind it is a no-op rather than a failure, so
        // a poker does not have to guess whether fees have accrued.
        //
        // A claim that genuinely fails is announced rather than swallowed.
        // This splitter is its pool's recipient for the life of the launch, so
        // the cause is not that the stream moved: it is that the hook's payout
        // to this address reverted, which in practice means the quote asset has
        // frozen it. An operator needs to see that. Distribution continues
        // either way, so a balance already received is never held hostage.
        //
        try IFeeSource(feeSource).claim(poolId) returns (uint256) {}
        catch {
            emit ClaimFailed(poolId);
        }

        /*
         * What is here and not yet spoken for.
         *
         * Saturating rather than a bare subtraction. The balance covers
         * `totalAllocated - totalCollected` while every payout debits exactly
         * what it settles, which `_pay` enforces. Were it ever to fall below,
         * a checked subtraction would revert here permanently and take every
         * future distribution with it; clamping reports nothing new to divide,
         * which is the truth in that state, and leaves allocated balances
         * reachable through `collect`.
         */
        uint256 booked = totalAllocated - totalCollected;
        uint256 held = _balance();
        uint256 pot = held > booked ? held - booked : 0;
        if (pot == 0) return 0;

        uint256 handedOut;
        uint256 n = recipients.length;
        // The last slot takes the remainder instead of its exact share, so the
        // parts sum to the whole. Truncation dust is a wei or two per pass, but
        // over a token's life it is the difference between an accounting
        // identity that holds and one that drifts.
        for (uint256 i; i < n - 1; ++i) {
            uint256 cut = (pot * shares[i]) / BPS_DENOMINATOR;
            owed[recipients[i]] += cut;
            handedOut += cut;
        }
        uint256 last = pot - handedOut;
        owed[recipients[n - 1]] += last;

        totalAllocated += pot;
        amount = pot;
        emit Distributed(pot, last - (pot * shares[n - 1]) / BPS_DENOMINATOR);
    }

    /// @notice Takes the caller's allocated balance to an address they name.
    /// @dev    Naming a destination matters for the same reason it does on the
    ///         hook: a recipient may be a contract that cannot itself receive
    ///         the asset. Without this, such a slot would accrue forever and
    ///         reach nobody.
    function collect(address to) public returns (uint256) {
        return collect(to, owed[msg.sender]);
    }

    /// @notice Takes part of the caller's allocated balance to an address they
    ///         name, so a slot can be drained in pieces rather than one move.
    ///
    /// @dev    Naming an amount is what survives a quote that caps the size of
    ///         a single transfer. All-or-nothing means such a slot dies the
    ///         moment its balance passes the cap: every payout attempts one
    ///         oversized transfer, the token refuses it, the revert rolls the
    ///         ledger write back, and the figure that caused it is still there.
    ///         Naming a destination does not help, because the refusal is keyed
    ///         to the amount and not to who is receiving it, and rotating the
    ///         slot carries the whole balance across rather than dividing it.
    ///
    ///         It is not only a grief. A slot crosses the cap on ordinary
    ///         accrual as soon as a launch earns more than one transfer's worth
    ///         between collects — anyone topping the balance up only makes it
    ///         immediate and cheap. So refusing donations would not have been a
    ///         fix; being able to take less than everything is.
    ///
    ///         Each piece still goes out through `_pay`, so the exactness the
    ///         contract promises is per transfer and unchanged, and
    ///         `totalCollected` still rises by exactly what left.
    function collect(address to, uint256 amount) public nonReentrant returns (uint256) {
        if (to == address(0)) revert ZeroAddress();
        // Collecting to this contract is not a payout, it is a donation to
        // everybody. The transfer is a self-transfer so the balance does not
        // move, but `totalCollected` rises, which puts the same money back in
        // the undivided pot to be split again on the next pass — the caller
        // gives away most of their own share and keeps their slot's fraction
        // of it. `initialize` and `rotate` both refuse this address for the
        // same reason; this was the one that did not.
        if (to == address(this)) revert SelfReference();

        uint256 booked = owed[msg.sender];
        if (booked == 0) revert NothingOwed();
        // Separate from `NothingOwed`, which says the slot is empty. This says
        // the slot holds something and the caller asked for a figure that is
        // not part of it.
        if (amount == 0 || amount > booked) revert AmountNotOwed(amount, booked);

        owed[msg.sender] = booked - amount;
        totalCollected += amount;

        _pay(to, amount);
        emit Collected(msg.sender, to, amount);
        return amount;
    }

    /// @notice Takes the caller's allocated balance to themselves.
    function collect() external returns (uint256) {
        return collect(msg.sender);
    }

    /// @notice Moves one slot's future and pending payouts to a new address.
    ///         Only the address currently holding the slot may do this.
    /// @dev    Recipient-controlled on purpose. Creator-controlled rotation,
    ///         with or without a delay, would let whoever launched the token
    ///         redirect a share they had already promised away; a timelock
    ///         announces that but does not prevent it.
    function rotate(address to) external nonReentrant {
        uint256 slotPlusOne = _slotOf[msg.sender];
        if (slotPlusOne == 0) revert NotARecipient();
        if (to == address(0)) revert ZeroAddress();
        if (to == address(this)) revert SelfReference();
        if (_slotOf[to] != 0) revert DuplicateRecipient();

        uint256 slot = slotPlusOne - 1;
        // Pending balance moves with the slot. Leaving it behind would strand
        // it on an address the holder is abandoning, usually because they can
        // no longer use it.
        uint256 pending = owed[msg.sender];
        owed[msg.sender] = 0;
        owed[to] += pending;

        _slotOf[msg.sender] = 0;
        _slotOf[to] = slotPlusOne;
        recipients[slot] = to;

        emit PayoutAddressRotated(slot, msg.sender, to);
    }

    // ————————————————— views —————————————————

    function recipientCount() external view returns (uint256) {
        return recipients.length;
    }

    function split() external view returns (address[] memory, uint16[] memory) {
        return (recipients, shares);
    }

    function slotOf(address who) external view returns (uint256 slot, bool isRecipient) {
        uint256 s = _slotOf[who];
        return (s == 0 ? 0 : s - 1, s != 0);
    }

    /// @notice Claimed but not yet allocated. Non-zero only between a direct
    ///         transfer in and the next `distribute`.
    function unallocated() external view returns (uint256) {
        // Clamped for the same reason `distribute` is: a view that reverts is
        // a view every caller has to wrap, and it would revert in exactly the
        // state somebody is trying to diagnose.
        uint256 booked = totalAllocated - totalCollected;
        uint256 held = _balance();
        return held > booked ? held - booked : 0;
    }

    // ————————————————— internals —————————————————

    function _balance() internal view returns (uint256) {
        return quote == address(0) ? address(this).balance : IERC20(quote).balanceOf(address(this));
    }

    /// @dev One balance stands behind up to four separate liabilities, so a
    ///      transfer debiting more than the amount it settles leaves the
    ///      shortfall with whoever collects last. The debit is required to be
    ///      exact. Callers clear their books before paying, so the check runs
    ///      after them and unwinds both together when it fails.
    function _pay(address to, uint256 amount) internal {
        if (quote == address(0)) {
            (bool ok,) = to.call{value: amount}("");
            if (!ok) revert EthTransferFailed();
        } else {
            ExactTransfer.payExact(IERC20(quote), to, amount);
        }
    }

    /// @dev Accepts ETH only when ETH is the payout asset. A stablecoin launch
    ///      that somehow received ETH would have it counted by nothing and
    ///      recoverable by nobody, so the transfer is refused instead.
    receive() external payable {
        if (quote != address(0)) revert UnexpectedEth();
    }
}
