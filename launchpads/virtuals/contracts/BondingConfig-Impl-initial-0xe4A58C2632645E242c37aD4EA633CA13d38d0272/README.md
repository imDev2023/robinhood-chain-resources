# BondingConfig-Impl-initial - 0xe4A58C2632645E242c37aD4EA633CA13d38d0272

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xe4A58C2632645E242c37aD4EA633CA13d38d0272
Role: BondingConfig-Impl-initial.
Contract name: BondingConfig.
Verified: True (verified at 2026-07-02T07:03:59.417679Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/launchpadv2/BondingConfig.sol.
Source files written: 4 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0xc844285afc0ffa0c8e3b52c8ae3cf670cb3a5909e26dd48e1a7bf01fc6560155.
Proxy type: None; implementations: [].

First BondingConfig implementation (2026-06-25); superseded.

## Constructor arguments

None decoded.

## Events

- `AcfFakeInitialVirtualLiqUpdated(uint256)`
- `BondingCurveParamsUpdated(tuple)`
- `CommonParamsUpdated(uint256,address)`
- `DeployParamsUpdated(tuple)`
- `GraduationExcessBurnWalletUpdated(address)`
- `Initialized(uint64)`
- `LegacyInitialVirtualLiqUpdated(uint256)`
- `OwnershipTransferred(address,address)`
- `PrivilegedLauncherUpdated(address,bool)`
- `ReserveSupplyParamsUpdated(tuple)`
- `TeamTokenReservedWalletUpdated(address)`

## State-changing functions

- `initialize(uint256,address,address,tuple,tuple,tuple,tuple,uint256)`
- `renounceOwnership()`
- `setBondingCurveParams(tuple,uint256)`
- `setCommonParams(uint256,address)`
- `setDeployParams(tuple)`
- `setGraduationExcessBurnWallet(address)`
- `setLegacyInitialVirtualLiq(uint256)`
- `setPrivilegedLauncher(address,bool)`
- `setReserveSupplyParams(tuple)`
- `setScheduledLaunchParams(tuple)`
- `setTeamTokenReservedWallet(address)`
- `transferOwnership(address)`

## View functions

- `ANTI_SNIPER_60S()`
- `ANTI_SNIPER_98M()`
- `ANTI_SNIPER_NONE()`
- `LAUNCH_MODE_ACP_SKILL()`
- `LAUNCH_MODE_NORMAL()`
- `LAUNCH_MODE_X_LAUNCH()`
- `acfFakeInitialVirtualLiq()`
- `bondingCurveParams()`
- `calculateBondingCurveSupply(uint16,bool)`
- `calculateGradThreshold(uint256,bool)`
- `calculateLaunchFee(bool,bool)`
- `deployParams()`
- `feeTo()`
- `getAntiSniperDuration(uint8)`
- `getDeployParams()`
- `getFakeInitialVirtualLiq()`
- `getFakeInitialVirtualLiq(bool)`
- `getLegacyInitialVirtualLiq()`
- `getScheduledLaunchParams()`
- `getTargetRealVirtual()`
- `graduationExcessBurnWallet()`
- `initialSupply()`
- `isPrivilegedLauncher(address)`
- `isValidAntiSniperType(uint8)`
- `legacyInitialVirtualLiq()`
- `owner()`
- `reserveSupplyParams()`
- `scheduledLaunchParams()`
- `teamTokenReservedWallet()`
