Probes re-run on 2026-09-03 for resources/robinhood-chain/32-explorer-and-data-apis.md.
Read-only. No transaction was broadcast and no private key was used.

The one write-shaped call made was a deliberate bad-source POST to
/api/v2/smart-contracts/0x1Cdad396DB64BDa184d5182A97Dd9B3C62100b7D/verification/via/flattened-code,
to establish whether the route accepts submissions. It returned
{"message":"Smart-contract verification started"}, failed the bytecode match as expected,
and the contract still reads is_verified: true / name "BeaconProxy" afterwards.

Files:
  README.txt                    this file
  bs_noUA.html                  the Cloudflare interstitial served without a browser User-Agent
  bs_config_backend-version.json  the same route with -A "$UA"
  bs_headers-2026-09-03.txt     full response headers, incl. the x-ratelimit-* family
  bs-endpoints.txt              25-endpoint v2 sweep, status code + remaining quota per row
  bs-verification-tests.txt     verification routes, and the v2 routes that 404 on this instance
  bs-apikey-tests.txt           BLOCKSCOUT_API_KEY on the instance (no effect) and on the PRO API
  dex-tests.txt                 Dexscreener probe log
  dex_pairs_v3.json             WETH/USDG v3 pair, by pair address
  dex_pairs_v4poolid.json       NVDA/WETH v4 pool, by 64-hex pool id
  dex_tokens_v1.json            tokens/v1/robinhood/<addr>
  dex_token-pairs_v1.json       token-pairs/v1/robinhood/<addr>, 30 pools for NVDA
  dex_latest_tokens.json        latest/dex/tokens/<addr>
  dex_search.json               latest/dex/search?q=NVDA robinhood
  dex_orders.json               orders/v1/robinhood/<addr>
  goldsky-robinhood-chain.md    docs.goldsky.com/chains/robinhood-chain.md, re-fetched
  goldsky-supported-networks.md docs.goldsky.com/chains/supported-networks.md, re-fetched
  goldsky-datasets.txt          Mirror dataset existence probes + the live subgraph on this account
  alchemy-probe.py              the Alchemy probe script
  alchemy-tests.txt             its output
  uniswap-probe.py              the Uniswap Developer API probe script
  uni-tests.txt                 its status-code log
  uni-quote.json  uni-swap.json  uni-approval.json
  uni-supported_chains.json     the 25-chain list incl. 4663 with its full contract set
  uni-swappable_tokens.json
  uni-api.json                  the OpenAPI spec, 28 routes
