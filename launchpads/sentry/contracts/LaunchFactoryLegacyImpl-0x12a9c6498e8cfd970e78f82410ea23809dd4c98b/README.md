# LaunchFactoryLegacyImpl - 0x12a9c6498e8cfd970e78f82410ea23809dd4c98b

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x12a9c6498e8cfd970e78f82410ea23809dd4c98b
Role: LaunchFactoryLegacyImpl.
Contract name: SentryLaunchFactory.
Verified: True (verified at 2026-07-25T13:21:32.253044Z).
Compiler: v0.8.20+commit.a1b79de6, EVM paris, optimizer True runs 200.
Main file: src/SentryLaunchFactory.sol.
Source files written: 3 under `sources/`.
Creator: 0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5.
Creation tx: 0x596ccfc8055acab01dc526ba5992225066c459f9db18ca45d6ef5dee9bf0313f.
Proxy type: None; implementations: [].

Implementation behind the legacy V3 factory proxy.

## Constructor arguments

None decoded.

## Events

- `BaseTokenAdded(address,address)`
- `BaseTokenRemoved(address)`
- `CreatorFeeBpsUpdated(uint256,uint256)`
- `CreatorFeePaid(uint256,address,address,uint256)`
- `FeeRecipientUpdated(uint256,address,address,address)`
- `FeesCollected(uint256,uint256,uint256)`
- `Initialized(address,address)`
- `LPLocked(uint256,address,address)`
- `LPSweptToVault(uint256,address,address,address)`
- `LiquidityMinted(uint256,address,address)`
- `NPMUpdated(address,address)`
- `PoolInitialized(address,address)`
- `PoolManagerUpdated(address,address,address)`
- `TokenDeployed(address,string,string,address,uint256)`
- `TreasuryUpdated(address,address)`

## State-changing functions

- `addBaseToken(address,address)`
- `adminSetFeeRecipient(uint256,address)`
- `collectFees(uint256)`
- `collectMultipleFees(uint256[])`
- `initialize(address,address,address,address)`
- `launch(string,string,address)`
- `launchWithFeeRecipient(string,string,address,address)`
- `migrateFeeRecipient(uint256,address)`
- `removeBaseToken(address)`
- `setCreatorFeeBps(uint256)`
- `sweepToVault(uint256[],address)`
- `transferOwnership(address)`
- `updateNPM(address)`
- `updatePoolManager(address,address)`
- `updateTreasury(address)`

## View functions

- `CREATOR_FEE_BPS()`
- `FEE_TIER()`
- `baseTokenToPoolManager(address)`
- `baseTokens(uint256)`
- `creatorFeeBps()`
- `creatorNFTs(address,uint256)`
- `feeRecipientMigrated(uint256)`
- `feeRecipientOf(uint256)`
- `feeRecipients(uint256)`
- `getCreator(uint256)`
- `getCreatorNFTCount(address)`
- `getCreatorNFTs(address)`
- `getPoolManager(address)`
- `getSupportedBaseTokens()`
- `getTokenByNFT(uint256)`
- `getTotalTokensDeployed()`
- `nftCreators(uint256)`
- `npm()`
- `onERC721Received(address,address,uint256,bytes)`
- `owner()`
- `tokenIdToToken(uint256)`
- `totalTokensDeployed()`
- `treasury()`
