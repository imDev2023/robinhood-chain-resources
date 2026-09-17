> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Trade Tokens

> Buy and sell Bags tokens on Robinhood Chain: bonding-curve trades before graduation and Uniswap v4 swaps (via the modified UniversalRouter) after.

In this guide, you'll trade Bags tokens on Robinhood Chain. Which venue you use depends on whether the token has **graduated**:

* **Before graduation** — trade against the token's `BagsBondingCurve` (buy with native ETH, sell for native ETH).
* **After graduation** — trade against the token/WETH Uniswap v4 pool through the Robinhood-modified UniversalRouter.

Always determine the phase first, then route accordingly.

## Prerequisites

Before starting, make sure you have:

* Completed the [Environment Setup](/robinhood/setup).
* Read the [Overview](/robinhood/overview) (fee model, lifecycle) and know the token address you want to trade.
* ETH in your wallet for buys and gas.

## 1. Route by Migration Status

Read the token's state and branch on `migrated`. The simplest source is `BagsLens` (see [Read State](/robinhood/read-state)):

```typescript theme={null}
import { publicClient } from "./clients";
import { ROBINHOOD_LAUNCHPAD } from "./addresses";
import { bagsLensAbi } from "./abi";

const state = await publicClient.readContract({
  address: ROBINHOOD_LAUNCHPAD.lens,
  abi: bagsLensAbi,
  functionName: "getTokenState",
  args: [token],
});

if (!state.exists) throw new Error("Not a Bags token");

if (state.migrated) {
  // Uniswap v4 pool — see "Trade after graduation"
} else {
  // Bonding curve at state.curve — see "Trade on the bonding curve"
}
```

<Warning>
  A buy that completes the bonding curve graduates the token **in the same transaction**. After any curve buy, re-read `migrated` (or check for the `Migrated` event in the receipt) before the next trade so you don't send a curve call to a paused curve.
</Warning>

## 2. Slippage Helper

Every trade below derives `minOut` from a **fresh** on-chain quote taken immediately before signing, with slippage applied. Use pure integer math:

```typescript slippage.ts theme={null}
const BPS = 10_000n;

/** amount * (10000 - slippageBps) / 10000, rounded down. Clamps bps to [0, 10000]. */
export function applySlippage(amount: bigint, slippageBps: number): bigint {
  const clamped = BigInt(Math.min(Math.max(Math.round(slippageBps), 0), 10_000));
  const minOut = (amount * (BPS - clamped)) / BPS;
  if (minOut <= 0n) throw new Error("Amount too small to trade safely.");
  return minOut;
}
```

<Note>
  Take the quote right before the swap — not from a stale polled value. Approvals and block time can move reserves enough to trip slippage otherwise.
</Note>

## 3. Trade on the Bonding Curve

Before graduation, trade directly against `state.curve`.

### Buy (ETH to token)

Quote with `quoteBuy`, then call `buy` with native ETH as `value`:

```typescript curve-buy.ts theme={null}
import { publicClient, getWalletClient } from "./clients";
import { bagsBondingCurveAbi } from "./abi";
import { applySlippage } from "./slippage";
import { parseEventLogs, type Address } from "viem";

export async function buyOnCurve(curve: Address, ethInWei: bigint, slippageBps: number) {
  const walletClient = getWalletClient();

  // quoteBuy returns: tokensOut, feeQuote, netQuoteIn, grossUsed, refundQuote
  const [tokensOut, , , grossUsed, refundQuote] = await publicClient.readContract({
    address: curve,
    abi: bagsBondingCurveAbi,
    functionName: "quoteBuy",
    args: [ethInWei],
  });
  if (tokensOut <= 0n) throw new Error("Buy quote unavailable.");

  // refundQuote > 0 means this buy completes the curve: only `grossUsed` of your
  // ETH is spent, the rest is refunded, and the token graduates.
  if (refundQuote > 0n) {
    console.log(`This buy completes the curve. Only ${grossUsed} wei will be used; the rest is refunded.`);
  }

  const minTokensOut = applySlippage(tokensOut, slippageBps);

  const { request } = await publicClient.simulateContract({
    account: walletClient.account,
    address: curve,
    abi: bagsBondingCurveAbi,
    functionName: "buy",
    args: [minTokensOut],
    value: ethInWei,
  });
  const txHash = await walletClient.writeContract(request);
  const receipt = await publicClient.waitForTransactionReceipt({ hash: txHash });
  if (receipt.status !== "success") throw new Error("Buy reverted.");

  const migrated = parseEventLogs({ abi: bagsBondingCurveAbi, logs: receipt.logs, eventName: "Migrated" }).length > 0;
  return { txHash, migrated };
}
```

<Note>
  `buyFor(recipient, minTokensOut)` is also available if you want the tokens delivered to a different address.
</Note>

### Sell (token to ETH)

Curve sells pull tokens via a plain ERC-20 `transferFrom`, so you must **approve the curve** first (a one-time `maxUint256` approval is convenient). Then quote with `quoteSell` and call `sell`:

```typescript curve-sell.ts theme={null}
import { publicClient, getWalletClient } from "./clients";
import { bagsBondingCurveAbi, bagsTokenAbi } from "./abi";
import { applySlippage } from "./slippage";
import { maxUint256, type Address } from "viem";

export async function sellOnCurve(token: Address, curve: Address, tokensInWei: bigint, slippageBps: number) {
  const walletClient = getWalletClient();
  const owner = walletClient.account.address;

  // Approve the curve once if the allowance is short (plain ERC-20 — NOT Permit2).
  const allowance = await publicClient.readContract({
    address: token,
    abi: bagsTokenAbi,
    functionName: "allowance",
    args: [owner, curve],
  });
  if (allowance < tokensInWei) {
    const { request } = await publicClient.simulateContract({
      account: walletClient.account,
      address: token,
      abi: bagsTokenAbi,
      functionName: "approve",
      args: [curve, maxUint256],
    });
    const approveTx = await walletClient.writeContract(request);
    await publicClient.waitForTransactionReceipt({ hash: approveTx });
  }

  // Quote AFTER approval so minOut reflects current reserves.
  // quoteSell returns: quoteToSeller, feeQuote, grossQuoteOut
  const [quoteToSeller] = await publicClient.readContract({
    address: curve,
    abi: bagsBondingCurveAbi,
    functionName: "quoteSell",
    args: [tokensInWei],
  });
  if (quoteToSeller <= 0n) throw new Error("Sell quote unavailable.");

  const minQuoteOut = applySlippage(quoteToSeller, slippageBps);
  const { request } = await publicClient.simulateContract({
    account: walletClient.account,
    address: curve,
    abi: bagsBondingCurveAbi,
    functionName: "sell",
    args: [tokensInWei, minQuoteOut],
  });
  const txHash = await walletClient.writeContract(request);
  const receipt = await publicClient.waitForTransactionReceipt({ hash: txHash });
  if (receipt.status !== "success") throw new Error("Sell reverted.");
  return { txHash };
}
```

Proceeds are paid as native ETH. `sellFor(recipient, tokensIn, minQuoteOut)` delivers proceeds to another address.

<Note>
  `BagsToken` supports [EIP-2612](https://eips.ethereum.org/EIPS/eip-2612) `permit`, so instead of a separate `approve` transaction you can have the seller sign a permit off-chain and submit the allowance gaslessly (or bundle permit + sell via multicall infrastructure) for a one-transaction sell UX.
</Note>

## 4. Trade After Graduation (Uniswap v4)

After migration, the token trades in a Uniswap v4 pool paired with **WETH**. Swaps go through the Robinhood-**modified** UniversalRouter.

<Warning>
  This router is a fork. Its v4 swap struct has an extra `uint256 minHopPriceX36` field (set it to `0`), so **stock Uniswap SDK calldata reverts** — you must encode the calldata manually as shown below. Only the router at `0x8876...0904` is correct.
</Warning>

Key facts for the pool phase:

* The pool pairs the token with **WETH**, not native ETH. To buy you need a sufficient **WETH** balance — wrap only the shortfall (the amount your wallet is missing), not the full input, since it may already hold some WETH. To receive native ETH after a sell you **unwrap WETH**.
* The router spends your ERC-20 input through **Permit2**, so you must set up a two-leg Permit2 route once.
* Swaps are **exact-in only** — the Bags hook reverts exact-out WETH by design.
* Quote amounts from `V4Quoter` **already include the 2% hook fee**; apply slippage only, never subtract the fee again.

### 4a. Periphery ABIs

These infrastructure contracts aren't part of the Bags ABI export. Save the minimal fragments as `abi/periphery.ts`:

```typescript abi/periphery.ts theme={null}
export const universalRouterAbi = [
  {
    type: "function",
    name: "execute",
    inputs: [
      { name: "commands", type: "bytes" },
      { name: "inputs", type: "bytes[]" },
      { name: "deadline", type: "uint256" },
    ],
    outputs: [],
    stateMutability: "payable",
  },
] as const;

export const permit2Abi = [
  {
    type: "function",
    name: "approve",
    inputs: [
      { name: "token", type: "address" },
      { name: "spender", type: "address" },
      { name: "amount", type: "uint160" },
      { name: "expiration", type: "uint48" },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "allowance",
    inputs: [
      { name: "owner", type: "address" },
      { name: "token", type: "address" },
      { name: "spender", type: "address" },
    ],
    outputs: [
      { name: "amount", type: "uint160" },
      { name: "expiration", type: "uint48" },
      { name: "nonce", type: "uint48" },
    ],
    stateMutability: "view",
  },
] as const;

export const v4QuoterAbi = [
  {
    type: "function",
    name: "quoteExactInputSingle",
    inputs: [
      {
        name: "params",
        type: "tuple",
        components: [
          {
            name: "poolKey",
            type: "tuple",
            components: [
              { name: "currency0", type: "address" },
              { name: "currency1", type: "address" },
              { name: "fee", type: "uint24" },
              { name: "tickSpacing", type: "int24" },
              { name: "hooks", type: "address" },
            ],
          },
          { name: "zeroForOne", type: "bool" },
          { name: "exactAmount", type: "uint128" },
          { name: "hookData", type: "bytes" },
        ],
      },
    ],
    outputs: [
      { name: "amountOut", type: "uint256" },
      { name: "gasEstimate", type: "uint256" },
    ],
    stateMutability: "nonpayable",
  },
] as const;

/** aeWETH proxy — WETH9-compatible interface (never rely on bytecode/codehash). */
export const wethAbi = [
  { type: "function", name: "deposit", inputs: [], outputs: [], stateMutability: "payable" },
  { type: "function", name: "withdraw", inputs: [{ name: "amount", type: "uint256" }], outputs: [], stateMutability: "nonpayable" },
  {
    type: "function",
    name: "approve",
    inputs: [
      { name: "spender", type: "address" },
      { name: "amount", type: "uint256" },
    ],
    outputs: [{ name: "", type: "bool" }],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "balanceOf",
    inputs: [{ name: "account", type: "address" }],
    outputs: [{ name: "", type: "uint256" }],
    stateMutability: "view",
  },
] as const;
```

### 4b. Pool key and swap direction

The pool is identified by a v4 `PoolKey`. It must match the factory's derivation exactly. Save as `poolKey.ts`:

```typescript poolKey.ts theme={null}
import { getAddress, type Address } from "viem";
import { ROBINHOOD_LAUNCHPAD, ROBINHOOD_POOL } from "./addresses";

/** True when the token sorts below WETH and is therefore currency0. */
export function isTokenCurrency0(token: Address): boolean {
  return BigInt(token) < BigInt(ROBINHOOD_LAUNCHPAD.weth);
}

/** The v4 PoolKey the factory creates for a Bags token (token/WETH, dynamic fee, Bags hook). */
export function bagsPoolKey(token: Address) {
  const tokenAddress = getAddress(token);
  const weth = getAddress(ROBINHOOD_LAUNCHPAD.weth);
  const tokenIs0 = isTokenCurrency0(tokenAddress);
  return {
    currency0: tokenIs0 ? tokenAddress : weth,
    currency1: tokenIs0 ? weth : tokenAddress,
    fee: ROBINHOOD_POOL.dynamicFeeFlag,
    tickSpacing: ROBINHOOD_POOL.tickSpacing,
    hooks: getAddress(ROBINHOOD_LAUNCHPAD.hook),
  };
}

/** Buy = WETH -> token, sell = token -> WETH. zeroForOne is true when the INPUT is currency0. */
export function directionFor(token: Address, side: "buy" | "sell"): { zeroForOne: boolean } {
  const tokenIs0 = isTokenCurrency0(token);
  return { zeroForOne: side === "buy" ? !tokenIs0 : tokenIs0 };
}
```

### 4c. Quote a pool swap

`V4Quoter.quoteExactInputSingle` is **not** a view function — call it through `simulateContract`. The returned amount already accounts for the 2% hook fee.

```typescript pool-quote.ts theme={null}
import { publicClient } from "./clients";
import { ROBINHOOD_LAUNCHPAD } from "./addresses";
import { v4QuoterAbi } from "./abi/periphery";
import { bagsPoolKey, directionFor } from "./poolKey";
import type { Address } from "viem";

export async function quotePoolExactIn(token: Address, side: "buy" | "sell", amountIn: bigint) {
  try {
    const { result } = await publicClient.simulateContract({
      address: ROBINHOOD_LAUNCHPAD.v4Quoter,
      abi: v4QuoterAbi,
      functionName: "quoteExactInputSingle",
      args: [
        {
          poolKey: bagsPoolKey(token),
          zeroForOne: directionFor(token, side).zeroForOne,
          exactAmount: amountIn,
          hookData: "0x",
        },
      ],
    });
    return result[0]; // amountOut
  } catch {
    return null; // no quote — treat as unavailable, never as 0
  }
}
```

### 4d. Wrap ETH and set up the Permit2 route

To buy, wrap the ETH you're about to spend; to swap any ERC-20 through the router, ensure the two-leg Permit2 route (`ERC-20 -> Permit2`, then `Permit2 -> router`).

```typescript permit2.ts theme={null}
import { erc20Abi, maxUint160, maxUint256, type Address } from "viem";
import { publicClient, getWalletClient } from "./clients";
import { ROBINHOOD_LAUNCHPAD } from "./addresses";
import { permit2Abi, wethAbi } from "./abi/periphery";

const PERMIT2_EXPIRY_SECONDS = 30 * 24 * 3600;

export async function wrapEth(amountWei: bigint) {
  const walletClient = getWalletClient();
  const { request } = await publicClient.simulateContract({
    account: walletClient.account,
    address: ROBINHOOD_LAUNCHPAD.weth,
    abi: wethAbi,
    functionName: "deposit",
    value: amountWei,
  });
  const txHash = await walletClient.writeContract(request);
  await publicClient.waitForTransactionReceipt({ hash: txHash });
  return txHash;
}

/** Ensure the router can pull `amountIn` of `inputToken` via Permit2. Runs at most two one-time approvals. */
export async function ensurePermit2Route(inputToken: Address, amountIn: bigint) {
  const walletClient = getWalletClient();
  const owner = walletClient.account.address;

  const [erc20ToPermit2, permit2Allowance] = await Promise.all([
    publicClient.readContract({ address: inputToken, abi: erc20Abi, functionName: "allowance", args: [owner, ROBINHOOD_LAUNCHPAD.permit2] }),
    publicClient.readContract({ address: ROBINHOOD_LAUNCHPAD.permit2, abi: permit2Abi, functionName: "allowance", args: [owner, inputToken, ROBINHOOD_LAUNCHPAD.universalRouter] }),
  ]);
  const [permit2Amount, permit2Expiration] = permit2Allowance;

  // Leg 1: ERC-20 -> Permit2
  if (erc20ToPermit2 < amountIn) {
    const { request } = await publicClient.simulateContract({
      account: walletClient.account, address: inputToken, abi: erc20Abi,
      functionName: "approve", args: [ROBINHOOD_LAUNCHPAD.permit2, maxUint256],
    });
    await publicClient.waitForTransactionReceipt({ hash: await walletClient.writeContract(request) });
  }

  // Leg 2: Permit2 -> router (amount is uint160; expiration is uint48)
  const nowSec = Math.floor(Date.now() / 1000);
  if (permit2Amount < amountIn || permit2Expiration <= nowSec) {
    const { request } = await publicClient.simulateContract({
      account: walletClient.account, address: ROBINHOOD_LAUNCHPAD.permit2, abi: permit2Abi,
      functionName: "approve", args: [inputToken, ROBINHOOD_LAUNCHPAD.universalRouter, maxUint160, nowSec + PERMIT2_EXPIRY_SECONDS],
    });
    await publicClient.waitForTransactionReceipt({ hash: await walletClient.writeContract(request) });
  }
}
```

### 4e. Execute the swap

Encode the modified router calldata manually: command `V4_SWAP (0x10)`, actions `[SWAP_EXACT_IN_SINGLE (0x06), SETTLE_ALL (0x0c), TAKE_ALL (0x0f)]`, with the extra `minHopPriceX36` set to `0`.

```typescript pool-swap.ts theme={null}
import { encodeAbiParameters, encodePacked, type Address, type Hex } from "viem";
import { publicClient, getWalletClient } from "./clients";
import { ROBINHOOD_LAUNCHPAD } from "./addresses";
import { universalRouterAbi } from "./abi/periphery";
import { bagsPoolKey, directionFor } from "./poolKey";

const V4_SWAP_COMMAND: Hex = "0x10";
const V4_ACTIONS = encodePacked(["uint8", "uint8", "uint8"], [0x06, 0x0c, 0x0f]);
const ROUTER_DEADLINE_SECONDS = 300;

/** Post-migration exact-in swap. Input is ALWAYS an ERC-20 (WETH for buys, the token for sells). */
export async function swapV4ExactIn(token: Address, side: "buy" | "sell", amountIn: bigint, minAmountOut: bigint) {
  const walletClient = getWalletClient();
  const poolKey = bagsPoolKey(token);
  const { zeroForOne } = directionFor(token, side);
  const inputCurrency: Address = side === "buy" ? ROBINHOOD_LAUNCHPAD.weth : token;
  const outputCurrency: Address = side === "buy" ? token : ROBINHOOD_LAUNCHPAD.weth;

  const swapParams = encodeAbiParameters(
    [
      {
        type: "tuple",
        components: [
          {
            name: "poolKey", type: "tuple",
            components: [
              { name: "currency0", type: "address" },
              { name: "currency1", type: "address" },
              { name: "fee", type: "uint24" },
              { name: "tickSpacing", type: "int24" },
              { name: "hooks", type: "address" },
            ],
          },
          { name: "zeroForOne", type: "bool" },
          { name: "amountIn", type: "uint128" },
          { name: "amountOutMinimum", type: "uint128" },
          // Robinhood-only field vs vanilla Uniswap — always 0 (disabled).
          { name: "minHopPriceX36", type: "uint256" },
          { name: "hookData", type: "bytes" },
        ],
      },
    ],
    [{ poolKey, zeroForOne, amountIn, amountOutMinimum: minAmountOut, minHopPriceX36: 0n, hookData: "0x" }]
  );
  const settleAll = encodeAbiParameters([{ type: "address" }, { type: "uint256" }], [inputCurrency, amountIn]);
  const takeAll = encodeAbiParameters([{ type: "address" }, { type: "uint256" }], [outputCurrency, minAmountOut]);
  const routerInput = encodeAbiParameters([{ type: "bytes" }, { type: "bytes[]" }], [V4_ACTIONS, [swapParams, settleAll, takeAll]]);

  // Deadline uses a timestamp — block numbers are unreliable on this Orbit chain.
  const deadline = BigInt(Math.floor(Date.now() / 1000) + ROUTER_DEADLINE_SECONDS);
  const { request } = await publicClient.simulateContract({
    account: walletClient.account,
    address: ROBINHOOD_LAUNCHPAD.universalRouter,
    abi: universalRouterAbi,
    functionName: "execute",
    args: [V4_SWAP_COMMAND, [routerInput], deadline],
  });
  const txHash = await walletClient.writeContract(request);
  const receipt = await publicClient.waitForTransactionReceipt({ hash: txHash });
  if (receipt.status !== "success") throw new Error("Swap reverted.");
  return { txHash };
}
```

### 4f. Full pool buy and sell

Compose the helpers. A **buy** wraps ETH, ensures the WETH route, quotes, then swaps. A **sell** ensures the token route, quotes, swaps, then unwraps the WETH proceeds back to native ETH.

```typescript pool-trade.ts theme={null}
import { getWalletClient, publicClient } from "./clients";
import { ROBINHOOD_LAUNCHPAD } from "./addresses";
import { wethAbi } from "./abi/periphery";
import { applySlippage } from "./slippage";
import { quotePoolExactIn } from "./pool-quote";
import { swapV4ExactIn } from "./pool-swap";
import { wrapEth, ensurePermit2Route } from "./permit2";
import type { Address } from "viem";

export async function buyPool(token: Address, ethInWei: bigint, slippageBps: number) {
  const walletClient = getWalletClient();
  const owner = walletClient.account.address;

  // Wrap only the shortfall — the wallet may already hold some WETH. Wrapping the
  // full amount unconditionally reverts when native ETH is below ethInWei.
  const wethBalance = await publicClient.readContract({
    address: ROBINHOOD_LAUNCHPAD.weth, abi: wethAbi, functionName: "balanceOf", args: [owner],
  });
  const wrapAmount = ethInWei > wethBalance ? ethInWei - wethBalance : 0n;
  if (wrapAmount > 0n) await wrapEth(wrapAmount);
  await ensurePermit2Route(ROBINHOOD_LAUNCHPAD.weth, ethInWei);

  const amountOut = await quotePoolExactIn(token, "buy", ethInWei);
  if (!amountOut || amountOut <= 0n) throw new Error("Swap quote unavailable.");

  return swapV4ExactIn(token, "buy", ethInWei, applySlippage(amountOut, slippageBps));
}

export async function sellPool(token: Address, tokensInWei: bigint, slippageBps: number) {
  const walletClient = getWalletClient();
  const owner = walletClient.account.address;

  await ensurePermit2Route(token, tokensInWei);

  const amountOut = await quotePoolExactIn(token, "sell", tokensInWei);
  if (!amountOut || amountOut <= 0n) throw new Error("Swap quote unavailable.");

  // Snapshot WETH before the swap so we only unwrap the proceeds.
  const wethBefore = await publicClient.readContract({
    address: ROBINHOOD_LAUNCHPAD.weth, abi: wethAbi, functionName: "balanceOf", args: [owner],
  });

  const swap = await swapV4ExactIn(token, "sell", tokensInWei, applySlippage(amountOut, slippageBps));

  // Unwrap the WETH gained into native ETH (optional convenience step).
  const wethAfter = await publicClient.readContract({
    address: ROBINHOOD_LAUNCHPAD.weth, abi: wethAbi, functionName: "balanceOf", args: [owner],
  });
  const delta = wethAfter - wethBefore;
  if (delta > 0n) {
    const { request } = await publicClient.simulateContract({
      account: walletClient.account, address: ROBINHOOD_LAUNCHPAD.weth, abi: wethAbi,
      functionName: "withdraw", args: [delta],
    });
    await publicClient.waitForTransactionReceipt({ hash: await walletClient.writeContract(request) });
  }
  return swap;
}
```

<Note>
  The unwrap is a secondary convenience transaction — the sale itself is already final once the swap confirms. If unwrapping fails, your proceeds are simply held as WETH and can be unwrapped or reused later.
</Note>

## 5. Understanding Fees and Quotes

* The 2% fee applies in **both** phases. On the curve, `quoteBuy`/`quoteSell` return fee-adjusted amounts (`tokensOut` / `quoteToSeller` are what you actually receive). In the pool, `V4Quoter` output already includes the hook fee.
* `quoteBuy` returns `refundQuote > 0` when a buy would cross graduation — only `grossUsed` is spent and the rest is refunded. Surface this to users.
* Distinguish a **failed** quote (RPC error / revert) from a **zero** quote. Treat a failure as "no quote" and disable trading; never coerce it to `0` (that would send an unprotected `minOut = 0`).

## Troubleshooting

* **`BagsBondingCurve_SlippageExceeded(minExpected, actualOut)`** — reserves moved between quote and execution. Re-quote immediately before signing and/or raise slippage.
* **`BagsBondingCurve_AlreadyMigrated` / `EnforcedPause`** — the token graduated; switch to the pool path.
* **Pool swap reverts with stock SDK calldata** — you must include the `minHopPriceX36` field (set `0`) and encode manually, as in section 4e. The correct router is `0x8876...0904`.
* **Router pulls nothing / transfer fails** — the Permit2 route isn't set up. Run `ensurePermit2Route` for the input token first (WETH for buys, the token for sells) and wait for the approvals to confirm.
* **Exact-out WETH reverts (`BagsV4Hook_ExactOutputWETHSpecifiedUnsupported`)** — unsupported by design. Always swap exact-in.

For the full function, event, and error catalog, see the [Contracts Reference](/robinhood/contracts).
