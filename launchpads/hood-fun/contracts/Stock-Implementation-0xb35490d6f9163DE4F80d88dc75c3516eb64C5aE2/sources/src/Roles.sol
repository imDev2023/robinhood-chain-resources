// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

bytes32 constant DEFAULT_ADMIN_ROLE = bytes32(0);
bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
bytes32 constant BURNER_ROLE = keccak256("BURNER_ROLE");
bytes32 constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
bytes32 constant TOKEN_DEPLOYER_ROLE = keccak256("TOKEN_DEPLOYER_ROLE");
bytes32 constant BEACON_UPGRADER_ROLE = keccak256("BEACON_UPGRADER_ROLE");
bytes32 constant FACTORY_UPGRADER_ROLE = keccak256("FACTORY_UPGRADER_ROLE");
bytes32 constant MULTIPLIER_UPDATER_ROLE = keccak256("MULTIPLIER_UPDATER_ROLE");
bytes32 constant METADATA_UPDATER_ROLE = keccak256("METADATA_UPDATER_ROLE");
bytes32 constant BLOCKER_ROLE = keccak256("BLOCKER_ROLE");
bytes32 constant ADMIN_BURNER_ROLE = keccak256("ADMIN_BURNER_ROLE");
bytes32 constant TOKEN_PAUSER_ROLE = keccak256("TOKEN_PAUSER_ROLE");
bytes32 constant ORACLE_PAUSER_ROLE = keccak256("ORACLE_PAUSER_ROLE");
