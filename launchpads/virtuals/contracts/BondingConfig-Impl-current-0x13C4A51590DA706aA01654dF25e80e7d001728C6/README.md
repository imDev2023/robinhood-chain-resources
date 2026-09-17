# BondingConfig-Impl-current - 0x13C4A51590DA706aA01654dF25e80e7d001728C6

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x13C4A51590DA706aA01654dF25e80e7d001728C6
Role: BondingConfig-Impl-current.
Contract name: BondingConfig.
Verified: True (verified at 2026-07-16T07:03:04.495086Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/launchpadv2/BondingConfig.sol.
Source files written: 4 under `sources/`.
Creator: 0xc31Cf1168b2f6745650d7B088774041A10D76d55.
Creation tx: 0xc6288c7ba0cd61b69c3b2872fc86ccc689d90e0a12d8267fe15420e70fc6c16c.
Proxy type: None; implementations: [].

Current BondingConfig implementation.

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

- `ANTI_SNIPER_10M()`
- `ANTI_SNIPER_60S()`
- `ANTI_SNIPER_98M()`
- `ANTI_SNIPER_98M_BOTH()`
- `ANTI_SNIPER_98M_SELL()`
- `ANTI_SNIPER_NONE()`
- `LAUNCH_MODE_ACP_SKILL()`
- `LAUNCH_MODE_NORMAL()`
- `LAUNCH_MODE_X_LAUNCH()`
- `acfFakeInitialVirtualLiq()`
- `appliesAntiSniperOnBuy(uint8)`
- `appliesAntiSniperOnSell(uint8)`
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
