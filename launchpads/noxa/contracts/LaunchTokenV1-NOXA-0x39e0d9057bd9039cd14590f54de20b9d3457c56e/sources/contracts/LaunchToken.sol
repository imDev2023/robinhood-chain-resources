// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IUniswapV3Factory {
    function getPool(address tokenA, address tokenB, uint24 fee) external view returns (address pool);
}

library LauncherTypes {
    struct Socials {
        string telegram;
        string twitter;
        string discord;
        string website;
        string farcaster;
    }

    struct TokenConfig {
        string name;
        string symbol;
        uint256 supply;
        address pairToken;
        address positionManager;
        address dexFactory;
        uint24 poolFee;
        uint16 maxWalletBps;
        uint16 maxTxBps;
        uint32 restrictionBlocks;
    }

    struct TokenInfo {
        address deployer;
        string logo;
        string description;
        Socials socials;
    }
}

contract LaunchToken is ERC20 {
    error MaxWalletExceeded(address account, uint256 balanceAfter, uint256 maxWallet);
    error MaxTxExceeded(address account, uint256 amount, uint256 maxTx);
    error LaunchBlockBuyBlocked(address account);

    LauncherTypes.TokenInfo private _tokenInfo;
    mapping(address account => uint256 amount) private _originBought;

    address public immutable launchFactory;
    address public immutable pairToken;
    address public immutable positionManager;
    address public immutable dexFactory;
    uint24 public immutable poolFee;
    uint16 public immutable maxWalletBps;
    uint16 public immutable maxTxBps;
    uint32 public immutable restrictionBlocks;
    uint256 public immutable launchBlock;
    uint256 public immutable restrictionEndBlock;
    uint256 public immutable maxWalletAmount;
    uint256 public immutable maxTxAmount;

    constructor(LauncherTypes.TokenConfig memory config, LauncherTypes.TokenInfo memory info)
        ERC20(config.name, config.symbol)
    {
        launchFactory = msg.sender;
        pairToken = config.pairToken;
        positionManager = config.positionManager;
        dexFactory = config.dexFactory;
        poolFee = config.poolFee;
        maxWalletBps = config.maxWalletBps;
        maxTxBps = config.maxTxBps;
        restrictionBlocks = config.restrictionBlocks;
        launchBlock = block.number;
        restrictionEndBlock = config.restrictionBlocks == 0 ? block.number : block.number + config.restrictionBlocks;
        maxWalletAmount = (config.supply * config.maxWalletBps) / 10_000;
        maxTxAmount = (config.supply * config.maxTxBps) / 10_000;

        _tokenInfo = info;

        _mint(msg.sender, config.supply);
    }

    function liquidityPool() public view returns (address) {
        return IUniswapV3Factory(dexFactory).getPool(address(this), pairToken, poolFee);
    }

    function maxWalletLimit() external view returns (uint256) {
        return maxWalletAmount;
    }

    function maxTxLimit() external view returns (uint256) {
        return maxTxAmount;
    }

    function getTokenInfo() external view returns (LauncherTypes.TokenInfo memory) {
        return _tokenInfo;
    }

    function deployer() external view returns (address) {
        return _tokenInfo.deployer;
    }

    function logo() external view returns (string memory) {
        return _tokenInfo.logo;
    }

    function description() external view returns (string memory) {
        return _tokenInfo.description;
    }

    function socials() external view returns (LauncherTypes.Socials memory) {
        return _tokenInfo.socials;
    }

    function _update(address from, address to, uint256 value) internal override {
        bool restrictionsActive = block.number > launchBlock && block.number <= restrictionEndBlock;
        address pool;
        bool onLaunchBlock = block.number == launchBlock;
        if (restrictionsActive || onLaunchBlock) {
            pool = liquidityPool();
            if (pool == address(0)) {
                restrictionsActive = false;
                onLaunchBlock = false;
            }
        }

        if (
            onLaunchBlock &&
            value > 0 &&
            from == pool &&
            to != launchFactory &&
            to != _tokenInfo.deployer
        ) {
            revert LaunchBlockBuyBlocked(to);
        }

        if (restrictionsActive && value > 0) {
            if (from == pool && to != launchFactory && to != _tokenInfo.deployer) {
                uint256 bought = _originBought[tx.origin] + value;
                _originBought[tx.origin] = bought;
                uint256 maxBuy = (maxTxAmount * 11_000) / 10_000;
                if (maxBuy == 0 || bought > maxBuy) {
                    revert MaxTxExceeded(tx.origin, bought, maxBuy);
                }
            }

            if (
                from != address(0) &&
                to != launchFactory &&
                to != _tokenInfo.deployer &&
                to != pool
            ) {
                uint256 balanceAfter = balanceOf(to) + value;
                if (balanceAfter > maxWalletAmount) {
                    revert MaxWalletExceeded(to, balanceAfter, maxWalletAmount);
                }
            }
        }

        super._update(from, to, value);
    }
}
