// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {IUniswapV3SwapCallback} from "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";

interface IWETH9 is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

/// @title CashCatBuybackBurner
/// @notice The destination of the platform's revenue. Every wei that arrives
///         is split, at the moment it is first accounted, between two pots:
///         a burn tank that market-buys CASHCAT on its canonical Uniswap v3
///         pool and sends it to the dead address, and a team tab pushed to
///         the team wallet. The split is owner-tunable for FUTURE revenue
///         only — ETH already allocated to the burn tank can never be
///         redirected to the team by flipping the knob afterwards.
///
///         Burns are permissionless and bounty-driven, exactly like the
///         self-burner the rest of the system already uses: anyone may call
///         `burn()`, earns 1% of the chunk, and exposure to sandwiching is
///         bounded by a per-call cap and a one-burn-per-block gate instead
///         of price oracles. The buy's recipient is the dead address itself —
///         this contract never custodies CASHCAT for even one instruction.
///
///         Trust model — this contract only ever holds the platform's own
///         revenue. The owner (a Safe) can tune the split, the team wallet,
///         the per-call cap, and can migrate the funds to a successor (e.g.
///         if CASHCAT liquidity moves venue) — the same reach the treasury
///         pointer already gave it. It cannot touch any pool, any creator's
///         stream, or any user funds: none ever pass through here.
contract CashCatBuybackBurner is Ownable2Step, ReentrancyGuard, IUniswapV3SwapCallback {
    error NotPool();
    error ZeroAddress();
    error InvalidShare();
    error InvalidCap();
    error TokenMismatch();
    error FeeTierMismatch();
    error NothingToBurn();
    error BurnedThisBlock();
    error BountyPayFailed();
    error TeamPayFailed();
    error WethPayFailed();
    error MigrateFailed();

    /// @notice Fresh revenue split into the two pots (burn wei, team wei).
    event Allocated(uint256 toBurnTank, uint256 toTeamTab);
    /// @notice A completed buyback: ETH spent on the pool, CASHCAT delivered
    ///         straight to the dead address, bounty paid to the caller.
    event Burned(address indexed caller, uint256 ethSpent, uint256 cashcatBurned, uint256 bounty);
    event TeamCollected(address indexed teamWallet, uint256 amount);
    event BurnShareUpdated(uint16 oldBps, uint16 newBps);
    event TeamWalletUpdated(address indexed oldWallet, address indexed newWallet);
    event MaxBurnPerCallUpdated(uint256 oldCap, uint256 newCap);
    event Migrated(address indexed to, uint256 amount);

    /// @dev CASHCAT has no burn() — supply reduction is not possible at the
    ///      token level, and the dead address is the token's own established
    ///      burn convention (millions already sit there). Buys are delivered
    ///      here directly by the pool.
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    /// @notice Share of each burn chunk paid to whoever pulls the trigger —
    ///         what makes burns self-driving: no operator, no cron, no trust.
    uint256 public constant BOUNTY_BPS = 100; // 1% of the chunk
    uint256 public constant BPS_DENOMINATOR = 10_000;
    /// @dev Uniswap v3 sqrt price bounds (TickMath constants; v3-core's
    ///      library targets Solidity 0.7 so the two values are pinned here).
    uint160 private constant MIN_SQRT_RATIO_PLUS_1 = 4295128740;
    uint160 private constant MAX_SQRT_RATIO_MINUS_1 =
        1461446703485210103287273052203988822378723970341;

    /// @notice The canonical CASHCAT/WETH v3 pool buys execute on. Immutable:
    ///         if liquidity ever migrates venue, deploy a successor burner
    ///         and repoint the treasury — the pattern the rest of the system
    ///         already uses for rotations.
    IUniswapV3Pool public immutable pool;
    IWETH9 public immutable weth;
    IERC20 public immutable cashcat;
    /// @dev Which side of the pool WETH sits on, fixed at construction.
    bool private immutable _wethIsToken0;

    /// @notice Of each incoming wei, the burn tank's share; the rest is the
    ///         team's. Applies to revenue allocated AFTER a change, never to
    ///         what is already sitting in the pots.
    uint16 public burnShareBps;
    /// @notice Receives the team's share via permissionless `collectTeam`.
    address public teamWallet;
    /// @notice Most burn-tank ETH a single `burn()` may spend. Caps what a
    ///         sandwich around one public burn can ever be worth; backlogs
    ///         drain across blocks. Owner-tunable as ETH's price drifts.
    uint256 public maxBurnPerCall;

    /// @notice ETH allocated to buying and burning CASHCAT, not yet spent.
    uint256 public burnTank;
    /// @notice ETH allocated to the team, awaiting `collectTeam`.
    uint256 public teamTab;
    uint256 private _lastBurnBlock;

    constructor(
        IUniswapV3Pool pool_,
        uint24 poolFee_,
        IERC20 cashcat_,
        IWETH9 weth_,
        address teamWallet_,
        uint16 burnShareBps_,
        uint256 maxBurnPerCall_,
        address owner_
    ) Ownable(owner_) {
        if (teamWallet_ == address(0)) revert ZeroAddress();
        if (burnShareBps_ > BPS_DENOMINATOR) revert InvalidShare();
        if (maxBurnPerCall_ == 0) revert InvalidCap();
        // the pool must be exactly the CASHCAT/WETH pair, whichever side
        // each token sits on...
        address token0 = pool_.token0();
        address token1 = pool_.token1();
        bool wethIsToken0 = token0 == address(weth_) && token1 == address(cashcat_);
        bool wethIsToken1 = token1 == address(weth_) && token0 == address(cashcat_);
        if (!wethIsToken0 && !wethIsToken1) revert TokenMismatch();
        // ...and it must be the intended fee tier. Several CASHCAT/WETH pools
        // exist at different tiers (and depths); pinning the tier turns a
        // fat-fingered successor-deploy address into a construction revert
        // instead of a burner silently routing through thin liquidity.
        if (pool_.fee() != poolFee_) revert FeeTierMismatch();
        _wethIsToken0 = wethIsToken0;
        pool = pool_;
        cashcat = cashcat_;
        weth = weth_;
        teamWallet = teamWallet_;
        burnShareBps = burnShareBps_;
        maxBurnPerCall = maxBurnPerCall_;
    }

    /// @dev Revenue arrives here: the hook's platform sweeps, the factory's
    ///      launch fees, or anything else. Deliberately empty — a payment
    ///      into this contract must never be able to revert (a launch's fee
    ///      push happens inside the launch transaction itself). Splitting is
    ///      lazy: whatever the balance holds beyond the two pots is fresh
    ///      revenue, allocated on the next touch. Force-sent ETH is simply
    ///      treated as revenue too.
    receive() external payable {}

    /// @notice Fresh revenue not yet split between the pots.
    function unallocated() public view returns (uint256) {
        return address(this).balance - burnTank - teamTab;
    }

    /// @dev Split all fresh revenue at the current share. Burn share rounds
    ///      down; the remainder wei goes to the team tab.
    function _allocate() private {
        uint256 fresh = unallocated();
        if (fresh == 0) return;
        uint256 toBurn = (fresh * burnShareBps) / BPS_DENOMINATOR;
        burnTank += toBurn;
        teamTab += fresh - toBurn;
        emit Allocated(toBurn, fresh - toBurn);
    }

    // —————————————————————————— the burn ——————————————————————————

    /// @notice Buys CASHCAT with the burn tank and sends it straight to the
    ///         dead address. Callable by anyone; pays the caller the bounty.
    ///         At most `maxBurnPerCall` of tank per call and one call per
    ///         block — larger backlogs drain across blocks, keeping any
    ///         single burn too small to be worth sandwiching hard.
    function burn() external nonReentrant returns (uint256 cashcatBurned) {
        if (_lastBurnBlock == block.number) revert BurnedThisBlock();
        _lastBurnBlock = block.number;

        _allocate();
        uint256 fuel = burnTank;
        if (fuel == 0) revert NothingToBurn();
        uint256 chunk = fuel > maxBurnPerCall ? maxBurnPerCall : fuel;
        burnTank = fuel - chunk;

        // hold back a provisional bounty reserve so the buy can never eat the
        // whole chunk; the real bounty is trued up from what actually bought.
        uint256 buyEth = chunk - (chunk * BOUNTY_BPS) / BPS_DENOMINATOR;

        // exact-input buy, no price limit on purpose (moving the price up is
        // the point); exposure is bounded by the cap and the block gate. The
        // pool pays CASHCAT out to the dead address directly.
        bool zeroForOne = _wethIsToken0; // WETH in
        (int256 amount0, int256 amount1) = pool.swap(
            BURN_ADDRESS,
            zeroForOne,
            int256(buyEth),
            zeroForOne ? MIN_SQRT_RATIO_PLUS_1 : MAX_SQRT_RATIO_MINUS_1,
            ""
        );
        uint256 ethSpent = uint256(zeroForOne ? amount0 : amount1);
        cashcatBurned = uint256(-(zeroForOne ? amount1 : amount0));
        // no bounty for burning nothing: reverting rolls back the tank
        // deduction too, so an empty pool can't be milked for bounties
        if (cashcatBurned == 0) revert NothingToBurn();

        // the bounty scales with the ETH that actually bought CASHCAT, not the
        // requested chunk — a partial fill near the price boundary pays a
        // proportional bounty, never the full 1% of the cap for a tiny buy.
        // Everything not spent on the buy or the bounty returns to the tank,
        // so the balance and the pots can never diverge.
        uint256 bounty = (ethSpent * BOUNTY_BPS) / BPS_DENOMINATOR;
        burnTank += chunk - ethSpent - bounty;

        (bool paid,) = msg.sender.call{value: bounty}("");
        if (!paid) revert BountyPayFailed();
        emit Burned(msg.sender, ethSpent, cashcatBurned, bounty);
    }

    /// @dev The pool collects payment for the buy here. Only swaps THIS
    ///      contract initiated can reach it (v3 calls back the swap caller),
    ///      and only the canonical pool may collect.
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata)
        external
        override
    {
        if (msg.sender != address(pool)) revert NotPool();
        uint256 owed = uint256(_wethIsToken0 ? amount0Delta : amount1Delta);
        weth.deposit{value: owed}();
        if (!weth.transfer(address(pool), owed)) revert WethPayFailed();
    }

    // —————————————————————————— the team ——————————————————————————

    /// @notice Pushes the team's accrued share to the team wallet. Callable
    ///         by anyone — the destination is fixed, so there is nothing to
    ///         steer. A reverting team wallet only blocks itself, never the
    ///         burn lane.
    function collectTeam() external nonReentrant returns (uint256 amount) {
        _allocate();
        amount = teamTab;
        if (amount == 0) return 0;
        teamTab = 0;
        (bool ok,) = teamWallet.call{value: amount}("");
        if (!ok) revert TeamPayFailed();
        emit TeamCollected(teamWallet, amount);
    }

    // —————————————————————————— admin ——————————————————————————

    /// @notice Retunes how future revenue splits. Everything received so far
    ///         is allocated under the outgoing share first, so the knob can
    ///         never reach backwards into ETH the burn tank already owns.
    function setBurnShareBps(uint16 newBps) external onlyOwner {
        if (newBps > BPS_DENOMINATOR) revert InvalidShare();
        _allocate();
        emit BurnShareUpdated(burnShareBps, newBps);
        burnShareBps = newBps;
    }

    function setTeamWallet(address newWallet) external onlyOwner {
        if (newWallet == address(0)) revert ZeroAddress();
        emit TeamWalletUpdated(teamWallet, newWallet);
        teamWallet = newWallet;
    }

    function setMaxBurnPerCall(uint256 newCap) external onlyOwner {
        if (newCap == 0) revert InvalidCap();
        emit MaxBurnPerCallUpdated(maxBurnPerCall, newCap);
        maxBurnPerCall = newCap;
    }

    /// @notice Moves the entire balance to a successor — the escape hatch if
    ///         CASHCAT liquidity ever migrates venue and a new burner must
    ///         take over. All-or-nothing so the pot accounting can never be
    ///         left skewed; only the platform's own revenue is reachable,
    ///         because nothing else ever enters this contract.
    function migrate(address to) external onlyOwner nonReentrant {
        if (to == address(0)) revert ZeroAddress();
        uint256 amount = address(this).balance;
        burnTank = 0;
        teamTab = 0;
        (bool ok,) = to.call{value: amount}("");
        if (!ok) revert MigrateFailed();
        emit Migrated(to, amount);
    }
}
