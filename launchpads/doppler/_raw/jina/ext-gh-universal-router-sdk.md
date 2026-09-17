Title: sdks/sdks/universal-router-sdk at main · Uniswap/sdks

URL Source: https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk

Markdown Content:
This SDK facilitates interactions with the contracts in [Universal Router](https://github.com/Uniswap/universal-router)

## Usage

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#usage)
Install latest version of universal-router-sdk. Then import the corresponding Trade class and Data object for each protocol you'd like to interact with.

### Trading on Uniswap

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#trading-on-uniswap)
warning: `swapERC20CallParameters()` to be deprecated in favor of `swapCallParameters()`

import { TradeType } from '@uniswap/sdk-core'
import { Trade as V2TradeSDK } from '@uniswap/v2-sdk'
import { Trade as V3TradeSDK } from '@uniswap/v3-sdk'
import { MixedRouteTrade, MixedRouteSDK, Trade as RouterTrade } from '@uniswap/router-sdk'

const options = { slippageTolerance, recipient }
const routerTrade = new RouterTrade({ v2Routes, v3Routes, mixedRoutes, tradeType: TradeType.EXACT_INPUT })
// Use the raw calldata and value returned to call into Universal Swap Router contracts
const { calldata, value } = SwapRouter.swapCallParameters(routerTrade, options)

This SDK has two entry points for encoding swap calldata:

*   **`SwapRouter.swapCallParameters(trade, options)`** — builds calldata from a high-level `RouterTrade` (shown above). Best when your swap fits as one or more independent linear routes through pools.
*   **`SwapRouter.encodeSwaps(spec, swapSteps)`** — takes Universal Router commands directly, with the SDK adding ingress, fee, and settlement calldata around them. Best for topologies that don't fit a Trade, routing-service integrations, or advanced V4 compositions. See [Encoding Router-Provided Swap Steps](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#encoding-router-provided-swap-steps-encodeswaps).

## Running this package

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#running-this-package)
Make sure you are running `node v18` Install dependencies and run typescript unit tests

yarn install
yarn test:hardhat

Run forge integration tests

forge install
yarn test:forge

## Encoding Router-Provided Swap Steps (`encodeSwaps`)

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#encoding-router-provided-swap-steps-encodeswaps)
`SwapRouter.encodeSwaps(spec, swapSteps)` is an alternative entry point for callers that already produce explicit `SwapStep[]` plans (e.g. routing services) and want the SDK to wrap them in a safety envelope. It decouples route topology from SDK trade construction.

The router owns `swapSteps` (V2/V3/V4 swaps + any `WRAP_ETH` / `UNWRAP_WETH`). The SDK owns ingress, fees, final settlement, exact-output refund, and optional `safeMode`.

### Swap Step Types

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#swap-step-types)
Each `SwapStep` is a 1:1 representation of a Universal Router command:

*   `V2_SWAP_EXACT_IN` / `V2_SWAP_EXACT_OUT` — V2 swap (multi-hop via `path: address[]`)
*   `V3_SWAP_EXACT_IN` / `V3_SWAP_EXACT_OUT` — V3 swap (multi-hop via packed `path: bytes`)
*   `V4_SWAP` — wraps a sequence of V4 actions (`SWAP_EXACT_IN`, `SETTLE`, `TAKE`, etc.) for the V4 router module
*   `WRAP_ETH` / `UNWRAP_WETH` — required when the route bridges native ETH and WETH

Routers compose these to express any supported route topology. The SDK does not infer wrap/unwrap commands — routers must include them when their route depends on it.

### Basic Usage

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#basic-usage)

import { SwapRouter, ROUTER_AS_RECIPIENT } from '@uniswap/universal-router-sdk'
import { CurrencyAmount, Percent, TradeType } from '@uniswap/sdk-core'

const { calldata, value } = SwapRouter.encodeSwaps(
  {
    tradeType: TradeType.EXACT_INPUT,
    routing: {
      inputToken: USDC,
      outputToken: WETH,
      amount: CurrencyAmount.fromRawAmount(USDC, '1000000000'),
      quote: CurrencyAmount.fromRawAmount(WETH, '500000000000000000'),
    },
    slippageTolerance: new Percent(50, 10000), // 0.5%
    recipient: '0x...',
  },
  [
    {
      type: 'V3_SWAP_EXACT_IN',
      recipient: ROUTER_AS_RECIPIENT,
      amountIn: '1000000000',
      amountOutMin: '0', // SDK enforces final slippage via the trailing SWEEP
      path: '0x...', // packed V3 path
    },
  ]
)

### What the SDK adds around `swapSteps`

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#what-the-sdk-adds-around-swapsteps)
1.   **Ingress**: `PERMIT2_TRANSFER_FROM` for ERC20 input, or `proxy.execute()` wrapping for `ApproveProxy`. Native input flows through `msg.value`.
2.   **Fee deduction** before settlement: portion (`PAY_PORTION` / `PAY_PORTION_FULL_PRECISION`) on exact-input, flat (`TRANSFER`) on exact-output.
3.   **Final SWEEP** of `outputToken` to recipient with the slippage-bounded floor.
4.   **Exact-output refund**: SWEEPs unused input back to recipient.
5.   **safeMode** (optional): trailing zero-min ETH SWEEP to recover dust or unintended `msg.value`.

### Constraints

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#constraints)
*   By default, all swap step recipients must be `ROUTER_AS_RECIPIENT` and `payerIsUser` is `false` (ingress runs once up-front via `PERMIT2_TRANSFER_FROM`) — the SDK's settlement sweeps need router custody to see the funds. The optional `allowDirectTransfers` regime relaxes both (see [Direct Transfers](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#direct-transfers-allowdirecttransfers)).
*   Routers must end with output in `routing.outputToken`. For exact-output, unused input must end in `routing.inputToken`.
*   The final top-level `SWEEP` is appended by the SDK — don't include it in `swapSteps`.

### Direct Transfers (`allowDirectTransfers`)

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#direct-transfers-allowdirecttransfers)
By default every transfer routes through router custody. Setting `allowDirectTransfers: true` on the spec lets routing-supplied steps move funds directly between the user and the pools — pulling input straight from the user (`payerIsUser` on V2/V3 swaps and v4 `SETTLE`) and paying output straight to `recipient` — which removes the Permit2 ingress and the final sweep transfer for a simple swap.

The safety contract is unchanged (the user pays at most `exactOrMaxAmountIn`; the recipient receives at least the slippage-bounded minimum), but it's enforced by counting instead of custody:

*   **Inbound budget** — contract-enforced direct pulls must sum within `exactOrMaxAmountIn`; the SDK ingress pulls only the remainder.
*   **Outbound coverage** — contract-enforced direct-output minimums reduce the final `SWEEP` floor. Since independently-floored per-leg minimums can sum a few wei below the trade minimum, the floor forgives a bounded, sub-economic rounding shortfall (`max(min(0.5bps of the minimum, 1% of slippage), a small per-leg allowance)`, zero at zero slippage); a larger, real gap still reverts.

Step amounts are never trusted — only counted or capped.

### Per-Hop Slippage

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#per-hop-slippage)
Per-hop bounds require Universal Router v2.1.1+ — set `urVersion: UniversalRouterVersion.V2_1_1` on `spec` to enable.

`encodeSwaps` accepts per-hop bounds as `minHopPriceX36` on each swap step, matching the contract parameter name. The value is a 1e36-scaled price floor.

{
  type: 'V3_SWAP_EXACT_IN',
  // ...
  minHopPriceX36: ['995000000000000000000000000000000000', ...], // one per hop
}

## Signed Routes (Universal Router v2.1)

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#signed-routes-universal-router-v21)
Universal Router v2.1 supports EIP712-signed route execution, enabling gasless transactions and intent-based trading.

**Important**: The SDK does not perform signing. It provides utilities to prepare EIP712 payloads and encode signed calldata. You sign with your own mechanism (wallet, KMS, hardware, etc.).

### Basic Flow

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#basic-flow)

import { SwapRouter, NONCE_SKIP_CHECK } from '@uniswap/universal-router-sdk'
import { Wallet } from '@ethersproject/wallet'

const wallet = new Wallet('0x...')
const chainId = 1
const routerAddress = '0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD'
const deadline = Math.floor(Date.now() / 1000) + 60 * 20

// 1. Generate regular swap calldata
const { calldata, value } = SwapRouter.swapCallParameters(trade, {
  slippageTolerance: new Percent(50, 10000),
  recipient: wallet.address,
  deadline,
})

// 2. Get EIP712 payload to sign
const payload = SwapRouter.getExecuteSignedPayload(
  calldata,
  {
    intent: '0x' + '0'.repeat(64), // Application-specific intent
    data: '0x' + '0'.repeat(64), // Application-specific data
    sender: wallet.address, // Or address(0) to skip sender verification
  },
  deadline,
  chainId,
  routerAddress
)

// 3. Sign externally (wallet/KMS/hardware)
const signature = await wallet._signTypedData(payload.domain, payload.types, payload.value)

// 4. Encode for executeSigned()
const { calldata: signedCalldata, value: signedValue } = SwapRouter.encodeExecuteSigned(
  calldata,
  signature,
  {
    intent: payload.value.intent,
    data: payload.value.data,
    sender: payload.value.sender,
    nonce: payload.value.nonce, // Must match what was signed
  },
  deadline,
  BigNumber.from(value)
)

// 5. Submit transaction
await wallet.sendTransaction({
  to: routerAddress,
  data: signedCalldata,
  value: signedValue,
})

### Nonce Management

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#nonce-management)
*   **Random nonce (default)**: Omit `nonce` parameter - SDK generates random nonce
*   **Skip nonce check**: Use `NONCE_SKIP_CHECK` sentinel to allow signature reuse
*   **Custom nonce**: Provide your own nonce for ordering

import { NONCE_SKIP_CHECK } from '@uniswap/universal-router-sdk'

// Reusable signature (no nonce check)
const payload = SwapRouter.getExecuteSignedPayload(
  calldata,
  {
    intent: '0x...',
    data: '0x...',
    sender: '0x0000000000000000000000000000000000000000', // Skip sender verification too
    nonce: NONCE_SKIP_CHECK, // Allow signature reuse
  },
  deadline,
  chainId,
  routerAddress
)

### Sender Verification

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#sender-verification)
*   **Verify sender**: Pass the actual sender address (e.g., `wallet.address`)
*   **Skip verification**: Pass `'0x0000000000000000000000000000000000000000'`

The SDK automatically sets `verifySender` based on whether sender is address(0).

## Cross-Chain Bridging with Across (Universal Router v2.1)

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#cross-chain-bridging-with-across-universal-router-v21)
Universal Router v2.1 integrates with Across Protocol V3 to enable seamless cross-chain bridging after swaps. This allows you to swap tokens on one chain and automatically bridge them to another chain in a single transaction.

### Basic Usage

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#basic-usage-1)

import { SwapRouter } from '@uniswap/universal-router-sdk'
import { BigNumber } from 'ethers'

// 1. Prepare your swap (e.g., USDC → WETH on mainnet)
const { calldata, value } = SwapRouter.swapCallParameters(trade, swapOptions, [
  {
    // Bridge configuration
    depositor: userAddress,
    recipient: userAddress, // Recipient on destination chain
    inputToken: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', // WETH mainnet
    outputToken: '0x4200000000000000000000000000000000000006', // WETH optimism
    inputAmount: BigNumber.from('1000000000000000000'), // 1 WETH
    outputAmount: BigNumber.from('990000000000000000'), // 0.99 WETH (with fees)
    destinationChainId: 10, // Optimism
    exclusiveRelayer: '0x0000000000000000000000000000000000000000',
    quoteTimestamp: Math.floor(Date.now() / 1000),
    fillDeadline: Math.floor(Date.now() / 1000) + 3600,
    exclusivityDeadline: 0,
    message: '0x',
    useNative: false,
  },
])

### Swap + Bridge Example

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#swap--bridge-example)

// Swap USDC to WETH, then bridge WETH to Optimism
const bridgeParams = {
  depositor: userAddress,
  recipient: userAddress, // Can be different address on destination
  inputToken: WETH_MAINNET,
  outputToken: WETH_OPTIMISM,
  inputAmount: CONTRACT_BALANCE, // Use entire swap output
  outputAmount: expectedOutputAmount,
  destinationChainId: 10,
  exclusiveRelayer: '0x0000000000000000000000000000000000000000',
  quoteTimestamp: Math.floor(Date.now() / 1000),
  fillDeadline: Math.floor(Date.now() / 1000) + 3600,
  exclusivityDeadline: 0,
  message: '0x', // Optional message to execute on destination
  useNative: false, // Set to true to bridge native ETH
}

const { calldata, value } = SwapRouter.swapCallParameters(
  trade,
  swapOptions,
  [bridgeParams] // Array of bridge operations
)

### Using CONTRACT_BALANCE

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#using-contract_balance)
When bridging after a swap, you often don't know the exact output amount. Use `CONTRACT_BALANCE` to bridge the entire contract balance:

import { CONTRACT_BALANCE } from '@uniswap/universal-router-sdk'

const bridgeParams = {
  // ... other params
  inputAmount: CONTRACT_BALANCE, // Bridge entire balance after swap
  // ... other params
}

### Multiple Bridge Operations

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#multiple-bridge-operations)
You can perform multiple bridge operations after a swap:

const { calldata, value } = SwapRouter.swapCallParameters(trade, swapOptions, [
  {
    // Bridge 50% to Optimism
    inputToken: WETH_MAINNET,
    outputToken: WETH_OPTIMISM,
    inputAmount: BigNumber.from('500000000000000000'),
    destinationChainId: 10,
    // ... other params
  },
  {
    // Bridge remaining USDC to Arbitrum
    inputToken: USDC_MAINNET,
    outputToken: USDC_ARBITRUM,
    inputAmount: CONTRACT_BALANCE,
    destinationChainId: 42161,
    // ... other params
  },
])

### Native ETH Bridging

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#native-eth-bridging)
To bridge native ETH instead of WETH:

const bridgeParams = {
  inputToken: WETH_ADDRESS, // Must be WETH address
  outputToken: WETH_ON_DESTINATION,
  useNative: true, // Bridge as native ETH
  // ... other params
}

### Important Notes

[](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#important-notes)
1.   **Across Quote**: Bridge parameters (especially `outputAmount`, `quoteTimestamp`, `fillDeadline`) should come from the Across API quote
2.   **Recipient Address**: Can be different from the sender, allowing cross-chain transfers to other addresses
3.   **Message Passing**: The `message` field allows executing arbitrary calls on the destination chain
4.   **Slippage**: The `outputAmount` already accounts for bridge fees and slippage

Links/Buttons:
- [Skip to content](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#start-of-content)
- [](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#important-notes)
- [Sign in](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2FUniswap%2Fsdks%2Ftree%2Fmain%2Fsdks%2Funiversal-router-sdk)
- [GitHub CopilotWrite better code with AI](https://github.com/features/copilot)
- [GitHub Copilot appDirect agents from issue to merge](https://github.com/features/ai/github-app)
- [MCP RegistryIntegrate external tools](https://github.com/mcp)
- [ActionsAutomate any workflow](https://github.com/features/actions)
- [CodespacesInstant dev environments](https://github.com/features/codespaces)
- [IssuesPlan and track work](https://github.com/features/issues)
- [Code ReviewManage code changes](https://github.com/features/code-review)
- [Code QualityEnforce quality at merge](https://github.com/features/code-quality)
- [GitHub Advanced SecurityFind and fix vulnerabilities](https://github.com/security/advanced-security)
- [Code securitySecure your code as you build](https://github.com/security/advanced-security/code-security)
- [Secret protectionStop leaks before they start](https://github.com/security/advanced-security/secret-protection)
- [Why GitHub](https://github.com/why-github)
- [Documentation](https://docs.github.com/)
- [Blog](https://github.blog/)
- [Changelog](https://github.blog/changelog)
- [Marketplace](https://github.com/marketplace)
- [View all features](https://github.com/features)
- [Enterprises](https://github.com/enterprise)
- [Small and medium teams](https://github.com/team)
- [Startups](https://github.com/enterprise/startups)
- [Nonprofits](https://github.com/solutions/industry/nonprofits)
- [App Modernization](https://github.com/solutions/use-case/app-modernization)
- [DevSecOps](https://github.com/solutions/use-case/devsecops)
- [DevOps](https://github.com/resources/articles?topic=devops)
- [CI/CD](https://github.com/solutions/use-case/ci-cd)
- [View all use cases](https://github.com/solutions/use-case)
- [Healthcare](https://github.com/solutions/industry/healthcare)
- [Financial services](https://github.com/solutions/industry/financial-services)
- [Manufacturing](https://github.com/solutions/industry/manufacturing)
- [Government](https://github.com/solutions/industry/government)
- [View all industries](https://github.com/solutions/industry)
- [View all solutions](https://github.com/solutions)
- [AI](https://github.com/resources/articles?topic=ai)
- [Software Development](https://github.com/resources/articles?topic=software-development)
- [Security](https://github.com/security)
- [View all topics](https://github.com/resources/articles)
- [Customer stories](https://github.com/customer-stories)
- [Events & webinars](https://github.com/resources/events)
- [Ebooks & reports](https://github.com/resources/whitepapers)
- [Business insights](https://github.com/solutions/executive-insights)
- [GitHub Skills](https://skills.github.com/)
- [Customer support](https://support.github.com/)
- [Community forum](https://github.com/orgs/community/discussions)
- [Trust center](https://github.com/trust-center)
- [Partners](https://github.com/partners)
- [View all resources](https://github.com/resources)
- [GitHub SponsorsFund open source developers](https://github.com/open-source/sponsors)
- [Security Lab](https://securitylab.github.com/)
- [Maintainer Community](https://maintainers.github.com/)
- [GitHub Stars](https://stars.github.com/)
- [Archive Program](https://archiveprogram.github.com/)
- [Topics](https://github.com/topics)
- [Trending](https://github.com/trending)
- [Collections](https://github.com/collections)
- [Copilot for BusinessEnterprise-grade AI features](https://github.com/features/copilot/copilot-business)
- [Premium SupportEnterprise-grade 24/7 support](https://github.com/enterprise/premium-support)
- [Pricing](https://github.com/pricing)
- [Sign up](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=Uniswap%2Fsdks)
- [Uniswap](https://github.com/Uniswap)
- [sdks](https://github.com/Uniswap/sdks/tree/main/sdks)
- [Notifications](https://github.com/login?return_to=%2FUniswap%2Fsdks)
- [Issues 34](https://github.com/Uniswap/sdks/issues)
- [Pull requests 86](https://github.com/Uniswap/sdks/pulls)
- [Actions](https://github.com/Uniswap/sdks/actions)
- [Security and quality 0](https://github.com/Uniswap/sdks/security)
- [Insights](https://github.com/Uniswap/sdks/pulse)
- [github-actions[bot]](https://github.com/Uniswap/sdks/commits?author=github-actions%5Bbot%5D)
- [chore(sdks): Version Packages (](https://github.com/Uniswap/sdks/commit/35c4e35aca9e22169ce17d7106e7fc5f27ccd03d)
- [#719](https://github.com/Uniswap/sdks/pull/719)
- [History](https://github.com/Uniswap/sdks/commits/main/sdks/universal-router-sdk)
- [abis](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk/abis)
- [Add 'sdks/universal-router-sdk/' from commit '47b75c849ad1e41f958f128…](https://github.com/Uniswap/sdks/commit/483f8fe365a2d0d61cdf8497018b04e7d286cf0f)
- [lib](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk/lib)
- [feat(universal-router-sdk): downgrade universal-router to v2.0.0-beta…](https://github.com/Uniswap/sdks/commit/86a6fd88d134192df3c0ed25d09c9362eea32e7e)
- [src](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk/src)
- [fix(sdk-core,universal-router-sdk): update permissioned pools address…](https://github.com/Uniswap/sdks/commit/209da9f4bf93c08a449393261dd328931bd0be75)
- [test](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk/test)
- [fix(universal-router-sdk): encode ACROSS_V4_DEPOSIT_V3 command input …](https://github.com/Uniswap/sdks/commit/0d91d5f75997a1779e966e631de939109c20cbf6)
- [.gitignore](https://github.com/Uniswap/sdks/blob/main/sdks/universal-router-sdk/.gitignore)
- [.prettierignore](https://github.com/Uniswap/sdks/blob/main/sdks/universal-router-sdk/.prettierignore)
- [chore(public): SDK monorepo initial migration (](https://github.com/Uniswap/sdks/commit/e501b2339bf14c7f8ac3a0c06417b7dbc36eea86)
- [#1](https://github.com/Uniswap/sdks/pull/1)
- [CHANGELOG.md](https://github.com/Uniswap/sdks/blob/main/sdks/universal-router-sdk/CHANGELOG.md)
- [README.md](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#readme)
- [feat(ur-sdk): allow direct transfers as an option on swapsteps (](https://github.com/Uniswap/sdks/commit/87069f5f73000e23552854d4a90c766f5ba24ea9)
- [#638](https://github.com/Uniswap/sdks/pull/638)
- [foundry.toml](https://github.com/Uniswap/sdks/blob/main/sdks/universal-router-sdk/foundry.toml)
- [feat(ur-sdk): Universal Router 2.1 support (](https://github.com/Uniswap/sdks/commit/1d9acec18f51f7138121a33759dea30c86e6e24f)
- [#504](https://github.com/Uniswap/sdks/pull/504)
- [hardhat.config.ts](https://github.com/Uniswap/sdks/blob/main/sdks/universal-router-sdk/hardhat.config.ts)
- [fix(uniswapx-sdk): add PriorityOrder integration tests (](https://github.com/Uniswap/sdks/commit/2eee6b49ecb803aacc4cfee84e62f10804d37809)
- [#60](https://github.com/Uniswap/sdks/pull/60)
- [package.json](https://github.com/Uniswap/sdks/blob/main/sdks/universal-router-sdk/package.json)
- [remappings.txt](https://github.com/Uniswap/sdks/blob/main/sdks/universal-router-sdk/remappings.txt)
- [tsconfig.base.json](https://github.com/Uniswap/sdks/blob/main/sdks/universal-router-sdk/tsconfig.base.json)
- [chore: migrate monorepo from Yarn to Bun (](https://github.com/Uniswap/sdks/commit/58a58d0df92029d4586ee808b0e7d55e2a520b2a)
- [#556](https://github.com/Uniswap/sdks/pull/556)
- [tsconfig.cjs.json](https://github.com/Uniswap/sdks/blob/main/sdks/universal-router-sdk/tsconfig.cjs.json)
- [tsconfig.esm.json](https://github.com/Uniswap/sdks/blob/main/sdks/universal-router-sdk/tsconfig.esm.json)
- [tsconfig.types.json](https://github.com/Uniswap/sdks/blob/main/sdks/universal-router-sdk/tsconfig.types.json)
- [Universal Router](https://github.com/Uniswap/universal-router)
- [Encoding Router-Provided Swap Steps](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#encoding-router-provided-swap-steps-encodeswaps)
- [Direct Transfers](https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk#direct-transfers-allowdirecttransfers)
- [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
- [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
- [Status](https://www.githubstatus.com/)
- [Community](https://github.community/)
- [Contact](https://support.github.com/?tags=dotcom-footer)
