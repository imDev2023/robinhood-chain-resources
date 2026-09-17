# V1LaunchFactory-Proxy

`0xF4fC0CD27fC8EcF17E55eE4c3f7201897dF3eb75`

Group: pons v1.
ERC1967 proxy, implementation `0x02081d3d…`. This is the live V1 factory: `launchEnabled()` true, `launchFee()` 0.0005 ETH, `locker()` = `0x10f2756e…`. Every September 2026 v1 launch in the live `/api/pons/launches` feed reports this address.

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
| Implementation | `0x02081d3Dec43f816b145672cFc65029948D396AE` |
| Creator | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` |
| Creation tx | `0x2bef55ac95ab157dd10030b400e0826913b3474b8554a8d2b337372f179dadad` |

## Constructor arguments

- `implementation` (address) = `0x02081d3Dec43f816b145672cFc65029948D396AE`
- `_data` (bytes) = `0x1794bb3c000000000000000000000000da4bcee76b29efec9697fcf663601c204204396800000000000000000000000010f2756e373bab14999fdc9177587d51d30a1cf50000000000000000000000000000000000000000000000000001c6bf52634000`

## Functions that matter for launching


## Events

- `Upgraded(address implementation)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 0 state-changing functions, 0 views, 1 events, 5 custom errors.
