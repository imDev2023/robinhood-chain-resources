//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ILPVault {
    error OnlyFactory();
    error ZeroAddress();

    /// @dev Collect fees from `tokenId` and pay them to the vault's immutable FACTORY.
    function collect(uint256 tokenId) external returns (uint256 amount0, uint256 amount1);

    /// @dev The factory proxy this vault pays and takes orders from. Used by the token's
    ///      seedInitialLiquidity guard to reject a vault that belongs to something else.
    function FACTORY() external view returns (address);

    function POSITION_MANAGER() external view returns (address);
}
