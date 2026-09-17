# Bags - Claim Creator Fees

> Source: https://docs.bags.fm/robinhood/claim-fees
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/robinhood/claim-fees.md)

---

# Claim Creator Fees

> Understand the Bags fee-share model on Robinhood Chain and claim accrued creator fees from a token's BagsFeeShare contract with viem.

In this guide, you'll read and claim trading fees on Robinhood Chain. Each token has its own `BagsFeeShare` contract that accrues the creator half of the trade fee (**1% of every trade**, in WETH) for the claimers configured at launch, plus the optional partner's cut of the protocol half.

## Prerequisites

Before starting, make sure you have:

* Completed the [Environment Setup](/robinhood/setup).
* A token whose `feeShare` address you can resolve (from launch, `factory.feeShareForToken(token)`, or `BagsLens.getTokenState`).
* A wallet with a positive claimable balance — i.e. one of the token's configured fee claimers or the optional partner. Check with `claimableOf(token, user)` (or `feeShare.claimable(user)`).

<Tip>
  To use the Bags API instead of reading contracts directly, call [Get Robinhood Claimable Positions](/api-reference/get-rh-claimable-positions), then [Create Robinhood Claim Transactions](/api-reference/create-rh-claim-txs) for each position you want to claim.
</Tip>

## 1. How Fee Sharing Works

The flat 2% trade fee splits into two halves, and the token's `BagsFeeShare` is the pull-payment ledger (in WETH) for two independent streams:

```text theme={null}
2% trade fee
├── creator half (1%)  -> FeeNotified(amount)        -> split among claimers:
│                          each claimer: amount * bps[i] / 10000
│                          (last claimer absorbs rounding dust)
└── protocol half (1%) -> partner cut = half * partnerFeeBps / 10000
                           -> PartnerFeeNotified(amount) -> claimable[partner]
                          remainder -> BagsVault (not claimable here)
```

* The **claimers** configured at launch split 100% of the creator half by their bps — the partner never reduces their share.
* The **partner** (if set at launch) earns its cut from the protocol half at the launch-snapshotted `partnerFeeBps` (default `2500` = 25% of the half). See the [Partner Program](/robinhood/partner-program) guide for the partner-side workflow.

Each recipient's balance accumulates in `claimable[address]` until they call `claim`. This happens automatically as trades occur in **both** phases — creators earn from bonding-curve trades and pool trades alike.

<Note>
  Post-migration fees first accrue inside the Bags v4 hook and are periodically swept into the fee-share contract (anyone can call `hook.sweep(poolId)`). `claim` pokes that sweep for you, so you don't need a separate sweep transaction.
</Note>

## 2. Read Claimable Fees

Use `BagsLens.claimableOf(token, user)` for the amount claimable **right now** (already notified to the fee-share, in WETH wei):

```typescript read-claimable.ts theme={null}
import { publicClient } from "./clients";
import { ROBINHOOD_LAUNCHPAD } from "./addresses";
import { bagsLensAbi } from "./abi";
import type { Address } from "viem";

export async function readClaimable(token: Address, user: Address): Promise<bigint> {
  return publicClient.readContract({
    address: ROBINHOOD_LAUNCHPAD.lens,
    abi: bagsLensAbi,
    functionName: "claimableOf",
    args: [token, user],
  });
}
```

You can also read directly from the fee-share contract:

| Call                        | Returns                                                                                         |
| --------------------------- | ----------------------------------------------------------------------------------------------- |
| `feeShare.claimable(user)`  | WETH wei claimable now for `user`                                                               |
| `feeShare.getClaimers()`    | `(address[] claimers, uint16[] bps)`                                                            |
| `feeShare.claimerBps(user)` | A user's share of the creator half in bps                                                       |
| `feeShare.PARTNER()`        | Partner address (`address(0)` when none)                                                        |
| `curve.partnerFeeBps()`     | The launch-snapshotted partner share of the protocol half (read from the token's bonding curve) |

<Tip>
  `claimableOf` counts only WETH already notified to the fee-share. Fees still sitting un-swept in the v4 hook are not included; they become claimable once `claim` (or another sweep) flushes them.
</Tip>

<Note>
  The claimer list is **not immutable** — the fee-share owner can call `setClaimers` (mirrored by the `ClaimersUpdated` event). Re-read `getClaimers()` rather than caching it forever.
</Note>

## 3. Claim Fees

Call `claim(unwrap)` on the token's `BagsFeeShare`. Pass `unwrap: true` to receive native ETH; `false` leaves the payout as WETH.

```typescript claim-fees.ts theme={null}
import "dotenv/config";
import { publicClient, getWalletClient } from "./clients";
import { bagsFeeShareAbi } from "./abi";
import { readClaimable } from "./read-claimable";
import type { Address } from "viem";

export async function claimFees(feeShare: Address, unwrap = true) {
  const walletClient = getWalletClient();
  const txHash = await (async () => {
    // Simulate first so custom errors (e.g. BagsFeeShare_NothingToClaim) decode cleanly.
    const { request } = await publicClient.simulateContract({
      account: walletClient.account,
      address: feeShare,
      abi: bagsFeeShareAbi,
      functionName: "claim",
      args: [unwrap],
    });
    return walletClient.writeContract(request);
  })();

  const receipt = await publicClient.waitForTransactionReceipt({ hash: txHash });
  if (receipt.status !== "success") throw new Error("Claim reverted.");
  console.log(`Claimed. Tx: https://robinhoodchain.blockscout.com/tx/${txHash}`);
  return { txHash };
}

// Example: resolve feeShare from the token, then claim as native ETH.
async function main() {
  const token = "0xTOKEN_ADDRESS" as Address;
  const user = getWalletClient().account.address;

  const feeShare = await publicClient.readContract({
    address: (await import("./addresses")).ROBINHOOD_LAUNCHPAD.factory,
    abi: (await import("./abi")).bagsFactoryAbi,
    functionName: "feeShareForToken",
    args: [token],
  }) as Address;

  const claimable = await readClaimable(token, user);
  if (claimable <= 0n) {
    console.log("Nothing to claim yet.");
    return;
  }
  console.log(`Claimable: ${claimable} WETH wei`);
  await claimFees(feeShare, true);
}

main().catch(console.error);
```

<Warning>
  Check `claimableOf` (or `feeShare.claimable`) is greater than zero before claiming. Calling `claim` with nothing to claim reverts with `BagsFeeShare_NothingToClaim` and wastes gas.
</Warning>

## 4. Estimate Pending (Un-Swept) Fees

For a fuller picture of what a creator will eventually receive, add the un-swept accrual sitting in the v4 hook for the token's pool. The hook exposes per-pool config and pending fees in one read: `pools(poolId)` returns `(bondingCurve, feeShare, pendingFees, minted, partner, partnerFeeBps)`.

```typescript pending-estimate.ts theme={null}
import { publicClient } from "./clients";
import { ROBINHOOD_LAUNCHPAD, ROBINHOOD_FEES } from "./addresses";
import { bagsLensAbi, bagsFeeShareAbi, bagsV4HookAbi } from "./abi";
import type { Address } from "viem";

/** Claimable-now plus an estimate of the user's cut of un-swept hook fees. */
export async function readClaimableBreakdown(token: Address, user: Address) {
  const state = await publicClient.readContract({
    address: ROBINHOOD_LAUNCHPAD.lens, abi: bagsLensAbi, functionName: "getTokenState", args: [token],
  });
  if (!state.exists) return null;

  const [claimable, claimers, pool] = await Promise.all([
    publicClient.readContract({ address: ROBINHOOD_LAUNCHPAD.lens, abi: bagsLensAbi, functionName: "claimableOf", args: [token, user] }),
    publicClient.readContract({ address: state.feeShare, abi: bagsFeeShareAbi, functionName: "getClaimers" }),
    publicClient.readContract({ address: ROBINHOOD_LAUNCHPAD.hook, abi: bagsV4HookAbi, functionName: "pools", args: [state.poolId] }),
  ]);

  const [addresses, bps] = claimers;
  const i = addresses.findIndex((a) => a.toLowerCase() === user.toLowerCase());
  const userBps = i === -1 ? 0 : bps[i];
  // pools(poolId) -> [bondingCurve, feeShare, pendingFees, minted, partner, partnerFeeBps]
  const pendingFees = pool[2]; // un-swept WETH accrual for this pool (the full 2% leg)
  const partnerFeeBps = pool[5]; // launch-snapshotted partner share of the protocol half

  // On sweep the accrual splits 50/50. The creator half goes entirely to the
  // fee-share, split among claimers by bps. The protocol half pays the partner
  // partnerFeeBps of it; the remainder goes to the vault. Multiply before
  // dividing to limit truncation. This estimates a claimer's cut; a partner's
  // pending cut is (pendingFees / 2n * partnerFeeBps) / 10000n.
  const bpsDenom = BigInt(ROBINHOOD_FEES.bpsDenominator);
  const creatorHalf = pendingFees / 2n;
  const pendingUserEstimate = (creatorHalf * BigInt(userBps)) / bpsDenom;

  return { claimable, pendingFees, userBps, partnerFeeBps, isClaimer: i !== -1, feeShare: state.feeShare, pendingUserEstimate };
}
```

<Note>
  `pendingUserEstimate` is an estimate — the exact amount is settled when the sweep runs during a claim (`FeesSwept(poolId, bagsShare, creatorShare, partnerShare)` reports the actual split).
</Note>

## Troubleshooting

* **`BagsFeeShare_NothingToClaim`** — your `claimable` balance is zero. Wait for trades to accrue fees (or for a sweep to flush hook fees), and check `claimableOf` before claiming.
* **`BagsFeeShare_NotAuthorized`** — only the bonding curve and hook may notify fees; you can't call `notifyFee` yourself. Just call `claim`.
* **Claim succeeds but you received WETH, not ETH** — you passed `unwrap: false`. Pass `true` for native ETH, or unwrap the WETH yourself later.
* **Not a claimer** — only the token's configured `claimers` and its optional `partner` accrue fees. Verify eligibility with `claimableOf(token, user)` (or `feeShare.claimable(user)`) being greater than zero. Note `feeShare.getClaimers()` lists only the configured claimers — it does **not** include the partner.

For the full function, event, and error catalog, see the [Contracts Reference](/robinhood/contracts).
