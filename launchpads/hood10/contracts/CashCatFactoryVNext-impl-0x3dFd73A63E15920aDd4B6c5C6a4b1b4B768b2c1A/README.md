# CashCatFactoryVNext-impl - 0x3dFd73A63E15920aDd4B6c5C6a4b1b4B768b2c1A

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x3dFd73A63E15920aDd4B6c5C6a4b1b4B768b2c1A
Role: CashCatFactoryVNext-impl.
Contract name: CashCatFactoryVNext.
Verified: True (verified at 2026-08-06T00:53:56.396839Z).
Compiler: v0.8.28+commit.7893614a, EVM cancun, optimizer True runs 800.
Main file: src/v4/CashCatFactoryVNext.sol.
Source files on disk: 75 under `sources/`.
Creator: 0x0679f72DCC42d8fBEB19FC2e0215Be8e7C090881.
Creation tx: 0xf0871106205ff3df6c8f3f11585be0508d813f5f0d3e5c1454c5464983766919.
Proxy type: None; implementations: [].
External libraries: none.

## Context, not part of the HOOD10 Launchpad

A verified `CashCatFactoryVNext` implementation for the letscash.fun proxy.
Not the implementation the proxy points at today: the EIP-1967 slot reads 0x40250b4C73FC30f8F6ad077744B0124B3f111C28.
Kept because it is the readable source for that generation of the CashCat factory, including `CashCatLaunchSplitter`, `CashCatSelfBurnerV2` and `CashCatHookV2`.

## Constructor arguments

None decoded.

## Events

- `FeeSplitterDeployed(bytes32,address,address[],uint16[])`
- `Initialized(uint64)`
- `LaunchConfigAdded(uint256,tuple)`
- `LaunchConfigEnabled(uint256,bool)`
- `LaunchEnabledUpdated(bool)`
- `LaunchFeeUpdated(uint256,uint256)`
- `MigratedToVNext(uint256,uint256)`
- `ModuleSetPublished(uint256,tuple)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `QuoteApprovalUpdated(address,bool)`
- `TokenLaunched(address,address,bytes32,uint256,uint256,uint256,address,address)`
- `TokenLaunchedVNext(address,bytes32,address,uint256,address)`
- `TreasuryUpdated(address,address)`
- `Upgraded(address)`

## State-changing functions

- `acceptOwnership()`
- `initializeVNext()`
- `launch(tuple,uint256,uint256,uint256,bytes32)`
- `launchWithFeeSplit(tuple,uint256,uint256,uint256,bytes32,address[],uint16[])`
- `launchWithPermit(tuple,uint256,uint256,uint256,bytes32,address[],uint16[],tuple)`
- `publishConfig(tuple)`
- `publishModuleSet(address,address,address,address)`
- `renounceOwnership()`
- `rescueToken(address,address)`
- `setApprovedQuote(address,bool)`
- `setLaunchConfigEnabled(uint256,bool)`
- `setLaunchEnabled(bool)`
- `setLaunchFee(uint256)`
- `setTreasury(address)`
- `sweep()`
- `transferOwnership(address)`
- `unlockCallback(bytes)`
- `upgradeToAndCall(address,bytes)`

## View functions

- `BPS_DENOMINATOR()`
- `FIRST_CONFIG_ID()`
- `MAX_FEE_RATE()`
- `MIN_QUOTE_DECIMALS()`
- `MODULE_GENERATION()`
- `PIPS_PER_BP()`
- `UPGRADE_INTERFACE_VERSION()`
- `approvedQuote(address)`
- `configCount()`
- `currentSplitterOf(bytes32)`
- `firstConfigId()`
- `getLaunchConfig(uint256)`
- `getModuleSet(uint256)`
- `launchConfigCount()`
- `launchEnabled()`
- `launchFee()`
- `launchSplitterOf(bytes32)`
- `mineSalt(tuple,uint256,address,uint256,uint256)`
- `moduleSetCount()`
- `nextConfigId()`
- `owner()`
- `pendingOwner()`
- `poolManager()`
- `predictTokenAddress(tuple,uint256,address,bytes32)`
- `proxiableUUID()`
- `publishedConfigCount()`
- `retiredConfigCount()`
- `retiredPointers()`
- `treasury()`
