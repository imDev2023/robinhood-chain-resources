// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {
    IERC20MetadataUpgradeable
} from "@openzeppelin-contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

import {
    IERC20PermitUpgradeable
} from "@openzeppelin-contracts-upgradeable/token/ERC20/extensions/IERC20PermitUpgradeable.sol";

interface IFlapTaxToken is IERC20MetadataUpgradeable, IERC20PermitUpgradeable {
    /// @notice Initialization parameters for setting up the token
    struct InitParams {
        /// @param name The name of the token
        string name;
        /// @param symbol The symbol of the token
        string symbol;
        /// @param meta The metadata of the token
        string meta;
        /// @param tax The tax rate for the token in basis points (1/100 of a percent)
        uint16 tax;
        /// @param taxSplitter The address of the tax splitter contract
        address taxSplitter;
        /// @param quoteToken The address of the quote token for pools (WETH or any ERC20)
        address quoteToken;
        /// @param liqExpectedOutputAmount The expected output amount in each liquidation
        uint256 liqExpectedOutputAmount;
        /// @param taxDuration The duration of the tax in seconds
        uint256 taxDuration;
    }

    /// @notice Initializes the token with the given parameters
    function initialize(InitParams memory params) external;

    /// @notice Returns the IPFS CID of the metadata JSON
    /// @return The metadata URI
    function metaURI() external view returns (string memory);

    /// @notice Returns the tax rate in basis points
    /// @return The tax rate (1/100 of a percent)
    function taxRate() external view returns (uint16);

    /// @notice Returns the tax splitter address
    function taxSplitter() external view returns (address);

    /// @notice Returns the main V2 pool address for this token
    /// @return The address of the main V2 pool
    function mainPool() external view returns (address);

    /// migration related functions

    /// @notice Starts the migration process used by the Portal Contract
    function startMigration() external;

    /// @notice Finalizes the migration process used by the Portal Contract
    function finalizeMigration() external;

    /// @notice Change the main pool
    /// @dev can only be called by owner
    /// @dev can only be called in the state of BondingCurve
    /// @dev This method may not exist on some chains
    /// Since this legacy tax token will be soon preceded by v2
    /// @param newMainPool The address of the new main pool
    /// @param router The address of the router for the main pool
    function setMainPool(address newMainPool, address router) external;

    /// @notice Custom transfer event for easier indexing
    /// @param from The address sending the tokens
    /// @param to The address receiving the tokens
    /// @param value The amount of tokens transferred
    event TransferFlapToken(address from, address to, uint256 value);

    /// @notice Emitted when tax liquidation fails
    event TaxLiquidationError(bytes reason);

    /// @notice Emitted when tax liquidation succeeds
    /// @param quoteToken The address of the quote token received
    /// @param taxAmount The amount of tax tokens liquidated
    /// @param outputAmount The amount of quote tokens received
    event FlapTaxLiquidationSuccess(address quoteToken, uint256 taxAmount, uint256 outputAmount);

    /// @notice Emitted when the pool state changes
    /// @param fromState The previous state
    /// @param toState The new state
    event PoolStateChanged(uint8 fromState, uint8 toState);
}

