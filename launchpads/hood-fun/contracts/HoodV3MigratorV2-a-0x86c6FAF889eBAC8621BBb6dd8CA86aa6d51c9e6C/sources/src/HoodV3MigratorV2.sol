// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IWETH} from "./interfaces/IUniswapV2.sol";
import {IHoodMigrator, INonfungiblePositionManager} from "./interfaces/IV3Migration.sol";

/// @dev Minimal Uniswap v3 pool surface: we only read the current price.
interface IV3PoolSlot0 {
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );
}

/// @title HoodV3MigratorV2
/// @notice Hardened graduation target for hood.fun coins. Identical economics to
///         the original migrator (1% pool, full-range, eternal-locked to the
///         Locker with the immutable creator/protocol fee split) — but closes the
///         pool-squatting / price-manipulation vector on `createAndInitialize`.
///
///         SECURITY MODEL (survives an exposed.fun teardown):
///         - Every mint is PRICE-CHECKED against the intended graduation price
///           (Fix 1) and slippage-bounded (Fix 2). There is NO code path anywhere
///           — owner or otherwise — that mints at a chosen price. So even a leaked
///           owner key cannot seize or misprice a coin's liquidity.
///         - A squatted pool therefore only DoSes migration (funds stay safe in
///           the launchpad, attacker profits nothing). Recovery is OPERATIONAL:
///           the Safe normalizes the squatted pool (seed dust → swap to the
///           intended price) then re-calls the permissionless `launchpad.migrate`,
///           which now passes the checks. No privileged bypass is needed or given.
///         - `owner` (the Safe) can ONLY rescue funds that end up stuck IN THIS
///           CONTRACT (Fix 4). It can never touch locked LP — that lives in the
///           Locker, a separate contract with no withdraw path.
contract HoodV3MigratorV2 is IHoodMigrator, ReentrancyGuard, Ownable {
    /// @dev 1% tier: canonical Uniswap fee amount 10000, tick spacing 200.
    uint24 public constant FEE = 10000;
    /// @dev Full range as usable ticks: nearest multiples of 200 to +/-887272.
    int24 internal constant MIN_TICK = -887200;
    int24 internal constant MAX_TICK = 887200;
    /// @dev Fix 1 tolerance: the freshly-initialized pool price equals the
    ///      intended price exactly, so 1% is pure safety margin. A squatted pool
    ///      sits at a wildly different price and is rejected.
    uint256 internal constant PRICE_TOLERANCE_BPS = 100; // 1%
    uint256 internal constant BPS = 10_000;

    address public immutable launchpad;
    INonfungiblePositionManager public immutable nfpm;
    address public immutable locker;
    IWETH public immutable weth;
    address public immutable protocol;
    uint16 public immutable creatorShareBps;

    event V3Migrated(
        address indexed token,
        address indexed pool,
        uint256 tokenId,
        uint256 tokenLiquidity,
        uint256 ethLiquidity
    );

    error NotLaunchpad();
    error PriceOverflow();
    error PoolSquatted(uint160 got, uint160 want); // Fix 1: pool at an unexpected price
    error RescueFailed();

    modifier onlyLaunchpad() {
        if (msg.sender != launchpad) revert NotLaunchpad();
        _;
    }

    constructor(
        address launchpad_,
        address nfpm_,
        address locker_,
        address weth_,
        address protocol_,
        uint16 creatorShareBps_,
        address owner_
    ) Ownable(owner_) {
        require(creatorShareBps_ <= 10_000, "BAD_BPS");
        require(
            launchpad_ != address(0) && nfpm_ != address(0) && locker_ != address(0) && weth_ != address(0)
                && protocol_ != address(0),
            "ZERO_ADDR"
        );
        launchpad = launchpad_;
        nfpm = INonfungiblePositionManager(nfpm_);
        locker = locker_;
        weth = IWETH(weth_);
        protocol = protocol_;
        creatorShareBps = creatorShareBps_;
    }

    /// @inheritdoc IHoodMigrator
    function migrate(address token, address creator)
        external
        payable
        override
        onlyLaunchpad
        nonReentrant
        returns (address pool)
    {
        uint256 tokenAmount = IERC20(token).balanceOf(address(this));
        uint256 wethAmount = msg.value;
        weth.deposit{value: wethAmount}();

        // Uniswap v3 sorts pool tokens by address.
        (address t0, address t1, uint256 a0, uint256 a1) = token < address(weth)
            ? (token, address(weth), tokenAmount, wethAmount)
            : (address(weth), token, wethAmount, tokenAmount);

        uint160 intended = _sqrtPriceX96(a0, a1);
        pool = nfpm.createAndInitializePoolIfNecessary(t0, t1, FEE, intended);

        // ---- Fix 1: reject a squatted / manipulated pool -------------------
        // `createAndInitializePoolIfNecessary` silently returns a PRE-EXISTING
        // pool at whatever price it was initialized to. If an attacker front-ran
        // us and created this pool at a garbage price, minting here would deposit
        // a skewed ratio and leave value stealable. So require the live price is
        // within tolerance of the price WE intended; otherwise revert (migration
        // is safely retried after the Safe normalizes the pool).
        (uint160 current,,,,,,) = IV3PoolSlot0(pool).slot0();
        uint256 lo = (uint256(intended) * (BPS - PRICE_TOLERANCE_BPS)) / BPS;
        uint256 hi = (uint256(intended) * (BPS + PRICE_TOLERANCE_BPS)) / BPS;
        if (current < lo || current > hi) revert PoolSquatted(current, intended);

        IERC20(t0).approve(address(nfpm), a0);
        IERC20(t1).approve(address(nfpm), a1);
        (uint256 tokenId,,,) = nfpm.mint(
            INonfungiblePositionManager.MintParams({
                token0: t0,
                token1: t1,
                fee: FEE,
                tickLower: MIN_TICK,
                tickUpper: MAX_TICK,
                amount0Desired: a0,
                amount1Desired: a1,
                // ---- Fix 2: slippage floor. Fix 1 (exact price check) is the real
                //      guard; this is a backstop. 99% (not 99.9%) so custom supplies
                //      across the full MIN..MAX range never false-revert on rounding
                //      dust in a full-range mint. Still reverts hard on a mispriced
                //      pool. (regression: test_migrate_acrossSupplyRange)
                amount0Min: (a0 * 99) / 100,
                amount1Min: (a1 * 99) / 100,
                recipient: address(this),
                deadline: block.timestamp
            })
        );

        // Lock forever: hand the position to the Liquidity Locker, recording the
        // immutable fee split in the same atomic transfer.
        nfpm.safeTransferFrom(address(this), locker, tokenId, abi.encode(creator, protocol, creatorShareBps));

        emit V3Migrated(token, pool, tokenId, tokenAmount, wethAmount);
    }

    // ---- Fix 4: rescue funds stuck IN THIS CONTRACT only ------------------
    // Between migrations this contract should hold ~nothing (post-Fix-2 dust at
    // most). These recover misdirected tokens / ETH. They CANNOT reach locked LP:
    // that NFT lives in the Locker, which this contract does not own or control.

    function rescueTokens(address token, uint256 amount, address to) external onlyOwner {
        require(to != address(0), "ZERO_TO");
        require(IERC20(token).transfer(to, amount), "TRANSFER_FAILED");
    }

    function rescueETH(address to) external onlyOwner nonReentrant {
        require(to != address(0), "ZERO_TO");
        (bool ok,) = to.call{value: address(this).balance}("");
        if (!ok) revert RescueFailed();
    }

    /// @dev sqrtPriceX96 = floor(sqrt(amount1/amount0) * 2^96), computed without
    ///      intermediate overflow via 512-bit mulDiv then integer sqrt.
    function _sqrtPriceX96(uint256 amount0, uint256 amount1) internal pure returns (uint160) {
        uint256 ratioX192 = Math.mulDiv(amount1, 1 << 192, amount0);
        uint256 sqrtP = Math.sqrt(ratioX192);
        if (sqrtP > type(uint160).max) revert PriceOverflow();
        return uint160(sqrtP);
    }

    receive() external payable {}
}
