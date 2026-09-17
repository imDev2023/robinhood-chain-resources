# V1LauncherToken-Example-PONS

`0x39dBED3a2bd333467115dE45665cC57F813C4571`

Group: pons v1.
The PONS token itself, a V1 launch.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `PonsLauncherToken` |
| Compiler | v0.8.30+commit.73712a01 |
| Optimizer | True, runs 300 |
| EVM version | cancun |
| License | mit |
| Proxy type | none |
| Creator | `0x0c37a24F5D23A486FA692d1500881d698B1F77a4` |
| Creation tx | `0x1f54f25fec2d963dcb338ecb8b46a6eb123198a5c7a746d34cb2dbe78d074af8` |

## Constructor arguments

- `name_` (string) = `Pons`
- `symbol_` (string) = `PONS`
- `logo_` (string) = `ipfs://bafybeiehcgbqotmir6tqi76eorpihucphlry53cx3mmnxgmqjjxpwherwq`
- `description_` (string) = `100% of fees go back to Pons`
- `socials_` (struct PonsLauncherToken.Socials) = `['', '', '', 'http://pons.family/launchpad', '']`
- `deployer_` (address) = `0xB9F5f4Ea1AF1F5d3678470eb98e8FBdcadEb24b0`
- `dexFactory_` (address) = `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`
- `positionManager_` (address) = `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3`
- `pairToken_` (address) = `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `poolFee_` (uint24) = `10000`
- `supply_` (uint256) = `1000000000000000000000000000`
- `maxWalletBps_` (uint16) = `200`
- `maxTxBps_` (uint16) = `220`
- `restrictionBlocks_` (uint32) = `366`

## Functions that matter for launching

- `setInitialBuyRecipient(address recipient)`

## Reads that matter

- `launchBlock()`
- `launchFactory()`
- `poolFee()`
- `restrictionBlocks()`
- `restrictionEndBlock()`

## Events

- `Approval(address owner, address spender, uint256 value)`
- `Transfer(address from, address to, uint256 value)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 4 state-changing functions, 26 views, 2 events, 11 custom errors.
