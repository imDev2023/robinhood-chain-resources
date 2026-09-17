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
        address locker; // FIX F-7 — fee-custody contract, excluded from anti-snipe limits
        uint24 poolFee;
        uint16 maxWalletBps;
        uint16 maxTxBps;
        uint32 restrictionSeconds; // anti-snipe window duration in SECONDS (real time)
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

    LauncherTypes.TokenInfo private _tokenInfo;
    mapping(address account => uint256 amount) private _originBought;

    address public immutable launchFactory;
    address public immutable pairToken;
    address public immutable positionManager;
    address public immutable dexFactory;
    address public immutable locker; // FIX F-7 — excluded from anti-snipe so fee collection can't revert
    uint24 public immutable poolFee;
    uint16 public immutable maxWalletBps;
    uint16 public immutable maxTxBps;
    uint32 public immutable restrictionSeconds;
    // NB: on Robinhood Chain the `block.number` opcode returns the L1 block number (~12s cadence),
    // NOT an L2 per-block counter — far too coarse for any per-block logic — so this contract never
    // uses block.number. ALL anti-snipe is wall-clock (block.timestamp) based.
    uint256 public immutable launchTime; // block.timestamp at deploy (wall-clock, reliable)
    uint256 public immutable restrictionEndTime; // launchTime + restrictionSeconds
    uint256 public immutable maxWalletAmount;
    uint256 public immutable maxTxAmount;

    constructor(LauncherTypes.TokenConfig memory config, LauncherTypes.TokenInfo memory info)
        ERC20(config.name, config.symbol)
    {
        launchFactory = msg.sender;
        pairToken = config.pairToken;
        positionManager = config.positionManager;
        dexFactory = config.dexFactory;
        locker = config.locker;
        poolFee = config.poolFee;
        maxWalletBps = config.maxWalletBps;
        maxTxBps = config.maxTxBps;
        restrictionSeconds = config.restrictionSeconds;
        launchTime = block.timestamp;
        restrictionEndTime = block.timestamp + config.restrictionSeconds;
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
        // Anti-snipe is wall-clock only (block.timestamp) and scoped to BUYS. The window is active
        // from launch (t0) through restrictionEndTime. We only meter/limit tokens LEAVING the pool
        // (from == pool) to a normal wallet, which means sells (to == pool), wallet-to-wallet
        // transfers, and any router/aggregator that holds tokens mid-swap are NEVER restricted — the
        // token can always be sold. block.number is deliberately not used (it is the L1 block number
        // on this chain, ~12s cadence, and the old `== launchBlock` check blocked ALL buys for up to
        // one full L1 block after launch, which honeypot scanners correctly flag as a transfer trap).
        if (value > 0 && block.timestamp <= restrictionEndTime) {
            address pool = liquidityPool();
            // FIX F-7 — the fee-custody `locker` is excluded (collectFees transfers pool->locker
            // during the window). FIX F-9 — the per-address buy meter keys on the RECIPIENT (`to`),
            // the same entity the max-wallet cap tracks, which is correct under AA/bundlers/aggregators
            // where tx.origin is a shared relayer.
            if (
                pool != address(0) &&
                from == pool &&
                to != launchFactory &&
                to != _tokenInfo.deployer &&
                to != locker
            ) {
                // Per-address cumulative buy cap (maxTx, +10% headroom).
                uint256 bought = _originBought[to] + value;
                _originBought[to] = bought;
                uint256 maxBuy = (maxTxAmount * 11_000) / 10_000;
                if (maxBuy == 0 || bought > maxBuy) {
                    revert MaxTxExceeded(to, bought, maxBuy);
                }
                // Per-wallet holding cap.
                uint256 balanceAfter = balanceOf(to) + value;
                if (balanceAfter > maxWalletAmount) {
                    revert MaxWalletExceeded(to, balanceAfter, maxWalletAmount);
                }
            }
        }

        super._update(from, to, value);
    }
}
