# LaunchFactoryV4Impl - 0x818fdd15dbe95851a0bd8c5389c49ed6d4fe2bbf

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x818fdd15dbe95851a0bd8c5389c49ed6d4fe2bbf
Role: LaunchFactoryV4Impl.
Contract name: SentryLaunchFactoryV4.
Verified: True (verified at 2026-07-25T12:39:16.758073Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/SentryLaunchFactoryV4.sol.
Source files written: 27 under `sources/`.
Creator: 0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5.
Creation tx: 0x6ef7e9b4f966531c27a68253450660f2d759e270f5d874b70409c72fa07ec255.
Proxy type: None; implementations: [].

Implementation shared by both live v4 factories (WETH pairs and stock pairs).

## Constructor arguments

None decoded.

## Events

- `BaseTokenAdded(address,address)`
- `BaseTokenRemoved(address)`
- `CreatorFeeBpsUpdated(uint256,uint256)`
- `FeeRecipientUpdated(address,address,address,address)`
- `HookUpdated(address,address)`
- `Initialized(address,address,address)`
- `LiquidityLocked(bytes32,address,uint128)`
- `MigratedToVault(address,bytes32,uint128)`
- `ParamSourceUpdated(address,address,address)`
- `ReflectionHookUpdated(address,address)`
- `StockBaseTokenAdded(address,address,address)`
- `TokenDeployed(address,string,string,address,bytes32)`
- `TreasuryUpdated(address,address)`
- `VaultProposed(address)`
- `VaultUpdated(address,address)`

## State-changing functions

- `acceptVault()`
- `addBaseToken(address,address)`
- `addStockBaseToken(address,address,address)`
- `adminSetFeeRecipient(address,address)`
- `initialize(address,address,address,address,address)`
- `launch(string,string,address)`
- `launchWithFeeRecipient(string,string,address,address)`
- `launchWithReflections(string,string,address,address,address[])`
- `launchWithWhitelist(string,string,address,address,address[])`
- `migrateFeeRecipient(address,address)`
- `migrateToVault(address)`
- `proposeVault(address)`
- `removeBaseToken(address)`
- `setCreatorFeeBps(uint256)`
- `setReflectionHook(address)`
- `transferOwnership(address)`
- `unlockCallback(bytes)`
- `updateHook(address)`
- `updateParamSource(address,address)`
- `updateTreasury(address)`

## View functions

- `TICK_SPACING()`
- `baseTokenToHook(address)`
- `baseTokenToPoolManager(address)`
- `baseTokens(uint256)`
- `creatorFeeBps()`
- `creatorTokens(address,uint256)`
- `feeRecipientMigrated(address)`
- `feeRecipientOf(address)`
- `feeRecipients(address)`
- `getCreator(address)`
- `getCreatorTokenCount(address)`
- `getCreatorTokens(address)`
- `getParamSource(address)`
- `getSupportedBaseTokens()`
- `getTotalTokensDeployed()`
- `hook()`
- `isReflectionToken(address)`
- `isStockBase(address)`
- `launches(address)`
- `migratedToVault(address)`
- `owner()`
- `pendingVault()`
- `poolIdOf(address)`
- `poolKeyOf(address)`
- `poolManager()`
- `reflectionHook()`
- `totalTokensDeployed()`
- `treasury()`
- `vault()`
