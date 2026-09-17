# Sentry - Guide, Ink xStocks (Developers)

> Source: https://www.sentry.trading/desktop/guide#ink-xstocks
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Ink xStocks (Developers)[](https://www.sentry.trading/desktop/guide#ink-xstocks "Copy link to this section")

Integrator reference for Backed wrapped-xStock pairs on Ink (chain id 57073). Use this if you are building a bot, router, indexer, or another frontend that needs to quote, swap, or launch against wNVDAx / wAAPLx / … .

## How a trade is routed

The v4 launch pool is always `CAMPAIGN / wXSTOCK`. ETH never sits in that pool. `SentryStockRouterInk` is the contract that lets a user spend or receive ETH:

ETH
  → peel 75% of the live decay fee as WETH
      60% creator  (0.90% of swap at the 2.00% floor)
      20% Quotron terminal pot (0.30%)
      20% Quotron growth sink  (0.30%)
  → WETH  → USDT0     Velodrome Slipstream, tickSpacing 100
  → USDT0 → USDG      Velodrome Slipstream, tickSpacing 1
  → USDG  → wXSTOCK   Foundation Uniswap V3, fee 500 (0.05%)
  → wXSTOCK → CAMPAIGN  Sentry v4 hook pool (dynamic fee, tickSpacing 200)
Sells reverse the hop; the WETH peel comes off the ETH proceeds. Wrapper-direct buys and sells skip the Velodrome legs: the router still peels 75% of the curve in the wrapper, converts that slice to WETH for creator / pots, and swaps the rest through the hook pool. The hook itself only skims the remaining 25% in the wrapper as holder reflections (or treasury during the first 10 minutes).

The 1% Sentry app fee charged on sentry.trading / the PWA API is **not** taken by this router. Integrators calling the contract directly pay only the on-chain curve (router peel + hook skim) plus venue hop fees.

## Core addresses

| Contract | Address | Notes |
| --- | --- | --- |
| **SentryStockRouterInk** | `0x1b4D919149912c9781b086C8242729EE317631C8` | Required swap router for every stock-pair trade |
| **Uniswap v4 PoolManager** | `0x360E68faCcca8cA495c1B759Fd9EEe466db9FB32` | Canonical Ink PoolManager |
| **CAMPAIGN / wXSTOCK hook** | `0x18195c33D8150B2e7f5166FC79e29a6C2B1fB0CC` | Flags `0x30CC`; router-gated; 40% → 2.00% floor |
| **Launch Factory v4** | `0xcF44b151aee1Ef69677f24cadED4d2d61b0D45BD` | Same proxy as WETH launches; `addStockBaseToken` registered the 8 wrappers |
| **Sentry LP Vault** | `0x86585D4474C78c1C0fA1f8771682E9aD020787eC` | Owns every v4 launch position; no withdraw |
| **v4 Quoter** | `0x3972C00f7ed4885e145823eb7C655375d275A1C5` | Allowlisted on the hook so quotes include the 25% skim |
| **v4 StateView** | `0x76fd297e2d437cd7f76d50f01afe6160f86e9990` | Slot0 / liquidity reads |
| **WETH9** | `0x4200000000000000000000000000000000000006` | 18 decimals |
| **USDT0** | `0x0200C29006150606B650577BBE7B6248F58470c1` | 6 decimals |
| **USDG** | `0xe343167631d89B6Ffc58B88d6b7fB0228795491D` | Foundation book quote asset |
| **Uni V3 Factory** | `0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424` | Official Ink Uniswap V3 |
| **Uni V3 SwapRouter02** | `0x177778F19E89dD1012BdBe603F144088A95C4B53` | USDG ↔ wrapper hop |
| **Uni V3 QuoterV2** | `0x96b572D2d880cf2Fa2563651BD23ADE6f5516652` | USDG ↔ wrapper quotes |
| **Velodrome SwapRouter** | `0x63951637d667f23D5251DEdc0f9123D22d8595be` | Old CL factory `0x04625B04…`; takes `tickSpacing`, not a Uni fee |
| **Velodrome Quoter** | `0x3FA596fAC2D6f7d16E01984897Ac04200Cb9cA05` | Same factory / tickSpacing ABI |
| **Velo WETH/USDT0 pool** | `0xaC7fC3e9b9d3377a90650fe62B858fF56bD841C9` | tickSpacing 100 |
| **Velo USDT0/USDG pool** | `0x31826a86cd62c6fa12a0a8441ec4c8bcfee8a453` | tickSpacing 1 |
| **Quotron terminal pot** | `0x0Aa7abB778DC11Dcaa1dBB16B72c70dD6f2d7A07` | 20% of the WETH peel; initialized ERC1967 proxy |
| **Quotron growth sink** | `0x73F5111EE91672c114923793C03B5c868d9C5E03` | 20% of the WETH peel; initialized ERC1967 proxy |

RPC: `https://rpc-gel.inkonchain.com`. Explorer: [explorer.inkonchain.com](https://explorer.inkonchain.com/). Do not use `SentryInkRouterV4` (`0x5275de614E06DbA10546171c1e6d2a30A87844b7`) for these pairs — that router is WETH-launch only.

## Registered wrappers

Eight Foundation wrappers are registered as launch bases. Each has a USDG book on official Uniswap V3 at fee `500` (0.05%). Logos and the live on-chain set: public `GET https://sentry.trading/api/pwa/evm/stocks?chain=ink`.

| Wrapper | Name | Wrapper (pair this) | Foundation V3 USDG pool | Raw xStock (do not pair) |
| --- | --- | --- | --- | --- |
| **wNVDAx** | NVIDIA | `0xa8ddb5Cd96b5222AFe198316E9A57CAA642850D5` | `0x01951DDb43A451500bfAF652d40C07309fAD4727` | `0xc845b2894dBDdD03858fd2D643b4eF725fE0849d` |
| **wAAPLx** | Apple | `0x943BF64D566c32A2Bcd41AC92FB63C111cC9De8f` | `0x8986Bb68391ad5b0aFd7605e8075b273ca0189D6` | `0x9d275685dC284C8eb1c79F6ABa7A63dc75EC890A` |
| **wTSLAx** | Tesla | `0xc3FdBe3A68EE5dE461D30415a8165cf9Aefe1171` | `0x09444CbDfF5CD4437150a1f26865a3Ed85D8ED5E` | `0x8aD3c73F833d3F9A523AB01476625f269AeB7cF0` |
| **wSPCXx** | SpaceX | `0x8e2eeD8b8B5E13Ea7BF38e50d7821d2C57309072` | `0xDf1531451f6D97f847B27FaC671738D113db1406` | `0x68FA48b1c2FE52b3d776e1953e0E782b5044CE28` |
| **wSPYx** | S&P 500 ETF | `0xE7E553Cd128F0011777323A0b44a7b96EA1CB540` | `0x06fB000Fe9C6505Eb3b2CdF52445d8C7d5690F47` | `0x90A2A4c76B5D8C0Bc892a69EA28aa775A8f2dD48` |
| **wPLTRx** | Palantir | `0x4A2df09536F62341C9f946427D16414C04e21342` | `0xe5D0EB7705889631adCB2550db0f8447D5cb6506` | `0x6D482CeC5F9dd1F05CCEE9Fd3Ff79B246170F8e2` |
| **wNFLXx** | Netflix | `0x7d87fD6A379714194a797c0bBB8B40c30D250856` | `0x111D25ac72aD434D895F6f1ac8184AB5175e99ff` | `0xa6A65ac27E76cD53cb790473e4345C46e5Ebf961` |
| **wMSTRx** | Strategy | `0x30987adF0B11dc698438a99BA04ec3a1AB2c7EaB` | `0x169F2ab4D25aBa4F9b2743658f8549641c9D069D` | `0xAE2f842eF90c0d5213259AB82639d5bBF649B08E` |

Wrappers are 18-decimal ERC-4626 vaults. `asset()` returns the raw xStock; `convertToAssets` / `convertToShares` give the share price if you need to mark the wrapper vs the rebase token. Sentry never holds or swaps the raw token.

## Swap router ABI

Approve the router before any token-in call (`sellExact*` or`buyExactStockForToken`). ETH-in sends `msg.value`. Pass `address(0)` as `recipient` to send to `msg.sender`.

// SentryStockRouterInk — 0x1b4D919149912c9781b086C8242729EE317631C8
function buyExactEthForStockToken(address token, address stock, uint256 minOut, address recipient) payable returns (uint256);
function sellExactStockTokenForEth(address token, address stock, uint256 amountIn, uint256 minOut) returns (uint256);
function buyExactStockForToken(address token, address stock, uint256 amountIn, uint256 minOut, address recipient) returns (uint256);
function sellExactTokenForStock(address token, address stock, uint256 amountIn, uint256 minOut) returns (uint256);
function wethFeePips(address token, bool isBuy) view returns (uint24);

event StockSwap(address indexed sender, address indexed token, address indexed stock, bool isBuy, uint256 amountIn, uint256 amountOut, uint256 wethFee);// ethers v6
const ROUTER = '0x1b4D919149912c9781b086C8242729EE317631C8';
const abi = [
  'function buyExactEthForStockToken(address token, address stock, uint256 minOut, address recipient) payable returns (uint256)',
  'function sellExactStockTokenForEth(address token, address stock, uint256 amountIn, uint256 minOut) returns (uint256)',
  'function buyExactStockForToken(address token, address stock, uint256 amountIn, uint256 minOut, address recipient) returns (uint256)',
  'function sellExactTokenForStock(address token, address stock, uint256 amountIn, uint256 minOut) returns (uint256)',
  'function wethFeePips(address token, bool isBuy) view returns (uint24)',
];
const router = new ethers.Contract(ROUTER, abi, signer);

// Buy campaign token with ETH
await router.buyExactEthForStockToken(
  campaignToken,
  wrapper,          // e.g. wNVDAx
  minOut,
  ethers.ZeroAddress,
  { value: ethers.parseEther('0.01') },
);

// Sell campaign token for ETH (approve router first)
await token.approve(ROUTER, amountIn);
await router.sellExactStockTokenForEth(campaignToken, wrapper, amountIn, minOut);
## Factory + hook discovery

Resolve the pool from the factory — do not hardcode currency order. The hook address is on the pool key.

// SentryLaunchFactoryV4 — 0xcF44b151aee1Ef69677f24cadED4d2d61b0D45BD
function launches(address token) view returns (address baseToken, address creator, address hook, int24 tickLower, int24 tickUpper);
function poolKeyOf(address token) view returns (tuple(address currency0, address currency1, uint24 fee, int24 tickSpacing, address hooks));
function poolIdOf(address token) view returns (bytes32);
function isStockBase(address) view returns (bool);
function feeRecipientOf(address token) view returns (address);
function launch(string name, string symbol, address baseToken) returns (address);
function launchWithFeeRecipient(string name, string symbol, address baseToken, address feeRecipient) returns (address);
function launchWithWhitelist(string name, string symbol, address baseToken, address feeRecipient, address[] whitelist) returns (address);

// SentryInkXStockFeeHook — 0x18195c33D8150B2e7f5166FC79e29a6C2B1fB0CC
function currentFee(bytes32 poolId) view returns (uint24);   // pips, 1e6 = 100%
function endFee() view returns (uint24);                     // 20000 = 2.00%
function launchWhitelist(bytes32 poolId, address wallet) view returns (bool);
function swapRouter() view returns (address);

// Pool key every CAMPAIGN / wXSTOCK launch uses
// fee          = 8388608   // Uniswap v4 DYNAMIC_FEE_FLAG (0x800000)
// tickSpacing  = 200
// hooks        = 0x18195c33D8150B2e7f5166FC79e29a6C2B1fB0CC
// currency0/1  = sorted(token, wrapper)
`baseToken == address(0)` on `launches(token)` means the address is not a Sentry v4 launch. If `baseToken` is one of the eight wrappers, route through `SentryStockRouterInk`, not the WETH v4 router.

## Quoting

Quote the hop yourself (the router has no `quote` function). Subtract `wethFeePips(token, isBuy)` from the ETH notionals — that is 75% of the live hook curve, in pips. Whitelisted `tx.origin` buyers pay `endFee` instead of the decay, matching the hook.

// Buy quote (ETH → token)
feePips  = router.wethFeePips(token, true)          // e.g. 15000 at the floor
afterFee = ethIn * (1_000_000 - feePips) / 1_000_000
usdt0    = veloQuoter.quoteExactInputSingle({ tokenIn: WETH,  tokenOut: USDT0, amountIn: afterFee, tickSpacing: 100, sqrtPriceLimitX96: 0 })
usdg     = veloQuoter.quoteExactInputSingle({ tokenIn: USDT0, tokenOut: USDG,  amountIn: usdt0,    tickSpacing: 1,   sqrtPriceLimitX96: 0 })
wrapper  = uniV3Quoter.quoteExactInputSingle({ tokenIn: USDG, tokenOut: wXSTOCK, amountIn: usdg, fee: 500, sqrtPriceLimitX96: 0 })
tokenOut = v4Quoter.quoteExactInputSingle({
  poolKey: factory.poolKeyOf(token),                // or {currency0, currency1, fee: 8388608, tickSpacing: 200, hooks}
  zeroForOne: wrapper == currency0,
  exactAmount: wrapper,
  hookData: '0x',
})

// Sell quote is the reverse; apply wethFeePips(token, false) to the WETH out.

// Velodrome quoter — 0x3FA596fAC2D6f7d16E01984897Ac04200Cb9cA05
function quoteExactInputSingle((address tokenIn, address tokenOut, uint256 amountIn, int24 tickSpacing, uint160 sqrtPriceLimitX96))
  returns (uint256 amountOut, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate);

// Uni V3 QuoterV2 — 0x96b572D2d880cf2Fa2563651BD23ADE6f5516652
function quoteExactInputSingle((address tokenIn, address tokenOut, uint256 amountIn, uint24 fee, uint160 sqrtPriceLimitX96))
  returns (uint256 amountOut, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate);

// Uni v4 Quoter — 0x3972C00f7ed4885e145823eb7C655375d275A1C5
function quoteExactInputSingle(((address currency0, address currency1, uint24 fee, int24 tickSpacing, address hooks) poolKey, bool zeroForOne, uint128 exactAmount, bytes hookData) params)
  returns (uint256 amountOut, uint256 gasEstimate);
## Fees on the curve

Decay is 40% flat for 3 minutes, then a 3-minute half-life, to a permanent **2.00%** floor (20,000 pips). Reflections unlock 10 minutes after launch. At the floor every trade splits like this — all of it out of the 2.00%, never on top:

| Leg | Share of the 2.00% | Of the trade | Asset / destination |
| --- | --- | --- | --- |
| **Creator** | 60% of the 75% WETH peel | 0.90% | WETH to `feeRecipientOf(token)` |
| **Terminal pot** | 20% of the WETH peel | 0.30% | WETH via `donate()` |
| **Growth sink** | 20% of the WETH peel | 0.30% | WETH via `donate()` |
| **Holder reflections** | The hook's 25% | 0.50% | wXSTOCK via `notifyReward()` on the campaign token |

During the opening window the same 25% hook skim is sent to treasury so snipers are not paid as “holders.” Launch-whitelist wallets pay `endFee` on buys only; sells are never exempt.

## Holder reflections ABI

Campaign tokens are dividend tokens. Zero transfer tax — claim anytime from the token itself.

function rewardToken() view returns (address);                    // the wrapper
function withdrawableDividendOf(address) view returns (uint256);
function accumulativeDividendOf(address) view returns (uint256);
function withdrawnDividends(address) view returns (uint256);
function claim() returns (uint256);
## Launching from another app

Call `launch` / `launchWithFeeRecipient` / `launchWithWhitelist` on the v4 factory with `baseToken` set to a registered wrapper. The factory routes stock bases to the xStock hook automatically. Do not use `launchWithReflections` for these pairs — that entrypoint is the WETH reflection hook. Confirm the base first:

factory.isStockBase(wrapper) == true
GET https://sentry.trading/api/pwa/evm/stocks?chain=ink   // live registered set
## Index + verify

*   **Subgraph:**[sentry-ink/1.5.0](https://api.goldsky.com/api/public/project_cmm7vh5xwsa8m01qmdr7w7u62/subgraphs/sentry-ink/1.6.0/gn) — launches, pool keys, swaps, and `WethFeePaid` from the stock router (creator fees on these tokens are WETH, not the wrapper).
*   **Router events:**`StockSwap` and `WethFeePaid` on `0x1b4D919149912c9781b086C8242729EE317631C8`.
*   **User walkthrough** (non-integrator): [Stocks as Base Pairs](https://www.sentry.trading/desktop/guide#stock-pairs).
