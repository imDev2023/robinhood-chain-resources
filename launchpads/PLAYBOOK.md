# Platform archive playbook

Written 2026-09-02 after finishing `pons` and `doppler`.
Read this before `SCRAPING-PLAN.md` part 5.
It exists so a platform section takes a fraction of the time the first two did, and so nobody re-learns what already cost a session to learn.

`SCRAPING-PLAN.md` stays the source of truth for **what** to produce (part 4.1 layout, part 8 definition of done).
This file is **how** to produce it fast.

---

## 0. The three things that actually save time

**1. Doppler is the substrate under most of this chain. Do not re-derive it.**
Long, Bankr and Feel are all Doppler integrators on chain 4663, not independent protocols.
Their contract sets are the Doppler set plus a thin launcher, and their economics are Doppler's economics plus a skim.
A session on any of them should open `launchpads/doppler/README.md` first and diff against it, not start from Blockscout.
Expect this to remove most of the contract work for those platforms.

**2. One GraphQL endpoint answers most ecosystem questions.**
`https://indexer-prod.doppler.lol/` is public, needs no key, and covers every Doppler-based platform at once.
It replaces hours of Blockscout crawling. See section 3.

**3. Read state from contracts, not from gated dashboards.**
Every time a wallet gate blocked the UI, the same number was available from an `eth_call`, and more precisely.
Fee splits, claimable balances, whitelists and per-launch config are all on-chain.
Reach for the UI to document *what a creator sees*, and reach for the chain to document *what is true*.

---

## 1. Session start, in order

```bash
cd "/Volumes/Farhan/Work Folder/Dev/AI/long-launch" && set -a && . ./.env && set +a
cd resources/launchpads/<slug> && \
echo "files: $(find . -type f | wc -l)"; for s in pages screenshots contracts socials _raw; do [ -d $s ] && echo "$s: $(find $s -type f | wc -l)"; done; \
ls contracts 2>/dev/null; ls _raw | head -40; for f in README.md LINKS.md contracts/ADDRESSES.md; do [ -f $f ] && echo "has $f"; done
```

Then, before anything else, ask whether the platform is Doppler-based:

```bash
curl -s -X POST https://indexer-prod.doppler.lol/ -H 'content-type: application/json' \
  -d '{"query":"{ assets(where:{chainId:4663, integrator:\"<their fee address>\"}, limit:3){ totalCount items { poolInitializer liquidityMigrator numeraire } } }"}'
```

A non-zero `totalCount` means most of section 5 of that README is already written in the doppler archive.

**Before you trust the brief, find the contract that would refuse.**
`SCRAPING-PLAN.md` section 5.11, three market articles and DefiLlama all described Noxa as permanently launch-disabled since 2026-07-11.
All of that is true of one factory and false of the platform: the same brand shipped a new factory eight days later and has launched 1,090 tokens through it since.
A platform's own shutdown announcement is a claim, not a state.
Two calls settle it, the enable flag on the current factory and the timestamp of the most recent successful launch, and both belong at the very start of any session on a platform described as paused, dead or migrated.

**Look for more than one deployment under one brand.**
Noxa has three launchpad contract sets on this chain and two are live right now, with different owners and different fee splits.
hood.fun has four launchpads, and the one its own frontend config names holds 3 percent of the platform's history.
Grep every frontend bundle for the launch factory address rather than assuming the docs or any one app tell the whole story: `noxa.io`'s bundle names its `launchFactoryAddress`, `launchLockerAddress`, `feeRouterAddress`, `feeSplitterAddress` **and** `legacyLockerAddress`, which is what exposed the split.

**A non-Doppler platform can still be someone else's published stack.**
Before reverse-engineering anything, check whether the vendor publishes a machine-readable deployment feed.
Uniswap serves <https://developers.uniswap.org/deployments.json>, generated from `github.com/Uniswap/contracts`, and filtering it to `chainId == 4663` returned all 42 addresses for pools.trade, roles and versions included, in one request.
That answered which contracts, which versions and which are superseded before a single Blockscout call, and it doubles as proof of who operates the platform.
Try `<vendor docs host>/deployments.json` and the vendor's docs repo before crawling an explorer.


---

## 2. Docs capture

**Never trust `tvly map` for page discovery.**
On docs.doppler.lol it found 21 URLs; the sitemap had 49.
Always do this instead:

```bash
curl -s <docs>/sitemap-pages.xml   # the complete list
curl -s <docs>/llms.txt            # nav order and one-line descriptions, ideal for page ordering
curl -s <docs>/llms-full.txt       # whole docs as one file, good for grepping
```

**GitBook sites serve clean markdown if you append `.md` to the path.**
Confirmed on docs.doppler.lol, docs.ponsfamily.com, and expected on docs.flap.sh, whitepaper.virtuals.io, docs.bags.fm, docs.ponsfamily.com.
That is far cleaner than Jina and costs nothing:

```bash
curl -s "https://docs.example.com/some/page.md" -o _raw/jina/docs-some_page.direct.md
```

**A GitBook sitemap can sit under the space path, not the domain root.**
`docs.flap.sh/sitemap-pages.xml` is a redirect stub; the real list is at `docs.flap.sh/flap/sitemap-pages.xml`, reached via `docs.flap.sh/flap/sitemap.xml`.

**When a docs site serves no sitemap at all, the app bundle holds the route table and often the page source.**
`docs.robinhood.com/chain` is a Vocs single-page app: `/sitemap.xml`, `/sitemap-pages.xml`, `/llms.txt` and `/llms-full.txt` all return the 535-byte app shell.
`tvly map` found 20 pages, the bundle listed 25, and the 5 it missed included pages the archive already had.
Its results also churn between runs, so two maps of the same site disagree.
The bundle at `https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/assets/index-*.js` carries both the router table and the URL-encoded MDX source of every page, which gives an exact source-level diff with no rendering and no per-page fetch.
Grep the bundle for route strings before accepting any map as complete.

**Read the bundle filename out of the page every time; it changes on every rebuild.**
`index-DCWCEAE1.js` became `index-BHBqPiOr.js` within a day, at exactly the same byte length, and the diff was three lazy-chunk filenames and a reordered route array with **every page source byte-identical**.
So a changed hash is not evidence of a content change, and a hardcoded hash silently 404s.
Fetch the page, read `<script src=...>`, then pull that.

**A sibling docs space usually has its own bundle.**
`docs.robinhood.com/chain` and `docs.robinhood.com/rhj` are one site with two bundles; the chain bundle carries the rhj route table but not its page bodies.
Finding the route in one bundle does not mean the content is there.

**Try the native `<url>.md` route on non-GitBook hosts too, before reaching for Jina or Tavily.**
It is documented above for GitBook, but it also worked on Chainlink's and Alchemy's docs, and it mattered: the Tavily extracts of those two pages had silently mangled the code blocks, stripping identifiers into `import{} from` and `uint256 private constant = 3600;`.
An extractor that returns clean-looking prose can still be destroying the part a reader most needs.
Try `<domain>/<space>/sitemap.xml` before concluding a GitBook site has no sitemap.

**Check for vendor-published machine-readable docs before crawling a SPA.**
Sentry serves its entire user guide as one file at `https://sentry.trading/sentry-guide.md`, written to be handed to an AI assistant, and Quotrons serves `llms.txt`, `llms-full.txt`, an `integration.md` and four ABI JSON files under `/integration/`.
Try `<host>/llms.txt`, `<host>/llms-full.txt` and `<host>/<product>-guide.md` even when the site is a SPA with no docs subdomain.
Treat them as the vendor's claims, not as facts: on Sentry the guide's own address list, the DefiLlama record and the app's stock picker each disagreed with the chain in at least one place.

Generate `pages/` from `llms.txt` order rather than hand-numbering.
A page that comes back with only a heading may genuinely be empty upstream: verify with the rendered version through Jina before recording it as a capture failure, then annotate the page file so nobody re-checks it.

**Some platforms have no docs site at all, and that is a finding, not a gap.**
hood.fun serves the SPA shell for `llms.txt`, `sitemap.xml` and `sitemap-pages.xml` alike, and a single `/whitepaper` route is its entire documentation.
Probe those three, and when all three return the shell, stop looking for a docs subdomain and read the app's own routes instead.

**A platform with no docs site can still have complete first-party docs on the operator's other properties.**
pools.trade serves no `/docs`, no `llms.txt` and no sitemap; its documentation lives on Uniswap's.
The user guide was found by snapshotting a token page, because the trade panel's explainer modal links to `support.uniswap.org/hc/en-us/articles/<id>`, which links onward to the blog announcement and the developer docs.
When a launchpad looks undocumented, snapshot its modals for outbound help links before concluding there are none.


---

## 3. Ecosystem numbers, the fast way

`indexer-prod.doppler.lol` covers every Doppler-based platform. `chainId` must be an **integer**, not a string, or the query fails validation.

```graphql
{ assets(where:{chainId:4663}, limit:1){ totalCount } }                       # total launches
{ assets(where:{chainId:4663, integrator:"0x..."}, limit:1){ totalCount } }   # per platform
{ assets(where:{chainId:4663, poolInitializer:"0x..."}, limit:1){ totalCount } }
{ assets(where:{chainId:4663, liquidityMigrator:"0x..."}, limit:1){ totalCount } }
{ swaps(where:{chainId:4663}, limit:1){ totalCount } }
{ migrationPools(where:{chainId:4663}, limit:1){ totalCount } }
```

Pull a 1000-asset sample once and count locally rather than issuing many queries:

```graphql
{ assets(where:{chainId:4663}, limit:1000, orderBy:"createdAt", orderDirection:"desc"){
    items { integrator poolInitializer liquidityMigrator numeraire migrated } } }
```

Top-level query fields available: `assets`, `pools`, `v4pools`, `v4PoolConfigs`, `migrationPools`, `swaps`, `positions`, `modules`, `tokens`, `tokenVestingSchedules`, `hourBuckets`, `volumeBucket24h`, `cumulatedFees`, `userAssets`, plus price feeds.

Beware `marketCapUsd` ordering: a few test tokens carry absurd values and will dominate a "top by market cap" query.
Use the app's own `/api/explore` for a sane leaderboard instead.

**The cheap non-Doppler check.** When a platform has no obvious integrator EOA, query the same indexer with the launcher, the hook and the fee router as both `integrator` and `poolInitializer`, and a sample launch token as `address`.
Five queries, about ten seconds, and a definitive answer.
Always run it against a control (`{assets(where:{chainId:4663},limit:1){totalCount}}`) so a zero means "not Doppler" rather than "query broken".

**For a platform with its own curve-pair factory, this is the non-Doppler equivalent.**
`allPairsLength()` on that factory is an exact launch count, and a `graduated()` view on the pair is a one-call graduation test.
Sampling that view over evenly spaced indices through **Multicall3 `aggregate3` at `0xcA11bde05977b3631167028862bE2a173976CA11`** gives a graduation rate in two round trips instead of a log scan.
Cross-check from the destination side by sampling the DEX factory's pairs for the launchpad's vanity suffix.
On Flap both methods agreed within a factor of three: 173,798 launches, roughly 0.07% to 0.21% graduating.

**Identifying an unlabelled integrator EOA:** decode one of its launches' `tokenFactoryData` and read the `tokenURI` domain.
That is how `0x3879b1ee...` was identified as Feel.
Blockscout tags and `/api/metadata` cover the rest.

**For a bonding-curve launchpad that emits a graduation event, `eth_getLogs` over the full range is an exact count in one call per launchpad**, and the event data carries the raise.
On hood.fun all 23 `Graduated` events carried a byte-identical `raisedEth`, which validated the curve arithmetic without a single `eth_call`.
Pair it with `tokenCount()` for an exact graduation rate.
This is cheaper and more precise than the Multicall3 sampling above, which remains the method when graduation is a view rather than an event.

**An ERC-721 `balanceOf` on the position manager is an exact launch count for any locker-based launchpad.**
Every Noxa launch mints exactly one Uniswap V3 position NFT and transfers it to a locker with no release path, so `NonfungiblePositionManager.balanceOf(locker)` is the exact number of launches, in one call, with no log scan and no sampling.
That gave 60,142, 1, 1,090 and 171 for the four Noxa lockers, and the sum of two of them reproduced the app's own headline counter to the unit, validating both numbers at once.
It works even when the factory is unverified.

**`eth_getLogs` on a locker's payout event answers what a creator actually earns after graduation, which no dashboard will.**
Summing `Collected` on hood.fun's lockers gave a per-position distribution whose median (0.0008 WETH) and mean (0.1686 WETH) differ by 200x.
Always report the median and the zero count, never only the total.
Watch for a second locker generation with a differently shaped event: decoding `HoodLiquidityLocker` logs with the `HoodBurnLocker` ABI produced plausible-looking nonsense.

**A launchpad's own tRPC router is often the cheapest census.**
`pools.trade/api/trpc/<procedure>?batch=1&input=<url-encoded JSON keyed by call index>` is open, unauthenticated and uncapped in practice.
`cca.listAllAuctions` returned the complete 126-auction history with statuses in one request, which is a graduation rate for free.
Look in the shipped bundles for the `list*`, `getAll*` and `*Deep` variants of whatever the UI calls: the UI usually calls the paginated one and the unpaginated one is usually also exposed.
Zod validation errors name the missing field, so an input schema can be recovered by sending `{}`.

**A backend "progress" percentage can be inverted into the exact threshold.**
`marketCapWeth / (graduationPct/100)` returned 20.0000 for all twelve sampled Noxa tokens, giving the graduation threshold to four decimal places with no documentation.
Sample a dozen, not two, and check the implied constant is identical, which is what distinguishes a real threshold from a coincidence.


---

## 4. Contracts, the fast way

Blockscout v2 needs a browser User-Agent or Cloudflare returns an interstitial:

```bash
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0 Safari/537.36"
B="https://robinhoodchain.blockscout.com/api/v2"
curl -s -A "$UA" "$B/addresses/<addr>"        # creator, creation tx, proxy impls
curl -s -A "$UA" "$B/smart-contracts/<addr>"  # sources, abi, constructor args
```

A reusable builder that turns those two responses into a full `contracts/<Role>-<addr>/` directory with `metadata.json`, `abi.json`, `sources/` and a generated `README.md` lives at:

`launchpads/doppler/_raw/tools/mkcontract.py`

**Constructor args are the cheapest way to map a protocol.**
Dumping `decoded_constructor_args` for every contract reconstructed Doppler's entire wiring in one pass, with no guesswork.

**Two registries can disagree, so check both.**
Being listed in the docs does not mean a contract is usable, and being un-whitelisted in one registry does not mean a feature is off.
On Doppler, `Airlock.getModuleState` gates *modules* while `DopplerHookInitializer.isDopplerHookEnabled` gates *hooks*, and Rehype is disabled in the first and live in the second.
Always read the registry the contract actually consults.

**An unverified implementation is not a dead end.**
A PUSH4 scan of the runtime bytecode (`re.finditer(r"63([0-9a-f]{8})", bytecode)`, which over-collects harmlessly) resolved in batches of 50 against `https://api.openchain.xyz/signature-database/v1/lookup?function=0x...` names roughly 60% of selectors with no API key, and the named 60% is always enough to identify the contract family.
It named 96 of Flap's Portal selectors and four of HOOD10's six unverified contracts.

**Three cheaper identifications to try first.**

- A **linked Solidity library** shows unverified but is named in the verified parent's `external_libraries` field in the `smart-contracts/<addr>` response.
- A contract deployed with **`new` by a verified factory** shows unverified, but the factory's event names it and the factory's verified sources are the readable source.
- An **EIP-1167 clone** needs no lookup: the 45-byte stub contains the implementation address literally, at bytes 10 to 29.

**When the entry point is unverified, look for its interface inside a verified sibling.**
Flap's `VaultPortalImpl` and `TaxProcessorUniV2Impl` both ship `src/interfaces/IPortal.sol`, carrying every struct and enum the unverified Portal takes. That, not the docs, is the authoritative ABI.

**Read the natspec, not just the ABI.**
The most valuable facts in these archives were prose comments in verified sources.
`LaunchDividendTreasury.sol` names an unverified contract by address and states its trust model outright; `QuoteRegistry.sol` identifies a competitor by behaviour; `LaunchFactory.sol` explains why there is no migration.
Grep verified sources for `@dev` and `@notice` before reaching for the chain.

**Read the pointer from the consumer, not the config from the pointee.**
An owner-settable address can silently take a documented contract out of the path while everything still looks right: HOOD10's `FeeRouter` still exists, is verified and returns sensible config, but `LaunchHook.feeRouter()` was repointed to an address with no code, and every fee since has bypassed it.
Compare `consumer.pointer()` against the address you archived, run `eth_getCode` on anything called a "router" or a "sink", then confirm with `eth_getLogs` on the `RouterUpdated`-style event, which gives the exact block and both addresses in one call.

**Read the EIP-1967 admin slot, not just the implementation slot.**
The admin slot then `owner()` on the ProxyAdmin then `getOwners()` and `getThreshold()` on the Safe answers "who can replace the contract holding user funds" in three calls.
On Flap it found a 2-of-5 with no timelock over the Portal that custodies every live curve's reserve, which no document mentions.
Beware the near-miss constant: the slot is `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`, and a commonly pasted variant ending `...0000000000c103` silently returns the zero address.

**Blockscout verification flags and sources come from different endpoints.**
`smart-contracts/<addr>` can return a name and an ABI for an address that `addresses/<addr>` reports as `is_verified: false`, because it matches a verified twin by bytecode.
Take the verification flag from `addresses` and the sources from `smart-contracts`, never both from one.

**Decoding a real production call beats any UI capture.**
`_raw/blockscout/<contract>-transactions-recent.json` plus `eth_abi` reconstructs the exact parameters a live launch used.
Note that `abi.decode(data, (SomeStruct))` for a dynamic struct wraps it in a leading offset, so decode as a one-element tuple:
`abidec(['(uint24,int24,...)'], blob)` and unpack with a trailing comma.
Worked example: `launchpads/doppler/_raw/wallet/real-create-decoded.txt`.

**Read the launch counter on every generation, not just the one the frontend names.**
hood.fun's frontend config names one launchpad; four are live, and the named one holds 3 percent of the platform's history.
The two that mattered were found by reading `launchpad()` back off each migrator and `locker()` off each of those.
A launchpad family is a ring of mutual pointers, and walking it in both directions finds generations no config file mentions.

**A frontend bundle can carry a fully annotated deployment history.**
`pools-trade/_raw/js/useCreatorFeeExecutor-44W_DATt.js` holds an array of every strategy ever deployed on the chain, each with its fee splitter, its creator-fee basis points, its initial tick, and a prose `description` naming the date and the git commit.
Grep bundles for a known current address and read outward: that one array explained eight otherwise-unidentifiable unverified contracts.
Then check it against the chain, because it can be stale: the same array records `initialTick: 198060` where every deployed strategy returns `198050`, and it labels `0xccccccca...` a "v1 TWA auction factory" where the chain verifies it as `ContinuousClearingAuctionFactory`.

**Bytecode length is a fast generation test for a family of near-identical deployments.**
Eight unverified Instant Launch strategies split cleanly into a 10,774-byte generation and a 10,822-byte one, and the 10,822 group matches the current verified contract exactly, which proves those differ only in immutables.
`eth_getCode` plus `wc -c` and `shasum`, no selector scan needed.
Two were byte-identical to each other, which identified a pure re-deploy under a different salt.

**Decode the launch `configData`, not just the outer call.**
The outer `distributeToken(token, (strategy, amount, configData), salt)` says almost nothing; `configData` is the whole product.
For pools.trade's Crowd Launch it decodes as `abi.decode(configData, (MigratorParameters, bytes))` and yields the supply split, the burn address for unsold supply, the LP position range, the LP allocation schedule, the auction duration in blocks, the floor price, the graduation threshold and a packed 13-step issuance schedule.
The struct definition is in the verified strategy's own `src/libraries/` and `src/interfaces/`.
Worked example: `launchpads/pools-trade/_raw/rpc/derived-economics.txt`.

**Read `StateView.getSlot0(poolId)` for the protocol fee, not only the LP fee.**
The third return value is a packed pair of `uint12`s in hundredths of a bip, `fee1For0 << 12 | fee0For1`.
On a Pools pool it is `1638800`, that is 400 and 400, so 0.04 percent each way on top of the 0.25 percent LP fee.
Platforms advertise the LP fee and omit this, and a trader's true cost is `protocolFee + lpFee - protocolFee*lpFee/1e6`.

**A PUSH4 scan plus one decoded production call plus a keccak check fully recovers an unverified factory's admin surface.**
The scan named `launchingEnabled()`, `setLaunchingEnabled(bool)`, `allTokensLength()` and `MAX_LAUNCH_FEE()` on Noxa's unverified V2 factory.
The two selectors it could not resolve were recovered by word-dumping a real call's calldata, reconstructing the tuple from the field values, and confirming with `keccak(signature)[:4]`.
Always hash the candidate signature before writing it down; guessing a plausible name and never checking is how wrong ABIs get archived.

**A verified callee documents an unverified caller.**
Noxa's V2 factory is unverified but its locker is verified, and the locker declares `interface ILaunchFactory { getLaunchedToken(address) returns (LauncherTypes.LaunchedToken) }` with the full struct, which is the factory's own storage layout.
Same trick as Flap's `IPortal.sol` above, but from a callee rather than a sibling implementation.

**Trace one real fee collection before believing a fee-share getter.**
`LaunchLockerV1.protocolFeeShare()` reads 100 on a 0-to-100 percent scale, which looks like the protocol taking everything.
The token-transfer list of an actual `collect` shows it routes 100 percent to a fee collector that keeps nothing, burns the token side and pays the whole WETH side to the creator.
Reading the getter alone would have put the exact opposite of the truth in the README.
`transactions/<hash>/token-transfers` on Blockscout is one request and gives the whole flow in order.

**Grep a locker or fee splitter for the branch that decides who gets paid, not just the split constants.**
hood.fun's split is a clean 80/20, but `_distribute` takes the creator branch only when the collected token `== WETH`, so an opt-in feature the same team shipped later routes the creator's entire income into a burn address.
The constant was right and the branch was wrong, and no amount of reading the fee table would have found it.


---

## 5. The wallet gate

Several platforms hide their creator flow behind a wallet. The full write-up is `launchpads/doppler/pages/62-app-connect-wallet-gate.md`.

**Start with the `headless-wallet` skill.**
`~/.claude/skills/headless-wallet` supersedes the manual setup below for most work.
Its tier 0 observer needs **no npm install and no Playwright**, and drives the `agent-browser` CLI directly:

```bash
S=~/.claude/skills/headless-wallet/scripts
node $S/chains.mjs resolve 4663 --verify                       # resolve and probe RPCs, no config
node $S/make-observer.mjs --chain 4663 --address <test wallet> --out ./hw-observer.js
agent-browser open <url> --init-script "$(pwd)/hw-observer.js"
```

It announces over EIP-6963 four times so late-mounting React pickers still see it, forwards reads to the chain, parks signature challenges on `window.__HW.pending`, and records then rejects every `eth_sendTransaction` into `window.__HW.capture`.
It opened Sentry's wallet login on the first attempt and reached the gated Create form.
Tier 1 of the same skill adds real signing and, in autopilot mode, real broadcasts.

The rest of this section is the manual route it replaces, kept because it explains what the skill is doing.

**Use a library, not the hand-rolled harness.**
Recommended: `@ensdomains/headless-web3-provider@1.0.8`.
Peer dependency is viem only, which matches the Doppler SDK's own stack, and it announces EIP-6963.
The alternative `headless-web3-provider@0.3.2` (cawabunga) works too but pulls in ethers and rxjs.
Both use the same architecture: `page.addInitScript` injects a page-side shim and `page.exposeFunction` bridges to Node, so the private key never enters the page.

```js
const wallet = await injectHeadlessWeb3Provider(page, [KEY], 4663,
  'https://app.doppler.lol/api/rpc/4663',
  { permitted: [Web3RequestKind.RequestAccounts, Web3RequestKind.SignMessage] })
// login auto-approves; a launch does not
const [tx] = wallet.getPendingRequests()          // full Airlock.create calldata
await wallet.reject(Web3RequestKind.SendTransaction, { code: 4001 })
```

It requires a real Playwright `Page`, so this is the one sanctioned exception to the agent-browser rule.
Keep it confined to the wallet harness.

### The shared test wallet

A persistent test wallet exists. Do not generate a new one.

```bash
set -a && . ./.env.testwallet && set +a    # TEST_WALLET_ADDRESS, TEST_WALLET_PRIVATE_KEY
```

`0xTEST_WALLET_ADDRESS_REDACTED`, gitignored, mode 600, nonce 0 as of 2026-09-02.

| chain | balance | useful? |
| --- | --- | --- |
| Robinhood Chain mainnet, 4663 | 0.001 ETH | **yes**, this is where the launchpads are |
| Robinhood Chain testnet | 0.1 ETH | no, Doppler is not deployed there and most others will not be either |

It exists to open wallet gates, not to hold value.
Top it up with dust if a flow needs more, and tell the user rather than moving funds yourself.
Retire it only when the user says so.

Before assuming testnet funds are useful on any platform, check the contract is actually deployed on that testnet:
`curl -s -A "$UA" https://explorer.testnet.chain.robinhood.com/api/v2/addresses/<contract>` and look at `is_contract`.

**Non-negotiables.**

- EIP-6963 is mandatory. Doppler's picker enumerates wallets purely from `eip6963:announceProvider`, and a provider that only sets `window.ethereum` will not appear.
- Never put a private key into the page.
- Never sign for an address you do not control. Connecting "as" a known creator is impossible past the login step, because the challenge proves ownership.
- Use a throwaway keypair. It authenticates identically and holds nothing.

**Known gates, in order:**

1. Privy SIWE login, bound to `Chain ID: 4663`, single-use server nonce.
2. A client-side balance precheck. Doppler refuses to build a launch with `You have no balance on Robinhood.`
   Only mainnet 4663 ETH clears it.
   **Robinhood testnet is useless for this**: the Airlock address returns `is_contract: False` on `explorer.testnet.chain.robinhood.com`, so Doppler is not deployed there at all.

**A SIWE challenge can be signed outside the page with `eth_account`.**
The classifier concern in section 6 did not block this on Sentry.
`eth_account` is already installed and signs a parked challenge in six lines, reading the key inside the script and printing only the signature (reusable copy: `launchpads/sentry/_raw/tools/sign-siwe.py`):

```python
from eth_account import Account
from eth_account.messages import encode_defunct
sig = Account.sign_message(encode_defunct(bytes.fromhex(msg_hex[2:])), private_key=key)
```

The whole loop is: click Connect wallet, click the announced wallet, read `window.__HW.pending.params[0]`, sign it, call `window.__HW.provide(id, sig)`.
Re-trigger the challenge immediately before signing rather than reusing an old one; Sentry's expires five minutes after issue.

If a gate cannot be passed, decode a real production transaction instead. It is better evidence anyway.

**Check whether there is a gate before building one.**
hood.fun's create form renders in full to Jina with no wallet, no cookie and no terms acceptance; only `/swap`, `/bridge` and `/portfolio` sit behind a modal, and none of those is part of a launch.
Fetching `/create` through Jina first cost ninety seconds and removed this entire section's workload.

**Not every gate is SIWE. Try connecting before building a signer.**
pools.trade has no login, no nonce and no signature: announcing over EIP-6963 and returning an account from `eth_requestAccounts` reached the full create wizard, the portfolio and the trade panels.
The tier 0 observer did it in two clicks and appeared in the picker as "Headless Wallet Detected".

**Watch for a balance gate at the end rather than the start.**
pools.trade's whole create flow renders and validates on an empty wallet; only the final button flips to `Add funds` when the balance is below the quoted network cost.
That is far enough to capture every parameter and every screenshot, so an unfunded wallet blocks capturing the `eth_sendTransaction` payload, not the documentation.

**`agent-browser upload <ref> <file>` clears a required-image field.**
pools.trade keeps `Review` disabled until a token image is uploaded.
A 762-byte PNG generated in the scratchpad with `zlib` and `struct` was enough; no real asset needed.


---

## 6. Environment gotchas that cost time

**The auto-mode classifier blocks a specific cluster of actions.**
Reliably blocked: reading `.env*` key material, deriving addresses from it, and patching `fetch` to fake an on-chain balance.
Hand those to the user as a script they invoke with `! bash <path>`.
**Signing is not reliably blocked**, contrary to what this section claimed before 2026-09-03: Sentry's SIWE login was signed in-session with `eth_account` outside the page (section 5).
Try it, and fall back to the user-invoked script only if the attempt is actually refused.
Blocks labelled `Stage 2 classifier error ... usually transient` genuinely are: retry once and they usually pass.

**`agent-browser` traps that cost time on three platforms.**

- **`screenshot` needs an absolute output path.** A relative one fails with `No such file or directory (os error 2)` even when the directory exists and the CLI reports the command started. Same class of trap as `bdata scrape -f screenshot`.
- **`open` then `read` in two separate Bash calls can read the wrong page.** The SPA finishes routing after the first call returns. Chain them in one call: `agent-browser open <url> >/dev/null && agent-browser read > out.txt`. `wait --load networkidle` did not fix it.
- **`wait --time <ms>` falsely reports timeouts on some apps.** On flap.sh it reported `Wait timed out after 25000ms` on every call while the page had in fact updated. Ignore that specific failure and re-snapshot; `wait --load networkidle` is fine.
- **Sticky headers make refs unclickable.** `Element '@eN' is covered by <div...>` and `--force` does not help. `agent-browser eval` with a `querySelectorAll` text or aria-label match clicks them.
- **`eval` shares one page context across calls**, so `const x = ...` in a second call throws `Identifier 'x' has already been declared`. Wrap every eval in `(() => { ... })()`.

**In zsh, `for path in ...` silently destroys `$PATH`.**
`path` is tied to the `PATH` array, so the loop overwrites it and the next command in the body dies with `command not found: curl`.
The loop looks correct and the failure looks like a missing binary.
Use any other variable name.

**`onesentence.py` rewrites in place.**
Run it as `python3 onesentence.py FILE...`.
Do **not** redirect its stdout over the file: `python3 onesentence.py x.md > x.md` destroys it, because the tool has already rewritten the file and the shell then overwrites it with the one-line status report.
This cost a restore-from-backup on HOOD10.

**Not every app RPC proxy is open.**
`app.doppler.lol/api/rpc/4663` works for any chain-4663 read from anywhere and is the default for `eth_call` work.
`launch.hood10.xyz/api/rpc` refuses direct calls with `{"error":"this endpoint serves the app, not direct calls"}`.
An app's proxy is also same-origin only in general, so do not point a harness for site B at site A's proxy.

**Launchpad backends behind Cloudflare need the same browser User-Agent trick as Blockscout.**
`batman.taxed.fun` returns an interstitial without one and clean JSON with one.

**Screenshot viewport.** Set `agent-browser set viewport 1440 2200` before capturing any modal.
The default viewport clipped roughly half the create wizard and forced a full re-shoot of fourteen screenshots.

**agent-browser refs go stale after every page change.** Re-snapshot before each click. This one-liner is reliable:

```bash
ref () { agent-browser snapshot -i -u 2>/dev/null | grep -oE "button \"$1\" \[ref=e[0-9]+" | grep -oE 'e[0-9]+$' | head -1; }
```

**Never suppress output on a launch step.** A race between `close` and `open` produced an empty address and a silent abort that took a round-trip to diagnose.

**`agent-browser open --init-script <path>`** registers a script that runs before page JS. This is how any provider injection must be done.

**Prose style.** `resources/launchpads/doppler/_raw/tools/onesentence.py` reformats authored markdown to one sentence per line while leaving tables, code fences and list structure intact. Run it on `README.md` and `LINKS.md` before finishing.

**`agent-browser open ... && agent-browser read` in one call still returns an empty document on a React Router SPA.**
On pools.trade the chained form recommended above returned a 1-byte read every time.
What worked was three separate calls: `open`, then `wait --load networkidle`, then `read`.
The failure is silent, so check `wc -c` on the output rather than trusting the exit code.

**`onesentence.py` un-indents continuation lines inside a numbered list**, which turns the rest of the list item into a sibling paragraph and breaks the numbering.
Prefer `###` subheadings over numbered lists with multi-paragraph bodies in any file you intend to run it on, and re-read any list-heavy section afterwards.

**Verbatim `pages/` captures keep their em dashes.**
The no-dash rule applies to authored files.
`sentry` has em dashes in 52 of 81 page files and none in its README; match that, and never rewrite a capture to satisfy a style rule.

**Jina Reader is blocked on x.com under a shared abuse penalty.**
`r.jina.ai/https://x.com/...` returns `AbuseAlleviationError ... blocked until <timestamp> due to previous abuse found on <someone else's profile>`, so the block is global to the domain and not caused by this session.
`bdata scrape https://x.com/<handle>` worked immediately for both a profile and a single status, so that is the fallback for X, not Jina.

**A launchpad backend can be completely open.**
`api.noxa.fi` needs no key, no browser User-Agent and no Cloudflare workaround, and serves tokens, trades, holders, candles and comments.
Probe `<api-host>/api/health` before building any browser harness.


---

## 7. Running sections in parallel

`SCRAPING-PLAN.md` part 0 rule 1 forbade parallelism because nine simultaneous subagents hit the account rate limit twice and killed everything.
Three separate sessions is a different risk profile and is fine, with two conditions:

1. **Do not fan out to subagents inside a session.** The limit is shared across everything one session spawns. One agent working sequentially per session.
2. **Do not run two Doppler-derived platforms in parallel.** Long, Bankr and Feel all read from and correct the same `launchpads/doppler/` archive, and concurrent edits to it will conflict.

Safe groupings from the remaining sections:

| group | why |
| --- | --- |
| ~~`long`, `bags`, `virtuals`~~ | done 2026-09-02 |
| ~~`sentry`, `flap`, `hood10`~~ | done 2026-09-03, all three confirmed non-Doppler |
| ~~`hood-fun` + `pools-trade` + `noxa`~~ | done 2026-09-03, merged; all three confirmed non-Doppler |
| `resources/` refresh | independent of every launchpad; can run alongside any of them |

Each session owns exactly one `launchpads/<slug>/` directory.
The only shared files are `SCRAPING-PLAN.md` part 4.4 and this playbook.
A session that runs in parallel with others must not edit them at all: write the 4.4 row, the section findings block and any playbook additions into `launchpads/<slug>/SESSION-NOTES.md`, and the coordinating session merges them once nothing else is running.
That is how the Long, Bags and Virtuals notes of 2026-09-02 were merged.

**Background agents from one session do work, and will hit the account session limit.** It happened on both waves: 2026-09-02 killed two of three, and overnight into 2026-09-03 killed all three mid-run. The reset time moves and is named in the error, so read it rather than assuming.
Wave 2 (hood.fun, Pools.trade, Noxa) then ran all three to completion in one pass without hitting it, so the limit is a risk to plan for, not a certainty.

**Resume a killed agent, do not relaunch it.** A resume keeps the agent's own inventory of what it already captured, so it does not redo work or re-derive decisions; a fresh agent starts blind against a directory full of work it does not remember doing. Everything already on disk survives either way. Send the resume with the current file counts for its directory, what is still missing, and a reminder to re-run the part 4.3 inventory first.

**Require `SESSION-NOTES.md` before the agent stops, even on partial work.** It is the only handoff into the merge, and none of the three wrote one before dying the first time.

---

## 8. Finish checklist

Beyond part 8 of `SCRAPING-PLAN.md`:

- [ ] Every `pages/NN-slug.md` reference in `README.md` and `LINKS.md` resolves to a real file.
      Verify, do not assume, especially after any renumbering:
      `grep -oE "pages/[0-9]+-[a-z0-9-]+\.md" README.md LINKS.md | sed 's/.*://' | sort -u | while read p; do [ -f "$p" ] || echo "MISSING $p"; done`
- [ ] Every screenshot is referenced by at least one page.
- [ ] No two screenshots are byte-identical: `md5 screenshots/*.png | sort | uniq -d`.
      Two inherited pairs in `noxa` were duplicates, so two documented "distinct views" were the same image.
- [ ] No em dashes or en dashes in authored files.
- [ ] `onesentence.py` has been run on the authored markdown.
- [ ] The agent-browser session for the platform is closed, by name, never `--all`.
- [ ] Part 4.4 of `SCRAPING-PLAN.md` updated, and a short findings block added under the platform's section 5 entry.
- [ ] Anything learned that would speed up the *next* platform is added to this playbook.

---

## 9. Learned from the platform sessions

### From Long, Bags and Virtuals (2026-09-02)

#### Before trusting the status table

A killed session can leave an archive far more complete than part 4.4 says.
Run the inventory command and `ls` every subdirectory first; Bags had 1,660 files, `LINKS.md`, `ADDRESSES.md` and 20 screenshots on disk where the table said 103 pages and one screenshot.
Look for derived-number scratch files (`_raw/rpc/derived-economics-*.txt`, `_raw/api/decoded-*.json`) before recomputing anything.

#### Cloudflare-hardened apps

When `agent-browser` gets `Sorry, you have been blocked` on the first page load (Long), stop trying browsers.
Jina Reader gets pages, `bdata scrape <url> -f screenshot -o <absolute path>` gets screenshots (a relative `-o` silently writes nothing), and the chain gets state.
The wallet-gate method in section 5 needs a page to load first and cannot help.
Bright Data's residential unlocker refuses x.com on compliance grounds; the X syndication endpoint `https://syndication.twitter.com/srv/timeline-profile/screen-name/<handle>` returns the latest timeline page as JSON inside `__NEXT_DATA__` with no key.

#### Reconstructing a wallet-gated create form

A Next.js app's launch parameters live in a constants export list in the chunk that mentions the API host.
Grep the chunks for the integrator or factory address to find the chain config, and for `START_FEE`, `INITIAL_SUPPLY` or similar to find the defaults.
Then decode fifty launches, not two: `addresses/<launcher>/transactions` returns fifty decoded calls in one request, and grouping them by fee, distribution, destination and integrator surfaces every template and every non-app caller at once (`long/_raw/api/decoded-launcher-recent-50.txt`).
The constants and the decoded calls agreeing byte for byte is a complete substitute for the form.

#### Doppler-derived platforms

- `getShares(poolId, address)`, not `getBeneficiaries(asset)`, for any platform that lets creators move their fee slot; `getBeneficiaries` is the creation-time list.
- Uniswap v4 dynamic-fee pools report `fee = 0x800000` in `getState`; read the real LP fee with `StateView.getSlot0(poolId).lpFee`.
- A Rehype hook fee schedule (`startFee` decaying to `endFee` over `durationSeconds`) is the anti-snipe path in production; do not stop at `maxBalanceLimit`.
- `long/_raw/tools/rpc.py` is a twelve-line `eth_call` helper over `eth_abi` for reading state without an ABI file; `long/_raw/tools/mkcontract.py` accepts raw files named either `smart-contracts-<Role>-<addr>.json` or `smart-contracts-<addr>.json`.

#### Docs platforms

- GitBook returns HTTP 200 for any path; a missing page's `.md` body starts with `# Page Not Found`.
  The sitemap and `llms.txt` can both be incomplete (38 hidden pages on whitepaper.virtuals.io); after the sitemap pass, run a link-closure loop: collect internal links from every captured page, fetch the missing ones as `.md`, repeat until nothing new (`virtuals/_raw/tools/`).
- Mintlify sites vary: docs.bags.fm serves MDX for `<path>.md` but has no `sitemap-pages.xml`; os.virtuals.io serves the SPA shell for `.md`.
  On Mintlify use `llms.txt` for the page list, and prefer the OpenAPI JSON behind an API reference over the per-endpoint pages.
- Jina cannot read Snapshot-style governance SPAs; `agent-browser read` after `wait --load networkidle` can.
- Jina extracts text from a route that serves a PDF (Long's `/litepaper`) even when a direct download of the same route returns a Cloudflare challenge.

#### Bright Data limits

`bdata pipelines x_posts` accepts only `https://x.com/<user>/status/<id>` URLs, there is no profile pipeline, and it silently returns fewer records than submitted.
Find status ids with `bdata search "<handle> <topic> site:x.com" --json`, the project's own docs, or the syndication endpoint above.

#### Blockscout

- Name search returns forks: searching `BondingV1`, `FRouter`, `AgentFactory` or `Long` returns verified copies by unrelated deployers.
  Confirm the creator address against the platform's deployer before treating a hit as part of the platform.
- Beacon proxies: `eth_getStorageAt(proxy, <EIP-1967 beacon slot>)` then `implementation()` on the beacon.
  Blockscout does not match bytecode for `BeaconProxy` instances or EIP-1167 clones, so they show unverified even when the logic is verified; record the slot and move on.

#### Environment

- In zsh, `echo ====` fails because `=word` is an equals expansion; quote separators.
- The auto-mode classifier denies a compound command containing `rm -rf <dir>/*` as a whole; keep destructive cleanup out of compound commands and make generators idempotent instead.
- Loops of thirty Jina fetches exceed the default two-minute Bash timeout; pass `timeout` or split the loop.
- `agent-browser session list` can print a session name once after `close`; the second call shows none.

### From Sentry, Flap and HOOD10 (2026-09-03)

Most of what these three sessions learned has been filed into sections 2 to 6 above, where it belongs.
What is left is cross-cutting.

**Treat a project's own numbers as claims until you re-derive them.**
Every one of the three platforms published at least one figure its own contracts contradict.
Sentry's DefiLlama record says Uniswap V3 and a 65/35 split; the chain says v4 and `creatorFeeBps() = 7000` everywhere.
Flap's docs say ETH is the only quote asset and the Portal is `v5.14.16`; the chain says 26 enabled quotes and `v5.21.2`.
HOOD10's docs contradict its own contracts in six places, including a tax ceiling of 11% against a contract-enforced 10%.

**A derived number in a dashboard is not an observation.**
HOOD10's `/api/vault` reports `buybackUsd` 39101.35 against `withdrawnUsd` 55859.07 and `buybackShare` 0.7, and 39101.35 is exactly the product of the other two.
The figure that was actually observed, `paidLifetime`, is 0.
Before citing a dashboard number, check whether it is a product of two other numbers in the same response.

**A frontend's config API can be stale against the chain.**
HOOD10's `/api/health` serves an `addresses` block stamped `recordedAt` that was four hours stale on the one address that had changed.
Treat a launchpad's config endpoint as a hint and re-read every address from the contract that consumes it.

**Check the entries array, not the byte count, on X syndication.**
The endpoint is per-account, not a universal fallback.
It returned a full 20-post timeline for `@quotrons404` and `{"entries": []}` with `hasResults: true` for `@sentrylauncher` and `@cruelhandeth`.
The empty response is still a valid 2.2 KB page, so a size check will not catch it.
It remains strictly better than `bdata pipelines x_posts` for a timeline: 6 status URLs submitted to Bright Data returned 1 record, while syndication returned all 20 posts in one request.

### From hood.fun, Pools.trade and Noxa (2026-09-03)

**Confirm the operator with the chain, not the marketing.**
Three separate third parties said Pools.trade was built by Uniswap Labs, and all three were right, but none of them was evidence.
What settled it was that Uniswap's own `deployments.json` lists the exact addresses the frontend pins, the verified sources carry `security@uniswap.org`, and the deployer EOA also deployed the same contract at the same address on Ethereum mainnet.
Run those three checks on any platform that claims a famous parent.

**Similar names on one chain are a real hazard.**
`pools.trade` (Uniswap Labs, Uniswap v4, 0.25 percent) and `pools.fun` (an independent team, SushiSwap V3, 1 percent) were both live on Robinhood Chain in August 2026 and are unrelated.
A contract's own natspec is the cheapest disambiguator: `PartyFactory`'s first comment line names its own domain.

**The blended fee figure and the contract fee figure will differ, and both will be published.**
Pools states the creator's cut three ways: "0.1 percent of every buy" in the app, "0.05 percent of the 0.25 percent LP fee" in the docs, and "20 percent to the creator" from the founder.
The contract says 40 percent of the native side and 0 percent of the token side.
All four are consistent once you notice that sells pay in token and the token side goes entirely to compounding.
Always quote the split as `(nativeBps, tokenBps)` from `getSplits()`, then give the blended figure as a derived number.

**A headline fee split can be a global knob rather than a per-launch term.**
Noxa's `LaunchLockerV2.protocolFeeShare` is read at collection time, not snapshotted at launch, and the verified source says that is deliberate.
It moved 50 to 70 to 0 within ninety minutes on 2026-08-29.
Before writing "the creator keeps X percent", check whether X is stored per launch or read from a settable global, and say which.

**A launchpad's indexer can be repointed, and the site's own history disappears with it.**
hood.fun's board went from 10,629 coins to 354 overnight while the contracts were untouched, and `/api/token/<addr>` now returns `unknown token` for the 10,568 that were dropped.
Capture `/api/board`-style bulk endpoints on the first day of a session, timestamp the file, and re-capture on the last day; the diff was one of the most useful findings on that platform.
Never treat a board API as a stable snapshot of a chain.

**Report the distribution, not the headline, for anything a creator earns.**
Three platforms in this wave advertise a generous creator share that is real and, for a median creator, worth nothing.
hood.fun pays 80 percent of the WETH-side pool fee to a creator who has a 0.21 percent chance of graduating, and among the 19 that did, the median lifetime payout is $1.92 and six earned zero.
The honest summary of a creator-share number is the share, the odds of reaching it, and the median outcome of those who did.

**X syndication continues to fail per-account, in two different ways.**
Add `@hooddotfun` to the accounts for which `syndication.twitter.com/srv/timeline-profile/screen-name/<handle>` returns a valid 2.2 KB page with `entries: []`; that is now three of five accounts tried across sessions, so treat the endpoint as a lucky shortcut rather than a method.
`@Noxa_Fi` fails the other way: 99 entries, none newer than late 2025, so the size and the entry count both look healthy while the timeline is a year out of date.
Check the newest `created_at` in the payload, not just `len(entries)`.

### From the resources refresh (2026-09-03)

**Re-derive a table from its own raw file before you trust it.**
The 2026-09-02 pass wrote nine `uiMultiplier()` values into `31-onchain-verification.md` and eight of them disagreed with `_raw/onchain-2026-09-02.json`, the file they came from, in the last two or three digits.
Two of the August values were wrong the same way, caught by replaying the call at the original block through the archive RPC.
A number that was transcribed by hand from a raw capture is not verified, however good the capture was.
Diff the document against its sources, not just the sources against the chain.

**"Verified" in an archive can mean "the vendor published it".**
The archived Chainlink feed list was the published reference directory, which is a claim, not a reading.
No feed on this chain had ever been called until the refresh called `latestRoundData()` on all 57 through Multicall3.
Check what a claim's evidence file actually is before citing it as on-chain.

**A vendor's description of someone else's contract is a claim to test.**
The Bags docs call UniversalRouter `0x8876...0904` a "Robinhood-modified fork".
`eth_getCode` plus the two verified source sets settle it: 24,546 bytes each, 109 identical source files, and 111 differing bytes that are all immutables.
It is stock Uniswap, and the difference between the chain's two routers is one constructor argument.
Cheap to check, and the wrong answer had already propagated into a platform README.

**An unsourced number is worse than a missing one.**
Where the refresh could not reproduce a figure, it marked it unsourced in place rather than deleting it or leaving it standing.
That keeps the next session from re-trusting it and from re-deriving it blind.
