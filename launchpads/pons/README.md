# Pons

Archived 2026-09-02.
Robinhood Chain, chain id 4663.

---

## 1. Identity

| field | value |
| --- | --- |
| Names in use | `pons` (the launch protocol), `pons.family` / `ponsfamily.com` (the launchpad front end), `PonsVault` (a second front end that attaches a revenue vault to a pons launch) |
| Legal entity | Pons Labs, LLC (footer of `pages/01-pons-home.md`) |
| Launchpad app | <https://www.ponsfamily.com/launchpad> |
| Create flow | <https://www.ponsfamily.com/launchpad/create> |
| Docs, v1 | <https://docs.ponsfamily.com/> (alias <https://docs.ponsfamily.com/docs>) |
| Docs, v2 | <https://docs.ponsfamily.com/v2> (alias <https://docs.ponsfamily.com/docs/v2>) |
| Vault front end | <https://www.ponsvault.com/> |
| Vault docs | <https://www.ponsvault.com/docs> |
| Contracts repo | <https://github.com/ponsdotdev/ponsfamily>, cloned at commit `845bd546b37515621e47b08015ce4f9d374f6eca` |
| X | [@ponsdotfamily](https://x.com/ponsdotfamily), [@PonsVault](https://x.com/PonsVault) |
| Contact | contact@ponsfamily.com. This is the only channel the project publishes: no Telegram, no Discord, no forum for support |
| CTO requests | <https://forms.gle/JjrWvybFeNfE5v8F6> |
| Chains | Robinhood Chain only |
| Capture date | 2026-09-02 |

Two front ends, one protocol.
`ponsfamily.com` is the launchpad itself and offers both generations behind a `v2 / v1` tab on the create page (`pages/03-pons-launchpad-create.md`).
`ponsvault.com` is a separate product by the same people that launches a token *through* the pons v2 factory and points its creator fees at a vault contract instead of at a wallet (`pages/18-ponsvault-docs.md`, Contracts).
PonsVault has its own X account, its own docs and its own contract set, and it is the only place a vault can be attached at launch.

`ponsfamily.com` geo-blocks the United Kingdom.
Requesting any page from a UK IP redirects to `/blocked?country=GB` (`pages/09-pons-blocked-geo.md`, `screenshots/45-ponsfamily-blocked-gb.png`).
Every ponsfamily page in this archive was therefore fetched through Jina Reader rather than a local browser.
`ponsvault.com` is not blocked and was driven live with `agent-browser`.

## 2. What it is

pons launches fixed-supply ERC-20 memecoins on Robinhood Chain, one signature per launch, with liquidity locked automatically and no ability for the creator to mint, freeze or re-tax afterwards.

There are two generations, both live, both accepting new launches today.

**v1** has no bonding curve.
`launchToken` mints the full supply and opens a one-sided Uniswap **V3** pool against WETH in the same transaction, then locks the position NFT in a locker contract.
The token trades in that pool from block one and never migrates.
"Graduation" in v1 only means the WETH paired in the locked pool crossed 4.2 ETH; nothing moves (`pages/10-docs-v1.md`, Graduation).

**v2** is a fair-launch curve.
The full supply mints to a per-launch constant-product bonding curve that trades in the same asset the future pool will use.
When the curve raises its threshold, the launch graduates permanently into a full-range Uniswap **v4** position, locked forever, governed by one shared hook (`pages/11-docs-v2.md`, Overview and Graduation; `pages/36-github-ponsfamily-contracts-readme.md`).

Who it is for: someone with no liquidity budget who wants a token with a real market from the first block.
The only ETH a v2 creator must spend is the 0.0005 ETH launch fee.
Everything the pool eventually holds is bought by the public through the curve.
That makes pons a direct fit for the stated goal of this archive, launching without seeding a pool.

The distinctive part is what a launch can be priced in.
A v2 launch does not have to be paired against ETH.
It can be paired against USDG or any of 23 tokenized Robinhood stock tokens, and when it is, that asset becomes the currency of the whole launch: buyers spend it, the pool holds it, and the creator is paid in it (`pages/11-docs-v2.md`, Custom pairs and Payouts).

## 3. How a launch works, step by step

### 3.1 pons v2, the current default

**Fields the creator fills in.**
From the live create form (`pages/03-pons-launchpad-create.md`) and the `launchToken` struct in `contracts/V2LaunchFactory-0x7eD598BcEf8bd9Edd8C97A195C6d13f40801EC7e/abi.json`:

- `name`, `symbol`, `logo` (an `ipfs://` URI), `description`
- `socials`: twitter, telegram, discord, website, farcaster, all optional strings
- `creatorFeeRecipient`, zero defaults to the caller
- `creatorTaxBps`, optional, capped at `maxCreatorTaxBps()` = 1000, that is 10%
- `buybackEnabled`, a bool
- `expectedEconomics`, a `bytes32` read from `previewLaunchEconomics(launchConfigId, pairToken)` immediately before sending, so the launch reverts rather than settling on terms the owner changed after your quote
- `salt`, a `bytes32` used for CREATE2, namespaced per initiating account, so a vanity address can be mined offline and confirmed with `predictLaunchAddresses`
- plus `launchConfigId` and `pairToken` as separate arguments, and an optional `address[]` of up to 32 snipe-tax-exempt wallets

**Cost to launch.**
0.0005 ETH, sent as `value`.
Read live from `PonsV2LaunchFactory.launchFee()` = `500000000000000` wei and confirmed by `/api/v2/status` (`_raw/api/pv-v2-status.json`) and by twelve real `launchToken` transactions in `_raw/blockscout/0x7ed598bcef8bd9edd8c97a195c6d13f40801ec7e.transactions-2026-09-02.json`, every one carrying exactly that value.
There is no minimum initial buy.

**Supply and the split.**
Launch config 0 is the only config (`launchConfigCount()` = 1) and reads, from `getLaunchConfig(0)`:

| field | value |
| --- | --- |
| `supply` | `1000000000000000000000000000`, that is 1,000,000,000 tokens at 18 decimals |
| `curveFeeBps` | 100, that is 1.00% |
| `phantomQuote` | `1680000000000000000`, that is 1.68 ETH |
| `graduationThreshold` | `4200000000000000000`, that is 4.2 ETH |
| `poolFee` | 0 |
| `tickSpacing` | 200 |
| `enabled` | true |

The curve holds back a reserved allocation for the future pool.
`PonsV2BondingCurve.sol` line 249 computes it as `supply * phantomQuote / (phantomQuote + graduationThreshold)`.
With 1.68 and 4.2 that is exactly **28.571% of supply reserved for the graduated pool and 71.429% sellable on the curve**, or 285,714,285 and 714,285,714 tokens.
Because every approved pair token has `graduationThreshold = 2.5 x phantomQuote` (checked across all 25 entries in `_raw/api/pv-v2-status.json`), that same 2:5 ratio, and therefore the same supply split, holds for every quote asset.

**Graduation threshold.**
4.2 ETH for an ETH-paired launch, shown in the create form as "Graduates once the curve raises 4.2 ETH" (`pages/03-pons-launchpad-create.md`).
For a non-ETH pair the threshold is denominated in that asset and read from `pairTokenEconomics(pairToken)`; see the table in section 4.

**Destination and fee tier.**
A full-range Uniswap **v4** position in the singleton PoolManager `0x8366a39CC670B4001A1121B8F6A443A643e40951`, minted by the graduation executor straight into `PonsV2LaunchLocker`, with tick spacing 200 and a **pool fee of 0**.
The pool charges no Uniswap fee of its own; the 1% is taken by the pons hook instead, so a trader pays the same rate before and after graduation (`pages/11-docs-v2.md`, Fees).

**Liquidity lock.**
Permanent.
`PonsV2LaunchLocker` exposes no withdrawal and no arbitrary-call function, by design (`pages/36-github-ponsfamily-contracts-readme.md`, Security).
Reading `contracts/V2LaunchLocker-0x267444D099b10fB5Ed7c3Cc7B7c767AdcA574952/README.md` confirms the ABI has no such entry point.

**Fee splits.**
The live policy, read from `PonsV2MemeHook.currentFeePolicy()`:

| field | value |
| --- | --- |
| `protocolFeeRecipient` | `0x263ed295dAFaE1d9AAdD6E56c4B6F9f38eE019Dd` |
| `protocolFeeShareBps` | 3000 |
| `buybackBurnBps` | 5000 |
| `hookFeeBps` | 100 |
| `maxInternalPriceImpactBps` | 300 |

So on every trade, in either direction, in either phase:

1. 1.00% of the quote leg is taken as the standard fee (`curveFeeBps` on the curve, `hookFeeBps` in the pool).
2. 30% of that fee goes to the protocol.
3. The remaining 70% is the creator's bucket.
4. If the creator enabled buybacks, 50% of that bucket accrues to a buyback balance (`PonsV2BondingCurve.sol` lines 620 to 621) which is spent buying the token back; the rest is credited to the creator in the fee escrow.
5. The creator tax, whatever the creator set from 0 to 10%, is charged on top and goes entirely to the creator.

With buybacks on and no creator tax, a creator's cash share of a trade is 0.35% of volume in the pairing asset, plus 0.35% converted into their own token and locked.
With buybacks off it is the full 0.70% in the pairing asset.

**Vesting of the buyback.**
Bought-back tokens are not burned.
They go into `PonsV2BuybackVault` on a five-year linear vest, `VESTING_DURATION()` = `157680000` seconds, with a weighted-average clock so a fresh buyback does not inherit an old one's progress.
When released, the tokens split 30% protocol and 70% creator, the same ratio as the cash fee (`PonsV2BuybackVault.sol` lines 190 to 195).
Either beneficiary can trigger the release and it pays both.

**Creator rewards, how they arrive.**
Not pushed.
Balances accrue in `PonsV2FeeEscrow` and the creator withdraws them, per pairing asset, whenever they want (`pages/11-docs-v2.md`, Getting paid).
A creator with launches against different pair assets has a separate balance in each.

**Anti-snipe.**
An opening tax on buys only, read live from the factory: `snipeTaxStartBps()` = 9900 and `snipeTaxSeconds()` = 3.
Buys in the launch second pay 99%, decaying to zero across three seconds.
The launching address and the creator fee recipient are exempted automatically; a team can name up to 32 more wallets at creation, fixed thereafter.
Read `currentSnipeTaxBps(recipient)` before quoting, keyed to the wallet receiving the tokens (`pages/11-docs-v2.md`, Snipe protection).

**What a creator can still change afterwards.**
Exactly two things (`pages/11-docs-v2.md`, Creator controls):
the fee recipient, via `setCreatorFeeRecipient`, which moves the buyback share with it;
and whether buybacks run, via `setBuybackEnabled`, which only the creator can turn on and pons can only turn off.
Supply, pricing, pairing asset, tax and graduation terms are all fixed at creation.

**Community takeovers.**
Voluntary handover is immediate.
An involuntary one is proposed by pons and sits behind a public **3-day timelock**, then stays executable for a further 3 days before expiring.
Both windows are on-chain constants: `CREATOR_FEE_RECIPIENT_TIMELOCK()` = 259200 and `CREATOR_FEE_RECIPIENT_EXECUTION_WINDOW()` = 259200 seconds.
A creator moving their fees during the wait does not cancel the proposal, deliberately, so a stolen wallet cannot dodge recovery.

**Is the public gate open?**
Yes, as of 2026-09-02.
The v2 docs still say "Public launches are closed, so only whitelisted addresses can create a token for now" (`pages/11-docs-v2.md`, Audits).
That is stale.
`launchEnabled()` reads true, `/api/v2/status` reports `launchEnabled: true` and `publicReady: true`, and `canLaunch(0x1111111111111111111111111111111111111111)` returns true for an address that `whitelistedLaunchers()` says is not whitelisted.
Twelve public `launchToken` calls landed in the 50 most recent factory transactions, all within minutes of each other.

### 3.2 A real launch, decoded

Transaction `0xa2fd067d865efb751ba8f9759d9513caa124ce1e137fb0291bf34d0ac094a6d9`, the PAPERHANDS launch, captured in `_raw/blockscout-tx/`.
It is the clearest worked example because it does everything at once.

The sender `0x1b1eA76A09C5f3cb18F656aD08a90f339FdE4B1F` is an EIP-7702 delegated account, so the whole launch is one user confirmation containing several calls.
Inside it:

1. The vault factory `0x7e344f13…` or `0x3422A17c…` deploys the creator's vault as a BeaconProxy at a deterministic address, here `0x8b6a7475A35a3cB9B2FE82f7d9778e279F5a0905`.
2. `PonsV2LaunchAndBuy.launchAndBuy(...)` at `0xe33E9E479dF8802cb0866d5d05258bEc4cF62948` is called with `value` covering the launch fee plus the initial buy.

The decoded `launchAndBuy` arguments:

```
name                 Paperhands
symbol               PAPERHANDS
logo                 ipfs://Qmc19xLq4gZ7CgffinPBbNATj1zD6KFLeBrn3UwJbBUCrr
description          We sold. It pumped. $Paperhands ...
socials              ('https://x.com/RH_Paperhands', '', '', '', '')
creatorFeeRecipient  0x8b6a7475a35a3cb9b2fe82f7d9778e279f5a0905   <- the vault
creatorTaxBps        100                                          <- 1%
buybackEnabled       False
expectedEconomics    0xa9fc75d4203a33fe660e8fa32c74c3aa41c1fda4bf23d3a39b6bc22a1f8b1ca7
salt                 0xe09b731a5cddb756900b3c689a22e543ea804ec3e4f1e38c7b501d887902acf6
launchConfigId       0
pairToken            0x0000000000000000000000000000000000000000   <- native ETH
buyAmount            580000000000000000                           <- 0.58 ETH dev buy
minTokensOut         0
recipient            0x1b1ea76a09c5f3cb18f656ad08a90f339fde4b1f
snipeTaxExemptions   ()
```

The internal call trace shows `LaunchAndBuy` calling the factory, which calls the deployer, guard, executor, hook, buyback vault and locker in turn, then a `CurveBuy` on the freshly created curve `0x35b4E2C475eced13C918DdBa57fec750bE225E49` and a `TokenLaunched` event on the factory.
The launch fee arrives at the owner Safe as a `SafeReceived`.

Two more decoded `launchToken` calls, both plain ETH launches at config 0 with the 0.0005 ETH fee, are in `_raw/blockscout-tx/0xed43089d….json` and `_raw/blockscout-tx/0x2488ff8c….json`.

### 3.3 pons v1, still live

`launchToken` on the proxy factory `0xF4fC0CD27fC8EcF17E55eE4c3f7201897dF3eb75` mints 1,000,000,000 tokens, opens a Uniswap **V3** pool against WETH at the **1% fee tier** (`10000`), locks the position NFT and optionally runs a developer buy, all in one call.
Launch fee is the same 0.0005 ETH (`launchFee()` = `500000000000000`).

Fee split is 70% creator, 30% protocol for current launches, and 90/10 for tokens from the legacy factory, snapshotted per token and never changed (`pages/10-docs-v1.md`, Fees and burns).
That is confirmed on-chain: the live locker `0x10f2756e…` reads `protocolFeeShare()` = 30, the legacy locker `0x31ca5E10…` reads 10.

Anti-snipe in v1 is a two-block window: on the launch block only the creator's initial buy executes, and for the rest of the window each wallet may hold at most 5% of supply and buy at most 5.5%.
Selling and transfers are never restricted (`pages/10-docs-v1.md`, How launches work).

Protocol revenue in v1 funds a TWAP buyback of the PONS token with 80% of protocol fees, with 20% to operations.
pons describes this as not yet immutable.

### 3.4 PonsVault, launching with a vault attached

PonsVault launches through the same pons v2 factory and sets `creatorFeeRecipient` to a vault contract instead of a wallet, so the creator's fee share is spent on a rule rather than paid out (`pages/18-ponsvault-docs.md`).

The live form (`pages/19-ponsvault-launch-live-staking.md` through `pages/21-…-feeshare.md`) offers three choices:

| template | what it does with creator fees | extra fields |
| --- | --- | --- |
| Staking | Pays them pro rata to holders who stake the token in the vault. Nothing minted, nothing burned, staked supply leaves circulation | minimum fees before a payout, floor 0.1 ETH; optional lock period |
| RWA Dividend | Buys a tokenized stock and opens a claimable round. Holders claim by balance, no staking | dividend stock (one or more), minimum fees before a purchase, floor 0.1 ETH |
| Fee Share | No vault at all. Fees are addressed to a wallet derived from an X handle; that account signs in at `/claim` and the derived wallet claims from the pons escrow and forwards | the X handle |

The earlier Jina capture of the same page also listed **Stake & Burn** and **Buyback & Burn**; the live page on 2026-09-02 does not offer them in the public form, though the protocol-stats endpoint still counts 49 stake-burn and 19 buyback-burn vaults, and the himgajria partner desk has its own Stake & Burn factory.
Compare `pages/17-ponsvault-launch.md` with `pages/19-ponsvault-launch-live-staking.md`.

Every vault parameter is written once at creation and has no setter (`pages/18-ponsvault-docs.md`, Parameters).
There is no schedule: a run happens whenever accrued fees clear the minimum, triggered by anyone, with a PonsVault bot doing it as a convenience that holds no special permission.

## 4. Economics

Every number below was read on 2026-09-02 either from the chain or from a captured file, and the source is named.

### 4.1 pons v2

| item | value | source |
| --- | --- | --- |
| Launch fee | 0.0005 ETH | `launchFee()`; `_raw/api/pv-v2-status.json`; 12 real launch txs |
| Standard trade fee | 1.00% of the quote leg, both directions, both phases | `getLaunchConfig(0).curveFeeBps` = 100; `V2MemeHook.hookFeeBps()` = 100 |
| Uniswap pool fee after graduation | 0 | `getLaunchConfig(0).poolFee` = 0; `pages/11-docs-v2.md`, Fees |
| Protocol share of the standard fee | 30% | `V2MemeHook.currentFeePolicy()` field `protocolFeeShareBps` = 3000 |
| Creator share of the standard fee | 70% | same, by subtraction |
| Buyback share of the creator bucket | 50%, optional | same, `buybackBurnBps` = 5000; `PonsV2BondingCurve.sol` L620 |
| Creator tax | 0 to 10%, set at creation, 100% to the creator | `maxCreatorTaxBps()` = 1000 |
| Hard caps in code | curve fee <= 10%, creator tax <= 10%, total trade fee <= 20% | `pages/36-github-ponsfamily-contracts-readme.md` |
| Total supply | 1,000,000,000, 18 decimals | `getLaunchConfig(0).supply` |
| Sold on the curve | 714,285,714, that is 71.429% | derived from `PonsV2BondingCurve.sol` L249 |
| Reserved for the pool | 285,714,285, that is 28.571% | same |
| Graduation threshold, ETH pair | 4.2 ETH | `getLaunchConfig(0).graduationThreshold` |
| Opening price seed (phantom quote), ETH pair | 1.68 ETH | `getLaunchConfig(0).phantomQuote` |
| Snipe tax | starts 9900 bps, decays to 0 over 3 seconds, buys only | `snipeTaxStartBps()`, `snipeTaxSeconds()` |
| Snipe exemptions | up to 32, fixed at creation | `pages/11-docs-v2.md` |
| Buyback vest | 5 years linear, weighted clock, released 70/30 creator/protocol | `VESTING_DURATION()` = 157680000; `PonsV2BuybackVault.sol` L190 |
| CTO timelock | 3 days to take effect, 3 more days to execute before expiry | `CREATOR_FEE_RECIPIENT_TIMELOCK()`, `..._EXECUTION_WINDOW()` = 259200 each |
| Graduation rescue delay | 7 days | `GRADUATION_RESCUE_DELAY()` = 604800 |
| Max internal price impact when converting hook fees | 3.00% | `V2MemeHook.maxInternalPriceImpactBps()` = 300 |
| Tick spacing | 200 | `getLaunchConfig(0).tickSpacing` |

### 4.2 Approved v2 quote assets

All 25, from `_raw/api/pv-v2-status.json`, cross-checked against `approvedPairTokens()` on-chain for ETH, WETH, AAPL and USDG.
`graduationThreshold` is 2.5 times `phantomQuote` in every row.
Amounts are in the pair asset's own units.

| symbol | address | decimals | phantom quote | graduation threshold |
| --- | --- | --- | --- | --- |
| ETH | `0x0000000000000000000000000000000000000000` | 18 | 1.68 (from launch config) | 4.2 (from launch config) |
| AAPL | `0xaF3D76f1834A1d425780943C99Ea8A608f8a93f9` | 18 | 9.68 | 24.2 |
| NVDA | `0xd0601ce157db5bdc3162bbac2a2c8af5320d9eec` | 18 | 16.64 | 41.6 |
| TSLA | `0x322f0929c4625ed5bad873c95208d54e1c003b2d` | 18 | 10.4 | 26.0 |
| GOOGL | `0x2e0847e8910a9732eb3fb1bb4b70a580adad4fe3` | 18 | 9.68 | 24.2 |
| GME | `0x1b0e319c6a659f002271b69db8a7df2f911c153e` | 18 | 147.6 | 369.0 |
| SPY | `0x117cc2133c37b721f49de2a7a74833232b3b4c0c` | 18 | 4.36 | 10.9 |
| SPCX | `0x4a0e65a3eccec6dbe60ae065f2e7bb85fae35eea` | 18 | 28.88 | 72.2 |
| AMD | `0x86923f96303D656E4aa86D9d42D1e57ad2023fdC` | 18 | 6.6662 | 16.6655 |
| SNDK | `0xB90A19fF0Af67f7779afF50A882A9CfF42446400` | 18 | 2.6522 | 6.6304 |
| MSFT | `0xe93237C50D904957Cf27E7B1133b510C669c2e74` | 18 | 6.4315 | 16.0786 |
| AMZN | `0x12f190a9F9d7D37a250758b26824B97CE941bF54` | 18 | 11.7321 | 29.3303 |
| META | `0xc0D6457C16Cc70d6790Dd43521C899C87ce02f35` | 18 | 5.4272 | 13.5679 |
| MU | `0xfF080c8ce2E5feadaCa0Da81314Ae59D232d4afD` | 18 | 3.6714 | 9.1785 |
| COIN | `0x6330D8C3178a418788dF01a47479c0ce7CCF450b` | 18 | 20.9883 | 52.4707 |
| MSTR | `0xec262a75e413fAfD0dF80480274532C79D42da09` | 18 | 31.9921 | 79.9802 |
| CRCL | `0xdF0992E440dD0be65BD8439b609d6D4366bf1CB5` | 18 | 47.9607 | 119.9017 |
| PLTR | `0x894E1EC2D74FFE5AEF8Dc8A9e84686acCB964F2A` | 18 | 18.8261 | 47.0651 |
| QQQ | `0xD5f3879160bc7c32ebb4dC785F8a4F505888de68` | 18 | 4.4586 | 11.1465 |
| COST | `0x4EA005168D7F09a7A0Ba9D1DEf21a479950E44C2` | 18 | 3.3882 | 8.4704 |
| TTWO | `0x5e81213613b6B86EaB4c6c50d718d34359459786` | 18 | 10.6556 | 26.6390 |
| RDDT | `0x05b37Fb53A299a1b874A619e1c4C404D52C36F4C` | 18 | 16.9389 | 42.3472 |
| DJT | `0x1D11f0496982706C5e14A514D4E79F2e6BdE4516` | 18 | 366.8649 | 917.1622 |
| BB | `0x48E39E56aCdbA37b09020C0b734A613C9a2f100A` | 18 | 503.8246 | 1259.5614 |
| USDG | `0x5fc5360d0400a0fd4f2af552add042d716f1d168` | 6 | 3236.0 | 8090.0 |

A USDG-paired launch therefore graduates at $8,090 raised, and a GME-paired one at 369 GME.

Note that `nativeApproved` and `wethApproved` both read `false` in `/api/v2/status` while `approvedPairTokens(0x0)` reads `true` on-chain.
The API field names refer to something else in the front end's own model; trust the contract.

### 4.3 pons v1

| item | value | source |
| --- | --- | --- |
| Launch fee | 0.0005 ETH | `launchFee()` on `0xF4fC0CD2…`; `pages/10-docs-v1.md`, Network |
| Supply | 1,000,000,000 | `pages/10-docs-v1.md` |
| Pool | Uniswap V3, WETH pair, 1% fee tier (`10000`) | `pages/10-docs-v1.md`, Network |
| Graduation | 4.2 ETH of WETH paired in the locked pool. Nothing migrates | `pages/10-docs-v1.md`, Graduation |
| Fee split, current | 70% creator, 30% protocol, from block 8991118 | `pages/10-docs-v1.md`; `protocolFeeShare()` = 30 on locker `0x10f2756e…` |
| Fee split, legacy | 90% creator, 10% protocol, from block 8600612 | same; `protocolFeeShare()` = 10 on locker `0x31ca5E10…` |
| Anti-snipe | Launch block: creator buy only. Then 5% max wallet and 5.5% max cumulative buy, for a two-block window | `pages/10-docs-v1.md` |
| Protocol revenue use | 80% to a TWAP buyback and burn of PONS, 20% to operations | `pages/10-docs-v1.md`, Protocol revenue |

### 4.4 PonsVault

| item | value | source |
| --- | --- | --- |
| Extra fee charged by PonsVault | none found | no fee field in the launch form or in `/api/v2/status`; the launch is a plain pons v2 launch |
| Vault payout floor | 0.1 ETH accrued before a run | `pages/19-ponsvault-launch-live-staking.md` |
| Staking lock period | creator's choice at launch, zero allowed, rewards never locked | `pages/18-ponsvault-docs.md`, Templates |
| RWA dividend claim window | fixed; unclaimed rounds roll into the next | same |
| Buyback and Burn burn share | creator's choice; 100% means no treasury | same, Parameters |
| Seat shop ETH fees | 10% of a seat's value on buy or sell, 15% on snipe, all to the reward pot with no protocol cut, floored against a 0.01 ETH seat | `pages/33-ponsvault-docs-live.md`, Vault Seats |
| Seat loan | 70% of shop price lent in fuel token, liquidator must repay principal | same |
| Seat round expiry | 7 days, then rolls into the next pot | same |

## 5. Smart contracts

The full table with creators, creation transactions and directory paths is in `contracts/ADDRESSES.md`.
52 addresses have a directory: 31 verified, carrying `abi.json` and full `sources/`, and 21 unverified, carrying `bytecode.hex` and a selector match.
This section is the map.

### 5.1 The pons v2 set

Read directly from the factory's own storage, so this is the live set and not a docs transcription:

| role | address | how it was resolved |
| --- | --- | --- |
| `PonsV2LaunchFactory` | `0x7eD598BcEf8bd9Edd8C97A195C6d13f40801EC7e` | named in `pages/36-github-…-readme.md` and in `pages/18-ponsvault-docs.md` |
| `PonsV2LaunchDeployer` | `0x3711ceA4feaDE896C913C68F01Eda97Cb06D1A42` | `factory.launchDeployer()` |
| `PonsV2GraduationGuard` | `0xf5695117b99B6f6401e67d4195BD653628176C6C` | `factory.graduationGuard()` |
| `V2GraduationExecutor` | `0xC7819B64A1dAECD7eC19856d026cb14EfBd89046` | `factory.graduationExecutor()` |
| `V2LaunchLocker` | `0x267444D099b10fB5Ed7c3Cc7B7c767AdcA574952` | `factory.locker()` |
| `V2BuybackVault` | `0x42df2a798f82289E177311362e8f5ccC45c1219c` | `factory.buybackVault()` |
| `V2FeeEscrow` | `0xd3AFEB2a57f70eF218Aa82451c51B2fb0416Ac9e` | `factory.feeEscrow()` |
| `V2MemeHook` | `0xE5e702641Ea86F4ae6cC3cDaeD2B886f976Be044` | `factory.memeHook()` |
| `PonsV2LaunchAndBuy` | `0xe33E9E479dF8802cb0866d5d05258bEc4cF62948` | `factory.launchForwarder()` |
| owner and protocol fee recipient | `0x263ed295dAFaE1d9AAdD6E56c4B6F9f38eE019Dd` | `factory.owner()`, a Gnosis `SafeProxy` |
| Uniswap v4 PoolManager | `0x8366a39CC670B4001A1121B8F6A443A643e40951` | `factory.poolManager()` |
| Uniswap v4 PositionManager | `0x58daec3116aae6D93017bAAea7749052E8a04fA7` | `factory.positionManager()` |
| Permit2 | `0x000000000022D473030F116dDEE9F6B43aC78BA3` | `factory.permit2()` |

Everything in that list is verified on Blockscout except the Safe's own implementation, which is Gnosis code.
Sources are in each directory under `contracts/`.

Per-launch contracts are created by CREATE2 and must be resolved, never hardcoded.
`contracts/V2BondingCurve-Example-COPPERINU-…` and `contracts/V2LauncherToken-Example-COPPERINU-…` are captured as one worked example of each.

The docs page renders its address table client-side, so the Jina capture in `pages/11-docs-v2.md` shows the labels with the values missing.
Every value above was therefore obtained from the chain rather than from the docs, which is the stronger source anyway.

### 5.2 The pons v1 lineage

Three factories exist and only one accepts launches today.
This was resolved by reading `launchEnabled()`, `locker()` and the EIP-1967 implementation slot on each:

| address | state on 2026-09-02 | locker | notes |
| --- | --- | --- | --- |
| `0xF4fC0CD27fC8EcF17E55eE4c3f7201897dF3eb75` | `launchEnabled()` **true** | `0x10f2756e…`, `protocolFeeShare()` = 30 | ERC1967 proxy, implementation `0x02081d3d…`. The live v1 factory. Every September 2026 v1 launch in the live feed reports it |
| `0xA5aAb3F0c6EeadF30Ef1D3Eb997108E976351feB` | `launchEnabled()` **false** | `0x736D7669…` | The address the official repo README names as "the V1 factory". Retired. 2142 of the 2154 launches in the archived feed came from here |
| `0x0c37a24F5D23A486FA692d1500881d698B1F77a4` | `launchEnabled()` **false** | `0x31ca5E10…`, `protocolFeeShare()` = 10 | Unverified. The legacy 90/10 generation. The PONS token's own locker points here |

This is the first place the archive contradicts a primary source: **the official contracts repository names a v1 factory that no longer accepts launches.**
Anyone integrating against v1 should read `launchEnabled()` rather than trusting the README.

### 5.3 The PonsVault sets

The PonsVault docs (`pages/18-ponsvault-docs.md`) print a six-row contract table.
Four of those six are vault factories, and the live site does not call any of them.

Evidence.
`/api/v2/status` reports `vaultLauncher: 0x1770c356…` together with `vaultLauncherWhitelisted: false`.
Decoding a live PonsVault launch (`0xa2fd067d…`, section 3.2) shows the flow going through `PonsV2LaunchAndBuy` directly, with the vault built beforehand by a factory the docs do not list.
Across a 40-launch sample from the live feed, staking vaults are built by `0x3422A17c3A85f751Acb7F978f7333F93ea39CB48` and both RWA Dividend and Buyback and Burn vaults by `0x7e344f13a42c8ae4C6c7e2D9d48f98deBeCd82aB`.

The two generations are related, not unrelated.
The Staking beacon `0xef9f80d2…` is **owned by** the documented factory `0x1488473464…` and its `implementation()` is `0xC8e0a4fE…`, the same implementation the documented factory points at.
So the live factory `0x3422A17c…` is a newer front for the same beacon and the same vault code.
The RWA beacon `0xe3847a77…` is owned by `0x64946a45…` and now points at a different implementation, `0xcd5a5eae…`.

| template | documented factory | factory the live site calls | beacon | implementation |
| --- | --- | --- | --- | --- |
| Staking | `0x1488473464F2C6E6c5C412f05d805c619322E7EB` | `0x3422A17c3A85f751Acb7F978f7333F93ea39CB48` | `0xef9f80d2f51ec6aecab284e778f328e9f0982a6f` | `0xC8e0a4fE58918c47F66CF630c6A7205741C11FD4` |
| RWA Dividend | `0xE3Dd55a527D7408d21f6Cc2aA66A488a0177C164` | `0x7e344f13a42c8ae4C6c7e2D9d48f98deBeCd82aB` | `0xe3847a778bbe852879bcc755f9fa7bfafda5314b` | `0xcd5a5eaefbc504ccded34b882889383255d6f9e3` |
| Buyback and Burn | `0xdE4670A2Be85Baa3f6a2C1F6443101EA041362aB` | `0x7e344f13…` (same as RWA; `template()` returns `rwa`) | `0xe3847a77…` | `0xcd5a5eae…` |
| Stake and Burn | `0x537483c5B33e2192CfB202d7C50d58975524B047` | not seen in the live sample | not resolved | `0x65b2eAaA7ae4eCC144494070aD6F2A3AD13A47d9` |
| Fee Share | none | none; no vault is deployed | n/a | n/a |

None of the PonsVault contracts is verified on Blockscout.
Every one is identified in this archive by extracting PUSH4 selectors from its runtime bytecode and matching against the verified pons ABIs plus the names the PonsVault docs use.
Each directory's `README.md` lists the matched selectors; the raw bytecode is in `bytecode.hex`.
Vaults are deployed behind a shared beacon and are upgradeable until the beacon's owner renounces (`pages/18-ponsvault-docs.md`, Upgrades), so the vault code a creator commits to today can change.

There is also a **PonsVault v1** set, which attaches vaults to v1 launches through the v1 locker's `feeRedirect` rather than through a v2 creator fee recipient: `PonsVaultLauncher` `0x9dDE735093d92EAAD379BE685E62c6d449628f64` (verified; its constructor names the retired v1 factory `0xA5aAb3F0…`, the v1 locker `0x736D7669…` and a v1 registry `0x770c1AA5…`), `PonsVaultRegistry` `0xaA9C86049A258D4A076d3eF367F69C231C9746D5`, and `PonsBuybackBurnVaultFactory` `0x3926af4490b4ba5af78D785DD9BA527b383c1B1e`.
The VAULT token's own live vault, `0x4a95863226826701031c282b611493AFfBfA096E`, is one of these.
Its token page (`pages/23-ponsvault-token-vault.md`) shows the v1 mechanics plainly: WETH fees, 70% creator / 30% protocol, 102 runs, 93,146,693 tokens burned.

Worth flagging: the prose in the PonsVault docs describing "how a vault earns" is written entirely against this v1 model, locker `feeRedirect` and WETH, even though the same page's contract table lists the v2 contracts.
Under pons v2, creator fees do not flow through a locker redirect at all; they accrue in `PonsV2FeeEscrow` credited to whatever address is the creator fee recipient, in the pairing asset.

### 5.4 Vault Seats

A separate PonsVault product: an NFT series plus its own fuel ERC-20, where the fuel token is itself launched on a pons v2 curve in the same transaction that creates the series.
Two unverified series registries are live, `0x9cc3207EC932f65fd83A514633802B4CdBB888E0` (2 series) and `0x278FFA5A46283A05635A3d33d820D9Cc7D7E67E2` (4 series), both read by the live `/seats` page and both captured in `contracts/`.
Calling `0xdc22cb6a(uint256 index)` on either returns a record of seven addresses (seat NFT, shop, activation, pot, loan vault, fuel token, fuel curve) plus name, symbol and two counters, which is how the full per-series contract set is enumerated.
The 42 per-series contracts are not given their own directories: they are per-launch instances of the same templates, not shared infrastructure.

### 5.5 Audits

Three engagements were open and none had closed at capture time: SB Security, Dingbats and Pashov Audit Group (`pages/11-docs-v2.md`, Audits).
No report is published.
The docs say to treat v2 as unaudited.
The PonsVault docs say the vault contracts "have not yet completed a third-party audit" either (`pages/18-ponsvault-docs.md`, Limits and caveats).

## 6. Backend APIs

Both front ends are Next.js apps on Vercel.
Wallet connection is Privy, app id `cmthyvinr001v0dl8xiibmgwh`.
The endpoints below were found in a HAR recording of a live browsing session (`_raw/har/ponsvault-session-1.har`) and in the earlier network captures (`_raw/network-*.json`), then re-fetched directly.
They are unauthenticated GETs.

**`GET https://www.ponsvault.com/api/v2/status`** is the single most useful one for a creator.
It returns the live launch gate, the fee, the tax cap and the full approved-pair table.

```json
{
  "factory": "0x7eD598BcEf8bd9Edd8C97A195C6d13f40801EC7e",
  "launchEnabled": true,
  "launchFeeWei": "500000000000000",
  "launchFeeEth": "0.0005",
  "maxCreatorTaxBps": 1000,
  "baseFeeBps": 100,
  "nativeApproved": false,
  "wethApproved": false,
  "vaultLauncher": "0x1770c356eB9312079b9A00e26a8CF4b0a1473dBA",
  "vaultLauncherWhitelisted": false,
  "vaultCanLaunch": true,
  "vaultCanLaunchReason": "Ready",
  "publicReady": true,
  "defaultBuyback": "0x0Ee057fcb7C5192AF04874D9E023B75E70A93B92",
  "buybackHelperReady": true,
  "pairTokens": [
    { "symbol": "AAPL", "name": "Apple • Robinhood Token",
      "address": "0xaF3D76f1834A1d425780943C99Ea8A608f8a93f9",
      "decimals": 18, "approved": true,
      "phantomQuote": "9680000000000000000",
      "graduationThreshold": "24200000000000000000" }
  ]
}
```

**`GET /api/rwa/assets`** returns which tokenized stocks a RWA Dividend vault can actually convert into, with `poolFee`, `perRound`, `impactBps`, `tradeable` and a `reason` when not.
This is where the launch form's greyed-out stock options come from.

**`GET /api/pons/launches?limit=N`** returns recent launches, newest first, with `token`, `name`, `symbol`, `description`, `logo`, `deployer`, `feeWallet`, `vault`, `vaultTemplate`, `feeShareHandle`, `launchedAt`, `transactionHash`, `everGraduated`, `graduated`, `graduationProgressPct`, `pool`, `marketCapUsd`, `priceUsd`, `creatorTaxBps` and a `vaultStat` object.
`_raw/api-pons-launches.json` is an older, differently shaped v1 dump of 2154 launches from 2026-07-13 to 2026-08-12 with `factory`, `pairToken`, `initialBuyWei` and `graduationThresholdEth` fields, useful for history.

**`GET /api/pons/protocol-stats`** returns the aggregate: vault counts by template, stakers, staked and burned totals in tokens and USD, harvested USD and dividends.

**`GET /api/pons/token/<address>`** returns a token record.
For a v1 token it includes the trading path a client needs: `pool`, `pairToken`, `router`, `poolFee`, `tickSpacing`, `routerRequiresDeadline`, `deployer`, `locker`, `positionManager`, `positionId`, `isToken0`, `restrictionEndBlock` and `initialBuyWei` (`_raw/api-pons-token-PONS.json`).

**`GET /api/pons/market/<symbol>`** returns price, market cap, liquidity, 24h volume, a price series and a recent trade list.

**`GET /api/partner/vault-stats?token=<address>`** returns a partner desk's vault statistics; without a token it returns `{"error":"A token address is required."}`.

**`POST /api/rpc`** is a JSON-RPC proxy to Robinhood Chain.
The front ends read all contract state through it rather than exposing an RPC URL.
Request and response bodies are in the HAR.

`ponsfamily.com` additionally serves `/api/ipfs/content/<cid>?variant=card` as an IPFS image proxy, and quotes its analytics from a Dune dashboard rather than its own indexer (`pages/04-pons-analytics.md`).

There is no documented public API for pons itself.
The v2 docs point integrators at the contracts and at the events to index, not at an HTTP API (`pages/11-docs-v2.md`, Events to index).

## 7. Ecosystem

**Fee revenue.**
Pons is the largest fee-earning launchpad on Robinhood Chain by a wide margin, and v2 has overtaken v1 within weeks of launching.
From `../_market/_raw/llama-fees-robinhood.txt`:

| protocol | 24h | 7d | 30d | all time |
| --- | --- | --- | --- | --- |
| Pons V2 | $4,221,588 | $21,826,857 | $26,939,684 | $26,939,684 |
| Pons V1 | $335,884 | $2,533,267 | $8,300,755 | $23,887,250 |
| NOXA Fun, the next launchpad | $142,924 | $933,642 | $4,069,455 | $20,894,770 |
| Robinhood Chain itself | $3,751,220 | $8,122,834 | $10,304,589 | $13,992,172 |

Pons V2's 24-hour fees exceed the whole chain's, which tells you the DefiLlama adapters count different things; treat the ranking as sound and the absolute cross-category comparison as not.

**Volume.**
The project claimed on X on 2026-09-02 that pons had done "over $4.54B in volume on Robinhood Chain" in under two months, and "over $111,000,000 in RWA volume" in 24 hours (`socials/01-x-ponsdotfamily.md`).
These are self-reported.

**Launch counts.**
The archived v1 feed holds 2154 launches from 2026-07-13 to 2026-08-12, of which 1958 graduated, every one paired against WETH (`_raw/api-pons-launches.json`).
v2 launches were landing several per minute at capture time: 12 `launchToken` calls in the 50 most recent factory transactions, spanning about 45 seconds.

**PonsVault.**
124 vaults built, by template: 49 stake-burn, 36 rwa, 20 staking, 19 buyback-burn, 0 lottery.
264 staking wallets across 336 positions in 41 vaults.
1.204B tokens staked ($462.5K), 1.826B tokens burned ($539.2K) across 28 vaults, $1,011,834 of fees harvested into vaults and $514,930 paid out as dividends (`_raw/api/pv-pons-protocol-stats.json`, 2026-09-02).
The site's own stats page, captured a few hours earlier, shows 119 vaults and 853 vault runs (`pages/14-ponsvault-stats.md`).

**Notable tokens.**
PONS `0x39dBED3a2bd333467115dE45665cC57F813C4571`, the protocol token, a v1 launch, about $422M market cap and $6.0M 24h volume at capture (`_raw/api-pons-market-PONS.json`).
COPPERINU `0x5317C0d077D2eEB639448939b930D49c4984B63B`, a v2 launch with a 4% creator tax, the largest PonsVault token.
VAULT `0xFdae23CE76018Da62507bB5ef20e6ef5450e8312`, PonsVault's own token, a v1 launch with a Buyback and Burn vault that has burned 9.315% of supply across 102 runs.

**Partner desks.**
PonsVault runs white-label desks at `/<handle>`, for example `/himgajria`, whose launches are kept out of the main Explore feed and get their own Stake and Burn factory (`pages/24-ponsvault-desk-himgajria.md`).

**Third-party tooling.**
No official SDK.
The community has published a Go trade SDK and a Go log parser for pons v2 (`_raw/github/pons-trade-sdk`, `_raw/github/pons-parser-sdk`), plus several sniping bots visible in a GitHub search.
The existence of an open trade SDK and parser is a decent signal that the v2 ABI is stable enough to build against.

## 8. Link inventory summary

Full table in `LINKS.md`.

| | count |
| --- | --- |
| Distinct hrefs discovered | 533 |
| Structural links listed individually | 206 |
| Token detail pages, collapsed to a summary row | 124 |
| Static assets, collapsed | 149 |
| Forum community boards, collapsed | 40 |
| Trader profile pages, collapsed | 14 |
| `pages/` files | 37 |
| `screenshots/` files | 59 |
| `contracts/` directories | 52 (31 verified, 21 unverified) |
| `socials/` files | 2 |
| `_raw/` files | 659, including 3 GitHub clones and a HAR of a live session |

Every internal route on both domains was visited and has a `pages/` file with rendered content, not a loading stub.
The four bulk groups repeat a single template with different data; one representative of each was captured in full and the complete list is pointed at from `LINKS.md`.

## 9. Gaps

**`github.com/ponsvault/PonsVault` does not exist.**
The PonsVault site and docs both link to it as the source for all six vault contracts.
The GitHub API returns 404 for the repo and the `ponsvault` user has zero public repositories.
No PonsVault source could be obtained, which is why all twelve PonsVault contract directories carry bytecode and a selector match rather than sources.

**No PonsVault contract is verified on Blockscout.**
Combined with the missing repo, this means a creator attaching a vault is committing their entire fee stream to unreviewed, upgradeable-behind-a-beacon bytecode.
The archive identifies each contract's interface but cannot show anyone the code.

**The @PonsVault timeline could not be read.**
`syndication.twitter.com` returns `entries: []` for that handle and Bright Data's scrape stops at the login wall.
The profile itself is captured (`socials/02-x-ponsvault.md`); 337 posts are not.
The @ponsdotfamily timeline worked and 28 posts are archived.

**The Dune dashboard behind `/analytics` could not be captured.**
`dune.com/adam_tehc/pons` sits behind Cloudflare and renders its charts client-side; both `agent-browser` and Bright Data returned only the shell (`_raw/bdata-dune-adam_tehc-pons.md`).
The numbers pons surfaces from it are in `pages/04-pons-analytics.md`.

**The CTO request form was not captured.**
`forms.gle/JjrWvybFeNfE5v8F6` is a Google Form behind a consent interstitial.

**`ponsfamily.com` is geo-blocked from this machine.**
Every ponsfamily page came through Jina Reader, so no live browser screenshots of the ponsfamily create flow exist, and the `v1` tab of the create form could not be clicked.
The v1 create fields are documented from `pages/10-docs-v1.md` instead.
`screenshots/45-ponsfamily-blocked-gb.png` records the block.

**The docs' rendered address table is empty in the capture.**
`docs.ponsfamily.com/v2` renders its "Deployed addresses" values client-side and Jina captured only the labels.
Every address in section 5 was read from the chain instead, which is a stronger source, but the archive cannot show what the docs claim to prove they agree.

**Two documented facts contradict the chain.**
The v2 docs say public launches are closed; `canLaunch` says otherwise.
The official repo names a v1 factory that reads `launchEnabled() == false`.
Both are recorded in sections 3.1 and 5.2 with the evidence.

**Vault Seats per-series contracts are enumerated but not archived.**
Six series exist across two registries, 42 contracts in total.
The registries and the enumeration call are captured; the individual series contracts are not.

**Not attempted, by rule.**
No transaction was sent, no wallet was connected and no wallet-gated view was opened.
`/profile`, the claim flow at `/claim`, the "Connect wallet" state of both create forms and the partner-desk launch form are captured only in their disconnected state.

---

Capture method: Jina Reader for `ponsfamily.com` and `docs.ponsfamily.com`, `agent-browser` (session `lp-pons`, closed) for `ponsvault.com`, Bright Data for X, the Blockscout v2 API for contract metadata and verified sources, and `eth_call` / `eth_getCode` / `eth_getStorageAt` against the Alchemy Robinhood Chain archive RPC for live state.
