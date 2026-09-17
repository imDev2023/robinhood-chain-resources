// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @notice Shared structs for the RobinFun launcher protocol.
library LauncherTypes {
    struct Socials {
        string telegram;
        string twitter;
        string discord;
        string website;
        string farcaster;
    }

    struct LaunchParams {
        string name;
        string symbol;
        string logo; // ipfs:// URI
        string description;
        Socials socials;
        address devWallet; // initial CTO leader / legacy creator-fee beneficiary
    }

    struct LaunchConfig {
        address pairToken; // e.g. WETH
        uint256 dexId; // default dex for this config
        int24 initialTick; // starting tick assuming token is token0 (mirrored otherwise)
        uint256 supply;
        uint16 maxWalletBps;
        uint16 maxTxBps;
        uint32 restrictionBlocks;
        uint24 buyPairHopFee;
        bool enabled;
        bool permissioned;
    }

    struct DexConfig {
        address dexFactory;
        address positionManager;
        address router;
        uint24 poolFee;
        int24 tickSpacing;
        bool enabled;
    }

    struct LaunchedToken {
        address token;
        address deployer;
        address feeWallet; // initial CTO leader; live LP fees are routed through factory.ctoVaultOf(token)
        address pairToken;
        address pool;
        uint256 dexId;
        uint256 launchConfigId;
        uint256 positionId;
        uint256 restrictionsEndBlock;
        uint256 initialBuyAmount;
        uint256 createdAtBlock;
        bool isToken0;
    }
}
