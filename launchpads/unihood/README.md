# Unihood

Archived 2026-09-19.
Site `unihood.fun`, X `@unihoodotfun`, DefiLlama slug `unihood`, category Launchpad, chain Robinhood Chain only.

**This is the most tightly constructed launchpad in the survey.**
Across the factory, the hook and the token there is not one `onlyOwner`, not one `Ownable` import and not one proxy.
Every economic number is a `constant` or an `immutable` fixed at deploy.
Nothing in the contract set can be changed by anyone after deployment, including the deployer.

## 1. What is archived

| Contract | Address | Verified | Lines |
| --- | --- | --- | --- |
| `UnihoodFactory` | `0x0485a4392b7300841e644bB1B36562AE7B2A0c82` | yes | 198 |
| `UnihoodHook` | `0xec392C2b716C4B46df67cA6196ff92f7Dc2De8Cc` | yes | 525 |
| `UnihoodToken` | in the factory's sources | yes | 70 |
| `PoolManager` (Uniswap v4, shared) | `0x8366a39CC670B4001A1121B8F6A443A643e40951` | yes | - |
| `StateView` (Uniswap v4, shared) | `0xf3334192d15450cdd385c8b70e03f9a6bd9e673b` | yes | - |

First-party code is 793 lines, all MIT.
Addresses, the deploy block and the `Launched` event signature came from the DefiLlama TVL adapter rather than from Blockscout crawling; see `PLAYBOOK.md` section 4.

## 2. Model

One transaction.
`UnihoodFactory.launch(name, symbol, metaURI)` deploys a fixed-supply token, registers it with the global hook, initializes a native-ETH Uniswap v4 pool at a fixed start tick, places the **entire 1B supply** as a single-sided range from the start tick down to the minimum usable tick, and optionally executes the creator's fee-free first buy from `msg.value`.

There is no bonding curve, no graduation event and no migration.
Supply is the liquidity, so the creator seeds nothing.

The factory's own natspec states the lock outright:

> The factory keeps the launch position forever: it has no function that can remove liquidity, so the position is locked by construction. Nothing ever migrates.

That is a stronger claim than a hook that reverts `removeLiquidity`, because there is no privileged caller to reason about: the function does not exist.

Constants: `TOKEN_SUPPLY` 1e9, `TICK_SPACING` 200, `LP_FEE_PIPS` 0.
The pool's own LP fee is zero; the hook charges everything.

## 3. Fees

The hook charges on the **native ETH side only**, both directions, and splits a 1% base fee three ways:

| Bucket | bps of gross native | Share of the 1% |
| --- | --- | --- |
| Creator | 80 | 80% |
| Platform | 15 | 15% |
| Bid wall | 5 | 5% |

**A creator receives 0.80% of all ETH volume, for the life of the token.**
That is second only to HOOD10's creator-set lane in the whole 22-platform survey, and unlike HOOD10 it has no fee router in the path that an owner can repoint.

Fees accrue as ERC-6909 claims inside the PoolManager and are redeemed through `unlock` on claim, so nothing is swapped or transferred on the swap path.

## 4. Anti-snipe

A three-step decay driven only by the wall clock:

| Window from launch | Total fee |
| --- | --- |
| < 5 s | 15.00% |
| < 15 s | 5.00% |
| thereafter | 1.00% |

Everything above the 1% base accrues to the **bid wall**, not to the platform and not to the creator.
The hook's own comment for this is "snipers build the floor".

The bid wall is a self-executing buy order one tick spacing wide (~2% band) placed just below spot, funded by that surcharge.
External LP is blocked until graduation, so nobody can front-run the wall with their own range.

Because the schedule reads the clock and nothing else, it cannot be gamed with dust swaps, which is the same property that makes Sentry's decay credible (`sentry` s3.3).

## 5. Custody and trust

- **No owner.** No `Ownable`, no `onlyOwner`, no `owner()` in factory, hook or token.
- **Two `platformRecipient` gates, neither reaching a creator.** `setFactory` is one-shot and reverts `FactoryAlreadySet` afterwards; live `factory()` already returns `0x0485a439...`, so it is spent. `claimPlatformFees` moves only the platform's own accrued 15%. Recorded because "no privileged functions" would overstate it: the accurate claim is that no key can alter a creator's terms, redirect their income, or touch the launch position.
- **No proxy.** Blockscout reports `proxy_type: null` for both factory and hook.
- **No fee knobs.** The hook's natspec: "every number below is immutable at deploy".
- **No withdrawal path.** The factory holds the launch position and has no function that removes liquidity.
- Creator `0x64900b69E56583C12900F3458525a3fdB6f274D7`, creation tx `0x570bc9a8518aae9981c079417a67d231244a22b5b1a3afa4016353a69de92525`.

Attribution recorded in the source: the fee-charging flow is "modeled after EthCreatorFeeHookV3 (programmable.family, MIT), adapted for the three-way split, the decay schedule and the self-executing bid wall".

## 6. Quote assets

**Native ETH only.**
Unlike HOOD10, Doppler or Pons there is no quote registry, so a token cannot be paired against USDG or a tokenized stock.
That is the platform's main functional limitation.

## 7. Gaps

Not settled in this pass, and each is a real question rather than an assumption:

1. **Graduation rate.** 61 launches at L2 block 70,733,903; how many graduated was not counted. What graduation unlocks is settled in section 8.
2. **No docs capture.** `unihood.fun` was not crawled, no `pages/`, no screenshots, no socials.
3. **No decoded production launch.** A launch was reproduced on a mainnet fork (section 8), but no real launch transaction was decoded.
4. **Bid wall behaviour unverified on chain.** The mechanism is read from source, not observed; the fork trades in section 8 stayed far below the 0.005 ETH threshold.
5. **No audit.** Consistent with all 21 other platforms on this chain.

## 8. Integrating: verified live and on a mainnet fork

> Read live from mainnet at L2 block 70,733,903 on 2026-09-23, then reproduced on an `anvil --fork-url` fork of mainnet at L2 blocks 70,737,559 and 70,739,598 the same day.
> Method: the meme-factory Unihood adapter (`packages/launch/src/adapters/robinhood-unihood/`), which launches from an impersonated address, buys and sells through the Universal Router, and claims the creator fee.
> Nothing was broadcast to mainnet.

### There is no creator parameter

`launch(string name, string symbol, string metaURI) payable` (selector `0x42a81515`) takes no creator argument.
The factory passes `msg.sender` as creator to the token, the hook's `registerPool` and the `Launched` event, and the hook sets `feeRecipient = creator`.
So the wallet that signs the launch is the creator and the fee recipient.
Launching from a hot wallet on someone else's behalf means a second transaction, `setFeeRecipient(poolId, to)`, callable only by the current recipient.

### Live parameters

| Read | Value |
| --- | --- |
| `startTick` | 197,600 (381.3M tokens per ETH, FDV 2.623 ETH) |
| `gradTick` | 172,800 (FDV about 31.3 ETH) |
| `wallThreshold` | 5,000,000,000,000,000 wei (0.005 ETH) |
| `feeDisclosure()` | 100, 80, 5, 15 bps (base, creator, wall, platform) |
| `SNIPE_*` | 1,500 bps under 5 s, 500 bps under 15 s |
| `platformRecipient` | `0x64900b69E56583C12900F3458525a3fdB6f274D7`, the deployer |
| `tokenCount()` | 61 |

`factory.hook()`, `factory.poolManager()` and `hook.factory()` all point at the addresses in section 1.

**Graduation (gap 1, settled from source).** `_afterSwap` latches `graduated` once the tick is at or below `gradTick`, and it never reverts.
Its only effect is in `_beforeAddLiquidity`: after graduation anyone may add liquidity, before it only the factory and the hook can.
Nothing migrates and no fee changes.

### `metaURI` is raw JSON, not a URL

Of the 61 launches, 60 store an inline JSON object as `metaURI` and one stores an empty string.
None is a URL or a `data:` URI, although the token's natspec suggests either.
Keys seen: `category` (60, always `"Meme"`), `description` (60), `image` (54), `x` (23), `website` (7), `telegram` (1).
Every `image` is an inline `data:image/webp;base64,...` thumbnail, and the longest `metaURI` is 3,571 bytes against the factory's 4,096 byte limit.
Whether unihood.fun renders an `https://` image in that field is not verified.

### Launch on the fork

| Measure | Value |
| --- | --- |
| Launch gas, 171 byte `metaURI`, 0.01 ETH first buy | 1,096,614 L2 gas on the fork |
| Launch gas, 91 byte `metaURI`, 0.01 ETH first buy | 1,027,880 L2 gas on the fork |
| Mainnet `eth_estimateGas` for the 171 byte case | 1,106,485 gas, at 0.0515 gwei = 0.000057 ETH |
| Fee-free first buy of 0.01 ETH | 3,798,194.78 tokens, 0.380% of supply |
| Tokens left in the PoolManager after that buy | 996,201,805.22 (99.62%) |
| Rounding dust kept by the factory | 16,511 wei of token |
| `currentFeeBps` right after launch, then 16 s later | 1,500, then 100 |

Launch gas grows with the `metaURI` length, because the token stores it: about 860 gas per byte between the two runs above.
The fork does not model Nitro's L1 data fee; the mainnet estimate includes it, about 10k gas here.
The token's address is the factory's next `CREATE` address, so it is predictable until someone else launches first.

Event topics: `Launched` `0x5cd196e1690a04a9ca256d39f6627563d3d3b650d3bde1bd4bb5b82bee064707`, `SwapFees` `0xe87c82083cef51c0583d7ecadc9f97c27cb43c40a2ffd2e23fd0f981ab0c16bc`.

### Trading and fees on the fork

After stepping past the anti-snipe window, a 0.001 ETH buy and a sale of half the tokens both went through the mainnet Universal Router (`0x8876789976dEcBfCbBbe364623C63652db8C0904`) with the six-field `ExactInputSingleParams`, and delivered the V4 Quoter's amount to the wei.
A per-hop floor 1% above the quote reverted `V4TooLittleReceivedPerHopSingle`, which confirms on mainnet what `robinhood-chain/44-uniswap-v4-hooks.md` found on testnet.
The sell used an on-chain `Permit2.approve` rather than a signed permit.

| Step | Gas | `SwapFees` split |
| --- | --- | --- |
| Buy 0.001 ETH | 164,292 | creator 8.0e12, wall 5.0e11, platform 1.5e12 wei: exactly 80/5/15 bps of gross |
| Sell for 0.000495 ETH gross | 159,137 | creator 3,960,744,382,189, wall 247,546,523,886, platform 742,639,571,660 wei |
| `claimCreatorFees(poolId)` | 64,526 | paid 11,960,744,382,189 wei, the sum of both creator fees |

Gap 4, the bid wall, is still unobserved: two small trades put 0.00000075 ETH in the wall budget, far below the 0.005 ETH threshold.

## 8. On-chain observations, 2026-09-23

Read at block ~70,756,000 with `eth_call` on `rpc.mainnet.chain.robinhood.com` and Etherscan v2 `getLogs` (chain 4663, free key).

- **61 launches in total**: `UnihoodFactory.tokenCount()` returned `0x3d`.
- **Pool ids are computable off chain**: `keccak256(abi.encode(address(0), token, uint24(0), int24(200), hook))` equals `poolIdFor(token)`; checked for UNIHOOD `0x99b1887E985a985ECb23AC248421EAc96CB92492`, pool id `0xa4a6ec2084c3d5f029383209cfb859853ef8413eff67767571fd4e95bdf9933e`.
- **Reading a creator's lifetime fees** takes two reads: `hook.pools(poolId).creatorAccrued` (field 6, unclaimed, wei) plus the sum of `CreatorFeesClaimed(bytes32 indexed poolId, address indexed recipient, uint256 amount)` logs for that pool id (topic0 `0x8e516b1bd244658d81db3afcb0a968075b1d535a0e97d62254d5fb333e0e3ec7`).
- UNIHOOD itself: 0.0613 ETH unclaimed, 11.333 ETH already claimed over 21 claims, so 11.39 ETH lifetime to its creator.
- Across the platform, 56 `CreatorFeesClaimed` events from 25 distinct pools had paid 13.202 ETH to creators.
- The hook's native ERC-6909 claim balance on the PoolManager (`balanceOf(hook, 0)`) was 0.2033 ETH, covering all unclaimed creator, platform and wall balances at that block.
- Gap 3 above is partly closed: the pool id and fee flows are now read on a production launch, though a `Launched` event has still not been decoded.
- Code that does this: meme-factory `packages/monitor/src/fees/unihood.ts`.

## Sources

- `contracts/` built by `scripts/bsfetch.py` and `scripts/mkarchive.py` from Blockscout, 2026-09-19.
- Addresses and deploy block: DefiLlama TVL adapter `DefiLlama-Adapters/projects/unihood/index.js`.
- Verified source natspec is the authority for every mechanism claim above.
