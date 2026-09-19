// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @notice The registrar surface PartyFactory uses on PartyLocker, plus the view
///         surface periphery reads (pool registry and protocol recipients) —
///         notably LiquidationModule's venue derivation via getPoolInfo.
interface IPartyLocker {
    function register(
        address token,
        address pairedAsset,
        address pool,
        uint256[] calldata tokenIds,
        address creator,
        address feeRecipient
    ) external;

    function getPoolInfo(address token)
        external
        view
        returns (address pairedAsset, address pool, address creator, address feeRecipient, uint256[] memory tokenIds);

    function getPoolSplits(address token)
        external
        view
        returns (uint16 pc, uint16 pp, uint16 pb, uint16 pcm, uint16 tc, uint16 tprot);

    function treasury() external view returns (address);

    function buyback() external view returns (address);

    function community() external view returns (address);

    /// @notice Sink for every illiquid protocol leg (token lumps + stock 80%-legs).
    function liquidationSink() external view returns (address);
}
