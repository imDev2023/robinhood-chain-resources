// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface ILaunchTokenMetadata {
    function updateName(string calldata newName) external;
    function updateSymbol(string calldata newSymbol) external;
    function updateContractURI(string calldata newContractURI) external;
    function updateExtraMetadata(string calldata metadataKey, string calldata metadataValue) external;
}
