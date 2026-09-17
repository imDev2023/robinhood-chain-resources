Title: GitHub - ryangoree/drift: Effortless ethereum development across web3 libraries

URL Source: https://github.com/delvtech/drift

Markdown Content:
[![Image 1: NPM Version](https://camo.githubusercontent.com/ab336af779f3cec6ae210de1871d9e5b4338be2295759401be4b543874ec7ca7/68747470733a2f2f696d672e736869656c64732e696f2f6e706d2f762f25343067756425324664726966743f636f6c6f723d636233383337)](https://npmjs.com/package/@gud/drift)[![Image 2: License:Apache-2.0](https://camo.githubusercontent.com/b1d183cd7e260b514791061f45cce29f35f6488693baf5d8fe19fa82e0d1c79e/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f417061636865253230322e302d3233343534643f6c6f676f3d617061636865)](https://github.com/ryangoree/drift/blob/main/LICENSE)[![Image 3: GitHub](https://camo.githubusercontent.com/722148e87c9708c9bfd38adea72b6e2b01ca1e332c008051c24f51c8d38f9041/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f7279616e676f72656525324664726966742d3135316232333f6c6f676f3d676974687562)](https://github.com/ryangoree/drift)

**Effortless Ethereum Development Across Web3 Libraries**

Write cached Ethereum protocol interactions once with Drift and run them anywhere. Seamlessly support multiple web3 libraries like [viem](https://viem.sh/), [web3.js](https://web3js.org/), and [ethers](https://ethers.org/)—without getting locked into a single provider or rewriting code.

With built-in caching, type-safe contract APIs, and easy-to-use testing mocks, Drift lets you build efficient and reliable applications without worrying about call optimizations or juggling countless hooks. Focus on what matters: creating great features and user experiences.

## Why Drift?

[](https://github.com/delvtech/drift#why-drift-)
Building on Ethereum often means dealing with:

*   **Optimizing Network Calls:** Manually caching calls and optimizing queries to minimize RPC requests slows down development.
*   **Managing Multiple Hooks:** Each contract call often needs its own hook and query key to prevent redundant network requests.
*   **Complex Testing:** Setting up mocks for contract interactions can be cumbersome and error-prone.
*   **Hard Dependency on a Specific Web3 Library:** There are several competing options, like viem, web3.js, ethers.js. Tying your business logic to a specific one creates vendor lock-in and makes it harder to switch down the road.

## Drift Solves These Problems

[](https://github.com/delvtech/drift#drift-solves-these-problems-)
*   ⚡ **Optimized Performance:** Automatically reduces redundant RPC calls with built-in caching. No need to manage hooks or query keys for each call.
*   🔒 **Type Safety:** Drift's type-checked APIs help catch errors at compile time.
*   🧪 **Testing Made Easy:** Built-in mocks simplify testing your contract interactions. Drift's testing mocks are also type-safe, ensuring your tests are always in sync with your contracts.
*   🌐 **Multi-Library Support:** Drift provides a unified interface compatible with multiple web3 libraries. Write your contract logic once and use it across different providers.
*   🔄 **Extensibility:** Designed to grow with your project's needs, Drift allows you to easily extend support to new web3 libraries by creating small adapter packages.

## Table of Contents

[](https://github.com/delvtech/drift#table-of-contents-)
*   [Installation](https://github.com/delvtech/drift#installation)
*   [Start Drifting](https://github.com/delvtech/drift#start-drifting)
    *   [1. Create a Drift client](https://github.com/delvtech/drift#1-create-a-drift-client)
    *   [2. Interact with your Contracts](https://github.com/delvtech/drift#2-interact-with-your-contracts)
        *   [Read Operations with Caching](https://github.com/delvtech/drift#read-operations-with-caching)
        *   [Write Operations](https://github.com/delvtech/drift#write-operations)
        *   [Deployments](https://github.com/delvtech/drift#deployments)
        *   [Contract Instances](https://github.com/delvtech/drift#contract-instances)

*   [Example: Building Vault Clients](https://github.com/delvtech/drift#example-building-vault-clients)
    *   [1. Define vault clients](https://github.com/delvtech/drift#1-define-vault-clients)
    *   [2. Use the clients in your application](https://github.com/delvtech/drift#2-use-the-clients-in-your-application)
        *   [Benefits of This Architecture](https://github.com/delvtech/drift#benefits-of-this-architecture)

    *   [3. Test Your Clients with Drift's Built-in Mocks](https://github.com/delvtech/drift#3-test-your-clients-with-drifts-built-in-mocks)
        *   [Example: Testing Client Methods with Multiple RPC Calls](https://github.com/delvtech/drift#example-testing-client-methods-with-multiple-rpc-calls)
        *   [Benefits](https://github.com/delvtech/drift#benefits)

*   [Simplifying React Hook Management](https://github.com/delvtech/drift#simplifying-react-hook-management)
    *   [The Problem Without Drift](https://github.com/delvtech/drift#the-problem-without-drift)
    *   [How Drift Helps](https://github.com/delvtech/drift#how-drift-helps)
        *   [Example Using React Query](https://github.com/delvtech/drift#example-using-react-query)

*   [Caching in Action](https://github.com/delvtech/drift#caching-in-action)
    *   [Cache Invalidation](https://github.com/delvtech/drift#cache-invalidation)
    *   [Preloading Cache Data](https://github.com/delvtech/drift#preloading-cache-data)
    *   [Direct Access to Cached Data](https://github.com/delvtech/drift#direct-access-to-cached-data)

*   [Extending Drift for Your Needs](https://github.com/delvtech/drift#extending-drift-for-your-needs)
    *   [Extension Points](https://github.com/delvtech/drift#extension-points)
        *   [Adapters](https://github.com/delvtech/drift#adapters)
        *   [Stores](https://github.com/delvtech/drift#stores)

    *   [Hooks](https://github.com/delvtech/drift#hooks)

*   [Contributing](https://github.com/delvtech/drift#contributing)
*   [License](https://github.com/delvtech/drift#license)

## Installation

[](https://github.com/delvtech/drift#installation)
Install Drift:

npm install @gud/drift

**Optional:** To use Drift with a specific web3 library, install the corresponding adapter:

# Install one (optional)
npm install @gud/drift-viem
npm install @gud/drift-web3
npm install @gud/drift-ethers
npm install @gud/drift-ethers-v5

Tip

Drift can be used without an adapter, however adapters reuse clients from their corresponding web3 library, which can be useful for sharing connection settings, signers, and other configurations.

## Start Drifting

[](https://github.com/delvtech/drift#start-drifting)
### 1. Create a Drift client

[](https://github.com/delvtech/drift#1-create-a-drift-client)

import { createDrift } from "@gud/drift";

const drift = createDrift({
  rpcUrl: "[YOUR_RPC_URL]",
});

**Viem adapter example:**

import { createDrift } from "@gud/drift";
import { viemAdapter } from "@gud/drift-viem";
import { createPublicClient, createWalletClient, http } from "viem";

const publicClient = createPublicClient({
  transport: http(),
});

// optionally create a wallet client
const walletClient = createWalletClient({
  transport: http(),
});

const drift = createDrift({
  adapter: viemAdapter({ publicClient, walletClient }),
});

### 2. Interact with your Contracts

[](https://github.com/delvtech/drift#2-interact-with-your-contracts)
#### Read Operations with Caching

[](https://github.com/delvtech/drift#read-operations-with-caching)

import { VaultAbi } from "./abis/VaultAbi";

// No need to wrap in separate hooks; Drift handles caching internally
const balance = await drift.read({
  abi: VaultAbi,
  address: "0xYourVaultAddress",
  fn: "balanceOf",
  args: {
    // Named type-safe arguments improve readability
    // and discoverability through IDE autocompletion
    account: "0xUserAddress",
  },
});

#### Write Operations

[](https://github.com/delvtech/drift#write-operations)
If Drift was initialized with a signer, you can perform write operations:

const txHash = await drift.write({
  abi: VaultAbi,
  address: "0xYourVaultAddress",
  fn: "deposit",
  args: {
    amount: BigInt(100e18),
    receiver: "0xReceiverAddress",
  },

  // Optionally wait for the transaction to be mined and invalidate cache
  onMined: () => {
    drift.cache.invalidateRead({
      abi: VaultAbi,
      address: "0xYourVaultAddress",
      fn: "balanceOf",
      args: {
        account: "0xReceiverAddress",
      },
    });
  },
});

#### Deployments

[](https://github.com/delvtech/drift#deployments)

const txHash = await drift.deploy({
  abi: ERC20.abi,
  bytecode: ERC20.bytecode,
  args: {
    decimals_: 18,
    initialSupply: 100_000_000n * 10n ** 18n, // 100M
  },
});

// Wait for the receipt to get the contract address
const receipt = await drift.waitForTransaction({ hash: txHash });

if (receipt?.status === "success" && receipt.contractAddress) {
  const totalSupply = await drift.read({
    abi: ERC20.abi,
    address: receipt.contractAddress,
    fn: "totalSupply",
  });
  // => 100000000000000000000000000n
}

#### Contract Instances

[](https://github.com/delvtech/drift#contract-instances)
Create contract instances to write your options once and get a streamlined, type-safe API to re-use across your application.

const vault = drift.contract({
  abi: VaultAbi,
  address: "0xYourVaultAddress",
  // ...other options
});

const balance = await vault.read("balanceOf", { account });

const txHash = await vault.write(
  "deposit",
  {
    amount: BigInt(100e18),
    receiver: "0xReceiverAddress",
  },
  {
    onMined: () => {
      vault.cache.invalidateRead("balanceOf", { account: "0xReceiverAddress" });
    },
  },
);

## Example: Building Vault Clients

[](https://github.com/delvtech/drift#example-building-vault-clients)
Let's build a simple library agnostic SDK with `ReadVault` and `ReadWriteVault` clients using Drift.

### 1. Define vault clients

[](https://github.com/delvtech/drift#1-define-vault-clients)
Define read and read-write clients that wrap Drift's `ReadContract` and `ReadWriteContract` abstractions.

// foobar-sdk/src/VaultClient.ts
import {
  type Address,
  type Drift,
  type EventLog,
  type Hash,
  type ReadContract,
  type ReadWriteAdapter,
  type ReadWriteContract,
  createDrift,
} from "@gud/drift";
import { vaultAbi } from "./abis/vaultAbi";

type VaultAbi = typeof vaultAbi;

/** A read-only Vault client */
export class ReadVault {
  contract: ReadContract<VaultAbi>;

  constructor(address: Address, drift: Drift = createDrift()) {
    this.contract = drift.contract({
      abi: vaultAbi,
      address,
    });
  }

  // Make read calls with internal caching
  getBalance(account: Address) {
    return this.contract.read("balanceOf", { account });
  }
  convertToAssets(shares: bigint) {
    return this.contract.read("convertToAssets", { shares });
  }
  async getAssetValue(account: Address) {
    const shares = await this.getBalance(account);
    return this.convertToAssets(shares);
  }

  // Fetch events with internal caching
  getDeposits(account?: Address) {
    return this.contract.getEvents("Deposit", {
      filter: {
        sender: account,
      },
    });
  }
}

/** A read-write Vault client that can sign transactions */
export class ReadWriteVault extends ReadVault {
  declare contract: ReadWriteContract<VaultAbi>;

  constructor(
    address: Address,
    drift: Drift<ReadWriteAdapter> = createDrift(),
  ) {
    super(address, drift);
  }

  // Make a deposit
  deposit(amount: bigint, account: Address) {
    return this.contract.write(
      "deposit",
      {
        assets: amount,
        receiver: account,
      },
      {
        // Optionally wait for the transaction to be mined and invalidate cache
        onMined: (receipt) => {
          if (receipt?.status === "success") {
            this.contract.cache.clearReads();
          }
        },
      },
    );
  }
}

### 2. Use the clients in your application

[](https://github.com/delvtech/drift#2-use-the-clients-in-your-application)
Using an adapter, you can integrate Drift with your chosen web3 library. Here's an example using `viem`:

import { createDrift } from "@gud/drift";
import { viemAdapter } from "@gud/drift-viem";
import { createPublicClient, http } from "viem";
import { ReadVault } from "@foobar/sdk";

const publicClient = createPublicClient({
  transport: http(),
  // ...other options
});

const drift = createDrift({
  adapter: viemAdapter({ publicClient }),
});

// Instantiate the ReadVault client
const readVault = new ReadVault("0xYourVaultAddress", drift);

// Fetch user balance
const userBalance = await readVault.getBalance("0xUserAddress");

// Get the asset value of the user; the balance will be fetched from the cache
const userAssetValue = await readVault.getAssetValue("0xUserAddress");

#### Benefits of This Architecture

[](https://github.com/delvtech/drift#benefits-of-this-architecture)
*   **Reusability:** Write your business logic once and reuse it across different environments. Easily extend support to new web3 libraries by creating small adapter packages.
*   **Simplicity:** Your application code stays clean and focused on business logic rather than on optimizing network calls or managing cache keys.

### 3. Test Your Clients with Drift's Built-in Mocks

[](https://github.com/delvtech/drift#3-test-your-clients-with-drifts-built-in-mocks)
Testing smart contract interactions can be complex and time-consuming. Drift simplifies this process by providing built-in mocks that allow you to stub responses and focus on testing your application logic.

Important

Drift's testing mocks have a peer dependency on [Sinon.JS](https://sinonjs.org/releases/v17/). Make sure to install it before using the mocks.

npm install --save-dev sinon @types/sinon

#### Example: Testing Client Methods with Multiple RPC Calls

[](https://github.com/delvtech/drift#example-testing-client-methods-with-multiple-rpc-calls)
In our `ReadVault` client, the `getAssetValue` method gets the total asset value for an account by fetching their vault balance and converting it to assets. Under the hood, this method makes multiple RPC requests.

Here's how you can use Drift's mocks to stub contract calls and test your method:

import assert from "node:assert";
import test from "node:test";
import { createMockDrift, randomAddress } from "@gud/drift/testing";
import { vaultAbi } from "./abis/VaultAbi";
import { ReadVault } from "./VaultClient";

test("getAssetValue returns account balances converted to assets", async () => {
  // Set up mocks
  const address = randomAddress();
  const account = randomAddress();
  const mockDrift = createMockDrift();
  const mockContract = mockDrift.contract({ abi: vaultAbi, address });

  // Stub the vault's return values using `on*` methods
  mockContract.onRead("balanceOf", { account }).resolves(
    // Return 100 shares for the account
    BigInt(100e18),
  );
  mockContract.onRead("convertToAssets").callsFake(
    // Simulate the conversion of shares to assets
    async (params) => (params.args.shares * BigInt(1.5e18)) / BigInt(1e18),
  );

  // Create your client with the mocked Drift instance
  const readVault = new ReadVault(address, mockDrift);

  // Call the method you want to test
  const accountAssetValue = await readVault.getAssetValue(account);

  // Assert the expected result
  assert.strictEqual(accountAssetValue, BigInt(150e18));
});

#### Benefits

[](https://github.com/delvtech/drift#benefits)
*   **No Network Calls:** Tests run faster and more reliably without actual network interactions.
*   **Focus on Logic:** Concentrate on testing your application's business logic.
*   **Easy Setup:** Minimal configuration required to get started with testing. You can even start building and testing your clients before the contracts are deployed.

## Simplifying React Hook Management

[](https://github.com/delvtech/drift#simplifying-react-hook-management)
### The Problem Without Drift

[](https://github.com/delvtech/drift#the-problem-without-drift)
In most setups, you might rely on data-fetching libraries like React Query. However, to prevent redundant network requests, each contract call would need:

*   Its own hook (e.g., `useBalanceOf`, `useTokenSymbol`).
*   Unique query keys for caching.

Composing multiple calls becomes cumbersome, as you have to manage each hook's result separately.

### How Drift Helps

[](https://github.com/delvtech/drift#how-drift-helps)
Drift's internal caching means you don't need to wrap every contract call in a separate hook. You can perform multiple contract interactions within a single function or hook without worrying about redundant requests from overlapping queries.

#### Example Using React Query

[](https://github.com/delvtech/drift#example-using-react-query)

import { useQuery } from "@tanstack/react-query";
import { ReadVault } from "sdk-core";

function useVaultData(readVault: ReadVault, userAddress: string) {
  return useQuery(["vaultData", userAddress], async () => {
    // Perform multiple reads without separate query keys.
    const [balance, symbol, deposits] = await Promise.all([
      readVault.getBalance(userAddress),
      readVault.contract.read("symbol"),
      readVault.getDeposits(userAddress),
    ]);

    return { balance, symbol, deposits };
  });
}

No need to manage multiple hooks or query keys — Drift handles caching internally, simplifying your code and development process.

## Caching in Action

[](https://github.com/delvtech/drift#caching-in-action)
Drift's caching mechanism ensures that repeated calls with the same parameters don't result in unnecessary network requests, even when composed within the same function.

// Return values are cached after the first call.
const balance = await contract.read("balanceOf", { account });

// Subsequent calls with the same parameters will return the cached value.
const fromCache = await contract.read("balanceOf", { account });

// Different parameters will trigger a network request.
const atBlock = await contract.read("balanceOf", { account }, { block: 123n });
const otherBalance = await contract.read("balanceOf", {
  account: "0xOtherAccount",
});

### Cache Invalidation

[](https://github.com/delvtech/drift#cache-invalidation)
Delete cached data to ensure it's re-fetched using `invalidate*` and `clear*` methods.

// Invalidate the cache for a specific read
contract.cache.invalidateRead("balanceOf", { account });

// Invalidate all reads matching partial arguments
contract.cache.invalidateReadsMatching("balanceOf");

// Clear all reads associated with the contract
contract.cache.clearReads();

// Let it all go...
contract.cache.clear();

### Preloading Cache Data

[](https://github.com/delvtech/drift#preloading-cache-data)
Add static data such as immutables from token lists using `preload*` methods to avoid network requests without changing how the data is accessed.

const drift = createDrift(/* ... */);
const contract = drift.contract({
  abi: erc20Abi,
  // ...
});

// Preloading read data
contract.cache.preloadRead({ fn: "symbol", value: "DAI" });

// Preloading event data
contract.cache.preloadEvents({
  event: "Transfer",
  value: [],
  // ...
});

### Direct Access to Cached Data

[](https://github.com/delvtech/drift#direct-access-to-cached-data)
Drift clients will automatically check the cache before fetching new data, but direct access to the cached data is available via `get*` methods.

// Get a cached read return
const cachedBalance = await contract.cache.getRead("balanceOf", { account });

// Get a cached transaction receipt
const cachedReceipt = await drift.cache.getTransactionReceipt({ hash });

The `invalidate*`, `clear*`, `preload*`, and `get*` methods are available on both the `Drift.cache` and `Contract.cache` instances.

Important

Manipulating cache data affects all clients that share the same cache. Since Drift passes its own cache to the contracts it creates via `Drift.contract()`, they'll already be preloaded with the `Drift` instance's cache and any cache operations performed on the contract cache will also affect the `Drift` cache.

## Extending Drift for Your Needs

[](https://github.com/delvtech/drift#extending-drift-for-your-needs)
Drift is designed to be extensible. You can build additional abstractions or utilities on top of it to suit your project's requirements.

### Extension Points

[](https://github.com/delvtech/drift#extension-points)
#### Adapters

[](https://github.com/delvtech/drift#adapters)
Extend support to new web3 libraries or custom providers by implementing the [`Adapter`](https://github.com/ryangoree/drift/blob/main/packages/drift/src/adapter/types/Adapter.ts#L23) interface. Drift [`Clients`](https://github.com/ryangoree/drift/blob/main/packages/drift/src/client/Client.ts#L30), including [`Drift`](https://github.com/ryangoree/drift/blob/main/packages/drift/src/client/Drift.ts#L27), extend the prototype of the `Adapter` they're provided, inheriting all of it's properties and methods, extending some, and adding some of their own. See the [`DefaultAdapter`](https://github.com/ryangoree/drift/blob/main/packages/drift/src/adapter/DefaultAdapter.ts#L57) for an example implementation.

import { DefaultAdapter, createDrift } from "@gud/drift";

class CustomAdapter extends DefaultAdapter {
  override async getChainId() {
    // Custom implementation...
  }
}

const drift = await createDrift({
  adapter: new CustomAdapter({
    rpcUrl: process.env.RPC_URL,
  }),
});

#### Stores

[](https://github.com/delvtech/drift#stores)
Implement a custom [`Store`](https://github.com/ryangoree/drift/blob/main/packages/drift/src/store/Store.ts#L7) to manage caching in a way that suits your application. The default store is an in-memory LRU cache, but you can create a custom store that uses TTL, localStorage, IndexedDB, [QueryClient](https://tanstack.com/query/latest/docs/reference/QueryClient), or any other storage mechanism, sync or async.

import { createDrift } from "@gud/drift";

class CustomStore extends Map {
  override set(key: string, value: unknown) {
    // Custom implementation...
  }
}

const drift = createDrift({
  store: new CustomStore(),
});

### Hooks

[](https://github.com/delvtech/drift#hooks)
Add custom logic by intercepting and modifying client methods with `hooks`. Each client method (including custom adapter methods) has type-safe `before:<method>` and `after:<method>` hooks that can be used to inspect and modify the arguments or results.

// Simulate writes before sending transactions
drift.hooks.on("before:write", async ({ args: [params] }) => {
  await drift.simulateWrite(params);
});

// Run middleware on reads
drift.hooks.on("before:read", async ({ args: [params], resolve }) => {
  const cachedValue = await drift.cache.getRead(params);
  const result = await readMiddleware({ drift, params, cachedValue });
  resolve(result);
});

// Run middleware to transform the result of calls
drift.hooks.on("after:call", ({ args: [params], result, setResult }) => {
  const transformedResult = callResultMiddleware({ drift, params, result });
  setResult(transformedResult);
});

## Contributing

[](https://github.com/delvtech/drift#contributing)
Got ideas or found a bug? Check the [Contributing Guide](https://github.com/ryangoree/drift/blob/main/.github/CONTRIBUTING.md) to get started.

## License

[](https://github.com/delvtech/drift#license)
Drift is open-source software licensed under the [Apache 2.0](https://github.com/ryangoree/drift/blob/main/LICENSE).

Links/Buttons:
- [Skip to content](https://github.com/delvtech/drift#start-of-content)
- [](https://github.com/slicesequal)
- [Sign in](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fryangoree%2Fdrift)
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
- [Sign up](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E&source=header-repo&source_repo=ryangoree%2Fdrift)
- [ryangoree](https://github.com/ryangoree/drift/commits?author=ryangoree)
- [drift](https://github.com/ryangoree/drift)
- [Notifications](https://github.com/login?return_to=%2Fryangoree%2Fdrift)
- [Issues 6](https://github.com/ryangoree/drift/issues)
- [Pull requests 5](https://github.com/ryangoree/drift/pulls)
- [Discussions](https://github.com/ryangoree/drift/discussions)
- [Actions](https://github.com/ryangoree/drift/actions)
- [Projects](https://github.com/ryangoree/drift/projects)
- [Security and quality 0](https://github.com/ryangoree/drift/security)
- [Insights](https://github.com/ryangoree/drift/pulse)
- [6 Branches](https://github.com/ryangoree/drift/branches)
- [441 Tags](https://github.com/ryangoree/drift/tags)
- [docs: Patch typo and remove empty code block](https://github.com/ryangoree/drift/commit/b95e11c7c10958c22418f13708e873bbe66e5974)
- [813 Commits](https://github.com/ryangoree/drift/commits/main/)
- [.changeset](https://github.com/ryangoree/drift/tree/main/.changeset)
- [chore: version packages (next) (](https://github.com/ryangoree/drift/commit/5b9d75727f93ae6bac8cef84b3d91851f6cd6c49)
- [#150](https://github.com/ryangoree/drift/pull/150)
- [.github](https://github.com/ryangoree/drift/tree/main/.github)
- [Update NPM token in release workflow](https://github.com/ryangoree/drift/commit/faddc86350df6cba4d6849b037cd81e83209aec1)
- [.vscode](https://github.com/ryangoree/drift/tree/main/.vscode)
- [Remaining name updates](https://github.com/ryangoree/drift/commit/e88357ebfc0a295e35ed2a0b57c8b5ee0369a369)
- [contracts](https://github.com/ryangoree/drift/tree/main/contracts)
- [Remove unused type params, patch gitignore](https://github.com/ryangoree/drift/commit/013cf9d1673b0606dd697bd48cd47965d76ae0db)
- [docs](https://github.com/ryangoree/drift/tree/main/docs)
- [examples](https://github.com/ryangoree/drift/tree/main/examples)
- [packages](https://github.com/ryangoree/drift/tree/main/packages)
- [scripts](https://github.com/ryangoree/drift/tree/main/scripts)
- [Bump fixed-point-wasm](https://github.com/ryangoree/drift/commit/5f95b401ec8b96c2d5cc4ca62317d1823ee3397d)
- [.gitignore](https://github.com/ryangoree/drift/blob/main/.gitignore)
- [Add GEMINI.md to gitignore](https://github.com/ryangoree/drift/commit/72f62fffd716254a71ed477d062b987744577db5)
- [.gitmodules](https://github.com/ryangoree/drift/blob/main/.gitmodules)
- [Implement call with support for bytecode (deployless) calls](https://github.com/ryangoree/drift/commit/81e536207028682fb8c51be8a64e56fafd0723d6)
- [.nvmrc](https://github.com/ryangoree/drift/blob/main/.nvmrc)
- [Bump deps](https://github.com/ryangoree/drift/commit/946c12fdcb9e909850820bd2b7c6a7d6cf432f8b)
- [.prettierrc.cjs](https://github.com/ryangoree/drift/blob/main/.prettierrc.cjs)
- [Change prettier to cjs](https://github.com/ryangoree/drift/commit/8bdf9eef2071b51b3a1a7cb08d5b9fe52d1aaca1)
- [LICENSE](https://github.com/ryangoree/drift/blob/main/LICENSE)
- [Enter Drift (](https://github.com/ryangoree/drift/commit/41602c0e689bdb651f81ae10f48d1c1e6b2e1381)
- [#86](https://github.com/ryangoree/drift/pull/86)
- [README.md](https://github.com/ryangoree/drift/blob/main/README.md)
- [Add @types/sinon to peer deps, update README and docs](https://github.com/ryangoree/drift/commit/96d81f212da2038610230cfe42f632c036872a30)
- [biome.json](https://github.com/ryangoree/drift/blob/main/biome.json)
- [Update example app](https://github.com/ryangoree/drift/commit/70f7deb419e5cf2a705bd2f7c528ff74a16d79cb)
- [package.json](https://github.com/ryangoree/drift/blob/main/package.json)
- [turbo.json](https://github.com/ryangoree/drift/blob/main/turbo.json)
- [Update getBlock in viem](https://github.com/ryangoree/drift/commit/d1e1809f42a9efd1b2d6980a692644ead553f839)
- [yarn.lock](https://github.com/ryangoree/drift/blob/main/yarn.lock)
- [README](https://github.com/delvtech/drift#)
- [viem](https://viem.sh/)
- [web3.js](https://web3js.org/)
- [ethers](https://ethers.org/)
- [Installation](https://github.com/delvtech/drift#installation)
- [Start Drifting](https://github.com/delvtech/drift#start-drifting)
- [1. Create a Drift client](https://github.com/delvtech/drift#1-create-a-drift-client)
- [2. Interact with your Contracts](https://github.com/delvtech/drift#2-interact-with-your-contracts)
- [Read Operations with Caching](https://github.com/delvtech/drift#read-operations-with-caching)
- [Write Operations](https://github.com/delvtech/drift#write-operations)
- [Deployments](https://github.com/delvtech/drift#deployments)
- [Contract Instances](https://github.com/delvtech/drift#contract-instances)
- [Example: Building Vault Clients](https://github.com/delvtech/drift#example-building-vault-clients)
- [1. Define vault clients](https://github.com/delvtech/drift#1-define-vault-clients)
- [2. Use the clients in your application](https://github.com/delvtech/drift#2-use-the-clients-in-your-application)
- [Benefits of This Architecture](https://github.com/delvtech/drift#benefits-of-this-architecture)
- [3. Test Your Clients with Drift's Built-in Mocks](https://github.com/delvtech/drift#3-test-your-clients-with-drifts-built-in-mocks)
- [Example: Testing Client Methods with Multiple RPC Calls](https://github.com/delvtech/drift#example-testing-client-methods-with-multiple-rpc-calls)
- [Benefits](https://github.com/delvtech/drift#benefits)
- [Simplifying React Hook Management](https://github.com/delvtech/drift#simplifying-react-hook-management)
- [The Problem Without Drift](https://github.com/delvtech/drift#the-problem-without-drift)
- [How Drift Helps](https://github.com/delvtech/drift#how-drift-helps)
- [Example Using React Query](https://github.com/delvtech/drift#example-using-react-query)
- [Caching in Action](https://github.com/delvtech/drift#caching-in-action)
- [Cache Invalidation](https://github.com/delvtech/drift#cache-invalidation)
- [Preloading Cache Data](https://github.com/delvtech/drift#preloading-cache-data)
- [Direct Access to Cached Data](https://github.com/delvtech/drift#direct-access-to-cached-data)
- [Extending Drift for Your Needs](https://github.com/delvtech/drift#extending-drift-for-your-needs)
- [Extension Points](https://github.com/delvtech/drift#extension-points)
- [Adapters](https://github.com/delvtech/drift#adapters)
- [Stores](https://github.com/delvtech/drift#stores)
- [Hooks](https://github.com/delvtech/drift#hooks)
- [Contributing](https://github.com/delvtech/drift#contributing-ov-file)
- [License](https://github.com/delvtech/drift#license)
- [Sinon.JS](https://sinonjs.org/releases/v17/)
- [Adapter](https://github.com/ryangoree/drift/blob/main/packages/drift/src/adapter/types/Adapter.ts#L23)
- [Clients](https://github.com/ryangoree/drift/blob/main/packages/drift/src/client/Client.ts#L30)
- [Drift](https://github.com/ryangoree/drift/blob/main/packages/drift/src/client/Drift.ts#L27)
- [DefaultAdapter](https://github.com/ryangoree/drift/blob/main/packages/drift/src/adapter/DefaultAdapter.ts#L57)
- [Store](https://github.com/ryangoree/drift/blob/main/packages/drift/src/store/Store.ts#L7)
- [QueryClient](https://tanstack.com/query/latest/docs/reference/QueryClient)
- [Contributing Guide](https://github.com/ryangoree/drift/blob/main/.github/CONTRIBUTING.md)
- [ryangoree.github.io/drift/](https://ryangoree.github.io/drift/)
- [Readme](https://github.com/delvtech/drift#readme-ov-file)
- [Apache-2.0 license](https://github.com/delvtech/drift#Apache-2.0-1-ov-file)
- [Activity](https://github.com/ryangoree/drift/activity)
- [9 forks](https://github.com/ryangoree/drift/forks)
- [Report repository](https://github.com/contact/report-content?content_url=https%3A%2F%2Fgithub.com%2Fryangoree%2Fdrift&report=ryangoree+%28user%29)
- [Releases](https://github.com/ryangoree/drift/releases)
- [@delvtech/drift@1.0.1LatestSep 6, 2025](https://github.com/ryangoree/drift/releases/tag/%40delvtech%2Fdrift%401.0.1)
- [Contributors](https://github.com/ryangoree/drift/graphs/contributors)
- [TypeScript99%](https://github.com/ryangoree/drift/search?l=typescript)
- [Other1%](https://github.com/ryangoree/drift/search?l=Other)
- [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
- [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
- [Status](https://www.githubstatus.com/)
- [Community](https://github.community/)
- [Contact](https://support.github.com/?tags=dotcom-footer)
