> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/token-migration.md).

# Token Migration

When a token's circulating supply reaches its dexSupplyThresh, it will be listed on a DEX, and a new pool will be created for the token. The event `LaunchedToDEX` is emitted to indicate that the token is listed on DEX.

```solidity
/// @notice emitted when adding liquidity to DEX
/// @param token The address of the token
/// @param pool The address of the pool
/// @param amount The amount of token added
/// @param eth The amount of quote Token added
event LaunchedToDEX(address token, address pool, uint256 amount, uint256 eth);
```
