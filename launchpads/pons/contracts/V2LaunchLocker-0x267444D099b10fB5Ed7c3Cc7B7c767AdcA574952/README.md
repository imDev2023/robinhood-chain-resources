# V2LaunchLocker

`0x267444D099b10fB5Ed7c3Cc7B7c767AdcA574952`

Group: pons v2.
Permanently holds every graduated v4 position NFT. No withdrawal path.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `V2LaunchLocker` |
| Compiler | v0.8.35+commit.47b9dedd |
| Optimizer | True, runs 200 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36` |
| Creation tx | `0x7b2f3e9dee1d150521161ee9fd071659aec18af8f07e5f63c6c53b28c315f47b` |

## Constructor arguments

- `initialOwner` (address) = `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36`
- `positionManager_` (address) = `0x58daec3116aae6D93017bAAea7749052E8a04fA7`

## Functions that matter for launching

- `lockPosition(address token, uint256 tokenId)`
- `lockTokenSupply(address token, uint256 amount)`

## Reads that matter

- `isLocked(address token)`
- `lockedPositions(address token)`
- `lockedTokenSupply(address token)`

## Events

- `PositionLocked(address token, uint256 tokenId)`
- `TokenSupplyLocked(address token, uint256 amount)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 5 state-changing functions, 9 views, 5 events, 10 custom errors.
