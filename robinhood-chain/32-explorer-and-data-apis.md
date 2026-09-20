# Explorer and Data APIs

**This page is original writing, not a captured document.**
Every other numbered file in this directory is a verbatim capture of a first-party page.
This one is a practitioner's reference for what actually answers a question about Robinhood Chain, written from probes run against the live services.

**Verified:** 2026-09-03, against mainnet chain id 4663 at block ~53,123,000.
Blockscout backend at the time: `v11.2.8.+commit.e889cab0`.
Nitro client at the time: `nitro/v3.11.3-beb2108/linux-amd64/go1.25.12`.

**Evidence.** Every claim below is either a curl you can paste, or a file in `_raw/apis-2026-09-03/`.
Where a probe from `_raw/apis-2026-09-02/` no longer reproduces, both dates are named.

**Neighbouring pages.**
`05-blockscout-explorer.md` is the explorer's own front page as captured.
`25-alchemy-robinhood-quickstart.md` is Alchemy's own quickstart.
`31-onchain-verification.md` is the on-chain snapshot that this page's RPC advice complements.
This page is the only one of the four that says which of those endpoints actually answer.

Set this once; most of the Blockscout examples need it.

```bash
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0 Safari/537.36"
```

---

## 1. Blockscout, the public instance

Base URL: `https://robinhoodchain.blockscout.com`.
API v2 lives under `/api/v2`, the Etherscan-shaped v1 API under `/api`.
No key is needed for either.

### The User-Agent requirement is real and it is the first thing that will waste your time

Without a browser `User-Agent` the instance is behind Cloudflare and returns an HTML interstitial, not JSON.

```bash
curl -s -o /dev/null -w '%{http_code} %{content_type}\n' \
  https://robinhoodchain.blockscout.com/api/v2/config/backend-version
# 403 text/html; charset=UTF-8   -> body is <title>Just a moment...</title>
```

The whole fix is `-A "$UA"`.

> **Correction 2026-09-11:** this no longer holds.
> On 2026-09-11 both this instance and rh-scan.com returned the Cloudflare challenge to curl even with the browser `UA` set.
> The Bright Data Web Unlocker (`brightdata scrape`) got through, as did the Blockscout MCP server.
> Evidence: `fly-brain/research/03-rh-scan-address.md`, Gaps section.

```bash
curl -s -A "$UA" https://robinhoodchain.blockscout.com/api/v2/config/backend-version
# {"backend_version":"v11.2.8.+commit.e889cab0"}
```

Captured proof: `_raw/apis-2026-09-03/bs_noUA.html` is the 5,549-byte challenge page, `bs_config_backend-version.json` is the 46-byte answer.
Any HTTP client whose default agent looks automated hits the same wall, which includes Python's `urllib` and most SDKs that do not let you set headers.

### v2 endpoints confirmed working on 2026-09-03

Every row below returned HTTP 200 today with the `UA` set.
Full sweep with status codes: `_raw/apis-2026-09-03/bs-endpoints.txt`.
`B="https://robinhoodchain.blockscout.com/api/v2"` in each example.

| Endpoint | What it is worth using for |
| --- | --- |
| `GET $B/addresses/<addr>` | `is_verified`, `is_contract`, `creator_address_hash`, `creation_transaction_hash`, `proxy_type`, `implementations`. This is the authoritative verification flag. |
| `GET $B/addresses/<addr>/transactions` | up to 50 decoded calls per page, the cheapest way to read what real callers actually pass |
| `GET $B/addresses/<addr>/logs` | event log history for one address, with decoded topics where the ABI is known |
| `GET $B/addresses/<addr>/internal-transactions` | value moves a receipt does not show |
| `GET $B/addresses/<addr>/token-transfers` | ERC-20 and ERC-721 flow for one address |
| `GET $B/addresses/<addr>/tokens?type=ERC-20` | token balances held by an address |
| `GET $B/addresses/<addr>/counters` and `/tabs-counters` | transaction, transfer and validation counts without paging |
| `GET $B/addresses/<addr>/nft` | NFTs held, for locker and position-manager work |
| `GET $B/addresses/<addr>/blocks-validated` | empty on this chain, it is an L2 |
| `GET $B/smart-contracts/<addr>` | `source_code`, `additional_sources`, `abi`, `compiler_version`, `decoded_constructor_args`, `external_libraries`. Sources come from here, the verification flag does not. |
| `GET $B/smart-contracts?q=<text>&filter=solidity` | search verified sources by contract name |
| `GET $B/tokens/<addr>`, `/holders`, `/counters`, `/instances`, `/transfers` | token metadata, holder list, supply counters |
| `GET $B/tokens?q=<text>` and `?type=ERC-20` | token search and enumeration |
| `GET $B/transactions`, `$B/transactions/<hash>` and its `/logs`, `/internal-transactions`, `/token-transfers` | one transaction in full, in order |
| `GET $B/blocks`, `$B/blocks/<n>`, `$B/blocks/<n>/transactions` | block bodies. `blocks/<n>` also carries an `arbitrum` object with the batch number and commitment transaction. |
| `GET $B/search?q=<text>` | mixed address, token, block and transaction search |
| `GET $B/stats`, `$B/stats/charts/transactions`, `$B/stats/charts/market` | chain-level counters and daily series |
| `GET $B/main-page/transactions`, `$B/main-page/blocks` | the explorer front page feed |
| `GET $B/addresses` | richest addresses, paginated |
| `GET $B/config/backend-version` | which Blockscout build you are talking to |
| `GET $B/proxy/account-abstraction/status` | ERC-4337 indexer state, v0.6 through v0.8 flags |
| `GET $B/smart-contracts/verification/config` | see section 3 |

Copy-pasteable shape:

```bash
B="https://robinhoodchain.blockscout.com/api/v2"
A=0x1Cdad396DB64BDa184d5182A97Dd9B3C62100b7D
curl -s -A "$UA" "$B/addresses/$A"        | python3 -m json.tool | head -40
curl -s -A "$UA" "$B/smart-contracts/$A"  | python3 -m json.tool | head -40
```

### Endpoints that do not exist on this instance

`SCRAPING-PLAN.md` section 3.6 lists `smart-contracts/<addr>/methods-read` as working.
It is not, on backend `v11.2.8`, on 2026-09-03.

```
404 "Page not found"   GET  /api/v2/smart-contracts/<addr>/methods-read
404 "Page not found"   GET  /api/v2/smart-contracts/<addr>/methods-read?is_custom_abi=false
404 "Page not found"   GET  /api/v2/smart-contracts/<addr>/methods-write
404 "Page not found"   GET  /api/v2/smart-contracts/<addr>/methods-read-proxy
404 "Page not found"   POST /api/v2/smart-contracts/<addr>/query-read-method
404 "Page not found"   GET  /api/v2/smart-contracts/<addr>/solidityscan-report
400 "Unknown API v2 action"  GET /api/v2/addresses/<addr>/methods-read
401 "Unauthorized"           GET /api/v2/transactions/watchlist   (account feature, needs a login)
```

It 404s for a verified proxy and for Multicall3 alike, so this is a missing route and not a per-contract condition.
To read contract state, use `eth_call` against an RPC, or pull the ABI from `$B/smart-contracts/<addr>` and call the chain yourself.
Raw record: `_raw/apis-2026-09-03/bs-verification-tests.txt`.

### Rate limits

There are three separate buckets, and the numbers moved between 2026-09-02 and 2026-09-03.

| Route | `x-ratelimit-limit` on 2026-09-03 | `x-ratelimit-limit` on 2026-09-02 |
| --- | --- | --- |
| most of `/api/v2/*` | 180, window reset 11 to 47 seconds | 10 |
| `/api/v2/stats` | 10, window reset under 1 second | 10 |
| `/api` (v1, Etherscan-shaped) | 10, and the 429 cooldown is about 47 minutes | 10 |

On 2026-09-02 the previous agent saw the whole v2 API capped at 10 and recorded 429s on `smart-contracts/<addr>` and `tokens?type=ERC-20` (`_raw/apis-2026-09-02/bs-endpoints.txt`, `bs-headers.txt`).
On 2026-09-03 a 25-endpoint sweep plus 60 rapid repeats produced no 429 at all on v2.
Treat 180 as today's value and not as a guarantee.

The v1 `/api` bucket is the dangerous one.
Ten calls exhausted it, and the reset header then read `2830595`, which is milliseconds, so roughly 47 minutes locked out from that one IP.

```bash
curl -s -A "$UA" -D - -o /dev/null "$B/config/backend-version" | grep -i x-ratelimit
# x-ratelimit-limit: 180
# x-ratelimit-remaining: 179
# x-ratelimit-reset: 11425      <- milliseconds left in the window
```

Response headers also advertise `bypass-429-option: temporary_token` and expose `api-v2-temp-token`, which is how the browser UI raises its own limit.
That path was not exercised here.

### `BLOCKSCOUT_API_KEY` does nothing to the public instance

The key in `.env` is a `proapi_` key, which belongs to the multichain PRO API and not to this instance.
Passing it to `robinhoodchain.blockscout.com` as `?apikey=`, or as `Authorization: Bearer`, leaves `x-ratelimit-limit` at exactly 180 and changes no behaviour.
Evidence: `_raw/apis-2026-09-03/bs-apikey-tests.txt`.

---

## 2. Blockscout PRO API, which does cover chain 4663

> **Corrected 2026-09-19.** The PRO key is out of credits and has been for at least a full UTC day, so the section below describes a route that no longer answers.
> `api.blockscout.com/4663/api?module=logs&action=getLogs` returns **HTTP 402 `{"error":"Out of credits"}`** with a valid key. A bogus key returns 401, so the 402 is quota exhaustion and not a bad key.
> The free tier is 100,000 credits a day at 20 credits per call, and it was being spent in full by 05:14 UTC with no identified consumer. There is no top-up product; the cheapest plan is $49/month.
>
> **The public instance is unaffected and still serves the v1 `getLogs` for free.**
> `robinhoodchain.blockscout.com/api?module=logs&action=getLogs` returns 200 for the same query, given a browser `User-Agent` and a `Referer` header of any value.
> Measured against the v4 PoolManager `0x8366a39cc670b4001a1121b8f6a443a643e40951`: blocks 67,300,000 to 67,300,010 gave 265 logs; a 1,000-block span gave exactly 1,000 and a 10,000-block span also gave exactly 1,000.
> `page=2&offset=1000` returned byte-identical results to `page=1`. **The 1,000-entry cap is a hard ceiling with no pagination behind it**, so the only way past it is to shrink the block range per window.
> Eight successful v1 calls were made in a few minutes during this check, which is consistent with the ten-per-47-minutes v1 bucket recorded above rather than evidence that the bucket has changed.
>
> For bulk logs on this chain use dRPC, which pulled 724,750 blocks in 3.53 minutes for free. See `44-uniswap-v4-hooks.md` and the v4-hooks repo's `docs/assurance/bulk-log-access-4663.md`.


This is the most useful thing found on 2026-09-03 and it is not in the plan.
The multichain PRO API serves Robinhood Chain under its chain id, and it fixes both of the instance's problems at once.

```bash
P="https://api.blockscout.com/4663/api/v2"
curl -s -H "Authorization: Bearer $BLOCKSCOUT_API_KEY" "$P/config/backend-version"
# {"backend_version":"v11.2.8.+commit.e889cab0"}
```

What it gives you:

- **No Cloudflare interstitial and no User-Agent requirement.** The call above used curl's default agent and returned JSON.
- **The same v2 route set.** `/addresses/<addr>`, `/smart-contracts/<addr>`, `/tokens/<addr>/holders`, `/search`, `/stats` and `smart-contracts?q=&filter=solidity` all returned 200 with identical bodies.
- **The v1 route too**, at `https://api.blockscout.com/4663/api?module=...`, which matters because the instance's own v1 bucket is ten calls per 47 minutes.
- **Credit accounting instead of a hard cap.** Responses carry `x-credits-remaining` (99,960 of 100,000 during these probes) alongside `x-ratelimit-limit: 5` with a sub-second window.

Without a key it returns `402 {"error":"Proceed with API key or make a X402 payment to continue"}`.
The bare host with no chain id returns `404 {"error":"Network not supported"}`, so the `/4663/` path segment is load-bearing.

Chain metadata is separately public and needs no key at all:

```bash
curl -s https://chains.blockscout.com/api/chains/4663
# {"name":"Robinhood Chain","description":"Robinhood Chain is a permissionless Layer 2 ...
```

---

## 3. Contract verification endpoints

### Which compilers this instance accepts

```bash
curl -s -A "$UA" "$B/smart-contracts/verification/config"
```

Returns `is_rust_verifier_microservice_enabled: true`, 1,657 solc versions, 52 vyper versions, 15 Solidity EVM versions, 14 license types, and seven `verification_options`.
Archived response: `_raw/apis-2026-09-02/bs_smart-contracts_verification_config.json`.

### The v2 verification routes, and which of them accept a submission

```
POST /api/v2/smart-contracts/<addr>/verification/via/flattened-code
POST /api/v2/smart-contracts/<addr>/verification/via/standard-input
POST /api/v2/smart-contracts/<addr>/verification/via/multi-part
POST /api/v2/smart-contracts/<addr>/verification/via/sourcify
POST /api/v2/smart-contracts/<addr>/verification/via/vyper-code
```

All five exist.
A sixth, invented path returns `404 "Page not found"`, which is how you tell a missing route from a rejected body.

Against a real contract the route accepts the job:

```bash
curl -s -X POST "$B/smart-contracts/<contract>/verification/via/flattened-code" -A "$UA" \
  -F "compiler_version=v0.8.20+commit.a1b79de6" \
  -F "contract_name=MyContract" \
  -F "license_type=none" \
  -F "source_code=$(cat flattened.sol)"
# {"message":"Smart-contract verification started"}
```

Failure modes worth knowing before you debug the wrong thing:

- Against an address with no code, `via/flattened-code` returns `404 {"message":"Address is not a smart-contract"}` most of the time and an HTML `500` page intermittently (one time in three across today's attempts). The 500 is not a different error, it is the same error surfacing badly.
- `via/standard-input`, `via/multi-part` and `via/sourcify` return `400 "Bad request"` when the multipart body is missing that route's own required fields, which is what a `flattened-code`-shaped body looks like to them. That 400 is a body problem, not a missing route.
- The 2026-09-02 run recorded `429` on the v2 verification POST (`_raw/apis-2026-09-02/bs_v2_verify_post.json`) and `404 "Address is not a smart-contract"` on the retry. Both reproduce today.
- A submission with source that does not match the deployed bytecode is accepted, queued, and then silently fails the match. `{"message":"Smart-contract verification started"}` is not success. Re-read `GET $B/addresses/<addr>` afterwards and check `is_verified`.

### Update 2026-09-10: the mainnet instance now walls every non-browser client

Re-tested while verifying the STREAK dry-run deployment.
Everything in this section above still describes the routes; what changed is who may reach them.

- `robinhoodchain.blockscout.com` returns the Cloudflare "Just a moment" page to curl even with the `$UA` string above, on `/api/` and `/api/v2/` alike. The User-Agent fix from 2026-09-03 no longer works. `forge verify-contract --verifier blockscout` fails the same way.
- The PRO API's documented Etherscan-shaped verification route, `https://api.blockscout.com/v2/api?chain_id=4663&module=contract&action=verifysourcecode&apikey=...` (`../blockscout/devs/verification/blockscout-smart-contract-verification-api.md`), returns `500 {"error":"Internal server error","source":"upstream"}` on every POST, including a one-line single-file contract. GETs on that route and `checkverifystatus` answer normally. The chain-in-path form `api.blockscout.com/4663/api/v2/smart-contracts/.../verification/via/*` gives 404 on the config and 500 on the POST.
- Sourcify lists chain 4663 as supported but a `forge verify-contract --verifier sourcify` job ends in `cannot_fetch_bytecode`.
- What works: the instance's own web form, driven in a headed Chromium, which passes the managed challenge with no CAPTCHA. The verification POST from the form is rate-limited (429) and throws intermittent HTML 500s, and a 500 can still be followed by a verified contract, so poll `is_verified` on `GET /api/v2/addresses/<addr>` through the PRO API before retrying. Script: `~/.claude/skills/blockscout-verify/`. All seven dry-run contracts were verified this way.
- The testnet instance still accepts forge's verifier, queued.

### The v1 Etherscan-shaped verification routes

These are live and validate field by field, which makes them easy to drive interactively.

```bash
H="https://robinhoodchain.blockscout.com"
curl -s -A "$UA" "$H/api?module=contract&action=verifysourcecode"
# {"message":"Missing codeformat field","result":null,"status":"0"}

curl -s -A "$UA" -X POST "$H/api?module=contract&action=verifysourcecode" \
  -d "codeformat=solidity-single-file" -d "contractaddress=<addr>" \
  -d "contractname=MyContract" -d "compilerversion=v0.8.20+commit.a1b79de6" \
  -d "optimizationUsed=0" -d "sourceCode=<flattened source>"

curl -s -A "$UA" "$H/api?module=contract&action=checkverifystatus&guid=<guid>"
# {"message":"OK","result":"Unknown UID","status":"1"}   for an unknown guid
```

Remember the 10-per-47-minutes bucket on `/api`.
Drive verification through `https://api.blockscout.com/4663/api?...` with the PRO key if you are going to iterate.

### Reading sources back

```bash
curl -s -A "$UA" "$H/api?module=contract&action=getsourcecode&address=<addr>"   # sources + AdditionalSources
curl -s -A "$UA" "$H/api?module=contract&action=getabi&address=<addr>"          # ABI as a JSON string
```

`getsourcecode` returns the flattened primary source plus an `AdditionalSources` array of every imported file, which is the same material as `GET $B/smart-contracts/<addr>` in Etherscan's shape.
Archived response: `_raw/apis-2026-09-02/bs_v1_getsourcecode.json`.

### Foundry

Blockscout's own guidance is `--verifier blockscout` plus `--verifier-url <explorer>/api/`, with the trailing `/api/` mandatory and the API key optional.
For this chain that is:

```bash
forge verify-contract \
  --rpc-url https://rpc.mainnet.chain.robinhood.com \
  --verifier blockscout \
  --verifier-url https://robinhoodchain.blockscout.com/api/ \
  --compiler-version v0.8.20+commit.a1b79de6 \
  <address> src/MyContract.sol:MyContract
```

Or at deploy time, on `forge create` or `forge script`, with `--verify --verifier blockscout --verifier-url https://robinhoodchain.blockscout.com/api/`.
Source: `_raw/apis-2026-09-02/blockscout-foundry-verification.md`.

Two cautions this page adds to that document.
Forge drives the `/api` v1 route, which is the 10-per-window bucket, so a multi-contract `forge script --verify` can exhaust it partway and report verification failures that are really 429s.
And Forge does not send a browser User-Agent, so if you see a Cloudflare interstitial in the verifier output the request never reached Blockscout at all.

---

## 4. Dexscreener

Chain id is the literal string `robinhood`.
No key, no User-Agent trick, no auth.
Every shape below returned 200 on 2026-09-03: `_raw/apis-2026-09-03/dex-tests.txt`.

```bash
D=https://api.dexscreener.com
NVDA=0xd0601CE157Db5bdC3162BbaC2a2C8aF5320D9EEC
PAIR=0x52e65B17fB6E5BA00Ed806f37Afcd2DaA50271Ca

curl -s "$D/latest/dex/pairs/robinhood/$PAIR"        # one pair by pair address or v4 pool id
curl -s "$D/token-pairs/v1/robinhood/$NVDA"          # every pool for one token
curl -s "$D/tokens/v1/robinhood/$NVDA"               # one or more tokens by address
curl -s "$D/latest/dex/search?q=NVDA%20robinhood"    # free-text search across chains
curl -s "$D/latest/dex/tokens/$NVDA"                 # chainless token lookup, same payload shape
curl -s "$D/orders/v1/robinhood/$NVDA"               # paid listing orders, [] for most tokens
```

A pair object carries `priceUsd`, `priceNative`, `txns` and `volume` bucketed at m5/h1/h6/h24, `priceChange`, `liquidity` in USD and both sides, `fdv`, `marketCap` and `pairCreatedAt` in milliseconds.
Worked example from today, WETH/USDG on Uniswap v3: `priceUsd` 2413.28, 24h volume 630.8M USD, liquidity 12.6M USD (`_raw/apis-2026-09-03/dex_pairs_v3.json`).

Rate limits are published per endpoint and are generous: 300 requests per minute for `latest/dex/pairs`, `latest/dex/search`, `token-pairs/v1` and `tokens/v1`; 60 per minute for the profile, boost, order and meta endpoints.

### The 64-hex id is a Uniswap v4 pool id, not an address

This is the one thing that trips people up on this chain, because a large share of the liquidity is v4.
A `pairAddress` of 66 characters is a v4 `PoolId`, which is a hash of the pool key and has no code at that address.
The pairs endpoint resolves it anyway:

```bash
curl -s "$D/latest/dex/pairs/robinhood/0x647836c4965c512f0d82a2128abe7826eacf5a79d2dbed252a89ba5c591d1e87"
```

returns `dexId: uniswap`, `labels: ["v4"]`, `baseToken` NVDA `0xd0601CE1...`, `quoteToken` WETH `0x0Bd7D308...`, `priceUsd` 225.71, `liquidity.usd` 17,890.
So Dexscreener is the cheapest way to turn a v4 pool id into its token pair.
Saved response: `_raw/apis-2026-09-03/dex_pairs_v4poolid.json`.

Of the 30 pools Dexscreener knows for NVDA, 13 are v4 with 66-character ids and 17 are conventional pair addresses across Uniswap v2 and v3, up, ramses, alandale, giga, sheriff, pancakeswap and robinswap.
Do not assume a Dexscreener id can be fed to `eth_getCode`.

---

## 5. Goldsky

**Chain 4663 is supported, and it is supported for real, not just in a table.**

### What the docs say

`https://docs.goldsky.com/chains/robinhood-chain.md` has a dedicated Robinhood Chain page listing mainnet `4663` and testnet `46630`, with Subgraphs, Mirror, Turbo, Edge RPC and Compose all marked supported on both networks and `partnerSponsored={false}`.
`https://docs.goldsky.com/chains/supported-networks.md` gives the slugs `robinhood-mainnet` and `robinhood-testnet` for subgraphs, `robinhood_mainnet` and `robinhood_testnet` for Turbo and Compose, and marks Blocks, Enriched Transactions, Logs, Traces and Fast Scan all ✓ for mainnet.
Compose lists 4663 with gas sponsorship ✓.
Both pages re-fetched on 2026-09-03 and are byte-identical to the 2026-09-02 capture except for two unrelated link titles.

### What the account actually shows

Docs tables are claims.
These were run with the CLI against the project behind `GOLDSKY_API_KEY` (`_raw/apis-2026-09-03/goldsky-datasets.txt`).

```bash
goldsky login --token "$GOLDSKY_API_KEY"
goldsky subgraph list
```

returns a healthy, 100 percent synced subgraph on this chain family:

```
octopus/1.0.0
  GraphQL API: https://api.goldsky.com/api/public/project_cmsaqlax74bi401vn1h6bc1uh/subgraphs/octopus/1.0.0/gn
  Status: healthy (Active)   Synced: 100%   Chain: robinhood-testnet
  Blocks indexed: 97,379,692 -> 112,090,050
```

and that endpoint answers:

```bash
curl -s -X POST "https://api.goldsky.com/api/public/project_cmsaqlax74bi401vn1h6bc1uh/subgraphs/octopus/1.0.0/gn" \
  -H 'content-type: application/json' \
  -d '{"query":"{ _meta { block { number timestamp } hasIndexingErrors } }"}'
# {"data":{"_meta":{"block":{"number":112090143,"timestamp":1788408613},"hasIndexingErrors":false}}}
```

So subgraph indexing on Robinhood Chain is proven end to end, at least on testnet.

### Mirror datasets that exist for mainnet

Probed one by one with `goldsky dataset get <name>`:

| Dataset | Present |
| --- | --- |
| `robinhood_mainnet.raw_blocks` | yes, "Raw Blocks", version 1.1.0 |
| `robinhood_mainnet.raw_logs` | yes, "Raw Logs", version 1.1.0 |
| `robinhood_mainnet.raw_traces` | yes, "Raw Traces", version 1.1.0 |
| `robinhood_testnet.raw_logs` | yes, "Raw Logs", version 1.1.0 |
| `robinhood_mainnet.raw_transactions` | **not found** |
| `robinhood_mainnet.enriched_transactions` | **not found** |
| `robinhood_mainnet.decoded_logs` | **not found** |
| `robinhood_mainnet.blocks` / `.logs` / `.transactions` / `.traces` / `.enriched_blocks` / `.edge_raw_logs` | not found |

The supported-networks table marks Enriched Transactions ✓ for Robinhood Chain, and `robinhood_mainnet.enriched_transactions` does not resolve today.
Plan a Mirror pipeline around `raw_blocks`, `raw_logs` and `raw_traces`, and confirm anything else with Goldsky before you design against it.

`goldsky dataset list` cannot be run from a non-interactive shell: it dies with `TTY initialization failed: uv_tty_init returned EINVAL (invalid argument)`.
Probe individual names with `goldsky dataset get` instead, or run the list command from a real terminal.

### What indexing this chain costs you in effort

**Install and authenticate.**
`curl https://goldsky.com | sh` installs the CLI, then `goldsky login --token <API key from Project Settings>` authenticates it.
There is no per-request API key for the hosted GraphQL endpoints; the CLI holds the session.

**Deploy a subgraph.**
Point `subgraph.yaml` at `network: robinhood-mainnet` and run `goldsky subgraph deploy <name>/<version>`.
The deployed endpoint is `https://api.goldsky.com/api/public/<project_id>/subgraphs/<name>/<version>/gn` and is public with no key.

**Or run a Mirror pipeline.**
Source from `robinhood_mainnet.raw_logs` and friends and sink into a database you own.
`goldsky pipeline list` on a fresh project returns "No pipelines found".

**Watch the slug shapes.**
Turbo and Compose use the underscore slugs `robinhood_mainnet` and `robinhood_testnet`, not the hyphenated subgraph slugs `robinhood-mainnet` and `robinhood-testnet`.
Mixing the two is a silent misconfiguration.

---

## 6. Alchemy

Robinhood Chain mainnet is a first-class Alchemy network, `robinhood-mainnet`, internally `ROBINHOOD_MAINNET`.
RPC base is `https://robinhood-mainnet.g.alchemy.com/v2/<key>`, which is what `ALCHEMY_MAINNET_URL` holds.
All results below are from `_raw/apis-2026-09-03/alchemy-tests.txt`, produced by `_raw/apis-2026-09-03/alchemy-probe.py`.

Standard JSON-RPC is complete.
`eth_chainId` returns `0x1237`, `web3_clientVersion` returns `nitro/v3.11.3-beb2108/linux-amd64/go1.25.12`, and `eth_feeHistory`, `eth_getCode`, `eth_call` and `eth_getBlockByNumber` all behave normally.

### Enhanced and Data API methods that work on 4663

| Method | Result |
| --- | --- |
| `alchemy_getTokenMetadata` | works. NVDA returns `{"decimals":18,"logo":null,"name":"NVIDIA • Robinhood Token","symbol":"NVDA"}` |
| `alchemy_getTokenBalances` | works, full ERC-20 balance sweep for an address in one call |
| `alchemy_getAssetTransfers` | works, including `fromBlock: 0x0` with `category: ["erc20"]`, which is the way to get full history despite the `eth_getLogs` cap below |
| `alchemy_getTransactionReceipts` | works, every receipt in a block in one call |
| `alchemy_getTokenAllowance` | works |
| Prices API, `POST https://api.g.alchemy.com/prices/v1/<key>/tokens/by-address` | works with `"network":"robinhood-mainnet"`. NVDA quoted at 225.91 USD at 04:03 UTC on 2026-09-03. |
| Prices API by symbol | works |
| Portfolio API, `POST https://api.g.alchemy.com/data/v1/<key>/assets/tokens/by-address` | works with `"networks":["robinhood-mainnet"]` |
| Portfolio API, `.../assets/nfts/by-address` | works |
| NFT API v3, `https://robinhood-mainnet.g.alchemy.com/nft/v3/<key>/getNFTsForOwner` and `getContractMetadata` | works |

### What does not work, and why

| Method | Error |
| --- | --- |
| `trace_block` | `trace_block is not available on the ROBINHOOD_MAINNET` |
| `arbtrace_block` | `arbtrace_block is not available on the ROBINHOOD_MAINNET` |
| `debug_traceBlockByNumber` | `not available on the Free tier - upgrade to Pay As You Go, or Enterprise` |
| `debug_traceTransaction` | same free-tier message |
| Transaction History API, `POST .../data/v1/<key>/transactions/history/by-address` | plain text `Unsupported network: ROBINHOOD_MAINNET` |

The two `trace_*` families are refused as a **network** capability, not a tier one, so paying does not turn them on.
The two `debug_*` methods are refused as a **tier** capability, so a paid plan should turn them on, though that was not tested from here.
The distinction matters: if you need call traces on this chain, plan on `debug_traceTransaction` with a paid key, or on Goldsky's `robinhood_mainnet.raw_traces`, not on `trace_block`.

### The free-tier `eth_getLogs` cap is exactly 10 blocks

Not "about 10". Measured today:

```
fromBlock..toBlock spanning 10 blocks  -> 200, results returned
fromBlock..toBlock spanning 11 blocks  -> -32600 "Under the Free tier plan, you can make eth_getLogs
                                          requests with up to a 10 block range."
```

The error helpfully names a range that would work.
For any real log scan use `alchemy_getAssetTransfers`, which is not capped this way, or Blockscout's `module=logs&action=getLogs`, or a paid tier.

---

## 7. Uniswap Developer API

Base URL `https://trade-api.gateway.uniswap.org/v1`.
Auth is a single `x-api-key` header holding `UNISWAP_DEVELOPER_API_KEY`.
A wrong key returns `401 {"errorCode":"Unauthorized","detail":"Unauthenticated api key or session"}`.

**It is behind Cloudflare and rejects non-browser user agents.**
Python's `urllib` default agent gets `403` with the body `error code: 1010` on every route, including the OpenAPI spec.
curl's default agent passes.
Set a browser `User-Agent` in any SDK or script and the problem disappears; this cost a full probe run to diagnose on 2026-09-03.

### Chain 4663 is fully listed

```bash
curl -s -H "x-api-key: $UNISWAP_DEVELOPER_API_KEY" \
  https://trade-api.gateway.uniswap.org/v1/supported_chains
```

Of 25 chains, `chainId 4663` is present as `"Robinhood"` with `protocols: ["V2","V3","V4","UniswapX"]` and `actions: ["SWAP","LP"]`, and it carries the full deployed contract set: UniswapV2Factory, UniswapV2Router02, UniswapV3Factory, Multicall, V3 Quoter, NonfungiblePositionManager, TickLens, v4 PoolManager, v4 PositionManager, StateView, V4 Quoter, Permit2, V3DutchOrderReactor, OrderQuoter, and `UniversalRouter` version `2.1.1` at `0x8876789976dEcBfCbBbe364623C63652db8C0904`.
Saved: `_raw/apis-2026-09-03/uni-supported_chains.json`.
That last line is the vendor's own answer to which Universal Router is current on this chain.

### Universal Router version header

The default for 4663 is `2.1.1`, so you do not need the header.
Setting it explicitly is confirmed today:

```
(no header)                          -> 200
x-universal-router-version: 2.1.1    -> 200
x-universal-router-version: 2.0      -> 404 {"errorCode":"ResourceNotFound","detail":"No quotes available"}
```

There is no 2.0 deployment on this chain, and the API reports that as "no quotes available" rather than as a version error, which is easy to misread as a liquidity problem.

### A worked quote, approval and swap

```bash
UNI=https://trade-api.gateway.uniswap.org/v1
curl -s -A "$UA" -H "x-api-key: $UNISWAP_DEVELOPER_API_KEY" -H 'content-type: application/json' \
  -X POST "$UNI/quote" -d '{
    "type":"EXACT_INPUT",
    "tokenInChainId":4663,"tokenOutChainId":4663,
    "tokenIn":"0x0000000000000000000000000000000000000000",
    "tokenOut":"0xd0601CE157Db5bdC3162BbaC2a2C8aF5320D9EEC",
    "amount":"1000000000000000",
    "swapper":"0x000000000000000000000000000000000000dEaD"}'
```

On 2026-09-03 at block 53,123,126 that returned `routing: "CLASSIC"`, 0.001 ETH in for `10631530475198875` NVDA wei out, `priceImpact` 0.05, `gasFeeUSD` 0.239, routed `[v3] 100.00% = [0.05%] 0x62AB521f71431f78ac374CdbadC6cda3c8916b6C`.
Full body: `_raw/apis-2026-09-03/uni-quote.json`.
On 2026-09-02 the same request routed three hops, WETH to SFI to USDG to NVDA (`_raw/apis-2026-09-02/uni-quote.json`), so the route is not stable and should never be hard-coded.

Feeding the `quote` object straight back to `/swap` returns an unsigned transaction:

```bash
curl -s -A "$UA" -H "x-api-key: $UNISWAP_DEVELOPER_API_KEY" -H 'content-type: application/json' \
  -X POST "$UNI/swap" -d '{"quote": <the quote object>, "simulateTransaction": false}'
```

`swap.to` is `0x8876789976dEcBfCbBbe364623C63652db8C0904`, `chainId` 4663, `value` `0x038d7ea4c68000`, `gasLimit` 211,759, calldata starting `0x3593564c` (`execute`).
Saved: `_raw/apis-2026-09-03/uni-swap.json`.

`/check_approval` answers whether Permit2 needs an allowance and hands back the exact approve calldata:

```bash
curl -s -A "$UA" -H "x-api-key: $UNISWAP_DEVELOPER_API_KEY" -H 'content-type: application/json' \
  -X POST "$UNI/check_approval" \
  -d '{"walletAddress":"0x000000000000000000000000000000000000dEaD",
       "token":"0xd0601CE157Db5bdC3162BbaC2a2C8aF5320D9EEC",
       "amount":"1000000000000000000","chainId":4663}'
# approval.to = the token, data = approve(0x000000000022D473030F116dDEE9F6B43aC78BA3, max)
```

For an ERC-20 input the quote itself returns `isTokenApprovalApplicable: true` and a `permitData` EIP-712 payload bound to `chainId 4663` and `verifyingContract 0x000000000022D473030F116dDEE9F6B43aC78BA3`; for native ETH input both are null.

### The route list

`GET /v1/api.json` is the OpenAPI spec and needs the same key and user agent.
It declares 28 routes: `/check_approval`, `/check_approval_4337`, `/limit_order_quote`, `/lp/check_approval`, `/lp/claim_fees`, `/lp/create`, `/lp/create_classic`, `/lp/decrease`, `/lp/increase`, `/margin/markets`, `/order`, `/orders`, `/permissions`, `/plan`, `/plan/{planId}`, `/quote`, `/supported_chains`, `/swap`, `/swap_4337`, `/swap_5792`, `/swap_7702`, `/swappable_tokens`, `/swaps`, `/tokens`, `/wallet/check_delegation`, `/wallet/encode_4337`, `/wallet/encode_7702`.

Routes that people guess at and that do not exist: `/lp/approve`, `/lp/pool_info` and `/indicative_quote` all return `404 {"message":"Route POST:/<name> not found"}`.
`GET /swaps?txHashes=<hash>&chainId=4663` works and returns `status: "NOT_FOUND"` for an unknown hash rather than erroring.

---

## 8. dRPC, the public RPC, and what a wide log scan actually costs

Measured 2026-09-19 against chain 4663 at block ~67,303,004, scanning Uniswap v4 `Initialize` off the PoolManager and v3 `PoolCreated` across three factories, constrained on both indexed currencies.

### Every endpoint refuses a wide `eth_getLogs`, but not for the same reason

The distinction decides whether splitting the range helps at all.

| Endpoint | Refusal | Limit is on |
| --- | --- | --- |
| `robinhood-mainnet.g.alchemy.com` (free) | `Under the Free tier plan, you can make eth_getLogs requests with up to a 10 block range` | block range |
| `lb.drpc.live` (free) | `ranges over 10000 blocks are not supported on free plan` | block range |
| `app.doppler.lol/api/rpc/4663` | `Log response size exceeded. You can make eth_getLogs requests with up to a 5,000 block range` | block range |
| `rpc.mainnet.chain.robinhood.com` | `logs matched by query exceeds limit of 10000` | **log count** |

**Only the public endpoint can serve a wide scan.** A block-range cap cannot be satisfied by halving - splitting 67M blocks six times still leaves ranges a thousand times wider than Alchemy's 10. A log-count cap is exactly what halving is for. So route log scans to `rpc.mainnet.chain.robinhood.com` and keep the keyed endpoints for `eth_call`, where they are genuinely better.

This is the same conclusion section 9 reaches for wide historical logs, arrived at from the other direction.

### Throttling arrives as a JSON-RPC error from a laptop, and as HTTP 429 from Cloudflare

The public endpoint throttles under sustained scanning, and from a workstation it reports that as a JSON-RPC `error` object rather than a 429 status.
From Cloudflare Workers egress it is a plain HTTP 429, returned in about 105 ms, so handle both. Code that treats any JSON-RPC error as "too many logs" and splits the range makes it worse: both halves are throttled too, so requests double per level while the answer never changes, and the ranges that end up "failing" get recorded as unscanned.

Same scan, same endpoint, one hour apart:

| Strategy | Requests | Pools found | Unscanned ranges |
| --- | --- | --- | --- |
| Split on every error | 254 | 12,281 | 120 |
| Retry on a backoff, split only on `exceeds limit` | **27** | **12,597** | **0** |

### Cloudflare Workers egress is throttled far harder than a laptop

The same full-chain scan takes 14 s from a laptop and **never completes inside 180 s from a deployed Worker**, which matters because a Worker invocation has a wall-clock budget and a partial scan that aborts may write nothing. Treat a first full-chain backfill as an operator task run from a workstation, then have the Worker scan only incremental ranges.

Measured from a deployed Worker on 2026-09-20, with every HTTP attempt timed: **70 of 72 `eth_getLogs` requests to the public endpoint came back HTTP 429**, and both keyed endpoints answered their block-range cap as a bare HTTP 400 with the message in the body.
So even the incremental scan is a lottery from a Worker, not only the first backfill.

Two rules follow, and breaking either cost a production pass its entire budget for sixteen hours:

- **Split only on `exceeds limit`.** A 429 is not splittable and neither is a block-range plan cap, even though the latter reads like a size refusal. Splitting on either turns one refused query into a 127-leaf tree.
- **Bound retries by wall clock, not by attempt count.** Six attempts at an exponential backoff is 15.75 s of sleep per query against 0.6 s of network; 127 leaves of that is 33 minutes. Cap the backoff (the long waits bought no extra successes), give the scan a deadline, and never put anything irreplaceable behind a log scan on a shared timeout.

**`eth_call` does not share the problem at all.** An earlier version of this section said a large Multicall3 page "did not return from a deployed Worker", and that was wrong: the call was never made, because a throttled log scan in front of it had already spent the invocation's abort, and the error named an endpoint tried after the abort fired. Measured properly, a Multicall3 `aggregate3` of ~1,900 calls returns in **500-600 ms from a deployed Worker** through Alchemy, the same as from a laptop.
When a Worker times out "in an `eth_call`", time each stage before believing it.

---

## 9. Which tool to reach for

| Question | Reach for | Why not the others |
| --- | --- | --- |
| Contract source, ABI, constructor args | `GET /api/v2/smart-contracts/<addr>` on Blockscout, or the same route on `api.blockscout.com/4663` | Only Blockscout has verified sources for this chain. Take the `is_verified` flag from `/addresses/<addr>` and the sources from `/smart-contracts/<addr>`; they disagree for bytecode-matched twins. |
| Who deployed it, and in which transaction | `GET /api/v2/addresses/<addr>` | `creator_address_hash` and `creation_transaction_hash` in one call. No RPC equivalent. |
| Reading a contract's current state | `eth_call` through Alchemy plus the ABI from Blockscout, batched through Multicall3 `0xcA11bde05977b3631167028862bE2a173976CA11` | Blockscout's `methods-read` route does not exist on this instance. |
| Token holders, holder count | `GET /api/v2/tokens/<addr>/holders` and `/counters` | Alchemy has no holder-set endpoint; deriving it from transfers costs a full log scan. |
| Token balances for one wallet | `alchemy_getTokenBalances`, or Blockscout `/addresses/<addr>/tokens?type=ERC-20` | Both are one call. Alchemy also returns raw hex balances without pagination. |
| Price, liquidity, 24h volume | Dexscreener `token-pairs/v1/robinhood/<token>` | It aggregates every DEX on the chain, v4 pool ids included. Alchemy's Prices API gives a single USD number with no liquidity context. |
| Turning a 64-hex pool id into tokens | Dexscreener `latest/dex/pairs/robinhood/<poolId>` | It is a v4 `PoolId`, so there is no contract at that address to query. |
| Historical logs over a wide range | `eth_getLogs` against `rpc.mainnet.chain.robinhood.com`, halving the range on `exceeds limit` (section 8); or `alchemy_getAssetTransfers` for transfers, or Blockscout `module=logs&action=getLogs` with paging | The keyed endpoints cap by block range (10 and 10,000), which halving cannot satisfy; the public one caps by log count, which it can. Blockscout's v1 getLogs takes wide ranges but returns at most 1,000 entries per page and 500s on a full-chain span. |
| Call traces | `debug_traceTransaction` on a paid Alchemy tier, or Goldsky `robinhood_mainnet.raw_traces` | `trace_block` and `arbtrace_block` are unavailable on this network at any tier. |
| A quote, a swap payload, or the current Uniswap contract set | Uniswap Developer API `/quote`, `/swap`, `/supported_chains` | `/supported_chains` is the vendor's own live answer for which Universal Router is current, which beats any archived address list. |
| Continuously indexing this chain | Goldsky subgraphs on `robinhood-mainnet`, or a Mirror pipeline from `robinhood_mainnet.raw_logs` | Confirmed working; the account already runs a healthy synced subgraph on `robinhood-testnet`. |
| Scripted, high-volume explorer reads | `https://api.blockscout.com/4663/api/v2/...` with `BLOCKSCOUT_API_KEY` | No Cloudflare user-agent requirement, credit-metered instead of the instance's 10-per-47-minutes v1 bucket. |

---

## 10. Known gaps in this page

- The `bypass-429-option: temporary_token` path that Blockscout advertises was not exercised, so the ceiling with a temp token is unknown.
- `debug_traceTransaction` on a paid Alchemy tier was not tested, only the free-tier refusal message.
- Goldsky Mirror was verified by dataset existence, not by running a pipeline, and `goldsky dataset list` could not be enumerated from a non-interactive shell.
- Goldsky subgraph indexing is proven on `robinhood-testnet`; no mainnet subgraph was deployed from this account.
- Paid tiers on Alchemy and dRPC were not tested, only the free-tier refusals in section 8.
- The Blockscout PRO API was exercised on nine routes, not exhaustively, and its credit cost per route was not measured.
