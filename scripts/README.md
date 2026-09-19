# scripts

Tooling for building and refreshing the launchpad archives.

`restore-upstream-repos.sh` predates these and is unrelated; it restores the cloned upstream repos listed in `upstream-repos.tsv`.

## The archive pipeline

Three scripts, composing left to right.

```bash
# 1. pull the two Blockscout responses for each contract, through a real browser
printf 'UnihoodFactory|0x0485a4392b7300841e644bB1B36562AE7B2A0c82\n' \
  | python3 scripts/bsfetch.py --slug unihood --build
```

`--build` chains straight into `mkarchive.py`, so that one command produces
`launchpads/unihood/contracts/UnihoodFactory-0x0485.../` with `metadata.json`,
`abi.json`, `sources/` and a generated `README.md`.

Input is `Role|0xaddress|optional note` lines on stdin.
Blank lines and `#` comments are skipped.

### `bsfetch.py`

Populates `launchpads/<slug>/_raw/blockscout/`.

Cloudflare began challenging `robinhoodchain.blockscout.com/api/v2` some time after 2026-09-03, so the browser User-Agent recipe in `PLAYBOOK.md` section 4 now returns a "Just a moment..." interstitial, and a Blockscout API key does not clear it either.

A real browser clears it once, and a `fetch` issued from inside the page then carries the clearance cookie.
This script drives one `agent-browser` session on that principle.
Responses of at least 216 KB round-trip intact.

It is idempotent: an address whose two files already exist is skipped unless `--force`.

### `mkarchive.py`

Builds `contracts/<Role>-<addr>/` from the cached responses.

Generalises `launchpads/doppler/_raw/tools/mkcontract.py`, which hardcoded a path into the old `long-launch` working copy and needed both responses fetched by hand first.
It can fetch directly too, but that path now hits Cloudflare, so in practice `bsfetch.py` feeds it.

Per `PLAYBOOK.md` section 4 it takes the verification flag from the `addresses` endpoint and the sources from `smart-contracts`, never both from one, because `smart-contracts` returns a name and an ABI for an address that `addresses` reports as unverified when it matched a verified twin by bytecode.

### `push4scan.py`

For unverified contracts.

```bash
python3 scripts/push4scan.py --addr 0xde540a7d140e27e50305fae78e736fe00f4a917f --slug raisehood
```

Scans the runtime bytecode for PUSH4 constants, resolves them in batches of 50 against `api.openchain.xyz` with no API key, and writes a report plus the raw bytecode to `launchpads/<slug>/_raw/rpc/`.

Resolution runs about 50 to 55% on this chain, which is enough to identify a contract family.
The scan over-collects by design: a PUSH4 can be any four-byte constant, so an unresolved candidate is not necessarily a function.

**A resolved name is evidence of a family, not of behaviour.** `setPlatformFee` exists on RaiseHood, but whether it is read at collection time or snapshotted per sale cannot be answered from the name.

## Finding addresses in the first place

Before any of the above, and before Blockscout, read DefiLlama's open-source adapters.
They are plain source naming the factory, the hook, the deploy block and often the launch event signature.

```bash
curl -s https://raw.githubusercontent.com/DefiLlama/DefiLlama-Adapters/main/projects/<slug>/index.js
curl -s https://raw.githubusercontent.com/DefiLlama/dimension-adapters/master/fees/<slug>/index.ts
```

This supplied the entry points for six of the eleven wave-two platforms outright, including all five o1 Launchpad generations.

Caveat: a TVL adapter names TVL-bearing contracts and nothing else, so it hands you lockers and custody and misses launch factories, which hold no TVL.

## Dependencies

`agent-browser` on `PATH`, Python 3, and network access to Blockscout and `api.openchain.xyz`.
No API keys.
