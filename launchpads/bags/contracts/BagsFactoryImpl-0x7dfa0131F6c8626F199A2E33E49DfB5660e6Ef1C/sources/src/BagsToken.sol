// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

// OpenZeppelin
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

// Local interfaces
import {IBagsToken} from "src/interfaces/IBagsToken.sol";

/// @title BagsToken
/// @notice ERC20 with 18 decimals, EIP-2612 permit, and a one-time initial mint to a bonding curve.
///         Supports both direct deployment (`new`) and EIP-1167 minimal proxy clones (factory).
/// @dev Clone-safe permit: OZ's EIP712 caches the domain separator for the deploying address only,
///      and `_domainSeparatorV4()` rebuilds it whenever `address(this)` differs from the cached
///      template address — which is always true for clones. The EIP-712 domain therefore uses the
///      protocol-wide name "Bags Token" (version "1") baked into the implementation bytecode, and
///      each clone still gets a unique separator via its own `address(this)` (verified against
///      lib/openzeppelin-contracts v5.4.0). The short name fits in a ShortString immutable, so the
///      EIP712 constructor writes no storage and the template stays clone-compatible.
/// @author Bags
contract BagsToken is ERC20Permit, Ownable, IBagsToken {
    /// @notice Fixed decimals for this token (18)
    uint256 public constant DECIMALS = 18;
    /// @notice Fixed total supply minted once to the bonding curve
    uint256 public constant INITIAL_SUPPLY = 1_000_000_000 * 10 ** DECIMALS; // 1e9 * 1e18

    /// @notice Off-chain metadata URI for the token (set at initialization)
    string public metadataURI;

    /// @dev Token name stored in contract storage (used for clones where ERC20 constructor doesn't run)
    string private _tokenName;
    /// @dev Token symbol stored in contract storage (used for clones where ERC20 constructor doesn't run)
    string private _tokenSymbol;
    /// @dev Prevents initialize() from being called more than once (or on a directly deployed instance)
    bool private _cloneInitialized;

    /// @dev Guards mintInitialSupply() to ensure it can only be called once
    bool private _initialMintDone;

    /// @notice Deploys the implementation template and locks it against initialize()
    /// @dev Only used once to create the clone template. All real state is set via initialize().
    ///      The EIP-712 domain name is protocol-wide by design (see contract NatSpec).
    constructor() ERC20("", "") ERC20Permit("Bags Token") Ownable(msg.sender) {
        _cloneInitialized = true;
    }

    // ====================================================================
    // EXTERNAL FUNCTIONS
    // ====================================================================

    /// @notice Initialize a clone created via Clones.clone()
    /// @dev Reverts if already initialized (constructor or previous initialize call)
    /// @param name_ Token name
    /// @param symbol_ Token symbol
    /// @param metadataURI_ Off-chain metadata URI
    /// @param initialOwner Address that will be set as the owner
    function initialize(
        string memory name_,
        string memory symbol_,
        string memory metadataURI_,
        address initialOwner
    ) external override {
        if (_cloneInitialized) revert BagsToken_AlreadyInitialized();
        _cloneInitialized = true;
        if (bytes(metadataURI_).length == 0) revert BagsToken_EmptyMetadataURI();
        _tokenName = name_;
        _tokenSymbol = symbol_;
        metadataURI = metadataURI_;
        _transferOwnership(initialOwner);
    }

    /// @notice One-time mint of the full fixed supply to a recipient (the bonding curve)
    /// @dev Only the owner (Factory) can call this, and only once
    /// @param recipient Address that receives the initial fixed supply
    function mintInitialSupply(
        address recipient
    ) external override onlyOwner {
        if (_initialMintDone) revert BagsToken_InitialMintAlreadyDone();
        if (recipient == address(0)) revert BagsToken_ZeroAddressRecipient();
        _initialMintDone = true;
        _mint(recipient, INITIAL_SUPPLY);
        emit InitialSupplyMinted(recipient, INITIAL_SUPPLY);
    }

    // ====================================================================
    // PUBLIC FUNCTIONS
    // ====================================================================

    /// @notice Returns token name from storage (works for both direct deploy and clones)
    /// @return Token name
    function name() public view override(ERC20, IBagsToken) returns (string memory) {
        return _tokenName;
    }

    /// @notice Returns token symbol from storage (works for both direct deploy and clones)
    /// @return Token symbol
    function symbol() public view override(ERC20, IBagsToken) returns (string memory) {
        return _tokenSymbol;
    }

    /// @notice Returns token decimals (18)
    /// @return decimalsCount Fixed decimals value (18)
    function decimals() public pure override(ERC20, IBagsToken) returns (uint8 decimalsCount) {
        return 18;
    }

    /// @notice Returns the current EIP-2612 permit nonce for an owner
    /// @param owner Address to query
    /// @return Current nonce
    function nonces(
        address owner
    ) public view override(ERC20Permit, IERC20Permit) returns (uint256) {
        return super.nonces(owner);
    }
}
