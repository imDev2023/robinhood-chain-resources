// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

/// @title Safety Deposit Box - Smart LP registry
/// @notice Tiny on-chain index of official Smart LP vaults. Vaults are deployed
///         directly (script `new SmartLpVault`) rather than through an on-chain
///         factory: inlining the vault creation code in a factory is the EIP-170
///         trap the launcher hit, and a deployer indirection buys nothing for an
///         owner-curated lineup. The registry is the ONLY discovery surface the
///         UI trusts; listing here is an explicit curation act.
contract SmartLpRegistry {
    error NotOwner();
    error AlreadyListed();
    error NotListed();
    error BadParams();

    event VaultListed(address indexed vault, address indexed pool, uint8 mode);
    event VaultDelisted(address indexed vault);
    event OwnerSet(address owner);

    address public owner;
    address[] public vaults;
    mapping(address => bool) public isListed;

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(address _owner) {
        if (_owner == address(0)) revert BadParams();
        owner = _owner;
    }

    function list(address vault, address pool, uint8 mode) external onlyOwner {
        if (vault == address(0)) revert BadParams();
        if (isListed[vault]) revert AlreadyListed();
        isListed[vault] = true;
        vaults.push(vault);
        emit VaultListed(vault, pool, mode);
    }

    /// @notice Delisting only removes the vault from the UI surface; the vault
    ///         itself is immutable and withdrawals keep working forever.
    function delist(address vault) external onlyOwner {
        if (!isListed[vault]) revert NotListed();
        isListed[vault] = false;
        uint256 n = vaults.length;
        for (uint256 i = 0; i < n; i++) {
            if (vaults[i] == vault) {
                vaults[i] = vaults[n - 1];
                vaults.pop();
                break;
            }
        }
        emit VaultDelisted(vault);
    }

    function setOwner(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert BadParams();
        owner = newOwner;
        emit OwnerSet(newOwner);
    }

    function count() external view returns (uint256) {
        return vaults.length;
    }

    function all() external view returns (address[] memory) {
        return vaults;
    }
}
