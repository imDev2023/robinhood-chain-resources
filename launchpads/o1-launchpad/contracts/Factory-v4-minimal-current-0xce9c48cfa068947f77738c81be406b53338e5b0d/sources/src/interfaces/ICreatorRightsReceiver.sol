// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface ICreatorRightsReceiver {
    function onCreatorRightsReceived(address previousCreator, address token, bytes calldata callbackData)
        external
        payable
        returns (bytes4 selector);
}
