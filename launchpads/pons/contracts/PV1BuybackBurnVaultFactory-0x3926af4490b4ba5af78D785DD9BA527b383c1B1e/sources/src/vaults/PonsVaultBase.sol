// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Initializable} from "@openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin-contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import {PonsAddresses} from "../PonsAddresses.sol";
import {IPonsFeeCollector} from "../interfaces/IPonsLaunchpad.sol";
import {ISwapRouter02, IUniswapV3Factory} from "../interfaces/IUniswapV3.sol";

/// @title PonsVaultBase
/// @notice Shared plumbing for PonsVault templates: claiming pons creator fees and buyback/burn
///         primitives.
///
/// @dev How a PonsVault earns: pons routes a launch's creator LP fees to `feeRedirects(token)` on
///      the locker, so pointing that at a vault makes the vault the payout recipient.
///
///      Sweeping and receiving are separate permissions, which shapes this design. The locker only
///      accepts `collectFees` from the token's `deployer` or pons's `protocolFeeRecipient` — a fee
///      redirect target is *not* authorised, even though it is where the funds land. The vault
///      therefore delegates the sweep to a `collector` (the {PonsVaultLauncher} that performed the
///      launch and is thus the on-chain deployer), while distribution stays permissionless here.
///
///      Fees arrive as ERC-20 WETH plus, when the pool has accrued token-side fees, the token
///      itself. No native ETH is ever received, so there is no fallback-gas constraint here.
abstract contract PonsVaultBase is Initializable, ReentrancyGuardUpgradeable {
    using SafeERC20 for IERC20;

    error ZeroAddress();
    error NothingToHarvest();

    event FeesHarvested(uint256 wethAmount, uint256 tokenAmount);
    event BuybackExecuted(uint256 wethSpent, uint256 tokensBought);
    event TokensBurned(uint256 amount);

    /// @notice The pons token this vault is bound to.
    address public token;

    /// @notice The pons locker custodying the token's LP position.
    address public locker;

    /// @notice Contract authorised to sweep this token's fees out of the locker.
    /// @dev The launcher that deployed the token, and therefore its on-chain `deployer`.
    address public collector;

    /// @notice Total WETH harvested from the locker over the vault's lifetime.
    uint256 public totalWethHarvested;

    /// @notice Total tokens sent to the burn address over the vault's lifetime.
    uint256 public totalTokensBurned;

    /// @notice Timestamp of the last successful distribution.
    uint256 public lastRunAt;

    /// @notice Number of successful distributions.
    uint256 public runCount;

    function __PonsVaultBase_init(address _token, address _locker, address _collector) internal onlyInitializing {
        if (_token == address(0) || _locker == address(0) || _collector == address(0)) revert ZeroAddress();
        __ReentrancyGuard_init();
        token = _token;
        locker = _locker;
        collector = _collector;
    }

    /// @notice The WETH/token Uniswap V3 pool backing this token.
    function pool() public view returns (address poolAddress) {
        poolAddress =
            IUniswapV3Factory(PonsAddresses.V3_FACTORY).getPool(PonsAddresses.WETH, token, PonsAddresses.POOL_FEE);
    }

    /// @notice Balances currently sitting in the vault, awaiting distribution.
    function idleBalances() public view returns (uint256 wethBalance, uint256 tokenBalance) {
        wethBalance = IERC20(PonsAddresses.WETH).balanceOf(address(this));
        tokenBalance = IERC20(token).balanceOf(address(this));
    }

    /// @notice Human-readable status for UIs. Implementations should reflect live state.
    function description() external view virtual returns (string memory);

    /// @notice Stable identifier for which template this vault is.
    /// @dev Templates expose different configs and a different {run} signature, so anything
    ///      reading a vault by address alone needs to know which it is holding before it can
    ///      decode anything else. Matches the ids the frontend uses.
    function template() external pure virtual returns (string memory);

    /// @dev Sweeps pending creator fees out of the locker into this vault, via the collector.
    ///      Deliberately a low-level call with the result ignored: the locker reverts when there is
    ///      nothing to collect, and a retrofitted vault may have an EOA as its collector, in which
    ///      case the call succeeds but returns no decodable data. Balances measured either side are
    ///      the source of truth, so a failed sweep simply contributes nothing.
    function _harvest() internal returns (uint256 wethGained, uint256 tokenGained) {
        (uint256 wethBefore, uint256 tokenBefore) = idleBalances();

        // solhint-disable-next-line avoid-low-level-calls
        (bool swept,) = collector.call(abi.encodeCall(IPonsFeeCollector.collect, (token)));
        swept;

        (uint256 wethAfter, uint256 tokenAfter) = idleBalances();
        wethGained = wethAfter - wethBefore;
        tokenGained = tokenAfter - tokenBefore;

        if (wethGained != 0) totalWethHarvested += wethGained;
        emit FeesHarvested(wethGained, tokenGained);
    }

    /// @dev Spends `wethAmount` buying the token into this vault.
    ///      The swap must deliver to the vault rather than straight to the burn address: pons tokens
    ///      reject a pool transfer whose recipient is the burn address (Uniswap surfaces this as
    ///      `TF`), even though an ordinary ERC-20 transfer to that same address succeeds. Burning is
    ///      therefore a separate step, see {_burnAllTokens}.
    function _buyback(uint256 wethAmount, uint256 amountOutMinimum) internal returns (uint256 bought) {
        IERC20(PonsAddresses.WETH).forceApprove(PonsAddresses.SWAP_ROUTER_02, wethAmount);

        bought = ISwapRouter02(PonsAddresses.SWAP_ROUTER_02)
            .exactInputSingle(
                ISwapRouter02.ExactInputSingleParams({
                tokenIn: PonsAddresses.WETH,
                tokenOut: token,
                fee: PonsAddresses.POOL_FEE,
                recipient: address(this),
                amountIn: wethAmount,
                amountOutMinimum: amountOutMinimum,
                sqrtPriceLimitX96: 0
            })
            );

        IERC20(PonsAddresses.WETH).forceApprove(PonsAddresses.SWAP_ROUTER_02, 0);
        emit BuybackExecuted(wethAmount, bought);
    }

    /// @dev Burns the vault's entire token balance, covering both bought tokens and token-side LP fees.
    function _burnAllTokens() internal returns (uint256 burned) {
        burned = IERC20(token).balanceOf(address(this));
        if (burned == 0) return 0;

        IERC20(token).safeTransfer(PonsAddresses.BURN_ADDRESS, burned);
        totalTokensBurned += burned;
        emit TokensBurned(burned);
    }

    uint256[45] private __gap;
}
