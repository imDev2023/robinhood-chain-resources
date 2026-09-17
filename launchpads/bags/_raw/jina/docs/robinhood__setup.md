> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Environment Setup

> Set up viem clients, the Robinhood Chain definition, contract addresses, and ABIs before integrating Bags launching and trading.

This guide sets up the shared building blocks — chain definition, read/write clients, addresses, and ABIs — used by every other Robinhood Chain guide. The examples use [viem](https://viem.sh), but the same calls translate directly to [ethers](https://docs.ethers.org) or any EVM library.

## Prerequisites

Before starting, make sure you have:

* Node.js 18+ and a TypeScript project. If you're starting fresh, follow the [TypeScript & Node.js Setup Guide](/how-to-guides/typescript-node-setup) for the base project, then install the EVM dependencies below.
* Some ETH on Robinhood Chain (chain ID `4663`) in the wallet you'll sign with.
* Read the [Robinhood Chain Overview](/robinhood/overview) for the token lifecycle and address book.

<Note>
  No Bags API key is required for Robinhood Chain. You interact with the public smart contracts directly.
</Note>

## 1. Install Dependencies

```bash theme={null}
npm install viem dotenv
```

## 2. Set Up Environment Variables

Create a `.env` file. The public RPC works out of the box but is rate-limited; set a dedicated endpoint if you have one.

```bash theme={null}
# .env
ROBINHOOD_RPC_URL=https://rpc.mainnet.chain.robinhood.com
# Required only for guides that send transactions (launch, trade, claim):
PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE
```

<Warning>
  Never commit your `.env` file. Add it to `.gitignore`. Treat your private key as a secret.
</Warning>

## 3. Define the Chain

Save this as `chain.ts`. It defines Robinhood Chain and tunes viem for the chain's \~100 ms blocks.

```typescript chain.ts theme={null}
import { defineChain } from "viem";

export const ROBINHOOD_CHAIN_ID = 4663;

export const ROBINHOOD_RPC_URL =
  process.env.ROBINHOOD_RPC_URL || "https://rpc.mainnet.chain.robinhood.com";

export const robinhoodChain = defineChain({
  id: ROBINHOOD_CHAIN_ID,
  name: "Robinhood Chain",
  nativeCurrency: { name: "Ether", symbol: "ETH", decimals: 18 },
  rpcUrls: {
    default: { http: [ROBINHOOD_RPC_URL] },
  },
  blockExplorers: {
    default: { name: "Blockscout", url: "https://robinhoodchain.blockscout.com" },
  },
  contracts: {
    multicall3: { address: "0xcA11bde05977b3631167028862bE2a173976CA11" },
  },
});
```

## 4. Addresses & Protocol Constants

Save this as `addresses.ts`. These are the protocol singletons and shared infrastructure (see the [full address book](/robinhood/overview#contract-address-book)).

```typescript addresses.ts theme={null}
export const ROBINHOOD_LAUNCHPAD = {
  /** Launch entry point + on-chain registry (UUPS proxy — stable address). */
  factory: "0xe8Cc4431adF8b5A847C113EF0c6af9043219Cb37",
  /** Stateless read aggregator — getTokenState(s), claimableOf. */
  lens: "0xC82Db941dAf90B754aecb5F7D14c683dc608d595",
  /** Singleton v4 hook shared by all Bags pools. */
  hook: "0x2380aBf72C17aABAb76480244759AC7E2932EEcC",
  /** Platform treasury (UUPS proxy, native ETH). */
  vault: "0x4861446aa7fFd9e67a83cBbAcb1A4B70540B83Aa",
  /** Robinhood-MODIFIED UniversalRouter fork (custom swap struct). */
  universalRouter: "0x8876789976dEcBfCbBbe364623C63652db8C0904",
  /** v4-periphery quoter (off-chain quoting only). */
  v4Quoter: "0x8Dc178eFB8111BB0973Dd9d722ebeFF267c98F94",
  /** v4 pool state reads: getSlot0(poolId), getLiquidity(poolId). */
  stateView: "0xF3334192D15450CdD385c8B70e03f9A6bD9E673b",
  /** v4 PoolManager singleton (Swap logs). */
  poolManager: "0x8366a39CC670B4001A1121B8F6A443A643e40951",
  /** v4 PositionManager (migration LP mint — reads only). */
  positionManager: "0x58daec3116aae6D93017bAAea7749052E8a04fA7",
  /** Canonical Permit2 — spender route for UniversalRouter ERC-20 inputs. */
  permit2: "0x000000000022D473030F116dDEE9F6B43aC78BA3",
  /** aeWETH upgradeable proxy — WETH9-compatible interface. */
  weth: "0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73",
} as const;

/** First protocol deploy block — lower bound for any log scan. */
export const ROBINHOOD_DEPLOY_BLOCK = 7887312n;

/** Native ETH sentinel address. */
export const ROBINHOOD_NATIVE_TOKEN = "0x0000000000000000000000000000000000000000";

/**
 * Uniswap v4 PoolKey tuning for Bags pools. Must match the factory
 * byte-for-byte or derived poolIds are wrong.
 */
export const ROBINHOOD_POOL = {
  dynamicFeeFlag: 0x800000,
  tickSpacing: 60,
} as const;

/**
 * Fee model: 2% of the ETH/WETH leg on every trade.
 * Creator half (1%) goes to the token's fee claimers; protocol half (1%) is
 * split between the optional partner (at the launch-snapshotted partnerFeeBps,
 * read live from the factory/curve) and the vault.
 */
export const ROBINHOOD_FEES = {
  txFeeBps: 200,
  creatorHalfBps: 100,
  protocolHalfBps: 100,
  bpsDenominator: 10_000,
} as const;

/** Fixed supply per Bags token: 1,000,000,000 x 1e18. FDV = spot price x 1e9. */
export const ROBINHOOD_TOKEN_SUPPLY_WEI = 1_000_000_000_000000000000000000n;
```

## 5. Create the Clients

Save this as `clients.ts`. The **public client** is for reads and simulations; the **wallet client** signs and sends transactions.

```typescript clients.ts theme={null}
import { createPublicClient, createWalletClient, http } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { robinhoodChain, ROBINHOOD_RPC_URL } from "./chain";

/**
 * Shared read client. `batch.multicall` coalesces parallel readContract calls
 * into single multicall3 requests — the main defense against public-RPC rate
 * limits. 500 ms polling suits the ~100 ms block time.
 */
export const publicClient = createPublicClient({
  chain: robinhoodChain,
  transport: http(ROBINHOOD_RPC_URL, { batch: true }),
  batch: { multicall: true },
  pollingInterval: 500,
});

/** Write client. Only needed for launch / trade / claim guides. */
export function getWalletClient() {
  const pk = process.env.PRIVATE_KEY;
  if (!pk) throw new Error("PRIVATE_KEY is required to send transactions");
  const account = privateKeyToAccount(pk as `0x${string}`);
  return createWalletClient({
    account,
    chain: robinhoodChain,
    transport: http(ROBINHOOD_RPC_URL),
  });
}
```

<Note>
  In a browser dApp, replace `getWalletClient` with a wallet-backed client, e.g. `createWalletClient({ account, chain: robinhoodChain, transport: custom(window.ethereum) })`, and switch the wallet to chain `4663` before writing.
</Note>

## 6. Get the ABIs

The Bags contract ABIs are published in the public [`robinhood-abi-v2`](https://github.com/bagsfm/bags-idl/tree/main/robinhood-abi-v2) directory of the [`bagsfm/bags-idl`](https://github.com/bagsfm/bags-idl) repository. It contains eight JSON files:

* `BagsFactory.json`, `BagsBondingCurve.json`, `BagsFeeShare.json`, `BagsLens.json`, `BagsToken.json`, `BagsV4Hook.json`, `BagsVault.json`, `BagsBeacon.json`

Import each JSON as an ABI, for example:

```typescript abi/index.ts theme={null}
import bagsFactory from "./BagsFactory.json";
import bagsBondingCurve from "./BagsBondingCurve.json";
import bagsFeeShare from "./BagsFeeShare.json";
import bagsLens from "./BagsLens.json";
import bagsToken from "./BagsToken.json";
import bagsV4Hook from "./BagsV4Hook.json";
import bagsVault from "./BagsVault.json";

export const bagsFactoryAbi = bagsFactory;
export const bagsBondingCurveAbi = bagsBondingCurve;
export const bagsFeeShareAbi = bagsFeeShare;
export const bagsLensAbi = bagsLens;
export const bagsTokenAbi = bagsToken;
export const bagsV4HookAbi = bagsV4Hook;
export const bagsVaultAbi = bagsVault;
```

<Tip>
  Import the **full** ABIs including their custom `error` definitions — viem uses them to decode revert reasons into readable errors (e.g. `BagsBondingCurve_SlippageExceeded`). See the [Contracts Reference](/robinhood/contracts) for the error catalog.
</Tip>

### Periphery ABIs (hand-written)

The Uniswap-style infrastructure (UniversalRouter, Permit2, WETH, V4Quoter, StateView) is **not** part of the Bags ABI export. The [Trade Tokens](/robinhood/trade-tokens) guide includes the minimal hand-written ABIs you need for post-migration swaps. The full definitions are also listed in the [Contracts Reference](/robinhood/contracts#periphery-abis).

## 7. Verify Your Setup

Read a value from the factory to confirm everything is wired up.

```typescript verify.ts theme={null}
import { publicClient } from "./clients";
import { ROBINHOOD_LAUNCHPAD } from "./addresses";
import { bagsFactoryAbi } from "./abi";

async function main() {
  const [creationFee, tokenCount] = await Promise.all([
    publicClient.readContract({
      address: ROBINHOOD_LAUNCHPAD.factory,
      abi: bagsFactoryAbi,
      functionName: "creationFee",
    }),
    publicClient.readContract({
      address: ROBINHOOD_LAUNCHPAD.factory,
      abi: bagsFactoryAbi,
      functionName: "allTokensLength",
    }),
  ]);

  console.log("Creation fee (wei):", creationFee.toString());
  console.log("Tokens launched:", tokenCount.toString());
}

main().catch(console.error);
```

```bash theme={null}
npx ts-node verify.ts
```

If you see the creation fee (default `0.02 ETH` = `20000000000000000` wei) and a token count printed, you're ready to move on.

## Next steps

<CardGroup cols={2}>
  <Card title="Launch a Token" icon="rocket" href="/robinhood/launch-token">
    Create a token through the BagsFactory.
  </Card>

  <Card title="Trade Tokens" icon="arrow-right-arrow-left" href="/robinhood/trade-tokens">
    Buy and sell across both phases.
  </Card>

  <Card title="Read State & Discover" icon="magnifying-glass" href="/robinhood/read-state">
    Query state and list tokens with BagsLens.
  </Card>

  <Card title="Claim Creator Fees" icon="coins" href="/robinhood/claim-fees">
    Claim accrued fees from BagsFeeShare.
  </Card>
</CardGroup>
