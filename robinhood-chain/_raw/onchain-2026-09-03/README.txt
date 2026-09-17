On-chain re-verification pass, 2026-09-03.

Method: Alchemy archive RPC (ALCHEMY_MAINNET_URL, host robinhood-mainnet.g.alchemy.com)
plus Multicall3 aggregate3 at 0xcA11bde05977b3631167028862bE2a173976CA11.
Read-only only: eth_chainId, web3_clientVersion, eth_blockNumber, eth_gasPrice,
eth_getBlockByNumber, eth_getCode, eth_getStorageAt, eth_call.
No transaction was sent and no private key was used.

Every state read below is pinned to block 53117114 (0x32a80ba). The four
chain-parameter methods (eth_chainId, web3_clientVersion, eth_blockNumber,
eth_gasPrice) are latest-block by definition and were taken at that same height.

| file | contents |
| chain-info-2026-09-03.json                        | chain id, client version, block height, gas price, base fee, gas limit, block time over 100 blocks |
| eth_getCode-2026-09-03.txt                        | byte count and sha256 for all 22 addresses in the deployment table, with a same/CHANGED flag against 2026-09-02 |
| stock-token-bytecode-2026-09-03.json              | eth_getCode over all 194 Stock Tokens, size and sha256 histograms, ERC-1967 beacon and implementation slots on 3 sampled tokens |
| onchain-tokens-2026-09-03.json                    | 8 fields read from all 194 token contracts, plus the derived totalSupplyUI identity check and the diff against 2026-09-02 |
| onchain-feeds-2026-09-03.json                     | latestRoundData(), decimals() and description() for all 57 Chainlink feeds |
| chainlink-feeds-robinhood-mainnet-2026-09-03.json | Chainlink reference directory, refetched (byte-identical to the 2026-09-02 copy) |
| erc8056-interface-2026-09-03.json                 | ERC-8056 selector probe on one token plus owner()/implementation() on the beacon |
| beacon-implementation-2026-09-03.json             | raw eth_call result for implementation() on the beacon |
| rhj-assets-2026-09-03.json                        | REST asset registry response, for the roster count cross-check |
| eth_getCode-supplement-2026-09-03.txt             | eth_getCode on 10 further addresses named in ROBINHOOD-CHAIN.md section 9 that no earlier capture covered |
| lighter-contract-2026-09-03.json                  | Lighter Robinhood Chain instance: code, ERC-1967 slots, implementation and ProxyAdmin |
| august-block-34251364-multipliers-reread.json     | archive replay of uiMultiplier()/effectiveAt() at the 2026-08-12 capture block, which corrected two digits in the August table |
