# Sentry - Quotrons, Docs

> Source: https://www.quotrons.cash/docs
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/quotrons-docs.md`

---

## Current V2 Status[#](https://www.quotrons.cash/docs#v2-status "Copy link to this section")

DEPLOYED

Separate V2 collection

VERIFYING

Zero-action distribution

VERIFYING

Metadata freeze

VERIFYING

Canonical market

These states are read from the production contracts every 30 seconds, not hardcoded. The collection and snapshot distribution can be live while trading remains staged; trading opens only after liquidity is seeded and the one-way onchain launch transaction succeeds. Metadata becomes immutable when the launch transaction freezes its base URIs.

## The Short Version[#](https://www.quotrons.cash/docs#short-version "Copy link to this section")

$QUOTRON is a token with only 4,444 units in existence, trading through one canonical QUOTRON/WETH pool. Hold a whole liquid token and a **dark terminal** appears in your wallet, assigned to one of ten stock-reward tracks. Sell below a whole token and the dark terminal dissolves back into circulation.

Burn the token backing a terminal and it is **hardwired**: permanent, irreversible, and earning its assigned tokenized-stock rewards from that moment on. The token supply shrinks with every hardwire; the fee stream it earns from does not.

Every buy and sell pays a permanent 3% fee, enforced by the token itself rather than by this website. 2% of volume flows to hardwired terminals as stock, 0.6375% compounds the locked liquidity, 0.2125% buys and burns $STONKBROKER, and 0.15% pays the creator.

That is the whole system: a gacha for flippers, a one-way commitment for holders, and a fee engine that cannot be routed around feeding the committed. Every section below expands one of those claims and links the contract that makes it true.

## Glossary[#](https://www.quotrons.cash/docs#glossary "Copy link to this section")

The vocabulary is proprietary on purpose — the machines are real, the states are not standard ERC-721 states. Every term used on this page:

All terms

Dark terminal A terminal backed by 1.0 liquid $QUOTRON. It trades with the token, can dissolve, can reroll, and earns nothing.
Hardwired (lit) terminal A terminal whose backing token has been burned. Permanent, freely transferable as a plain NFT, and the only state that earns reflections. The screen lights up and animates.
Materialize What happens when your liquid balance crosses up through a whole unit: a terminal is drawn from the unclaimed pool and appears in your wallet.
Dissolve What happens when your balance drops below a whole unit: your most recently received dark terminal returns to the pool.
Reroll Dissolving and rematerializing draws a different random ID. Selling below a whole token and buying back is the gacha loop.
Floor / track One of ten groups of 444 terminals, each assigned a single reward stock (NVDA, AAPL, TSLA, GME, SPCX, SPY, PLTR, NFLX, RDDT, MSTR).
Tier Machine model rarity: T1 (1.0x), T2 (1.5x), T3 (2.5x), T4 (5.0x) reflection weight.
Relic One of four unique pre-screen machines (ids 4441–4444) with their own reward streams instead of a floor assignment.
Reflections The 2% of trading volume that accrues to hardwired terminals, paid in each floor's tokenized stock.
Epoch One batch conversion of queued WETH fees into the ten reward stocks through the sealed converter routes.
Poke A permissionless call that re-prices a terminal's Broker boost from live balances. Anyone can poke any hardwired id.
Boost 1.25x reflection weight on every standard terminal you hardwired while your wallet holds at least one STONK BROKER.
Canonical router The only contract that can move $QUOTRON into the PoolManager. Immutable, ETH-native on both sides.
Hook The Uniswap v4 contract attached to the QUOTRON/WETH pool. It takes the fee on the WETH side and authorizes each swap's settlement.
Keeper The operational address that runs conversions, epochs, and pot sweeps. Disclosed and rate-limited by contract rules.

## V1 Retirement And V2 Distribution[#](https://www.quotrons.cash/docs#v1-retirement "Copy link to this section")

V2 is a separate contract stack and a separate OpenSea collection. It does not replace, mutate, or reuse the retired V1 mirror. The reviewed V2 ledger was distributed directly to eligible wallets; holders did not need to claim or sign a migration transaction.

What happened, and what was preserved

V1 was paused after an approvals-related incident on the V1 mirror: an ERC-721 approval could survive a burn and rematerialization cycle. V2's mirror clears each token's individual approval on every ownership or state change — including hardwiring — so that class of bug is closed by construction, not by policy.

V1 generated **$113,850** in tokenized-stock rewards for hardwired holders before retirement. The exact archived value is $113,849.84, calculated from the final onchain fee pots at the frozen V1 accounting marks — not today's market prices. [Audit the calculation.](https://www.quotrons.cash/migration/v1-historical-rewards.json)

*   Eligible hardwired terminals kept their exact IDs and lit state. This is what the V2 pool's inverse index exists for: specific IDs can be pulled from the unclaimed pool, so a V1 hardwire migrated to the same machine, not a lookalike.
*   Eligible liquid allocations were rerolled under the published plan, and reviewed restitution allocations were included.
*   Purchases after the applicable cutoff created no V2 entitlement — on OpenSea, in unofficial external pools, or anywhere else. The cutoffs are documented below.
*   Finalization required the committed distribution cap to be fully delivered and the migration reserve to hold zero QUOTRON.

Distribution finalization permanently closed every remaining claim, assignment, handoff, fractional, and restitution path. The V1 Migration Record is read-only except for tools that help users revoke unsafe legacy operator approvals.

The two snapshot cutoffs

Two cutoff blocks governed V2 eligibility. Both are committed in the published [migration manifest](https://www.quotrons.cash/migration/manifest.json) and documented in the [public post-mortem record](https://github.com/mavrkofficial/quotrons-v1-post-mortem):

*   **Halt block 34,984,482** — August 12, 2026, 8:09:32 PM CT, the block where trading was halted on-chain. Dark terminal ownership, liquid and fractional QUOTRON balances, and the set of terminals eligible for lit copies froze here. Terminals unminted at this block had no allocation to copy.
*   **Hardwired ownership block 35,337,540** — August 13, 2026, 6:00 AM CT, the announced stop-trading deadline. Only for the 2,001 terminals already hardwired at the halt block: their lit V2 copies followed V1 NFT ownership through this later block. This cutoff never applied to dark terminals.

Purchases, sales, and transfers after the applicable cutoff created no V2 entitlement — on any venue, including OpenSea and unofficial external pools. Each V2 copy went to the wallet holding the asset at its cutoff block; in a post-cutoff sale that is the seller, not the buyer.

## The Machines[#](https://www.quotrons.cash/docs#machines "Copy link to this section")

Every terminal is a real machine from the history of stock quotation, drawn as 8-bit pixel art. Rarer machines carry more reflection weight.

| Tier | Machine | Supply | Weight |
| --- | --- | --- | --- |
| T1 | Quotron I Keypad (1960) | 2,450 | 1.0x |
| T2 | Quotron II Desk Unit (1962) | 1,330 | 1.5x |
| T3 | Quotron 800 (1970s) | 530 | 2.5x |
| T4 | NASDANK Terminal (1971) | 130 | 5.0x |
| Relic | The Semaphore (1814) | 1 | 0.083% of all volume |
| Relic | The Universal Ticker (1871) | 1 | 0.083% of all volume |
| Relic | The Trans-Lux (1923) | 1 | 0.083% of all volume |
| Relic | The Gold Indicator (1867) | 1 | 0.10% of all volume, paid as all ten tokenized stocks |

The history behind the models
The 1960 Quotron I had no screen at all: you typed a ticker on the keypad and the answer printed on a paper slip, because electronics that could form characters were too expensive. The Quotron 800 brought the CRT. The 1971 NASDANK terminal, fed by twin Univac 1108 mainframes over 20,000 miles of leased line, was the first time a dealer could see the whole market's quotes on one screen. The four Relics predate screens entirely.

## The Reroll[#](https://www.quotrons.cash/docs#reroll "Copy link to this section")

Dark terminals are not stable assignments — they are draws. When your liquid balance crosses down through a whole unit, your most recently received dark terminal dissolves back into the unclaimed pool. When it crosses back up, a **new terminal is drawn at random** from whatever the pool currently holds. Sell 0.1 $QUOTRON and buy it back, and you are holding a different machine.

This is the gacha half of the protocol. A T1 draw can be rerolled for another shot at a T4 by cycling through the pool, at the cost of the 3% fee each way plus price impact. The odds are exactly the pool's live composition — and the pool is public state, so the odds are checkable at any moment.

How the draw works onchain

The pool is a lazy Fisher–Yates shuffle over the unclaimed IDs. A slot whose stored value is zero implicitly holds slot + 1, so the 4,444-entry pool costs no storage until touched. Draws index into it with a hash of the previous block's randomness, the timestamp, the recipient, and a nonce:

SOLIDITY Quotron404V2 — the draw

```
function _draw(address account) internal returns (uint256 id) {
    uint256 position = uint256(
        keccak256(abi.encodePacked(
            block.prevrandao, block.timestamp,
            block.number, account, ++_drawNonce
        ))
    ) % poolSize;
    id = _slotValue(position);
    _removePoolPosition(position, id);
}
```

This is pseudorandomness, and we describe it as such: it is drawn from block state, not from an oracle. It is unpredictable enough for a gacha whose prizes share one fee stream, and every draw is publicly auditable after the fact. It is not a commitment-scheme lottery and does not claim to be.

Dissolution is last-in, first-out: _syncDown pops the most recent dark terminal first. If you hold three terminals and sell one token's worth, the newest of the three dissolves — the two older draws stay put.

NOTE

Every hardwire removes an ID from this pool **permanently**. The reroll pool only ever shrinks. As holders commit, the remaining draw odds concentrate on whatever is left — the flipper's game and the holder's game consume each other by design. See [The 4,444 Invariant](https://www.quotrons.cash/docs#invariant).

## The 10 Reward Stocks[#](https://www.quotrons.cash/docs#reward-stocks "Copy link to this section")

Each standard terminal has one assigned reward stock. Every track holds exactly 444 machines with an identical tier mix (245 / 133 / 53 / 13), and each receives an equal WETH epoch budget. Per-terminal outcomes vary with conversion execution, live reward weight, and how many terminals on that track are hardwired.

NVDA

444 machines

AAPL

444 machines

TSLA

444 machines

GME

444 machines

SPCX

444 machines

SPY

444 machines

PLTR

444 machines

NFLX

444 machines

RDDT

444 machines

MSTR

444 machines

NOTE

Fewer hardwired terminals on a track means a larger share of that track's stock per terminal. A fully-lit track splits its 82.5% among 444 machines; a track with ten lit machines splits the same inflow ten ways.

## Reward Epochs[#](https://www.quotrons.cash/docs#reward-epochs "Copy link to this section")

Trading fees are taken in WETH and queue in the hook's reflection pot. A dedicated executor converts them to the ten reward stocks in **epochs**: an epoch can open only when at least 0.1 WETH is queued, is capped at 100 WETH, and at least 60 seconds must pass between openings. The opened budget is split equally across the ten sealed stock routes.

Where each converted dollar lands

*   Each track sends **82.5%** of its converted stock to ordinary hardwired terminals by live reward weight.
*   **12.5%** is split equally among the three basket relics.
*   **5%** accrues to the Gold Indicator, which receives all ten tokenized stocks directly.

The converter can send stock only to the V2 reflections contract — the destination is immutable. V2 has no fresh PAXG conversion route, and the zero-action distribution did not move accrued V1 rewards into V2. Pending V2 rewards stay attached to a hardwired terminal ID when that NFT transfers.

The Machine's Record is the live sum of V1 and V2 rewards generated. V1 starts from the retirement archive and adds later stock-reward notifications at current stock marks. V2 adds every reward-pot pull to the live WETH queue at the current ETH/USD mark, and separately shows how much has already been converted and allocated to hardwired terminals.

## Where Every Dollar Goes[#](https://www.quotrons.cash/docs#fee-split "Copy link to this section")

The permanent base fee is 3% of WETH-side volume, taken by the hook inside the swap itself — the pool's own LP fee is forced to zero and the protocol fee replaces it. The carve is fixed in the fee library as parts per 240:

| Stream | Of the 3% fee | Of volume |
| --- | --- | --- |
| Stock rewards for hardwired terminals and relics | 66.6667% | 2.0000% |
| LP reinvest, permanently locked | 21.25% | 0.6375% |
| $STONKBROKER buyback and burn | 7.0833% | 0.2125% |
| Creator | 5% | 0.15% |

The carve, from source

SOLIDITY QuotronV2FeeLib — parts per 240

```
uint256 internal constant FLOOR_FEE_BPS = 300;   // 3%

// At the 3% floor these equal:
// 2.0000% reflections, 0.2125% STONKBROKER burn,
// 0.6375% locked LP, and 0.1500% creator.
uint256 internal constant REFLECT_PARTS = 160;
uint256 internal constant BURN_PARTS    = 17;
uint256 internal constant CREATOR_PARTS = 12;
uint256 internal constant TOTAL_PARTS   = 240;
// LP takes the remainder: 240 - 160 - 17 - 12 = 51 parts
```

The three retained streams accumulate in destination-locked pots on the hook: only the reflections sink can pull the reflections pot, only the burn vault can pull the burn pot, only the LP vault can pull the LP pot. The creator's share is taken directly inside each swap with no custody step. There is no arbitrary sweep function.

The historical launch phase
Launch-fee finalization has executed, so every wallet now uses the permanent 3% base fee. During the historical launch phase, the keeper and published eligible wallets paid 3% while other wallets paid 90%; an account that actually paid 90% remained marked for one hour, and its transfers were restricted for the duration of the mark. Always read currentFeeBps for the actual payer before signing.

FEE

This is a **swap fee, not a transfer tax**. Wallet-to-wallet $QUOTRON transfers and NFT transfers pay nothing. The 3% applies only when the trade settles against the canonical pool.

## The Routing Lock[#](https://www.quotrons.cash/docs#routing "Copy link to this section")

The supported V2 market is one registered QUOTRON/WETH Uniswap v4 pool reached through the immutable canonical router. What makes that claim unusual is **where it is enforced: in the token**. Most protocols enforce a fee in their pool and hope volume stays there. $QUOTRON refuses to settle anywhere else.

The problem this solves: every Uniswap v4 pool — ours or a rogue one — settles through the same PoolManager singleton contract. An address allowlist cannot tell our pool from a copycat pool, because both settle at the same address. So the token treats the PoolManager as **locked by default**, and our hook unlocks it one swap at a time.

How the per-swap authorization works

During each swap through the registered pool, the hook writes a settlement allowance into the token — bound to the exact direction and amount of that swap, stored in transient storage so it cannot outlive the transaction:

SOLIDITY QuotronWethHook — grants during the swap

```
// afterSwap: authorize exactly this swap's QUOTRON movement
int128 quotronDelta = wethIsCurrency0
    ? delta.amount1()
    : delta.amount0();
quotron.authorizePoolTransfer(quotronDelta);
```

SOLIDITY Quotron404V2 — checks on settlement

```
if (from == manager) {
    // QUOTRON leaving the pool: must be authorized, at least
    // this amount, in this same transaction (tload/tstore)
    uint256 authorized = _transientLoad(PM_SEND_AUTHORIZATION_SLOT);
    if (amount > authorized) revert UnauthorizedPoolSettlement();
    _transientStore(PM_SEND_AUTHORIZATION_SLOT, authorized - amount);
} else if (to == manager) {
    // QUOTRON entering the pool: only the canonical router
    if (msg.sender != canonicalRouter) revert NotRouter();
    uint256 authorized = _transientLoad(PM_RECEIVE_AUTHORIZATION_SLOT);
    if (amount > authorized) revert UnauthorizedPoolSettlement();
    _transientStore(PM_RECEIVE_AUTHORIZATION_SLOT, authorized - amount);
}
```

A rogue v4 pool's swaps run without our hook, so no authorization is ever written, so the settlement reverts. It cannot trade $QUOTRON — and because seeding a pool is itself a transfer to the PoolManager, **it cannot even be seeded**. After each swap, the router asserts that every authorization was fully consumed, which closes the ERC-6909 claim-settlement path where permissions might otherwise be banked for later use.

What the lock does not cover

*   A v2- or v3-style pair never touches the PoolManager, so the lock cannot see it. Known non-v4 venue archetypes are refused by runtime codehash instead — an owner action that can only target contract code, never a person: EOA codehashes are unbannable by construction, so wallet-to-wallet transfers can never be blocked.
*   The codehash ban is reactive. A novel AMM contract would work until identified and banned. In practice, meaningful off-route liquidity is hard to bootstrap and arbitrage returns volume to the deep canonical pool — but that is an economic tendency, not a contract guarantee, and we state it as such.
*   Ordinary ERC-20 and NFT transfers remain possible, always. The lock constrains pools, not people.

The canonical router records its caller as the payer and names the output recipient separately. Contract integrations must account for that distinction: the caller's fee tier applies, and sells pull QUOTRON from the caller.

## Hardwiring[#](https://www.quotrons.cash/docs#hardwiring "Copy link to this section")

Dark terminals are liquid: they trade, they reroll, they earn nothing. Hardwiring burns the single $QUOTRON backing a terminal you own. In exchange the terminal becomes a permanent NFT that can never dissolve, its screen lights up and animates, and it starts earning its assigned reward stock. This is one-way. There is no function in any deployed contract that un-hardwires a terminal.

ONE-WAY

This is not staking and it is not a lock-up. There is no position to unwind and nothing held in escrow. The burned token leaves totalSupply permanently — whether or not the protocol ever earns another cent.

How to hardwire, step by step

*   **1.** Hold the dark terminal you want to commit. Its backing 1.0 $QUOTRON must be in the same wallet.
*   **2.** On the Machines page, select the terminal and hit **HARDWIRE** — or call hardwire(id) on the token contract directly from any wallet UI.
*   **3.** The transaction burns 1.0 $QUOTRON, emits Hardwired(id, owner), clears any outstanding ERC-721 approval on the id, and registers the terminal with the reflections engine at the current accumulator mark.
*   **4.** Rewards accrue from that mark forward. Check them any time with pending(id); claim with claim([id]) from the owning wallet.

SOLIDITY Quotron404V2 — the one-way door

```
function hardwire(uint256 id) external {
    if (_ownerOf[id] != msg.sender) revert NotTerminalOwner();
    if (isHardwired[id]) revert AlreadyHardwired();
    if (balanceOf[msg.sender] < UNIT) revert InsufficientBalance();

    balanceOf[msg.sender] -= UNIT;
    totalSupply -= UNIT;                    // real supply reduction
    emit Transfer(msg.sender, address(0), UNIT);

    _removeDark(msg.sender, id);            // leaves token accounting
    isHardwired[id] = true;                 // never unset, anywhere
    totalHardwired += 1;

    mirror.clearApproval(msg.sender, id);   // V1's missing invariant
    emit Hardwired(id, msg.sender);
    reflections.onHardwire(id, msg.sender);
}
```

RACE

Each track's reflections accrue from the moment trading begins. Until a track has its first hardwired terminal, its 82.5% share collects in a pot — and the **first terminal hardwired on that track claims the entire pot**. Ten tracks, ten pots, ten races.

Boost, poke, and claiming

A standard terminal's weight is its tier base (100 / 150 / 250 / 500) times a 1.25x boost while the owner's wallet holds at least one STONK BROKER, read live from the Broker contract. The boost is checkpointed at hardwire, transfer, and claim — and anyone can call poke(id) to re-price a stale boost at any time. Sell your Broker and expect to be poked.

Pending rewards travel with a hardwired terminal when its NFT moves, but a seller may claim immediately before a sale; buyers should re-check pending balances at execution time. V2 clears each token's individual ERC-721 approval whenever ownership or approval domain changes, including hardwiring. Wallet-wide operator approvals remain explicit choices controlled by the wallet owner.

TYPESCRIPT Read pending rewards, then claim

```
// pending(id) -> [amount, stockToken] in the floor's stock
const [amount, stock] = await client.readContract({
  address: REFLECTIONS,
  abi: reflectionsAbi,
  functionName: "pending",
  args: [terminalId],
});

// claim() pays every id in the list to its owner (must be caller)
await wallet.writeContract({
  address: REFLECTIONS,
  abi: reflectionsAbi,
  functionName: "claim",
  args: [[terminalId]],
});
```

## The 4,444 Invariant[#](https://www.quotrons.cash/docs#invariant "Copy link to this section")

Hardwiring is usually described as deflationary. That is true of the liquid token — totalSupply genuinely falls with every burn — but it misses the more precise mechanic. The token contract tracks it in one line:

SOLIDITY Quotron404V2 — the invariant

```
/// Liquid tokens plus hardwired terminals: always 4,444.
function economicUnits() external view returns (uint256) {
    return totalSupply + totalHardwired * UNIT;
}
```

Every unit is always in exactly one of two states: liquid (a token, tradable, rerolling) or hardwired (an NFT, permanent, earning). Hardwiring does not destroy value — it moves a unit out of the tradable float into a permanent claim on that same float's trading activity. The claim survives; only the liquidity disappears.

What this does to the system over time

*   **The float shrinks.** Every hardwire removes 1.0 from tradable supply forever, so the same buy pressure moves price further.
*   **The reroll pool shrinks.** The hardwired ID can never be drawn again, so gacha odds concentrate on the remaining dark supply.
*   **The claimant set grows.** Each hardwire adds a permanent earner, so per-terminal yield dilutes as commitment rises. Hardwiring is most attractive early on each track and self-limits as tracks fill — an equilibrium, not a flywheel that runs away.

Said plainly: the fee stream is generated by the liquid float and consumed by the hardwired set, and every hardwire moves one unit from the generating side to the consuming side. That tension is the design.

## The STONK BROKERS Alliance[#](https://www.quotrons.cash/docs#alliance "Copy link to this section")

QUOTRONS is built to sit alongside the StonkBrokers ecosystem, not compete with it. Brokers stared at Quotrons for thirty years.

*   **Permanent boost:** hold a STONK BROKER and every standard terminal you have hardwired earns a 1.25x weight, read live from the Broker contract at [0x53…AbF0](https://robinhoodchain.blockscout.com/address/0x539CdD042c2f3d93EbC5BE7DfFf0c79F3B4fAbF0 "0x539CdD042c2f3d93EbC5BE7DfFf0c79F3B4fAbF0"). Sell the Broker and anyone can call poke() to re-price you back down.
*   **Perpetual tribute:** at the 3% base fee, 0.2125% of volume buys and burns $STONKBROKER, forever.
*   **Historical launch phase:** STONK BROKER holders, the keeper, and published eligible wallets used the 3% base rate while the public rate was 90%. That phase ended through irreversible finalization; every wallet now pays 3%.

## Security Controls And Trust Assumptions[#](https://www.quotrons.cash/docs#security "Copy link to this section")

V2 adds explicit emergency powers in response to the V1 incident. These controls are disclosed trust assumptions, not claims of full decentralization — we would rather you read them here than discover them in the source.

*   The owner can pause the token and fee hook, ban or unban non-EOA venue codehashes, and irreversibly finalize the public fee at 3% (this has executed).
*   The blacklist guardian can freeze an address but cannot remove a freeze. The recovery administrator can add or remove freezes.
*   The recovery administrator is an onchain Safe whose threshold must remain at least two — the token checks getThreshold() >= 2 before every recovery action. It can forcibly move V2 QUOTRON balances or terminal NFTs between non-protocol accounts.
*   Core protocol accounts are excluded from arbitrary recovery, and every blacklist or recovery action emits an onchain event.
*   Metadata base URIs and the ERC721-C transfer validator are immutable once launched: setTransferValidator reverts after launch by construction.

Blacklist guardian: [0x71…7866](https://robinhoodchain.blockscout.com/address/0x7171E64E979265aeD6588577D1c6b60A701d7866 "0x7171E64E979265aeD6588577D1c6b60A701d7866")

Recovery Safe (2-of-N threshold minimum): [0x15…bA89](https://robinhoodchain.blockscout.com/address/0x15277aA1ecC13734d57C519a2DAA1cc4A748bA89 "0x15277aA1ecC13734d57C519a2DAA1cc4A748bA89")

Keeper dependencies, stated plainly
Two hops in the reward path are keeper-initiated: converting queued WETH into the ten stocks, and pulling marketplace royalties through the royalty converter. If the keeper stops, fees continue to accrue safely in destination-locked pots — nothing is stealable, because each pot can only be pulled by its sealed sink — but nothing pays out until the keeper resumes. Trustless destinations, trusted initiation.

## NFT Transfers And Creator Earnings[#](https://www.quotrons.cash/docs#transfers "Copy link to this section")

The V2 mirror is a separate ERC-721 collection using ERC721-C transfer validation. Compatible marketplace sales enforce a 5% creator earning: 4% to the keeper and 1% to the creator through the royalty splitter. This is separate from the creator's 0.15% share of canonical QUOTRON/WETH volume.

What ERC721-C actually enforces

Most collections advertising royalties mean ERC-2981, which is advisory: royalty-optional marketplaces simply ignore it. The V2 mirror implements the CreatorToken interface and calls a transfer validator on every transferFrom. The validator enforces by **venue restriction**: a transfer initiated by a non-allowlisted operator reverts, so a terminal cannot be listed on a marketplace that strips royalties at all.

Two precise limits. Wallet-to-wallet transfers you initiate yourself always pass — the validator gates operators, not owners. And marketplace compatibility is venue-specific: a venue that does not support the configured transfer validator may reject the transfer entirely. Buyers and sellers should verify the exact consideration split before signing.

SOLIDITY QuotronMirrorV2 — frozen at launch

```
function setTransferValidator(address validator) external {
    if (msg.sender != base.owner()) revert NotOwner();
    if (base.isLaunched()) revert TransferValidatorFrozen();
    ...
}
```

*   Royalty splitter: [0xd8…01d7](https://robinhoodchain.blockscout.com/address/0xd8eb805e96B05cb412A1e48eb3a85B6267f901d7 "0xd8eb805e96B05cb412A1e48eb3a85B6267f901d7")
*   Transfer validator: [0xA0…0000](https://robinhoodchain.blockscout.com/address/0xA000027A9B2802E1ddf7000061001e5c005A0000 "0xA000027A9B2802E1ddf7000061001e5c005A0000")
*   Keeper: [0xd1…9e58](https://robinhoodchain.blockscout.com/address/0xd1dE50B724de2e243D3f6f3C3ef1806BABD39e58 "0xd1dE50B724de2e243D3f6f3C3ef1806BABD39e58")
*   Creator: [0x71…7866](https://robinhoodchain.blockscout.com/address/0x7171E64E979265aeD6588577D1c6b60A701d7866 "0x7171E64E979265aeD6588577D1c6b60A701d7866")

Royalties arriving at the splitter release permissionlessly in the immutable 80/20 proportion — anyone can call releaseToken. The keeper's share funds the reward engine's royalty path: USDG is converted through sealed routes whose only possible destination is the royalty reflections contract, then claimed by hardwired terminals exactly like trading-fee rewards.

## Verify It Yourself[#](https://www.quotrons.cash/docs#verify "Copy link to this section")

Which machine each id is, which reward stock it earns, and its art were all fixed before launch and committed onchain. Nothing can be reassigned after the fact.

*   Assignment seed: **44440707**, hashed into the token contract at deploy as assignmentHash
*   Dark art: ipfs://bafybeibxh5bcdw353ufuprmzyzmk4wwtptjkym7em6igmmwp4izzoxrjym
*   Hardwired art: ipfs://bafybeicmrosixas4ry3mp6afuevniqbqzq72to2n65ys5umuqqzijzsmsm
*   Dark metadata: ipfs://bafybeig447r5kqu34u2qm5aklrvgk5igor6qe6o7ng6wmuj2vet3idiwhe
*   Hardwired metadata: ipfs://bafybeigl2vkhz4pwib27k6l6g5nqsvp5i6zgnhogc27csap3cltlvvx5mi

Reproduce the commitment

The full generator, specs, and the on-chain liquidity audit that chose the 10 reward stocks are published in the project repository. Re-run the generator with the seed above and you will reproduce this exact collection, byte for byte. Then hash the assignment file and compare against the chain:

SHELL Check the assignment hash

```
# sha256 of the committed assignment file
sha256sum assignment.csv

# what the token was deployed with
cast call 0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F "assignmentHash()(bytes32)" \
  --rpc-url https://rpc.robinhoodchain.com
```

## Live Contracts[#](https://www.quotrons.cash/docs#contracts "Copy link to this section")

V2 is deployed on Robinhood Chain (chain id 4663). Snapshot distribution is finalized, and the current market gates are read live in the status panel above. Verify every address yourself — each row links to verified source on Blockscout:

| Contract | Address |
| --- | --- |
| V2 $QUOTRON (ERC-404 core) | [0x5a…0D7F](https://robinhoodchain.blockscout.com/address/0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F "0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F") |
| V2 terminal NFTs (ERC-721 mirror) | [0x02…9d6e](https://robinhoodchain.blockscout.com/address/0x027ACa2794E44f24950D81227DcD516FfBB49d6e "0x027ACa2794E44f24950D81227DcD516FfBB49d6e") |
| Reflections engine | [0xe0…d3Ec](https://robinhoodchain.blockscout.com/address/0xe04fba61FD54Ba78Dd450A30d8Af40167aF5d3Ec "0xe04fba61FD54Ba78Dd450A30d8Af40167aF5d3Ec") |
| Launch eligibility registry | [0x94…aC81](https://robinhoodchain.blockscout.com/address/0x94CfC3798Ca6320Ac5e6af04484EFE90bD04aC81 "0x94CfC3798Ca6320Ac5e6af04484EFE90bD04aC81") |
| Canonical WETH fee hook | [0x62…B0cc](https://robinhoodchain.blockscout.com/address/0x62E200Cc8e4D95cf622f40Dd70f407C883EcB0cc "0x62E200Cc8e4D95cf622f40Dd70f407C883EcB0cc") |
| Canonical ETH router | [0x42…1C18](https://robinhoodchain.blockscout.com/address/0x42024fCFdB4F3089Dd619A0cEF0Cd24E7b841C18 "0x42024fCFdB4F3089Dd619A0cEF0Cd24E7b841C18") |
| View quoter | [0xb8…2df2](https://robinhoodchain.blockscout.com/address/0xb8960fdC8A0Be155d196C2795b75747763562df2 "0xb8960fdC8A0Be155d196C2795b75747763562df2") |
| Epoch stock converter | [0x24…a2FE](https://robinhoodchain.blockscout.com/address/0x24e62Dd5C7058CC41ad9c5375C137460ea1Da2FE "0x24e62Dd5C7058CC41ad9c5375C137460ea1Da2FE") |
| Stonks incinerator | [0xc3…38F9](https://robinhoodchain.blockscout.com/address/0xc388e730807C6F69b959443Ed497C731b8d138F9 "0xc388e730807C6F69b959443Ed497C731b8d138F9") |
| WETH burn vault | [0xd1…0760](https://robinhoodchain.blockscout.com/address/0xd1258efafa9d1B1d09c86403139Db78465540760 "0xd1258efafa9d1B1d09c86403139Db78465540760") |
| Destination-locked burn adapter | [0x59…6f0a](https://robinhoodchain.blockscout.com/address/0x59b09A326984dd3c1076B864aa27F0BDd9876f0a "0x59b09A326984dd3c1076B864aa27F0BDd9876f0a") |
| Locked LP vault | [0x4b…cCBe](https://robinhoodchain.blockscout.com/address/0x4b7A4F53D9b7E4B4941bc9CF74e852D55444cCBe "0x4b7A4F53D9b7E4B4941bc9CF74e852D55444cCBe") |
| Liquidity seeder | [0xCc…2Fee](https://robinhoodchain.blockscout.com/address/0xCc949C33860E0F695be3373628955D77Dd922Fee "0xCc949C33860E0F695be3373628955D77Dd922Fee") |
| V1 → V2 migrator (finalized) | [0x20…Cd6D](https://robinhoodchain.blockscout.com/address/0x205E13e6Ec07baa4eD1c57d677DE9FeE1C88Cd6D "0x205E13e6Ec07baa4eD1c57d677DE9FeE1C88Cd6D") |
| Migration reserve (distributed) | [0xCF…f292](https://robinhoodchain.blockscout.com/address/0xCF39cb2363f85d3adad4fF891bb357C1766ef292 "0xCF39cb2363f85d3adad4fF891bb357C1766ef292") |
| Fractional migration sink | [0x07…27ad](https://robinhoodchain.blockscout.com/address/0x077403e402B63Da54a594Cbd2CfC46DbC92927ad "0x077403e402B63Da54a594Cbd2CfC46DbC92927ad") |
| ERC721-C royalty splitter | [0xd8…01d7](https://robinhoodchain.blockscout.com/address/0xd8eb805e96B05cb412A1e48eb3a85B6267f901d7 "0xd8eb805e96B05cb412A1e48eb3a85B6267f901d7") |
| STONK BROKERS collection | [0x53…AbF0](https://robinhoodchain.blockscout.com/address/0x539CdD042c2f3d93EbC5BE7DfFf0c79F3B4fAbF0 "0x539CdD042c2f3d93EbC5BE7DfFf0c79F3B4fAbF0") |
| Canonical WETH | [0x0B…AD73](https://robinhoodchain.blockscout.com/address/0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73 "0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73") |
| Reward-route USDG | [0x5f…d168](https://robinhoodchain.blockscout.com/address/0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168 "0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168") |

The terminal token, hook and router jointly enforce the registered QUOTRON/WETH PoolManager route. The ten tokenized-stock markets are used only by the destination-locked reward converter.

TEXT Canonical QUOTRON/WETH pool id

`0x0b142aaf734f1b063355bfe854e282a13b26dcac86e2e564e74540f9b218d069`
V1 remains visible only as historical onchain state: [core 0x40…81E6](https://robinhoodchain.blockscout.com/address/0x40686524e56AfF0F1446958725dCF6e6dA5381E6 "0x40686524e56AfF0F1446958725dCF6e6dA5381E6") · [mirror 0xbd…cd83](https://robinhoodchain.blockscout.com/address/0xbde7BEc47cbFc689e5E952B6cdD113A500abcd83 "0xbde7BEc47cbFc689e5E952B6cdD113A500abcd83") · [reflections 0x66…877C](https://robinhoodchain.blockscout.com/address/0x666A51Eb731a9CF79d97B4A9c64cD5a4806c877C "0x666A51Eb731a9CF79d97B4A9c64cD5a4806c877C").

## The Swap API[#](https://www.quotrons.cash/docs#swap-api "Copy link to this section")

The immutable V2 router accepts native ETH buys and returns native ETH on sells. There is no API key, no backend, and no permission to ask for — the canonical route is public infrastructure, and it is safe to publish precisely because the routing lock means it cannot be bypassed. Wallets, aggregators, and bots integrate directly against the contracts.

Router surface

SOLIDITY QuotronWethRouter @ 0x42024fCFdB4F3089Dd619A0cEF0Cd24E7b841C18

```
// Buys are payable in native ETH; sells return native ETH.
function buyExactEth(
    uint256 minQuotronOut, address recipient, uint256 deadline
) external payable returns (uint256 quotronOut);

function buyExactQuotron(
    uint256 quotronOut, address recipient, uint256 deadline
) external payable returns (uint256 wethSpent);

function sellExactQuotronForEth(
    uint256 quotronIn, uint256 minEthOut,
    address recipient, uint256 deadline
) external returns (uint256 ethOut);
```

CARE

The hook prices the **caller** as the payer; the recipient only receives output. A contract that routes on behalf of users pays its own fee tier, and sells pull $QUOTRON from the caller — so the caller needs the ERC-20 allowance, not the end user.

Quoter surface

SOLIDITY QuotronWethQuoter @ 0xb8960fdC8A0Be155d196C2795b75747763562df2

```
// All views: no ETH, tokens, or allowance required to quote.
function quoteBuyExactEth(uint256 ethIn, address payer)
    external view returns (
        uint256 quotronOut, uint256 feeBps,
        uint256 feeWeth,    uint256 poolWethIn
    );

function quoteSellExactQuotron(uint256 quotronIn, address payer)
    external view returns (
        uint256 ethOut,  uint256 feeBps,
        uint256 feeWeth, uint256 poolWethOut
    );

function quoteBuyExactQuotron(uint256 quotronOut, address payer)
    external view returns (
        uint256 ethIn,   uint256 feeBps,
        uint256 feeWeth, uint256 poolWethIn
    );

function currentFeeBps(address payer) external view returns (uint256);
```

Integration example (viem)

TYPESCRIPT Quote, then buy

```
// 1. quote for the actual payer — returns the full fee breakdown
const [quotronOut, feeBps, feeWeth, poolWethIn] =
  await client.readContract({
    address: QUOTER,
    abi: quoterAbi,
    functionName: "quoteBuyExactEth",
    args: [ethIn, account],
  });

// 2. user-approved slippage floor on the quoted output
const minOut =
  (quotronOut * (10_000n - slippageBps)) / 10_000n;

// 3. execute — send only after displaying quote, fee, and minimum
await wallet.writeContract({
  address: ROUTER,
  abi: routerAbi,
  functionName: "buyExactEth",
  args: [minOut, account, deadline],
  value: ethIn,
});
```

TYPESCRIPT Sell (needs allowance to the router)

```
// one-time allowance: approve only what this sale needs
await wallet.writeContract({
  address: QUOTRON,
  abi: erc20Abi,
  functionName: "approve",
  args: [ROUTER, quotronIn],
});

const [ethOut] = await client.readContract({
  address: QUOTER,
  abi: quoterAbi,
  functionName: "quoteSellExactQuotron",
  args: [quotronIn, account],
});
const minEthOut = (ethOut * (10_000n - slippageBps)) / 10_000n;

await wallet.writeContract({
  address: ROUTER,
  abi: routerAbi,
  functionName: "sellExactQuotronForEth",
  args: [quotronIn, minEthOut, account, deadline],
});
```

Selling a whole token dissolves your most recent dark terminal — that is the reroll, not a bug. Hardwired terminals are unaffected by any token movement.

## The Stonks Incinerator[#](https://www.quotrons.cash/docs#incinerator "Copy link to this section")

One transaction that liquidates tokenized stocks into USDG, native ETH, or straight back into $QUOTRON through the canonical router. Ownerless and immutable: no admin, no upgrade path, no pause switch, and it holds nothing between transactions. The ten Quotron reward stocks trade through routes copied from the sealed epoch converter; **any other Robinhood Chain token with a hookless V4 USDG pool** trades through the generic surface below — it is public infrastructure, and any project can integrate it. A fixed 2.5% service fee on proceeds goes to the Quotron admin Safe, denominated in the delivered asset.

Incinerator surface

SOLIDITY QuotronStonksIncinerator @ 0xc388e730807C6F69b959443Ed497C731b8d138F9

```
// The ten Quotron reward stocks, by floor index 0-9.
// amounts[i]: exact amount, type(uint256).max = full balance, 0 = skip.
function incinerate(
    uint256[10] amounts, bool toEth,
    uint256 minUsdgOut, uint256 minWethOut, uint256 deadline
) external returns (uint256 usdgOut, uint256 wethOut, uint256 feePaid);

// Same, with one EIP-2612 permit per floor: zero approval transactions.
// deadline == 0 in a permit slot means "no permit for this floor".
function incinerateWithPermits(
    uint256[10] amounts, StockPermit[10] permits, bool toEth,
    uint256 minUsdgOut, uint256 minWethOut, uint256 deadline
) external returns (uint256 usdgOut, uint256 wethOut, uint256 feePaid);

// ANY token with a hookless V4 USDG pool - the integration surface.
// Caller supplies the pool's fee tier and tick spacing per token.
function incinerateAny(
    GenericSale[] sales, bool toEth,
    uint256 minUsdgOut, uint256 minWethOut, uint256 deadline
) external returns (uint256 usdgOut, uint256 wethOut, uint256 feePaid);

// permits.length must equal sales.length; zero-deadline slots are skipped.
function incinerateAnyWithPermits(
    GenericSale[] sales, StockPermit[] permits, bool toEth,
    uint256 minUsdgOut, uint256 minWethOut, uint256 deadline
) external returns (uint256 usdgOut, uint256 wethOut, uint256 feePaid);

// Reinvest path: proceeds buy $QUOTRON on the canonical pool and land
// in the caller's wallet - every whole token draws a dark terminal.
// Service fee is taken in WETH before the buy; the pool's own 3%
// trading fee applies to the buy leg. Permit slots optional.
function incinerateForQuotron(
    uint256[10] amounts, StockPermit[10] permits,
    uint256 minUsdgOut, uint256 minWethOut, uint256 minQuotronOut,
    uint256 deadline
) external returns (
    uint256 usdgOut, uint256 wethOut, uint256 feePaid, uint256 quotronOut);

// Same for caller-supplied sales; permits may be empty.
function incinerateAnyForQuotron(
    GenericSale[] sales, StockPermit[] permits,
    uint256 minUsdgOut, uint256 minWethOut, uint256 minQuotronOut,
    uint256 deadline
) external returns (
    uint256 usdgOut, uint256 wethOut, uint256 feePaid, uint256 quotronOut);

struct GenericSale {
    address token;      // the tokenized stock (never USDG itself)
    uint24  fee;        // its USDG pool's fee tier
    int24   tickSpacing;// V4 only: the pool's tick spacing (0 for V3)
    uint256 amount;     // exact, max = full balance, 0 = skip
    uint8   venue;      // 0 = hookless V4 pool, 1 = V3 pool
}

struct StockPermit {
    uint256 value;      // allowance the signature grants
    uint256 deadline;   // permit expiry; 0 = no permit in this slot
    uint8 v; bytes32 r; bytes32 s;
}

// Anyone can sweep stranded tokens/ETH to the admin Safe. The
// reentrancy lock keeps rescues out of in-flight incinerations.
function rescue(address token) external;
function rescueNative() external;

// Constants and views
function quotronRouter() external view returns (address);  // canonical router
function FEE_RECIPIENT() external view returns (address); // admin Safe
function FEE_BPS() external view returns (uint256);       // 250 = 2.5%
function routes(uint256 floorIdx) external view returns (
    address stock, uint24 fee, int24 tickSpacing, address hooks,
    uint8 venue);   // the pinned best-venue table, verified vs the converter

// Events (for indexers)
event StockIncinerated(
    address indexed account, address indexed stock,
    uint256 amountIn, uint256 usdgOut);
event Incinerated(
    address indexed account, uint256 usdgOut,
    uint256 wethOut, uint256 feePaid, bool toEth);
event IncineratedForQuotron(
    address indexed account, uint256 usdgOut, uint256 wethOut,
    uint256 feePaid, uint256 quotronOut);
event Rescued(address indexed token, uint256 amount);
```

How it settles

Every sale executes inside a single pool-manager unlock: each token swaps to USDG in its canonical V4 pool, the aggregate USDG is taken once, and the 2.5% fee is carved from the proceeds. On the ETH path the USDG then hops through the 0.01% USDG/WETH V3 pool and unwraps, with the fee taken in WETH instead. Exact-input fills are all-or-nothing on **both** legs — a swap that would only partially fill (drained liquidity) reverts the whole transaction rather than stranding a remainder.

Min-outs protect the **net** amount the caller receives after the fee: minUsdgOut binds net USDG on the USDG path, minWethOut binds net WETH on the ETH and QUOTRON paths, and minQuotronOut binds the router's delivery on the QUOTRON path. The QUOTRON leg is the canonical router's buyExactEth with the caller as recipient: the incinerator never holds $QUOTRON, and the router is verified against the token's canonicalRouter at construction. Pulls are strictly msg.sender: no integration, and no third party, can ever spend another wallet's allowance through this contract.

Floor routes are an immutable table fixed at deployment from a live depth scan of every V4 and V3 USDG pool per stock — the stock in each slot is verified against the sealed epoch converter, while the venue and fee tier are chosen for depth. V3-venue sales go through the canonical V3 router; V4-venue sales share one pool-manager unlock.

CARE

The generic surface accepts hookless V4 pools or V3 pools, and the pool params must match the token's live USDG pool exactly — a wrong fee tier or tick spacing reverts against an uninitialized pool. Selling into thin liquidity is bounded by your min-out, not prevented: quote first.

Integration example (viem)

TYPESCRIPT Sell any tokenized stock for USDG

```
// one-time allowance (or use incinerateAnyWithPermits - see below)
await wallet.writeContract({
  address: STOCK,
  abi: erc20Abi,
  functionName: "approve",
  args: [INCINERATOR, amount],
});

// quote by simulating the exact call - returns include the fee
const { result } = await client.simulateContract({
  account,
  address: INCINERATOR,
  abi: incineratorAbi,
  functionName: "incinerateAny",
  args: [
    [{ token: STOCK, fee: POOL_FEE, tickSpacing: POOL_TICKS, amount, venue: 0 }],
    false,  // toEth
    1n, 0n, // min-outs: 1 wei floor for the quote pass
    deadline,
  ],
});
const [usdgOut, , feePaid] = result;
const minNet =
  ((usdgOut - feePaid) * (10_000n - slippageBps)) / 10_000n;

// execute with the real floor
await wallet.writeContract({
  address: INCINERATOR,
  abi: incineratorAbi,
  functionName: "incinerateAny",
  args: [
    [{ token: STOCK, fee: POOL_FEE, tickSpacing: POOL_TICKS, amount, venue: 0 }],
    false, minNet, 0n, deadline,
  ],
});
```

TYPESCRIPT Zero approval transactions (EIP-2612)

```
// the Robinhood tokenized stocks are permit-capable: collect one
// gasless typed-data signature per token instead of approvals
const sig = parseSignature(await wallet.signTypedData({
  domain: await client.getEip712Domain({ address: STOCK })
    .then((d) => d.domain),
  types: { Permit: [
    { name: "owner",    type: "address" },
    { name: "spender",  type: "address" },
    { name: "value",    type: "uint256" },
    { name: "nonce",    type: "uint256" },
    { name: "deadline", type: "uint256" },
  ]},
  primaryType: "Permit",
  message: { owner: account, spender: INCINERATOR, value: amount,
             nonce, deadline: permitDeadline },
}));

await wallet.writeContract({
  address: INCINERATOR,
  abi: incineratorAbi,
  functionName: "incinerateAnyWithPermits",
  args: [
    [{ token: STOCK, fee: POOL_FEE, tickSpacing: POOL_TICKS, amount, venue: 0 }],
    [{ value: amount, deadline: permitDeadline,
       v: Number(sig.v ?? BigInt(sig.yParity + 27)),
       r: sig.r, s: sig.s }],
    false, minNet, 0n, deadline,
  ],
});
```

Permit slots are try/catch'd on purpose: a permit consumed by a front-runner is harmless when the allowance it set already covers the pull. MetaMask renders each permit signature as a "Spending cap request" — free signatures, not transactions.

## Errors & Events Reference[#](https://www.quotrons.cash/docs#reference "Copy link to this section")

Every revert in the V2 stack is a named custom error. If your integration hits one, this table says why and what to do. Events follow, for indexers.

Errors you may actually hit

| Error | Meaning |
| --- | --- |
| UnauthorizedPoolSettlement | A QUOTRON settlement with the PoolManager had no live hook authorization — a rogue v4 pool or a direct PoolManager call. Route through the canonical router. |
| NotRouter | QUOTRON moving into the PoolManager from anything except the canonical router, or a swap whose sender is not the router. Same fix: use the canonical route. |
| TradingNotOpen | Swap attempted before the one-way launch() transaction. |
| ContractPaused / Paused_ | The owner has paused the token or hook (emergency control). Check the status panel at the top of this page. |
| TransfersAreLocked | Pre-launch staged state. Only setup-allowed addresses can move tokens. |
| BlacklistedAccount | Sender, recipient, or operator is frozen by the disclosed blacklist. Every freeze emits BlacklistUpdated. |
| LaunchTransferRestricted | Historical: a wallet that paid the 90% launch fee was transfer-restricted for one hour. Cannot occur since fee finalization. |
| ExactOutputFeeTooHigh | Exact-output buys are refused when the payer's fee is 50% or higher. Historical launch-phase guard; at the permanent 3% fee it cannot trigger. |
| NotTerminalOwner | hardwire(id) or a mirror transfer from an address that does not own the id. |
| AlreadyHardwired | The id is already permanent. There is no re-hardwire. |
| InsufficientBalance | Hardwiring needs the full 1.0 $QUOTRON in the caller's wallet; dark-terminal NFT transfers move 1.0 with the id. |
| NotHardwiredId / NotIdOwner | Reflections claims: only the current owner of a hardwired id can claim it. Dark terminals have nothing to claim. |
| BannedVenue | A transfer touched a contract whose runtime codehash is a banned venue archetype (non-v4 AMM pair). EOAs can never trigger this. |
| UnsafeReceiver | safeTransferFrom to a contract that does not implement onERC721Received. |

Events for indexers

SOLIDITY Quotron404V2 — token + terminal lifecycle

```
event Transfer(address indexed from, address indexed to, uint256 amount);
event Hardwired(uint256 indexed id, address indexed owner);
event TerminalMaterialized(uint256 indexed id, address indexed owner);
event TerminalDissolved(uint256 indexed id, address indexed owner);
event Launched(uint256 timestamp);
event Paused(bool paused);
event BlacklistUpdated(address indexed account, bool blacklisted, address indexed caller);
event QuotronRecovered(address indexed from, address indexed to, uint256 amount);
event TerminalRecovered(address indexed from, address indexed to, uint256 indexed id, bool hardwired);
```

SOLIDITY QuotronWethHook — every fee, itemized

```
event FeeTaken(
    PoolId indexed poolId,
    address indexed swapper,
    uint256 feeBps,
    uint256 total,          // WETH
    uint256 toReflections,
    uint256 toBurn,
    uint256 toLp,
    uint256 toCreator
);
event PotPulled(uint8 indexed pot, address indexed sink, uint256 amount);
```

SOLIDITY QuotronReflectionsV2 — reward accounting

```
event FeesNotified(uint8 indexed floorIdx, uint256 amount, uint256 toFloor, uint256 toBasket, uint256 toGold);
event Claimed(uint256 indexed id, address indexed to, address stock, uint256 amount);
event Poked(uint256 indexed id, uint256 oldWeight, uint256 newWeight);
event FloorPotClaimed(uint8 indexed floorIdx, uint256 indexed id, uint256 amount);
```

The 8-bit terminal lifecycle can be reconstructed from TerminalMaterialized / TerminalDissolved / Hardwired alone; the ERC-721 mirror additionally emits standard Transfer events for marketplace indexers on every one of those transitions.

## Feed This To Your AI[#](https://www.quotrons.cash/docs#ai "Copy link to this section")

The entire project in one self-contained markdown file: every mechanic, fee split, tier weight, relic, verification hash, and risk. Download it and hand it to ChatGPT, Claude, or whatever you use, then ask it anything about QUOTRONS.

Served at the standard llms.txt paths, so assistants that look for machine-readable docs will find them on their own. Everything on this page also renders as plain HTML in the DOM — collapsed sections included — so crawlers and assistants reading the page see the full text, not summaries.

## The Venue[#](https://www.quotrons.cash/docs#xstocks-overview "Copy link to this section")

Separate from the terminals and the $QUOTRON market, we run a tokenized-equity venue on **Ink (chain id 57073)**: eight Uniswap V4 pools trading Backed's wrapped xStocks against USDG. It is the reward-stock infrastructure the terminals ultimately draw on, and it is open for anyone to trade or build against today.

Every pool is **0% LP fee** with a **0.30% hook fee** taken in USDG on each swap and split exactly in half: one half accrues to hardwired Quotron terminals, the other pays the pool's liquidity vault. There is no separate LP fee tier to reason about — the hook is the only thing charging.

NOTE

**No oracle exists anywhere in this system.** No contract of ours asserts what a share is worth. Price is discovered by the AMM curve, and every trade walks that curve. Nothing can be extracted at a stale quoted price, because there is no quoted price — there is a book.

Pools are quoted in USDG and hold _wrapped_ xStocks (the ERC-4626 wrappers), never the raw rebasing Backed tokens. Prices track real-world value by arbitrage against Backed NAV and the other venues on Ink — not by any peg mechanism we operate.

CARE

Equities trade roughly 32 hours of the week; these pools trade all 168. While the underlying market is closed, pool prices can drift from fair value by roughly the fee band before arbitrage makes correcting it worthwhile, and news arriving over a weekend or after an earnings release can gap the underlying with no way for passive liquidity to reprice first. That risk is real and it is borne by liquidity providers.

## Fees And Dividends[#](https://www.quotrons.cash/docs#xstocks-fees "Copy link to this section")

The hook takes its fee in USDG and immediately splits it into two pots. Nothing is custodied off-chain and nothing waits on a signature to move.

| Leg | Share | Where it goes |
| --- | --- | --- |
| Terminal pot | 50% | Pooled venue-wide across all pools, then converted to tokenized equities and paid to hardwired terminals. |
| LP pot | 50% | Held per-pool and claimable by that pool's liquidity vault depositors. |

The terminal half is pooled across the whole venue rather than per-pool, so a quiet market still reaches an epoch on the back of a busy one. Epochs fire at a minimum of $250 USDG, cap at $10,000, and run at most once every 5 minutes. Each epoch splits its budget equally across the ten reward floors.

FEE

The fee is steppable by the operator in 0.05% increments within bounds fixed at deployment: **minimum 0.05%, maximum 1.00%**. Those bounds live in the immutable hook and can never be widened — not by an upgrade, not by us. Whatever the fee is when you read this, it can never exceed 1.00%.

Quote the fee live rather than assuming 0.30%; it is returned by the hook per swap and applies to the USDG leg of the trade.

## Ink Contracts[#](https://www.quotrons.cash/docs#xstocks-contracts "Copy link to this section")

Deployed on Ink (chain id 57073). All source is verified on Blockscout — every row links to it. Addresses are shortened for width; use the copy button beside each one to get the exact value.

| Contract | Address | Mutability |
| --- | --- | --- |
| Uniswap V4 Pool Manager | [0x36…FB32](https://explorer.inkonchain.com/address/0x360E68faCcca8cA495c1B759Fd9EEe466db9FB32 "0x360E68faCcca8cA495c1B759Fd9EEe466db9FB32") | Uniswap, immutable |
| Quotrons stock hook | [0x8b…30cc](https://explorer.inkonchain.com/address/0x8bb4516059F9149Bc3b89018Fc7537f1F14a30cc "0x8bb4516059F9149Bc3b89018Fc7537f1F14a30cc") | Immutable |
| Pool factory | [0xbF…d3A2](https://explorer.inkonchain.com/address/0xbFA531C90FD9e42aC13Af14823B30e40761dd3A2 "0xbFA531C90FD9e42aC13Af14823B30e40761dd3A2") | Immutable |
| Epoch converter | [0xFd…B33F](https://explorer.inkonchain.com/address/0xFd30F33dE4A2dA00c5c844Acef5728535B95B33F "0xFd30F33dE4A2dA00c5c844Acef5728535B95B33F") | UUPS proxy |
| Terminal dividends | [0x2E…6C2C](https://explorer.inkonchain.com/address/0x2E1509FBc75b621d08F64d8328a3C4152cf96C2C "0x2E1509FBc75b621d08F64d8328a3C4152cf96C2C") | UUPS proxy |
| WETH terminal pot | [0x0A…7A07](https://explorer.inkonchain.com/address/0x0Aa7abB778DC11Dcaa1dBB16B72c70dD6f2d7A07 "0x0Aa7abB778DC11Dcaa1dBB16B72c70dD6f2d7A07") | UUPS proxy |
| Liquidity growth sink | [0x73…5E03](https://explorer.inkonchain.com/address/0x73F5111EE91672c114923793C03B5c868d9C5E03 "0x73F5111EE91672c114923793C03B5c868d9C5E03") | UUPS proxy |
| LP vault beacon | [0x65…7D78](https://explorer.inkonchain.com/address/0x6560417F6Df140597c3d2811ED833cD9a70e7D78 "0x6560417F6Df140597c3d2811ED833cD9a70e7D78") | Beacon |
| LP vault implementation | [0x76…5B21](https://explorer.inkonchain.com/address/0x76fDf913c2bc8AF5ce545B5C27B18bEF51245B21 "0x76fDf913c2bc8AF5ce545B5C27B18bEF51245B21") | Immutable |
| USDG (quote asset) | [0xe3…491D](https://explorer.inkonchain.com/address/0xe343167631d89B6Ffc58B88d6b7fB0228795491D "0xe343167631d89B6Ffc58B88d6b7fB0228795491D") | Third party |

The hook — the only contract in the path of every swap — is immutable. The accounting contracts sit behind proxies so the epoch and dividend math can be corrected without redeploying the markets and forcing every LP to migrate. Upgrade authority is held at [0x15…bA89](https://explorer.inkonchain.com/address/0x15277aA1ecC13734d57C519a2DAA1cc4A748bA89 "0x15277aA1ecC13734d57C519a2DAA1cc4A748bA89"), separate from the operational owner: the operator can open pools, step the fee and run epochs, but cannot swap an implementation. Each proxy carries `renounceUpgradeability()` to remove that path permanently once audited.

Implementations behind the proxies

| Component | Implementation |
| --- | --- |
| Terminal dividends | [0x07…6c76](https://explorer.inkonchain.com/address/0x0707F946992b32F53652FFdFdD015bA8797a6c76 "0x0707F946992b32F53652FFdFdD015bA8797a6c76") |
| Epoch converter | [0xf9…9888](https://explorer.inkonchain.com/address/0xf9084d029F8fb7c42b070C2df9F14EfBa18F9888 "0xf9084d029F8fb7c42b070C2df9F14EfBa18F9888") |
| WETH terminal pot | [0x79…c6B5](https://explorer.inkonchain.com/address/0x79A8a083721a4AcAa41A81b03c48ca95F24Ec6B5 "0x79A8a083721a4AcAa41A81b03c48ca95F24Ec6B5") |
| Liquidity growth sink | [0x14…4b51](https://explorer.inkonchain.com/address/0x14576500103291c76F7723E740D21FEb05084b51 "0x14576500103291c76F7723E740D21FEb05084b51") |

Live pool ids, LP vault addresses and per-market stats are on the [xStocks Pools](https://www.quotrons.cash/xstocks) page.

## Integration Guide[#](https://www.quotrons.cash/docs#xstocks-integration "Copy link to this section")

The pools are ordinary Uniswap V4 pools with a hook attached. There is no proprietary router, no API key, and no permission to request — if your code can talk to the V4 `PoolManager`, it can trade these markets. This section is everything you need to integrate without reading our source.

1. Network

Use a private or paid RPC. The public Ink endpoint prunes state and rejects batched calls, which breaks most indexing and multicall patterns.

2. Reconstruct the PoolKey

Pool ids are the keccak of the `PoolKey`. Build it exactly as the factory does — currencies sorted ascending, the dynamic-fee flag rather than a fee tier, tick spacing 60, and our hook:

SOLIDITY PoolKey for any Quotrons stock market

```
// currency0 < currency1, sorted by address.
(address c0, address c1) = usdg < stock ? (usdg, stock) : (stock, usdg);

PoolKey memory key = PoolKey({
    currency0:   Currency.wrap(c0),
    currency1:   Currency.wrap(c1),
    fee:         LPFeeLibrary.DYNAMIC_FEE_FLAG,   // 0x800000 — NOT 3000
    tickSpacing: 60,
    hooks:       IHooks(0x8bb4516059F9149Bc3b89018Fc7537f1F14a30cc)
});
PoolId id = key.toId();
```

CARE

The `fee` field is the **dynamic-fee flag**, not 0.30%. Hardcoding `3000` derives a different pool id and you will hit an uninitialised pool. The real fee is supplied by the hook at swap time.

Or skip the derivation and read it from the factory: `poolOf(address stock)` returns the pool id and `vaultOf(address stock)` the LP vault. `stockCount()` and `allStocks(uint256)` enumerate every live market.

3. Quote and swap

Swap through the `PoolManager` using the standard V4 unlock/settle pattern, or any V4-compatible router. Quote by simulating the swap — the hook adjusts the fee per call, so a static fee assumption will misprice the trade.

SOLIDITY Swap direction

```
// zeroForOne == true  spends currency0, receives currency1
// Buying stock with USDG means zeroForOne == (usdg < stock)

bool buyingStock = true;
bool zeroForOne  = buyingStock ? (usdg < stock) : (stock < usdg);
```

FEE

The hook takes its fee on the **USDG leg** in every case, so a buy and a sell of the same notional pay the same fee. Set `minAmountOut` from a simulation of the exact transaction, never from a spot-price calculation — these are thin pools and price impact is real.

4. Read live state

Everything the venue does is indexed publicly. No key required:

TEXT Subgraph endpoint

`https://api.goldsky.com/api/public/project_cmssuu23e13si01xt3o30067i/subgraphs/quotrons-ink-stocks/prod/gn`

TEXT Markets, prices, volume and fees

```
{
  pools {
    id                # V4 pool id
    symbol            # e.g. wAAPLx
    vault             # LP vault address
    feeBps            # live hook fee
    priceUsdE6        # last trade price, 6dp
    volumeUSDG
    feesUSDG
    feesToTerminal
    txCount
  }
}
```

TEXT Recent swaps for one market

```
{
  swaps(
    first: 100
    orderBy: timestamp
    orderDirection: desc
    where: { pool: "<poolId>" }
  ) {
    timestamp
    sender
    usdgAmount
    stockAmount
    buyingStock       # true = bought stock with USDG
    priceUsdE6
    sqrtPriceX96
  }
}
```

5. Provide liquidity

Each market has its own vault holding a single concentrated position. Depositing mints shares that accrue the pool's half of the hook fee, claimable in USDG at any time.

SOLIDITY LP vault surface

```
function deposit(uint256 amount0Max, uint256 amount1Max,
                 uint256 minShares, uint256 deadline)
    external returns (uint256 shares, uint256 paid0, uint256 paid1);

function withdraw(uint256 sharesIn, uint256 amount0Min,
                  uint256 amount1Min, uint256 deadline)
    external returns (uint256 out0, uint256 out1);

function claim()  external returns (uint256 usdgAmount);
function pendingDividends(address account) external view returns (uint256);
```

CARE

Public LP deposits are **not open yet** — the vaults are live but deposits remain restricted pending an audit. Read the closed-hours risk in [The Venue](https://www.quotrons.cash/docs#xstocks-overview) before planning around them.

6. Contribute in WETH

Two contracts accept plain WETH from anyone and deploy it on their next epoch. Sending WETH is the entire integration — no allowlist, no call required.

The pot routes WETH → USDT0 → USDG, buys equities across the ten floors and pays terminals. The sink splits 50/50 between buying the stock and holding USDG, then adds both sides as protocol-owned liquidity whose shares are non-transferable. Both fire between 0.01 and 10 WETH per epoch.

ONE-WAY

Contributions are **donations, not deposits**. They buy no claim, mint you no redeemable share, and there is no withdrawal path. A disclosed recovery admin can sweep idle balances stranded on either contract — it can never reach vault shares or a pool position. Do not send funds you expect to get back.

7. Caveats worth knowing

*   **Pools can be paused.** The operator can pause any market; swaps revert while paused. Check before routing.
*   **The fee moves.** It is steppable within 0.05%–1.00% and may be raised while the underlying market is closed. Always quote live.
*   **Some addresses are fee-exempt.** The protocol's own rails trade at zero hook fee. Do not infer the fee from an observed swap unless you know the sender.
*   **Two markets have no other venue.** wGOOGLx and wAMZNx trade only here, so there is no second price to arbitrate against.
*   **These are young, thin pools.** Size trades accordingly and simulate before sending.

Building something on this? Reach out — [@quotrons404](https://x.com/quotrons404).

## Brand Assets[#](https://www.quotrons.cash/docs#brand-assets "Copy link to this section")

The real files, the same ones this app ships. Free to use for coverage, listings, and community work. The SVGs are true pixel-rect vectors: every pixel is a rectangle, so they stay hard-edged at any size. Don't restretch, recolor, or add effects to the mark, and don't put the icons back in a bordered square.

[**Download the full kit**Logos, wordmark, icons, banners, cards, animated GIFs and the usage rules · ZIP, ~28 MB ZIP](https://www.quotrons.cash/brand/quotrons-brand-kit.zip)
Or browse it on [github.com/mavrkofficial/quotrons-brand-kit](https://github.com/mavrkofficial/quotrons-brand-kit).

### The mark

### Wordmark

### App icon

### Banners

### Animated

### Cards & wallpapers

### Brochures

### Colour

Paper #F1EADA Ink #3A2A1C Cream light #E5DDB8 Cream shade #B4B181 CRT green #43E858 Bezel ink #27282A Key salmon #FBB7B1 Accent red #DD0104 Brochure orange #CE5810 NASDANK teal #2EBCAE

Sampled from the artwork itself, not guessed. Site terminals still run orange #ff6e00 on shell black #111111. Typeface everywhere is the system monospace stack; the pixel lettering is our own 5x7 and 3x5 faces, the same ones the machines use on their screens.

## FAQ[#](https://www.quotrons.cash/docs#faq "Copy link to this section")

Do my burned tokens go to a burn address?
No — better. totalSupply is genuinely reduced; nothing accumulates at a dead address. The Transfer(you, 0x0, 1.0) event is the ERC-20 convention so explorers render it as a burn, but the supply is destroyed, not parked.

Is hardwiring staking?
No. Staking implies a position you can unwind. Hardwiring destroys the token permanently; what you keep is the terminal NFT and its claim on future fees. There is no unbonding, no escrow, and no way back.

Can I pick which terminal I get?
Not by buying — materialization draws randomly from the unclaimed pool. You can buy a specific dark or hardwired terminal on secondary markets (the dark one arrives with its 1.0 $QUOTRON backing), or reroll by cycling your balance below and above a whole unit.

If I sell my token, what happens to my terminal?
Dark terminals dissolve newest-first as your balance crosses down through whole units. Hardwired terminals are untouchable by token movement — that is the entire point of hardwiring.

Why is my quoted fee different from 3%?
It shouldn't be — launch-fee finalization has executed and every wallet pays the permanent 3%. If a quote surprises you, read currentFeeBps(payer) on the quoter for the address that will actually call the router. Remember the caller is the payer, not the recipient.

Can someone fork a pool and trade $QUOTRON without the fee?
Not on Uniswap v4 — the token refuses settlement with the PoolManager unless our hook authorized that exact swap, so a rogue pool cannot even be seeded. Non-v4 venues can be banned by codehash reactively. See [The Routing Lock](https://www.quotrons.cash/docs#routing) for what is and is not guaranteed.

Do rewards keep accruing if I never claim?
Yes. The masterchef accumulator credits your terminal's share continuously; claiming just transfers the accrued stock out. Pending rewards travel with the NFT if it is sold — though a seller can claim right before the sale, so buyers should check pending balances at execution time.

What exactly does holding a STONK BROKER do?
Every standard terminal you have hardwired earns 1.25x weight while your wallet holds at least one Broker. It is read live: sell the Broker and anyone can poke() your terminals back to 1.0x. Plus 0.2125% of all volume buys and burns $STONKBROKER regardless of who holds what.

Are the reward stocks real equities?
They are tokenized stock products issued by a third party on Robinhood Chain — not shares held in your name. The issuer's contracts are upgradeable and that risk passes through to anything denominated in them. See Risks.

Who can move my tokens besides me?
Two disclosed powers exist: the blacklist guardian can freeze (not move) an address, and the recovery Safe (threshold ≥ 2) can forcibly move balances or terminals between non-protocol accounts — the mechanism that made V1 restitution possible. Every such action emits an onchain event. See Security & Trust for addresses.

## Risks[#](https://www.quotrons.cash/docs#risks "Copy link to this section")

Reflections and reward drops are promotional rewards for taking part in the protocol. They are not dividends, not investment income, and confer no equity, ownership, or share of profits in any company.

*   Hardwiring is irreversible. The burned token is gone whether or not the protocol ever earns another cent.
*   Per-terminal reward rates dilute as more terminals hardwire: each new lit terminal adds a permanent claimant while removing liquid supply from the float that generates fees. Early per-terminal rates are not representative.
*   V2 used a temporary 90% public launch fee before irreversible finalization. That phase has ended and the permanent fee is 3%. Verify the onchain fee before every swap.
*   The tokenized stocks are issued by a third party as upgradeable contracts. Their issuer can pause or alter them, and that risk passes through to anything denominated in them.
*   Reward conversion and royalty processing are keeper-initiated. Fees accrue safely in destination-locked pots if operations stop, but payouts require the keeper to run.
*   Liquidity on Robinhood Chain moves fast. Stock-conversion routes that are deep today can thin out, the canonical QUOTRON/WETH market can be volatile, and rewards depend entirely on trading volume that may never materialize.
*   Canonical v4 settlement is enforced, and known alternate venue codehashes can be blocked, but arbitrary future custom contracts cannot be represented as categorically impossible.
*   The blacklist guardian, owner pause powers, and threshold recovery Safe are explicit trust assumptions. The Safe can forcibly move user balances or terminal NFTs between eligible accounts.
*   ERC721-C marketplace compatibility varies. Unsupported venues may reject transfers or listings.
*   Access to tokenized-stock products is restricted in some jurisdictions, including the United States region. Users are responsible for their own legal eligibility.
*   This is experimental software. Never risk more than you can afford to lose completely.

Links/Buttons:
- [QUOTRONS](https://www.quotrons.cash/)
- [My Desk](https://www.quotrons.cash/desk)
- [Exchange](https://www.quotrons.cash/exchange)
- [xStocks Pools](https://www.quotrons.cash/xstocks)
- [Social Market](https://www.quotrons.cash/market)
- [Reward Stocks](https://www.quotrons.cash/rewards)
- [OTC Desk](https://www.quotrons.cash/otc)
- [Relics](https://www.quotrons.cash/relics)
- [V1 Migration Record](https://www.quotrons.cash/v1)
- [Docs](https://www.quotrons.cash/docs)
- [](https://www.dextools.io/app/robinhood/pair-explorer/0x0b142aaf734f1b063355bfe854e282a13b26dcac86e2e564e74540f9b218d069)
- [#](https://www.quotrons.cash/docs#risks)
- [Audit the calculation.](https://www.quotrons.cash/migration/v1-historical-rewards.json)
- [migration manifest](https://www.quotrons.cash/migration/manifest.json)
- [public post-mortem record](https://github.com/mavrkofficial/quotrons-v1-post-mortem)
- [The 4,444 Invariant](https://www.quotrons.cash/docs#invariant)
- [0x53…AbF0](https://robinhoodchain.blockscout.com/address/0x539CdD042c2f3d93EbC5BE7DfFf0c79F3B4fAbF0)
- [0x71…7866](https://robinhoodchain.blockscout.com/address/0x7171E64E979265aeD6588577D1c6b60A701d7866)
- [0x15…bA89](https://explorer.inkonchain.com/address/0x15277aA1ecC13734d57C519a2DAA1cc4A748bA89)
- [0xd8…01d7](https://robinhoodchain.blockscout.com/address/0xd8eb805e96B05cb412A1e48eb3a85B6267f901d7)
- [0xA0…0000](https://robinhoodchain.blockscout.com/address/0xA000027A9B2802E1ddf7000061001e5c005A0000)
- [0xd1…9e58](https://robinhoodchain.blockscout.com/address/0xd1dE50B724de2e243D3f6f3C3ef1806BABD39e58)
- [0x5a…0D7F](https://robinhoodchain.blockscout.com/address/0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F)
- [0x02…9d6e](https://robinhoodchain.blockscout.com/address/0x027ACa2794E44f24950D81227DcD516FfBB49d6e)
- [0xe0…d3Ec](https://robinhoodchain.blockscout.com/address/0xe04fba61FD54Ba78Dd450A30d8Af40167aF5d3Ec)
- [0x94…aC81](https://robinhoodchain.blockscout.com/address/0x94CfC3798Ca6320Ac5e6af04484EFE90bD04aC81)
- [0x62…B0cc](https://robinhoodchain.blockscout.com/address/0x62E200Cc8e4D95cf622f40Dd70f407C883EcB0cc)
- [0x42…1C18](https://robinhoodchain.blockscout.com/address/0x42024fCFdB4F3089Dd619A0cEF0Cd24E7b841C18)
- [0xb8…2df2](https://robinhoodchain.blockscout.com/address/0xb8960fdC8A0Be155d196C2795b75747763562df2)
- [0x24…a2FE](https://robinhoodchain.blockscout.com/address/0x24e62Dd5C7058CC41ad9c5375C137460ea1Da2FE)
- [0xc3…38F9](https://robinhoodchain.blockscout.com/address/0xc388e730807C6F69b959443Ed497C731b8d138F9)
- [0xd1…0760](https://robinhoodchain.blockscout.com/address/0xd1258efafa9d1B1d09c86403139Db78465540760)
- [0x59…6f0a](https://robinhoodchain.blockscout.com/address/0x59b09A326984dd3c1076B864aa27F0BDd9876f0a)
- [0x4b…cCBe](https://robinhoodchain.blockscout.com/address/0x4b7A4F53D9b7E4B4941bc9CF74e852D55444cCBe)
- [0xCc…2Fee](https://robinhoodchain.blockscout.com/address/0xCc949C33860E0F695be3373628955D77Dd922Fee)
- [0x20…Cd6D](https://robinhoodchain.blockscout.com/address/0x205E13e6Ec07baa4eD1c57d677DE9FeE1C88Cd6D)
- [0xCF…f292](https://robinhoodchain.blockscout.com/address/0xCF39cb2363f85d3adad4fF891bb357C1766ef292)
- [0x07…27ad](https://robinhoodchain.blockscout.com/address/0x077403e402B63Da54a594Cbd2CfC46DbC92927ad)
- [0x0B…AD73](https://robinhoodchain.blockscout.com/address/0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73)
- [0x5f…d168](https://robinhoodchain.blockscout.com/address/0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168)
- [core 0x40…81E6](https://robinhoodchain.blockscout.com/address/0x40686524e56AfF0F1446958725dCF6e6dA5381E6)
- [mirror 0xbd…cd83](https://robinhoodchain.blockscout.com/address/0xbde7BEc47cbFc689e5E952B6cdD113A500abcd83)
- [reflections 0x66…877C](https://robinhoodchain.blockscout.com/address/0x666A51Eb731a9CF79d97B4A9c64cD5a4806c877C)
- [Download integration.md](https://www.quotrons.cash/integration.md)
- [Download manifest.json](https://www.quotrons.cash/integration/manifest.json)
- [Download router ABI](https://www.quotrons.cash/integration/QuotronWethRouter.abi.json)
- [Download token ABI](https://www.quotrons.cash/integration/Quotron404V2.abi.json)
- [Download hook ABI](https://www.quotrons.cash/integration/QuotronWethHook.abi.json)
- [Download quoter ABI](https://www.quotrons.cash/integration/QuotronWethQuoter.abi.json)
- [Download quotrons-llm.md](https://www.quotrons.cash/quotrons-llm.md)
- [/llms.txt](https://www.quotrons.cash/llms.txt)
- [/llms-full.txt](https://www.quotrons.cash/llms-full.txt)
- [0x36…FB32](https://explorer.inkonchain.com/address/0x360E68faCcca8cA495c1B759Fd9EEe466db9FB32)
- [0x8b…30cc](https://explorer.inkonchain.com/address/0x8bb4516059F9149Bc3b89018Fc7537f1F14a30cc)
- [0xbF…d3A2](https://explorer.inkonchain.com/address/0xbFA531C90FD9e42aC13Af14823B30e40761dd3A2)
- [0xFd…B33F](https://explorer.inkonchain.com/address/0xFd30F33dE4A2dA00c5c844Acef5728535B95B33F)
- [0x2E…6C2C](https://explorer.inkonchain.com/address/0x2E1509FBc75b621d08F64d8328a3C4152cf96C2C)
- [0x0A…7A07](https://explorer.inkonchain.com/address/0x0Aa7abB778DC11Dcaa1dBB16B72c70dD6f2d7A07)
- [0x73…5E03](https://explorer.inkonchain.com/address/0x73F5111EE91672c114923793C03B5c868d9C5E03)
- [0x65…7D78](https://explorer.inkonchain.com/address/0x6560417F6Df140597c3d2811ED833cD9a70e7D78)
- [0x76…5B21](https://explorer.inkonchain.com/address/0x76fDf913c2bc8AF5ce545B5C27B18bEF51245B21)
- [0xe3…491D](https://explorer.inkonchain.com/address/0xe343167631d89B6Ffc58B88d6b7fB0228795491D)
- [0x07…6c76](https://explorer.inkonchain.com/address/0x0707F946992b32F53652FFdFdD015bA8797a6c76)
- [0xf9…9888](https://explorer.inkonchain.com/address/0xf9084d029F8fb7c42b070C2df9F14EfBa18F9888)
- [0x79…c6B5](https://explorer.inkonchain.com/address/0x79A8a083721a4AcAa41A81b03c48ca95F24Ec6B5)
- [0x14…4b51](https://explorer.inkonchain.com/address/0x14576500103291c76F7723E740D21FEb05084b51)
- [Download the full kitLogos, wordmark, icons, banners, cards, animated GIFs and the usage rules · ZIP, ~28 MB ZIP](https://www.quotrons.cash/brand/quotrons-brand-kit.zip)
- [github.com/mavrkofficial/quotrons-brand-kit](https://github.com/mavrkofficial/quotrons-brand-kit)
- [Primary logoSVG · pixel-rect vector](https://www.quotrons.cash/brand/quotrons-logo.svg)
- [Primary logoPNG · 1024, transparent](https://www.quotrons.cash/brand/quotrons-logo-1024.png)
- [CirclePNG · 1024, avatars](https://www.quotrons.cash/brand/quotrons-logo-circle-1024.png)
- [SquarePNG · 1024, listings](https://www.quotrons.cash/brand/quotrons-logo-square-1024.png)
- [WordmarkSVG · ink](https://www.quotrons.cash/brand/quotrons-wordmark.svg)
- [Wordmark, whitePNG · 1200, for dark ground](https://www.quotrons.cash/brand/quotrons-wordmark-white-1200.png)
- [LockupPNG · mark + wordmark](https://www.quotrons.cash/brand/quotrons-lockup-h600.png)
- [App iconPNG · 512, full bleed](https://www.quotrons.cash/brand/icon-512.png)
- [MaskablePNG · 512, safe zone](https://www.quotrons.cash/brand/icon-maskable-512.png)
- [Icon, circlePNG · 1024, round slots](https://www.quotrons.cash/brand/icon-circle-1024.png)
- [Favicon.ico · 16 to 256](https://www.quotrons.cash/brand/favicon.ico)
- [X bannerPNG · 1500x500](https://www.quotrons.cash/brand/quotrons-banner-1500x500.png)
- [X banner, 2x masterPNG · 3000x1000](https://www.quotrons.cash/brand/quotrons-banner-3000x1000.png)
- [Square bannerPNG · 1500x1500](https://www.quotrons.cash/brand/quotrons-banner-1500x1500.png)
- [Small bannerPNG · 600x200](https://www.quotrons.cash/brand/quotrons-banner-600x200.png)
- [Collection bannerPNG · 2400x900](https://www.quotrons.cash/brand/banner-2400x900.png)
- [Typing bannerGIF · boots, then types](https://www.quotrons.cash/brand/quotrons-banner-typing-1500x500.gif)
- [Boot-up logoGIF · 1024](https://www.quotrons.cash/brand/quotrons-logo-square-boot-1024.gif)
- [Boot-up logo, smallGIF · 100, OpenSea slot](https://www.quotrons.cash/brand/quotrons-logo-square-boot-100.gif)
- [Logo cardPNG · 1024, rounded](https://www.quotrons.cash/brand/quotrons-logo-card-1024.png)
- [Wordmark cardPNG · 1600x800](https://www.quotrons.cash/brand/quotrons-wordmark-card-1600x800.png)
- [Social cardPNG · 1200x630](https://www.quotrons.cash/brand/og-card.png)
- [CoverPNG · 2560x1440](https://www.quotrons.cash/brand/cover-2560x1440.png)
- [WallpaperPNG · 2560x1440](https://www.quotrons.cash/brand/wallpaper-2560x1440.png)
- [KeypadPNG · 3584x1024](https://www.quotrons.cash/brochures/keypad-full.png)
- [Desk UnitPNG · 3584x1024](https://www.quotrons.cash/brochures/desk-unit-full.png)
- [Quotron 800PNG · 3584x1024](https://www.quotrons.cash/brochures/quotron-800-full.png)
- [NASDANK nightPNG · 3584x1024](https://www.quotrons.cash/brochures/nasdank-full.png)
- [About & Legal](https://www.quotrons.cash/about)
