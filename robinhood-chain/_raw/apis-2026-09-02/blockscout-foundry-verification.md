Title: Verify smart contracts with Foundry Forge - Blockscout

URL Source: https://docs.blockscout.com/devs/verification/foundry-verification

Markdown Content:
> ## Documentation Index
> 
> 
> Fetch the complete documentation index at:[/llms.txt](https://docs.blockscout.com/llms.txt)
> 
> 
> Use this file to discover all available pages before exploring further.

[Skip to main content](https://docs.blockscout.com/devs/verification/foundry-verification#content-area)

[Blockscout home page![Image 1: light logo](https://mintcdn.com/blockscout/cNJj4Zpe0FBD2sXC/logo/Color_BS_logo_hor.svg?fit=max&auto=format&n=cNJj4Zpe0FBD2sXC&q=85&s=7cffdcbb354b1aa090d9f7d3ca4f3452)![Image 2: dark logo](https://mintcdn.com/blockscout/cNJj4Zpe0FBD2sXC/logo/White_BS_logo_hor.svg?fit=max&auto=format&n=cNJj4Zpe0FBD2sXC&q=85&s=79d28502f70131c02702daa820d2345b)](https://www.blockscout.com/)

Search...

Ctrl K Ask Assistant CTRL I

*   [Support](https://discord.gg/blockscout)
*   [blockscout/blockscout 4,661](https://github.com/blockscout/blockscout "blockscout/blockscout")
*   [blockscout/blockscout 4,661](https://github.com/blockscout/blockscout "blockscout/blockscout")

Search...

Navigation

Smart Contract Verification

Verify smart contracts with Foundry Forge

[Guides](https://docs.blockscout.com/)[API Reference](https://docs.blockscout.com/devs/apis)[About Blockscout](https://docs.blockscout.com/about/features)

*   [Community](https://discord.gg/blockscout)
*   [Blog](https://www.blog.blockscout.com/)
*   [API Docs](https://docs.blockscout.com/devs/apis)

### Get Started

*   [Blockscout blockchain explorer documentation](https://docs.blockscout.com/)
*   [Using Blockscout](https://docs.blockscout.com/get-started/using-an-explorer)
*   [Developer Integration](https://docs.blockscout.com/get-started/integrating-data)
*   [Setup & Configuration](https://docs.blockscout.com/get-started/running-blockscout)
*   [Migration Guide](https://docs.blockscout.com/get-started/migration-guide)

### Using Blockscout

*    Overview  
*    My Account  
*    Dappscout Apps Marketplace  
*   [Widgets: 3rd-Party Data on Address and Contract Pages](https://docs.blockscout.com/using-blockscout/widgets)
*    Essential Dapps  
*    Merits  
*   [CSV Exports](https://docs.blockscout.com/using-blockscout/export-to-csv)
*    Token Support  

### Developer Support

*   [For Web3 Developers](https://docs.blockscout.com/devs/for-web3-developers)
*   [Link to Blockscout](https://docs.blockscout.com/devs/replace-links)
*   [Blockscout APIs](https://docs.blockscout.com/devs/apis)
*    Wallet as a Service (WaaS)  
*    Smart Contract Verification  
    *   [Overview](https://docs.blockscout.com/devs/verification)
    *   [Verify contracts using the Blockscout UI](https://docs.blockscout.com/devs/verification/blockscout-ui)
    *   Hardhat Verification Plugin  
    *   [Verify smart contracts with Foundry Forge](https://docs.blockscout.com/devs/verification/foundry-verification)
    *   [Verify contracts via Sourcify on Blockscout](https://docs.blockscout.com/devs/verification/contracts-verification-via-sourcify)
    *   [Verify contracts with the Remix IDE plugin](https://docs.blockscout.com/devs/verification/remix-verification)
    *   [Verify contracts via thirdweb on Blockscout](https://docs.blockscout.com/devs/verification/verification-via-thirdweb)
    *   [Stylus Verification](https://docs.blockscout.com/devs/verification/stylus-verification)
    *   [Interacting with Smart Contracts](https://docs.blockscout.com/devs/verification/interacting-with-smart-contracts)
    *   [Smart contract verification websocket events](https://docs.blockscout.com/devs/verification/websocket-notifications)

*   [MCP Server](https://docs.blockscout.com/devs/mcp-server)
*   [Blockscout SDK](https://docs.blockscout.com/devs/blockscout-sdk)
*   [Chainscout Chains List](https://docs.blockscout.com/devs/chainscout-chains-list)
*   [Blockscout Software Licence](https://docs.blockscout.com/devs/blockscout-license)

### Setup and Run Blockscout

*    Autoscout 1-click Launchpad  
*    General Overview  
*    Requirements  
*    ENV Variables  
*    Deployment  
*    Microservices  
*    Configuration Options  
*    Indexing  
*   [Celestia Node and Indexer for Blockscout](https://docs.blockscout.com/setup/celestia-node-indexer)
*   [Testing](https://docs.blockscout.com/setup/testing)
*   [Blockscout Database Schema Reference](https://docs.blockscout.com/setup/db-schema)

### FAQs

*   [User FAQs](https://docs.blockscout.com/faqs/faqs)
*   [Developer FAQs](https://docs.blockscout.com/faqs/developer-faqs)

### Resources

*   [EaaS: Hosting with Blockscout](https://docs.blockscout.com/resources/premium-features)
*   [Contributing to Blockscout](https://docs.blockscout.com/resources/contributing-to-blockscout)
*   [Security Program](https://docs.blockscout.com/resources/security-program)
*   [Media Kit](https://docs.blockscout.com/resources/media-kit)
*   [Release Notes](https://docs.blockscout.com/resources/release-notes)
*   [Discord Channel](https://discord.gg/blockscout)
*   [Discussion](https://github.com/blockscout/blockscout/discussions)
*   [GitHub Repo](https://github.com/poanetwork/blockscout)

## On this page

*   [Verify contract](https://docs.blockscout.com/devs/verification/foundry-verification#verify-contract)
    *   [Tips:](https://docs.blockscout.com/devs/verification/foundry-verification#tips)
    *   [Example (Deploy and verify)](https://docs.blockscout.com/devs/verification/foundry-verification#example-deploy-and-verify)
    *   [Example (Verify already deployed contract)](https://docs.blockscout.com/devs/verification/foundry-verification#example-verify-already-deployed-contract)

Smart Contract Verification

# Verify smart contracts with Foundry Forge

Copy page Copy page

Verify Solidity smart contracts on Blockscout directly from the Foundry toolchain using Forge’s built-in verification support and CLI flags.

Copy page Copy page

[Foundry](https://github.com/foundry-rs/foundry/) is a smart contract development toolchain. Foundry manages your dependencies, compiles your project, runs tests, deploys, and lets you interact with the chain from the command line and via Solidity scripts.Forge is a command-line tool that ships with Foundry. Forge tests, builds, and deploys your smart contracts. Forge supports contract verification out of the box ([https://www.getfoundry.sh/reference/forge/verify-contract](https://www.getfoundry.sh/reference/forge/verify-contract))
## [​](https://docs.blockscout.com/devs/verification/foundry-verification#verify-contract)

Verify contract

In forge, contracts can be verified at the time of the deployment (e.g. using `forge script`), or later, if the contracts are already deployed (e.g. using `forge verify-contract`).
#### [​](https://docs.blockscout.com/devs/verification/foundry-verification#tips)

Tips:

1.   Specify the `--verifier=blockscout` flag to use the Blockscout verification provider. API key for Blockscout verification is optional.
2.   Specify the `--verifier-url=<blockscout_homepage_explorer_url>/api/` flag for connecting to a specific Blockscout instance (e.g., `--verifier-url=https://eth-sepolia.blockscout.com/api/`).
3.   You can specify most configuration options (e.g., evm version, disabling optimizations) via the usual [Forge configuration](https://www.getfoundry.sh/config/compiler).

### [​](https://docs.blockscout.com/devs/verification/foundry-verification#example-deploy-and-verify)

Example (Deploy and verify)

Verify a contract with Blockscout right after deployment (make sure you add “/api/” to the end of the Blockscout homepage explorer URL):

```
forge create \
  --rpc-url <rpc_https_endpoint> \
  --private-key $PRIVATE_KEY \
  <contract_file>:<contract_name> \
  --verify \
  --verifier blockscout \
  --verifier-url <blockscout_homepage_explorer_url>/api/
```

Or if using foundry scripts:

```
forge script <script_file> \
  --rpc-url <rpc_https_endpoint> \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --verifier blockscout \
  --verifier-url <blockscout_homepage_explorer_url>/api/
```

### [​](https://docs.blockscout.com/devs/verification/foundry-verification#example-verify-already-deployed-contract)

Example (Verify already deployed contract)

```
forge verify-contract \
  --rpc-url <rpc_https_endpoint> \
  <address> \
  <contract_file>:<contract_name> \
  --verifier blockscout \
  --verifier-url <blockscout_homepage_explorer_url>/api/
```

Or if using foundry scripts for last executed script run:

```
forge script <script_file> \
  --rpc-url <rpc_https_endpoint> \
  --private-key $PRIVATE_KEY \
  --resume \
  --verify \
  --verifier blockscout \
  --verifier-url <blockscout_homepage_explorer_url>/api/
```

Was this page helpful?

Yes No

[Sourcify plugin for Hardhat Previous](https://docs.blockscout.com/devs/verification/hardhat-verification-plugin/sourcify-plugin-for-hardhat)[Verify contracts via Sourcify on Blockscout Next](https://docs.blockscout.com/devs/verification/contracts-verification-via-sourcify)

[github](https://github.com/blockscout/blockscout)[telegram](https://t.me/blockscoutcommunity)[discord](https://discord.gg/blockscout)[x](https://x.com/blockscout)

[Powered by This documentation is built and hosted on Mintlify, a developer documentation platform](https://www.mintlify.com/?utm_campaign=poweredBy&utm_medium=referral&utm_source=blockscout)

Assistant

Responses are generated using AI and may contain mistakes.
