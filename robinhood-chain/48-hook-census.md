# Hook census: how much of the chain trades through a hook, and where the data lives

> Original writing, 2026-09-19. Two outside sources, read and summarised, plus figures computed the same day from Uniswap's public `hooklist.json`.
> Complements `44-uniswap-v4-hooks.md` (what reaches hook code) and `45-v4-pools-and-liquidity.md`, which records that DEX Screener returns no hook address for a v4 pool.
> The census figures are not ours; the one thing measured by us on-chain is the worked example under "Measuring a hook's take with two read-only calls", added 2026-09-20. The provenance of each figure is stated.

## Uniswap publishes a hook registry, and this chain tops it

`https://github.com/Uniswap/hooklist` is a public registry of verified v4 hooks, one JSON file per hook under `hooks/<chain>/`, plus a combined `hooklist.json` (6.2 MB on 2026-09-19).
Each entry carries the address, all 14 permission flags, `dynamicFee`, `upgradeable`, `requiresCustomSwapData`, `vanillaSwap`, a `swapAccess` class, `verifiedSource`, an `auditUrl`, and a name and description generated from the verified source.
New hooks are added by opening an issue; an automated job fetches the source from Etherscan and opens the pull request.

Entries per chain on 2026-09-19, of 4,955 in total:

| Chain | Hooks |
| --- | ---: |
| **Robinhood Chain** | **1,161** |
| Base | 1,154 |
| Ethereum | 1,125 |
| Unichain | 697 |
| BNB | 267 |
| Arbitrum | 203 |

Robinhood Chain has more registered hooks than any other chain.

Computed from the 1,161 Robinhood Chain entries:

| Property | Hooks | Share |
| --- | ---: | ---: |
| `afterSwap` | 919 | 79% |
| `beforeSwap` | 906 | 78% |
| `afterSwapReturnsDelta` | 841 | 72% |
| `beforeSwapReturnsDelta`, which lets a hook replace the swap | 768 | 66% |
| `beforeInitialize` | 560 | 48% |
| dynamic fee | 206 | 18% |
| swap access gated by governance | 101 | 9% |
| swap access gated by time rules | 84 | 7% |
| upgradeable | 35 | 3% |
| swap access gated by an allowlist | 21 | 2% |
| lists an audit | 4 | 0.3% |

Most common hook names: `SaturnOmnichainV4Hook` 80, `LaunchpadHook` 27, `LaunchHook` 25, `NasdankFeeHook` 20, `Spot` 17, `PmavHookQuoted` 17, `UnihoodStockHook` 16, `TipOffFeeHook` 16.

Two cautions.
Only hooks with verified source are registered, so unverified hooks are absent; Bitquery, below, counts more than 1,500 deployed.
The repository showed no licence on 2026-09-19, so its files should be read, not redistributed; the flags are derivable from any hook address and the rest can be rebuilt from verified source.

## Bitquery's census, 4 to 8 September 2026

Source: `https://bitquery.io/investigations/uniswap-v4-hooks-robinhood-chain`, figures its authors verified on 2026-09-08 from the chain's logs, internal calls and token transfers.

- **74.5% of Uniswap v4 trades on the chain run through a hook**, while hooks are attached to about a third of pools.
- One hook carries almost three quarters of all hooked swaps; the top five carry more than nine in ten.
- About 300 distinct hooks see use on a given day; roughly one hook in six with a pool attached has never processed a swap.
- About 15,000 pools are created per day; the share created with a hook fell from about two in five to one in four across the window.
- **The largest hook's pools record a 0% fee while the hook takes a median of 1% of the output**, using `afterSwapReturnsDelta`. The pool's own record, and therefore every DEX trade feed, shows zero. Pools without a hook charge a median of about 2% and show it.
- `beforeSwap` calls fail 1.174% of the time, which is a hook refusing a trade. `afterSwap` fails 0.095%.
- `afterSwap` costs a median of 40,075 gas and 701,574 at the 95th percentile; `beforeSwap` 16,128 and 103,022.
- Money into hooks falls into three patterns: a vault that holds buyers' funds for a bonding curve (`0x24cd6d9e`, $10.1M received, 99.9% kept, a liability not revenue), a toll booth (`0xe5e70264`, $6.1M received across 1,181,743 transfers, 5.3% kept), and a pass-through (`0x127b3f3b`, keeps nothing).
- On that reading the largest fee-taking hook earned about $1M in four days.

Hook designs by permission set, from the same census:

| Design | Permissions | Hooks | Pools | Swaps |
| --- | --- | ---: | ---: | ---: |
| Toll booth | `beforeInitialize`, `afterSwap`, `afterSwap` delta | 46 | 2,454 | 9,374,371 |
| Launchpad | the same, plus every liquidity add and removal | 2 | 8,662 | 1,695,390 |
| Gatekeeper | `beforeInitialize` only | 159 | 84 | 299,188 |
| Inspector | `beforeSwap` only | 54 | 86 | 246,672 |
| Full control | liquidity gates plus both sides of a swap | 40 | 1,407 | 171,500 |
| Market maker | can fill a swap from its own books first | 81 | 2,488 | 130,550 |

Limits its authors state: a four-day window, because their archive for this chain is rolling; revenue counted in USDG and ETH only, so hooks earning in their own launched tokens are undercounted; and the 1% take is measured on one hook over one day.

## Two traps from the same source

**Nine contracts on this chain trade under the ticker of the main stablecoin**, one real and eight imitations with different decimals.
Summing volume by ticker instead of by contract address returns a figure in the quadrillions.
Always key on the token address; USDG's is in `16-token-contracts.md` and `ROBINHOOD-CHAIN.md`.

**Hook creators are hidden by the CREATE2 factory.**
Most hooks are deployed through the shared factory at `0x4e59b44847b379578588920cA78FbF26c0B4956C`, so the creation record names that address as the creator of hundreds of unrelated hooks.
Finding who built a hook takes a funding trace, not the creation record.

## Measuring a hook's take with two read-only calls

Measured by us, 2026-09-20, at chain head through Alchemy `robinhood-mainnet`; not pinned to a block, so treat the figures as a demonstration of the method and re-read them before relying on them.

A hook's take can be read without logs, traces or an indexer, which matters here because `trace_block` is unavailable at any tier and most hooked pools quote in native ETH, whose movements leave no transfer log.

1. Get the pool's key. `PositionManager.poolKeys(bytes25)` at `0x58daec3116aae6d93017baaea7749052e8a04fa7` returns `(currency0, currency1, fee, tickSpacing, hooks)` for the first 25 bytes of a pool id, for pools whose positions were minted through it.
2. Read the pool price and LP fee from `StateView.getSlot0(bytes32)` at `0xf3334192d15450cdd385c8b70e03f9a6bd9e673b`.
3. Quote a small exact-input swap in each direction with `Quoter.quoteExactInputSingle(((address,address,uint24,int24,address),bool,uint128,bytes))` at `0x8dc178efb8111bb0973dd9d722ebeff267c98f94`, with empty `hookData`. The Quoter simulates the swap with the hook attached, so its output already reflects whatever the hook takes.
4. Quoted cost is `1 - quoted output / (amount in x pool price)`; the hook's take is that minus the LP fee. Keep the size small against the pool's depth so price impact does not pollute the number.

Worked example, HIMS/BONER, the sixth deepest pool on the chain in `45-v4-pools-and-liquidity.md`:

| | |
| --- | --- |
| Pool id | `0x9c89b04303dfa76f3f6fb02c2b77be0e8a00ab8fa00d507119acd54ab3e8640d` |
| `currency0` / `currency1` | BONER `0x98096d17e191B3dA1d5f99a6D7b3584351b11E18` / HIMS `0xCceE82fE024c36fA15E1005edE3E9e4787e23D09` |
| `fee` / `tickSpacing` | `8388608`, the dynamic-fee flag / `8` |
| Hook | `0x4e3468951D49f2EEa976eD0D6e75fFCb44a9a544`, registered in Uniswap's hooklist as `Doppler`, flags `beforeInitialize`, `afterAddLiquidity`, `afterRemoveLiquidity`, `afterSwap`, `afterSwapReturnsDelta` |
| `getSlot0` | `sqrtPriceX96` 3190814128983647224291727889, tick -64245, protocol fee 0, **LP fee 1000 (0.10%)** |
| Quote 0.01 BONER to HIMS | 15976669393257 out, against 16219700000000 at the pool price: **quoted cost 1.4986%** |
| Quote 0.01 HIMS to BONER | 6072932325809246330 out: **quoted cost 1.4986%** |
| Implied hook take | **about 1.40% in each direction**, on a pool that displays 0.10% |

Each quote reported a gas estimate of about 750,000, so quoting is far heavier than a state read and must be paged accordingly in any batch job.

Limits of the method.
A quote that reverts does not by itself mean the hook refuses trades: the Quoter is not the Universal Router, and a hook that admits only certain callers or requires custom `hookData` will revert for the Quoter while serving real swaps.
`poolKeys` is empty for pools whose liquidity was never minted through the PositionManager, so those keys must come from the `Initialize` event instead.

## What is still nobody's product

As of 2026-09-19 no trader-facing tool was found that shows a pool's hook, its permissions and its measured fee take on this chain.
DEX Screener, GeckoTerminal, DEXTools and Birdeye carry no hook field; HookRank (`hookrank.io`) rendered every metric as "---" and never mentions this chain; the Uniswap app shows a hook address but not what the hook takes.
