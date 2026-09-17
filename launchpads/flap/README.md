# Flap on Robinhood Chain

## 1. Identity

| field | value |
| --- | --- |
| Name | Flap |
| App | <https://flap.sh/robinhood/board> |
| Docs | <https://docs.flap.sh/flap> (59 pages, all captured) |
| Backend API | `https://batman.taxed.fun/v3/` |
| Chain covered here | Robinhood Chain mainnet, chain id **4663** |
| Other chains | BNB Chain, X Layer, Monad, Morph, ToshiMart, plus a Robinhood testnet deployment (`pages/14-docs-developers-deployed-contract-addresses.md`) |
| X | [@flapdotsh](https://x.com/flapdotsh), 89.6K followers, 7,412 posts, joined January 2024 (`socials/01-x-flapdotsh-profile.md`) |
| Telegram | [t.me/FlapOfficial](https://t.me/FlapOfficial), 17,981 members (`socials/03-telegram-flapofficial.md`) |
| Discord | <https://discord.gg/flapdotsh>, did not render for any extractor (`socials/04-discord-and-farcaster.md`) |
| Farcaster | <https://warpcast.com/flap>, did not render (`socials/04-discord-and-farcaster.md`) |
| Backer named in the X bio | YZi Labs, `@yzilabs` (`socials/01-x-flapdotsh-profile.md`) |
| Third-party trackers | CertiK Skynet `projects/flap`, RootData `detail/Flap`, CoinGecko `flap`, DefiLlama `flap-sh` (`socials/05-certik-skynet.md`) |
| Live Portal version | `v5.21.2`, read from the chain (`_raw/rpc/portal-config.txt`) |
| Capture date | 2026-09-02 and 2026-09-03 |

No individual team handles are published anywhere in the docs, the app or the X profile.
The only named party is the backer.

## 2. What it is

Flap is a bonding-curve launchpad with a programmable tax layer.

A creator picks a name, a symbol, a quote asset and, optionally, a buy and sell tax.
The Portal deploys a 1,000,000,000-supply ERC-20, places the whole supply on a constant-product bonding curve and starts trading immediately.
There is no liquidity to seed, no listing fee and no approval step.
When 80% of supply has been bought off the curve the Portal migrates the accumulated reserve and the remaining 20% into a Uniswap V2 pair and burns the LP.

The distinctive part is not the curve, which is ordinary, but the tax:

- A tax token can charge up to 10% on buys and up to 10% on sells, with different rates for each side (`pages/10-create-tax-token.md`).
- The tax is split, on chain, across four buckets the creator chooses: a funds wallet, burn, dividends to holders, and liquidity (`pages/10-create-tax-token.md`).
- The funds wallet may be a **Vault**, an arbitrary contract that implements Flap's vault interface.
Vault factories are permissionless, so a launch can route its own tax revenue into any contract logic, and the app generates the vault's configuration form from an on-chain schema (`pages/72-ca-store-vault-store.md`, `pages/49-docs-developers-vault-developers-vault-and-vaultfactory-specification.md`).
The one featured vault on Robinhood Chain buys tokenized stocks with the tax and pays them out as dividends (`pages/70-create-tax-token-indexvault.md`).

Who it is for: someone who wants a memecoin whose trading volume funds something continuously, rather than a one-off creator allocation.
For a creator who does **not** want a tax, Flap pays nothing at all after launch on this chain, because the LP is burned (see section 3.7).

## 3. How a launch works, as the creator experiences it

### 3.1 Two token types, and only two

The Robinhood integration guide is explicit: only `TOKEN_V2_PERMIT` (non-tax) and `TOKEN_TAXED_V3` (tax) are accepted on chain 4663, and every other token version reverts with `FeatureDisabled()` (`pages/45-docs-developers-token-launcher-developers-robinhood-integration-guide.md`).
Only `V2_MIGRATOR` is accepted; V3, V4 and Pancake Infinity migrators all revert.

| type | entry point | implementation | vanity suffix |
| --- | --- | --- | --- |
| Non-tax | `Portal.newTokenV5` | `0x88882688a067FE97E11C2185b996286e53132222` | `8888` |
| Tax V3 | `Portal.newTokenV6` with `tokenVersion = 6` | `0x7777C8743C88B3aff3cf262135beF2c8b2e83333` | `7777` |

Both were confirmed live: 6 of the 50 most recent Portal transactions were `newTokenV5` and 17 were `newTokenV6` (`_raw/blockscout/portal-txs.json`, selectors resolved in `contracts/PortalImpl-0xa3b96df56f254b926b17d5f7fb6cd858c216ff44/selectors-decoded.txt`).

### 3.2 The form

Fields on `https://flap.sh/create` (non-tax) and `https://flap.sh/launch?chain=robinhood` (tax), captured without a wallet (`pages/09-create-non-tax-token.md`, `pages/10-create-tax-token.md`):

| field | required | notes |
| --- | --- | --- |
| Cover image | no | PNG, JPEG, WebP, SVG, GIF, 3MB limit |
| Token name, symbol | yes | |
| Blockchain network | yes | Robinhood, chosen by the header chain switcher |
| Description | no | |
| Payment (quote) token | yes | CRYPTO tab: ETH. RWA tab: 24 tokenized stocks plus HOODon |
| DEX for migration | yes | PancakeSwap or Uniswap. Both resolve to a V2 fork on this chain |
| Creator token purchase | no | "Maximum purchase amount: 800M tokens... Deploy cost: around 0.001 ETH". Caps shown were `Max: 5 ETH / Maximum purchase: 5.05 ETH` for non-tax and `Max: 5.1 ETH` for tax |
| Anti-farmer protection duration | yes | default 30 days, range 0 to 365 days |
| Buy tax rate, sell tax rate | tax only | sliders, 0% to 10% each |
| Tax allocation | tax only | Creator Funds Wallet, Burn, Dividend, Liquidity. "Total allocation must be 100%" |
| Minimum balance for dividend eligibility | tax only | minimum 0 tokens in the form, 10,000 when the Stocks vault is used |
| Recipient wallet | tax only | an EVM address, or a Vault |
| Vault | tax only | Custom Vault Factory by address, or the featured Stocks IndexVault |
| Optional links | no | Telegram, Twitter, GitHub, YouTube, DeBox, Website |

There is no field for supply, for the graduation threshold, or for a creator allocation.
All three are fixed by the protocol.

### 3.3 What a real launch actually sends

Five launches from the 50 most recent Portal transactions were decoded from their calldata (`_raw/decoded/launch-calls-decoded.txt`).
A representative tax launch, `0x4272efc4...`, `FlokiHood`:

| parameter | value | meaning |
| --- | --- | --- |
| `dexThresh` | `1` | `FOUR_FIFTHS`, graduate at 80% of supply |
| `migratorType` | `1` | `V2_MIGRATOR` |
| `quoteToken` | `0x0000...0000` | native ETH |
| `quoteAmt` | `51000000000000000` | 0.051 ETH creator buy, equal to `msg.value` |
| `beneficiary` | the creator's own address | |
| `buyTaxRate` / `sellTaxRate` | `300` / `300` | 3% each way |
| `taxDuration` | `3153600000` | 100 years, that is "forever" |
| `antiFarmerDuration` | `2592000` | 30 days, the form default |
| `mktBps` | `10000` | 100% of the creator share to the funds wallet |
| `deflationBps` / `dividendBps` / `lpBps` | `0` / `0` / `0` | |
| `tokenVersion` | `6` | `TOKEN_TAXED_V3` |
| `extensionID` | zero | no extension |

Two of the five launches sent `msg.value = 0`, so the creator buy is genuinely optional and **there is no launch fee**.
The gas is the only unavoidable cost, which matches the app's "Deploy cost: around 0.001 ETH".

One non-tax launch, `Mars`, used `dexId = 1` (PancakeSwap) rather than `0`, so the DEX choice in the form does reach the chain.

### 3.4 The curve

`(x + h)(y + r) = K`, where `x` is the token balance still in the curve and `y` is the quote reserve (`pages/16-docs-developers-basic-and-mechanism-bonding-curve.md`).
The Robinhood parameters are not in the docs table, which stops at Monad.
They were read from the chain instead, `Portal.getTokenV8Safe($moon)` (`_raw/rpc/lp-and-token-state.txt`), and they match the app bundle exactly (`_raw/js/robinhood-chain-config.js`):

| quote | r | h | K | reserve at graduation |
| --- | --- | --- | --- | --- |
| ETH | 1.9189797 | 107,036,752 | 2,124,381,054.2419344 | **exactly 5.000000 ETH** |
| HOODon | 34.26749453 | 107,036,751 | 37,935,375,809.40147203 | 89.285714 HOODon |

Derived in `_raw/rpc/curve-math.txt`:

- Opening FDV on the ETH curve is **1.733438 ETH**, about $7,280 at the app's $4,200 fallback ETH price.
- Graduation FDV is **22.534695 ETH**, about $94,646.
- The price multiple from the first token to the last is **exactly 13.0000x**, and it is 13.0000x on the HOODon curve too.
Every Flap curve on this chain is calibrated to the same 13x, so the quote asset changes the denominated size of a launch but not its shape.

The docs name this curve `CURVE_RH_TOSHI_5ETH`, and `getQuoteTokenConfiguration(address(0))` returns curve enum index **25** (`_raw/rpc/quote-token-config.txt`).
The `CurveType` enum published in the verified `IPortal.sol` only reaches index 24, so the deployed Portal is ahead of every published copy of the interface.
Do not hardcode curve parameters; read `getTokenV8Safe` as the docs themselves advise.

### 3.5 Quote assets: the docs are wrong

The Robinhood integration guide says "Native ETH (`address(0)`) is currently the only enabled quote token on Robinhood Chain, for both token types" (`pages/45-docs-developers-token-launcher-developers-robinhood-integration-guide.md`).

That is false as of capture.
`Portal.getQuoteTokenConfiguration` returns `enabled = 1` for **26 assets**: ETH, HOODon and 24 tokenized stocks (`_raw/rpc/quote-token-config.txt`).
The app's RWA tab lists the same 25 non-ETH assets (`pages/09-create-non-tax-token.md`).
Flap announced the change on X on 2026-08-27 (`socials/02-x-flapdotsh-posts.md`).
And it is in production use: of the 200 tokens on the board, 24 are quoted in something other than ETH (`_raw/rpc/board-summary.txt`).

Enabled quote assets, with their on-chain curve index:

ETH (25), HOODon (31), SPY (28), GME (29), NVDA (30), PLTR (31), AAPL (34), GOOGL (34), SKHY (32), DJT (40), MSTR (44), LULU (44), AMC (49), BB (51), F (52), PFE (54), INDA (57), NFLX (60), SPCX (63), AMZN (69), JNJ (69), TSLA (71), MSFT (74), QQQ (76), COST (79), SNDK (82).

WETH (`0x0Bd7D308...`) is **not** an enabled quote asset; only native ETH is.

### 3.6 Fees

| fee | rate | who pays | who receives | source |
| --- | --- | --- | --- | --- |
| Launch fee | **none** | | | two decoded launches with `msg.value = 0`, `_raw/decoded/launch-calls-decoded.txt` |
| Bonding-curve trade fee | **1% buy, 1% sell** | every trader on the curve | Flap's FeeSafe, in full | `Portal.getFeeRate()` returns `(100, 100)`, `_raw/rpc/portal-config.txt` |
| Protocol share of a tax token's tax | **3% of the tax** | the token's tax bucket | Flap's FeeSafe | `TaxProcessor.feeConfigV2().feeRate = 300`, `_raw/rpc/taxprocessor-live.txt` |
| Launcher commission on a tax token | **0.6% of the tax** | the token's tax bucket | whatever `commissionReceiver` the launch set | `commissionBps = 60`, same file |
| Unallocated tax | whatever the creator leaves unassigned | the token's tax bucket | Flap's FeeSafe | `TaxProcessorBase._processFeeQuote`, `contracts/TaxProcessorUniV2Impl-0x92C7ed364CB74B13D0C0168CDb2195e569811dF2/README.md` |
| Salt lock (vanity CA reservation) | **0.003 ETH** | the creator, optional | Flap | `Portal.SALT_LOCK_FEE()` returns `3000000000000000`, `_raw/rpc/portal-config.txt` |
| Uniswap V2 LP fee after graduation | 0.3% | traders | nobody claimable, the LP is burned | section 3.7 |

The 1% curve fee was confirmed by tracing a real buy.
In `0xec60221a...` a `37053982898397` wei buy sent `370539828983` wei, exactly 1%, straight to the FeeSafe `0xa4A727E0...` inside the same transaction (`_raw/blockscout/txinternal-0xec60221a8940933af1673e90cd4726da5889fa368526b50ccb4ea11f8bc86993.json`).
None of it reaches the creator.

The docs describe the tax-side rate as "up to 0.3% of trade volume, regardless of the token's tax rate" (`pages/19-docs-developers-basic-and-mechanism-protocol-economics.md`).
That is the same number stated differently: 3% of a tax, and the maximum tax is 10%, so 3% x 10% = 0.3% of volume.
A third-party launcher, `SinjohFlapAdapter`, hardcodes both constants (`flapFeeRate() = 300`, `flapCommissionBps() = 60`) and exposes `feeRoutingIntact()` so integrators can detect a change, which is independent confirmation (`_raw/rpc/sinjoh-adapter.txt`).

### 3.7 What the creator actually earns

**Non-tax token: nothing.**
The Portal exposes `claim(address)`, documented as "Revenue Share: Claim LP fees for a vanity token", and `delegateClaim` and `setTokenBeneficiary` alongside it (`pages/42-docs-developers-token-launcher-developers-launch-token-through-portal.md`).
On this chain there is nothing for it to claim.
Migration is V2-only, and the V2 LP is burned: for the graduated `$moon` pair, `totalSupply()` is `44821502752390679081447` and the dead address holds `44790004104703970611336`, that is **99.93%** (`_raw/rpc/lp-and-token-state.txt`).
`Portal.getLocks($moon)` returns `(0, 0)`, so no locker position exists either.
A non-tax launch on Flap Robinhood is a pure giveaway by the creator.

**Tax token: the tax, minus 3.6%.**
Of every unit of tax collected, 3% goes to Flap and up to 0.6% to a commission receiver; the remaining 96.4% is divided across the creator's four buckets.
The `$UBER` tax page shows the creator side working in practice: "Total Tax 0.538308 ETH" with the note "Creator fees accumulate first.
Once the balance reaches about $4, it is automatically sent to the configured recipient wallet" (`pages/74-token-uber-tax-info.md`).

Note the wording on that page, "All tax from this token will be sent to the following recipient wallet", is not accurate.
3% plus the commission never reaches the recipient.

### 3.8 Supply, graduation and migration

- Supply is fixed at 1,000,000,000 with 18 decimals for every launch, and `maxSupply()` on the non-tax implementation is hardcoded to `1,000,000,000 ether` (`pages/45-docs-developers-token-launcher-developers-robinhood-integration-guide.md`).
- 100% of supply starts on the curve. There is no creator allocation, no team allocation and no vesting anywhere in the launch parameters.
- Graduation is at `dexSupplyThresh = 800,000,000`, that is 80% of supply, which on the ETH curve is exactly 5 ETH of reserve.
The docs note that on a live Robinhood RPC "graduation consistently occurs at the 6th buy round, just above 5 ETH cumulative spend" using 1 ETH steps, which is the 1% fee showing up.
- Nobody can buy past 800M: "You can not buy more than 800M no matter it is an old token or new one" (`pages/17-docs-developers-basic-and-mechanism-list-on-dex.md`).
- At graduation the remaining 200M tokens and the reserve are added to a Uniswap V2 pair and the LP is burned.
- The pool therefore opens at 5 ETH / 200M = 2.5e-8 ETH per token, against a final curve price of 2.2535e-8, an arithmetic step up of about 11% (`_raw/rpc/curve-math.txt`).
This is derived from the mechanism, not observed on a fresh graduation.

Almost nothing graduates.
`FlapCurvePairFactory.allPairsLength()` is **173,798**, one per token ever launched here.
Sampling `graduated()` on 3,000 evenly spaced curve pairs returned **2** (`_raw/rpc/graduation-sample.txt`).
Sampling from the other side, 27 of 3,000 sampled Uniswap V2 pairs had a Flap vanity token on one side, implying about **364** graduated pairs of the 40,431 that exist.
Both methods put graduation at roughly **0.1% to 0.2%** of launches.

### 3.9 Anti-snipe

Flap's anti-snipe is a hard revert, not a fee (`pages/45-docs-developers-token-launcher-developers-robinhood-integration-guide.md`):

| phase | behaviour |
| --- | --- |
| Pre-graduation | all transfers to or from any registered pool are blocked, both directions |
| Anti-farmer window, post-graduation, before expiry | transfers to and from `mainPool` allowed, all other registered pools blocked |
| After expiry | unrestricted |

`antiFarmerExpirationTime` is set when the migrator calls `removeTransferConstraints()`.
The window defaults to 30 days and the decoded launches used 1, 3 and 30 days.

The docs are honest about the limit: "the block only applies to pools registered at initialization time...
Anti-farmer here raises friction on the known/expected venues; it does not prevent farming through arbitrary unlisted pools."

There is no per-wallet buy cap by default, though the Portal has `maxBuyPerOrigin(address)` and `setTokenMaxBuyBps(address,uint16)` in its selector table.

### 3.10 Reserving an address before launch

`https://flap.sh/prelaunch` mines a CREATE2 salt for the `7777` or `8888` vanity suffix and locks it to your wallet for `SALT_LOCK_FEE` = 0.003 ETH (`pages/71-prelaunch-reserve-ca.md`, `Portal.lockSalt`, `getSaltLock`, `getLockedSaltsByUserAndVersion`).
Without it the app mines a salt client-side at launch time.

## 4. Economics table

Every number here was read from the chain, from decoded calldata, or from a captured page.

| item | value | source |
| --- | --- | --- |
| Launch fee | 0 | `_raw/decoded/launch-calls-decoded.txt` |
| Deploy gas, as quoted by the app | about 0.001 ETH | `pages/09-create-non-tax-token.md` |
| Optional creator buy, cap | 800M tokens; UI showed 5.05 ETH (non-tax) and 5.1 ETH (tax) | `pages/09-...`, `pages/10-...` |
| Total supply | 1,000,000,000, 18 decimals | `pages/45-docs-developers-token-launcher-developers-robinhood-integration-guide.md` |
| Supply on the curve | 100% | decoded launches, no allocation parameter exists |
| Graduation threshold | 800,000,000 sold, 80% | `Portal.getTokenV8Safe`, `_raw/rpc/lp-and-token-state.txt` |
| Graduation reserve, ETH quote | exactly 5.000000 ETH | `_raw/rpc/curve-math.txt` |
| Graduation reserve, HOODon quote | 89.285714 HOODon | `_raw/rpc/curve-math.txt` |
| Opening FDV, ETH quote | 1.733438 ETH, about $7,280 | `_raw/rpc/curve-math.txt` |
| Graduation FDV, ETH quote | 22.534695 ETH, about $94,646 | `_raw/rpc/curve-math.txt` |
| Price multiple across the curve | 13.0000x, identical for every quote asset | `_raw/rpc/curve-math.txt` |
| Curve trade fee | 1.00% buy, 1.00% sell, 100% to Flap | `Portal.getFeeRate()`, `_raw/rpc/portal-config.txt` |
| Creator tax range | 0% to 10% buy, 0% to 10% sell, independent | `pages/10-create-tax-token.md` |
| Flap's share of the tax | 3.00% | `feeConfigV2().feeRate = 300`, `_raw/rpc/taxprocessor-live.txt` |
| Launcher commission share of the tax | 0.60% | `commissionBps = 60`, same file |
| Creator's share of the tax | 96.40%, split over 4 buckets | same file |
| Unallocated tax | added to Flap's fee bucket | `contracts/TaxProcessorUniV2Impl-0x92C7ed364CB74B13D0C0168CDb2195e569811dF2/sources/src/Tax/TaxProcessorBase.sol` |
| Tax payout threshold | about $4 accumulated before auto-forward | `pages/74-token-uber-tax-info.md` |
| Vanity salt lock fee | 0.003 ETH | `Portal.SALT_LOCK_FEE()` |
| Migration destination | Uniswap V2 fork, factory `0x8bcEaA40...` | `pages/45-docs-developers-token-launcher-developers-robinhood-integration-guide.md` |
| LP after migration | burned, 99.93% to `0x...dEaD` on `$moon` | `_raw/rpc/lp-and-token-state.txt` |
| Creator LP fee revenue | none on this chain | section 3.7 |
| Vesting | none | no vesting parameter exists in `NewTokenV5Params` or `NewTokenV6Params` |
| Anti-farmer default | 30 days, range 0 to 365 | `pages/10-create-tax-token.md` |
| Default V4 fee constants on the Portal | `DEFAULT_V4_NORMAL_FEE_PIPS = 12500`, `DEFAULT_V4_TICK_SPACING = 250` | `_raw/rpc/portal-config.txt`, unused on this chain |

Worked example, a 3% / 3% tax token that graduates:

- Traders pay 5 ETH into the curve plus 1% fee, so about 5.05 ETH leaves buyers' wallets, of which 0.05 ETH goes to Flap.
- The 3% tax on that same volume is roughly 0.15 ETH, of which Flap takes 3% (0.0045 ETH), a launcher commission takes up to 0.6% (0.0009 ETH), and the creator's buckets take the remaining 0.1446 ETH.
- The creator receives nothing else, ever, unless the token keeps trading.

## 5. Smart contracts

Full table with creators, creation transactions and per-contract notes: `contracts/ADDRESSES.md`.
39 directories, each with a `README.md`, and either verified `sources/` or `bytecode.hex` plus a decoded selector list.

The launch path, in order:

1. **Portal** `0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09`, a `TransparentUpgradeableProxy`.
This is the single entry point.
`contracts/FlapCore-0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09/`.
The archive directory is named `FlapCore` from an earlier guess; the address is what the docs and the app both call `Portal`.
2. **Portal implementation** `0xa3b96df56f254b926b17d5f7fb6cd858c216ff44`, **unverified**.
96 selectors were recovered by a PUSH4 scan and resolved through openchain, which is how the whole call surface in this README was established.
Argument types come from `IPortal.sol`, which ships verified inside `VaultPortalImpl`.
3. **Dispatch modules**, all unverified, all delegatecall targets of the Portal seen in real transaction traces:
`0xA90B476c...` on every `swapExactInput`, `0x0C84dD8B...` on the native-ETH curve path where the 1% fee is taken, `0xe5F72d6F...` on the non-ETH quote path.
4. **FlapCurvePairFactory** `0x0d1eBb179cdbcA88D74C923C4255Cb2B17474AfD`, unverified, confirmed by `Portal.flapCurvePairFactory()`.
One beacon-proxy curve pair per token, implementation `0xF9ADbAfF...`.
5. **Token implementations**: `FlapNonTaxToken` `0x88882688...` (verified) and `FlapTaxTokenV3` `0x7777C874...` (verified).
6. **Tax machinery**: `TaxProcessorUniV2` implementation `0x92C7ed36...` (verified) cloned per tax token, `TaxTokenHelper` `0xb10bD267...`, `SwapRegistry` `0x35Bae0b7...`, `Dividend` `0x95Ddb566...` cloned per token, `DividendClaimHelper` `0xA9af2890...`.
7. **VaultPortal** `0xe9F7AB7DE8FB8756acbB6a1cd13316a43308197B` (verified), the vault-backed launch path.
8. **Migration**: Uniswap V2 factory `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f`, example graduated pair `0x55aED1a1...`.
9. **FeeSafe** `0xa4A727E0918cf9B39639Fc4cB7D742d39C5352a4`, the fee recipient.

Every address the docs publish for Robinhood matched what is on chain, and the docs' version label `v5.14.16` is stale: the live Portal reports `v5.21.2`.

### Governance, which the docs do not cover at all

Read from the EIP-1967 admin slots and the Safes themselves (`_raw/rpc/proxy-admins.txt`, `_raw/rpc/feesafe-and-roles.txt`):

| what | who | threshold |
| --- | --- | --- |
| Portal, VaultPortal, SwapRegistry, TaxTokenHelper proxy admin | `ProxyAdmin` `0x21f7f9b33dfd0dbc3a94c0efa79f1546a1391ff5` | |
| Owner of that ProxyAdmin | Gnosis Safe `0xc68f29bfe2f6c3d95adb5685592b9f86680968f2` | **2 of 5** |
| TriggerService and DividendClaimHelper proxy admin | `ProxyAdmin` `0x49b0f3b3c2b4f92000dd8e5b89efbf4956ed8ddb` | |
| Owner of that ProxyAdmin | the FeeSafe | |
| FeeSafe, fee recipient | Gnosis Safe `0xa4A727E0918cf9B39639Fc4cB7D742d39C5352a4` | **2 of 3** |
| Portal `DEFAULT_ADMIN_ROLE` | the FeeSafe | |

So two signatures out of five can replace the Portal implementation that custodies every live bonding curve's reserve, and two out of three can change quote-token configuration, fee rates, token beneficiaries and the blocked-token list.
Two of the three FeeSafe owners (`0x01db3757...`, `0x29a64981...`) are also owners of the upgrade Safe, plus `0xa85c06f5...`, so the two Safes are not independent.
There is no timelock on either path.

### Third-party launchers

`SinjohFlapAdapterFactory` `0x77748D07CAD323A7f6EFa54968aCF69de743be61` (verified) deploys EIP-1167 adapters that wrap `Portal.newTokenV6` and take the commission slot.
The board also shows `IOO.fun` branding on a live bonding token (`pages/73-token-uber-bonding-curve.md`).
Launching on top of the Flap Portal is permissionless, which is worth knowing if the plan is to build a front end rather than use theirs.

## 6. Backend APIs the frontend uses

Host `https://batman.taxed.fun` (per-chain: `bnb.taxed.fun` for BSC), set as `backend` and `authBackend` in `_raw/js/robinhood-chain-config.js`.
**A browser `User-Agent` is required**; without one Cloudflare returns an interstitial.

```bash
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0 Safari/537.36"
curl -s -A "$UA" -H "Origin: https://flap.sh" "https://batman.taxed.fun/v3/board?limit=20"
```

| endpoint | purpose | captured |
| --- | --- | --- |
| `GET /v3/board?limit=&sort=&category=&cursor=` | the token list | `_raw/api/` board captures, `_raw/api/board-all-createdAt-desc.jsonl` |
| `GET /v3/coin/<address>` | one token, with curve parameters and holders | `_raw/api/api-v3_coin_moon.json`, `_raw/api/coins/` |
| `GET /v3/banners` | homepage promo slots | `_raw/api/api-v3_banners.json` |
| `wss://flap.rcto.fun/latest` | live price and trade feed | not captured |
| `https://batman-dividend.taxed.fun` | dividend profile backend | not captured |
| `GET https://flap.sh/api/bstocks/eligibility` | leveraged-stock gating, BSC feature | `_raw/network-board-tabs.json` |

`/v3/board` response shape:

```json
{"category":"trending","sort":"volume24h_desc","nextCursor":"5873.65477|0x3450...7777|20",
 "items":[{"coin":{"address":"0x862c...7777","name":"mooncat","symbol":"moon","image":"bafkrei..."},
   "listed":true,"quoteToken":"0x0000...0000","price":"0.005105","marketCap":"...","fdv":"...",
   "volume24h":"...","holders":2269,"liquidity":"...","change5m":"...","change1h":"...",
   "change4h":"...","change24h":"...","progress":"100.00",
   "tax":{"hasTax":true,"buyTaxBps":500,"sellTaxBps":500},"vault":null,
   "isInnovation":false,"isLowRisk":false,"createdAt":1787244980}]}
```

`/v3/coin/<address>` adds `creator`, `mode`, `r`, `h`, `k`, `version`, `dexThreshSupply`, `reserve`, `supply`, `pool`, `beneficiary` and a `holders` array.

**Pagination is capped.** `limit` is silently clamped to 20 and `nextCursor` stops after 10 pages, so the board yields at most 200 rows however you ask.
Ecosystem totals have to come from the chain, not this API.

Other hosts the app calls: `https://rpc.mainnet.chain.robinhood.com/` (the chain RPC, used directly from the browser), `https://api.binance.com/api/v3/avgPrice` and `https://hermes.pyth.network/` for quote prices, `https://flap.mypinata.cloud` for IPFS metadata, and `https://www.defined.fi/robinhood/<pair>/embed` for charts.

## 7. Ecosystem

Read from the chain on 2026-09-02 and 2026-09-03:

| metric | value | source |
| --- | --- | --- |
| Tokens ever launched on Flap Robinhood | **173,798** | `FlapCurvePairFactory.allPairsLength()`, `_raw/rpc/ecosystem-counts.txt` |
| Portal transactions | 405,407 | `_raw/blockscout/portal-counters.json` |
| `Portal.nonce()` | 295,537 | `_raw/rpc/ecosystem-counts.txt` |
| Graduated tokens | roughly 116 to 364, that is 0.07% to 0.21% | two independent samples, `_raw/rpc/graduation-sample.txt` |
| Uniswap V2 pairs on the chain, all protocols | 40,431 | `UniswapV2Factory.allPairsLength()` |

From the board's 200 rows (`_raw/rpc/board-summary.txt`):

- Quote mix: ETH 176, HOODon 11, GME 5, SPY 3, NVDA 2, NFLX 1, PLTR 1, BB 1.
- 181 of 200 are tax tokens. The most common rates are 1%/1% (66), 3%/3% (47), 2%/2% (34), 5%/5% (9), and three tokens sit at the 10%/10% maximum.
- 51 of 200 have a vault attached.
- Combined 24h volume across those 200 rows: about $2.64M. Combined liquidity: about $3.22M.
- Creation dates span 2026-07-09 to 2026-09-02, so the whole visible board is under two months old.

Largest launches by 24h volume at capture:

| token | name | market cap | 24h volume | liquidity | holders | quote | tax |
| --- | --- | --- | --- | --- | --- | --- | --- |
| $moon | mooncat | $5.01M | $760,628 | $352,061 | 2,270 | ETH | 5%/5% |
| $PRISM | Prism Assets | $2.31M | $698,246 | $383,661 | 2,518 | ETH | 3%/3% |
| $KITTENS | Dancing Kittens | $264K | $262,694 | $46,487 | 107 | HOODon | 1%/1% |
| $CHILLZ | Chilleez | $274K | $144,150 | $50,824 | 266 | NFLX | 2%/2% |
| $RAMEN | RAMENCOIN | $71K | $127,859 | $29,761 | 930 | ETH | 2%/2% |
| $AUREON | AUREON | $184K | $117,634 | $64,727 | 824 | ETH | 1%/1% |

DefiLlama, chain-filtered to Robinhood Chain, slug `flap-sh`:

| pull | 24h | 7d | 30d | all time |
| --- | --- | --- | --- | --- |
| 2026-09-02, `_market/_raw/llama-fees-robinhood.txt` | $9,177 | $58,950 | $179,570 | $1,077,783 |
| 2026-09-03, `_raw/llama/fees-robinhood-chain.json` | $20,994 | $120,133 | | $1,148,449 |

That puts Flap **8th among launchpads on this chain by all-time fees**, behind Pons V2 ($26.9M), Pons V1 ($23.9M), NOXA Fun ($20.9M), StonkBrokers ($3.5M), LetsCash ($2.0M), Pools ($1.5M) and o1 Launchpad ($1.16M), and ahead of Bags ($586K).

## 8. Link inventory summary

`LINKS.md` holds 312 rows.

| type | rows |
| --- | --- |
| docs page | most of the file; 59 docs pages, each link recorded once per source page |
| repo | 37 GitHub links, 3 repos cloned into `_raw/github/` |
| app | the Flap routes visited, all captured into `pages/` |
| social | X, Telegram, Discord, Farcaster, LinkedIn, CoinGecko |
| audit | CertiK Skynet, plus two BlockSec PDFs in `_raw/docs/files/` |
| external | backend API, RPC, price oracles, chart embeds, other chains' explorers |

34 rows are recorded without being fetched.
They are all links off the Flap surface: other chains' block explorers, `lucide.dev`, a Desmos calculator, `clawhub.ai`, the Binance skills repo, `rootdata`, `coingecko` and `linkedin`.

Docs coverage is complete: `https://docs.flap.sh/flap/sitemap-pages.xml` lists 59 URLs and all 59 are in `pages/` (`_raw/docs/sitemap-pages.xml` versus `_raw/docs/pages-index.tsv`).

## 9. Gaps

1. **The Portal implementation is unverified.** `0xa3b96df5...` has no published source, and neither do the three dispatch modules, `FlapCurvePairFactory`, `FlapCurvePair`, `SwapRegistryImpl`, `TriggerServiceImpl` or `DividendClaimHelperImpl`.
Everything in this README about the Portal's behaviour comes from decoded selectors, the verified `IPortal.sol` interface that ships inside `VaultPortalImpl`, decoded production calldata, live `eth_call`, and traced transactions.
It is good evidence, but it is not source.

2. **No wallet was connected.** The create form was captured unconnected, so the confirmation modal, the fee breakdown shown at signing time and the post-launch dashboard were not seen.
Nothing in section 4 depends on them; every number is from the chain or from decoded calldata.
The shared test wallet at `.env.testwallet` was not needed and was not used.

3. **No graduation was observed live.** The 11% price step from the last curve price to the opening pool price is arithmetic from the mechanism, not a measurement.
Confirming it needs a token watched across its migration transaction.

4. **Graduation count is a sample, not a census.** Two independent samples of 3,000 give 116 and 364. An exact figure needs a log scan of the migration event across the chain's history.

5. **The board API caps at 200 rows.** Per-token history beyond those 200 is not retrievable from the backend.

6. **Discord and Farcaster did not render** for Jina or for Bright Data, so no member counts were captured for either (`socials/04-discord-and-farcaster.md`).

7. **No audit covers what runs here.** The published audits are CertiK on Protocol V2 and V4 and Tax Token V1, and BlockSec on Protocol V5 with Tax Token V2 and PreLaunch V1.
Robinhood Chain runs Portal `v5.21.2` and **Tax Token V3**, and neither is covered by a published report.
CertiK Skynet lists Flap's ecosystems as BSC and Base only, so no Skynet score covers chain 4663 (`socials/05-certik-skynet.md`).

8. **The prelaunch page's network selector is stuck.** After switching the header chain to Robinhood, the in-form `Blockchain Network` field still reads `BNB` (`pages/71-prelaunch-reserve-ca.md`).
Whether that is cosmetic or whether it would lock a salt on the wrong chain was not tested, because testing it means paying the 0.003 ETH fee.

9. **`Terms and Conditions` and `Contact Us`** in the site footer were recorded in `LINKS.md` but not captured.

10. **Bright Data's `x_posts` pipeline under-returns.** Six status URLs were submitted and one record came back, which is the known behaviour noted in the playbook.
    The 20 most recent posts were recovered from the X syndication endpoint instead (`socials/02-x-flapdotsh-posts.md`).
