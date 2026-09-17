# V2LauncherToken-Example-COPPERINU

`0x5317C0d077D2eEB639448939b930D49c4984B63B`

Group: pons v2.
One fixed-supply ERC-20 per launch, minted entirely to its curve.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `PonsV2LauncherToken` |
| Compiler | v0.8.35+commit.47b9dedd |
| Optimizer | True, runs 200 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0x3711ceA4feaDE896C913C68F01Eda97Cb06D1A42` |
| Creation tx | `0x376cad198a1dc19804f43a925bbf3ef512ef6438009a9255fed7f93a3efe4b68` |

## Constructor arguments

- `name_` (string) = `Copper Inu`
- `symbol_` (string) = `COPPERINU`
- `logo_` (string) = `ipfs://QmfRELDhxv3hiLhMQCV8k1C1YP64hGnwh4ejJecWmvJP1Q`
- `description_` (string) = `Stack your Copper by staking Inu.`
- `socials_` (struct PonsV2LauncherToken.Socials) = `['https://x.com/himgajria', '', '', 'https://www.ponsvault.com/himgajria', '']`
- `deployer_` (address) = `0x98469ccF8B1807870F61557aeA293ADF959BC212`
- `curve_` (address) = `0x6A7a7f7Cd83719f47f6Fd15b580d24A9a8E6Df2f`
- `launchFactory_` (address) = `0x7eD598BcEf8bd9Edd8C97A195C6d13f40801EC7e`
- `supply_` (uint256) = `1000000000000000000000000000`

## Functions that matter for launching

- `burn(uint256 value)`
- `burnFrom(address account, uint256 value)`

## Reads that matter

- `launchFactory()`

## Events

- `Approval(address owner, address spender, uint256 value)`
- `Transfer(address from, address to, uint256 value)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 5 state-changing functions, 13 views, 2 events, 7 custom errors.
