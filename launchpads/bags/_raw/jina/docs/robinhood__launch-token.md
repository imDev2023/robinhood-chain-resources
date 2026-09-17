> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Launch a Token

> Launch a Bags token on Robinhood Chain by calling the BagsFactory directly with viem, with an optional atomic initial buy and configurable fee claimers.

In this guide, you'll launch a token on Robinhood Chain by calling `BagsFactory` directly. A single transaction deploys the token, its bonding curve, and its fee-share contract, mints the fixed supply to the curve, and registers everything on-chain. You can optionally include an **atomic initial buy** in the same transaction.

## Prerequisites

Before starting, make sure you have:

* Completed the [Environment Setup](/robinhood/setup) (`chain.ts`, `addresses.ts`, `clients.ts`, and the ABIs).
* Read the [Overview](/robinhood/overview) for the token lifecycle and fee model.
* ETH in your wallet to cover the creation fee (default 0.02 ETH — read it live), any initial buy, and gas.

## 1. How Launching Works

`BagsFactory` exposes two launch entry points:

| Function       | Use when                     | `value` to send                  |
| -------------- | ---------------------------- | -------------------------------- |
| `create`       | No initial buy               | `creationFee` (surplus refunded) |
| `createAndBuy` | You want an atomic first buy | `creationFee + initialBuyWei`    |

Both take the same arguments:

```solidity theme={null}
function create(
    string name,
    string symbol,
    string metadataURI,
    address partner,       // address(0) for none
    address[] claimers,    // fee-share recipients
    uint16[] bps           // parallel to claimers; must sum to 10000
) external payable returns (address token, address curve);
```

The partner's fee rate is **not** a launch parameter: the factory's global `partnerFeeBps` (default `2500`) is snapshotted into the launch, and the partner is paid from the **protocol half** of trading fees — it never reduces the claimers' share. See section 6.

With `createAndBuy`, the factory spends the entire surplus above `creationFee` on an atomic `buyFor(msg.sender, 1)` — there is no front-run window, and if the buy would cross the graduation threshold the excess is auto-refunded.

<Warning>
  The returned `token` and `curve` addresses, plus the `feeShare`, `partner`, and `poolId`, must be read from the **`TokenCreated` event** in the receipt. Per-launch addresses are not predictable before the launch.
</Warning>

## 2. Fee Claimers Rules

The `claimers` / `bps` arrays configure who earns the creator half (1%) of trading fees. The factory enforces:

1. **1 to 100 claimers**, with `claimers.length == bps.length`.
2. Each claimer address is **valid, non-zero, and unique**, and not equal to the `partner`.
3. Each `bps` is a `uint16`, and **all `bps` sum to exactly `10000`** (100%). The factory enforces only the sum — individual shares of `0` are accepted on-chain. The client validator below additionally requires each share to be `>= 1` as a sensible default (a `0`-bps claimer would never earn).

The simplest setup is a single claimer (the creator) at `10000` bps. Validate client-side before signing — an on-chain revert still costs gas.

<Note>
  When splitting a percentage across claimers, have the **last** claimer absorb any rounding remainder so the total lands on exactly `10000`.
</Note>

## 3. Prepare Metadata

`metadataURI` should point to a JSON document describing the token (name, symbol, description, image, socials), typically hosted on IPFS. Upload it however you like and pass the resulting URI (e.g. `https://ipfs.io/ipfs/...`). This guide assumes you already have a `metadataURI`.

## 4. The Launch Script

Save this as `launch-token.ts`. It validates claimers, reads the live creation fee, simulates, sends, and parses the receipt.

```typescript launch-token.ts theme={null}
import "dotenv/config";
import {
  getAddress,
  isAddress,
  parseEther,
  parseEventLogs,
  zeroAddress,
  type Address,
} from "viem";
import { publicClient, getWalletClient } from "./clients";
import { ROBINHOOD_LAUNCHPAD } from "./addresses";
import { bagsFactoryAbi, bagsBondingCurveAbi } from "./abi";

const TOTAL_BPS = 10_000;
const MAX_CLAIMERS = 100;

interface ClaimerAllocation {
  address: Address;
  bps: number;
}

/** Client-side mirror of the factory's claimer rules. Returns an error string, or null when valid. */
function validateClaimers(claimers: ClaimerAllocation[], partner?: Address): string | null {
  if (claimers.length === 0) return "Add at least one fee claimer.";
  if (claimers.length > MAX_CLAIMERS) return `At most ${MAX_CLAIMERS} claimers.`;

  // Only reject claimers matching a *real* partner — zeroAddress means "no partner".
  const partnerKey =
    partner && partner.toLowerCase() !== zeroAddress ? partner.toLowerCase() : null;

  const seen = new Set<string>();
  for (const c of claimers) {
    if (!isAddress(c.address)) return `"${c.address}" is not a valid address.`;
    const key = c.address.toLowerCase();
    if (key === zeroAddress) return "The zero address cannot be a claimer.";
    if (partnerKey && key === partnerKey) return "The partner cannot also be a claimer.";
    if (seen.has(key)) return "Claimer addresses must be unique.";
    seen.add(key);
    if (!Number.isInteger(c.bps) || c.bps < 1 || c.bps > TOTAL_BPS)
      return "Each claimer needs a whole bps share between 1 and 10000.";
  }
  const total = claimers.reduce((sum, c) => sum + c.bps, 0);
  if (total !== TOTAL_BPS)
    return `bps must sum to exactly 10000 (currently ${total}).`;
  return null;
}

async function launchToken(params: {
  name: string;
  symbol: string;
  metadataURI: string;
  claimers: ClaimerAllocation[];
  /** Optional partner, paid from the protocol half at the factory's snapshotted partnerFeeBps. */
  partner?: Address;
  /** ETH spent on an atomic initial buy. Use 0n for no buy. */
  initialBuyEth?: bigint;
}) {
  const { name, symbol, metadataURI, claimers } = params;
  const initialBuyWei = params.initialBuyEth ?? 0n;
  const partner = params.partner ?? zeroAddress;

  const claimersError = validateClaimers(claimers, partner);
  if (claimersError) throw new Error(claimersError);

  const walletClient = getWalletClient();
  const account = walletClient.account;

  // The creation fee is owner-settable — read it live right before signing.
  const creationFee = await publicClient.readContract({
    address: ROBINHOOD_LAUNCHPAD.factory,
    abi: bagsFactoryAbi,
    functionName: "creationFee",
  });

  // partner defaults to address(0) (no partner) unless one is passed in.
  const args = [
    name,
    symbol,
    metadataURI,
    partner,
    claimers.map((c) => getAddress(c.address)),
    claimers.map((c) => c.bps),
  ] as const;

  const value = creationFee + initialBuyWei;
  const functionName = initialBuyWei > 0n ? "createAndBuy" : "create";

  console.log(`Launching $${symbol} via ${functionName} (fee ${creationFee} wei)...`);

  // Simulate first so reverts surface as decoded custom errors before signing.
  const { request } = await publicClient.simulateContract({
    account,
    address: ROBINHOOD_LAUNCHPAD.factory,
    abi: bagsFactoryAbi,
    functionName,
    args,
    value,
  });

  const txHash = await walletClient.writeContract(request);
  const receipt = await publicClient.waitForTransactionReceipt({ hash: txHash });
  if (receipt.status !== "success") {
    throw new Error("Launch transaction reverted on-chain. No token was created.");
  }

  // Clone addresses only exist in the TokenCreated event.
  const [created] = parseEventLogs({
    abi: bagsFactoryAbi,
    logs: receipt.logs,
    eventName: "TokenCreated",
  });
  if (!created) throw new Error("Launch confirmed but no TokenCreated event found.");

  // A large enough initial buy can graduate the token in the same tx.
  const migratedLogs = parseEventLogs({
    abi: bagsBondingCurveAbi,
    logs: receipt.logs,
    eventName: "Migrated",
  });

  const result = {
    txHash,
    token: created.args.token as Address,
    curve: created.args.curve as Address,
    feeShare: created.args.feeShare as Address,
    partner: created.args.partner as Address,
    poolId: created.args.poolId as `0x${string}`,
    migrated: migratedLogs.length > 0,
  };

  console.log("Token launched!");
  console.log("  token   :", result.token);
  console.log("  curve   :", result.curve);
  console.log("  feeShare:", result.feeShare);
  console.log("  partner :", result.partner);
  console.log("  poolId  :", result.poolId);
  console.log("  migrated:", result.migrated);
  console.log(`  explorer: https://robinhoodchain.blockscout.com/tx/${txHash}`);
  return result;
}

// Example: launch with all fees to the creator and a small initial buy.
launchToken({
  name: "My Token",
  symbol: "MTK",
  metadataURI: "https://ipfs.io/ipfs/YOUR_METADATA_CID",
  claimers: [
    { address: "0xYOUR_WALLET_ADDRESS", bps: 10000 }, // creator gets 100%
  ],
  initialBuyEth: parseEther("0.01"),
}).catch(console.error);
```

## 5. Run Your Script

```bash theme={null}
npx ts-node launch-token.ts
```

On success you'll see the token, curve, feeShare, and poolId addresses. Save the `token` address — it's the identifier you'll use everywhere else.

## 6. Splitting Fees Among Multiple Claimers

To share the creator side with additional wallets, list each with its bps. The example below gives the creator 50%, and two collaborators 30% and 20%:

```typescript theme={null}
launchToken({
  name: "Shared Token",
  symbol: "SHARE",
  metadataURI: "https://ipfs.io/ipfs/YOUR_METADATA_CID",
  claimers: [
    { address: "0xCREATOR", bps: 5000 },
    { address: "0xCOLLAB_ONE", bps: 3000 },
    { address: "0xCOLLAB_TWO", bps: 2000 }, // absorbs rounding; total = 10000
  ],
});
```

To include a **partner**, pass a non-zero `partner` address. The partner's cut comes from the **protocol half** of trading fees, not from the claimers: the factory's global `partnerFeeBps` (default `2500` = 25% of the protocol half = 0.25% of volume) is snapshotted at launch, the partner accrues that share in the token's `BagsFeeShare`, and the vault receives the remainder. The claimers always split the full creator half regardless of partner. The partner must not also appear in `claimers`. See the [Partner Program](/robinhood/partner-program) guide for the full partner workflow (tracking tokens, reading earnings, claiming).

```typescript theme={null}
launchToken({
  name: "Partnered Token",
  symbol: "PART",
  metadataURI: "https://ipfs.io/ipfs/YOUR_METADATA_CID",
  partner: "0xPARTNER_ADDRESS", // earns the snapshotted partnerFeeBps of the protocol half
  claimers: [
    { address: "0xCREATOR", bps: 10000 }, // creator still gets the full creator half
  ],
});
```

## 7. What Happens Next

After launch, the token trades on its bonding curve. Buyers send ETH to the curve to receive tokens; the creator side of every trade fee accrues to the `feeShare` contract. When enough ETH is raised, the token graduates to a Uniswap v4 pool.

* To trade the token, see [Trade Tokens](/robinhood/trade-tokens).
* To read live state (price, bonding progress, migration status), see [Read State & Discover Tokens](/robinhood/read-state).
* To claim accrued fees, see [Claim Creator Fees](/robinhood/claim-fees).

## Troubleshooting

* **`BagsFactory_InsufficientCreationFee`** — you sent less than `creationFee()`. Read the fee live and set `value` accordingly.
* **`BagsFactory_NoClaimers`** — the `claimers` array is empty. Pass at least one claimer.
* **`BagsFactory_InvalidClaimers`** — the config failed a rule in section 2: `claimers.length != bps.length`, a duplicate or zero address, a claimer equal to the `partner`, more than 100 claimers, or `bps` that don't sum to `10000`.
* **`BagsFactory_BuyFailed(curve, value)`** — the atomic initial buy in `createAndBuy` reverted (e.g. slippage or curve state). Lower the buy value, or call `create` and buy separately.
* **`BagsFactory_NoBuyValue`** — you called `createAndBuy` with `value == creationFee` (nothing left to buy with). Either add buy value or call `create`.
* **Simulation reverts before sending** — the decoded custom error tells you exactly which rule failed; fix the inputs and retry. Simulating first means you never waste gas on a doomed launch.

For the full function, event, and error catalog, see the [Contracts Reference](/robinhood/contracts).
