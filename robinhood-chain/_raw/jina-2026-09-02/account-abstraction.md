Title: Account Abstraction

URL Source: https://docs.robinhood.com/chain/account-abstraction

Markdown Content:
[Skip to content](https://docs.robinhood.com/chain/account-abstraction#vocs-content)

[![Image 1: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-light.svg)![Image 2: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-dark.svg)](https://docs.robinhood.com/chain)

Get Started

[About Robinhood Chain](https://docs.robinhood.com/chain)[Connecting to Robinhood Chain](https://docs.robinhood.com/chain/connecting)[Add network to your wallet](https://docs.robinhood.com/chain/add-network-to-wallet)[Bridging](https://docs.robinhood.com/chain/bridging)

Stock Tokens

[Overview](https://docs.robinhood.com/chain/stock-tokens)[Building with Stock Tokens](https://docs.robinhood.com/chain/building-with-stock-tokens)[Stock Token APIs](https://docs.robinhood.com/chain/stock-token-apis)

Core Concepts

[Differences from Ethereum](https://docs.robinhood.com/chain/differences-from-ethereum)[Gas & Fees](https://docs.robinhood.com/chain/gas-and-fees)[Transaction Finality](https://docs.robinhood.com/chain/transaction-finality)

[Token Contracts](https://docs.robinhood.com/chain/contracts)[Protocol Contracts](https://docs.robinhood.com/chain/protocol-contracts)

Build

[Deploy a Contract](https://docs.robinhood.com/chain/deploy-smart-contracts)[Account Abstraction](https://docs.robinhood.com/chain/account-abstraction)[Cross-Chain Messaging](https://docs.robinhood.com/chain/cross-chain-messaging)[Oracles & Price Feeds](https://docs.robinhood.com/chain/oracles-and-price-feeds)[Data Streams](https://docs.robinhood.com/chain/data-streams)

[Run a full node](https://docs.robinhood.com/chain/run-a-full-node)[Governance](https://docs.robinhood.com/chain/governance)

Brand Guidelines

[Overview](https://docs.robinhood.com/chain/brand-guidelines)

Notices & Upgrades

[Overview](https://docs.robinhood.com/chain/notices-and-upgrades)

[Report an issue](https://docs.robinhood.com/chain/report-issue)[Terms of Service](https://docs.robinhood.com/chain/terms-of-service)

Search...

[![Image 3: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-light.svg)![Image 4: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-dark.svg)](https://docs.robinhood.com/chain)

[![Image 5: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-light.svg)![Image 6: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-dark.svg)](https://docs.robinhood.com/chain)

Menu

Account Abstraction

On this page

[Ask in ChatGPT](https://chatgpt.com/?hints=search&q=Please%20research%20and%20analyze%20this%20page%3A%20https%3A%2F%2Fdocs.robinhood.com%2Fchain%2Faccount-abstraction%20so%20I%20can%20ask%20you%20questions%20about%20it.%20Once%20you%20have%20read%20it%2C%20prompt%20me%20with%20any%20questions%20I%20have.%20Do%20not%20post%20content%20from%20the%20page%20in%20your%20response.%20Any%20of%20my%20follow%20up%20questions%20must%20reference%20the%20site%20I%20gave%20you.)

## On this page

*   [What's available](https://docs.robinhood.com/chain/account-abstraction#whats-available)
*   [Network configuration](https://docs.robinhood.com/chain/account-abstraction#network-configuration)
*   [Deployed ERC-4337 contracts](https://docs.robinhood.com/chain/account-abstraction#deployed-erc-4337-contracts)
*   [Quickstart](https://docs.robinhood.com/chain/account-abstraction#quickstart)

    *   [Using Alchemy](https://docs.robinhood.com/chain/account-abstraction#using-alchemy)
    *   [Using ZeroDev](https://docs.robinhood.com/chain/account-abstraction#using-zerodev)

*   [Further reading](https://docs.robinhood.com/chain/account-abstraction#further-reading)

# Account Abstraction[](https://docs.robinhood.com/chain/account-abstraction#account-abstraction)

Robinhood Chain has first-class support for ERC-4337 account abstraction, and also supports EIP-7702, which lets existing externally-owned accounts delegate to smart contract code — so users can get smart-account features (batching, sponsorship, session keys) without migrating to a new address.

Account abstraction on Robinhood Chain is powered by Alchemy, with ZeroDev available as an alternative.

## What's available[](https://docs.robinhood.com/chain/account-abstraction#whats-available)

| Service | Description |
| --- | --- |
| Alchemy | Create and manage programmable wallets to submit and manage transactions with built-in batching, configurable spend policies, and gas sponsorship for users. |
| ZeroDev | Smart AA wallets that can be embedded as UI or used through API. Supports gas sponsorship, transaction batching, transaction automation, and cross-chain execution. |
| Privy | Embedded wallets and account abstraction tooling |
| Dynamic | Embedded wallets, wallet connectors, and account abstraction tooling |

## Network configuration[](https://docs.robinhood.com/chain/account-abstraction#network-configuration)

| Property | Value |
| --- | --- |
| Chain ID | 4663 |
| Bundler / RPC URL | `https://robinhood-mainnet.g.alchemy.com/v2/{API_KEY}` |

## Deployed ERC-4337 contracts[](https://docs.robinhood.com/chain/account-abstraction#deployed-erc-4337-contracts)

| Contract | Address |
| --- | --- |
| ERC-4337 Entrypoint v0.6.0 | **`0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789`** |
| ERC-4337 SenderCreator v0.6.0 | **`0x7fc98430eAEdbb6070B35B39D798725049088348`** |
| ERC-4337 Entrypoint v0.7.0 | **`0x0000000071727De22E5E9d8BAf0edAc6f37da032`** |
| ERC-4337 SenderCreator v0.7.0 | **`0xEFC2c1444eBCC4Db75e7613d20C6a62fF67A167C`** |
| ERC-4337 Entrypoint v0.8.0 | **`0x4337084D9E255Ff0702461CF8895CE9E3b5Ff108`** |
| ERC-4337 SenderCreator v0.8.0 | **`0x449ED7C3e6Fee6a97311d4b55475DF59C44AdD33`** |
| ERC-4337 Safe Module Setup v0.3.0 | **`0x2dd68b007B46fBe91B9A7c3EDa5A7a1063cB5b47`** |
| ERC-4337 Safe 4337 Module v0.3.0 (supporting Entrypoint v0.7.0) | **`0x75cf11467937ce3F2f357CE24ffc3DBF8fD5c226`** |

## Quickstart[](https://docs.robinhood.com/chain/account-abstraction#quickstart)

### Using Alchemy[](https://docs.robinhood.com/chain/account-abstraction#using-alchemy)

Alchemy recommends using the latest version `@alchemy/wallet-apis` for the easiest setup.

Sending sponsored txs on Robinhood mainnet:

1.   Create an Alchemy account and [create an app on Robinhood Chain](https://dashboard.alchemy.com/apps?utm_source=docs&utm_medium=referral&utm_content=wallets_transactions_send-transactions) to get your API key
2.   In the Alchemy dashboard, create a [Gas Manager policy to sponsor gas](https://dashboard.alchemy.com/gas-manager/policy/create?utm_source=docs&utm_medium=referral&utm_content=wallets_transactions_sponsor-gas), and note your Policy ID
3.   Install dependencies

`npm install @alchemy/wallet-apis @alchemy/common viem`

1.   Create a client and send gas-sponsored operation

```
import { createSmartWalletClient, alchemyWalletTransport } from "@alchemy/wallet-apis";
import { robinhoodMainnet } from "@alchemy/common/chains";
import { privateKeyToAccount } from "viem/accounts";
import { zeroAddress } from "viem";
 
const client = createSmartWalletClient({
  transport: alchemyWalletTransport({
    apiKey: "YOUR_API_KEY",
  }),
  chain: robinhoodMainnet,
  signer: privateKeyToAccount("0xYOUR_PRIVATE_KEY" as const),
  paymaster: {
    policyId: "YOUR_POLICY_ID", // sponsor gas for the user
  },
});
 
// prepare and send calls
const { id } = await client.sendCalls({
  calls: [{ to: zeroAddress, value: BigInt(0) }],
});
 
// get calls status
const status = await client.waitForCallsStatus({ id });
console.log(`Call ID: ${id}`);
console.log(`Status: ${status.status}`);
```

### Using ZeroDev[](https://docs.robinhood.com/chain/account-abstraction#using-zerodev)

If you prefer ZeroDev for gas sponsorship, configure a ZeroDev paymaster pointed at Robinhood Chain (chain ID 4663).

Install ZeroDev SDK:

`npm i @zerodev/sdk @zerodev/ecdsa-validator`

Send a sponsored transaction with ZeroDev:

```
import { createKernelAccount, createKernelAccountClient, createZeroDevPaymasterClient } from "@zerodev/sdk"
import { KERNEL_V3_1, getEntryPoint } from "@zerodev/sdk/constants"
import { signerToEcdsaValidator } from "@zerodev/ecdsa-validator"
import { http, createPublicClient, zeroAddress } from "viem"
import { generatePrivateKey, privateKeyToAccount } from "viem/accounts"
import { robinhoodMainnet } from "viem/chains"
 
const ZERODEV_RPC = 'https://rpc.zerodev.app/api/v3/YOUR_PROJECT_ID/chain/4663'
 
const chain = robinhoodMainnet
const entryPoint = getEntryPoint("0.7")
const kernelVersion = KERNEL_V3_1
 
const main = async () => {
  // Construct a signer
  const privateKey = generatePrivateKey()
  const signer = privateKeyToAccount(privateKey)
 
  // Construct a public client
  const publicClient = createPublicClient({
    // Use your own RPC provider in production (e.g. Infura/Alchemy).
    transport: http(ZERODEV_RPC),
    chain
  })
 
  // Construct a validator
  const ecdsaValidator = await signerToEcdsaValidator(publicClient, {
    signer,
    entryPoint,
    kernelVersion
  })
 
  // Construct a Kernel account
  const account = await createKernelAccount(publicClient, {
    plugins: {
      sudo: ecdsaValidator,
    },
    entryPoint,
    kernelVersion
  })
 
  const zerodevPaymaster = createZeroDevPaymasterClient({
    chain,
    transport: http(ZERODEV_RPC),
  })
 
  // Construct a Kernel account client
  const kernelClient = createKernelAccountClient({
    account,
    chain,
    bundlerTransport: http(ZERODEV_RPC),
    // Required - the public client
    client: publicClient,
    paymaster: {
        getPaymasterData(userOperation) {
            return zerodevPaymaster.sponsorUserOperation({userOperation})
        }
    },
  })
 
  const accountAddress = kernelClient.account.address
  console.log("My account:", accountAddress)
 
  // Send a UserOp
  const userOpHash = await kernelClient.sendUserOperation({
      callData: await kernelClient.account.encodeCalls([{
        to: zeroAddress,
        value: BigInt(0),
        data: "0x",
      }]),
  })
 
  console.log("UserOp hash:", userOpHash)
  console.log("Waiting for UserOp to complete...")
 
  await kernelClient.waitForUserOperationReceipt({
    hash: userOpHash,
    timeout: 1000 * 15,
  })
 
  console.log("UserOp completed: https://robinhoodchain.blockscout.com/op/" + userOpHash)
 
  process.exit()
}
 
main()
```

For more information, check [ZeroDev docs](https://docs.zerodev.app/).

## Further reading[](https://docs.robinhood.com/chain/account-abstraction#further-reading)

*   [Alchemy documentation](https://www.alchemy.com/docs/wallets)
*   [ERC-4337 specification](https://docs.erc4337.io/index.html)
*   [ZeroDev documentation](https://docs.zerodev.app/)

[Deploy a Contract Previous shift←](https://docs.robinhood.com/chain/deploy-smart-contracts)[Cross-Chain Messaging Next shift→](https://docs.robinhood.com/chain/cross-chain-messaging)

Your Privacy Choices![Image 7](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/privacy-options.svg)
