// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IWETH} from "./interfaces/IUniswapV2.sol";
import {IHoodMigrator, INonfungiblePositionManager} from "./interfaces/IV3Migration.sol";

/// @title HoodV3Migrator
/// @notice Graduation target for hood.fun coins. When the launchpad migrates a
///         graduated curve it hands this contract the LP token supply + the
///         raised ETH; this contract:
///           1. creates a Uniswap v3 pool at the graduation price (1% fee tier),
///           2. mints a full-range position,
///           3. sends that position to the hood.fun Liquidity Locker, encoding
///              the immutable creator/protocol fee split in the transfer.
///
///         The locker has no withdraw path, so the liquidity is locked forever;
///         the pool's 1% fee keeps accruing to the locked position and every
///         collection is split creator/protocol for the life of the coin.
///
///         Pluggable by design: the launchpad points at this via an
///         owner-settable address, so future migration logic never forces
///         another launchpad redeploy.
contract HoodV3Migrator is IHoodMigrator, ReentrancyGuard {
    /// @dev 1% tier: canonical Uniswap fee amount 10000, tick spacing 200.
    uint24 public constant FEE = 10000;
    /// @dev Full range as usable ticks: nearest multiples of 200 to +/-887272.
    int24 internal constant MIN_TICK = -887200;
    int24 internal constant MAX_TICK = 887200;

    address public immutable launchpad;
    INonfungiblePositionManager public immutable nfpm;
    /// @dev The hood.fun Liquidity Locker every graduated position is sent to.
    address public immutable locker;
    IWETH public immutable weth;
    /// @dev Protocol treasury: receives the protocol side of pool-fee splits.
    address public immutable protocol;
    /// @dev Creator's share of the pool fee, in bps (5000 = 50%).
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
        uint16 creatorShareBps_
    ) {
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
    /// @dev Called by the launchpad, which has already transferred the LP token
    ///      supply here and forwarded the raised ETH as msg.value.
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

        pool = nfpm.createAndInitializePoolIfNecessary(t0, t1, FEE, _sqrtPriceX96(a0, a1));

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
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            })
        );

        // Lock forever: hand the position to the hood.fun Liquidity Locker,
        // recording the immutable fee split in the same atomic transfer.
        nfpm.safeTransferFrom(address(this), locker, tokenId, abi.encode(creator, protocol, creatorShareBps));

        emit V3Migrated(token, pool, tokenId, tokenAmount, wethAmount);
    }

    /// @dev sqrtPriceX96 = floor(sqrt(amount1/amount0) * 2^96), computed without
    ///      intermediate overflow via 512-bit mulDiv then integer sqrt.
    function _sqrtPriceX96(uint256 amount0, uint256 amount1) internal pure returns (uint160) {
        uint256 ratioX192 = Math.mulDiv(amount1, 1 << 192, amount0);
        uint256 sqrtP = Math.sqrt(ratioX192);
        if (sqrtP > type(uint160).max) revert PriceOverflow();
        return uint160(sqrtP);
    }
}
