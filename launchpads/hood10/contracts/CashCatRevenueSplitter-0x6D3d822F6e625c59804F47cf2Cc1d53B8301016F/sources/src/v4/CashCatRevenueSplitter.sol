// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {IUniswapV3SwapCallback} from "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";
import {IWETH9} from "./CashCatBuybackBurner.sol";

/// @title CashCatRevenueSplitter
/// @notice Receives the platform's share of every pool's fees and divides it
///         between two CASHCAT lanes and a set of participants paid in ETH.
///
///         Two lanes buy CASHCAT on the canonical pool: one sends it to the
///         dead address, one sends it to the CashCat treasury. Both are permissionless
///         cranks paying the caller a bounty, and the pool delivers the tokens
///         to their destination directly — this contract never custodies
///         CASHCAT for a single instruction.
///
///         Participants accrue ETH and withdraw it. Their share never routes
///         through a swap, so a thin or hostile CASHCAT pool cannot delay or
///         reduce what they are owed.
///
///         Splitting is lazy: whatever the balance holds beyond the tanks and
///         the tabs is fresh revenue, divided on the next touch. `receive` is
///         empty because a payment in must never revert — the fee engine
///         pushes the platform share inside a swap's own sweep, and the launch
///         fee arrives inside a launch.
///
///         **Two different treasuries, and they must not be confused.** This
///         contract is the launchpad's own treasury: the address the fee engine
///         pushes every pool's platform share to, and the thing
///         `CashCatHook.treasury` points at. The CashCat treasury is somewhere
///         else entirely, controlled by CASHCAT rather than by the launchpad,
///         and it receives tokens this contract buys for it. Money flows one
///         way, from here to there, and pointing the fee engine at the CashCat
///         treasury by mistake would send every pool's platform share to an
///         address that cannot divide it.
///
///         Trust model: this contract only ever holds the platform's own
///         revenue. No creator earnings, no holder funds and no trader's ETH
///         ever pass through it.
///
///         **A participant's tab is protected; a lane's tank is not.** Once
///         revenue is allocated to a participant, only that participant can
///         receive it. No owner call moves it, and that includes migration,
///         which sends the balance less every tab and so cannot reach one.
///
///         The lane tanks carry no such protection, and the difference is
///         larger than a redirection. `setCashcatTreasury` changes where the
///         treasury lane delivers CASHCAT its tank has already been funded to
///         buy. `migrate` sends every unspent wei of both tanks to whatever
///         address it is given: a successor splitter is the intended
///         destination, but nothing here requires one, and a plain wallet
///         receives it as ETH. So the owner can withdraw the lanes outright,
///         not only move them between platform uses.
///
///         What that reaches is the platform's own unspent revenue and nothing
///         else. Participant tabs are subtracted before it; creator earnings,
///         holder funds and pool liquidity are not in this contract at all.
contract CashCatRevenueSplitter is Ownable2Step, ReentrancyGuard, IUniswapV3SwapCallback {
    error NotPool();
    error ZeroAddress();
    error InvalidShare();
    error InvalidCap();
    error TokenMismatch();
    error FeeTierMismatch();
    error NothingToBuy();
    error BoughtThisBlock();
    error BountyPayFailed();
    error PayoutFailed();
    error WethPayFailed();
    error MigrateFailed();
    error NoParticipants();
    error DuplicateParticipant();

    event Allocated(uint256 toBurnTank, uint256 toTreasuryTank, uint256 toParticipants);
    event Bought(address indexed caller, address indexed destination, uint256 ethSpent, uint256 cashcatOut, uint256 bounty);
    event Collected(address indexed participant, uint256 amount);
    event SplitUpdated(uint16 burnBps, uint16 treasuryBps, uint256 participantCount);
    event CashcatTreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event MaxBuyPerCallUpdated(uint256 oldCap, uint256 newCap);
    event Migrated(address indexed to, uint256 amount);

    /// @dev CASHCAT has no burn function, and the dead address is the token's
    ///      established convention for supply taken out of circulation.
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    /// @notice Share of each buy chunk paid to whoever pulls the trigger.
    uint256 public constant BOUNTY_BPS = 100; // 1% of the chunk
    uint256 public constant BPS_DENOMINATOR = 10_000;
    /// @dev Uniswap v3 sqrt price bounds, pinned because v3-core's TickMath
    ///      targets an older compiler.
    uint160 private constant MIN_SQRT_RATIO_PLUS_1 = 4295128740;
    uint160 private constant MAX_SQRT_RATIO_MINUS_1 =
        1461446703485210103287273052203988822378723970341;

    /// @notice The canonical CASHCAT/WETH v3 pool both lanes buy on. Immutable:
    ///         if liquidity migrates venue, deploy a successor and repoint the
    ///         fee engine's treasury pointer.
    IUniswapV3Pool public immutable pool;
    IWETH9 public immutable weth;
    IERC20 public immutable cashcat;
    /// @dev Which side of the pool WETH sits on, fixed at construction.
    bool private immutable _wethIsToken0;

    struct Participant {
        address account;
        uint16 shareBps;
    }

    /// @notice Of each incoming wei, the share bought and burned.
    uint16 public burnShareBps;
    /// @notice Of each incoming wei, the share bought and sent to the CashCat
    ///         treasury.
    uint16 public cashcatTreasuryShareBps;
    /// @notice Where the CashCat-treasury lane delivers its CASHCAT. NOT this
    ///         contract, and not the fee engine's treasury pointer — see the
    ///         note on the two treasuries above.
    address public cashcatTreasury;
    /// @notice Accounts paid in ETH, and their shares. Together with the two
    ///         lane shares these always sum to `BPS_DENOMINATOR`.
    Participant[] private _participants;

    /// @notice Most tank ETH a single buy may spend on one lane. Bounds what a
    ///         sandwich around one public buy can be worth; backlogs drain
    ///         across blocks.
    uint256 public maxBuyPerCall;

    /// @notice ETH allocated to buying and burning, not yet spent.
    uint256 public burnTank;
    /// @notice ETH allocated to buying for the CashCat treasury, not yet spent.
    uint256 public cashcatTreasuryTank;
    /// @notice ETH a participant has accrued and not yet withdrawn.
    mapping(address => uint256) public owed;
    /// @notice Sum of every entry in `owed`, so fresh revenue can be told apart
    ///         from ETH already spoken for.
    uint256 public totalOwed;

    uint256 private _lastBurnBuyBlock;
    uint256 private _lastCashcatTreasuryBuyBlock;

    constructor(
        IUniswapV3Pool pool_,
        uint24 poolFee_,
        IERC20 cashcat_,
        IWETH9 weth_,
        address cashcatTreasury_,
        uint16 burnShareBps_,
        uint16 cashcatTreasuryShareBps_,
        Participant[] memory participants_,
        uint256 maxBuyPerCall_,
        address owner_
    ) Ownable(owner_) {
        if (cashcatTreasury_ == address(0)) revert ZeroAddress();
        if (maxBuyPerCall_ == 0) revert InvalidCap();
        // The pool must be exactly the CASHCAT/WETH pair, whichever side each
        // token sits on, and at the intended fee tier — several CASHCAT/WETH
        // pools exist at different tiers and depths, so pinning the tier turns
        // a mistyped successor address into a construction revert rather than a
        // splitter quietly routing through thin liquidity.
        address token0 = pool_.token0();
        address token1 = pool_.token1();
        bool wethIsToken0 = token0 == address(weth_) && token1 == address(cashcat_);
        bool wethIsToken1 = token1 == address(weth_) && token0 == address(cashcat_);
        if (!wethIsToken0 && !wethIsToken1) revert TokenMismatch();
        if (pool_.fee() != poolFee_) revert FeeTierMismatch();
        _wethIsToken0 = wethIsToken0;
        pool = pool_;
        cashcat = cashcat_;
        weth = weth_;
        cashcatTreasury = cashcatTreasury_;
        maxBuyPerCall = maxBuyPerCall_;
        _setSplit(burnShareBps_, cashcatTreasuryShareBps_, participants_);
    }

    receive() external payable {}

    // —————————————————————————— allocation ——————————————————————————

    /// @notice Fresh revenue not yet divided.
    function unallocated() public view returns (uint256) {
        return address(this).balance - burnTank - cashcatTreasuryTank - totalOwed;
    }

    /// @notice Divides whatever has arrived since the last touch. Callable by
    ///         anyone; every path that moves money calls it first.
    function allocate() external {
        _allocate();
    }

    /// @dev The two lanes round down and the remainder follows the
    ///      participants, so the sum of the parts is always the whole.
    function _allocate() private {
        uint256 fresh = unallocated();
        if (fresh == 0) return;

        uint256 toBurn = (fresh * burnShareBps) / BPS_DENOMINATOR;
        uint256 toTreasury = (fresh * cashcatTreasuryShareBps) / BPS_DENOMINATOR;
        burnTank += toBurn;
        cashcatTreasuryTank += toTreasury;

        uint256 remaining = fresh - toBurn - toTreasury;
        uint256 distributed;
        uint256 count = _participants.length;
        for (uint256 i; i < count; i++) {
            // The last participant takes what is left rather than its own
            // rounded share, so no wei is stranded unallocated.
            uint256 cut =
                i == count - 1 ? remaining - distributed : (fresh * _participants[i].shareBps) / BPS_DENOMINATOR;
            owed[_participants[i].account] += cut;
            distributed += cut;
        }
        totalOwed += remaining;
        emit Allocated(toBurn, toTreasury, remaining);
    }

    // —————————————————————————— the two lanes ——————————————————————————

    /// @notice Buys CASHCAT with the burn tank and sends it to the dead
    ///         address. Callable by anyone; pays the caller the bounty.
    function buyAndBurn() external nonReentrant returns (uint256 cashcatOut) {
        return _buy(BURN_ADDRESS, true);
    }

    /// @notice Buys CASHCAT with its lane's tank and sends it to the CashCat
    ///         treasury. Callable by anyone; pays the caller the bounty.
    function buyForCashcatTreasury() external nonReentrant returns (uint256 cashcatOut) {
        return _buy(cashcatTreasury, false);
    }

    /// @dev One lane's buy. `destination` receives the CASHCAT from the pool
    ///      directly.
    function _buy(address destination, bool fromBurnTank) private returns (uint256 cashcatOut) {
        // Each lane has its own gate, so neither can block the other.
        if (fromBurnTank) {
            if (_lastBurnBuyBlock == block.number) revert BoughtThisBlock();
            _lastBurnBuyBlock = block.number;
        } else {
            if (_lastCashcatTreasuryBuyBlock == block.number) revert BoughtThisBlock();
            _lastCashcatTreasuryBuyBlock = block.number;
        }

        _allocate();
        uint256 fuel = fromBurnTank ? burnTank : cashcatTreasuryTank;
        if (fuel == 0) revert NothingToBuy();
        uint256 chunk = fuel > maxBuyPerCall ? maxBuyPerCall : fuel;
        if (fromBurnTank) burnTank = fuel - chunk;
        else cashcatTreasuryTank = fuel - chunk;

        // Hold back the most the caller could earn so the buy is sized against
        // ETH that is certainly free to spend.
        uint256 buyEth = chunk - (chunk * BOUNTY_BPS) / BPS_DENOMINATOR;

        bool zeroForOne = _wethIsToken0; // WETH in
        (int256 amount0, int256 amount1) = pool.swap(
            destination,
            zeroForOne,
            int256(buyEth),
            zeroForOne ? MIN_SQRT_RATIO_PLUS_1 : MAX_SQRT_RATIO_MINUS_1,
            ""
        );
        uint256 ethSpent = uint256(zeroForOne ? amount0 : amount1);
        cashcatOut = uint256(-(zeroForOne ? amount1 : amount0));
        // No bounty for buying nothing: reverting rolls the tank deduction back
        // too, so an empty pool cannot be milked for bounties.
        if (cashcatOut == 0) revert NothingToBuy();

        // Earned on the ETH that actually bought, not on the requested chunk,
        // so a partial fill pays proportionally. Everything neither spent nor
        // earned returns to the tank, so the balance and the pots cannot
        // diverge.
        uint256 bounty = (ethSpent * BOUNTY_BPS) / BPS_DENOMINATOR;
        if (fromBurnTank) burnTank += chunk - ethSpent - bounty;
        else cashcatTreasuryTank += chunk - ethSpent - bounty;

        (bool paid,) = msg.sender.call{value: bounty}("");
        if (!paid) revert BountyPayFailed();
        emit Bought(msg.sender, destination, ethSpent, cashcatOut, bounty);
    }

    /// @dev The pool collects payment for a buy here. Only swaps this contract
    ///      initiated can reach it, and only the canonical pool may collect.
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata) external override {
        if (msg.sender != address(pool)) revert NotPool();
        uint256 due = uint256(_wethIsToken0 ? amount0Delta : amount1Delta);
        weth.deposit{value: due}();
        if (!weth.transfer(address(pool), due)) revert WethPayFailed();
    }

    // —————————————————————————— participants ——————————————————————————

    /// @notice Pays a participant everything they have accrued. Callable by
    ///         anyone, because the destination is fixed and there is nothing to
    ///         steer. A recipient that cannot receive ETH blocks only itself.
    function collect(address participant) external nonReentrant returns (uint256 amount) {
        _allocate();
        amount = owed[participant];
        if (amount == 0) return 0;
        owed[participant] = 0;
        totalOwed -= amount;
        (bool ok,) = participant.call{value: amount}("");
        if (!ok) revert PayoutFailed();
        emit Collected(participant, amount);
    }

    function participants() external view returns (Participant[] memory) {
        return _participants;
    }

    function participantCount() external view returns (uint256) {
        return _participants.length;
    }

    // —————————————————————————— admin ——————————————————————————

    /// @notice Retunes how future revenue divides. Everything received so far
    ///         is allocated under the outgoing split first, so a new split
    ///         never re-cuts ETH a tank or a tab already holds, and an account
    ///         dropped from the set keeps whatever it accrued and can still
    ///         withdraw it.
    ///
    ///         This is a statement about this call only. Migration does move a
    ///         tank, and a successor divides it under its own split — see the
    ///         note on tanks and tabs above.
    function setSplit(uint16 burnBps, uint16 treasuryBps, Participant[] calldata newParticipants)
        external
        onlyOwner
    {
        _allocate();
        _setSplit(burnBps, treasuryBps, newParticipants);
    }

    /// @dev The shares must account for every wei, so the three parts are
    ///      required to sum to the denominator exactly rather than merely not
    ///      exceeding it — a set summing to less would leave revenue
    ///      permanently unallocated.
    function _setSplit(uint16 burnBps, uint16 treasuryBps, Participant[] memory newParticipants) private {
        if (newParticipants.length == 0) revert NoParticipants();
        uint256 total = uint256(burnBps) + treasuryBps;
        for (uint256 i; i < newParticipants.length; i++) {
            if (newParticipants[i].account == address(0)) revert ZeroAddress();
            if (newParticipants[i].shareBps == 0) revert InvalidShare();
            for (uint256 j = i + 1; j < newParticipants.length; j++) {
                if (newParticipants[i].account == newParticipants[j].account) revert DuplicateParticipant();
            }
            total += newParticipants[i].shareBps;
        }
        if (total != BPS_DENOMINATOR) revert InvalidShare();

        delete _participants;
        for (uint256 i; i < newParticipants.length; i++) {
            _participants.push(newParticipants[i]);
        }
        burnShareBps = burnBps;
        cashcatTreasuryShareBps = treasuryBps;
        emit SplitUpdated(burnBps, treasuryBps, newParticipants.length);
    }

    /// @notice Repoints the CashCat treasury the buy lane delivers to. This
    ///         reaches CASHCAT the tank has already been funded to buy, not
    ///         only future revenue, because the destination is read when the
    ///         buy runs rather than when the tank was filled.
    function setCashcatTreasury(address newTreasury) external onlyOwner {
        if (newTreasury == address(0)) revert ZeroAddress();
        emit CashcatTreasuryUpdated(cashcatTreasury, newTreasury);
        cashcatTreasury = newTreasury;
    }

    function setMaxBuyPerCall(uint256 newCap) external onlyOwner {
        if (newCap == 0) revert InvalidCap();
        emit MaxBuyPerCallUpdated(maxBuyPerCall, newCap);
        maxBuyPerCall = newCap;
    }

    /// @notice Sends the two lanes and any undivided revenue to `to`. The route
    ///         out when the CASHCAT venue changes or the arrangement is
    ///         restructured: deploy the successor, repoint **both** treasury
    ///         pointers at it — `CashCatHook.treasury` for the platform share of
    ///         every trade and `CashCatFactory.treasury` for every launch fee —
    ///         then migrate.
    ///
    ///         What a participant has already accrued stays here and stays
    ///         withdrawable: the amount sent is the balance less every tab.
    ///
    ///         `to` is not required to be a splitter, or a contract. A successor
    ///         receives the tanks as undifferentiated ETH and divides it under
    ///         its own split, so a migration does not preserve which lane the
    ///         money was sitting in; a plain wallet simply receives it as ETH.
    ///         This is the owner's withdrawal path for the platform's own
    ///         unspent revenue, and it is deliberately not restricted, because
    ///         nothing on chain distinguishes a successor splitter from any
    ///         other address that could hold the funds while one is built.
    function migrate(address to) external onlyOwner nonReentrant {
        if (to == address(0)) revert ZeroAddress();
        _allocate();
        uint256 amount = address(this).balance - totalOwed;
        burnTank = 0;
        cashcatTreasuryTank = 0;
        if (amount == 0) return;
        (bool ok,) = to.call{value: amount}("");
        if (!ok) revert MigrateFailed();
        emit Migrated(to, amount);
    }
}
