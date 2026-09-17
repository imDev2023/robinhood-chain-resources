# Refresh capture, 2026-09-03

Raw inputs for the `SCRAPING-PLAN.md` 5.12 subtask 3 refresh of `resources/uniswap/`.

| File | Source | Method |
| --- | --- | --- |
| `llms.txt` | <https://developers.uniswap.org/llms.txt> | `curl`, verbatim |
| `deployments.json` | <https://developers.uniswap.org/deployments.json> | `curl`, verbatim |
| `code-0x8876789976dEcBfCbBbe364623C63652db8C0904.hex` | `eth_getCode` on chain 4663 via `$ALCHEMY_MAINNET_URL` | JSON-RPC, `result` field only |
| `code-0x06AfBA43Fd06227fA663b0DAecF536f6EaA6bf99.hex` | `eth_getCode` on chain 4663 via `$ALCHEMY_MAINNET_URL` | JSON-RPC, `result` field only |
| `bs_address_<addr>.json` | `https://robinhoodchain.blockscout.com/api/v2/addresses/<addr>` | `curl` with a browser User-Agent |
| `bs_counters_<addr>.json` | `https://robinhoodchain.blockscout.com/api/v2/addresses/<addr>/counters` | `curl` with a browser User-Agent |
| `bs_txs_to_<addr>.json` | `https://robinhoodchain.blockscout.com/api/v2/addresses/<addr>/transactions?filter=to` | `curl` with a browser User-Agent |
| `trading-api-quote-4663.json` | `POST https://trade-api.gateway.uniswap.org/v1/quote` | `x-api-key: $UNISWAP_DEVELOPER_API_KEY` |
| `trading-api-swap-4663-default.json` | `POST https://trade-api.gateway.uniswap.org/v1/swap`, no version header | `x-api-key: $UNISWAP_DEVELOPER_API_KEY` |
| `trading-api-swap-4663-urv2.1.1.json` | same, `x-universal-router-version: 2.1.1` | `x-api-key: $UNISWAP_DEVELOPER_API_KEY` |
| `trading-api-swap-4663-urv2.0.json` | same, `x-universal-router-version: 2.0` | `x-api-key: $UNISWAP_DEVELOPER_API_KEY`, returns HTTP 500 |
| `universal-router-evidence.txt` | derived from all of the above | hand-written, every block names its source |

## Drift result

`llms.txt` fetched 2026-09-03 is byte-identical to `_raw/llms.txt` (sha256 `667c4332ffa3456433343dece9a64111b79785e460ef4951be6ac69acabae4a6`).
`deployments.json` fetched 2026-09-03 is byte-identical to `_raw/deployments.json` (sha256 `6536407a4404e179b9b9f2da35b5dd9794d92f8862d05b74aafa6410e0f518f3`, still `generatedAt` 2026-07-15T22:25:40.000Z from `Uniswap/contracts@37936185de`).
No pages were added, removed or renamed, so nothing new was captured into the archive and `DEPLOYMENTS.md` needed no regeneration.
No `deployments-2026-08-22.json` snapshot was written, because a byte-identical copy under a second name would record a change that did not happen.

The addresses used above were picked to be the two candidates in the Universal Router question plus the two `spokePool` targets those two candidates name.
