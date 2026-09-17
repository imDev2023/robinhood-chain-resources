// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AccessControlled.sol";
import "./Roles.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import "./interfaces/IStockFactory.sol";
import "./interfaces/IStock.sol";

contract StockFactory is IStockFactory, AccessControlled, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address public immutable beacon;

    event Deployed(bytes32 indexed uid, address stock, string name, string symbol);

    /// @custom:storage-location erc7201:robinhood.storage.StockFactory
    struct StockFactoryStorage {
        mapping(bytes32 => address) uidToStock;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address registryAndBeacon) AccessControlled(registryAndBeacon) {
        require(registryAndBeacon != address(0));
        beacon = registryAndBeacon;
        _disableInitializers();
    }

    bytes32 private constant StockFactoryStorageLocation =
        0x5531e8eeb8ad0385749a56c1e35f7ae27f26e2e485517e59400aca9bb5c27b00;

    function _getStockFactoryStorage() private pure returns (StockFactoryStorage storage $) {
        assembly {
            $.slot := StockFactoryStorageLocation
        }
    }

    function initialize() public initializer {
        __Context_init();
    }

    function deploy(bytes32 uid_, string calldata name_, string calldata symbol_)
        external
        override
        onlyRole(TOKEN_DEPLOYER_ROLE)
        returns (address)
    {
        StockFactoryStorage storage $ = _getStockFactoryStorage();
        require($.uidToStock[uid_] == address(0), "StockFactory: stock already exists");
        bytes memory creationCode = abi.encodePacked(type(BeaconProxy).creationCode, abi.encode(beacon, ""));
        address stock = Create2.deploy(0, uid_, creationCode);
        $.uidToStock[uid_] = stock;

        emit Deployed(uid_, stock, name_, symbol_);

        IStock(stock).initialize(uid_, name_, symbol_);

        return stock;
    }

    function tokenAddress(bytes32 uid_) external view override returns (address) {
        StockFactoryStorage storage $ = _getStockFactoryStorage();
        return $.uidToStock[uid_];
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(FACTORY_UPGRADER_ROLE) {}
}
