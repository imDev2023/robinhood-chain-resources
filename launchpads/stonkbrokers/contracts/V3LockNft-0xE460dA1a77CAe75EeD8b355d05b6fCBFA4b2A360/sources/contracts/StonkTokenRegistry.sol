// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @notice Simple on-chain whitelist + display metadata registry for the Stonk ecosystem.
/// Intended for testnet / early mainnet usage; metadata is advisory for UI.
contract StonkTokenRegistry is Ownable {
    struct TokenInfo {
        bool whitelisted;
        string symbol;
        uint8 decimals;
        string logoURI; // optional (ipfs://..., https://..., etc.)
        string metadataURI; // optional (ipfs://... JSON metadata)
    }

    /// @dev token => info
    mapping(address => TokenInfo) private info;

    /// @dev enumerable list of tokens we have ever touched.
    address[] private tokens;
    mapping(address => uint256) private tokenIndexPlusOne;

    /// @notice Optional privileged factory allowed to auto-register launched tokens.
    address public launcherFactory;

    event LauncherFactoryUpdated(address indexed oldFactory, address indexed newFactory);
    event TokenUpdated(
        address indexed token,
        bool whitelisted,
        string symbol,
        uint8 decimals,
        string logoURI,
        string metadataURI
    );

    error NotFactory();
    error TokenZero();

    constructor(address initialOwner) Ownable(initialOwner) {}

    function setLauncherFactory(address newFactory) external onlyOwner {
        emit LauncherFactoryUpdated(launcherFactory, newFactory);
        launcherFactory = newFactory;
    }

    function setToken(
        address token,
        bool whitelisted,
        string calldata symbol,
        uint8 decimals_,
        string calldata logoURI,
        string calldata metadataURI
    ) external onlyOwner {
        _upsert(token);
        info[token] = TokenInfo({
            whitelisted: whitelisted,
            symbol: symbol,
            decimals: decimals_,
            logoURI: logoURI,
            metadataURI: metadataURI
        });
        emit TokenUpdated(token, whitelisted, symbol, decimals_, logoURI, metadataURI);
    }

    /// @notice Called by launcher factory when a token is launched.
    function registerLaunchedToken(
        address token,
        string calldata symbol,
        uint8 decimals_,
        string calldata logoURI,
        string calldata metadataURI
    ) external {
        if (msg.sender != launcherFactory) revert NotFactory();
        _upsert(token);

        // Always whitelist launched tokens by default.
        info[token] = TokenInfo({
            whitelisted: true,
            symbol: symbol,
            decimals: decimals_,
            logoURI: logoURI,
            metadataURI: metadataURI
        });
        emit TokenUpdated(token, true, symbol, decimals_, logoURI, metadataURI);
    }

    function isWhitelisted(address token) external view returns (bool) {
        return info[token].whitelisted;
    }

    function getToken(address token) external view returns (TokenInfo memory) {
        return info[token];
    }

    function tokenCount() external view returns (uint256) {
        return tokens.length;
    }

    function tokenAt(uint256 index) external view returns (address) {
        require(index < tokens.length, "index");
        return tokens[index];
    }

    function listTokens(uint256 offset, uint256 limit) external view returns (address[] memory out) {
        if (offset >= tokens.length) return new address[](0);
        uint256 end = offset + limit;
        if (end > tokens.length) end = tokens.length;
        out = new address[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            out[i - offset] = tokens[i];
        }
    }

    function _upsert(address token) internal {
        if (token == address(0)) revert TokenZero();
        if (tokenIndexPlusOne[token] == 0) {
            tokens.push(token);
            tokenIndexPlusOne[token] = tokens.length; // index+1
        }
    }
}

