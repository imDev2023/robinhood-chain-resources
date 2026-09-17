# Bags - Partner Program

> Source: https://docs.bags.fm/robinhood/partner-program
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/robinhood/partner-program.md)

---

# Partner Program

> Earn a share of trading fees as a Robinhood Chain launch partner: how partner economics work, how to launch with a partner, track your tokens, and claim earnings.

If your app or platform launches Bags tokens on behalf of creators, you can register yourself as the **partner** on every launch and earn a share of the trading fees for the lifetime of the token — without taking anything away from the creator.

## Prerequisites

Before starting, make sure you have:

* Completed the [Environment Setup](/robinhood/setup).
* Read the [Overview](/robinhood/overview) for the fee model and lifecycle.

## 1. How Partner Economics Work

Every trade pays a flat 2% fee on the ETH/WETH leg, split into two halves. The partner is paid from the **protocol half** — the creator half always goes 100% to the token's fee claimers:

```text theme={null}
2% trade fee
├── creator half (1%)  -> the token's fee claimers (untouched by the partner)
└── protocol half (1%)
    ├── partner: half * partnerFeeBps / 10000   -> accrues in the token's BagsFeeShare (WETH)
    └── remainder                               -> BagsVault
```

* `partnerFeeBps` is a **factory global** (`factory.partnerFeeBps()`, default `2500` = 25% of the protocol half = **0.25% of trade volume**).
* It is **snapshotted at launch**: each token keeps the value that was set when it was created, readable per token via `curve.partnerFeeBps()`. Later factory changes only affect future launches.
* Partner earnings accrue in **both phases** — bonding-curve trades and post-graduation Uniswap v4 swaps alike.

<Note>
  A launch has at most **one** partner, set once at `create` time and immutable afterwards. The partner address must not also appear in the launch's `claimers` array.
</Note>

## 2. Launch With Your Partner Address

Pass your address as the `partner` argument to `create` / `createAndBuy` — that's the entire integration on the launch side:

```typescript theme={null}
launchToken({
  name: "Creator Token",
  symbol: "CTK",
  metadataURI: "https://ipfs.io/ipfs/METADATA_CID",
  partner: "0xYOUR_PLATFORM_WALLET", // you earn partnerFeeBps of the protocol half
  claimers: [
    { address: "0xCREATOR_WALLET", bps: 10000 }, // creator keeps the full creator half
  ],
});
```

See [Launch a Token](/robinhood/launch-token) for the full `launchToken` script. Use a dedicated, secured wallet for the partner address — it cannot be changed after launch.

## 3. Track the Tokens You Partner On

The `TokenCreated` event carries the `partner` field, so index your launches from factory logs and filter on it (`partner` is not an indexed topic, so filter client-side):

```typescript partner-tokens.ts theme={null}
import { parseAbiItem, type Address } from "viem";
import { publicClient } from "./clients";
import { ROBINHOOD_LAUNCHPAD, ROBINHOOD_DEPLOY_BLOCK } from "./addresses";

const tokenCreatedEvent = parseAbiItem(
  "event TokenCreated(address indexed token, address indexed curve, address indexed creator, address feeShare, address partner, bytes32 poolId, string name, string symbol, string metadataURI)"
);

/** All launches where `partner` is your address. */
export async function getPartnerTokens(partner: Address, fromBlock: bigint = ROBINHOOD_DEPLOY_BLOCK) {
  const logs = await publicClient.getLogs({
    address: ROBINHOOD_LAUNCHPAD.factory,
    event: tokenCreatedEvent,
    fromBlock,
    toBlock: "latest",
  });
  return logs
    .filter((log) => log.args.partner?.toLowerCase() === partner.toLowerCase())
    .map((log) => ({
      token: log.args.token!,
      curve: log.args.curve!,
      feeShare: log.args.feeShare!,
      poolId: log.args.poolId!,
      symbol: log.args.symbol!,
    }));
}
```

For an ongoing feed, checkpoint the last scanned block as described in [Read State & Discover Tokens](/robinhood/read-state). To verify a single token's partner setup, read `curve.partner()` and `curve.partnerFeeBps()` from its bonding curve.

## 4. Read Partner Earnings

Partner earnings accrue in each token's `BagsFeeShare` and are read exactly like claimer balances:

```typescript partner-earnings.ts theme={null}
import { publicClient } from "./clients";
import { ROBINHOOD_LAUNCHPAD } from "./addresses";
import { bagsLensAbi } from "./abi";
import type { Address } from "viem";

/** Claimable WETH (wei) per token, batched through multicall. */
export async function readPartnerEarnings(partner: Address, tokens: Address[]) {
  const amounts = await Promise.all(
    tokens.map((token) =>
      publicClient.readContract({
        address: ROBINHOOD_LAUNCHPAD.lens,
        abi: bagsLensAbi,
        functionName: "claimableOf",
        args: [token, partner],
      })
    )
  );
  return tokens.map((token, i) => ({ token, claimable: amounts[i] }));
}
```

Two useful mirrors when accounting:

* Pre-graduation, each curve trade emits `FeesSplit(payer, vault, feeShare, vaultFeeQuote, creatorFeeWETH, partnerFeeWETH)` — your cut is `partnerFeeWETH`.
* The fee-share emits `PartnerFeeNotified(amount)` whenever your cut is delivered.

<Tip>
  Like claimer balances, `claimableOf` counts only fees already notified to the fee-share. Post-graduation fees still un-swept in the v4 hook become claimable once a sweep runs — your `claim` triggers one automatically. Your pending share of the un-swept amount is `(pendingFees / 2) * partnerFeeBps / 10000`, with `pendingFees` and `partnerFeeBps` from `hook.pools(poolId)`.
</Tip>

## 5. Claim Partner Fees

Claiming is identical to claimer flow — call `claim(unwrap)` on each token's `BagsFeeShare` from the partner wallet (see [Claim Creator Fees](/robinhood/claim-fees) for the full script):

```typescript theme={null}
import { bagsFeeShareAbi } from "./abi";

const { request } = await publicClient.simulateContract({
  account: partnerWallet.account,
  address: feeShare,
  abi: bagsFeeShareAbi,
  functionName: "claim",
  args: [true], // true = receive native ETH, false = keep WETH
});
await partnerWallet.writeContract(request);
```

Fee shares are per token, so claim each token separately. Skip tokens where `claimableOf` is zero — claiming with nothing to claim reverts with `BagsFeeShare_NothingToClaim`.

## Troubleshooting

* **`BagsFeeShare_NothingToClaim`** — no partner fees accrued yet on this token, or you already claimed. Check `claimableOf(token, partner)` first.
* **Your address earns nothing on a token** — confirm you were actually set as the partner at launch: `curve.partner()` must return your address. The partner cannot be added retroactively.
* **Launch reverts with `BagsFactory_InvalidClaimers`** — the partner address also appears in `claimers`. Remove it; the partner is paid from the protocol half, not the claimer split.
* **Earnings look \~0.25% of volume, not 1%** — that's correct: the default `partnerFeeBps` of `2500` pays 25% of the 1% protocol half. The creator half is never shared with partners.

For the full function, event, and error catalog, see the [Contracts Reference](/robinhood/contracts).
