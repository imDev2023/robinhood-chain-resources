# UniswapV4PositionManager

`0x58daec3116aae6D93017bAAea7749052E8a04fA7`

Group: Uniswap.
v4 position manager. Mints the locked full-range position.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `PositionManager` |
| Compiler | v0.8.26+commit.8a97fa7a |
| Optimizer | True, runs 30000 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0x4e59b44847b379578588920cA78FbF26c0B4956C` |
| Creation tx | `0x228c18ada6cb46b4fbcc18f4ec1519953415393e256fa8349aafbd5a2db037c8` |

## Functions that matter for launching

- `modifyLiquiditiesWithoutUnlock(bytes actions, bytes[] params)` payable
- `unlockCallback(bytes data)`

## Events

- `Approval(address owner, address spender, uint256 id)`
- `ApprovalForAll(address owner, address operator, bool approved)`
- `Subscription(uint256 tokenId, address subscriber)`
- `Transfer(address from, address to, uint256 id)`
- `Unsubscription(uint256 tokenId, address subscriber)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 17 state-changing functions, 22 views, 5 events, 28 custom errors.
