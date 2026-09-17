// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

/// @title IBagsToken
/// @notice Interface for `BagsToken` ERC20 with one-time fixed mint, EIP-2612 permit, and clone support
/// @dev Extends IERC20Permit: `permit(owner, spender, value, deadline, v, r, s)`, `nonces(owner)`,
///      and `DOMAIN_SEPARATOR()`. The EIP-712 domain uses the protocol-wide name "Bags Token"
///      (version "1") for every clone; separators are still unique per clone via `address(this)`.
/// @author Bags
interface IBagsToken is IERC20Permit {
    /// @notice Emitted when the initial fixed supply is minted to the bonding curve
    /// @param recipient Recipient address
    /// @param amount Amount minted
    event InitialSupplyMinted(address indexed recipient, uint256 amount);

    /// @notice Metadata URI must be non-empty
    error BagsToken_EmptyMetadataURI();
    /// @notice Initial supply has already been minted
    error BagsToken_InitialMintAlreadyDone();
    /// @notice Recipient address is zero
    error BagsToken_ZeroAddressRecipient();
    /// @notice Clone has already been initialized
    error BagsToken_AlreadyInitialized();

    /// @notice Fixed decimals for this token (18)
    /// @return decimalsCount Fixed decimals value (18)
    function DECIMALS() external view returns (uint256 decimalsCount);
    /// @notice Fixed total supply minted once to the bonding curve
    /// @return supply Initial total supply
    function INITIAL_SUPPLY() external view returns (uint256 supply);
    /// @notice Off-chain metadata URI for the token
    /// @return uri Metadata URI string
    function metadataURI() external view returns (string memory uri);

    /// @notice Initialize a clone created via Clones.clone()
    /// @param name_ Token name
    /// @param symbol_ Token symbol
    /// @param metadataURI_ Off-chain metadata URI
    /// @param initialOwner Address that will be set as the owner
    function initialize(
        string memory name_,
        string memory symbol_,
        string memory metadataURI_,
        address initialOwner
    ) external;

    /// @notice Returns token name
    /// @return Token name
    function name() external view returns (string memory);
    /// @notice Returns token symbol
    /// @return Token symbol
    function symbol() external view returns (string memory);
    /// @notice Returns token decimals (18)
    /// @return decimalsCount Fixed decimals value (18)
    function decimals() external pure returns (uint8 decimalsCount);
    /// @notice One-time mint of the full fixed supply to a recipient (the bonding curve)
    /// @param recipient Address that receives the initial fixed supply
    function mintInitialSupply(
        address recipient
    ) external;
}
