# V1LaunchFactory

`0xA5aAb3F0c6EeadF30Ef1D3Eb997108E976351feB`

Group: pons v1.
Verified `PonsLaunchFactory`, the address named in the official contracts repo. `launchEnabled()` reads false at the 2026-09-02 head, so it no longer accepts new launches. `locker()` = `0x736D7669…`. 2142 of the 2154 launches in the archived v1 feed came from here.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `PonsLaunchFactory` |
| Compiler | v0.8.30+commit.73712a01 |
| Optimizer | True, runs 300 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` |
| Creation tx | `0x836c5e41d4a4162c922cb7f0cc6713018c40b32265fb3b63926b9fdfbe0c0e67` |

## Constructor arguments

- `initialOwner` (address) = `0xda4bCee76B29EFEc9697Fcf663601c2042043968`
- `locker_` (address) = `0x736D76699C26D0d966744cAe304C000d471f7F35`
- `initialLaunchFee` (uint256) = `500000000000000`

## Functions that matter for launching

- `addLaunchConfig(tuple config)`
- `launchToken(tuple params, uint256 launchConfigId, uint256 dexId, bytes32 salt)` payable
- `setLaunchEnabled(bool enabled)`
- `setLaunchFee(uint256 newLaunchFee)`
- `setWhitelistedLauncher(address launcher, bool enabled)`
- `updateLaunchConfig(uint256 id, tuple config)`

## Reads that matter

- `getLaunchConfig(uint256 id)`
- `getLaunchedToken(address token)`
- `launchConfigCount()`
- `launchEnabled()`
- `launchFee()`
- `locker()`
- `predictTokenAddress(tuple params, uint256 launchConfigId, uint256 dexId, bytes32 salt, address tokenDeployer)`
- `whitelistedLaunchers(address launcher)`

## Events

- `LaunchConfigAdded(uint256 id, address pairToken, uint256 graduationThreshold, int24 initialTick, uint256 supply, uint16 maxWalletBps, uint16 maxTxBps, uint32 restrictionBlocks, uint24 reservedFee, bool enabled, bool routerRequiresDeadline)`
- `LaunchConfigUpdated(uint256 id, address pairToken, uint256 graduationThreshold, int24 initialTick, uint256 supply, uint16 maxWalletBps, uint16 maxTxBps, uint32 restrictionBlocks, uint24 reservedFee, bool enabled, bool routerRequiresDeadline)`
- `LaunchEnabledUpdated(bool enabled)`
- `LaunchFeeUpdated(uint256 launchFee)`
- `TokenLaunched(address token, address deployer, address dexFactory, address pairToken, address pool, uint256 dexId, uint256 launchConfigId, uint256 positionId, uint256 restrictionsEndBlock, uint256 initialBuyAmount)`
- `WhitelistedLauncherUpdated(address launcher, bool enabled)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 11 state-changing functions, 13 views, 11 events, 22 custom errors.
