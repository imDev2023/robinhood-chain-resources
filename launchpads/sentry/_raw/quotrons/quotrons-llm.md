# QUOTRONS V2 — LLM Reference

Last updated 2026-08-13.

QUOTRONS is a 4,444-terminal ERC-404 collection on Robinhood Chain
(chain id 4663). V1 is permanently retired after a stale-approval
incident. V2 is a separate, newly deployed collection and does not
replace or mutate V1.

The V2 snapshot distribution was zero-action and is finalized. Eligible
dark terminals, hardwired terminals, fractional balances, and approved
restitution allocations were delivered directly. The canonical
QUOTRON/WETH pool is seeded, trading and hardwiring are live, and the
permanent fee is 3%.

The revealed assets are pinned to IPFS. The one-way metadata freeze
executed as part of launch, so the base URIs are immutable.

Promotional rewards are not dividends, investment income, equity, or a
share of profits. Nothing here is financial, investment, legal, or tax
advice.

## Token and terminal mechanics

- V2 preserves exactly 4,444 economic units:
  liquid supply + hardwired count × 1e18 = 4,444e18.
- One whole liquid QUOTRON materializes one dark terminal.
- Selling below a whole unit dissolves a dark terminal.
- Hardwiring burns exactly one liquid QUOTRON backing a chosen dark
  terminal.
- Hardwiring is permanent and irreversible.
- A hardwired terminal is a permanent ERC-721 and can claim its assigned
  promotional stock rewards.
- Pending rewards stay attached to the hardwired terminal ID when its NFT
  transfers.

Standard tiers and weights:

- Quotron I Keypad: 1.0x.
- Quotron II Desk Unit: 1.5x.
- Quotron 800: 2.5x.
- NASDANK Terminal: 5.0x.

Holding a STONK BROKER NFT increases an ordinary hardwired terminal's
live reward weight to 1.25x. Anyone can call `poke(id)` after the owner's
Broker status changes.

## One market and ten reward stocks

V2 has one canonical QUOTRON/WETH Uniswap v4 market. It does not have ten
QUOTRON/stock pools.

The ten tokenized stocks are reward conversion tracks:

`NVDA AAPL TSLA GME SPCX SPY PLTR NFLX RDDT MSTR`

Fresh WETH reward fees are converted in bounded epochs and deposited as
those stocks into the V2 reflections contract.

The three basket relics (#4441–#4443) each receive one third of a 12.5%
carve from every track's converted stock. The Gold Indicator (#4444)
receives 5% of every track's converted stock. V2 has no fresh PAXG
conversion route; migrated legacy PAXG credit remains claimable.

## Fee policy

The permanent base fee is 3%. At that rate:

- 2.0000% of volume funds stock rewards;
- 0.6375% compounds locked QUOTRON liquidity;
- 0.2125% buys and burns STONKBROKERS; and
- 0.1500% goes to the creator.

During the historical launch phase, before irreversible finalization:

- the keeper, registry-eligible wallets, and STONK BROKER holders pay 3%;
- the public fee is 90%; and
- a recipient that actually pays the 90% buy fee is transfer-restricted
  for one hour.

There is no six-hour V2 timer and no 40% V2 tier. The manual, one-way
finalization has executed, so every wallet now uses the 3% base fee.

## Reward epochs

The destination-locked epoch converter:

- requires at least 0.1 WETH to open an epoch;
- caps an epoch at 100 WETH;
- enforces at least 60 seconds between epochs;
- splits WETH equally among the ten reward tracks;
- uses sealed WETH -> USDG -> stock routes; and
- sends stock only to the reflections contract.

The Machine's Record displays a cumulative V2 reward total that does not
reset when an epoch opens. It adds all historical reward-pot pulls to the
live queue, then separately reports WETH already converted and allocated,
WETH in an active conversion, and WETH awaiting the next epoch. USD is
marked at the current ETH/USD price.

Each track's stock inflow is divided 82.5% to ordinary hardwired
terminals by weight, 12.5% to the three basket relics, and 5% to #4444.

## Canonical routing

The only supported route is:

`user -> QuotronWethRouter -> registered QUOTRON/WETH v4 pool`

The hook rejects every noncanonical sender and pool. The token requires a
one-shot PoolManager settlement authorization issued by that hook. Known
non-v4 venue code hashes can be banned, while EOA hashes cannot.
This prevents alternate v4 settlement; ordinary ERC-20 transfers remain,
so arbitrary future custom contracts are not claimed to be impossible.

Router API:

```solidity
buyExactEth(uint256 minQuotronOut, address recipient, uint256 deadline)
    payable returns (uint256 quotronOut);

sellExactQuotronForEth(
    uint256 quotronIn,
    uint256 minEthOut,
    address recipient,
    uint256 deadline
) returns (uint256 ethOut);
```

Sells require an ERC-20 allowance to the canonical router. Approve only
the needed amount. Aggregators quote with `QuotronWethQuoter` via
`eth_call` using `(amount, payer)`, then apply an explicit slippage
minimum and submit through the canonical router.

There is no hosted quote API key. Public integration files:

- Guide: `https://quotrons.cash/integration.md`
- Manifest: `https://quotrons.cash/integration/manifest.json`
- Router ABI:
  `https://quotrons.cash/integration/QuotronWethRouter.abi.json`
- Token ABI:
  `https://quotrons.cash/integration/Quotron404V2.abi.json`
- Hook ABI:
  `https://quotrons.cash/integration/QuotronWethHook.abi.json`
- Quoter ABI:
  `https://quotrons.cash/integration/QuotronWethQuoter.abi.json`

## V1 migration

The V2 Merkle distribution preserved eligible exact IDs and hardwire
state, delivered reviewed fractional allocations and restitution, and
excluded post-cutoff purchases on every venue (OpenSea, unofficial
external pools, or direct transfers). Dark ownership and balances froze
at halt block 34984482; eligible hardwired ownership followed V1 NFTs
through block 35337540.

Finalization required both full distribution of the committed cap and a
zero migration-reserve balance. It permanently closed all remaining
claim, assignment, handoff, fractional, and restitution entrypoints.
The website's V1 Migration Record is now read-only, except for safe V1
operator revocation.

The zero-action distribution did not take V1 NFTs or move accrued V1
rewards. Those remain separate V1 entitlements; V2 terminals accrue new
V2 epoch rewards.

V1's final historical record is **$113,849.84** in tokenized-stock
rewards generated for hardwired holders (displayed as **$113,850**).
This frozen archive uses the final onchain V1 fee pots, the exact 80/17
reward-to-burn ratio, and the stock marks used for final V1 accounting.
It is not a live balance or a current-price valuation. Audit data:
`/migration/v1-historical-rewards.json`.

## Disclosed controls

- The owner can pause the core and hook, manage non-EOA venue codehash
  bans, and irreversibly finalize the base fee.
- The blacklist guardian can freeze addresses but cannot remove a freeze.
- The recovery administrator can add or remove freezes.
- A Safe with threshold at least two is the recovery administrator.
- The Safe can forcibly move V2 ERC-20 balances or terminal NFTs between
  eligible non-protocol accounts.
- Protected protocol accounts cannot be arbitrary recovery targets.
- Actions emit onchain events.

Guardian:
`0x7171E64E979265aeD6588577D1c6b60A701d7866`

Recovery Safe:
`0x15277aA1ecC13734d57C519a2DAA1cc4A748bA89`

These controls are explicit trust assumptions. Metadata base URIs and
the ERC721-C transfer validator become immutable at launch. The V2
mirror clears individual token approvals on base-driven ownership and
approval-domain transitions; wallet-wide operator approvals remain the
wallet owner's choice.

## NFT creator earnings

The V2 mirror uses ERC721-C transfer validation. The intended creator
earning is 5%: 4% to the keeper and 1% to the creator. Venue
compatibility depends on support for the transfer validator and payment
split. This is separate from the token-market creator carve.

## Production V2 addresses

- Core: `0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F`
- Mirror: `0x027ACa2794E44f24950D81227DcD516FfBB49d6e`
- Reflections: `0xe04fba61FD54Ba78Dd450A30d8Af40167aF5d3Ec`
- Hook: `0x62E200Cc8e4D95cf622f40Dd70f407C883EcB0cc`
- Router: `0x42024fCFdB4F3089Dd619A0cEF0Cd24E7b841C18`
- View quoter: `0xb8960fdC8A0Be155d196C2795b75747763562df2`
- Eligibility registry: `0x94CfC3798Ca6320Ac5e6af04484EFE90bD04aC81`
- Epoch converter: `0x24e62Dd5C7058CC41ad9c5375C137460ea1Da2FE`
- WETH burn vault: `0xd1258efafa9d1B1d09c86403139Db78465540760`
- Burn adapter: `0x59b09A326984dd3c1076B864aa27F0BDd9876f0a`
- Finalized migrator: `0x205E13e6Ec07baa4eD1c57d677DE9FeE1C88Cd6D`
- Empty migration reserve: `0xCF39cb2363f85d3adad4fF891bb357C1766ef292`
- Fractional sink: `0x077403e402B63Da54a594Cbd2CfC46DbC92927ad`
- Locked LP vault: `0x4b7A4F53D9b7E4B4941bc9CF74e852D55444cCBe`
- Liquidity seeder: `0xCc949C33860E0F695be3373628955D77Dd922Fee`
- Royalty splitter: `0xd8eb805e96B05cb412A1e48eb3a85B6267f901d7`

Pool id:
`0x0b142aaf734f1b063355bfe854e282a13b26dcac86e2e564e74540f9b218d069`

## Metadata

- Dark images:
  `ipfs://bafybeibxh5bcdw353ufuprmzyzmk4wwtptjkym7em6igmmwp4izzoxrjym/`
- Hardwired animations:
  `ipfs://bafybeicmrosixas4ry3mp6afuevniqbqzq72to2n65ys5umuqqzijzsmsm/`
- V2 dark metadata:
  `ipfs://bafybeig447r5kqu34u2qm5aklrvgk5igor6qe6o7ng6wmuj2vet3idiwhe/`
- V2 hardwired metadata:
  `ipfs://bafybeigl2vkhz4pwib27k6l6g5nqsvp5i6zgnhogc27csap3cltlvvx5mi/`

## Risks

- Smart contracts, wallets, marketplaces, RPCs, and the chain can fail.
- The canonical market can be volatile and illiquid.
- A 90% launch fee is intentionally punitive; verify the actual onchain
  payer fee before signing. A recipient that pays it is
  transfer-restricted for one hour.
- Hardwiring is irreversible.
- Reward volume may never materialize.
- Tokenized stocks are third-party upgradeable assets.
- The guardian and recovery Safe are trust assumptions.
- Canonical v4 settlement is enforced, but arbitrary future custom
  contracts cannot be claimed to be impossible.
- Unsupported marketplaces may reject ERC721-C transfers or listings.
- Stock-token access is restricted in some jurisdictions, including the
  United States region.
- Never risk more than you can afford to lose completely.

The longer canonical reference is served at `/llms-full.txt`.
