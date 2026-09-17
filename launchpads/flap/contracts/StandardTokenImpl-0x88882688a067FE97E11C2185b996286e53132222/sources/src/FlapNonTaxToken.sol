// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {IFlapNonTaxToken} from "./interfaces/IFlapNonTaxToken.sol";

import {ERC20Upgradeable} from "@openzeppelin-contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {
    ERC20PermitUpgradeable
} from "@openzeppelin-contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";

/// @notice Token with max supply and metaURI
contract FlapNonTaxToken is IFlapNonTaxToken, ERC20PermitUpgradeable, OwnableUpgradeable {
    /// @notice The max supply of the token
    uint256 public maxSupply;

    /// @notice URI for the token metadata
    string public metaURI;

    /// @notice If true, transferring to uniswap v2/v3 pool is not allowed
    bool public transferConstraints;

    /// @dev uniswap v2 pool
    address internal uniswapV2Pool;

    /// @dev uni v3 pool
    address internal uniswapV3Pool;

    /// @notice The primary trading pool — the UniV2 pair for this token.
    ///         This address MUST also be present in `pools` at initialize() time.
    ///         During the anti-farmer period only this pool is exempt from the transfer block,
    ///         allowing normal DEX swaps (and LP provisioning at graduation) to continue.
    address public mainPool;

    /// @notice All known pool addresses for this token.
    ///         Populated from MULTI_DEX_ROUTER.getAllTradingPools() at launch time.
    mapping(address => bool) internal _pools;

    /// @notice The duration of the anti-farmer period in seconds.
    ///         Stored at initialize() time; removeTransferConstraints() converts it to an expiry timestamp.
    uint256 public antiFarmerDuration;

    uint256 public antiFarmerExpirationTime;

    error InvalidAddress();
    error MainPoolNotRegistered();
    error DirectPoolManagerTransferBlocked();

    constructor() {
        _disableInitializers();
    }

    /// @dev Reverts with InvalidAddress if addr is zero.
    function _requireNotZero(address addr) internal pure {
        if (addr == address(0)) revert InvalidAddress();
    }

    function initialize(InitParams memory params) external override initializer {
        __ERC20_init(params.name, params.symbol);
        __ERC20Permit_init(params.name);
        __Ownable_init();

        _requireNotZero(params.mainPool);

        mainPool = params.mainPool;
        uniswapV2Pool = params.v2Pool;
        uniswapV3Pool = params.v3Pool;
        maxSupply = params.maxSupply;
        metaURI = params.meta;
        antiFarmerDuration = params.antiFarmerDuration;

        uint256 numPools = params.pools.length;
        for (uint256 i = 0; i < numPools; i++) {
            if (params.pools[i] != address(0)) _pools[params.pools[i]] = true;
        }
        if (!_pools[params.mainPool]) revert MainPoolNotRegistered();

        // restrict transferring when initialized
        transferConstraints = true;

        // mint the maxsupply to the msg.sender
        _mint(msg.sender, params.maxSupply);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal override {
        // emit our custom event for easier indexing
        emit TransferFlapToken(from, to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256) internal view override {
        if (transferConstraints) {
            // BondingCurve: block all transfers to/from any registered pool.
            if (_pools[from] || _pools[to]) revert DirectPoolManagerTransferBlocked();
        } else if (antiFarmerExpirationTime != 0 && block.timestamp <= antiFarmerExpirationTime) {
            // EnforcedAntiFarmer (V2/V3 path): mainPool trades are allowed so that normal
            // DEX swaps continue to work. All other registered pools are blocked.
            //
            // LP provisioning safety: removeTransferConstraints() and _mintToken(token, amount, pool)
            // are called in the same migration tx. At that point `to == pool == mainPool`, so the
            // mainPool exemption lets the token transfer to the pair through without reverting.
            if ((_pools[from] && from != mainPool) || (_pools[to] && to != mainPool)) {
                revert DirectPoolManagerTransferBlocked();
            }
        }
        // Free: no restrictions (anti-farmer period has elapsed)
    }

    /// @inheritdoc IFlapNonTaxToken
    function removeTransferConstraints() external override onlyOwner {
        transferConstraints = false;
        antiFarmerExpirationTime = block.timestamp + antiFarmerDuration;
    }

    /// @inheritdoc IFlapNonTaxToken
    function pools() external view override returns (address v2, address v3) {
        return (uniswapV2Pool, uniswapV3Pool);
    }
}

