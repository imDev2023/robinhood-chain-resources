# Robinhood Chain launchpads, compared

Eleven platforms, each archived in `launchpads/<slug>/`, compared on the dimensions that decide where to launch a token with no budget to seed liquidity.

> **A second wave of eleven platforms was archived on 2026-09-19; see `LAUNCHPADS-II.md`.**
> It completes the recommended-next-archives list in section 10, corrects three entries there, and ranks all twenty-two on custody rather than on creator payout.
> Two corrections bear on this document directly: **LetsCash was never missing**, being the CashCat set already archived under `hood10/`, and **PAIR's absence from the catalog is a DefiLlama data defect**, not a gap in `_market`.

Written 2026-09-03 from the eleven platform READMEs.
Every cell cites the README section it came from, in the form `<slug> s3.1`.
Where an archive did not answer a dimension the cell reads `not recorded`, which means the question was not settled, not that the answer is no.

**Capture dates differ and are not normalised.**
Nine archives captured 2026-09-02, `noxa` and `pools-trade` on 2026-09-03.
Where a number moved between those two days it is marked.
The DefiLlama column uses the single 2026-09-02 pull in `_market/README.md`, because it is the only internally consistent set across all eleven; the per-platform READMEs' own 2026-09-03 pulls are higher and are noted where they differ.

**A dimension was added to the plan's list.**
Part 6 of `SCRAPING-PLAN.md` specifies fourteen dimensions.
This document adds a fifteenth, **owner and admin powers**, because it is what actually separates the candidates: nine of the eleven platforms have a privileged key that can redirect a creator's income, upgrade the code underneath a live launch, or both.
Economics alone ranks these platforms in almost the opposite order to economics plus custody.

---

## 1. The short version

Ranked for the stated constraint, launching with no LP budget.
Read the assumptions in section 9 before using this ranking; four of the five open questions in `NEXT-SESSIONS.md` are still unanswered and two of them would reorder it.

| # | Platform | Launch cost | Creator income | Can the operator take it away? |
| --- | --- | --- | --- | --- |
| 1 | **Pools.trade** | gas only, $2.83 | 40% of the ETH side of a 0.25% LP fee, opt-in | **No.** No owner, setter, treasury or proxy anywhere in the launch path |
| 2 | **Sentry** | gas only | 1.00% of every trade at the floor, settled in-swap | Partly. Hook fee params are immutable per pool, but one EOA can upgrade the factories |
| 3 | **Pons v2** | 0.0005 ETH | 0.70% of volume plus a creator tax up to 10% | Yes. An owner Safe can reassign a token's fee recipient behind a 3-day timelock |
| 4 | **Bags** | gas only, 0.000638 ETH | 1% of all ETH volume, forever | Yes. One EOA owns every `BagsFeeShare` and can call `setClaimers` |
| 5 | **HOOD10** | gas only | up to 9% of volume, creator-set at launch | No, on the creator lane. The owner's only launch-path power is `setFeeRouter` |
| 6 | **Doppler** (direct) | gas only, 3.16M | up to 95% of a 1% pool fee | Partly. A 3-of-6 Safe controls the module whitelist and hook approval |
| 7 | **Virtuals** | 0 VIRTUAL plain | 0.7% of the VIRTUAL leg, paid in USDG | Yes. One EOA is owner and proxy admin, and has already upgraded three times |
| 8 | **Noxa v2** | 0 ETH | 100% of a 1% pool fee today | **Yes, retroactively, in one transaction, with no delay** |
| 9 | **hood.fun** | gas only, $1.34 | 80% of a per-launch trade fee | Partly, and three undocumented paths zero it without anyone acting |
| 10 | **Long** | gas only, 1.8M | 0.095% of volume | Long takes ~0.9% of the same volume, about nine times the creator |
| 11 | **Flap** | gas only, ~0.001 ETH | **nothing, unless you levy a tax** | A 2-of-5 Safe with no timelock can replace the Portal holding every curve's reserve |

The two rows worth arguing about are 1 and 2.
Pools.trade pays less than Sentry per unit of volume and cannot take it back; Sentry pays roughly three times more per trade and its operator retains an upgrade path.
Section 9 sets out which of your unanswered questions decides between them.

---

## 2. Launch model, cost and what one transaction does

| Platform | Model | Creation fee | Gas |
| --- | --- | --- | --- |
| pons v2 | Bonding curve in the pair asset, graduates to a full-range Uniswap v4 position (`pons` s2, s3.1) | 0.0005 ETH, read from `launchFee()` and confirmed on twelve real launches (`pons` s3.1, s4.1) | not recorded (`pons` s4.1) |
| doppler | `Airlock.create` with four modules; on 4663 the app builds only Multicurve, a curve that never leaves (`doppler` s3.1, s3.2) | none, `create` is not payable in a fee sense (`doppler` s4) | ~3.16M (`doppler` s9 gap 1) |
| long | A Doppler Multicurve launch with Long's Rehype hook attached (`long` s2, s5.1) | none, `value = 0` on all 50 decoded calls (`long` s4) | ~1.8M (`long` s4) |
| bags | Virtual constant-product curve in ETH, one-way migration to Uniswap v4 (`bags` s2, s3.2) | **0 ETH live**, set by the owner 2026-07-13; docs still advertise 0.02 ETH (`bags` s4) | 1,731,956 gas, 0.000638 ETH (`bags` s3.3) |
| virtuals | Curve against VIRTUAL, graduates to Uniswap V2. **Two transactions**, `preLaunch` then `launch` (`virtuals` s3.2) | 0 VIRTUAL plain, 10 VIRTUAL for ACF (`virtuals` s4) | not recorded (`virtuals` s4) |
| sentry | **Direct pool seed, no curve.** One transaction deploys, renounces, seeds 100% of supply one-sided and opens trading (`sentry` s2, s3.2) | free apart from gas (`sentry` s2) | not recorded; no launch was ever executed (`sentry` s9) |
| flap | Bonding curve with an optional programmable tax layer (`flap` s2, s3.1) | zero, two of five decoded launches sent `msg.value = 0` (`flap` s3.3) | ~0.001 ETH, the app's own quote (`flap` s3.6) |
| hood10 | **Direct pool seed** inside one `PoolManager.unlock` (`hood10` s2, s3.2) | none (`hood10` s3.1, s4.1) | not recorded (`hood10` s4.1) |
| hood-fun | Bonding curve, pump.fun in shape, built for this chain and **not** on Doppler (`hood-fun` s2) | `creationFee` = 0 (`hood-fun` s4.1) | 1,235,667 gas, 0.000557 ETH, **$1.34** (`hood-fun` s4.1) |
| pools-trade | Two models: Crowd Launch is a continuous clearing auction; Instant Launch is one v4 position holding the whole supply (`pools-trade` s2) | zero fee, gas only (`pools-trade` s3, s4) | $2.83 Instant, $7.14 Crowd, the interface's own quotes (`pools-trade` s4) |
| noxa v2 | **Direct pool seed**, Uniswap V3 1% pool, nothing migrates (`noxa` s2, s3) | **0 ETH**, since 2026-08-29 18:58 UTC; was 0.0005 ETH before (`noxa` s3, s4) | not recorded (`noxa` s9) |

Three of the eleven have no bonding curve at all.
Sentry, HOOD10 and Noxa put the entire supply into a live pool in the launch transaction, which is why they have no graduation event and no migration risk.

**The cheapest launch is hood.fun at $1.34, and it has the worst expected payout in the set** (`hood-fun` s4.1, s4.3).
Cost is not the discriminator here; every platform is between zero and about $7.

---

## 3. Trade fee, split, and what the creator actually receives

| Platform | Total trade fee | Creator's cut | Settlement | Per-launch or global? |
| --- | --- | --- | --- | --- |
| pons v2 | 1.00% of the quote leg, both phases; pool fee is 0 after graduation (`pons` s3.1) | 0.70% of volume, or 0.35% cash plus 0.35% into a 5-year vested buyback; **plus a creator tax of 0 to 10%** (`pons` s3.1, s4.1) | Pull, from `PonsV2FeeEscrow`, in the pairing asset (`pons` s3.1) | The tax is per-launch; **the 70/30 split is a live global knob**, and the launch struct carries an `expectedEconomics` guard precisely so a launch reverts if the owner moved it after your quote (`pons` s3.1) |
| doppler | 1% pool fee by default, up to 10% (`doppler` s3.1, s4) | up to 95%, so 0.95% of volume; Doppler's 5% floor is enforced in code and `create` reverts without it (`doppler` s4) | Pull, `collectFees(poolId)`, watermark accounting, **in both sides of the pair** (`doppler` s5.6) | Per-launch, stored at creation; a beneficiary can hand their slot away with `updateBeneficiary` (`doppler` s4, s5.6) |
| long | Two stacked fees: 0.1% LP plus a Rehype hook fee decaying to 1.12% (`long` s3.2, s3.3) | **0.095% of volume**, being 95% of the LP fee. Nothing from the hook fee (`long` s4) | Pull, `collectFees(poolId)`, both assets (`long` s3.5) | The 95/5 LP split is per-launch; the fee levels are app constants Long changed globally with no announcement (`long` s3.4) |
| bags | 2% flat on the ETH leg, both phases (`bags` s3.3) | **1% of all ETH volume, for the life of the token** (`bags` s4) | Pull, in WETH, from the token's `BagsFeeShare` (`bags` s3.3) | **The 50/50 split is hard-coded** in the curve and hook, so it is not a knob; the claimer set is per-launch (`bags` s3.3) |
| virtuals | 1% buy and 1% sell of the VIRTUAL leg, plus 0.30% Uniswap V2 after graduation (`virtuals` s3.2, s4) | 0.7% of the VIRTUAL leg, less an optional partner share up to 20% (`virtuals` s4) | **Push**, not pull, and not in-swap: accumulates, then swaps to USDG once 1 VIRTUAL has accrued (`virtuals` s3.2 step 10) | **Global mutable knob**: `feeRate()` is contract state with no per-token override (`virtuals` s4) |
| sentry | **Decaying dynamic fee**: opens at 40.0000%, holds 180 s, halves every 180 s, floor at ~17 minutes. Floor 1.7000% on WETH (`sentry` s3.3) | **1.00% of every trade at the floor** on a plain WETH launch, 0.50% on reflections and stock launches; **23.5% during the opening window** (`sentry` s3.4, s4) | **In-swap, by the hook. There is nothing to claim and no accrual ledger** (`sentry` s3.4) | Hook fee params are `immutable` per pool; but `setCreatorFeeBps` on the factories makes the recorded share owner-settable **for future launches** (`sentry` s5) |
| flap | 1% on curve buys and sells, **100% of it to Flap's FeeSafe** (`flap` s3.6) | **Non-tax token: nothing, ever.** Tax token: 96.40% of a tax you set up to 10% (`flap` s3.7) | Push once ~$4 accrues, in the quote asset (`flap` s3.7) | The 1% curve rate and the 3%/0.6% tax skim are global protocol knobs; the tax rate and its four-bucket split are per-launch (`flap` s3.6) |
| hood10 | Protocol lane fixed at 1.00%, plus a creator lane of 0.00% to 9.00% (`hood10` s3.4) | **up to 9% of volume**, whatever the creator chose at launch (`hood10` s3.4) | Pull, `settle(poolId)` then `claim(poolId, to)`, **in the pool's quote asset** (`hood10` s3.4) | **Per-launch and immutable**: `register` is factory-only and reverts `AlreadyRegistered`; the 1% protocol rate is a constant nobody can change (`hood10` s3.4) |
| hood-fun | `tradeFeeBps` is a **per-launch argument** bounded 100 to 500; the form always sends 100 (`hood-fun` s4.1, s4.5) | 80% of the curve trade fee and 80% of the migration fee; post-graduation, 80% of the **WETH side only** (`hood-fun` s4.1, s4.3) | Pull, credited as a claimable balance (`hood-fun` s3.6) | Migration terms are snapshotted at launch and `_migrate` reads the snapshot, so **an owner cannot re-price a launched coin** (`hood-fun` s3.2) |
| pools-trade | 0.25% LP fee plus a 0.04% Uniswap v4 protocol fee, about 0.29% total (`pools-trade` s4) | **40% of the native side, 0% of the token side**, opt-in and **off by default** (`pools-trade` s4) | Pull, in ETH, and the claim right is a **transferable ERC-721**; collection is permissionless but always pays the NFT holder (`pools-trade` s3) | **Per-launch and immutable.** The `FeeSplitter` split table is fixed in the constructor (`pools-trade` s5) |
| noxa v2 | 1% Uniswap V3 pool fee (`noxa` s3) | **100% today** (`noxa` s3) | Pull, in ETH, but **permissioned**: only the deployer, the locker's owner, or an owner-whitelisted address may call `collectFees` (`noxa` s3) | **Global, mutable and retroactive, read at collection time.** The verified source says the non-snapshotting is deliberate (`noxa` s5, s9) |

Two mechanisms in this table are structurally different from the rest.

**Sentry settles in-swap.** There is no accrual, no claim call and no balance sitting in a contract that someone else administers (`sentry` s3.4). Every other platform here has a claimable balance, and on several of them a privileged key decides who may claim it.

**Noxa's 100% is a global read at collection time, not a term of your launch.** It was 50 at deploy, 70 at 2026-08-29 15:14:49Z, and 0 at 16:42:51Z the same day (`noxa` s4). The 50 held five weeks; the 70 held 88 minutes. The launch fee went to zero at 18:58 UTC that same day, so three economic terms moved inside about four hours. A creator launching on the "100% of fees" promise is trusting a value the owner can set to 100% protocol, retroactively, for every token ever launched, in one transaction with no delay (`noxa` s9).

---

## 4. Graduation and liquidity lock

| Platform | Threshold | Real or display? | Destination | Lock mechanism |
| --- | --- | --- | --- | --- |
| pons v2 | 4.2 ETH, or 8,090 USDG, or the per-asset equivalent (`pons` s3.1, s4.2) | **Real** | Full-range Uniswap v4 position (`pons` s3.1) | `PonsV2LaunchLocker`, which **exposes no withdrawal and no arbitrary-call function** (`pons` s3.1) |
| pons v1 | 4.2 ETH of WETH paired | **Display only.** "Nothing moves" (`pons` s2, s4.3) | n/a, the pool is the launch pool | Position NFT in a locker; permanence not recorded, and both live v1 lockers are ERC1967 proxies (`pons` ADDRESSES.md) |
| doppler | A price (`farTick`), not an amount raised (`doppler` s3.2) | **Inert on this chain.** 0 of 109,177 assets have migrated (`doppler` s7.2) | none in practice; 109,129 use `NoOpMigrator` (`doppler` s3.3) | **No locker on the live path and no named mechanism.** Permanence comes from nothing migrating, which is a weaker claim (`doppler` s3.3) |
| long | none, "the pool is permanent" (`long` s4) | n/a | the launch pool itself (`long` s5.1) | **None recorded**, because 100% of supply is sold on the curve and no locker is in the path (`long` s3.2, s5.1) |
| bags | 5 ETH of net real reserves (`bags` s3.4) | **Real**, and a buy that overshoots is capped and refunded (`bags` s3.4) | Uniswap v4, one pool per token against WETH (`bags` s3.4) | **The hook reverts every `removeLiquidity`.** The LP NFT is minted to the platform key, which holds it but cannot withdraw while the hook is in place (`bags` s3.4) |
| virtuals | 42,000 real VIRTUAL (`virtuals` s3.2) | **Real**, arithmetic verified against a live token (`virtuals` s3.3) | Uniswap V2 (`virtuals` s4) | **A time lock, not a structural bar**: 100% of LP staked in `AgentVeTokenV2` with a **ten-year** maturity, sTOKEN to the creator (`virtuals` s4) |
| sentry | **none, by design** (`sentry` s3.6) | n/a | the launch pool, Uniswap v4 (`sentry` s3.2) | `SentryLPVault`, which **has no withdrawal function at all**; the only outward paths are fee collection. "Locked even against that owner" (`sentry` s3.4, s5) |
| flap | 800,000,000 supply, exactly 5.000000 ETH on the ETH curve (`flap` s3.8) | **Real** | Uniswap V2 fork (`flap` s3.8) | **Burn.** 99.93% of `$moon`'s LP sits at the dead address, and `getLocks()` returns `(0,0)` (`flap` s3.7) |
| hood10 | **none** (`hood10` s3.6) | n/a | the launch pool, Uniswap v4 (`hood10` s2) | **The strongest in the set.** `_beforeInitialize` factory-only, `_beforeAddLiquidity` one add per pool, `_beforeRemoveLiquidity` **always reverts**, and no owner path around any of the three (`hood10` s3.3) |
| hood-fun | 6.5159 ETH, identical on all 23 graduations ever emitted (`hood-fun` s3.3) | **Real**, and migration is atomic inside the graduating buy (`hood-fun` s3.3) | Uniswap v3, 1% fee tier (`hood-fun` s3.3) | **Ownerless locker.** "No withdraw, no owner and no admin, so the position can never leave" (`hood-fun` s2, s5.3) |
| pools-trade | Crowd Launch: `requiredCurrencyRaised` 2.0905178565 ETH, a $10K FDV. Instant Launch: $50,000 (`pools-trade` s4, s3) | Crowd Launch **real**; **Instant Launch is a display milestone**, `graduationTargetUsd` drives a discovery tab and nothing else (`pools-trade` s3) | Uniswap v4, hookless, 0.25% (`pools-trade` s2) | The LP NFT is owned by a `FeeSplitter` that can collect fees and increase liquidity but **can never transfer the position out** (`pools-trade` s4) |
| noxa v2 | 20 WETH FDV, about $48,000 (`noxa` s3) | **Display only**, and derived over 12 tokens rather than documented, so it could change server-side with no chain event (`noxa` s3, s9) | n/a, the token is on the destination from block one | Locker with **no unlock, withdraw or transfer-out function** (`noxa` s3, s5) |

**Graduation rates, where an archive states one.**

| Platform | Rate | Base |
| --- | --- | --- |
| pools-trade, Crowd Launch | **52.9%** | 64 of 121 concluded auctions (`pools-trade` s7) |
| bags | ~0.9% | 38 of 4,248 (`bags` s7) |
| hood-fun | **0.21%** | 23 of 11,026 (`hood-fun` s5.1) |
| flap | 0.07% to 0.21% | two samples of 3,000, flagged as a sample not a census (`flap` s7) |
| virtuals | not stated as a rate | 85 graduated of 25,342 pre-launched (`virtuals` s5.3) |
| doppler, long | 0%, by design | 0 of 109,177 migrated (`doppler` s7.2) |
| sentry, hood10, noxa v2, pons v1 | n/a | no graduation, or display only |

Pools.trade's 52.9% is not evidence of better outcomes and its own README says so: it is a consequence of a $10K FDV bar, which is very low (`pools-trade` s7).

---

## 5. Quote assets, supply and anti-snipe

| Platform | Quote assets | Supply | Creator allocation | Anti-snipe, and is it enforced? |
| --- | --- | --- | --- | --- |
| pons v2 | **25 approved**: ETH, USDG and 23 stock tokens (`pons` s4.2) | 1B, 71.429% curve / 28.571% pool (`pons` s4.1) | none as a parameter; only a dev buy (`pons` s3.1) | **Enforced**: 99% opening tax decaying over 3 s, launcher exempt, up to 32 more wallets nameable (`pons` s3.1) |
| doppler | **98 assets** in the app dropdown; pairing against a stock is first-class, and ETH is not the norm (`doppler` s3.1, s7.4) | 1B, 100% sold, unallocated burned (`doppler` s3.1) | possible but the app ships it at zero (`doppler` s3.1) | **The built-in one is off**: a real app launch sets `maxBalanceLimit = 0`. What runs in production is the Rehype hook fee (`doppler` s4) |
| long | ~95 stock tokens, USDG, ETH, AI, even a leveraged token (`long` s2, s5.4) | 1B, 100% on the curve (`long` s3.2) | **none**, and vesting is not offered (`long` s3.2) | **Enforced**, and it is the 80% opening hook fee, which works with no per-wallet cap (`long` s4) |
| bags | **ETH only.** Stock tokens appear as an output, never as the pair (`bags` s3.4, s3.6) | 1B, 830M curve / 170M pool (`bags` s4) | 0 (`bags` s3.3) | **Only the atomic `createAndBuy`.** No whitelist, no cap, no delay (`bags` s3.3) |
| virtuals | **VIRTUAL only**, and specifically the CCIP-bridged token (`virtuals` s4) | 1B; curve supply 100% plain, 50% with ACF (`virtuals` s4) | **Yes, and vested on chain**: ACF team allocation 25% locked 1 year then 6-month linear, plus a 25% fundraise sold on an FDV ladder (`virtuals` s4) | **Enforced**: 99% decaying to the 1% base over 60 s to 98 min depending on preset (`virtuals` s4) |
| sentry | WETH, plus 19 stocks and ETFs in the picker (`sentry` s3.1, s5) | 1B, **100% into the pool** (`sentry` s4) | **none.** "There is no supply field, no fee field, no curve field and no liquidity field" (`sentry` s2) | **Enforced, and it is the fee curve itself**, driven only by the clock so it cannot be gamed with dust swaps (`sentry` s3.3) |
| flap | **26 assets**: ETH, HOODon and 24 stocks. The docs say ETH only, which the README calls false (`flap` s3.5) | 1B, 100% on the curve (`flap` s3.8) | none, and no vesting parameter exists (`flap` s3.8) | **Enforced as a hard revert**, not a fee: all pool transfers blocked pre-graduation, default 30-day window. Limited: only pools registered at init are covered (`flap` s3.9) |
| hood10 | **Permissionless in denomination, deliberately not an allowlist**; the 21 offered are a convenience list (`hood10` s4.2) | **Creator's choice**: 100M, 1B, 10B, 100B in the form, any `uint256` in the contract (`hood10` s3.1) | none of any kind (`hood10` s4.1) | **Enforced**, creator-set surge decaying over a block window, and the proceeds go to the protocol lane, never the creator (`hood10` s3.4) |
| hood-fun | WETH by default; five quotes have a configured path: USDG, GME, AAPL, NVDA, TSLA (`hood-fun` s3.4) | configurable, default 1B; 80% curve / 20% LP (`hood-fun` s4.1) | none (`hood-fun` s3.2) | **Enforced**, three overlapping caps, none of which survive graduation, and the contract's own comment says so (`hood-fun` s3.3) |
| pools-trade | **ETH only** (`pools-trade` s4) | 1B fixed, nothing configurable (`pools-trade` s3) | none by default; `Buy at launch` capped at **5%**, paid at pool price (`pools-trade` s4) | Crowd Launch: **enforced** by a 13-step schedule, 70% dripping over 4 hours and 30% clearing in the final block. Instant Launch: **the interface itself says "No sniper protection"** (`pools-trade` s4) |
| noxa v2 | **WETH only**, on all three deployments (`noxa` s3, ADDRESSES.md) | 1B, no mint function (`noxa` s3) | 0% unless bought via the dev buy, which is **uncapped** (`noxa` s3) | **Not enforced in practice**: `maxWalletBps` 10000, `maxTxBps` 10000, `restrictionSeconds` 1, while the UI claims a one-hour limit (`noxa` s3) |

If pairing against a tokenized stock or USDG matters, the field narrows to **doppler (98), long (~95), flap (26), pons (25), sentry (20), hood10 (permissionless)**.
Bags, Virtuals, Pools.trade and Noxa cannot do it at all, and on hood.fun **doing it destroys the creator's post-graduation income** (section 6).

---

## 6. Where a creator's money quietly goes to zero

Four platforms have a documented path by which a creator who did everything right earns nothing.
This is not a risk column, it is a mechanism column: each of these is a specific contract behaviour someone verified.

**flap, if you launch without a tax.** The curve's 1% goes entirely to Flap's FeeSafe, migration is V2-only, and the LP is burned, so there is no fee stream and no LP position to collect from. `Portal.getLocks($moon)` returns `(0,0)`. The README's own words: "A non-tax launch on Flap Robinhood is a pure giveaway by the creator" (`flap` s3.7).

**hood.fun, three ways** (`hood-fun` s4.4), none of them in the whitepaper:
1. **A rewards mode gives away 100% of the fee stream.** The community and stock factories call `createTokenFor(creator = <a clone>)`, so the coin's `creator` is a vault contract, not your wallet. 3,593 of 10,629 coins on the 2026-09-02 board are community coins, and the platform's highest-volume coin ever is one of them, so its creator earned nothing from it.
2. **Pairing against a stock or USDG burns your post-graduation income permanently.** `HoodBurnLocker._distribute` pays the creator only when the collected token *is* WETH. Pair against NVDA and 80% of the quote-side fee is burned to `0x...dEaD`, 20% goes to protocol, and the creator receives nothing, forever. The README calls this an oversight in a contract written when WETH was the only quote.
3. **The 1% trade fee is a UI choice, not a protocol constant.** `tradeFeeBps` is bounded 100 to 500, so a direct caller can set 5% and keep 80% of it. This is the one undocumented path that works **in the creator's favour**.

**long, if you enter Community mode.** The v2 vault retains a share for a hardcoded Long ops EOA to push or migrate at will, and the vault source states the arrangement "carries NO creator guarantees and NO governance" (`long` s3.5).

**virtuals, structurally.** The creator's 70% is recorded by `AgentTaxV2.registerToken` and fee delegation can point it at another identity, so the recipient is redirectable at the contract level (`virtuals` s3.2 step 10).

And the near-miss worth naming: **HOOD10's advertised 0.7/0.3 use of its 1% protocol fee is not enforced.** The `feeRouter` was repointed on 2026-08-29 at 21:45 UTC, five hours after being pointed at the real `FeeRouter` contract, to `0xbd40E138...`, **which has no code**. All 117 `PlatformCollected` events since name that EOA. `/api/vault` reports `paidLifetime` of 0 and a `buybackUsd` that is arithmetically just `withdrawnUsd x 0.7`, a projection rather than an observed purchase. `/api/health` still serves the stale router address, so anyone integrating against it wires up the wrong one (`hood10` s3.4, s6). **This does not touch the creator lane**, which `settle`/`claim` route to `creatorTab[poolId]` with no owner path (`hood10` s4.3).

---

## 7. Trust: audits, teams, verification and privileged keys

| Platform | Audit | Public repo | Named team | Contracts verified | Who holds the keys |
| --- | --- | --- | --- | --- | --- |
| pons | **None closed.** Three engagements open; the docs say treat v2 as unaudited (`pons` s5.5) | Yes for the protocol; the PonsVault repo **does not exist** (`pons` s1, s9) | Legal entity only, Pons Labs LLC (`pons` s1) | 31 of 52 (`pons` s5) | A Safe, threshold not recorded. **Can propose an involuntary reassignment of a token's `creatorFeeRecipient` behind a 3-day timelock, and moving your fees during the wait does not cancel it, deliberately** (`pons` s3.1) |
| doppler | Two claimed, **neither readable**, both behind a signed-in Drive folder, both predating the 4663 deployment (`doppler` s5.7) | Yes, 18 repos cloned (`doppler` s1) | Legal entity, Local Group Inc / Whetstone Research; no roster (`doppler` s1) | **33 of 33.** But only 11 of 136 checked addresses are whitelisted as modules, and two contracts the docs list for this chain are not among them (`doppler` s5.3) | Safe, **3-of-6**. Controls the module whitelist and hook approval. `StreamableFeesLockerV2.owner()` is still the pre-transfer constructor address (`doppler` s5.5) |
| long | **None claimed** (`long` s5.6) | **None**, and no docs either; every documentation domain is dead (`long` s1) | Co-founder `@Natan_benish`; no legal entity stated anywhere (`long` s1) | 23 of 24 (`long` s5) | **All EOAs. No multisig anywhere in Long's set** (`long` s5.5) |
| bags | **None.** No captured page mentions an audit of the Robinhood Chain contracts (`bags` s5.5) | Tooling only; contract sources are read from Blockscout (`bags` s1) | **None.** No captured page names founders or staff (`bags` s1) | 26 of 28 (`bags` s5) | **One EOA holds every privileged path.** Owns the factory proxy and **both beacons, so it can upgrade every live bonding curve and every live fee share in one transaction**; is `platformAdmin` on every curve; owns every `BagsFeeShare` and can call `setClaimers`. Mitigating: no `Upgraded` event has ever fired (`bags` s4) |
| virtuals | One, Code4rena April 2025; the README does not say it covers this deployment, and BondingV5 has been upgraded three times since (`virtuals` s1, s5.2) | Yes, 37 repos, and on-chain source matches a named commit (`virtuals` s1) | **Partially**: core contributor handles Ethermage, everythingempty, 0xkookoo (`virtuals` s1) | 50 of 63. **`FFactoryV3`'s implementation and every `FPairV2` are unverified**, and the pair bytecode changed between July and September with neither version matchable to a commit (`virtuals` s5.2) | **One EOA is owner and proxy admin** of BondingV5, BondingConfig and TaxAccountingAdapter, with no timelock or multisig, and has already upgraded three times (`virtuals` s5.2) |
| sentry | **None.** DefiLlama records zero; the GitHub org publishes only a brand kit (`sentry` s9) | **None** (`sentry` s9) | **Yes, and the most identifiable in the set.** Mavrk Inc, a Delaware corporation incorporated 2026-06-12; founder and CEO Sergio Luna, `@cruelhandeth` (`sentry` s1) | 49 of 54, and **every contract in the live launch path is verified** (`sentry` s5) | One EOA owns both v4 factories as `TransparentUpgradeableProxy`, **so the launch logic is upgradeable by one key**, and holds `setCreatorFeeBps`. Counterweight: the hooks are immutable and **the LP vault has no withdrawal function at all** (`sentry` s5) |
| flap | **None covering what runs.** CertiK and BlockSec audited other versions; Robinhood Chain runs Portal v5.21.2 and Tax Token V3, neither covered (`flap` s9 gap 7) | Not identified as first-party (`flap` s8) | **None.** The only named party is the backer, YZi Labs (`flap` s1) | Partial, and **the Portal implementation itself is unverified** (`flap` s5) | **A 2-of-5 Safe with no timelock can replace the Portal implementation that custodies every live bonding curve's reserve.** A separate 2-of-3 FeeSafe holds `DEFAULT_ADMIN_ROLE` and controls fee rates and beneficiaries, and **the two Safes share two signers, so they are not independent** (`flap` s5) |
| hood10 | **None.** No audit, no bug bounty, no legal entity, no terms of service (`hood10` s9) | **None**; the repo its own source refers to is not public (`hood10` s9) | **None.** No team member is named anywhere (`hood10` s9) | Partial, mostly verified on the launch path (`hood10` s5) | One EOA, not a Safe, no timelock. **But its only launch-path power is `setFeeRouter`.** It cannot mint, change a launched fee, pause a live pool, move liquidity, or reach the creator lane (`hood10` s3.7, s4.3) |
| hood-fun | **None.** The footer says "being audited"; the sources carry AUDIT fix comments, so a review happened, but no report or auditor is named (`hood-fun` s4.5) | **Not recorded** (`hood-fun` s9) | **None**, and the two owner Safes have six distinct signers, none labelled (`hood-fun` s9) | **34 of 38, and the whole live launch path is verified** (`hood-fun` s5.4) | **Two owner Safes with different owner sets and no overlapping signer**, where the whitepaper describes one. Both 2-of-3, no timelock over the Safe itself. **Contracts are non-upgradeable.** Migrator changes and CTOs sit behind 7-day public timelocks. Neither Safe can touch curve reserves or locked liquidity (`hood-fun` s5.2) |
| pools-trade | **None published**; DefiLlama records `audits: 0` and the header still says Beta (`pools-trade` s1, s9) | No pools.trade repo; the contracts are open Uniswap repos (`pools-trade` s1) | **Yes: Uniswap Labs, confirmed six ways, three of them on-chain** (see below) | 28 of 40, and **no unverified contract sits in the current launch path** (`pools-trade` s9 gap 5) | **Nothing.** "There is no owner, no setter and no upgrade path on the strategies, the fee splitters, the vault or the compounding recipient. None of them is a proxy." `protocolFeeController()` is the zero address (`pools-trade` s5, s4) |
| noxa | **None**; DefiLlama `audits: 0` (`noxa` s1) | **Not recorded** (`noxa` s8) | **Contested, and this is the archive's central open question** (see below) | Partial, and **the live V2 factory itself is unverified**; its ABI was reconstructed by PUSH4 scan plus keccak confirmation (`noxa` s9) | One EOA with **no timelock on the power that matters**: `setProtocolFeeShare` is global, retroactive and instant. Also `proposeCreatorReassign` (24 h), `setProtocolFeeRecipient`, a launch fee settable to **1 ETH**, and `setLaunchingEnabled`, **with V1 as proof it gets used** (`noxa` s5, s9) |

**Pools.trade's operator, settled.** Uniswap Labs, by six independent lines of evidence, three on-chain: the `deployments.json` feed generated from `Uniswap/contracts` commit `3793618` carries 42 records for chain 4663 whose addresses are exactly what the frontend pins; the verified `LBPStrategy.sol` carries `/// @custom:security-contact security@uniswap.org` and imports `@uniswap/v4-core`; and the deployer EOA `0x32f4B2e6...` deployed `ContinuousClearingAuctionFactory` at the identical address on Ethereum mainnet (`pools-trade` s2).

**Noxa's operator, unproven.** The V2 owner has no ENS under `noxa.eth`, was funded 14 minutes before deployment by an unidentified wallet, and never received anything from `dev.noxa.eth` or `treasury.noxa.eth`. The circumstantial case is strong, since it controls `noxa.fi`, the docs and the `@NoxaLaunchpad` account, but there is no on-chain link (`noxa` s9). Separately, **a competing live deployment runs under the same brand**: `noxa.io`, 171 launches, all four contracts verified, paying the creator **33.34%** instead of 100%. A creator who searches for "Noxa" and lands on the wrong domain gets a different fee split and a different owner (`noxa` s9).

**The audit column is empty across all eleven.** Not one platform has a published audit covering the code that runs on Robinhood Chain today. Doppler's two are unreadable and predate the deployment; Flap's cover other versions on other chains; Virtuals' predates three upgrades. If an audit is a gate, nothing on this chain passes it.

---

## 8. Activity

DefiLlama 30-day fees, from the single 2026-09-02 pull in `_market/README.md`, which is the only set captured on one date across all platforms.

| Platform | 24h | 7d | 30d | All time | Note |
| --- | --- | --- | --- | --- | --- |
| Pons V2 | 4,221,588 | 21,826,857 | 26,939,684 | 26,939,684 | Largest by a wide margin. The README's own caveat: V2's 24h fees exceed the whole chain's, so the adapters count different things; trust the ranking, not the absolute |
| Pons V1 | 335,884 | 2,533,267 | 8,300,755 | 23,887,250 | |
| NOXA Fun | 142,924 | 933,642 | 4,069,455 | 20,894,770 | **Cross-chain.** The adapter's chart begins 2025-11-24, before Robinhood Chain existed. Do not read as Robinhood-only. The table's "launches disabled" annotation is **wrong** and is corrected later in the same file |
| Pools | 32,451 | 260,828 | 1,514,075 | 1,546,609 | $1,596,520 on 2026-09-03, against **$0 lifetime revenue** |
| Flap sh | 9,177 | 58,950 | 179,570 | 1,077,783 | |
| Bags | 22,155 | 66,882 | 203,850 | 585,729 | |
| Sentry | 4,698 | 49,243 | 75,790 | 102,063 | The platform README records TVL only, not fees |
| Virtuals Protocol | 27,497 | 150,634 | 438,465 | 2,556,217 | AI Agents category, not Launchpad. Robinhood Chain overtook Base in August 2026 |
| **Long, Doppler, hood.fun, HOOD10** | \- | \- | \- | \- | **Absent from DefiLlama for this chain entirely.** Their activity must be read from their own archives |

Launch counts and venue health, from the archives themselves.

| Platform | Launches | Health signal |
| --- | --- | --- |
| flap | **173,798** (`flap` s7) | 0.07% to 0.21% graduate |
| doppler | 109,177 on 4663 (`doppler` s7.2) | Second-largest Doppler deployment; 0 migrations by design |
| noxa, all deployments | 61,404, of which **1,090 on the live V2** (`noxa` s7) | **10 coins launched in the last 7 days.** "A very different platform from the one that did $2.33M of fees in a single day on 2026-07-11" |
| virtuals | 25,342 pre-launched (`virtuals` s5.3) | 85 graduated |
| long | 13,802 (`long` s7.1) | ~77 launches an hour on the capture day, the most active integrator |
| hood-fun | 11,026 (`hood-fun` s5.1) | 0.21% graduate; 24h volume 1.113 ETH platform-wide, 4h volume 0 |
| bags | 4,248 in 54 days (`bags` s7) | Of the 100 newest, 11 had any bonding progress |
| pools-trade | ~44,000 launcher txs since 2026-08-05, a proxy not a count (`pools-trade` s7) | 126 auctions, 64 graduated |
| pons v1 | 2,154 archived (`pons` s7) | v2 count not recorded; launches were landing several per minute |
| sentry | 185 (`sentry` s7) | **Median lifetime volume per token 0.059 WETH.** One token, CHILL, is 83% of all platform volume |
| hood10 | **81, over three days** (`hood10` s7.1) | **75 of 81 have one trade or none.** One coin is 97% of $391K volume. No launch in the 30 hours before capture |

**Read the two columns together.** Sentry and HOOD10 have the best creator mechanisms in the set and the thinnest venues. Flap and hood.fun have enormous launch counts and the worst payouts. Volume does not follow mechanism quality on this chain, and nothing in these archives suggests a creator can rely on the venue to supply it.

---

## 9. Fit for a project with no LP budget

**Every one of the eleven satisfies the literal constraint.** None requires the creator to seed liquidity, and the most expensive launch in the set is $7.14. So the constraint does not discriminate, and the ranking in section 1 is driven by what a creator receives afterwards and who can take it away.

The README's own verdict, where it gives one:

| Platform | The archive's own words |
| --- | --- |
| sentry | "It fits this project's constraint exactly, which is having no budget to seed a pool" (`sentry` s2) |
| pons | "a direct fit for the stated goal of this archive, launching without seeding a pool" (`pons` s2) |
| doppler | "the plainest of the options on this chain: no launch fee, no graduation threshold to clear, no LP to seed" (`doppler` s2) |
| pools-trade | for "someone launching a memecoin who wants Uniswap-grade routing and distribution from block one and has no ETH to seed a pool with" (`pools-trade` s2) |
| hood10 | "Someone with no capital to seed a pool, because you seed nothing: the supply is the liquidity" (`hood10` s2) |
| virtuals | for founders who want "a token, a locked pool ... without seeding liquidity themselves" (`virtuals` s2) |
| bags | "creators who want ongoing fee income without seeding liquidity" (`bags` s2) |
| hood-fun | "It is aimed at people with no capital ... The only outlay to launch is gas" (`hood-fun` s2) |
| long | for a creator "content with 0.095% of volume as income" (`long` s2) |
| flap | **Negative.** "A non-tax launch on Flap Robinhood is a pure giveaway by the creator" (`flap` s3.7) |
| noxa | No explicit verdict. "It is aimed at memecoin creators who want zero capital outlay" (`noxa` s2) |

### Assumptions behind the section 1 ranking

Four of the five open questions in `NEXT-SESSIONS.md` are unanswered, so the ranking rests on assumptions rather than decisions. Each is stated so you can overturn it.

1. **Anonymity is priced in, not disqualifying.** Question 1. Gating on trust first would cut the field to **Pools.trade** (Uniswap Labs, confirmed on-chain) and **Sentry** (Mavrk Inc, a named Delaware corporation with a named CEO), and would rank Pools.trade first outright. Every other platform is anonymous or a bare legal entity.
2. **The token is expected to trade after launch, so ongoing creator income matters.** Question 2. If the launch itself is the deliverable and post-launch income is irrelevant, the ranking collapses to cost and lock quality, and **HOOD10** rises to the top on the strength of the strictest lock in the set, with **hood.fun** second at $1.34.
3. **Pons belongs on the shortlist.** Question 3. Nothing in any archive records a reason it was excluded, its own README calls it a direct fit, and it is the chain's fee leader by an order of magnitude. Treated here as an oversight rather than a decision, so it is ranked on merit.
4. **Noxa is included but heavily discounted.** Question 4. The unproven operator, the retroactive fee knob with no delay, the unverified live factory and the ten launches in seven days together put it at 8 despite having the best headline number in the set, 100% of fees.
5. **The trademark constraint bears on the token's name, not on the pad.** Question 5, which is new. Terms of Service sections 5.7(d) and 5.7(h) bar the Robinhood Chain Marks from a token name, domain, handle and metadata, and 5.11 puts a token name behind prior written consent. This does not change the ranking, but it can invalidate a name already chosen, so settle it before launching anywhere.

### What each of the top three costs you

**Pools.trade.** You give up the entire supply into a pool you can never withdraw from, and 60% of the ETH fee plus 100% of the token fee compounds back into that locked pool rather than being paid out. In exchange nobody, including Uniswap Labs, can alter the terms after the fact, and the claim right is a transferable NFT you hold. On a token doing $100K of buy volume a day, the creator's side is about $100 a day (`pools-trade` s4). Note the creator fee switch is **off by default**, so it must be deliberately enabled at launch.

**Sentry.** You accept a permanent 1.7% trade fee on your token in exchange for 1.00% of every trade settled inside the swap, with nothing to claim and no accrual anyone administers, plus up to 23.5% of every trade in the first seventeen minutes. The liquidity is locked even against the operator. The exposure is that one EOA can upgrade both factories, and the venue's median launch has done under 0.06 WETH of lifetime volume.

**Pons v2.** The best raw economics of the three if the creator tax is used, since the tax is entirely yours on top of the 0.70%, and it is the only one of the three with a real graduation event into a locker with no withdrawal function. The exposure is specific and unusual: the owner Safe can propose an involuntary reassignment of your fee recipient, and moving your fees during the 3-day wait does not cancel it. Also note `ponsfamily.com` redirects UK IPs to `/blocked?country=GB` (`pons` s1).

---

## 10. Platforms found but not archived

`_market/README.md` catalogs **54 distinct platforms** on this chain, of which 10 are on `launchpad-research.md` and **44 are not**.
Full catalog, mechanism descriptions and sources are there; it is the authority for this section and this is a pointer, not a copy.

Two platforms, **PAIR** and **Hookers**, appear in the DefiLlama fee table but are **absent from the catalog table entirely**, with no site, handle or mechanism recorded anywhere. ~~That is a gap in `_market`, not in this document.~~

**Corrected 2026-09-19: it is neither.** DefiLlama lists PAIR with an **empty `chains` array**, so it survives a chain fee query and is dropped by every chain-filtered catalog query; no amount of care in `_market` would have caught it. PAIR is `pair.fund`, `@pairdotfund`, live on Robinhood Chain, and is now archived in `launchpads/pair/`. Hookers is `hookersrh.com`, `@hookersrh`, and is correctly categorised; it was simply not pulled.

`_market/README.md` also contradicts itself twice on protocol counts, "143 fee-earning protocols" against "all 134 protocols", and "30 protocols in its Launchpad category" against "the 20 Launchpad-category protocols". Neither pair is reconciled.

### Recommended next archives

**All of these were archived on 2026-09-19. See `LAUNCHPADS-II.md`; the annotations below record what each one turned out to be.**

1. **StonkBrokers** - $2,542,956 in 30 days makes it the fourth-largest fee earner on the chain and by far the largest with no archive. The biggest single blind spot in the survey. **Archived, partially: seven verified contracts, but the launch factory itself is still not identified.**
2. ~~**LetsCash** - $1,613,786 in 30 days, and the catalog records no site, no X handle and no mechanism at all. Pure unknown at real scale.~~ **Wrong. LetsCash is letscash.fun, whose factory `0x5bd1Fbe7...` is the `CashCatFactory-proxy` already archived in `hood10/contracts/` and documented in `hood10/README.md` section 5.1. It was never a missing archive.**
3. **o1 Launchpad** - $463,085 in 24h against $656,777 in 30d, so most of its lifetime fees landed on the capture date. Either accelerating hard or a one-day artefact, and the answer changes the ranking.
4. **Uniswap CCA** - a **merge, not an archive**. Already documented in `resources/uniswap/liquidity/liquidity-launchpad/`, and `pools-trade/README.md` has already decoded the same `ContinuousClearingAuctionFactory`, the 13-step issuance schedule and all 126 auctions from the other side. Cheapest thing on this list to finish.
5. **Bankr** - the only catalogued pad whose fee split is described as four-way across creator, locked liquidity, protocol and buybacks, which is precisely the design question a no-LP-budget launch turns on. It is also the **largest Doppler integrator on the chain at 88,764 assets, 81% of all Doppler launches** (`long` s7.1), and it is absent from the fee table, so its economics are unknown at the largest scale on the chain.
6. **RaiseHood** - one of only two pads recorded as pairing against USDG or stock tokens rather than ETH.
7. **pools.fun** - unrelated to Pools.trade, verified `PartyFactory` at `0x626C3d09B65bF5d1D40E0D5F25e19fa49783B3D4`, 2,439 tokens on day one, a SushiSwap V3 route nothing else in the survey uses, and it is **not in `launchpad-research.md`**, so nobody owns it.

Below that: Coinbarrel, token.select, PAIR, Openfair, then Unihood and Mixpad together, since both build the same single-sided-supply design as Noxa and Pools Instant Launch and would show whether it is converging chain-wide.

**Resolved 2026-09-19.** Items 3 and 5 through 7 are archived, as are Coinbarrel, token.select, PAIR, Unihood and Mixpad. Item 4, the Uniswap CCA merge, is still open. Openfair and Hookers are still unarchived.

The closing question is answered: **the single-sided-supply design has converged.** Ten of the twenty-two platforms now use it, and all six of the newest do. The wave-two archive that matters most is **Unihood**, which reaches a stricter custody posture than anything in wave one, including Pools.trade, in 793 lines of first-party MIT Solidity.

---

## 11. What this comparison cannot tell you

Honest limits, so the table is not read as more settled than it is.

- **No platform has a published audit covering the code running on this chain.** The column is empty eleven times.
- **A like-for-like graduation rate does not exist.** Four platforms have no graduation, two have a display-only milestone, and the rates that exist are measured against different bases; Pools.trade's 52.9% and hood.fun's 0.21% are not comparable quantities.
- **Gas is recorded for only five of eleven**, and in USD for only two. Cost comparison is approximate.
- **KYC was never affirmatively checked anywhere.** Every archive records a wallet or social gate and none records a KYC requirement, but absence of a mention is not evidence of absence. The honest cell is "wallet only, no KYC recorded".
- **Long and Doppler are not independent rows.** A Long launch is a Doppler launch with a hook fee and a different front end.
- **Pons v2's own launch count and graduation rate are not recorded**; only v1's, and v1 graduation is a display metric.
- **Noxa's DefiLlama figures are cross-chain** and cannot be placed in a Robinhood-only column.
- **Two archives captured a day later than the other nine.** Where a number moved in that day, both are given.

---

## Sources

One README per platform under `launchpads/<slug>/README.md`, plus `launchpads/_market/README.md` for the catalog and the DefiLlama table.
Method and the traps that cost time are in `launchpads/PLAYBOOK.md`.
Per-archive status is part 4.4 of `SCRAPING-PLAN.md`.
