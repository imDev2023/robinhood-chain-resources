// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @dev Minimal Chainlink Data Feed surface used by PartyFactory: USD price
///      feeds per paired asset, and the L2 sequencer-uptime feed (answer 0 = up,
///      1 = down; startedAt = when the current status began).
interface IChainlinkAggregatorV3 {
    function decimals() external view returns (uint8);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
