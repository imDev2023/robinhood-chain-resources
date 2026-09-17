Title: Deploy a Contract

URL Source: https://docs.robinhood.com/chain/deploy-smart-contracts

Markdown Content:
[Skip to content](https://docs.robinhood.com/chain/deploy-smart-contracts#vocs-content)

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

Deploy a Contract

On this page

[Ask in ChatGPT](https://chatgpt.com/?hints=search&q=Please%20research%20and%20analyze%20this%20page%3A%20https%3A%2F%2Fdocs.robinhood.com%2Fchain%2Fdeploy-smart-contracts%20so%20I%20can%20ask%20you%20questions%20about%20it.%20Once%20you%20have%20read%20it%2C%20prompt%20me%20with%20any%20questions%20I%20have.%20Do%20not%20post%20content%20from%20the%20page%20in%20your%20response.%20Any%20of%20my%20follow%20up%20questions%20must%20reference%20the%20site%20I%20gave%20you.)

## On this page

*   [Prerequisites](https://docs.robinhood.com/chain/deploy-smart-contracts#prerequisites)
*   [Deploy with Foundry](https://docs.robinhood.com/chain/deploy-smart-contracts#deploy-with-foundry)

    *   [1. Install Foundry](https://docs.robinhood.com/chain/deploy-smart-contracts#1-install-foundry)
    *   [2. Create a project](https://docs.robinhood.com/chain/deploy-smart-contracts#2-create-a-project)
    *   [3. Create a contract](https://docs.robinhood.com/chain/deploy-smart-contracts#3-create-a-contract)
    *   [4. Deploy](https://docs.robinhood.com/chain/deploy-smart-contracts#4-deploy)
    *   [5. Verify on Block Explorer](https://docs.robinhood.com/chain/deploy-smart-contracts#5-verify-on-block-explorer)

*   [Deploy with Hardhat](https://docs.robinhood.com/chain/deploy-smart-contracts#deploy-with-hardhat)

    *   [1. Create a project](https://docs.robinhood.com/chain/deploy-smart-contracts#1-create-a-project)
    *   [2. Configure Robinhood Chain](https://docs.robinhood.com/chain/deploy-smart-contracts#2-configure-robinhood-chain)
    *   [3. Create a contract](https://docs.robinhood.com/chain/deploy-smart-contracts#3-create-a-contract-1)
    *   [4. Compile and Deploy](https://docs.robinhood.com/chain/deploy-smart-contracts#4-compile-and-deploy)
    *   [5. Verify on Block Explorer](https://docs.robinhood.com/chain/deploy-smart-contracts#5-verify-on-block-explorer-1)

    

# Deploy a Contract[](https://docs.robinhood.com/chain/deploy-smart-contracts#deploy-a-contract)

Robinhood Chain is fully EVM-compatible, so smart contracts written in Solidity or Vyper deploy without modification using standard Ethereum tooling. This guide covers deploying a simple contract with Foundry or Hardhat — pick whichever you prefer.

## Prerequisites[](https://docs.robinhood.com/chain/deploy-smart-contracts#prerequisites)

Before you begin, you'll need:

*   A wallet with ETH on Robinhood Chain for gas — see [Add network to your wallet](https://docs.robinhood.com/chain/add-network-to-wallet).
*   The network details below.

| Property | Mainnet | Testnet |
| --- | --- | --- |
| Network | Robinhood Chain | Robinhood Chain Testnet |
| Chain ID | 4663 | 46630 |
| RPC URL | `https://rpc.mainnet.chain.robinhood.com` | `https://rpc.testnet.chain.robinhood.com` |
| Block Explorer | [robinhoodchain.blockscout.com](https://robinhoodchain.blockscout.com/) | [explorer.testnet.chain.robinhood.com](https://explorer.testnet.chain.robinhood.com/) |

_We recommend deploying to testnet first. The steps below target mainnet — to deploy to testnet instead, use the testnet values above: set `RH\_RPC\_URL` to the testnet RPC, use chain ID 46630, and verify against `https://explorer.testnet.chain.robinhood.com/api/`._

_Security note: Never commit a real private key. Use an environment variable, and prefer a throwaway deployer key for testing._

## Deploy with Foundry[](https://docs.robinhood.com/chain/deploy-smart-contracts#deploy-with-foundry)

### 1. Install Foundry[](https://docs.robinhood.com/chain/deploy-smart-contracts#1-install-foundry)

If Foundry is already installed, skip this step. Run the installer and follow the prompts:

```
# Install foundryup
curl -L https://foundry.paradigm.xyz | bash
 
# Install forge, anvil, cast, and chisel
foundryup
```

### 2. Create a project[](https://docs.robinhood.com/chain/deploy-smart-contracts#2-create-a-project)

```
# Initialize a new project
mkdir rh-deploy && cd rh-deploy
forge init
```

### 3. Create a contract[](https://docs.robinhood.com/chain/deploy-smart-contracts#3-create-a-contract)

Create `src/HelloRobinhood.sol` with the following content:

```
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
 
contract HelloRobinhood {
    function hello() external pure returns (string memory) {
        return "Hello, Robinhood Chain!";
    }
}
```

### 4. Deploy[](https://docs.robinhood.com/chain/deploy-smart-contracts#4-deploy)

```
# Set environment variables
export PRIVATE_KEY=0x<your_private_key>
export RH_RPC_URL=https://rpc.mainnet.chain.robinhood.com
 
# Deploy contract
forge create HelloRobinhood \
  --rpc-url $RH_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### 5. Verify on Block Explorer[](https://docs.robinhood.com/chain/deploy-smart-contracts#5-verify-on-block-explorer)

```
# Verify the contract on Blockscout
forge verify-contract <contract_address> \
  src/HelloRobinhood.sol:HelloRobinhood \
  --chain-id 4663 \
  --rpc-url $RH_RPC_URL \
  --verifier blockscout \
  --verifier-url https://robinhoodchain.blockscout.com/api/
```

After verification, view your contract at `https://robinhoodchain.blockscout.com/address/<contract_address>`.

## Deploy with Hardhat[](https://docs.robinhood.com/chain/deploy-smart-contracts#deploy-with-hardhat)

### 1. Create a project[](https://docs.robinhood.com/chain/deploy-smart-contracts#1-create-a-project)

Initialize your environment and Hardhat project:

```
# Initialize project and install Hardhat
mkdir rh-deploy && cd rh-deploy
npm init -y
npm install --save-dev hardhat
npx hardhat init
```

### 2. Configure Robinhood Chain[](https://docs.robinhood.com/chain/deploy-smart-contracts#2-configure-robinhood-chain)

Update `hardhat.config.js` with the network settings:

```
require("@nomicfoundation/hardhat-toolbox");
 
module.exports = {
  solidity: "0.8.13",
  networks: {
    robinhood: {
      url: process.env.RH_RPC_URL,
      chainId: 4663,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: { robinhood: "empty" },
    customChains: [
      {
        network: "robinhood",
        chainId: 4663,
        urls: {
          apiURL: "https://robinhoodchain.blockscout.com/api",
          browserURL: "https://robinhoodchain.blockscout.com/",
        },
      },
    ],
  },
};
```

Set your environment variables before proceeding:

```
export PRIVATE_KEY=0x<your_private_key>
export RH_RPC_URL=https://rpc.mainnet.chain.robinhood.com
```

### 3. Create a contract[](https://docs.robinhood.com/chain/deploy-smart-contracts#3-create-a-contract-1)

Create `contracts/HelloRobinhood.sol`:

```
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
 
contract HelloRobinhood {
    function hello() external pure returns (string memory) {
        return "Hello, Robinhood Chain!";
    }
}
```

### 4. Compile and Deploy[](https://docs.robinhood.com/chain/deploy-smart-contracts#4-compile-and-deploy)

Create `scripts/deploy.js` and then execute the deployment command:

```
const hre = require("hardhat");
 
async function main() {
  const contract = await hre.ethers.deployContract("HelloRobinhood");
  await contract.waitForDeployment();
  console.log("Deployed to:", await contract.getAddress());
}
 
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

```
# Compile and run deployment script
npx hardhat compile
npx hardhat run scripts/deploy.js --network robinhood
```

### 5. Verify on Block Explorer[](https://docs.robinhood.com/chain/deploy-smart-contracts#5-verify-on-block-explorer-1)

```
# Verify the contract on Blockscout
npx hardhat verify --network robinhood <contract_address>
```

After verification, view your contract at `https://robinhoodchain.blockscout.com/address/<contract_address>`.

[Protocol Contracts Previous shift←](https://docs.robinhood.com/chain/protocol-contracts)[Account Abstraction Next shift→](https://docs.robinhood.com/chain/account-abstraction)

Your Privacy Choices![Image 7](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/privacy-options.svg)
