// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {FullMath} from "v4-core/libraries/FullMath.sol";

interface IQuotronV2WhitelistView {
    function allowed(address who) external view returns (bool);
}

/// @title QuotronV2FeeLib
/// @notice Manual launch-phase fee policy and permanent floor-fee carve.
/// Public accounts pay a true 90% fee until one-way finalization. The keeper
/// and published eligible holders always pay the true 3% floor. A buyer that
/// actually paid 90% remains at 90% for one hour after its purchase.
library QuotronV2FeeLib {
    uint256 internal constant BPS = 10_000;
    uint256 internal constant FLOOR_FEE_BPS = 300;
    uint256 internal constant LAUNCH_FEE_BPS = 9_000;
    uint256 internal constant BUYER_COOLDOWN = 1 hours;

    // Parts per 240 of every fee. At the 3% floor these equal:
    // 2.0000% reflections, 0.2125% STONKBROKERS burn,
    // 0.6375% locked LP, and 0.1500% creator.
    uint256 internal constant REFLECT_PARTS = 160;
    uint256 internal constant BURN_PARTS = 17;
    uint256 internal constant CREATOR_PARTS = 12;
    uint256 internal constant TOTAL_PARTS = 240;

    function feeBps(
        address swapper,
        address keeper,
        bool launchFeesFinalized,
        uint256 markedUntil,
        uint256 nowTs,
        IQuotronV2WhitelistView whitelist
    ) internal view returns (uint256) {
        if (markedUntil > nowTs) return LAUNCH_FEE_BPS;
        if (swapper == keeper || whitelist.allowed(swapper)) return FLOOR_FEE_BPS;
        return launchFeesFinalized ? FLOOR_FEE_BPS : LAUNCH_FEE_BPS;
    }

    /// @notice Fee deducted from a gross WETH output or gross user budget.
    function feeFromGross(uint256 grossAmount, uint256 bps) internal pure returns (uint256) {
        return FullMath.mulDiv(grossAmount, bps, BPS);
    }

    /// @notice Fee added to a net WETH pool input.
    function feeFromNet(uint256 netAmount, uint256 bps) internal pure returns (uint256) {
        return FullMath.mulDivRoundingUp(netAmount, bps, BPS - bps);
    }

    function carve(uint256 fee)
        internal
        pure
        returns (uint256 toReflections, uint256 toBurn, uint256 toLp, uint256 toCreator)
    {
        toReflections = FullMath.mulDiv(fee, REFLECT_PARTS, TOTAL_PARTS);
        toBurn = FullMath.mulDiv(fee, BURN_PARTS, TOTAL_PARTS);
        toCreator = FullMath.mulDiv(fee, CREATOR_PARTS, TOTAL_PARTS);
        toLp = fee - toReflections - toBurn - toCreator;
    }

    function launchFeeBps() internal pure returns (uint256) {
        return LAUNCH_FEE_BPS;
    }

    function buyerCooldown() internal pure returns (uint256) {
        return BUYER_COOLDOWN;
    }
}
