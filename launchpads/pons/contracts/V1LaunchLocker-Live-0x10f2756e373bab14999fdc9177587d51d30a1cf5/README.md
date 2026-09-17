# V1LaunchLocker-Live

`0x10f2756e373bab14999fdc9177587d51d30a1cf5`

Group: pons v1.
ERC1967 proxy. The locker the live V1 factory uses. `protocolFeeShare()` = 30, matching the docs' current 70/30 creator/protocol split. `factory()` = `0xF4fC0CD2…`.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `ERC1967Proxy` |
| Compiler | v0.8.35+commit.47b9dedd |
| Optimizer | True, runs 200 |
| EVM version | osaka |
| License | none |
| Proxy type | eip1967 |
| Implementation | `0xd4af1dfB098402182875e7f966c01eaAc512Bd22` |
| Creator | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` |
| Creation tx | `0x47faab19254e8f014e053b992255a3dbb7373977b8f20b921a572c3675c4358d` |

## Constructor arguments

- `implementation` (address) = `0xd4af1dfB098402182875e7f966c01eaAc512Bd22`
- `_data` (bytes) = `0x1794bb3c000000000000000000000000da4bcee76b29efec9697fcf663601c2042043968000000000000000000000000da4bcee76b29efec9697fcf663601c2042043968000000000000000000000000000000000000000000000000000000000000000a`

## Functions that matter for launching


## Events

- `Upgraded(address implementation)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 0 state-changing functions, 0 views, 1 events, 5 custom errors.
