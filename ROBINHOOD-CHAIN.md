# Robinhood Chain and Stock Tokens: Master Reference

One standing reference for every Robinhood Chain project.
Synthesized from all 26 official documentation pages plus 3 linked sub-pages, then verified against mainnet.

**Compiled:** 2026-08-12. **Refreshed:** 2026-09-02 (docs drift check, on-chain re-verification at block 52,266,372, roster re-read at block 52,437,900) and **2026-09-03** (full on-chain re-verification, every read pinned to block 53,117,114; details in `robinhood-chain/31-onchain-verification.md` and `robinhood-chain/CHANGELOG-2026-09-02.md`).
Each snapshot figure below carries its own capture date inline, because they were not all read on the same day.
**Sources:** `robinhood-chain/` holds a verbatim archive of every page, one file per URL.
**Verification:** `robinhood-chain/31-onchain-verification.md` records what was read directly from chain, and where the docs and reality diverge.

Values that move (prices, supply, multipliers, gas) are point-in-time snapshots.
Addresses, interfaces, and architecture are stable and are the reason this document exists.

---

## 1. What Robinhood Chain is

A permissionless, EVM-compatible Layer 2 built on **Arbitrum Dedicated Blockchains** (Arbitrum Nitro), settling to Ethereum, using **Ethereum blobs for data availability** and **ETH as the native gas token**.
It is purpose-built for tokenized real-world assets: equities, ETFs, and other financial instruments.

The flagship asset class is **Robinhood Stock Tokens**, ERC-20 tokens giving economic exposure to US equities and ETFs, issued by Robinhood Assets (Jersey) Limited.

Two design choices set it apart from a generic L2:

**First-come, first-served sequencing.**
Ordering is strictly by arrival time at the sequencer.
There are no priority gas auctions, and paying more will not move you ahead in the queue.
Any MEV strategy that assumes fee-based reordering does not transfer to this chain.

**Sequencer-level compliance screening.**
Transactions associated with sanctioned addresses are excluded from inclusion at the sequencer.
A blocked transfer is never processed, so it appears as though the event never occurred, which keeps indexers consistent with actual state.
Read operations (`eth_call`, `eth_getLogs`, balance queries) are unaffected.
This is a real behavioural difference: a transaction can be silently dropped rather than reverted, so do not build flows that assume every submitted transaction eventually lands or fails visibly.

## 2. Network connection

| Property | Mainnet | Testnet |
| --- | --- | --- |
| Chain ID | **4663** (`0x1237`) | **46630** |
| Native currency | ETH | ETH |
| Public RPC | `https://rpc.mainnet.chain.robinhood.com` | `https://rpc.testnet.chain.robinhood.com` |
| Sequencer feed | `wss://feed.mainnet.chain.robinhood.com` | `wss://feed.testnet.chain.robinhood.com` |
| Sequencer | `https://sequencer.mainnet.chain.robinhood.com` | `https://sequencer.testnet.chain.robinhood.com` |
| Explorer | `https://robinhoodchain.blockscout.com` | `https://explorer.testnet.chain.robinhood.com` |
| Status page | `http://status.robinhoodchain.offchain.io/` | - |

Public endpoints are rate-limited and explicitly not for production.

**Providers.** Alchemy is the recommended provider and supplies the RPC, Data API, and gasless transaction infrastructure.

| Endpoint | Mainnet | Testnet |
| --- | --- | --- |
| Alchemy RPC | `https://robinhood-mainnet.g.alchemy.com/v2/{API_KEY}` | `https://robinhood-testnet.g.alchemy.com/v2/{API_KEY}` |
| Alchemy WSS | `wss://robinhood-mainnet.g.alchemy.com/v2/{API_KEY}` | `wss://robinhood-testnet.g.alchemy.com/v2/{API_KEY}` |
| QuickNode | `https://{ENDPOINT}.robinhood-mainnet.quiknode.pro/{TOKEN}` | - |

Also supported: Blockdaemon, dRPC, Validation Cloud.
Historical reads and pinned fork tests need an **archive** endpoint, since public endpoints prune state after roughly 5,000 blocks.

**Verified at block 34,251,364 on 2026-08-12:** client `nitro/v3.11.2`, observed block time ~0.1 s, gas price ~0.0426 gwei, block gas limit 2^50 (the Arbitrum sentinel value, not a real budget).
**Re-verified at block 52,266,372 on 2026-09-02:** client `nitro/v3.11.3`, block time still 0.1 s, gas price 0.361 gwei (about 8.5x the August reading; Blockscout gas oracle 0.38 / 0.52 / 0.98 gwei), gas limit unchanged.
**Re-verified at block 53,117,114 on 2026-09-03:** chain id 4663 (`0x1237`), client `nitro/v3.11.3-beb2108/linux-amd64/go1.25.12` (same build hash as the day before), block time still 0.1 s over 100 blocks, gas price 472,640,000 wei (0.473 gwei), base fee 471,712,000 wei, gas limit still 2^50.
Between 2026-09-02 and 2026-09-03 only two of those moved: the block height, by 850,742 blocks in about 24 hours, and the gas price, by about 31 percent.
Gas price is the one chain parameter here worth re-reading before you quote it: 0.043 gwei on 2026-08-12, 0.361 on 2026-09-02, 0.473 on 2026-09-03.

## 3. Differences from Ethereum that will bite you

Contracts deploy unmodified, but Nitro semantics differ in ways that cause silent bugs.

| Behaviour | On Robinhood Chain | What to do |
| --- | --- | --- |
| `block.number` | Returns an estimate of the **L1** block number, updated only periodically | Use `ArbSys(0x64).arbBlockNumber()` for the real L2 height |
| `block.prevrandao` / `block.difficulty` | Constant | Never use for randomness; use Chainlink VRF |
| `blockhash(n)` | Reliable only for recent blocks | Do not use for old blocks or randomness |
| `block.coinbase` | Network fee account, not a validator | Do not treat as a miner address |
| `gasleft()` and gas estimation | Differ because fees have an L1 data component | Query pricing via `ArbGasInfo`; do not hardcode gas |
| `msg.sender` from L1 | **Aliased** L1 address (original plus fixed offset) | Apply/undo alias in access control; use SDK `applyAlias` |
| Max contract size | **96 KB** code, 192 KB init code (vs 24 KB on Ethereum) | Contracts too big for Ethereum can deploy here |
| Transaction ordering | First-come, first-served | Fee bumping does not reprioritize |
| Inclusion | Sanctioned-address transactions silently excluded | Do not assume every submitted tx resolves |

Full detail in `robinhood-chain/12-differences-from-ethereum.md`.

## 4. Gas, fees, and finality

A fee has two components, both bundled into the gas your transaction pays:

- **L2 execution fee**, gas used times L2 gas price. Low and stable.
- **L1 data fee**, the cost of posting calldata to Ethereum. Varies with Ethereum congestion and scales with calldata size.

Standard estimation (`eth_estimateGas`, wallet previews) accounts for both.
Because the L1 component scales with calldata, the highest-leverage optimization is **shrinking calldata**: pack arguments tightly, drop unnecessary data, and batch operations.

**Finality is staged.**

| Stage | Latency | Guarantee |
| --- | --- | --- |
| Soft confirmation (sequencer) | Sub-second | Sequencer committed to inclusion and ordering; reversible only if it posts a different order |
| Posted to Ethereum L1 Inbox | Minutes | Ordering fixed; reorg only if Ethereum reorgs |
| Ethereum finality | ~13 min after posting | Irreversible, inherits Ethereum security |

Use soft confirmations for everyday UX.
Wait for L1 posting or full finality for high-value or irreversible actions.

**Withdrawal delay is separate from finality.**
Moving assets back to Ethereum through the canonical bridge takes a **7-day challenge period**, a requirement of Arbitrum's fraud-proof system.

## 5. Bridging

| Route | Type | Speed | Best for |
| --- | --- | --- | --- |
| Arbitrum canonical bridge | Trustless L1 to L2 | Deposit ~10 min, withdrawal ~7 days | Trust-minimized ETH and ERC-20 movement |
| LayerZero OFT / Stargate | Omnichain token transfer | Minutes | WBTC, USDG, other OFTs |
| Chainlink CCIP / Transporter | Messaging plus token transfer | Minutes | Bridge-and-act flows |
| Relay | Intents | Seconds | Fast transfers, bridge-and-execute |
| Across | Intents | Seconds | Fast, capital-efficient |
| LiFi / 0x | Aggregators | Seconds to minutes | Swap-and-bridge in one step |

Withdrawing is three steps: initiate on L2, wait the 7-day challenge period, then **claim on Ethereum** with an L1 transaction that costs L1 gas.
That final claim is mandatory and easy to forget in UX design.

Failed deposits are not lost.
Deposits use Arbitrum retryable tickets and can be manually redeemed from the bridge interface within 7 days.

A bridged ERC-20 has a **different address on L2** than on Ethereum.
Resolve it with `calculateL2TokenAddress` on the L2 Gateway Router.

## 6. Robinhood Stock Tokens

### What they are, legally

Tokenized **debt securities** issued by Robinhood Assets (Jersey) Limited ("RHJ"), registration number 162428.
They give economic exposure to underlying securities but grant **no legal or beneficial rights** in, or against the issuer of, those underlying securities.

Not registered under US securities law.
May not be offered or sold to US persons, with further restrictions in Canada, the UK, and Switzerland.
Full prospectus and restricted-jurisdiction list: <https://docs.robinhood.com/rhj/>.
That is a second documentation space with its own app bundle, archived in full as `robinhood-chain/36-` through `43-`; note it 301s without the trailing slash.

Only **Authorised Participants** can mint directly with RHJ, after KYB onboarding.
At issuance the docs name only "BBVI"; `/rhj/service-providers` now names the Authorised Participant as **Bitstamp Global Ltd**, registered in Tortola, BVI, which is very likely what that acronym meant, though no captured source spells it out (`41-rhj-service-providers.md`).

**Corrected 2026-09-03: redemption is not Authorised-Participants-only.**
The issuer's own FAQ says a holder can redeem directly with the Issuer "where there is no authorized participant ... subject to completing the Issuer's KYC/AML (identity verification) processes" (`39-rhj-faq.md`).
So a retail redemption path exists, gated on KYC rather than on KYB onboarding.
Earlier text in this document and in `07-building-with-stock-tokens.md` said there was none.
Everyone else, including you, composes with tokens that already exist on the secondary market.
There is no permissionless mint path to design around.

### Issuer-side facts the chain docs do not carry

All from the issuer's own documentation space, archived as `36-` to `43-` and captured 2026-09-03.

- **The issuer is not regulated.** Robinhood Assets (Jersey) Limited holds "certain consents in Jersey" which it states explicitly are not prudential supervision and carry no Jersey-authority responsibility for its financial soundness (`36-rhj-about-the-issuer.md`).
- **The Base Prospectus was approved by the Financial Market Authority Liechtenstein** under the EU Prospectus Regulation (`40-rhj-product.md`).
- **One block confirmation constitutes a legal transfer.** That is a far weaker finality assumption than section 4 of this document describes for anything settling to L1, and it is the issuer's own position (`40-rhj-product.md`).
- **Redemption carries a 0.05% fee after 90 days**; subscription is 0.00% and redemption is 0.00% for the first 90 days. The Issuer can change these within the Final Terms limits (`40-rhj-product.md`).
- **Custody is Alpaca Securities LLC, a New York broker**, which sits oddly against a product that may not be offered to US persons. The Authorised Participant is Bitstamp Global Ltd (BVI), the paying account provider is JPMorgan Chase Bank N.A. London Branch, and the security agent is Security Agent Services AG (Zug) (`41-rhj-service-providers.md`).
- **On issuer insolvency**, the independent security agent sells the underlying shares and arranges for cash proceeds to be paid to token holders (`39-rhj-faq.md`).
- **The United Kingdom is a restricted jurisdiction**, alongside the US, Canada and Switzerland, and the issuer site requires a Professional Client attestation to use at all (`42-`, `43-`). Note the Pons launchpad front end independently geo-blocks UK IPs, so this is the second UK block in this archive.

### What they are, technically

Standard ERC-20, **18 decimals**, one contract per ticker, all on chain 4663.
They also implement **ERC-8056 (Scaled UI Amount Extension)**.

**96 tokens were active at the 2026-08-12 capture, all with `ASSET_STATUS_ACTIVE`; the roster had grown to 194 active tokens by 2026-09-02, with 98 added and none removed, and was still 194 when re-read on 2026-09-03 at block 53,117,114.**
Full table with addresses, ISINs, UIDs, multipliers, and matched feeds: `robinhood-chain/16-token-contracts.md`.

Base tokens:

| Symbol | Address |
| --- | --- |
| WETH | `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73` |
| USDG | `0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168` |

### Architecture: they are beacon proxies

Not documented anywhere by Robinhood, found by inspection.

All Stock Tokens (96 in August, 194 on 2026-09-02 and on 2026-09-03) have **byte-identical 283-byte bytecode** (the August text said 284 bytes; the correct figure is 283).
On 2026-09-03 `eth_getCode` was run over the whole roster at block 53,117,114 rather than sampled, and all 194 hash to one sha256, `399ec4bc5b43db03486ceae11f9a6fc5c126427f8f8e10c90fed0c773f4325c6`.
They are beacon proxies sharing one beacon and one implementation:

| Role | Address |
| --- | --- |
| Beacon | `0xe10B6f6B275De231345c20d14aB812DB62151B00` |
| Implementation | `0xb35490d6f9163de4f80d88dc75c3516eb64c5ae2` |

**One beacon upgrade changes the logic of all tokens at once (194 as of 2026-09-03).**
If your protocol accepts Stock Tokens as collateral, that is an upgrade dependency you are inheriting, and it is not per-token.
`owner()` on the beacon reverts because the beacon is not `Ownable`.
Resolved 2026-09-03: it is a verified contract named **`AccessControlsRegistry`** using OpenZeppelin `AccessControl`, where `upgradeTo` is gated by `BEACON_UPGRADER_ROLE`.

**`DEFAULT_ADMIN_ROLE` is held by `0xd6f8378f8e440c65f8382f5f2728c78dfd55b66d`, which is an externally owned account, not a multisig and not a contract.**
Because `DEFAULT_ADMIN_ROLE` administers every role by default, that one key can grant itself `BEACON_UPGRADER_ROLE` and replace the implementation behind all 194 Stock Tokens in two transactions, with no timelock and no notice period.
Weigh that against the Lighter deposit contract in section 8, which needs 3 of 5 Safe signatures plus 21 days for the same class of change.

The same registry carries the compliance machinery: `blockAccounts` / `isBlocked` gated by `BLOCKER_ROLE`, and a global `pause` gated by `PAUSER_ROLE`.
The blocklist is in active use, with `Blocked` fired for dozens of distinct addresses; `paused()` was false at block 53,117,114.
If you accept Stock Tokens, you are accepting that an address can be blocked and that transfers can be paused chain-wide for all 194 tokens at once.

### The multiplier (ERC-8056)

Corporate actions are handled by an on-chain **multiplier** rather than by rebasing.
Raw balances and total supply never change.
`balanceOf()` and `totalSupply()` are stable, which means Stock Tokens are safe for AMM pools and lending markets that break on rebasing tokens.

```
underlying shares = raw token amount x uiMultiplier() / 1e18
```

`uiMultiplier()` is 18-decimal fixed point, so `1e18` is 1.0.
At launch every token is `1e18`.
Dividends are **reinvested** into the multiplier, so a Stock Token tracks the **total return** of the underlying, not just its share price.
Over time the token price drifts above the headline share price, and this is expected, not a bug.

Interface, all confirmed live on every token:

```solidity
interface IScaledUIAmount {
    function uiMultiplier() external view returns (uint256);
    event UIMultiplierUpdated(uint256 oldMultiplier, uint256 newMultiplier, uint256 effectiveAtTimestamp);
    event TransferWithScaledUI(address indexed from, address indexed to, uint256 value, uint256 uiValue);
}

interface IScaledUIAmountNewUIMultiplier {
    function newUIMultiplier() external view returns (uint256); // staged value
    function effectiveAt()     external view returns (uint256); // when it activates
}

interface IScaledUIAmountBalances {
    function balanceOfUI(address account) external view returns (uint256);
    function totalSupplyUI()              external view returns (uint256);
}
```

Also present on-chain: `oraclePaused()` and `uid()`.
Absent on-chain (they revert): `owner()`, `version()`, `isin()`, `oracle()`.
ISIN comes from the REST registry, not from the contract.

**Trap: `effectiveAt()` is not cleared after an update lands.**
Seven tokens had a non-zero `effectiveAt()` with a timestamp in the past and `newUIMultiplier() == uiMultiplier()` on 2026-08-12; nine did on 2026-09-02 and ten on 2026-09-03, and no token has ever been observed with a genuinely scheduled change.
The tenth, `F`, picked up its multiplier at 15:10 UTC on 2026-09-02, the same minute of day as six of the others, so this is a scheduled accrual job and the count should be expected to grow.
Do not cache a multiplier across a session.
A non-zero `effectiveAt()` does **not** mean an update is pending.
Detect a genuinely scheduled change by comparing `newUIMultiplier()` against `uiMultiplier()`, or by testing `effectiveAt() > block.timestamp`.

Verified across all 96 tokens on 2026-08-12, all 194 on 2026-09-02 and all 194 again on 2026-09-03 at block 53,117,114 with zero failures: `totalSupplyUI() == totalSupply() * uiMultiplier() / 1e18` holds exactly.

### Update paths and oracle pauses

Robinhood updates the multiplier two ways:

- `updateMultiplier(uint256)` applies immediately. Used for small, continuous dividend reinvestments.
- `updateMultiplier(uint256, uint256 effectiveAt)` stages a value, exposed via `newUIMultiplier()` and `effectiveAt()`. Used for large, discontinuous actions like splits, and requires a scheduled pause window and manual confirmation.

During a corporate action the feed is **paused** so an inconsistent price is never published:

1. Robinhood calls `pauseOracle()`, freezing the feed at the last good value.
2. The new multiplier is staged or applied.
3. After the underlying price and multiplier agree, `unpauseOracle()` is called.
4. The feed resumes with the updated multiplier.

Read this state via `oraclePaused()` on the token.
Treat `true` as "price temporarily unavailable", not as zero or stale.
**The flag is advisory and not enforced on-chain**, so a paused oracle may still return a value.
Keep the `updatedAt` staleness check as your primary guard.

At capture, no token had `oraclePaused() == true`.

## 7. Prices

### On-chain: Chainlink feeds

Standard `AggregatorV3Interface`, read through the **proxy**.
Robinhood equity feeds return the **token** price, already multiplier-adjusted.
Do not apply the multiplier yourself.

```
Token Price = Underlying Equity Market Price x uiMultiplier()
```

```solidity
(, int256 answer, , uint256 updatedAt, ) = AggregatorV3Interface(PROXY).latestRoundData();
require(answer > 0, "bad price");
require(block.timestamp - updatedAt < HEARTBEAT, "stale price");
```

Most USD feeds use **8 decimals**, but call `decimals()` rather than hardcoding.

Presentation, same economics either way:

| You want | Compute |
| --- | --- |
| Token value (default) | feed price directly |
| Underlying share price | `feedPrice * 1e18 / uiMultiplier()` |
| Share-equivalent units | `balance * uiMultiplier() / 1e18` |

**56 feeds existed on Robinhood Chain on 2026-08-12 and all 56 returned live data when called; the directory listed 57 from 2026-09-02, the addition being `CBBTC / USD`, and on 2026-09-03 all 57 were called at block 53,117,114 and all 57 returned live data with none stale beyond twice its own heartbeat.**
35 are Robinhood tokenized-equity feeds and 22 are crypto, stablecoin, and exchange-rate feeds; the directory JSON refetched on 2026-09-03 is byte-identical to the 2026-09-02 copy, so nothing was added or removed in between.
All are 8 or 18 decimals (52 at 8 and 5 at 18, read on-chain 2026-09-03), 86400 s heartbeat on every one of the 57, 0.5% deviation threshold.
Full table: `robinhood-chain/11-chainlink-feed-addresses.md`.
Machine-readable source: <https://reference-data-directory.vercel.app/feeds-robinhood-mainnet.json>.

**Three gaps between the docs and reality:**

1. **Only 35 of 96 Stock Tokens had a Chainlink feed on 2026-08-12, and still only 35 of 194 on 2026-09-03 (159 without).** Checked symbol by symbol on 2026-09-03: all 35 equity feeds match a token that exists, and no feed points at a token that does not, so 159 is exact rather than a subtraction. The docs say every Stock Token has a live price feed. Handle the missing-feed case explicitly rather than assuming coverage.
2. **No L2 Sequencer Uptime Feed is published for Robinhood Chain, and there never will be.** The docs recommend checking one before trusting a price and give sample code, but the Chainlink directory lists none for this network, re-confirmed 2026-09-03 across all 57 feeds.
Chainlink's own page now carries a caution added between the 2026-09-02 and 2026-09-03 captures: **"Chainlink is no longer expanding L2 Sequencer Uptime Feeds to additional networks"** (`24-chainlink-l2-sequencer-feeds.md`).
Robinhood Chain is not among the 11 supported networks, so this is not a gap waiting to be filled.
Anything you build here needs a different staleness guard: check each feed's own `updatedAt` against its heartbeat rather than asking whether the sequencer is up.
3. **On-chain `description()` is inconsistent, in three different ways.** Read from chain on 2026-09-03: 23 of the 35 equity feeds return `Robinhood <SYM> / USD`, 9 return `RH<SYM> / USD` (SPY, TSLA, SNDK, INTC, MU, NVDA, USO, MSFT, AMD), and 3 return `Robinhood <SYM>-USD` with a hyphen and no spaces (SGOV, USAR, DELL). Never match feeds by parsing `description()`.

Observed feed update ages ranged from about 15 minutes to about 15 hours on 2026-08-12, and from 18 minutes to 13.9 hours across all 57 feeds on 2026-09-03, measured against the timestamp of block 53,117,114 itself: well inside the 24-hour heartbeat, but far from tick-by-tick.
For low-latency data use Data Streams.

### On-chain: Chainlink Data Streams

Pull-based, sub-second latency, signed off-chain reports verified on-chain.
Suited to perps, options, liquidations, and high-frequency strategies.

| Network | VerifierProxy |
| --- | --- |
| Robinhood Chain | `0xcE73c8ad08CBDEaCa6078BF0627C8fe0a9a536E7` (verified deployed, 7,009 B) |

Call `verify()` on that contract to authenticate a report before acting on it.
SDKs in Go, TypeScript, and Rust; REST and WebSocket access; dashboards at <https://data.chain.link/streams>.

### Off-chain: Robinhood REST API

Read-only, base `https://api.robinhood.com/rhj/`, **60 req/s**, cached.
No authentication was required for `/assets` at capture.

| Endpoint | Cache | Returns |
| --- | --- | --- |
| `GET /rhj/assets` | - | Asset metadata, deployments, current and pending multiplier, logo, trading capabilities |
| `GET /rhj/prices/{symbol}` | 15 s | Raw underlying-equity bid/ask, volume, halt flag |
| `GET /rhj/corporate-actions` | 1 hour | Processed corporate actions, most recent first. **A rolling window, about one month**: on 2026-09-03 it started 2026-08-05, so it does not contain CRWD's 4:1 split of 2026-07-02, nor ORCL, MU or DELL. Poll and archive it if history matters |
| `GET /rhj/price-deviations` | not recorded | Disclosed deviations between the on-chain price and the underlying's reference price. Empty at capture 2026-09-03 |

**Critical: the two price surfaces are not the same number.**
REST `/prices` returns the **raw underlying-equity** bid/ask, **not** multiplier-adjusted.
The Chainlink feed returns the **multiplier-adjusted token** price.
If you mix them, apply `currentMultiplier` from `/assets` to convert, or you will misprice every token whose multiplier has drifted from 1.0.

Always pass `/{symbol}` on `/prices` to avoid extra latency.

Use `/corporate-actions` to reconcile *why* a multiplier changed: a `FORWARD_SPLIT` entry with `oldRate`/`newRate` explains the corresponding `uiMultiplier()` update.
Types active at launch are forward split, reverse split, cash dividend, and stock dividend; the rest of the enum is forward-compatibility only.

**The documented `/assets` schema is stale.**
The live response differs from the docs:

| Field | Docs | Live |
| --- | --- | --- |
| `tradingCapabilities` | `fractionalTradability`, `allDayTradability`, `extendedHoursFractionalTradability` | `market` / `extended` / `overnight`, each with `whole` and `fractional`, valued `TRADING_STATUS_*` |
| `tokenDecimals` | absent | present (18) |
| `isin` | absent | present |
| `deployments[].networkName` | absent | present |

Code against the live response, not the documented schema.

**Registry integrity.** All 96 tokens were cross-checked field by field against chain state on 2026-08-12, all 194 on 2026-09-02, and the roster count was confirmed at 194 again on 2026-09-03.
Zero mismatches on symbol, name, decimals, `uiMultiplier`, and `uid`.
The REST registry is a faithful mirror, so it is safe for discovery.
Still read prices and multipliers on-chain when they drive money movement.

## 8. Liquidity and trading

Stock Tokens are plain ERC-20s and transfer in any wallet.
Trading routes:

| Venue | Mechanism | Notes |
| --- | --- | --- |
| RFQ | Signed market-maker quotes via 0x RFQ, 1inch Fusion, LiFi | Primary route at launch; off-chain quotes, so not composable inside a contract call |
| AMM | Uniswap pools | Fully composable on-chain |
| propAMM | Rialto | Market-maker-backed but on-chain, so composable, unlike RFQ |
| Orderbook | Lighter (spot and perps) | Dedicated Robinhood Chain instance, own contracts and sequencer; see below |
| Direct mint | With RHJ | Authorised Participants only (Bitstamp Global Ltd), KYB required |
| Direct redemption | With RHJ | Also open to a holder where there is no authorized participant, subject to the Issuer's KYC/AML (`39-rhj-faq.md`) |

If your design needs to trade Stock Tokens **inside a smart contract**, RFQ will not work: the quotes are off-chain signatures.
Use an AMM or propAMM route for atomic on-chain composition.

### Lighter on Robinhood Chain

Lighter runs a **dedicated instance** on this chain with its own contracts, sequencer, blockspace and liquidity.
It is not Lighter Core, and the two do not share liquidity (`34-lighter-domains.md`).

| Resource | Value |
| --- | --- |
| Lighter contract | `0x94bAB9693Ba2f6358507eFfcbd372b0660AFfF9d` |
| Public UI | <https://robinhoodchain.lighter.xyz> |
| API base | <https://api.rh.lighter.xyz/> |
| API docs | <https://apidocs.rh.lighter.xyz/docs/get-started> |

Verified from chain at block 53,117,114 on 2026-09-03: the contract holds 1,367 bytes of code and is an **EIP-1967 transparent proxy**.
Its implementation slot points at `0x82de5b1161c93afdfe21ba0d5343f01cd7401d90` (23,168 B) and its admin slot at `0x43cff77cd060a155dce5deb12b93b875f69f2716` (4,116 B, so a ProxyAdmin contract rather than an EOA).
The docs page does not say the address is a proxy; treat the Lighter deployment as upgradeable.
Who controls it was resolved on 2026-09-03.
The admin is not an OpenZeppelin `ProxyAdmin` at all but a verified **`UpgradeGatekeeper`**, a zkSync-lineage upgrade controller, which is why every standard ownership accessor reverted on it.
An upgrade needs **3 of 5** signatures on the Safe at `0x8caf9ff9392f39e87cbc65a130c026caacd321ef` and then a **21-day** notice period, and six upgrades have already completed (`versionId()` = 6, `upgradeStatus()` = 0, idle).
The notice period can be shortened by `cutUpgradeNoticePeriod`, and the security council that can do it, `0x4972e0cacb2ac45644ba054838e96ff4f6f7efdb`, is a single externally owned account.
Full read in `robinhood-chain/31-onchain-verification.md`.

Same-chain deposits call the contract directly:

```solidity
function deposit(
    address _to,
    uint16  _assetIndex,          // 3 = USDG
    TxTypes.RouteType _routeType, // uint8, 0 for a direct deposit
    uint256 _amount               // USDG is 6 decimals, so 1 USDG = 1000000
) external payable
```

Anyone may call `deposit` on behalf of any address, and the account is created on the first deposit.
Cross-chain deposits use `createIntentAddress` instead: send USDG to the returned deterministic address and Lighter's monitoring service calls `deposit` for you via CREATE2.
Withdrawals come in a fast mode using the chain's soft finality and a secure mode using full L2 finality.

## 9. Contract addresses

### L2 (Robinhood Chain), all verified deployed

Every address in this table returned bytecode from `eth_getCode` at block 53,117,114 on 2026-09-03, at the same byte count as on 2026-09-02 and 2026-08-12.

| Contract | Address |
| --- | --- |
| L2 Gateway Router | `0x1E324B9316138CA9a73F960213621AD1aaf01B89` |
| L2 ERC20 Gateway | `0xfd9b17206278C16DdaacF6AC8f05dBf97EdCb31e` |
| L2 Arb-Custom Gateway | `0x912285144fC0f6e89d3Ed16F5Ab72f87A1878959` |
| L2 Weth Gateway | `0x1D187C3E2dA52D72BC9C41e3AbA0fdFa6a7bF055` |
| L2 Proxy Admin | `0xa3Acd31AFb851B4eB9DAD00F5204c01D924267dF` |
| L2 Multicall (per docs) | `0x2cAC2D899eCC914d704FeaAE33ac1bF36277DaD1` |
| **Multicall3 (canonical, undocumented)** | `0xcA11bde05977b3631167028862bE2a173976CA11` |
| Permit2 | `0x000000000022D473030F116dDEE9F6B43aC78BA3` |
| **CREATE2 deployer (undocumented)** | `0x4e59b44847b379578588920cA78FbF26c0B4956C` |
| Data Streams VerifierProxy | `0xcE73c8ad08CBDEaCa6078BF0627C8fe0a9a536E7` |

Multicall3 at its canonical cross-chain address is not in the docs but is deployed and working, 3,808 B at block 53,117,114 on 2026-09-03.
It makes batched reads dramatically cheaper: the verification pass behind this document read 960 token fields in 4 RPC calls.
The CREATE2 deployer being present means Foundry's deterministic deployment works out of the box.

### Ethereum L1 core

| Contract | Mainnet | Testnet (Sepolia) |
| --- | --- | --- |
| Rollup | `0x23A19d23e89166adedbDcB432518AB01e4272D94` | `0xdc5F8E399DBd8a9F5F87AeC4C23Beb12431b386D` |
| Sequencer Inbox | `0xBd0D173EEb87D57A09521c24388a12789F33ba96` | `0xA0D9dB3DC9791D54b5183C1C1866eFe1eCA7D414` |
| Delayed Inbox | `0x1A07cc4BD17E0118BdB54D70990D2158AbAD7a2D` | `0xF2939afA86F6f933A3CE17fCAB007907B6b0B7a4` |
| Bridge | `0xDf8755334ce7A73cCF6b581C02eA649AE3E864b3` | `0x96295BDad104eaD97cC08797b3dC68efF59CcF30` |
| Outbox | `0xf0ce991ea4A0d2400A4AB49b20ae333f6Dce3DE9` | `0x8D180Caf588f3Da027BEf1F42a106Da93F90b166` |
| L1 Gateway Router | `0x6a2E3a1e16FC29f27Ce61429746D558d656975bB` | `0xF6F11aAEE80875776C264d93B37B34cE437382D1` |
| CoreProxyAdmin / L1 Proxy Admin | `0x1232813BDd40aa9d53066A880dE78a4Be70B90FD` | `0x20d5d542c1bF0a3c295524Eaef336fC07e890622` |

Full L1 gateway set in `robinhood-chain/17-protocol-contracts.md`.

### Arbitrum precompiles (same address on both networks)

| Precompile | Address |
| --- | --- |
| ArbSys | `0x0000000000000000000000000000000000000064` |
| ArbInfo | `0x0000000000000000000000000000000000000065` |
| ArbAddressTable | `0x0000000000000000000000000000000000000066` |
| ArbFunctionTable | `0x0000000000000000000000000000000000000068` |
| ArbOwnerPublic | `0x000000000000000000000000000000000000006b` |
| ArbGasInfo | `0x000000000000000000000000000000000000006C` |
| ArbAggregator | `0x000000000000000000000000000000000000006D` |
| ArbRetryableTx | `0x000000000000000000000000000000000000006E` |
| ArbStatistics | `0x000000000000000000000000000000000000006F` |
| ArbOwner | `0x0000000000000000000000000000000000000070` |
| ArbWasm | `0x0000000000000000000000000000000000000071` |
| ArbWasmCache | `0x0000000000000000000000000000000000000072` |
| NodeInterface | `0x00000000000000000000000000000000000000C8` |

`NodeInterface` has **no bytecode**, which is correct, re-confirmed at block 53,117,114 on 2026-09-03.
It is a virtual contract simulated by the node during `eth_call`.
Never `eth_getCode`-gate on it, and never call it from a contract.

### ERC-4337, all verified deployed

All eight addresses returned bytecode from `eth_getCode` at block 53,117,114 on 2026-09-03; the three `SenderCreator` and two Safe addresses had never been captured before that pass.

| Contract | Address |
| --- | --- |
| EntryPoint v0.6.0 | `0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789` |
| SenderCreator v0.6.0 | `0x7fc98430eAEdbb6070B35B39D798725049088348` |
| EntryPoint v0.7.0 | `0x0000000071727De22E5E9d8BAf0edAc6f37da032` |
| SenderCreator v0.7.0 | `0xEFC2c1444eBCC4Db75e7613d20C6a62fF67A167C` |
| EntryPoint v0.8.0 | `0x4337084D9E255Ff0702461CF8895CE9E3b5Ff108` |
| SenderCreator v0.8.0 | `0x449ED7C3e6Fee6a97311d4b55475DF59C44AdD33` |
| Safe Module Setup v0.3.0 | `0x2dd68b007B46fBe91B9A7c3EDa5A7a1063cB5b47` |
| Safe 4337 Module v0.3.0 (EntryPoint v0.7.0) | `0x75cf11467937ce3F2f357CE24ffc3DBF8fD5c226` |

**EIP-7702 is also supported**, so existing EOAs can delegate to contract code and gain batching, sponsorship, and session keys without migrating to a new address.
AA providers: Alchemy (primary), ZeroDev, Privy, Dynamic.

## 10. Deploying

Standard tooling works unmodified: Foundry, Hardhat, ethers.js, viem, Wagmi.

Foundry:

```bash
export RH_RPC_URL=https://rpc.mainnet.chain.robinhood.com
forge create HelloRobinhood --rpc-url $RH_RPC_URL --private-key $PRIVATE_KEY --broadcast

forge verify-contract <address> src/HelloRobinhood.sol:HelloRobinhood \
  --chain-id 4663 --rpc-url $RH_RPC_URL \
  --verifier blockscout --verifier-url https://robinhoodchain.blockscout.com/api/
```

Hardhat:

```js
networks: {
  robinhood: { url: process.env.RH_RPC_URL, chainId: 4663, accounts: [process.env.PRIVATE_KEY] },
}
```

Testnet is chain ID 46630 with verifier URL `https://explorer.testnet.chain.robinhood.com/api/`.
Deploy to testnet first.

## 11. Cross-chain messaging

Arbitrum Nitro mechanisms throughout.
Use `@arbitrum/sdk` rather than hand-encoding.

Robinhood Chain is a custom chain, so register it once:

```js
import { registerCustomArbitrumNetwork } from "@arbitrum/sdk";
registerCustomArbitrumNetwork({
  name: "Robinhood Chain",
  chainId: 4663,
  parentChainId: 1,
  confirmPeriodBlocks: 45818,
  ethBridge: {
    bridge:         "0xDf8755334ce7A73cCF6b581C02eA649AE3E864b3",
    inbox:          "0x1A07cc4BD17E0118BdB54D70990D2158AbAD7a2D",
    sequencerInbox: "0xBd0D173EEb87D57A09521c24388a12789F33ba96",
    outbox:         "0xf0ce991ea4A0d2400A4AB49b20ae333f6Dce3DE9",
    rollup:         "0x23A19d23e89166adedbDcB432518AB01e4272D94",
  },
});
```

L1 to L2 uses retryable tickets through the Delayed Inbox, typically minutes, redeemable for 7 days if L2 execution fails.
Remember address aliasing on the receiving side.

L2 to L1 uses `ArbSys(0x64).sendTxToL1(...)`, then a claim through the Outbox after the 7-day challenge period.
Code for both directions is in `robinhood-chain/20-cross-chain-messaging.md`.

## 12. Governance and trust assumptions

Worth reading before you assume this chain is as neutral as a generic L2.

**Security Council of 8 signers.**
Robinhood holds 2 seats; 6 are independent.
Routine actions need 6 of 8 plus a **7-day on-chain timelock**.
Emergency actions bypass the timelock and need 7 of 8.

| Seats | Participant |
| --- | --- |
| 2 | Robinhood |
| 1 | BitGo, Inc. |
| 1 | Chainlink Labs |
| 1 | Fireblocks Trust Company |
| 1 | Offchain Labs |
| 1 | Paxos |
| 1 | Talos |

**Validators are permissioned.**
Dispute resolution uses BoLD (Bounded Liquidity Delay).
There are currently **two** validators, operated by Offchain Labs and Alchemy (`27-governance.md`).

**The sequencer and the validators are run by different parties, and the sequencer operator changed in the Terms of Service on or before 2026-09-02.**
The Terms now read "Robinhood operates a sequencer node that receives, records, and reports transactions on Robinhood Chain"; the earlier wording said Offchain Labs operated the sequencer on behalf of Robinhood (`29-terms-of-service.md` section 1).
This is not a contradiction of the validator line above: sequencing and validation are separate roles, and Offchain Labs still runs one of the two validators.
The practical reading is that ordering and inclusion, which is where the compliance screening sits, are now stated to be operated by Robinhood itself, while fraud proofs remain with two third parties.
The Terms also state the sequencer is non-custodial, cannot modify, reverse or cancel a submitted transaction, and carries no uptime guarantee.

Taken with sequencer-level compliance screening and the shared Stock Token beacon, the honest summary is: permissionless to *use* and *build on*, but with meaningful centralized control over inclusion, upgrades, and validation.
Say so plainly in any risk disclosure you write.

### Using the Robinhood Chain name, which is now a licensed trademark

New in the Terms of Service since 2026-08-12: sections 5.5 through 5.13 define the "Robinhood Chain Marks" and grant a conditional, revocable trademark licence over them (`29-terms-of-service.md`).
Anyone launching a token or a product on this chain is inside that licence whether or not they read it, so the constraints below are operational, not background reading.

**Pre-approved without asking (section 5.6).**
Factual identification and compatibility statements: "Deployed on Robinhood Chain", "Built on Robinhood Chain", "[Your Brand] - Powered by Robinhood Chain".
Developer tooling names such as `[project-name]-robinhoodchain-sdk`, but not `robinhood-chain` standing alone.
Educational and editorial content, and community channels that are clearly labelled as community-run.

**Prohibited outright (section 5.7).**
The Marks may not be part of your own trademark, trade name, logo, **domain name, social media handle or token name** (5.7(d)).
They may not appear in the artwork, iconography, **metadata or smart contract attributes of any NFT or token** (5.7(h)).
They may not be the most prominent element of a product, service or company name, and your own branding must be more prominent (5.7(c)).
Community channels must carry a disclaimer of non-affiliation (5.7(b)).
Logo assets must come from the official Brand Asset Library unmodified, and must follow the Brand Guidelines at `33-brand-guidelines.md`, which are incorporated by reference (5.8).

**Requires prior written consent (section 5.11).**
Using the Marks as part of a product, company or **token name**, and using them **in connection with a token issuance or similar fundraising event**.
Both are directly relevant to launching a token here, and neither is covered by the pre-approved list.

**Teeth.**
Breach terminates the licence automatically and without notice (5.12), triggers a trademark-specific indemnity (5.13), and section 12.14 carves trademark and IP claims out of the mandatory arbitration clause so Robinhood can go straight to court, seek injunctive relief, Lanham Act statutory and enhanced damages, disgorgement of profits and fees.
"Misleading Use" is defined broadly and judged by Robinhood's reasonable judgment (5.5(d)).

**Practical rule for a token launch on this chain.**
Do not put "Robinhood" or "Robinhood Chain" in the token name, symbol, contract name, token metadata, domain or social handle.
Describe the chain factually in prose instead, and keep your own brand the loudest thing on the page.
If the launch materials need more than that, ask first: `robinhoodchain@robinhood.com` is the contact named in section 17 for authorization requests and misuse reports.

## 13. Running a node

Nitro node in Docker, requires the Robinhood-provided chain info file.

| Requirement | Spec |
| --- | --- |
| CPU | Modern multi-core (8+), strong single-core |
| RAM | 64 GB minimum, 128 GB recommended |

Key flags:

- `--chain.info-files=/home/nitro/config/robinhood-chain-info.json` (required)
- `--init.genesis-json-file=/home/nitro/config/robinhood-genesis.json` (**mainnet only**; testnet has no custom genesis)
- `--parent-chain.connection.url` and `--parent-chain.blob-client.beacon-url` (your own L1 endpoints)
- `--node.feed.input.url=wss://feed.mainnet.chain.robinhood.com` for low-latency updates, and it must be `wss://`, not `https://`
- `--init.url=<SNAPSHOT_URL>` on first start to skip syncing from genesis

Mount the data directory at `/home/nitro/.arbitrum`.
The image runs as the `nitro` user, so mounting elsewhere leaves the node unable to persist chain data.

Full commands and troubleshooting in `robinhood-chain/26-run-a-full-node.md`.

## 14. Upgrades

The chain runs Arbitrum Nitro and periodically upgrades ArbOS on a scheduled on-chain activation.
An un-upgraded node stops cleanly at the upgrade block and resumes once updated, with no data loss or resync.
The notices table at <https://docs.robinhood.com/chain/notices-and-upgrades> was **empty** at capture, so there is no upgrade history to review yet.
Node operators should watch that page.

## 15. Integration checklist

Reading prices:

- [ ] Read through the feed **proxy**, never the aggregator
- [ ] Call `decimals()`, never hardcode
- [ ] Reject zero or negative answers
- [ ] Check `updatedAt` against the heartbeat as your **primary** staleness guard
- [ ] Check `oraclePaused()` on the token, but treat it as advisory only
- [ ] Handle the tokens with **no** Chainlink feed (61 of 96 on 2026-08-12, 159 of 194 on 2026-09-03)
- [ ] Do not apply the multiplier to a Chainlink price; it is already included
- [ ] Do apply the multiplier if you mix in REST `/prices`, which is raw underlying

Handling the multiplier:

- [ ] Detect scheduled updates via `newUIMultiplier() != uiMultiplier()`, not via non-zero `effectiveAt()`
- [ ] Subscribe to `UIMultiplierUpdated` to track corporate actions
- [ ] Reconcile against `/rhj/corporate-actions` for the reason behind a change, remembering it is a rolling ~1-month window and will not explain an older multiplier
- [ ] Remember tokens are **not** rebasing, so `balanceOf` is stable and AMM/lending integration is safe

Writing contracts:

- [ ] `ArbSys(0x64).arbBlockNumber()` for L2 block height, never `block.number`
- [ ] No `prevrandao`/`blockhash` randomness
- [ ] Account for address aliasing in L1-to-L2 access control
- [ ] Minimize calldata, since the L1 data fee dominates
- [ ] Do not build fee-bumping or priority-auction logic
- [ ] Handle silent non-inclusion from compliance screening

Risk disclosure:

- [ ] Stock Tokens are debt securities with no rights in the underlying
- [ ] Not available to US persons; restricted in Canada, UK, Switzerland
- [ ] All Stock Tokens (194 as of 2026-09-03) are upgradeable through one shared beacon
- [ ] 7-day withdrawal challenge period to Ethereum
- [ ] "Robinhood Chain" is a licensed trademark: keep it out of your token name, symbol, metadata, domain and handles, and clear any launch or fundraising use in writing first (section 12)
- [ ] Two permissioned validators (Offchain Labs and Alchemy); the sequencer is operated by Robinhood itself per the Terms of Service as of 2026-09-02, and screens transactions

## 16. Archive index

Verbatim page archive in `robinhood-chain/`.
Generated tables and verification results are marked.

| File | Contents |
| --- | --- |
| `01-overview.md` | Chain overview, ecosystem partner table |
| `02-connecting.md` | Network config, RPC endpoints, providers |
| `03-add-network-to-wallet.md` | Wallet setup |
| `04-bridging.md` | All bridge routes, canonical bridge mechanics |
| `05-blockscout-explorer.md` | Explorer landing page |
| `06-stock-tokens.md` | Stock Token overview and full legal disclaimer |
| `07-building-with-stock-tokens.md` | Use cases, venues, ERC-8056 integration code |
| `08-stock-token-apis.md` | REST API reference |
| `09-eip-8056.md` | Full ERC-8056 specification |
| `10-chainlink-tokenized-equity-feeds.md` | Chainlink Robinhood feed mechanics |
| `11-chainlink-feed-addresses.md` | **Generated** - all 57 feeds (56 in August plus `CBBTC / USD`), all 57 verified live on-chain 2026-09-03 |
| `12-differences-from-ethereum.md` | Nitro semantics differences |
| `13-gas-and-fees.md` | Two-part fee model |
| `14-transaction-finality.md` | Finality stages |
| `15-arbitrum-compliance-filtering.md` | How sequencer screening works |
| `16-token-contracts.md` | **Generated** - all 194 tokens (regenerated 2026-09-02), addresses, ISINs, UIDs, multipliers, feeds |
| `32-explorer-and-data-apis.md` | Blockscout API and verification, Dexscreener, Goldsky, Alchemy Data APIs, Uniswap Trading API, all live-tested 2026-09-02 |
| `33-brand-guidelines.md` | Brand guidelines page added to the docs site in August 2026 |
| `34-lighter-domains.md` | Lighter Robinhood Chain instance: contract address, API hosts, deposit and withdraw paths (new page, captured 2026-09-03) |
| `35-privacy-statements.md` | US, UK and EU privacy statements (new page, unlinked from the sidebar, captured 2026-09-03) |
| `36-rhj-about-the-issuer.md` | **The issuer.** Robinhood Assets (Jersey) Limited, LEI, registered address, and its own statement that it **is not regulated** |
| `37-rhj-corporate-actions.md` | What a corporate action does to a token, the trading pause window, and the live dividend feed |
| `38-rhj-price-deviations.md` | The 5%-for-seven-days disclosure test between on-chain price and the underlying |
| `39-rhj-faq.md` | Holder-facing terms: 1:1 backing, custody, dividends as a multiplier, redemption, insolvency waterfall |
| `40-rhj-product.md` | Base Prospectus authority (FMA Liechtenstein), fee schedule, and **1 block confirmation as a legal transfer** |
| `41-rhj-service-providers.md` | Authorised Participant, broker, custodian, paying agent, tokenizer, security agent |
| `42-rhj-restricted-jurisdictions.md` | Restricted jurisdictions, including the **United Kingdom**, and the Prohibited Investor list |
| `43-rhj-use-of-website.md` | The issuer site's own terms, including a **Professional Client** attestation |
| `CHANGELOG-2026-09-02.md` | What changed in the docs between the two captures |
| `17-protocol-contracts.md` | L1/L2 protocol contracts and precompiles |
| `18-deploy-smart-contracts.md` | Foundry and Hardhat deployment |
| `19-account-abstraction.md` | ERC-4337, EIP-7702, provider quickstarts |
| `20-cross-chain-messaging.md` | Retryable tickets, ArbSys, SDK code |
| `21-oracles-and-price-feeds.md` | Feed integration and best practices |
| `22-data-streams.md` | Data Streams and VerifierProxy |
| `23-chainlink-data-streams.md` | Chainlink Data Streams reference |
| `24-chainlink-l2-sequencer-feeds.md` | Sequencer uptime feed pattern |
| `25-alchemy-robinhood-quickstart.md` | Alchemy API quickstart |
| `26-run-a-full-node.md` | Node operation |
| `27-governance.md` | Security Council, validators |
| `28-notices-and-upgrades.md` | Upgrade notices (empty at capture) |
| `29-terms-of-service.md` | Full terms |
| `30-report-issue.md` | Contact |
| `31-onchain-verification.md` | **Generated** - full on-chain verification results |
| `_raw/` | Untouched Tavily extractions, API responses, on-chain dumps |

Original link list: `robinhood-chain-links.md`.

## 17. Key contacts and canonical links

| Purpose | Link |
| --- | --- |
| Docs | <https://docs.robinhood.com/chain> |
| Explorer | <https://robinhoodchain.blockscout.com> |
| Status | <http://status.robinhoodchain.offchain.io/> |
| Chainlink feeds | <https://docs.chain.link/data-feeds/price-feeds/addresses?network=robinhood> |
| Feed directory (JSON) | <https://reference-data-directory.vercel.app/feeds-robinhood-mainnet.json> |
| RHJ prospectus and restrictions | <https://docs.robinhood.com/rhj/> (301s without the trailing slash) |
| Technical issues, vulnerabilities, partnerships | chain-developers-group@robinhood.com |
| Robinhood Chain Marks: authorization requests and misuse reports | robinhoodchain@robinhood.com |
| Analytics | <https://arbdata.com/ecosystems/robinhood> |

---

## Caveats

The verbatim archive under `robinhood-chain/` preserves source wording and punctuation exactly, including em dashes, so it is a faithful record.
This master document is original writing.

Docs pages captured 2026-08-12; on-chain state captured at block 34,251,364 the same day.
Refreshed 2026-09-02: docs re-extracted and diffed (one new page, four pages changed), chain re-verified at block 52,266,372, token roster re-read at block 52,437,900 (194 tokens).
Refreshed again 2026-09-03: every on-chain figure in this document re-read at a single block, 53,117,114, covering chain parameters, the 22-address deployment table, all 194 token contracts, all 57 Chainlink feeds and the ERC-8056 interface probe.
Two multiplier tables in `robinhood-chain/31-onchain-verification.md` were corrected on that pass, where the write-up's last few digits disagreed with the raw capture it came from.
Raw captures for that pass are in `robinhood-chain/_raw/onchain-2026-09-03/`.
Re-run the verification before trusting the moving values in a production decision.
