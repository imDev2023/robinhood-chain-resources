# Robinhood Chain launchpads, wave two

Eleven more platforms, archived 2026-09-19, completing the list of recommended next archives in `LAUNCHPADS.md` section 10.
Read `LAUNCHPADS.md` first: it covers the original eleven and its fifteen dimensions are not repeated here.

**This document asks a different question.**
`LAUNCHPADS.md` ranks platforms for a creator deciding where to launch a token with no LP budget.
This one ranks them for someone deciding **which design to build on**, so it is weighted toward custody, upgradeability and mechanism rather than toward creator payout.

**It is also shallower, deliberately.**
Wave one archives carry docs captures, screenshots, socials, decoded production launches and wallet-gated UI walkthroughs.
These eleven carry verified contracts and a mechanism read from source, and nothing else.
Every archive's own README ends with an explicit gap list.
Where a cell here says "not read", that means nobody checked, not that the answer is no.

---

## 1. Corrections to `LAUNCHPADS.md`

Three of the twelve targets in section 10 were not what the catalog said.

**LetsCash is already archived, and was never missing.**
It was ranked the #2 next archive, "$1,613,786 in 30 days, and the catalog records no site, no X handle and no mechanism at all.
Pure unknown at real scale."
Its factory is `0x5bd1Fbe78a78fe8236fa00CF48fbEBA74ae34661`, which is the `CashCatFactory-proxy` sitting in `launchpads/hood10/contracts/`, and `hood10/README.md` section 5.1 already documents the relationship in depth.
LetsCash is letscash.fun, the pad the HOOD10 token itself launched on.
The chain's second-largest unarchived fee earner was a naming collision.

**PAIR is a DefiLlama data defect, not a research gap.**
`LAUNCHPADS.md` section 10 records PAIR as appearing "in the DefiLlama fee table but absent from the catalog table entirely, with no site, handle or mechanism recorded anywhere", and calls that "a gap in `_market`".
It is not.
DefiLlama lists PAIR with an **empty `chains` array**, so it survives a chain fee query and is dropped by every chain-filtered catalog query.
PAIR is `pair.fund`, `@pairdotfund`, and it is live on Robinhood Chain.

**pools.fun and Pools.trade are unrelated**, which the catalog flagged and which is confirmed: different operators, different venues, SushiSwap V3 against Uniswap v4.

### PonsVault is archived, inside `pons/`

Recorded here because it is not findable by name from the top level and is easy to mistake for a missing archive.

`ponsvault.com` is a second front end by the Pons team that launches **through the same pons v2 factory** and sets `creatorFeeRecipient` to a vault contract instead of a wallet, so the creator's fee share is spent on a rule rather than paid out.
It is covered in `pons/README.md` section 3.4, with 22 page captures (`pons/pages/12-ponsvault-home.md` through `33-ponsvault-docs-live.md`) and 20 PV1 and PV2 contracts under `pons/contracts/`.

Its launch menu is the widest set of creator-fee options on the chain: **Staking**, **RWA Dividend** and **Fee Share** in the live form, plus **Stake & Burn** and **Buyback & Burn**, which were pulled from the public form but still have 49 and 19 live vaults respectively.
Every vault parameter is written once at creation and has no setter.

**The design idea is worth more than the contracts.**
Because the vault is simply the fee recipient, the launchpad core needs to know nothing about vault types, and an options menu can be added without touching custody-critical code.
Unihood already supports the same composition: `UnihoodHook.setFeeRecipient` is gated on `msg.sender == feeRecipient`, so a creator can point the stream at a vault and **no admin can redirect it**, which is the specific weakness Pons itself has.

**The contracts are not reusable.** Re-checked live on 2026-09-19: all five PV2 vault implementations (`PV2StakingVault`, `PV2RwaVault` and its live twin, `PV2BuybackBurnVault`, `PV2StakeBurnVault`) are **unverified**, and the archive holds them as `bytecode.hex` and `metadata.json` only.
The PV1 generation is verified (`PV1VaultLauncher`, `PV1VaultRegistry`, `PV1BuybackBurnVaultFactory`), but the v1 vault instance itself is not.
Anyone building a vault menu has no source to copy from PonsVault.

---

## 2. The custody ranking, across all twenty-two

This is the column that decides what to build on, and it is the one where the new eleven change the picture.

| # | Platform | Privileged surface in the launch path | Upgradeable? |
| --- | --- | --- | --- |
| 1 | **Unihood** | **None.** No `Ownable`, no `onlyOwner`, no `owner()` in factory, hook or token | No |
| 1= | **Pools.trade** | **None.** No owner, setter, treasury or proxy anywhere | No |
| 3 | **Coinbarrel** (custody only) | None on the custody contract, 81 lines | No |
| 4 | **HOOD10** | Two: `setFeeRouter` on the hook, `setPaused` on the factory | No |
| 5 | **hood.fun** | Two Safes, neither able to touch curve reserves or locked liquidity | No |
| 6 | **o1 Launchpad** | Hook and escrow ownerless; **10 `onlyOwner` on the factory** | No |
| 7 | **Mixpad** | 7 on `MixpadFactory`, 6 on `RwaFactory` | No |
| 8 | **pools.fun** | 7 on `PartyFactory` | No |
| 9 | **Sentry** | Hooks immutable, LP vault has no withdrawal; **one EOA upgrades both factories** | Yes |
| 10 | **Bankr / Doppler** | Airlock 2, DERC20 4; **BNKR numeraire is a proxy** | Token yes |
| 11 | **PAIR** | Not enumerated; **`PairLaunchpadV5Upgradeable` behind ERC-1967** | Yes |
| 12 | **token.select** | Not enumerated; factory behind ERC-1967 | Yes |
| 13 | **Bags** | One EOA owns the factory proxy and **both beacons** | Yes |
| 14 | **Virtuals** | One EOA is owner and proxy admin, already upgraded three times | Yes |
| 15 | **Noxa v2** | `setProtocolFeeShare` is **global, retroactive, instant** | Factory unverified |
| 16 | **RaiseHood** | **`setLpLocker` swaps the locker**; `setCreatorApproval` gates who may launch | Unverified |

Rows 1 to 5 are the only ones where a creator's position cannot be reached by any key.

**Unihood is the new top of this table.**
Pools.trade shares the property but is Uniswap Labs' auction machinery, tens of thousands of lines across 40 contracts.
Unihood reaches the same custody posture in **793 lines of first-party MIT Solidity**.

**RaiseHood is the new bottom.**
`setLpLocker(address)` means the contract holding locked liquidity can be replaced by the admin.
No other platform in the twenty-two, including Noxa, allows that.

---

## 3. The new eleven, by model

| Platform | Model | Venue | Graduation | Lock |
| --- | --- | --- | --- | --- |
| Unihood | Direct seed, full supply single-sided | Uniswap v4 | `gradTick` exists, unlocks external LP | Factory holds position, **no removal function exists** |
| Mixpad | Direct seed, full supply single-sided | Uniswap v4 | none | **LP burned** |
| o1 Launchpad | Direct seed, single-sided | Uniswap v4 | none | Hook owns position, **no negative liquidityDelta path** |
| Coinbarrel | not read | Uniswap v4 + V3 | not read | **Ownerless custody** |
| StonkBrokers | not read | Uniswap V3 + Slipstream | yes, "bond" | Locker, right held as **transferable NFT** |
| Bankr | Doppler Multicurve | Uniswap v4 | **none, `NoOpMigrator`** | Nothing migrates |
| PAIR | not read, **two pools per launch** | Uniswap v4 | not read | not read |
| token.select | Fixed-price funding (unconfirmed) | Uniswap V3 | migrates | **Per-launch `lpVault`** |
| pools.fun | Direct pools, no curve (unconfirmed) | **SushiSwap V3** | none | not read |
| RaiseHood | Fixed-price presale with vesting | Uniswap V3 | settlement | Locker, **swappable by admin** |
| bow.fun | Curve then migration | Uniswap V3 | `migrated()` | Locker |

Six of the eleven are direct-seed with no bonding curve.
Together with Sentry, HOOD10, Noxa and Pools Instant Launch from wave one, **ten of twenty-two** now use the single-sided-supply design, and every one of the six newest does.
The original survey's closing question, whether that design is converging chain-wide, is answered: it has.

---

## 4. Unihood in detail, because it is the recommendation

One transaction deploys the token, initializes a native-ETH v4 pool at a fixed start tick, places the entire 1B supply as a single-sided range down to the minimum usable tick, and optionally runs the creator's fee-free first buy.

**Fees.** The pool's LP fee is zero. The hook charges 1% on the ETH side, both directions, split:

| Bucket | Share of the 1% |
| --- | --- |
| Creator | **80%** |
| Platform | 15% |
| Bid wall | 5% |

A creator receives **0.80% of all ETH volume for the life of the token**, with no accrual ledger an operator administers and no fee router in the path.
Fees accrue as ERC-6909 claims inside the PoolManager.

**Anti-snipe.** Total fee is 15% under 5 seconds, 5% under 15 seconds, then 1% forever. Everything above the 1% base funds a self-executing **bid wall**, a buy order one tick spacing below spot. The hook's own comment: "snipers build the floor". The schedule reads the clock only, so it cannot be gamed with dust swaps.

**Limitation.** Native ETH only. No quote registry, so no USDG and no tokenized-stock pairs. HOOD10, o1, Mixpad's `RwaFactory`, Doppler, Long, Flap, Pons and Sentry all can do this and Unihood cannot.

---

## 5. What is still missing

**Two archived contracts are unverified**: RaiseHood's factory and bow.fun's factory. Both have PUSH4 selector scans in `_raw/rpc/`, which identify the family but are not source.

**Two archives have no launch factory at all**, only downstream contracts: StonkBrokers and Coinbarrel. The DefiLlama TVL adapters that supplied the addresses name TVL-bearing contracts and nothing else, so lockers and custody came through and the launchers did not.

**Cheap wins left on the table:**

1. `bow.fun/docs.html#deployed-contracts` publishes its addresses. One fetch.
2. `github.com/o1exchange/o1-launch` at commit `756a75c` is o1's public source. One clone, and it answers o1's ten owner functions.
3. Enumerating the owner functions on Mixpad (13), pools.fun (7) and o1 (10) would finish section 2's table.

**Unverified claims carried forward from the catalog**, each of which needs a contract read before it is trusted: Bankr's four-way fee split, pools.fun's daily buy-and-burn, token.select's presale model.

**No audit anywhere.** Adding eleven platforms did not change the finding from `LAUNCHPADS.md` section 11: not one platform on this chain has a published audit covering the code that runs on it. The column is now empty twenty-two times.

---

## 6. Refreshed chain numbers, 2026-09-19

Read live, and they have moved since 2026-09-02.

| Measure | At capture | Now | Change |
| --- | --- | --- | --- |
| Doppler assets on 4663 | 109,177 | **153,855** | +41% |
| Bankr assets | 88,764 | **90,404** | +1.8% |
| Bankr share of Doppler | 81.1% | **58.8%** | other integrators grew |
| DefiLlama Launchpad protocols on 4663 | ~20 to 30, self-contradictory | **36** | - |

The 36 includes platforms that did not exist at capture: Pez Family, PerpsHood, Bonker, Phera DEX Launchpad, HoodSale and others.
`_market/README.md` catalogued 54 distinct platforms; the launchpad category alone has grown, so that number is now low.

## Sources

One README per platform under `launchpads/<slug>/README.md`.
Contracts built by `scripts/bsfetch.py` and `scripts/mkarchive.py` from Blockscout on 2026-09-19; selector scans by `scripts/push4scan.py`.
Method additions from this wave are in `launchpads/PLAYBOOK.md` section 9.
