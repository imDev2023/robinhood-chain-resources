# ERC-8056 `uiMultiplier()` is display-only: `balanceOf` does not move

> Original writing. Measured 2026-09-19 against mainnet chain 4663 over a dRPC archive endpoint.
> Corrects `45-v4-pools-and-liquidity.md`, which said stock tokens "behave as elastic-supply tokens for any contract that holds them". They do not.
> Method below is reproducible from the addresses and block numbers given.

## The claim being corrected

A Robinhood Stock Token's `uiMultiplier()` does move, often. 28 of the 194 tokens carry a multiplier other than 1.0 as of 2026-09-19, up from 18 sixteen days earlier.

It is tempting, and wrong, to conclude from that the tokens rebase. They do not. The ERC-20 ledger is raw and a corporate action never touches it. Only `balanceOfUI()` and `totalSupplyUI()` scale.

This matters for anyone writing a contract that holds these tokens. Under the wrong reading, a protocol crediting the difference between two balance reads can be paid for currency nobody supplied, which is a critical bug. Under the correct reading, that hazard does not exist on this chain and the tokens are ordinary fixed-supply ERC-20s at the accounting layer.

## Four independent confirmations

**1. The standard.** `09-eip-8056.md` calls the extension "a cosmetic layer" and states in implementation requirement 3 that the standard ERC-20 functions "MUST continue to work with raw amounts". Rationale item 4 is titled "Raw Amount Preservation". The stated motivation is precisely to stop stock splits breaking DeFi internal accounting.

**2. The issuer.** `06-stock-tokens.md`, from `docs.robinhood.com/chain/stock-tokens`: the multiplier "adjusts the shares-per-token ratio while keeping your raw balance static until redemption", and "Onchain swaps remain unaffected".

**3. The chain.** The multiplier flips when `block.timestamp` crosses `effectiveAt`, so the change lands between two consecutive blocks with no transaction in either. Nothing else can have moved a balance.

Ford (`F`), `0x25C288E6D899b9BC30160965aD9644c67e73bE0C`, `effectiveAt` 1788361826:

| | block 52,671,214 | block 52,671,215 |
| --- | --- | --- |
| timestamp | 1788361825 | 1788361826 |
| `uiMultiplier()` | 1.000000000000000000 | 1.000145502866133906 |
| `totalSupply()` | 3777.039000 | **3777.039000** |
| `totalSupplyUI()` | 3777.039000 | 3777.588570 |
| Uniswap v4 PoolManager `balanceOf` | 2937.376921292278 | **2937.376921292278** |
| PoolManager `balanceOfUI` | 2937.376921292278 | 2937.804318053243 |

`Transfer` events emitted by the token across those two blocks: zero.

Carnival (`CCL`), `0x9651342CeA770aE9a2969Ba2A52611523146aef9`, `effectiveAt` 1788189026, a 2.1 percent move, blocks 50,960,760 and 50,960,761: same result, zero `Transfer` events, `totalSupply()` held at 12.984000 while `totalSupplyUI()` moved to 13.262980. Four holders with a non-zero balance, including the PoolManager, had a byte-identical raw `balanceOf` on both sides.

Across all 194 tokens, `totalSupplyUI() == totalSupply() * uiMultiplier() / 1e18` holds 194 times with zero mismatches.

**4. The deployed code.** Implementation `0xb35490d6f9163DE4F80d88dc75c3516eb64C5aE2`, contract `Stock`, verified on `robin.etherscan.io`. `ERC20ScaledUIUpgradeable` does not override `balanceOf` or `totalSupply`; only `balanceOfUI()` and `totalSupplyUI()` apply the multiplier, via `Math.mulDiv`. `_update` is `super._update` plus one extra event, with no fee and no rebase.

## What the tokens *do* carry, which matters more

Reading the deployed `Stock` contract to settle the above surfaced three issuer powers that any integrator should price in. These are the real reasons to be careful with stock tokens, not the multiplier.

**A central registry gates every transfer.** `transfer`, `transferFrom`, `approve` and `permit` all carry `onlyNotBlocked` on both counterparties, checked against `IAccessControlsRegistry.isBlocked()`. Pointed at a protocol's own contract it freezes every position in that token for as long as the flag is set.

**`adminBurn` burns from any address.** `adminBurn(address from, uint256 amount)` under `ADMIN_BURNER_ROLE` calls `_burn` with no holder consent and no pause check. It can remove reserves from a live pool or vault without a transfer that contract initiated.

**All 194 tokens share one upgrade beacon, and it is the registry.** Every stock token is a `BeaconProxy` pointing at `0xe10b6f6B275de231345c20D14Ab812db62151b00`, which is simultaneously the upgrade beacon and the `AccessControlsRegistry` holding the roles, the blocklist and a global `paused()`. One upgrade rewrites the code of every stock token on the chain at once; one pause halts all 194. The registry does not expose `AccessControlEnumerable`, so role holders cannot be listed from chain state and would have to be reconstructed from `RoleGranted` logs.

There is **no fee on transfer**. `transfer` delegates to `super.transfer` with no skim, confirmed live: NVDA block 67,252,507 carried three `Transfer` events to one recipient summing to 2.187914867962, and that recipient's `balanceOf` moved by exactly 2.187914867962.

## Two traps met on the way

**dRPC serves historical `eth_call` inconsistently, and never says so.** The same `(block, calldata)` pair returned different values on different attempts, and sometimes empty data, with no error. A plain binary search over block height reported a state transition at a block where it did not happen. Repeat every archive read until two identical non-empty responses agree; one read is not evidence. `32-explorer-and-data-apis.md` covers the endpoints generally.

**The Etherscan-verified source for the stock tokens carries an injected advertising banner.** The `Stock.sol` served by `robin.etherscan.io` opens with a block comment advertising an unrelated bundling service, above the SPDX line. Live probes of `terms()`, `uid()` and `oraclePaused()` return the values the source predicts, so the source does correspond to the deployed contract and the banner is cosmetic. Recorded so the next reader does not conclude they are looking at the wrong contract.

## Provenance

Settled as ADR-0002 in the `v4-hooks` project (`docs/adr/0002-uimultiplier-is-display-only.md`), which has the full working and the consequences for Uniswap v4 hook design.
