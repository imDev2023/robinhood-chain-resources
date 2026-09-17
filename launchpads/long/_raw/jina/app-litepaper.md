Title: litepaper

URL Source: https://app.long.xyz/litepaper

Published Time: Wed, 02 Sep 2026 17:48:32 GMT

Number of Pages: 5

Markdown Content:
# LongX: Tokenized Cross-Domain Leverage 

# Abstract 

LongX issues ERC-20 tokens on a settlement domain S that track a constant-leverage perpetual position held in an execution domain X . The two domains cannot transact atomically: a token mint on S and the corresponding position adjustment on X are separate, independently-ordered events. LongX resolves this with deferred atomicity — every cross-domain action is executed first and reconciled afterwards against X ’s validity-proven state roots, which are posted natively to S. The vault verifies Merkle inclusion of its own account leaf and derives net asset value on-chain, with no price oracle and no trusted reporter. Divergence between the two domains is bounded by proof staleness rather than eliminated, and every settlement is priced at a proven state. Trading authority is delegated through bonded key-leasing : an executor receives a revocable, trade-only signing key on X against a posted bond, is judged on proven end state rather than on trajectory, and is bounded by a keyless repair path that requires no cooperation. The bond is priced against non-strategic executor failure by a measured model (§7) whose inputs — venue leverage caps, maintenance margins, volatility, book depth, and replenishment — are all read directly from the venue. 

# 1. Domains         

> Ssettlement domain: token supply, mint/redeem queues, bond escrow, proof verifi-cation
> Xexecution domain: the margin account, its position and collateral vault contract on S; sole L1 owner of the Xaccount executor holder of a leased, trade-only signing key on X

The vault performs account creation, deposits, key rotation, forced reduce-only orders, and withdrawals by direct calls to the bridge. Withdrawals are circuit-bound to the vault’s own 

S-address: no key holder can redirect funds. The bridge’s priority queue obliges the sequencer to process forced orders and withdrawals; failure activates escape-hatch mode, permitting proof-based withdrawal of the account’s full value. User exit is never contingent on executor or operator cooperation. 

# 2. Tokenized leverage 

Let E be account equity, N position notional, and L = N/E effective leverage, with target λ and band [ λ, λ ]. A token represents a pro-rata claim on E. Supply S and NAV per token ν = E/S 

move only with E; issuance and redemption are ν-neutral. Mint and redemption are queued on S and settled at the NAV of the first proven state following request acceptance (§5), which removes stale-price arbitrage against existing holders. 

# 3. Rebalancing 

Over a price return r:

N ′ = N (1 + r), E′ = E + N r, L′ = L(1 + r)1 + Lr .

When L′ leaves the band the position is rebalanced by trading ∆N = λE ′ − N ′,

1restoring L = λ and leaving equity unchanged net of execution cost. Starting from L = λ, a band edge B is reached at 

r∗ = λ − Bλ(B − 1) ,

i.e. ≈ ± 5% per cycle for λ = 3, B ∈ { 2.74 , 3.35 }.

Non-liquidation. After a rebalance, equity reaches zero only on a further single-interval return 

r ≤ − 1/λ (−33 .3%); at the band maximum the distance is −1/λ ≈ − 29 .9%. A protocol stop-out closes the position above the venue’s maintenance margin, so holders bear mark-to-market loss and never socialised liquidation debt. Residual gap risk — a jump exceeding the stop-out distance within one reaction interval — is disclosed and partially absorbed by a fee-funded reserve. 

# 4. Deferred atomicity 

X posts batch commitments and validity proofs to S at a measured 60.15 s cadence. The vault verifies Merkle inclusion of its account leaf against a committed state root and derives, on-chain: • collateral balance, • signed position size in the target market, • mark price, • the position-bucket digests covering every market. 

Committed-root basis. Proofs anchor to committed roots — the operator’s validity claim — not to roots whose zk proof has already landed. This is the accepted trust delta of the design; the alternative is a settlement latency equal to full proof cadence. 

Cost-basis netting. The account trie nets a position’s entry cost out of the collateral balance, so true equity is the balance plus signed position value. NAV follows directly, with no oracle. 

Single-market attestation. The leaf commits to sixteen position buckets. A proof supplies openings for the target bucket and digests for the rest, and rejects any non-zero size in a sibling slot of the opened bucket. A successful proof therefore attests that the account’s only position is in the target market, at no extra verification cost. Positions in other buckets are cleared by supplying their openings and requiring all sizes zero; a residual funding prefix-sum keeps a once-used bucket permanently flagged, so the clearing is attached to every subsequent proof rather than healed. 

Anchor lag. No proof attests state younger than its anchor. Every proof-gated decision therefore acts on information up to ∆ old — 1–2 batches on the action paths, up to 15 on accountability and repair paths. This is structural: it bounds what can be prevented , as distinct from what can be punished .

# 5. Divergence synchronicity 

Between proofs, the token’s recorded NAV on S and the account’s true state on X diverge. The protocol bounds rather than eliminates this. 

Settlement. Every mint and redeem prices at a proven state. Instant mints are quoted against the last proven NAV plus a spread covering the divergence over the quote’s validity window; queued mints settle at the next proof. Every unit of value is counted or proven, never both and never neither. 

Attribution. Two anchored equity proofs bracket any lease. Each is stale by up to ∆, so the resulting measurement of loss is unbiased with standard deviation of order Λ V σ √∆ — priced explicitly in §7 rather than assumed away. 2Repair. A keyless, permissionless rebalance restores the band using only a proof and the bridge’s forced-order path. It is available whether or not a lease is active and requires no executor cooperation. 

# 6. Bonded key-leasing 

Trading authority is leased, not assigned. States: Parked → AcquirePending → Leased →

ReleasePending , with a park key K∅ — a canonical-form public key with no known private key, used because the bridge rejects zero keys. 

Acquire. A caller submits a fresh proof establishing L / ∈ band, posts bond B, and supplies their X public key. The vault escrows the bond and rotates the key through the bridge. The grace clock starts at inclusion of the priority request, not at bond posting: the executor does not control sequencer latency. 

Execute. Fills, routing and timing are unconstrained. Only end state is judged. 

Release. The executor proves the account at a later state. Order cancellation and key parking are enqueued together; the key stops signing at L1 inclusion + ≈ 1.4 s. 

Accountability. Because release is gated on a proof that is up to ∆ stale, release attests accounting, not safety. A post-release challenge window allows any party to prove the terminal state was out of band and bar the lessee; a supplied terminal proof can never leave a lessee better off than supplying none. Foreign positions are separately challengeable and permissionlessly force-closable. 

Recovery. The claim is the equity shortfall against the benchmark path — the equity a mandated 

λ-exposure would have had over the same interval, evaluated between the two anchored proofs using the marks those proofs carry. No external price oracle is required. 

# 7. Bond model 

The bond is priced against non-strategic executor failure : a buggy or abandoned executor, not an adversary holding positions whose value depends on vault state. It indemnifies equity destruction in excess of the mandated exposure; failure to deliver that exposure is not indemnified. 

7.1 Assumptions 

• S1 the executor holds no position whose value depends on vault state, and does not optimise over its own detection, inclusion or repair latency; • S2 market m absorbs at most Dm of notional per side and makers restore at most Rm per unit time, so traded notional over τ is bounded by 2 Dm + Rmτ regardless of submission rate; • S2 ′ liquidation executes at the barrier within penalty ρ, with no gap exceeding rliq ;• S3 mmΛm < 1 and ρm ≤ mm for every reachable market; • S4 over τ the traded return is a driftless Brownian motion rt = σZ t;• S5 gas and fixed recovery costs are negligible against the bond. 

7.2 Failure modes and exposure window                       

> #mode effect
> 1leverage misconfiguration exposure up to Λ 2direction inversion exposure −λto −Λ3size miscomputation effective leverage ̸=λ
> 4abandonment mid-operation position held, unrevoked, for τ
> 5looping submission friction, bounded by S2 6off-target market position in a market ̸=M

3# mode effect   

> 7inaction when a rebalance is due exposure drifts past the band edge

The conditioning event is F = (1 ∪ 2 ∪ 3 ∪ 7) ∩ 4: a mis-exposure persisting for the window. Modes 5 and 6 are modifiers — 6 selects the market, 5 the friction regime. 

τ = Td + Tincl + W + Tr.

Market selection. No per-key market restriction exists on the venue, so mode 6 places the position outside M . Parameters are those of arg max m CVaR α(Lm) over reachable markets — not arg max m Λmσm, which is monotone increasing in Λ m while the liquidation cap is monotone decreasing in it, and which cannot see mm or ρm.

7.3 Loss 

With the short-side barrier rliq = (1 /Λ − m)/(1 + m), exactly one branch applies per path: 

L =

> 

V [1 − Λ(1 + rliq )( m − ρ)] − L λ max t≤τ (−rt) ≥ rliq 

ΛV (−rτ )+ − L λ otherwise, floored at zero, where Lλ = λV (−rMτ )+ is the mandated-exposure loss. The notional at the barrier is Λ V (1 + rliq ) — a short’s notional grows into an adverse move — and at ρ = 0 the branches agree at the barrier. Under S3, L ≤ V .Friction is bounded by both constraints, the smaller governing: 

Lfric = min 

> (

1 − e−κτ , (2 D+Rτ )( δ+f ) 

> V

, 1

> )

, κ = Λ( δ + f )

teff 

.

The rate term alone permits turning over many multiples of the visible book per unit time, for which no counterparty exists. 

7.4 Bond 

B = CVaR α

> (

L + ε | F ) + fr,

with the claim-attribution error ε inside the risk measure: the bond covers the loss and the shortfall of the estimate used to claim it. Under S4, with the liquidation branch immaterial, 

B − fr

V ≃ Λ σ ψ (α)√τ + 2∆ , ψ(α) = φ(zα)1 − α

Loss and attribution error are disjoint increments of one process and combine in quadrature, both carrying ψ(α) since B is a CVaR throughout. 

Validity requires the liquidation branch to contribute negligibly to the tail — a loss-weighted condition, 2Φ( −a) · L liq ≪ (1 − α)Λ V σψ (α)√τ with a = rliq /(σ√τ ) — not a bare probability one. 

Sensitivities. B ∝ σ; B ∝ √τ + 2∆; B ∝ Λ only while the closed form is valid. Design controls are the venue leverage cap and the set of reachable markets, then τ and ∆. The rebalance band enters only through mode 7. 

7.5 Result 

At α = 0 .99, τ = 120 s, ∆ = 90 s, over 38 markets: 

B/V = 6 .46% [95% CI 6 .43–6 .50] ,

4on the selected market (ETH), against 1 .57% if sized on the target market alone — venue-wide selection is 4 .1× the target-only bond. Simulation reproduces the closed form to +0 .1% across all markets, and the liquidation branch is immaterial at these parameters (barrier 25 .8σ). Friction is liquidity-bound at 1 .2–6 .0% of V , below the directional term; a rate-only model overstates it by 20–40 ×.

# Appendix A. Instantiation 

Batch cadence is 60.15 s (median; p05 59.3, p95 62.9), measured by sampling L1 block timestamps across 10,001 batches. Block time is 100 ms. Any figure below quoted in batches converts at this rate. 

Symbol Measured value 

batch cadence 60.15 s median; block time 100 ms ∆ non-uniform: 1–2 batches = 60–120 s on the action paths; up to 15 batches on accountability and repair paths 

W inclusion + ≈ 1.4 s 

Td 1–2 batches for position state; resting and trigger orders are not observable in the position proof Λm 40 markets; max 50 (ETH, BTC, SPY, QQQ); target market 20 

mm, ρ m Λmmm = 0 .6 uniformly ; ρm = 0 .01 venue-wide 

σm 38 markets, robust (MAD) estimator over 10,001 batches; 2 excluded as inactive 

δ 1–5 bp at realistic size, from live book walks; grows with notional 

f 0 — taker and maker fees are zero venue-wide arg max m CVaR α(Lm) ETH ; runner-up SOXL, 14 % below 

S2 (liquidity) depth caps $200k ETH ·NVDA, $500k BTC, $1k CASHCAT; replenish $682/s ETH, $23/s NVDA 

S2’ (gaps) gap rates and p99 magnitudes measured per market 

S3 (ρ ≤ m, mΛ < 1) HOLDS venue-wide; tightest at BTC ( m − ρ = +0 .002) friction S2 binds before the rate bound throughout: capped at 1.2–6.0 % of V

5

Links/Buttons:
This page does not seem to contain any buttons/links.
