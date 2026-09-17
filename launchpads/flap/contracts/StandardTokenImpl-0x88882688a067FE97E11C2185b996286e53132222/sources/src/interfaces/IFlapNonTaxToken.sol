// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {
    IERC20MetadataUpgradeable
} from "@openzeppelin-contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

import {
    IERC20PermitUpgradeable
} from "@openzeppelin-contracts-upgradeable/token/ERC20/extensions/IERC20PermitUpgradeable.sol";

interface IFlapNonTaxToken is IERC20MetadataUpgradeable, IERC20PermitUpgradeable {
    /// @notice Packed initialization parameters for initialize().
    ///         Using a struct reduces EVM stack pressure at call sites.
    struct InitParams {
        /// @dev All known pool addresses.
        ///      MUST include `mainPool`.
        ///      Blocked during BondingCurve phase and during anti-farmer.
        address[] pools;
        /// @dev The primary trading pool.
        address mainPool;
        /// @dev Uniswap v2 pool address.
        address v2Pool;
        /// @dev Uniswap v3 pool address.
        address v3Pool;
        /// @dev The token name.
        string name;
        /// @dev The token symbol.
        string symbol;
        /// @dev The token metadata URI.
        string meta;
        /// @dev The maximum supply of the token.
        uint256 maxSupply;
        /// @dev Anti-farmer period in seconds (stored; converted to absolute expiry
        ///      by removeTransferConstraints() at graduation time).
        uint256 antiFarmerDuration;
    }

    /// @notice Initialize the token.
    function initialize(InitParams memory params) external;

    /// @notice Remove the transferring constraints of the token
    /// @dev This can only be called by the owner of the contract
    function removeTransferConstraints() external;

    function metaURI() external view returns (string memory);

    /// @notice the max supply of the token
    function maxSupply() external view returns (uint256);

    /// @notice the predicted pool address for uniswap v2 & v3
    function pools() external view returns (address v2, address v3);

    /// @notice Timestamp when the anti-farmer period ends.
    function antiFarmerExpirationTime() external view returns (uint256);

    //
    // Customized Events to ease the indexer
    //

    // custom transfer event

    /// @notice the same as the ERC20 Transfer event, we intentionally duplicate it here
    /// This would make the indexer easier to index our transfer event only.
    /// To save gas, we remove indexed from the from and to
    event TransferFlapToken(address from, address to, uint256 value);
}

