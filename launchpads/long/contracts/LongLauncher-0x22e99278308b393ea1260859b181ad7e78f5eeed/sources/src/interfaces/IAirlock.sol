// SPDX-License-Identifier: BUSL-1.1
// Copyright (c) 2026 long.xyz. All rights reserved.
pragma solidity ^0.8.26;

/// @notice Minimal Airlock interface required by the ticker-guarded wrapper.
interface IAirlock {
    struct CreateParams {
        uint256 initialSupply;
        uint256 numTokensToSell;
        address numeraire;
        address tokenFactory;
        bytes tokenFactoryData;
        address governanceFactory;
        bytes governanceFactoryData;
        address poolInitializer;
        bytes poolInitializerData;
        address liquidityMigrator;
        bytes liquidityMigratorData;
        address integrator;
        bytes32 salt;
    }

    function create(CreateParams calldata createData)
        external
        returns (address asset, address pool, address governance, address timelock, address migrationPool);
}
