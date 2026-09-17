// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Strings} from "@openzeppelin/utils/Strings.sol";

import {PonsAddresses} from "../PonsAddresses.sol";
import {PonsVaultBase} from "./PonsVaultBase.sol";

/// @title PonsBuybackBurnVault
/// @notice PonsVault template that turns a pons token's creator LP fees into automated
///         buyback-and-burn pressure, optionally splitting a share to a treasury.
///
/// @dev Distribution is permissionless: anyone may call {run}, and the vault itself is the
///      authorised fee claimant on the locker. That keeps the incentive-sensitive parameters
///      (split and harvest floor) fixed at configuration time rather than under an operator's
///      control, so no privileged party can time or shape the buyback.
///
///      Pacing comes from `minHarvestWei` alone rather than a timer. A run spends the entire idle
///      balance, so it cannot repeat until trading has refilled the vault past the floor — which
///      makes the frequency track volume instead of the clock, and leaves nothing to spam.
///
///      The buyback carries no price check of its own. Because {run} is open to anyone, a caller who
///      wants protection has to supply `amountOutMinimum`; passing zero accepts whatever the pool
///      gives at that instant, including a price someone moved on purpose in the same block.
contract PonsBuybackBurnVault is PonsVaultBase {
    using SafeERC20 for IERC20;

    error InvalidBurnBps(uint16 burnBps);
    error TreasuryRequired();

    event TreasuryPaid(address indexed treasury, uint256 amount);
    event Configured(uint16 burnBps, address treasury, uint256 minHarvestWei);

    /// @param burnBps Share of harvested WETH spent on buyback-and-burn, in basis points.
    /// @param treasury Recipient of the remaining WETH. Required unless `burnBps` is 10000.
    /// @param minHarvestWei Minimum idle WETH required before {run} will act. This is the only
    ///        pacing control: a run spends the whole balance, so the next one cannot happen until
    ///        trading has accrued this much again.
    struct Config {
        uint16 burnBps;
        address treasury;
        uint256 minHarvestWei;
    }

    Config public config;

    /// @notice Total WETH forwarded to the treasury over the vault's lifetime.
    uint256 public totalTreasuryPaid;

    constructor() {
        _disableInitializers();
    }

    function initialize(address _token, address _locker, address _collector, Config calldata _config)
        external
        initializer
    {
        __PonsVaultBase_init(_token, _locker, _collector);
        _validate(_config);
        config = _config;
        emit Configured(_config.burnBps, _config.treasury, _config.minHarvestWei);
    }

    /// @notice Harvest creator fees, buy back and burn the configured share, and forward the rest.
    /// @dev Permissionless. `amountOutMinimum` is the caller's own slippage floor and the only
    ///      protection the swap has; zero means accept any fill.
    /// @param amountOutMinimum Minimum tokens the buyback swap must return. Zero to accept any.
    /// @return wethSpent WETH spent on the buyback.
    /// @return tokensBurned Tokens sent to the burn address, including harvested token-side fees.
    function run(uint256 amountOutMinimum) external nonReentrant returns (uint256 wethSpent, uint256 tokensBurned) {
        Config memory cfg = config;

        _harvest();

        (uint256 wethBalance,) = idleBalances();
        if (wethBalance < cfg.minHarvestWei || wethBalance == 0) revert NothingToHarvest();

        lastRunAt = block.timestamp;
        runCount += 1;

        wethSpent = (wethBalance * cfg.burnBps) / PonsAddresses.BPS_DENOMINATOR;
        uint256 treasuryAmount = wethBalance - wethSpent;

        if (wethSpent != 0) {
            _buyback(wethSpent, amountOutMinimum);
        }

        tokensBurned = _burnAllTokens();

        if (treasuryAmount != 0) {
            totalTreasuryPaid += treasuryAmount;
            IERC20(PonsAddresses.WETH).safeTransfer(cfg.treasury, treasuryAmount);
            emit TreasuryPaid(cfg.treasury, treasuryAmount);
        }
    }

    /// @notice Whether {run} would currently succeed, and why not if it would not.
    function canRun() external view returns (bool ready, string memory reason) {
        Config memory cfg = config;

        (uint256 wethBalance,) = idleBalances();
        if (wethBalance < cfg.minHarvestWei || wethBalance == 0) {
            return (false, "Insufficient accrued fees (harvest may still be pending in the locker)");
        }
        if (pool() == address(0)) {
            return (false, "Pool not deployed yet");
        }
        return (true, "");
    }

    /// @inheritdoc PonsVaultBase
    function template() external pure override returns (string memory) {
        return "buyback-burn";
    }

    /// @inheritdoc PonsVaultBase
    function description() external view override returns (string memory) {
        Config memory cfg = config;
        (uint256 wethBalance,) = idleBalances();

        return string.concat(
            "PonsBuybackBurnVault: ",
            Strings.toString(cfg.burnBps / 100),
            "% of creator fees buy back and burn the token",
            cfg.burnBps == PonsAddresses.BPS_DENOMINATOR
                ? ""
                : string.concat(
                    ", ", Strings.toString((PonsAddresses.BPS_DENOMINATOR - cfg.burnBps) / 100), "% to treasury"
                ),
            ". Burned so far: ",
            Strings.toString(totalTokensBurned / 1e18),
            " tokens across ",
            Strings.toString(runCount),
            " runs. Pending: ",
            Strings.toString(wethBalance),
            " wei WETH."
        );
    }

    function _validate(Config calldata cfg) private pure {
        if (cfg.burnBps == 0 || cfg.burnBps > PonsAddresses.BPS_DENOMINATOR) revert InvalidBurnBps(cfg.burnBps);
        if (cfg.burnBps != PonsAddresses.BPS_DENOMINATOR && cfg.treasury == address(0)) revert TreasuryRequired();
    }
}
