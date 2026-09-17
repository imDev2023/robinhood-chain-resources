# Integrate QUOTRON swaps

QUOTRON's production swap API is a verified smart contract. There is no API
key. Aggregators should `eth_call` the view quoter with `(amount, payer)`.
That returns output and the payer's hook fee without the payer holding ETH,
QUOTRON, or a router allowance. Execution still goes through the canonical
router; apply a user-approved slippage minimum before submitting.

## Live deployment

| Item | Value |
| --- | --- |
| Network | Robinhood Chain |
| Chain ID | `4663` |
| RPC | `https://rpc.mainnet.chain.robinhood.com` |
| QUOTRON | `0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F` |
| Canonical router | `0x42024fCFdB4F3089Dd619A0cEF0Cd24E7b841C18` |
| Canonical hook | `0x62E200Cc8e4D95cf622f40Dd70f407C883EcB0cc` |
| View quoter | `0xb8960fdC8A0Be155d196C2795b75747763562df2` |
| WETH | `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73` |
| Pool ID | `0x0b142aaf734f1b063355bfe854e282a13b26dcac86e2e564e74540f9b218d069` |

ETH and QUOTRON use 18 decimals.

Machine-readable resources:

- [Integration manifest](/integration/manifest.json)
- [Router ABI](/integration/QuotronWethRouter.abi.json)
- [QUOTRON ABI](/integration/Quotron404V2.abi.json)
- [Hook ABI](/integration/QuotronWethHook.abi.json)
- [Quoter ABI](/integration/QuotronWethQuoter.abi.json)
- [Full project reference](/llms-full.txt)

## Why this route is canonical

The official QUOTRON/WETH v4 pool is intentionally bound to one router. The
router supplies payer and recipient context to the hook, and the token accepts
PoolManager settlement only when the hook authorizes that exact amount during
the same swap.

That path protects the WETH fee engine funding hardwired Terminal NFT rewards,
the STONK BROKERS burn, locked liquidity, and the creator carve. Integrators
call the router; they do not call PoolManager or construct hook data.

This guarantee is scoped to canonical v4 settlement. Ordinary ERC-20 transfers
remain possible, so it is not a claim that every future custom contract or
non-v4 venue is impossible.

## Router API

```solidity
function buyExactEth(
    uint256 minQuotronOut,
    address recipient,
    uint256 deadline
) external payable returns (uint256 quotronOut);

function buyExactQuotron(
    uint256 quotronOut,
    address recipient,
    uint256 deadline
) external payable returns (uint256 wethSpent);

function sellExactQuotronForEth(
    uint256 quotronIn,
    uint256 minEthOut,
    address recipient,
    uint256 deadline
) external returns (uint256 ethOut);
```

`deadline` is Unix time in seconds. `recipient` must be nonzero. Exact-output
buys revert if the payer's current fee is 50% or higher.

## View quoter

The sealed router cannot grow a `quote` function, and wrapping it would price
fees for the wrapper instead of `payer`. `QuotronWethQuoter` is a separate
read-only contract bound to the live router. It does not change the hook.

```solidity
function quoteBuyExactEth(uint256 ethIn, address payer)
    external view
    returns (uint256 quotronOut, uint256 feeBps, uint256 feeWeth, uint256 poolWethIn);

function quoteSellExactQuotron(uint256 quotronIn, address payer)
    external view
    returns (uint256 ethOut, uint256 feeBps, uint256 feeWeth, uint256 poolWethOut);

function quoteBuyExactQuotron(uint256 quotronOut, address payer)
    external view
    returns (uint256 ethIn, uint256 feeBps, uint256 feeWeth, uint256 poolWethIn);
```

`payer` is the wallet that will call the router. The quoter reads
`hook.currentFeeBps(payer)`, applies the same gross/net WETH carve the hook
uses, then runs Uniswap v4 swap math on the remaining pool amount with the
hook's 0 LP-fee override.

```ts
const QUOTER = "0xb8960fdC8A0Be155d196C2795b75747763562df2";
const quoterAbi = await fetch(
  "https://quotrons.cash/integration/QuotronWethQuoter.abi.json",
).then((response) => response.json());

const [quotronOut, feeBps, feeWeth] = await publicClient.readContract({
  address: QUOTER,
  abi: quoterAbi,
  functionName: "quoteBuyExactEth",
  args: [ethIn, account],
});
```

A sell quote does not need an approval. Still approve the router before
submitting `sellExactQuotronForEth`. Simulating the exact router call remains
a valid execution check when the payer is funded.

## Buy: quote, apply slippage, execute

The example uses viem and an injected wallet. Use `1n` only for simulation;
never submit a production swap with a placeholder minimum.

```ts
import {
  createPublicClient,
  createWalletClient,
  custom,
  http,
  parseEther,
} from "viem";

const chain = {
  id: 4663,
  name: "Robinhood Chain",
  nativeCurrency: { name: "Ether", symbol: "ETH", decimals: 18 },
  rpcUrls: {
    default: { http: ["https://rpc.mainnet.chain.robinhood.com"] },
  },
} as const;

const ROUTER = "0x42024fCFdB4F3089Dd619A0cEF0Cd24E7b841C18";
const routerAbi = await fetch(
  "https://quotrons.cash/integration/QuotronWethRouter.abi.json",
).then((response) => response.json());

const [account] = await window.ethereum.request({
  method: "eth_requestAccounts",
});
const publicClient = createPublicClient({ chain, transport: http() });
const walletClient = createWalletClient({
  account,
  chain,
  transport: custom(window.ethereum),
});

const ethIn = parseEther("0.1");
const deadline = BigInt(Math.floor(Date.now() / 1000) + 20 * 60);
const quote = await publicClient.simulateContract({
  account,
  address: ROUTER,
  abi: routerAbi,
  functionName: "buyExactEth",
  args: [1n, account, deadline],
  value: ethIn,
});

const slippageBps = 500n; // user-selected 5%
const minOut = (quote.result * (10000n - slippageBps)) / 10000n;
if (minOut === 0n) throw new Error("minimum output is zero");

const hash = await walletClient.writeContract({
  account,
  address: ROUTER,
  abi: routerAbi,
  functionName: "buyExactEth",
  args: [minOut, account, deadline],
  value: ethIn,
});
```

## Sell: approve, quote, execute

The canonical router pulls QUOTRON from its caller. Approve only the sale
amount and wait for the approval receipt before simulating the sell.

```ts
import { parseEther } from "viem";

const QUOTRON = "0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F";
const tokenAbi = await fetch(
  "https://quotrons.cash/integration/Quotron404V2.abi.json",
).then((response) => response.json());
const quotronIn = parseEther("1");

const approvalHash = await walletClient.writeContract({
  account,
  address: QUOTRON,
  abi: tokenAbi,
  functionName: "approve",
  args: [ROUTER, quotronIn],
});
await publicClient.waitForTransactionReceipt({ hash: approvalHash });

const sellDeadline = BigInt(Math.floor(Date.now() / 1000) + 20 * 60);
const quote = await publicClient.simulateContract({
  account,
  address: ROUTER,
  abi: routerAbi,
  functionName: "sellExactQuotronForEth",
  args: [quotronIn, 1n, account, sellDeadline],
});

const minEthOut = (quote.result * (10000n - slippageBps)) / 10000n;
if (minEthOut === 0n) throw new Error("minimum output is zero");

const sellHash = await walletClient.writeContract({
  account,
  address: ROUTER,
  abi: routerAbi,
  functionName: "sellExactQuotronForEth",
  args: [quotronIn, minEthOut, account, sellDeadline],
});
```

## Executor and aggregator contracts

The connected wallet should call the canonical router directly whenever
possible. If an executor contract calls it, that executor becomes the payer.

- On buys, the executor supplies ETH and can name the user as recipient, but
  the executor's onchain fee tier applies.
- On sells, the executor must hold QUOTRON and approve the router.
- Moving whole QUOTRON units through a non-exempt executor can materialize or
  dissolve ERC-404 Terminal NFTs.

Test the exact executor path on a fork before advertising support.

## Required preflight

1. Require chain ID `4663`.
2. Read `Quotron404V2.isLaunched()` and `paused()`.
3. Read `QuotronWethHook.paused()` and `currentFeeBps(payer)`.
4. Quote with `QuotronWethQuoter` using the actual payer address.
5. For sells, read `isTransferRestricted(payer)`, balance, and allowance.
6. Display input, quote, fee tier, slippage, and minimum output.
7. Estimate gas from the exact call. Whole-unit transitions may create or
   dissolve Terminal NFTs and increase gas use.
8. Submit only after explicit user approval.

If simulation reverts, do not send the transaction.

Support and verified addresses: [quotrons.cash/docs](https://quotrons.cash/docs)
