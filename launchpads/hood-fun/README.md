# hood.fun

## 1. Identity

| field | value |
| --- | --- |
| Name | hood.fun (styled `HOOD fun` in the app header) |
| App | <https://hood.fun/> |
| Docs | <https://hood.fun/whitepaper> - there is no docs subdomain and no `llms.txt`, `sitemap.xml` or `sitemap-pages.xml` on the host |
| Terms | <https://hood.fun/terms> |
| X | [@hooddotfun](https://x.com/hooddotfun), 3,976 followers, 161 posts, joined February 2025, blue verified (`socials/01-x-hooddotfun.md`) |
| Telegram | [t.me/hooddotfun](https://t.me/hooddotfun), 455 subscribers, channel created 10 September 2025 (`socials/02-telegram-hooddotfun.md`) |
| Contact | contact@hood.fun |
| Chains | Robinhood Chain mainnet only, chain id 4663. The app bundle also defines chain 46630 (Robinhood testnet) and mainnet, Arbitrum, Base and Optimism for the bridge, but every launchpad contract is on 4663 (`_raw/frontend-config-block.txt`) |
| Team handles | None published. The app names no individuals, and the on-chain owner is a Safe (section 5) |
| Capture date | 2026-09-02 and 2026-09-03 |

There is no self-description of a team anywhere in the app, the whitepaper or the X profile.
The X bio reads "Hood is the official launchpad for the Robinhood chain on the EVM network", which is a claim about status, not about who runs it.

## 2. What it is

hood.fun is a bonding-curve memecoin launchpad, a pump.fun clone in shape, built specifically for Robinhood Chain.
It is not built on Doppler.
The Doppler indexer at `indexer-prod.doppler.lol` returns `totalCount: 0` for all four hood.fun launchpads as `integrator` and as `poolInitializer`, and 0 for a hood.fun launch token as `address`, against a control of 110,392 assets on chain 4663 (checked 2026-09-03, playbook section 1).
Every contract in its launch path is its own, in a compact non-upgradeable set of four generations of launchpad plus migrators and lockers.

A creator picks a name, ticker and image, optionally picks a supply, a rewards mode and two anti-whale toggles, and pays nothing but gas.
The coin trades on an `x*y=k` virtual-reserve curve inside the launchpad contract, with 80% of supply on the curve and 20% held back.
When the last curve token sells, the same transaction that fills the curve seeds a Uniswap v3 1% pool with the raise and the reserved 20%, and locks the LP position forever in an ownerless locker.
The locked position keeps earning the pool's 1% fee, and that fee is split 80% creator / 20% protocol on the WETH side and 80% burned / 20% protocol on the token side.

It is aimed at people with no capital.
There is no creation fee, no presale, no team allocation, no LP to provide and no mandatory first buy.
The only outlay to launch is gas: one observed `createTokenGuarded` cost 1,235,667 gas, 0.000557 ETH, about $1.34 at the day's ETH price (`_raw/blockscout`-style pull of `addresses/0x8c529f.../transactions`, tx of 2026-09-02T20:15:00Z).

## 3. How a launch works, step by step, as a creator experiences it

### 3.1 The form

`pages/02-create.md` and `screenshots/09-create.png` are the whole create flow.
It renders fully without a connected wallet, so there was no wallet gate to pass on this platform.

Fields, in the order the form presents them:

1. **Image** (required in practice - the preview and the board tile use it).
2. **Coin name** and **Ticker**. "Choose carefully - none of this can be changed once the coin is live."
3. **Description**, optional.
4. **Social links**, optional.
5. **Banner**, optional. Required if you also want a holder comment board.
6. **Rewards** - "Where trading fees go - pick one, or neither": *Community coin* (fees stream to holders) or *Stock rewards* (fees buy a stock for holders). Picking either gives away the creator's own fee stream entirely; see section 4.
7. **Fair launch** toggles, described as "Plain creator coins only - a rewards mode turns these off": *Anti-snipe* ("Blocks bots for 2 min") and *max per wallet* (the form labels it 2%, the contract enforces 5%; see section 4).
8. **Liquidity & supply**: *Pair with a stock* ("Graduate into a stock LP, not ETH") and *Custom supply* ("Standard is 1 billion").
9. **Community**: add a holder comment board on the coin page. Needs a banner.
10. **Buy your own coin first**, optional, in ETH. "Runs inside the launch transaction as the curve's first buy - provably the first buyer, no sniper can beat you."

The form does **not** expose the trade fee.
Every one of the 354 coins on the live board has `tradeFeeBps` 100.
The contract accepts 100 to 500 (section 4).

The footer reads, verbatim, `Deploys a real coin on Robinhood Chain. Contracts fork-tested + being audited.`
"Being audited" as of 2026-09-03; no audit report is linked anywhere.

### 3.2 What the contract does on submit

The app calls `createTokenGuarded(name, symbol, metadataURI, minTokensOut, salt, tradeFeeBps, totalSupply_, antiSnipe, maxWallet)` on `HoodCustomLaunchpad` at `0x8c529f0a77c07ce0e6796f153d292501ee6f66f6`.
`msg.value` is the creation fee (0) plus the optional dev buy, so a launch with no dev buy sends 0 ETH.

- The token is deployed with CREATE2, salted `keccak256(msg.sender, salt)`, and **the address must end in `0x600d`** because `config.vanityEnforced` is `true` on every live launchpad. The app grinds the salt for you. Anyone calling the contract directly must grind it themselves, against their own address as the caller.
- `metadataURI` is a JSON string written into the calldata. On observed launches it carries the image as an inline `data:image/webp;base64,...` URI, which is why a create costs 1.2M gas rather than ~400k.
- Curve supply is `totalSupply * 80%`, LP supply is the remaining 20%, and the virtual token seed scales as `1,145,000,000e18 * totalSupply / 1,000,000,000e18` so the ETH economics are identical at any supply.
- The migration terms are snapshotted into `migrationTerms[token]` at this moment and `_migrate` reads the snapshot, never the live config. The owner cannot change an already-launched coin's fees.
- Any `msg.value` above the creation fee is spent immediately as the creator's first buy, inside the same transaction, subject to the same per-wallet cap as anyone else.

### 3.3 Trading, graduation and migration

Buys and sells run against the virtual reserves inside the launchpad.
Fee is `tradeFeeBps` on the ETH leg of both directions.
Three caps apply while the coin is on the curve:

- A launch **snipe guard** for `config.guardBlocks` = 100 blocks after creation, capping each wallet at `config.guardMaxWalletBps` = 10% of curve supply.
- An optional **anti-snipe** window of `ANTI_SNIPE_WINDOW` = 120 seconds capping each wallet at `ANTI_SNIPE_MAX_WALLET_BPS` = 0.5% of curve supply.
- An optional **max-wallet** cap of `MAX_WALLET_BPS` = 5% of curve supply on cumulative buys, on by default.

None of these survive graduation; the contract's own comment says so ("a real cap can't exist post-graduation").

When a buy takes `realTokens` to zero the coin graduates and migrates **in the same transaction**.
The public `migrate(address)` entrypoint exists only as a defensive fallback and reverts with `AlreadyMigrated` in normal operation.
This contradicts the whitepaper, which describes migration as a separate permissionless call (`pages/09-whitepaper.md` section 5).

`_migrate` deducts the migration fees from the raise, unlocks the token for free transfer, sends the LP supply and the remaining ETH to `migrator()`, and the migrator seeds a full-range Uniswap v3 1% position and hands the NFT to the locker.
The locker has no withdraw, no owner and no admin, so the position can never leave.

### 3.4 The stock-pair option

`migrator()` on the live launchpad is `HoodStockPairMigrator` at `0xC14F3Be12F5c0f3eE544Fc4E8883be981197f0be`, not `HoodV3MigratorV2`.
Before graduation, a coin's creator may call `selectQuote(token, quote)` on it to pair against something other than WETH.
Five quotes have a configured single-hop path today: USDG (0.05% pool), GME (0.05%), AAPL (0.05%), NVDA (0.3%) and TSLA (0.3%).
If the swap fails or the quote pool is too thin, the whole quote path rolls back in a `try/catch` and the coin migrates against WETH as normal.

**A creator should not use this.** See section 4.

### 3.5 The rewards modes

Both rewards modes are separate factory contracts that are whitelisted `platforms` on the launchpad with `feeShareBps` 2000 each.
They call `createTokenFor(creator = <a clone>, ...)`, so **the coin's `creator` on the launchpad is a vault contract, not the launcher's wallet**.

- `HoodCommunityFactory` at `0x6d188c21f99a7578d4E3fD449b67d740ff97eb4d` clones a `HoodCommunityRewards` per coin. Every creator fee - curve fees and the WETH creator share of the locked pool - lands in the clone and is pushed pro-rata to holders by a keeper, with the keeper reimbursing its own gas out of the pot, capped at 10% of a batch.
- `HoodStockFactory` at `0x1811F54e2964758641AaC993cA91F9189a8BdA2d` clones a `HoodStockRewards` per coin. The creator fees become a budget that buys a chosen whitelisted tokenized stock from sellers at an oracle price plus a capped premium, and a keeper distributes the acquired stock to holders on an epoch schedule.

A dev buy through either factory is routed to the launcher's own wallet, not to the vault.
The fees are not.
A third factory, `HoodCommunityGuarded` at `0xed2d2a46E64Bc84355eE3CD6A02ab470EA42147E`, is in the app bundle's list but `platforms()` reports it **not approved**, so it cannot launch anything today.

### 3.6 Handing a coin over

- `transferCreator(token, to)` moves future fees to another wallet immediately. Accrued fees are credited to the old creator as a claimable balance first.
- `proposeCto` / `executeCto` let the owner Safe move an abandoned coin's future fees to a new team behind a public 7-day timelock. The recipient can never be the owner or the launchpad itself. Accrued fees stay with the original creator.

## 4. Economics

All figures read from the chain on 2026-09-03 unless the source column says otherwise.
ETH price $2,405.47 from `https://hood.fun/api/ethprice` on 2026-09-03.

### 4.1 Live configuration of the launchpad in use

`config()` on `0x8c529f0a77c07ce0e6796f153d292501ee6f66f6`:

| item | value | source |
| --- | --- | --- |
| `virtualEthSeed` | 2.81 ETH | `config()` |
| `creationFee` | **0** | `config()` |
| `defaultTradeFeeBps` | 100 (1%) | `config()` |
| `migrationFee` | 0.05 ETH flat | `config()` |
| `migrationFeeBps` | 300 (3% of the raise) | `config()` |
| `guardBlocks` | 100 | `config()` |
| `guardMaxWalletBps` | 1000 (10% of curve supply) | `config()` |
| `creatorFeeShareBps` | **8000 (80%)** | `config()` |
| `vanityEnforced` | true - the token address must end `0x600d` | `config()` |
| `protocolMigrationFee` | **0.5 ETH flat**, 100% to protocol | `protocolMigrationFee()` |
| `migrator()` | `0xC14F3Be12F5c0f3eE544Fc4E8883be981197f0be` | `migrator()` |
| `pendingMigrator()` / `migratorUnlockAt()` | zero / 0 - no migrator change staged | `contracts/ADDRESSES.md` |

Constants in `contracts/HoodCustomLaunchpad-v2-default-.../sources/src/HoodCustomLaunchpad.sol`:

| constant | value |
| --- | --- |
| `CURVE_BPS` | 8000 - 80% of supply sells on the curve, 20% goes to LP |
| `DEFAULT_TOTAL_SUPPLY` | 1,000,000,000 |
| `DEFAULT_VIRTUAL_TOKEN_SEED` | 1,145,000,000 |
| `MIN_TOTAL_SUPPLY` / `MAX_TOTAL_SUPPLY` | 1 / 1,000,000,000,000,000 whole tokens |
| `MIN_TRADE_FEE_BPS` / `MAX_TRADE_FEE_BPS` | **100 / 500** |
| `MAX_MIGRATION_FEE_BPS` | 1000 |
| `MAX_TOTAL_MIGRATION_FEE_BPS` | 3000 - the total migration take is clamped, never reverted |
| `MAX_PROTOCOL_MIGRATION_FEE` | 1 ETH |
| `ANTI_SNIPE_WINDOW` / `ANTI_SNIPE_MAX_WALLET_BPS` | 120 seconds / 50 (0.5%) |
| `MAX_WALLET_BPS` | **500 (5%)** |
| `CTO_TIMELOCK` / `MIGRATOR_TIMELOCK` | 7 days each |

### 4.2 What a graduation actually pays out

Every one of the 23 `Graduated` events ever emitted across all four launchpads carries the same `raisedEth`: **6.5159 ETH**.
This is the deterministic consequence of a 2.81 ETH virtual seed against a 1.145e9 token seed with 0.8e9 on the curve.

| line | amount | who gets it | source |
| --- | --- | --- | --- |
| Gross buy volume to fill the curve at a 1% fee | 6.5817 ETH ($15,832) | - | derived from the raise |
| ETH into the curve (`raisedEth`) | 6.5159 ETH ($15,674) | - | `Graduated` logs, all 23 |
| Curve trade fees over the whole raise, buys only | 0.0658 ETH ($158) | 80% creator / 20% protocol | `_accrueFee` |
| Migration fee, 0.05 flat + 3% of raise | 0.24548 ETH ($590) | **80% creator / 20% protocol** | `_migrate`, `_accrueFee` |
| Flat protocol migration fee | 0.5 ETH ($1,203) | 100% protocol | `_migrate` |
| ETH seeded into the Uniswap v3 pool | **5.77046 ETH ($13,881)** | locked forever | `Migrated` logs, both v2 graduations |
| Tokens seeded into the pool | 20% of supply | locked forever | `Migrated` logs |
| **Creator take at graduation** | **~0.249 ETH ($599)** | creator | 0.0527 + 0.19638 |
| **Protocol take at graduation** | **~0.562 ETH ($1,352)** | protocol | 0.5 + 0.0491 + 0.0132 |

The protocol earns **2.26x what the creator earns** on a coin that graduates.
The 0.5 ETH flat fee is new to the current launchpad: the two older launchpads seeded 6.27046 ETH into their pools, the current one seeds 5.77046 ETH.

Graduation market cap is 27.03 ETH FDV, about **$65,022** at today's ETH price.
The whitepaper says "~26.9 ETH (~$44k)"; the ETH figure is right, the dollar figure was computed at roughly $1,636/ETH and is stale.

### 4.3 What a graduation pays out afterwards

The locked v3 position charges 1% per swap forever.
`HoodBurnLocker` splits the collected fee: `creatorShareBps` = 8000 of the **WETH** side to the creator and the rest to protocol, and `BURN_BPS` = 8000 of the **token** side burned to `0x...dEaD` with the rest to protocol.
Collection is permissionless and nobody can redirect it.

Observed lifetime creator income, summed from every `Collected` event:

| locker | positions | total creator WETH | median per position | mean | max |
| --- | --- | --- | --- | --- | --- |
| `0xad69d8...` (custom-v1 launchpad's 19 graduations) | 19 | 3.20378 WETH ($7,707) | **0.0008 WETH ($1.92)** | 0.1686 WETH ($406) | 1.5874 WETH ($3,818) |
| `0xd2a7c9...` (current launchpad's 2 graduations) | 2 | 2.16353 WETH ($5,205) | - | 1.0818 WETH ($2,602) | 2.1219 WETH ($5,104) |

The distribution is the whole story.
Across the 19 older graduations, six positions have paid their creator exactly zero, and the median has paid $1.92 for life.
Three positions account for 2.88 of the 3.20 WETH.

Protocol WETH from the same events is 0.540882 + 0.800945 = 1.341827 WETH, exactly a quarter of the creator total, which is the 80/20 split holding.

### 4.4 Three places the creator's money quietly goes to zero

These are the findings that matter most for a creator, and none of them are in the whitepaper.

1. **A rewards mode gives away 100% of the creator fee stream.** Both `HoodCommunityFactory` and `HoodStockFactory` set a clone as the coin's `creator`, so every curve fee and every WETH-side pool fee goes to holders or into a stock-buying budget, never to the launcher. 52 of the 354 coins on the live board, and 3,593 of the 10,629 on the 2026-09-02 board, are community coins. Three of the four graduated coins on the live board are community coins, including the top two by volume.
2. **Pairing against a stock or USDG burns the creator's post-graduation income.** `HoodBurnLocker._distribute` pays the creator only when the collected token *is* WETH; every other token goes down the burn branch. Pair a coin against USDG or NVDA and 80% of the quote-side fee is burned to `0x...dEaD`, 20% goes to protocol, and **the creator receives nothing at all, forever**. The migrator offers five such quotes and the create form offers the toggle. Nothing in the app or the whitepaper warns about this. The token-side burn is intended; the quote-side burn looks like an oversight in a contract written when the only quote was WETH.
3. **The 1% trade fee is a UI choice, not a protocol constant.** `MIN_TRADE_FEE_BPS` is 100 and `MAX_TRADE_FEE_BPS` is 500, and `tradeFeeBps` is a per-launch argument. A creator calling `createTokenGuarded` directly can set 500 and keep 80% of a 5% fee. The form does not offer it. 10,612 of 10,629 coins in the 2026-09-02 board snapshot used 100 bps; 5 used 500, 9 used 200, 3 used 300. The whitepaper's "Trade fee 1% flat" is a description of the interface, not of the contract.

### 4.5 Where the platform's numbers disagree with the chain

| claim | source of the claim | what the chain says |
| --- | --- | --- |
| "Trade fee 1% flat" | whitepaper section 4 | `tradeFeeBps` is a launch argument bounded 100 to 500 |
| "a 5%-of-curve per-wallet cap" | whitepaper section 6 | `MAX_WALLET_BPS` = 500, so 5% is right - but the create form says "2% max per wallet" and the contract's own natspec comments say 2% in three places |
| "Anyone can then call the permissionless migrate function" | whitepaper section 5 | migration is atomic inside the graduating buy; the public `migrate` reverts `AlreadyMigrated` in normal operation |
| "Graduation market cap ~26.9 ETH (~$44k)" | whitepaper section 3 | 27.03 ETH is right, $44k implies $1,636/ETH against today's $2,405 |
| "the protocol owner - a 2-of-3 multisig (Gnosis Safe)" | whitepaper section 7 | true for the current owner (`getThreshold()` 2, three owners), but there are **two** such Safes with different owner sets, one over the current launchpad and one over the three older ones |
| "migrates to official Uniswap v3" | whitepaper section 5 | true, but through `HoodStockPairMigrator`, a contract the whitepaper never mentions and whose stock-pair path silently costs the creator all post-graduation income |
| "Contracts fork-tested + being audited" | create page footer | no audit report is published. The sources carry `AUDIT`, `AUDIT #2`, `AUDIT H-1`, `AUDIT M-1` and `AUDIT L-1` fix comments, so a review clearly happened |

## 5. Smart contracts

Full table with creators, creation transactions and per-contract directories: `contracts/ADDRESSES.md`.
38 contract directories, 34 with verified sources, 4 bytecode-only.

The live launch path is five contracts:

| role | address | verified |
| --- | --- | --- |
| `HoodCustomLaunchpad` (current) | `0x8c529f0a77c07ce0e6796f153d292501ee6f66f6` | yes |
| `HoodStockPairMigrator` (its `migrator()`) | `0xC14F3Be12F5c0f3eE544Fc4E8883be981197f0be` | yes |
| Uniswap v3 `NonfungiblePositionManager` | `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3` | yes |
| Uniswap v3 factory | `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA` | yes |
| `HoodBurnLocker` (its `locker()`) | `0xd2a7c92fcb240c755919e9230c8db066e9ca1500` | yes |

### 5.1 Four launchpads, not one

Reading `tokenCount()` on each:

| launchpad | address | launches | graduations | `creatorFeeShareBps` | owner |
| --- | --- | --- | --- | --- | --- |
| classic `HoodLaunchpad` | `0x6a63d96ef77ae569fcb85934cf1bd1ec7fe9b33d` | 85 | 2 (2.4%) | **5000** | legacy Safe |
| custom v1 | `0x5Fcc1DF0dC020CF454e742E9a8Ae2554C37A452C` | 10,575 | 19 (0.18%) | 8000 | legacy Safe |
| custom, third deployment | `0x3d1c455f81ec131cc91b000b42fccbf45a132026` | 14 | 0 | 8000 | legacy Safe |
| **custom v2, current** | `0x8c529f0a77c07ce0e6796f153d292501ee6f66f6` | 352 | 2 (0.57%) | 8000 | current Safe |
| | | **11,026** | **23 (0.21%)** | | |

Launch and graduation counts are `tokenCount()` and a full-range `eth_getLogs` on each launchpad's `Graduated` topic, on 2026-09-03.

The third launchpad is not mentioned anywhere in the app, the whitepaper or the frontend config block.
It was found by reading `launchpad()` off `HoodV3MigratorV2-b`, which is the playbook's "read the pointer from the consumer" rule applied in reverse.

### 5.2 Two owner Safes with different owner sets

| Safe | controls | `getThreshold()` | `getOwners()` |
| --- | --- | --- | --- |
| `0x8E96a84AdC54d04869ded92661a01f75e283741B` (SafeL2 1.4.1) | current launchpad, `HoodStockPairMigrator`, `HoodCommunityFactory`, `HoodStockFactory` | 2 | `0x7218c9dd9abd93e8f10bc0699af6af70b2746668`, `0xbfb8a920b80d65c1778be32e82e1cd3dad535885`, `0x380f9a94cf165fdd8747c733e1d265b575b15da8` |
| `0xB3f3B54E11217F4F73e7a766B7CAA187390d700D` | classic, custom v1 and the third launchpad | 2 | `0xb2327f35fa82c1ad07b6f894ecde30817c61af92`, `0x906ec2115fea4cf1a0622ebfcd474efc8bf3e65e`, `0x45dd1f09efd94c11aed36d14db8d05e67e77c143` |

Both are 2-of-3 with no timelock over the Safe itself.
The whitepaper describes one Safe; there are two, with no overlapping signer.
Neither can touch curve reserves or locked liquidity: the launchpad has no such function and the locker has no owner.
What the current Safe can do is set fee config for future launches, change the migrator behind a 7-day public timelock, execute a CTO behind a 7-day public timelock, whitelist platform contracts and their fee share, set `protocolMigrationFee` up to 1 ETH, and withdraw accrued protocol fees.

### 5.3 Lockers

Four lockers exist, one per migrator generation, and each holds its generation's positions permanently.

| locker | contract | positions locked |
| --- | --- | --- |
| `0xd2a7c92fcb240c755919e9230c8db066e9ca1500` | `HoodBurnLocker` (live) | 2 |
| `0xad69d8a00564f4a2365cc74594925f95281706aa` | `HoodBurnLocker` | 19 |
| `0x86083371c51654816518c35cc589871c24018a54` | `HoodLiquidityLocker` | 2 |
| `0x5e27754b2cdf4fe3715451d2d3d267801e0f4934` | `HoodBurnLocker` | 0 |

`HoodLiquidityLocker` is a different contract from `HoodBurnLocker` with a different `Collected` event layout; decoding its logs with the burn locker's ABI produces nonsense, and I did not decode it separately.

### 5.4 Verification

34 of 38 archived contracts are fully verified with sources.
The four bytecode-only directories are the community-factory implementation, the stock-factory implementation, the `HoodCommunityGuarded` implementation and the legacy owner Safe proxy.
The first three are `new`-deployed by verified factories, so the factories' own sources are the readable source, exactly as the playbook's section 4 predicts; each directory's README names the factory to read.

## 6. Backend APIs

The app is a Next.js SPA.
Its own routes, from `_raw/network-home.txt`, the raw captures and direct probing on 2026-09-03:

| route | method | shape |
| --- | --- | --- |
| `GET /api/board` | GET | `{tokens: [...], activity: {byToken, recent}, profiles: {...}}`. The whole board in one response, 370 KB today. Each token: `address, launchpad, creator, name, symbol, metadataURI, createdAtBlock, timestamp, totalSupply, hasImage, isCommunity, rewardsVault, curve{virtualEth, virtualTokens, realEth, realTokens, creator, createdAtBlock, graduated, migrated, tradeFeeBps}, pairPriceWei`. `activity.byToken[addr]` is `{volumeWei, vol4hWei, vol24hWei, tradeCount, lastTradeBlock, lastBuyBlock, spark[]}`. |
| `GET /api/token/<address>` | GET | One token record in the same shape. `{"error":"unknown token"}` with HTTP 404 for anything the indexer does not carry. |
| `GET /api/trades/<address>` | GET | Trade feed for a coin. Timed out on a 25s probe on 2026-09-03; the 2026-09-02 capture of the same route for FEATHER returned `{"error":"unknown token"}`. |
| `GET /api/partners/by-wallet/<address>` | GET | `{"slug": "axiom", "label": "Axiom"}` even for the zero address, so it is a partner-attribution lookup with a default. |
| `GET /api/ethprice` | GET | `{"usd": 2405.465}` |
| `GET /api/version` | GET | `{"v": "dpl_AbdfUcC5WeNP41qZJi9kKDSuJUjw"}`, the Vercel deployment id |
| `/api/presence` | not GET | HTTP 405 to a GET |
| `/api/rpc` | not GET | HTTP 405 to a GET. Same-origin JSON-RPC proxy for chain 4663 |
| `GET /api/token-image/<address>`, `GET /api/coin-banner/<address>` | GET | Image routes used by the board and coin pages |

Raw captures: `_raw/api-board.json` (2026-09-02, 8.5 MB), `_raw/api-board-2026-09-03.json` (370 KB), `_raw/api-version.json`, `_raw/api-ethprice.json`, `_raw/api-token_*.json`, `_raw/api-trades_*.json`, `_raw/api-partners_by-wallet_*.json`.
`_raw/api-board-stats.json` is **not** a raw API response: it is a locally derived summary of the 2026-09-02 board, written by an earlier session.
Treat its numbers as derived, not observed.

`https://app.doppler.lol/api/rpc/4663` served every `eth_call` and `eth_getLogs` in this archive. hood.fun's own `/api/rpc` was not needed.

## 7. Ecosystem

### 7.1 The board was reset between the two capture days

This is the single largest thing to know about hood.fun's public numbers.

| | 2026-09-02 09:36 | 2026-09-03 03:35 |
| --- | --- | --- |
| tokens in `/api/board` | 10,629 | 354 |
| launchpads represented | custom v1 (10,570), classic (59) | current (352), custom v1 (2) |
| first token timestamp | 2026-07-06 19:11 | 2026-07-10 14:28 |
| last token timestamp | 2026-07-31 04:14 | 2026-09-02 20:15 |
| profiles | 72 | 0 |
| record fields | no `isCommunity`, no `rewardsVault`, no `curve.tradeFeeBps` | all three present |

Between the two captures the indexer was repointed from the older launchpads to the current one, and 10,568 coins of history left the board.
The two custom-v1 coins that survived are FEATHER and Robin, both graduated.
`/api/token/<addr>` now returns `unknown token` for any coin from the dropped set, so a creator who launched before this switch has lost their coin page.
The contracts are untouched; only the interface changed.

### 7.2 Scale and activity

From the chain, 2026-09-03: **11,026 launches, 23 graduations, a 0.21% graduation rate**.

From the 2026-09-02 board snapshot of 10,629 coins (`_raw/api-board-stats.json`, derived):

- 3,593 community coins (33.8%)
- 635 coins with any trading activity at all (6.0%)
- 23,621 trades, 1,335.40 ETH cumulative volume
- 24h volume 0.098 ETH, about $236 across the whole platform
- 72 creator profiles
- supplies: 6,552 at 1B, 1,529 at 1T, 1,461 at 100M, 1,018 at 1M

From the live board, 2026-09-03:

- 310 of 354 coins have activity, 25,376 trades, 959.69 ETH cumulative
- 24h volume 1.113 ETH, about $2,677 across the whole platform; 4h volume 0
- one coin, Buttkiss (`DICK`), is 541 of those 960 ETH

DefiLlama does not track hood.fun as a launchpad (`pages/15-ext-defillama-launchpads.md`), so there is no third-party fee series to check against.

### 7.3 Notable launches

| coin | address | note |
| --- | --- | --- |
| Buttkiss `DICK` | `0xE62bEafF79E79EEf9F08f7fD47FEB6b96A04600D` | Highest volume on the platform, 541 ETH. Graduated on the current launchpad. A **community** coin, so its creator earned nothing from it |
| FEATHER | `0x72081aDC58bdb794b989d424a65948c16848600d` | 115 ETH, graduated on custom v1, community coin. Coin page shows "$3.0k paid to holders, 11 sends so far" (`pages/06-coin-feather.md`) |
| DeepFuckingValue `DFV` | `0xE584d4b1BB5BbBfc2Cc63a9bE5a59a871f8F600d` | 60 ETH, graduated on the current launchpad, community coin (`pages/07-coin-deepfuckingvalue.md`) |
| Robin | `0x67AF360b375DC86aE5Ad620693bfCD916A31600D` | 8.75 ETH, graduated on custom v1, not a community coin |
| Cat Meme Index `CMI` | `0x68af2a31212FBd3F02Bb0f761713C559eE72600d` | 406 ETH in the 2026-09-02 snapshot, the top coin of the old board, now dropped from the board |

### 7.4 Quote assets available for pairing

WETH by default.
Five configured single-hop paths on the migrator: USDG `0x5fc5360D...` (0.05%), GME `0x1b0E319c...` (0.05%), AAPL `0xaF3D76f1...` (0.05%), NVDA `0xd0601CE1...` (0.3%), TSLA `0x322F0929...` (0.3%).
The app bundle lists 50 Robinhood tokenized stocks and ETFs as `STOCK_ASSETS`, every one marked live, so the migrator's whitelist is far narrower than the UI's asset list.

## 8. Link inventory summary

`LINKS.md` has 489 rows.
The one URL `launchpad-research.md` lists for this platform, `hood.fun` (entry 8.1), is the first row.

- 8 app routes: `/`, `/create`, `/swap`, `/bridge`, `/portfolio`, `/whitepaper`, `/terms`, `/coin/<address>`. All captured as `pages/01` to `pages/10`.
- `/creator/<address>` and `/coin/<address>` are templated routes with one instance per wallet and per coin. Three coin pages captured; creator profiles not visited, see section 9.
- 2 social destinations, both captured: `x.com/hooddotfun` and `t.me/hooddotfun` (plus the `t.me/s/` preview).
- 6 external pages about hood.fun captured as `pages/13` to `pages/18`: two TrustSwap guides, DefiLlama's Robinhood Chain launchpad list, a Bitcoin Foundation round-up, the TMCnet launch press release and a KuCoin article that names hood.fun alongside Pons.
- No docs subdomain, no `llms.txt`, no `llms-full.txt`, no sitemap. `/whitepaper` is the complete documentation.

## 9. Gaps

- **Creator profile routes were not visited.** `LINKS.md` carries 193 distinct `/creator/<address>` links harvested from the DFV trade and holder feeds. They are one template with one instance per wallet; visiting them would add no information about the platform. The template itself is visible inside `pages/07-coin-deepfuckingvalue.md`.
- **One coin page capture came back as the terms overlay.** `pages/08-coin-cat-meme-index.md` is Jina's terms-gate output rather than the page. The same reader returned full pages for the two coins either side of it on the same run, so this is a reader flake, not an upstream gate. Recorded rather than re-chased.
- **`/swap`, `/bridge` and `/portfolio` capture only the terms overlay.** Those three routes render the accept-terms modal to any client with no stored acceptance, and Jina has no cookie jar. The screenshots do not cover them either. What is behind them is a Uniswap-style swap widget on `SwapRouter02`, an Arbitrum-stack bridge, and a wallet-gated portfolio; none of it is part of a launch.
- **`GET /api/trades/<address>` was not captured against a live token.** It timed out on a 25 second probe. Its shape is inferred from the coin page's trade feed, not observed.
- **`HoodLiquidityLocker` logs were not decoded.** It is a different contract from `HoodBurnLocker` with a different `Collected` layout, and it holds only the classic launchpad's 2 positions.
- **No audit report.** The create page says "being audited". The sources carry numbered audit-fix comments (`AUDIT #2`, `AUDIT H-1`, `AUDIT M-1`, `AUDIT L-1`), so a review happened, but no report or auditor is named anywhere.
- **The X syndication endpoint is empty for this account.** `syndication.twitter.com/srv/timeline-profile/screen-name/hooddotfun` returns a valid 2.2 KB page with `entries: []`. The five most recent posts came from the Bright Data `x_posts` pipeline by status URL instead (`socials/04-x-posts-hooddotfun.md`). The full 161-post history was not retrieved.
- **No team identity.** Nothing in the app, the whitepaper, the X profile, the Telegram channel or the press release names a person or a company. The two owner Safes have six distinct signer addresses between them and none is labelled on Blockscout.
- **No wallet-gated flow was exercised.** None was needed: the create form renders fully unconnected, and every number in this document came from the chain or from the app's own JSON. No agent-browser session was opened, so there is none to close.
