# V1LaunchFactory-Legacy

`0x02081d3DEc43F816b145672cfC65029948d396AE`

Group: pons v1.
Verified `PonsLaunchFactory`. This is the implementation the live V1 proxy `0xF4fC0CD2…` delegates to, read from the EIP-1967 slot. Its own storage is empty, as expected for an implementation.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `PonsLaunchFactory` |
| Compiler | v0.8.35+commit.47b9dedd |
| Optimizer | True, runs 200 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` |
| Creation tx | `0x742f17d29334c4fc2878eea7be5374edf52476a0478b006881ba2bf180bc2c22` |

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
Counts: 13 state-changing functions, 15 views, 13 events, 30 custom errors.
