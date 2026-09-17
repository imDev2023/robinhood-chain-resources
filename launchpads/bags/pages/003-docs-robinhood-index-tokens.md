# Bags - Launch an Index Token

> Source: https://docs.bags.fm/robinhood/index-tokens
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/robinhood/index-tokens.md)

---

# Launch an Index Token

> Launch a dividend coin on Robinhood Chain whose creator fees automatically buy a basket of tokenized assets and pay them out to holders, then register and monitor it through the Bags API.

In this guide, you'll set up an **index token** (also called a *dividend coin*): a Bags token on Robinhood Chain whose creator fees are automatically converted into a basket of 1–10 tokenized assets (stocks like TSLA, NVDA, AAPL, …) and distributed pro rata to the token's holders. Holders earn dividends in the underlying assets simply by holding the token.

## Prerequisites

Before starting, make sure you have:

* Completed the [Environment Setup](/robinhood/setup).
* A Bags API key from [dev.bags.fm](https://dev.bags.fm) belonging to the same Bags user that owns the token's creator wallet.
* Read the [Launch a Token](/robinhood/launch-token) guide — an index token is a normal Bags V2 launch with a specific fee-claimer configuration.

## 1. How Index Tokens Work

An index token runs on the standard Bags fee-share rails (see [Claim Creator Fees](/robinhood/claim-fees)), with one twist: the creator half of the trade fee is routed entirely to the Bags index bot, which converts it into dividends for holders.

```text theme={null}
trades happen
└── creator fees accrue (WETH) to the Bags claimer wallet
    └── bot claims once ≥ 0.001 ETH is claimable
        ├── snapshots current token holders
        ├── splits the ETH evenly across the basket (1-10 assets)
        ├── buys each asset
        └── transfers each purchased asset to holders,
            pro rata by snapshot balance
```

Key properties of a distribution cycle:

* **Cadence** — the bot scans continuously (roughly once a minute) and starts a cycle once the claimable creator fees reach the minimum threshold (currently 0.001 ETH).
* **Even split** — the claimed ETH is divided equally across the basket assets.
* **No skim** — 100% of the claimed ETH is spent on basket assets; `distributableWei` always equals `totalWei` in the history payload.
* **Pro rata payouts** — each purchased asset is transferred to holders proportionally to their snapshot balance, in batched multisend transactions.
* **Excluded holders** — contracts are excluded from distributions (pools, the token itself, its fee-share contract, the bot wallet, and any address the explorer classifies as a contract). There is no minimum balance: small holders are included, but a share that rounds down to zero base units pays nothing for that asset.

<Note>
  The basket is fixed at registration. Constituents must be tradeable tokenized assets on Robinhood Chain — the same markets available in the Bags launch flow.
</Note>

## 2. Launch with the Required Claimer

For the bot to ever see your token's fees, the token must be launched with the **Bags claimer wallet as its only fee claimer at 100%**:

```text theme={null}
required claimer: 0x6828E679Fb51b6d0416035370aF6Ec0fb2f2055a (100%)
```

This replaces regular fee sharing — an index token routes the entire creator half of the trade fee into dividends for holders, so you cannot combine it with custom fee-share splits. Launch the token as described in [Launch a Token](/robinhood/launch-token), passing this single claimer.

<Warning>
  Initialization is rejected with `403` if the required claimer is not configured on the token. The claimer configuration is part of the launch — set it up front.
</Warning>

## 3. Register the Index Token

After the launch transaction confirms, register the basket with [Initialize Index Token](/api-reference/init-rh-index-token). The API key's user must own the token's on-chain creator wallet.

```bash theme={null}
curl --request POST \
  --url https://public-api-v2.bags.fm/api/v1/evm/rh/index-token/init \
  --header 'Content-Type: application/json' \
  --header 'x-api-key: YOUR_API_KEY' \
  --data '{
    "tokenAddress": "0xYOUR_TOKEN_ADDRESS",
    "tokens": [
      "0xTSLA_TOKEN_ADDRESS",
      "0xNVDA_TOKEN_ADDRESS",
      "0xAAPL_TOKEN_ADDRESS"
    ]
  }'
```

* `tokens` is the basket: 1–10 asset addresses, no duplicates. Any casing is accepted; addresses are normalized to EIP-55 checksum form.
* A successful call returns `{ "success": true, "response": "Index token initialized successfully" }`.

Error cases:

| Status | Meaning                                                                                            |
| ------ | -------------------------------------------------------------------------------------------------- |
| `403`  | The token's creator wallet does not belong to your user, or the required claimer is not configured |
| `404`  | The address is not a Bags token                                                                    |
| `409`  | The token is already initialized as an index token                                                 |

<Tip>
  If initialization fails after a successful launch, the token still exists on-chain — just retry the `init` call once the issue is fixed. Nothing needs to be relaunched.
</Tip>

## 4. Verify the Registration

Check that the token is registered (and read back its basket) with [Get Index Token Statuses](/api-reference/get-rh-index-token-status). The endpoint is batch-oriented — pass 1–100 addresses:

```bash theme={null}
curl --request POST \
  --url https://public-api-v2.bags.fm/api/v1/evm/rh/index-token/status \
  --header 'Content-Type: application/json' \
  --header 'x-api-key: YOUR_API_KEY' \
  --data '{ "tokenAddresses": ["0xYOUR_TOKEN_ADDRESS"] }'
```

```json theme={null}
{
  "success": true,
  "response": [
    {
      "tokenAddress": "0xYourTokenAddress",
      "isIndexToken": true,
      "tokens": ["0xTSLA...", "0xNVDA...", "0xAAPL..."]
    }
  ]
}
```

`tokens` is empty when `isIndexToken` is `false`.

## 5. Monitor Distribution Cycles

Once trading generates enough fees, completed cycles appear in [Get Index Token History](/api-reference/get-rh-index-token-history), newest first:

```bash theme={null}
curl --request GET \
  --url 'https://public-api-v2.bags.fm/api/v1/evm/rh/index-token/history?tokenAddress=0xYOUR_TOKEN_ADDRESS&limit=20' \
  --header 'x-api-key: YOUR_API_KEY'
```

Each item is one full cycle:

| Field             | Contents                                                                                                                                                                              |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `claim`           | The fee claim funding the cycle — `claimedWei` (ETH in wei), `txHash`, mined/finalized timestamps                                                                                     |
| `buys[]`          | One entry per basket asset — `ethInWei` spent, `boughtAmountRaw` received (base units), `txHash`                                                                                      |
| `distribution`    | `totalWei` / `distributableWei` (always equal), `payoutTxHashes`, `completedAt`, and the holder `snapshot` (`recipientCount`, `excludedHolderCount`, `includedSupply`, `blockNumber`) |
| `topRecipients[]` | Top 10 recipients by snapshot balance, with per-asset amounts received                                                                                                                |

For pagination, pass `nextCursor` back as `cursor`; it is `null` when the history is exhausted. Only completed cycles with confirmed claims are returned — a cycle that is still claiming, buying, or transferring does not appear yet.

<Note>
  `snapshot.includedSupply` is the pro-rata denominator: the token supply held by eligible (non-excluded) holders at the snapshot. A holder's payout per asset is `boughtAmountRaw * holderBalance / includedSupply`, truncated.
</Note>

## Troubleshooting

* **`403` on init** — either the launch was made from a wallet that doesn't belong to your Bags user, or the token wasn't launched with the required claimer at 100%. The claimer set is part of launch configuration; verify with `feeShare.getClaimers()`.
* **`409` on init** — the token is already registered. The basket is immutable; there is no re-init.
* **`isIndexToken` is `false` after a successful init** — statuses are cached briefly server-side; re-check after a few seconds.
* **No history items** — cycles only complete after claimable fees reach the 0.001 ETH threshold and the buy + distribution finish. Check accrued fees via [Get Claimable Positions](/api-reference/get-rh-claimable-positions) for the claimer wallet, and note the empty history payload (`items: []`, `hasMore: false`) is expected for a fresh token.
* **A holder received nothing** — contract addresses are excluded, and very small balances can truncate to zero base units for a given asset. Both are expected behavior.
