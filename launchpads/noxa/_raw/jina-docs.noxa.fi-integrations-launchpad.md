Title: Building on NOXA Fun

URL Source: https://docs.noxa.fi/integrations/launchpad/

Markdown Content:
This page is for developers building apps, bots, and analytics on top of NOXA Fun launches.

Everything you need is **on-chain**. You can read launches, pools, and restrictions directly from the contracts and event logs using any standard RPC.

## Tokens Are Standard and Instantly Tradable

[Section titled “Tokens Are Standard and Instantly Tradable”](https://docs.noxa.fi/integrations/launchpad/#tokens-are-standard-and-instantly-tradable)

At launch we deploy a standard ERC-20 and add single-sided liquidity to a Uniswap V3-style pool, so the token is live in a real V3 pool from the launch transaction itself.

*   A token launched targeting **Uniswap V3** is tradable on Uniswap V3. Use Uniswap’s normal SwapRouter / QuoterV2.
*   A token launched targeting **NOXA DEX** or any other supported V3 fork trades through that DEX’s standard contracts.
*   There is no migration step and no custom AMM. If you already integrate Uniswap V3, you already integrate NOXA Fun tokens.

Public swaps execute from the block **after** the launch block. The launch block itself is reserved to prevent same-block sniping (see [Trading Restrictions](https://docs.noxa.fi/integrations/launchpad/#trading-restrictions)).

## Discovering Launches

[Section titled “Discovering Launches”](https://docs.noxa.fi/integrations/launchpad/#discovering-launches)

The `LauncherFactory` emits `TokenLaunched` for every launch. Filter this event from the factory address for your chain (see [NOXA Fun Contracts](https://docs.noxa.fi/contracts/noxa-fun/)) to discover launches in real time, or backfill historically by querying logs from the factory’s deployment block.

`event TokenLaunched(    address indexed token,    address indexed deployer,    address indexed dexFactory,    address pairToken,    address pool,    uint256 dexId,    uint256 launchConfigId,    uint256 positionId,    uint256 restrictionsEndBlock,    uint256 initialBuyAmount);`

`token` is the new ERC-20, `pool` is the V3 pool to trade against, `pairToken` is the quote token (the chain’s wrapped native, or USDC on Arc), and `dexFactory` identifies which DEX the token launched on.

## Verifying a Launch Is Genuine

[Section titled “Verifying a Launch Is Genuine”](https://docs.noxa.fi/integrations/launchpad/#verifying-a-launch-is-genuine)

Anyone can deploy a lookalike token. To confirm a token actually came from NOXA Fun, query the factory:

`function getLaunchedToken(address token) external view returns (LaunchedToken memory);struct LaunchedToken {    address token;    address deployer;    address pairedToken;    address positionManager;    uint256 positionId;    uint256 dexId;    uint256 launchConfigId;    uint256 restrictionsEndBlock;    uint256 supply;    bool    isToken0;    uint24  poolFee;    bool    exists;    uint256 initialBuyAmount;}`

Check `exists == true`. The struct also gives you everything you need to locate the pool and position without any extra calls.

Alternatively, read `launchFactory()` on the token and confirm it equals the known factory address for that chain.

The token exposes its own pool and pairing directly:

`function liquidityPool() external view returns (address); // the V3 poolfunction pairToken()     external view returns (address); // quote token (e.g. WETH, USDC)function poolFee()       external view returns (uint24);  // fee tier, currently 10000 (1%)`

`liquidityPool()` resolves the pool from the DEX factory for the `(token, pairToken, poolFee)` triple, so it returns the canonical V3 pool address you swap against.

## Trading Restrictions

[Section titled “Trading Restrictions”](https://docs.noxa.fi/integrations/launchpad/#trading-restrictions)

Launched tokens enforce anti-snipe restrictions for a short window after launch. Your integration **must** respect these or transfers will revert. Restrictions are active while:

`launchBlock < block.number <= restrictionEndBlock`

Read the limits and window from the token:

`function maxWalletLimit()     external view returns (uint256); // max balance per wallet (currently 2% of supply)function maxTxLimit()         external view returns (uint256); // per-tx cap (configured per chain)function restrictionEndBlock() external view returns (uint256); // restrictions lift after this block`

Rules while restrictions are active:

*   **Launch block:** buys directly from the pool revert with `LaunchBlockBuyBlocked(address recipient)`. Public trading starts the next block.
*   **Max wallet:** a recipient’s resulting balance cannot exceed `maxWalletLimit()`, or the transfer reverts with `MaxWalletExceeded(address account, uint256 balance, uint256 limit)`.
*   **Max tx:** cumulative buys from the pool per `tx.origin` are capped at 110% of `maxTxLimit()`, or the transfer reverts with `MaxTxExceeded(address originator, uint256 attempted, uint256 limit)`.

After `restrictionEndBlock`, the token behaves as a fully standard ERC-20 with no limits.

Launch restrictions usually operate for ~1 hour after launch.

## Minimal Interfaces

[Section titled “Minimal Interfaces”](https://docs.noxa.fi/integrations/launchpad/#minimal-interfaces)

Drop-in interfaces covering the read paths above:

`interface ILauncherFactory {    function getLaunchedToken(address token) external view returns (LaunchedToken memory);}interface ILauncherToken {    function launchFactory() external view returns (address);    function liquidityPool() external view returns (address);    function pairToken() external view returns (address);    function poolFee() external view returns (uint24);    function maxWalletLimit() external view returns (uint256);    function maxTxLimit() external view returns (uint256);    function restrictionEndBlock() external view returns (uint256);}`

Contract addresses per chain are on the [NOXA Fun Contracts](https://docs.noxa.fi/contracts/noxa-fun/) page, and chain IDs are on [Supported Chains](https://docs.noxa.fi/launchpad/chains/).

Links/Buttons:
- [Skip to content](https://docs.noxa.fi/integrations/launchpad/#_top)
- [NOXA](https://docs.noxa.fi/)
- [Twitter](https://x.com/Noxa_Fi)
- [Telegram](https://t.me/Noxa_Fi)
- [Introduction](https://docs.noxa.fi/introduction/)
- [Overview](https://docs.noxa.fi/dex/overview/)
- [How to Launch](https://docs.noxa.fi/launchpad/how-to-launch/)
- [Supported Chains](https://docs.noxa.fi/launchpad/chains/)
- [Trading](https://docs.noxa.fi/dex/trading/)
- [Liquidity](https://docs.noxa.fi/dex/liquidity/)
- [NOXA Fun](https://docs.noxa.fi/contracts/noxa-fun/)
- [NOXA DEX](https://docs.noxa.fi/contracts/noxa-dex/)
- [Building on NOXA Fun](https://docs.noxa.fi/integrations/launchpad/)
- [DEX Integration](https://docs.noxa.fi/integrations/dex/)
- [Tokens Are Standard and Instantly Tradable](https://docs.noxa.fi/integrations/launchpad/#tokens-are-standard-and-instantly-tradable)
- [Discovering Launches](https://docs.noxa.fi/integrations/launchpad/#discovering-launches)
- [Verifying a Launch Is Genuine](https://docs.noxa.fi/integrations/launchpad/#verifying-a-launch-is-genuine)
- [Finding the Pool](https://docs.noxa.fi/integrations/launchpad/#finding-the-pool)
- [Trading Restrictions](https://docs.noxa.fi/integrations/launchpad/#trading-restrictions)
- [Minimal Interfaces](https://docs.noxa.fi/integrations/launchpad/#minimal-interfaces)
