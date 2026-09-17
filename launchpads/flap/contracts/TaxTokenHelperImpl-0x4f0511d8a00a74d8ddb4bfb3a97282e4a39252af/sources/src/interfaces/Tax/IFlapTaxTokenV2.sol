// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {
    IERC20MetadataUpgradeable
} from "@openzeppelin-contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

import {
    IERC20PermitUpgradeable
} from "@openzeppelin-contracts-upgradeable/token/ERC20/extensions/IERC20PermitUpgradeable.sol";

interface IFlapTaxTokenV2 is IERC20MetadataUpgradeable, IERC20PermitUpgradeable {
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
        /// @param taxProcessor The address responsible for processing or receiving taxes (optional handler)
        address taxProcessor;
        /// @param dividendContract The address of the dividend contract for share tracking
        address dividendContract;
        /// @param quoteToken The address of the quote token for pools (WETH or any ERC20)
        address quoteToken;
        /// @param liqExpectedOutputAmount The expected output amount in each liquidation
        uint256 liqExpectedOutputAmount;
        /// @param taxDuration The duration of the tax in seconds
        uint256 taxDuration;
        /// @param pools The array of pool addresses
        address[] pools;
        /// @param v2 router
        address v2Router;
        /// @param antiFarmerDuration The duration of the anti-farmer tax in seconds
        uint256 antiFarmerDuration;
    }

    /// @notice Initializes the token with the given parameters
    /// @param params The initialization parameters
    function initialize(InitParams memory params) external;

    /// @notice Returns the stored PCS V2 router address (previously an immutable)
    function v2Router() external view returns (address);

    /// @notice Returns the main V2 pool address for this token
    function mainPool() external view returns (address);

    /// @notice Returns the minimum liquidation threshold
    function MIN_LIQ_THRESHOLD() external view returns (uint256);

    /// @notice Returns the starting liquidation threshold
    function START_LIQ_THRESHOLD() external view returns (uint256);

    /// @notice Returns the anti-farmer duration
    function antiFarmerDuration() external view returns (uint256);

    /// @notice Returns the IPFS CID of the metadata JSON
    /// @return The metadata URI
    function metaURI() external view returns (string memory);

    /// @notice Returns the tax rate in basis points
    /// @return The tax rate (1/100 of a percent)
    function taxRate() external view returns (uint16);

    /// @notice Returns the tax processor address
    function taxProcessor() external view returns (address);

    /// @notice Returns the dividend contract address
    function dividendContract() external view returns (address);

    /// migration related functions

    /// @notice Starts the migration process used by the Portal Contract
    function startMigration() external;

    /// @notice Finalizes the migration process used by the Portal Contract
    function finalizeMigration() external;

    /// @notice Custom transfer event for easier indexing
    /// @param from The address sending the tokens
    /// @param to The address receiving the tokens
    /// @param value The amount of tokens transferred
    event TransferFlapToken(address from, address to, uint256 value);

    /// @notice Emitted when tax liquidation fails
    event TaxLiquidationError(bytes reason);

    /// @notice Custom errors
    error DividendShareUpdateFailed(address account, bytes reason);

    /// @notice Emitted when the pool state changes
    /// @param fromState The previous state
    /// @param toState The new state
    event PoolStateChanged(uint8 fromState, uint8 toState);

    /// @notice Emitted when tokens are burned for deflation
    /// @param amount The amount of tokens burned
    event TokensBurned(uint256 amount);

    /// @notice Returns the current liquidation threshold
    /// @return The threshold of tokens for liquidity
    function liquidationThreshold() external view returns (uint256);

    /// @notice Returns the timestamp when the tax expires
    /// @return Timestamp when the tax expires (0 if not yet finalized)
    function taxExpirationTime() external view returns (uint256);
}

