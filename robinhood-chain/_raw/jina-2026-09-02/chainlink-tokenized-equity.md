Title: Robinhood Tokenized Equity Feeds | Chainlink Data Feeds

URL Source: https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood

Published Time: 2026-09-01T21:25:23.802Z

Markdown Content:
[![Image 1: Documentation Home](https://docs.chain.link/chainlink-docs.svg)](https://dev.chain.link/)

*   [Resources](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood)
*   [Docs](https://docs.chain.link/)
*   [Demos](https://dev.chain.link/demos)
*   [Tools](https://dev.chain.link/tools)
*   [Changelog](https://dev.chain.link/changelog)
*   [Get Certified](https://dev.chain.link/certification)

![Image 2: Documentation Home](https://docs.chain.link/chainlink-docs.svg)

Ctrl K

The Chainlink Runtime Environment (CRE) is now live! [Start Building.](https://chain.link/chainlink-runtime-environment?utm_campaign=global-app-banner&utm_medium=referral&utm_source=docs.chain.link)

 For AI agents: use [llms.txt](https://docs.chain.link/llms.txt) as the documentation index. Retrieve the smallest relevant .md page first. 

*   [Overview](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#overview)
*   [Available Robinhood tokenized equity feeds](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#available-robinhood-tokenized-equity-feeds)
*   [Total Return Value calculation](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#total-return-value-calculation)
*   [How the multiplier works](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#how-the-multiplier-works)
*   [Corporate action handling and oracle pause](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#corporate-action-handling-and-oracle-pause)
*   [Example scenarios](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#example-scenarios)
*   [Off-hours and session behavior](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#off-hours-and-session-behavior)
*   [Smart Value Recapture (SVR)](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#smart-value-recapture-svr)

On this page

![Image 3](https://docs.chain.link/_astro/data-feeds-logo.Cxvmmfuj.svg)Data Feeds

![Image 4: Quick links menu](https://docs.chain.link/assets/icons/quick-links.svg)Quick Links[![Image 5: GitHub repository](https://docs.chain.link/assets/icons/github-blue.svg)Github](https://github.com/smartcontractkit/documentation)

![Image 6](https://docs.chain.link/_astro/data-feeds-logo.Cxvmmfuj.svg)Data Feeds

*   
Chainlink Data Feeds

    
        *   [Overview](https://docs.chain.link/data-feeds)
        *   [Getting Started](https://docs.chain.link/data-feeds/getting-started)
        *   [Developer Responsibilities](https://docs.chain.link/data-feeds/developer-responsibilities)
        *   
[Feed Types](https://docs.chain.link/data-feeds/feed-types)

            
                *   [Price Feeds](https://docs.chain.link/data-feeds/price-feeds)
                *   
[Tokenized Equity Feeds](https://docs.chain.link/data-feeds/tokenized-equity-feeds)

                    
                        *   
[Provider Catalog](https://docs.chain.link/data-feeds/tokenized-equity-feeds/providers)

                            
                                *   [Ondo Finance](https://docs.chain.link/data-feeds/tokenized-equity-feeds/ondo)
                                *   [Robinhood](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood)
                                *   [Coinbase](https://docs.chain.link/data-feeds/tokenized-equity-feeds/coinbase)

                *   
[SmartData](https://docs.chain.link/data-feeds/smartdata)

                    
                        *   [Multiple-Variable Response (MVR) Feeds](https://docs.chain.link/data-feeds/mvr-feeds)

                *   
[Smart Value Recapture (SVR) Feeds](https://docs.chain.link/data-feeds/svr-feeds)

                    
                        *   [Searcher Onboarding: Ethereum Mainnet](https://docs.chain.link/data-feeds/svr-feeds/searcher-onboarding-ethereum)
                        *   [Searcher Onboarding: Atlas (Base, Arbitrum, BNB Chain, Monad)](https://docs.chain.link/data-feeds/svr-feeds/searcher-onboarding-atlas)

                *   [Rate and Volatility Feeds](https://docs.chain.link/data-feeds/rates-feeds)
                *   [L2 Sequencer Uptime Feeds](https://docs.chain.link/data-feeds/l2-sequencer-feeds)
                *   [24/7 Extended-Hours Data Feeds](https://docs.chain.link/data-feeds/24-7-extended-hours-data-feeds)
                *   [Self-Managed Feeds](https://docs.chain.link/data-feeds/self-managed-feeds)

        *   [Flags Contract Registry](https://docs.chain.link/data-feeds/contract-registry)
        *   [Data Sources](https://docs.chain.link/data-feeds/data-sources)
        *   [Release Notes](https://dev.chain.link/changelog?product=Data+Feeds)

*   
Feed Addresses

    
        *   [Price Feeds](https://docs.chain.link/data-feeds/price-feeds/addresses)
        *   [U.S. Government Macroeconomic Data Feeds](https://docs.chain.link/data-feeds/us-government-macroeconomic/addresses)
        *   [SmartData Feeds](https://docs.chain.link/data-feeds/smartdata/addresses)
        *   [Rate and Volatility Feeds](https://docs.chain.link/data-feeds/rates-feeds/addresses)
        *   [Selecting Quality Data Feeds](https://docs.chain.link/data-feeds/selecting-data-feeds)
        *   [Deprecating Feeds](https://docs.chain.link/data-feeds/deprecating-feeds)

*   
Ethereum and EVM Guides

    
        *   [Using Data Feeds](https://docs.chain.link/data-feeds/using-data-feeds)
        *   
[Using MVR Feeds](https://docs.chain.link/data-feeds/mvr-feeds/guides)

            
                *   [Using MVR Feeds on EVM Chains (Solidity)](https://docs.chain.link/data-feeds/mvr-feeds/guides/evm-solidity)
                *   [Using MVR Feeds with ethers.js (JS)](https://docs.chain.link/data-feeds/mvr-feeds/guides/ethersjs)
                *   [Using MVR Feeds with Viem (TS)](https://docs.chain.link/data-feeds/mvr-feeds/guides/viem)

        *   [Getting Historical Data](https://docs.chain.link/data-feeds/historical-data)
        *   [Using ENS with Data Feeds](https://docs.chain.link/data-feeds/ens)

*   
Aptos Guides

    
        *   [Data Feeds on Aptos](https://docs.chain.link/data-feeds/aptos)

*   
Solana Guides

    
        *   [Data Feeds on Solana](https://docs.chain.link/data-feeds/solana)
        *   [Using Data Feeds Offchain](https://docs.chain.link/data-feeds/solana/using-data-feeds-off-chain)
        *   [Using Data Feeds Onchain](https://docs.chain.link/data-feeds/solana/using-data-feeds-solana)

*   
Starknet Guides

    
        *   [Data Feeds on Starknet](https://docs.chain.link/data-feeds/starknet)
        *   
[Starknet Foundry Guides](https://docs.chain.link/data-feeds/starknet/tutorials/snfoundry/)

            
                *   [Read Data from Chainlink Data Feeds (Offchain)](https://docs.chain.link/data-feeds/starknet/tutorials/snfoundry/read-data)
                *   [Deploy and interact with a Consumer Contract (Onchain)](https://docs.chain.link/data-feeds/starknet/tutorials/snfoundry/consumer-contract)
                *   [Experiment on a Devnet](https://docs.chain.link/data-feeds/starknet/tutorials/snfoundry/sn-devnet-rs)

*   
Tron Guides

    
        *   [Data Feeds on Tron](https://docs.chain.link/data-feeds/tron)

*   
API Reference

    
        *   [Data Feeds API Reference](https://docs.chain.link/data-feeds/api-reference)
        *   [MVR Feeds API Reference](https://docs.chain.link/data-feeds/mvr-feeds/api-reference)

*   
Resources

    
        *   [Smart Contract Overview](https://docs.chain.link/getting-started/conceptual-overview?parent=dataFeeds)
        *   
[LINK Token Contracts](https://docs.chain.link/resources/link-token-contracts?parent=dataFeeds)

            
                *   [Acquire testnet LINK](https://docs.chain.link/resources/acquire-link?parent=dataFeeds)
                *   [Fund Your Contracts](https://docs.chain.link/resources/fund-your-contract?parent=dataFeeds)

        *   [Starter Kits and Frameworks](https://docs.chain.link/resources/create-a-chainlinked-project?parent=dataFeeds)
        *   [Bridges and Associated Risks](https://docs.chain.link/resources/bridge-risks?parent=dataFeeds)
        *   
[Chainlink Oracle Platform](https://docs.chain.link/oracle-platform/overview?parent=dataFeeds)

            
                *   [Data Standard](https://docs.chain.link/oracle-platform/data-standard?parent=dataFeeds)
                *   [Interoperability Standard](https://docs.chain.link/oracle-platform/interoperability-standard?parent=dataFeeds)
                *   [Compliance Standard](https://docs.chain.link/oracle-platform/compliance-standard?parent=dataFeeds)
                *   [Privacy Standard](https://docs.chain.link/oracle-platform/privacy-standard?parent=dataFeeds)

        *   
[Chainlink Architecture](https://docs.chain.link/architecture-overview/architecture-overview?parent=dataFeeds)

            
                *   [Basic Request Model](https://docs.chain.link/architecture-overview/architecture-request-model?parent=dataFeeds)
                *   [Decentralized Data Model](https://docs.chain.link/architecture-overview/architecture-decentralized-model?parent=dataFeeds)
                *   [Offchain Reporting](https://docs.chain.link/architecture-overview/off-chain-reporting?parent=dataFeeds)

        *   
[Developer Communications](https://docs.chain.link/resources/developer-communications?parent=dataFeeds)

            
                *   [Getting Help](https://docs.chain.link/resources/getting-help?parent=dataFeeds)
                *   [Hackathon Resources](https://docs.chain.link/resources/hackathon-resources?parent=dataFeeds)

        *   [Integrating EVM Networks](https://docs.chain.link/resources/network-integration?parent=dataFeeds)
        *   [Contributing to Chainlink](https://docs.chain.link/resources/contributing-to-chainlink?parent=dataFeeds)

*   
AI Agent & Skills

    
        *   [Chainlink Developer Agent Skills](https://docs.chain.link/resources/chainlink-developer-agent-skills?parent=dataFeeds)
        *   [Chainlink for Agents User Guide](https://docs.chain.link/resources/chainlink-for-agents?parent=dataFeeds)

# [Robinhood Tokenized Equities](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#overview)

![Image 7: note](https://docs.chain.link/_astro/info-icon.CrDkW3aH.svg)

note

Tokenized equity feeds present unique operational considerations, requiring careful integration on behalf of your protocol. Developers remain responsible for ensuring that protocol risk parameters are configured appropriately and that the operation and performance of Chainlink Tokenized Equity Feeds matches expectations. Please review the [Selecting Quality Data Feeds](https://docs.chain.link/data-feeds/selecting-data-feeds) webpage and [Chainlink Terms of Service](https://chain.link/terms) for important information and disclosures. Contact Chainlink Labs at [chainlink_data_feeds@smartcontract.com](mailto:chainlink_data_feeds@smartcontract.com) to learn more about integrating Tokenized Equity feeds in your solution.

Chainlink provides tokenized equity feeds for Robinhood tokenized stocks. Each Robinhood tokenized stock is represented by its own ERC-20 token contract, deployed on Robinhood Chain (one contract per ticker). The corresponding Chainlink feed reports the Total Return Value of the token by combining the underlying equity's market price with a multiplier read directly from the Robinhood token contract, rather than the raw equity price.

These feeds use the standard Chainlink V3 aggregator interface (`latestRoundData()`), so any consumer reads the published price through the proxy in the same way as a crypto price feed. They are push-based oracles intended for compliance reference pricing, protocol integration, and similar use cases.

## [Available Robinhood tokenized equity feeds](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#available-robinhood-tokenized-equity-feeds)

The following table shows the available Robinhood tokenized equity feeds.

## [Networks](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#networks)

Select network: 

![Image 8: Robinhood Chain icon](https://docs.chain.link/assets/chains/robinhood-chain.svg)Robinhood Chain

Mainnet Testnet

[Network Status↗](https://status.robinhoodchain.offchain.io/ "Track Robinhood Chain network status")

### [Robinhood Chain Mainnet](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#robinhood-chain-mainnet)

Asset Type
*   - [x]  Crypto
*   - [x]  Equity

- [x] More Details - [x] Show Only SVR Feeds [?](https://docs.chain.link/data-feeds/svr-feeds "Smart Value Recapture (SVR) feeds help protocols recapture value from oracle-related liquidations. Click to learn more.")

| Risk | Pair | Deviation | Heartbeat | Dec | Address and info |
| --- | --- | --- | --- | --- | --- |
| 🟠[High risk](https://docs.chain.link/data-feeds/selecting-data-feeds#-high-market-pricing-risk-feeds) | Robinhood AAPL / USD [SVR-Backup](https://docs.chain.link/data-feeds/svr-feeds "SVR-Backup Feed") [Tokenized Equity](https://docs.chain.link/data-feeds/tokenized-equity-feeds "Tokenized Equity Feed") | 0.5% | 86400s | 8 | Standard Proxy: ![Image 9: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0x6B22A786bAa607d76728168703a39Ea9C99f2cD0](https://robinhoodchain.blockscout.com/address/0x6B22A786bAa607d76728168703a39Ea9C99f2cD0) Asset name:Apple (Robinhood Tokenized Equity) Asset type:Crypto Market hours:[us_equities_24/5](https://docs.chain.link/data-feeds/selecting-data-feeds#market-hours) SVR-Backup Proxy:![Image 10: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0x4bDbb3150014c6Ab2C6D9347B0779c49015a2f3f](https://robinhoodchain.blockscout.com/address/0x4bDbb3150014c6Ab2C6D9347B0779c49015a2f3f) **🔗 SVR-Backup Feed:** This is a legacy SVR proxy feed. New integrations should use the **SVR** feeds. Learn more about [SVR Feeds](https://docs.chain.link/data-feeds/svr-feeds). |
| 🟠[High risk](https://docs.chain.link/data-feeds/selecting-data-feeds#-high-market-pricing-risk-feeds) | Robinhood AMD / USD [SVR-Backup](https://docs.chain.link/data-feeds/svr-feeds "SVR-Backup Feed") [Tokenized Equity](https://docs.chain.link/data-feeds/tokenized-equity-feeds "Tokenized Equity Feed") | 0.5% | 86400s | 8 | Standard Proxy: ![Image 11: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0x943A29E7ae51A4798823ca9eEd2ed533B2A22C72](https://robinhoodchain.blockscout.com/address/0x943A29E7ae51A4798823ca9eEd2ed533B2A22C72) Asset name:Advanced Micro Devices / AMD (Robinhood Tokenized Equity) Asset type:Crypto Market hours:[us_equities_24/5](https://docs.chain.link/data-feeds/selecting-data-feeds#market-hours) SVR-Backup Proxy:![Image 12: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0xF6d57763DFa625F4A413485261Ab2E71Ff4304CF](https://robinhoodchain.blockscout.com/address/0xF6d57763DFa625F4A413485261Ab2E71Ff4304CF) **🔗 SVR-Backup Feed:** This is a legacy SVR proxy feed. New integrations should use the **SVR** feeds. Learn more about [SVR Feeds](https://docs.chain.link/data-feeds/svr-feeds). |
| 🟠[High risk](https://docs.chain.link/data-feeds/selecting-data-feeds#-high-market-pricing-risk-feeds) | Robinhood AMZN / USD [SVR-Backup](https://docs.chain.link/data-feeds/svr-feeds "SVR-Backup Feed") [Tokenized Equity](https://docs.chain.link/data-feeds/tokenized-equity-feeds "Tokenized Equity Feed") | 0.5% | 86400s | 8 | Standard Proxy: ![Image 13: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0xD5a1508ceD74c084eBf3cBe853e2C968fB2a651C](https://robinhoodchain.blockscout.com/address/0xD5a1508ceD74c084eBf3cBe853e2C968fB2a651C) Asset name:Amazon (Robinhood Tokenized Equity) Asset type:Crypto Market hours:[us_equities_24/5](https://docs.chain.link/data-feeds/selecting-data-feeds#market-hours) SVR-Backup Proxy:![Image 14: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0x9244830430bC7D9C9A48dd47603F24AD61f7c56e](https://robinhoodchain.blockscout.com/address/0x9244830430bC7D9C9A48dd47603F24AD61f7c56e) **🔗 SVR-Backup Feed:** This is a legacy SVR proxy feed. New integrations should use the **SVR** feeds. Learn more about [SVR Feeds](https://docs.chain.link/data-feeds/svr-feeds). |
| 🟠[High risk](https://docs.chain.link/data-feeds/selecting-data-feeds#-high-market-pricing-risk-feeds) | Robinhood ASML / USD [SVR-Backup](https://docs.chain.link/data-feeds/svr-feeds "SVR-Backup Feed") [Tokenized Equity](https://docs.chain.link/data-feeds/tokenized-equity-feeds "Tokenized Equity Feed") | 0.5% | 86400s | 8 | Standard Proxy: ![Image 15: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0xB4106147E8cce40b7d46124090d373A71b70f87D](https://robinhoodchain.blockscout.com/address/0xB4106147E8cce40b7d46124090d373A71b70f87D) Asset name:ASML Holding NV (Nasdaq) (Robinhood Tokenized Equity) Asset type:Crypto Market hours:[us_equities_24/5](https://docs.chain.link/data-feeds/selecting-data-feeds#market-hours) SVR-Backup Proxy:![Image 16: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0x3eFBba343e2b1cF9ed4d4D5768e20B70307Aa8c9](https://robinhoodchain.blockscout.com/address/0x3eFBba343e2b1cF9ed4d4D5768e20B70307Aa8c9) **🔗 SVR-Backup Feed:** This is a legacy SVR proxy feed. New integrations should use the **SVR** feeds. Learn more about [SVR Feeds](https://docs.chain.link/data-feeds/svr-feeds). |
| 🟠[High risk](https://docs.chain.link/data-feeds/selecting-data-feeds#-high-market-pricing-risk-feeds) | Robinhood BABA / USD [SVR-Backup](https://docs.chain.link/data-feeds/svr-feeds "SVR-Backup Feed") [Tokenized Equity](https://docs.chain.link/data-feeds/tokenized-equity-feeds "Tokenized Equity Feed") | 0.5% | 86400s | 8 | Standard Proxy: ![Image 17: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0x62Cc8F9b5f56a33c9C8A60c8B92779f523c4E984](https://robinhoodchain.blockscout.com/address/0x62Cc8F9b5f56a33c9C8A60c8B92779f523c4E984) Asset name:Alibaba Group Holding Ltd (ADRs) (Robinhood Tokenized Equity) Asset type:Crypto Market hours:[us_equities_24/5](https://docs.chain.link/data-feeds/selecting-data-feeds#market-hours) SVR-Backup Proxy:![Image 18: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0xDB69948B26050818E8c9f43300F78b2582e67260](https://robinhoodchain.blockscout.com/address/0xDB69948B26050818E8c9f43300F78b2582e67260) **🔗 SVR-Backup Feed:** This is a legacy SVR proxy feed. New integrations should use the **SVR** feeds. Learn more about [SVR Feeds](https://docs.chain.link/data-feeds/svr-feeds). |
| 🟠[High risk](https://docs.chain.link/data-feeds/selecting-data-feeds#-high-market-pricing-risk-feeds) | Robinhood CLSK / USD [SVR-Backup](https://docs.chain.link/data-feeds/svr-feeds "SVR-Backup Feed") [Tokenized Equity](https://docs.chain.link/data-feeds/tokenized-equity-feeds "Tokenized Equity Feed") | 0.5% | 86400s | 8 | Standard Proxy: ![Image 19: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0x810c12D3a554Bc47fd39597Fe3b3AAC4941F50eF](https://robinhoodchain.blockscout.com/address/0x810c12D3a554Bc47fd39597Fe3b3AAC4941F50eF) Asset name:CleanSpark Inc (Robinhood Tokenized Equity) Asset type:Crypto Market hours:[us_equities_24/5](https://docs.chain.link/data-feeds/selecting-data-feeds#market-hours) SVR-Backup Proxy:![Image 20: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0x951C5E9a2a065053035D4B812b1f6cA7e64c5102](https://robinhoodchain.blockscout.com/address/0x951C5E9a2a065053035D4B812b1f6cA7e64c5102) **🔗 SVR-Backup Feed:** This is a legacy SVR proxy feed. New integrations should use the **SVR** feeds. Learn more about [SVR Feeds](https://docs.chain.link/data-feeds/svr-feeds). |
| 🟠[High risk](https://docs.chain.link/data-feeds/selecting-data-feeds#-high-market-pricing-risk-feeds) | Robinhood COIN / USD [SVR-Backup](https://docs.chain.link/data-feeds/svr-feeds "SVR-Backup Feed") [Tokenized Equity](https://docs.chain.link/data-feeds/tokenized-equity-feeds "Tokenized Equity Feed") | 0.5% | 86400s | 8 | Standard Proxy: ![Image 21: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0xA3a468A452940B7D6b69991207B508c609a98Ef2](https://robinhoodchain.blockscout.com/address/0xA3a468A452940B7D6b69991207B508c609a98Ef2) Asset name:Coinbase (Robinhood Tokenized Equity) Asset type:Crypto Market hours:[us_equities_24/5](https://docs.chain.link/data-feeds/selecting-data-feeds#market-hours) SVR-Backup Proxy:![Image 22: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0xA7F7D79D578fb007384BaDF42c8E1D76a6a63bBD](https://robinhoodchain.blockscout.com/address/0xA7F7D79D578fb007384BaDF42c8E1D76a6a63bBD) **🔗 SVR-Backup Feed:** This is a legacy SVR proxy feed. New integrations should use the **SVR** feeds. Learn more about [SVR Feeds](https://docs.chain.link/data-feeds/svr-feeds). |
| 🟠[High risk](https://docs.chain.link/data-feeds/selecting-data-feeds#-high-market-pricing-risk-feeds) | Robinhood CRCL / USD [SVR-Backup](https://docs.chain.link/data-feeds/svr-feeds "SVR-Backup Feed") [Tokenized Equity](https://docs.chain.link/data-feeds/tokenized-equity-feeds "Tokenized Equity Feed") | 0.5% | 86400s | 8 | Standard Proxy: ![Image 23: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0x6652eDf64bA3731C4F2D3ce821A0Fb1f1f6b482a](https://robinhoodchain.blockscout.com/address/0x6652eDf64bA3731C4F2D3ce821A0Fb1f1f6b482a) Asset name:Circle Internet Group Inc (Robinhood Tokenized Equity) Asset type:Crypto Market hours:[us_equities_24/5](https://docs.chain.link/data-feeds/selecting-data-feeds#market-hours) SVR-Backup Proxy:![Image 24: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)[0x025Ba3B3569Ca7d15Da7BFC1648F13F06A072851](https://robinhoodchain.blockscout.com/address/0x025Ba3B3569Ca7d15Da7BFC1648F13F06A072851) **🔗 SVR-Backup Feed:** This is a legacy SVR proxy feed. New integrations should use the **SVR** feeds. Learn more about [SVR Feeds](https://docs.chain.link/data-feeds/svr-feeds). |

Prev
Showing 1 to 8 of 33 entries

Next

## [Total Return Value calculation](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#total-return-value-calculation)

Robinhood tokenized equity feeds calculate the token price using the following formula:

![Image 25: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)

```plaintext
Token Price = Underlying Equity Market Price × Multiplier
```

Where:

*   **Underlying Equity Market Price**: Sourced from Chainlink's 24/5 equity price feeds, which aggregate data across regular, pre-market, post-market, and overnight trading sessions.
*   **Multiplier**: Read from the Robinhood token contract via the `uiMultiplier()` function. The multiplier accounts for dividend reinvestments and corporate action adjustments (see [Corporate action handling](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#corporate-action-handling-and-oracle-pause) below).

This approach ensures the token price reflects the total return of the underlying equity, including dividend reinvestments and corporate action adjustments, rather than just the current market price per share.

## [How the multiplier works](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#how-the-multiplier-works)

The multiplier accounts for events that change the relationship between token quantity and underlying equity value:

| Event Type | Multiplier Behavior | Example |
| --- | --- | --- |
| Dividend reinvestment | Small increase | `uiMultiplier`: 1.000 → 1.008 |
| Stock split (10:1 example) | Large increase | `uiMultiplier`: 1.0 → 10.0 |
| Reverse split (1:10 example) | Large decrease | `uiMultiplier`: 10.0 → 1.0 |
| Spin-offs | Adjustment to reflect new value | Varies by event |

Robinhood updates the multiplier on the token contract through two paths:

*   **Immediate update**: `updateMultiplier(uint256)` sets a new `uiMultiplier` effective immediately.
*   **Scheduled update**: `updateMultiplier(uint256, uint256 effectiveAt)` stages the next multiplier. The staged value is exposed through `newUIMultiplier()` and the activation time through `effectiveAt()`. The new value becomes the active `uiMultiplier` once the `effectiveAt` timestamp is reached.

The `UIMultiplierUpdated` event (`oldMultiplier`, `newMultiplier`, `effectiveAtTimestamp`) is emitted whenever the multiplier changes or a new value is staged.

Robinhood's on-chain token contract enforces two update paths:

*   **Small updates** (no price discontinuity): Applied immediately via automated processes. These handle routine dividend reinvestments.
*   **Large updates** (price discontinuity): Requires a scheduled pause window and manual confirmation before unpause. These handle major corporate actions like stock splits.

## [Corporate action handling and oracle pause](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#corporate-action-handling-and-oracle-pause)

Corporate actions are coordinated by Robinhood as the asset issuer. Chainlink does not provide corporate-action calendar data or automated pause triggers; pause timing and multiplier updates are coordinated by Robinhood.

The Robinhood token contract exposes a dedicated oracle pause flag, `oraclePaused()`, that the feed honors:

**Normal mode** (`oraclePaused() == false`): The feed returns the current underlying equity market price multiplied by the current `uiMultiplier`.

**Paused mode** (`oraclePaused() == true`): The feed stops publishing new prices and holds the last known good value. This prevents an inconsistent token price from being published while a corporate action is in progress and the underlying price and multiplier are temporarily out of sync.

During a corporate action, the issuer-driven workflow keeps the token price continuous:

1.   Robinhood pauses the oracle (`pauseOracle()`), freezing the feed at the last known good value.
2.   The new multiplier is staged via `updateMultiplier(newMultiplier, effectiveAt)` (or applied at the scheduled time).
3.   After the corporate action takes effect and Robinhood confirms that both the underlying market price and the multiplier reflect the new values correctly, the oracle is unpaused (`unpauseOracle()`).
4.   The feed resumes publishing using the updated multiplier.

For example, during a 10:1 stock split:

| Stage | Stock Price | `uiMultiplier` | Token Price |
| --- | --- | --- | --- |
| Before split | $200 | 1.0 | $200 |
| During pause | Frozen | Pending: 10.0 | $200 (frozen) |
| After unpause | $20 | 10.0 | $200 |

The token price remains continuous at $200 throughout the event, even though the underlying equity market price dropped from $200 to $20.

## [Example scenarios](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#example-scenarios)

**Normal operation**

![Image 26: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)

```plaintext
- Stock price: $200 → $201
- uiMultiplier: 1.000 (unchanged)
- Token price: $201
```

**Dividend reinvestment** (small multiplier drift)

![Image 27: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)

```plaintext
- Stock price: $200
- uiMultiplier: 1.000 → 1.008
- Token price: $201.60
```

**Stock split** (10:1, scheduled corporate action)

![Image 28: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)

```plaintext
1. Robinhood pauses the oracle and stages newUIMultiplier = 10 with an effectiveAt timestamp
2. The feed freezes at the current token price while oraclePaused() is true
3. Market reopens with the underlying stock price at $20 (post-split)
4. Robinhood confirms alignment and calls unpauseOracle()
5. uiMultiplier becomes 10.0, token price = $20 × 10 = $200 (continuous)
```

**Split with timing mismatch** (stock price updates before the multiplier)

![Image 29: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)

```plaintext
- Oracle paused with newUIMultiplier = 10 staged
- Underlying stock price = $20, uiMultiplier still 1.0 (not yet effective)
- Result: Feed remains frozen at the pre-pause price until Robinhood unpauses the oracle
```

This fail-safe behavior prevents incorrect token prices from being published when the underlying stock price and the multiplier are temporarily out of sync.

## [Off-hours and session behavior](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#off-hours-and-session-behavior)

Robinhood tokenized equity feeds are configured as 24/5 tokenized equity feeds (regular, pre-market, post-market, and overnight sessions), where underlying liquidity and session data quality support it. Integrators should be aware of standard tokenized equity behavior:

*   **Off-hours / closed sessions**: When underlying equity markets are closed (weekends, holidays, thin overnight windows), the feed may hold the last published price even though the contract remains callable via `latestRoundData()`. These feeds do not have heartbeats during off-hours.
*   **Staleness checks**: Integrators should read `updatedAt` and implement staleness bounds appropriate to their use case.

See [Tokenized Equity Feeds](https://docs.chain.link/data-feeds/tokenized-equity-feeds) for the shared behavioral model across providers.

## [Smart Value Recapture (SVR)](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#smart-value-recapture-svr)

Primary mint and redeem for Robinhood tokenized equities can be permissioned, but once the tokens are onchain, anyone can hold them and anyone can liquidate positions that use the feed.

Robinhood feeds have SVR enabled even when the primary market is not public to all participants. The liquidator set includes teams that can also access primary mint and redeem when they need to. Permissioned mint and redeem concerns the primary market; tokens can still circulate onchain and positions that use the feed can still be liquidated outside that path.

For Oracle Extractable Value (OEV) and how SVR relates to standard feeds, use [SVR Feeds](https://docs.chain.link/data-feeds/svr-feeds)—especially [Understanding MEV and OEV](https://docs.chain.link/data-feeds/svr-feeds#understanding-mev-and-oev). To read answers from contracts, follow [Using Data Feeds](https://docs.chain.link/data-feeds/using-data-feeds) and point at the proxy address for your feed.

## What's next

*   [> Smart Value Recapture (SVR) Feeds](https://docs.chain.link/data-feeds/svr-feeds)
*   [> View Provider Catalog](https://docs.chain.link/data-feeds/tokenized-equity-feeds/providers)
*   [> Learn about tokenized equity feeds](https://docs.chain.link/data-feeds/tokenized-equity-feeds)
*   [> Find Price Feed Addresses](https://docs.chain.link/data-feeds/price-feeds/addresses)

Use with LLMs AI Copy page

## On this page

*   [Overview](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#overview)
*   [Available Robinhood tokenized equity feeds](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#available-robinhood-tokenized-equity-feeds)
*   [Networks](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#networks)
*   [Robinhood Chain Mainnet](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#robinhood-chain-mainnet)
*   [Total Return Value calculation](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#total-return-value-calculation)
*   [How the multiplier works](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#how-the-multiplier-works)
*   [Corporate action handling and oracle pause](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#corporate-action-handling-and-oracle-pause)
*   [Example scenarios](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#example-scenarios)
*   [Off-hours and session behavior](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#off-hours-and-session-behavior)
*   [Smart Value Recapture (SVR)](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood#smart-value-recapture-svr)

## More

*   [Complete Data Feeds docs (TXT)](https://docs.chain.link/data-feeds/llms-full.txt)
*   [Edit this page](https://github.com/smartcontractkit/documentation/tree/main/src/content/data-feeds/tokenized-equity-feeds/robinhood.mdx)
*   [Quick links for builders](https://docs.chain.link/builders-quick-links)
*   [Join our community](https://discord.com/invite/aSK4zew)

## Feedback

Was this page helpful?

Yes

No

## Get the latest Chainlink content straight to your inbox.

Email Address 

### Developers

*   [Developer Resources](https://chain.link/developer-resources)
*   [Builder Quick Links](https://docs.chain.link/builders-quick-links)
*   [LINK Token Contracts](https://docs.chain.link/resources/link-token-contracts)
*   [Data Feeds](https://docs.chain.link/data-feeds)
*   [Data Streams](https://docs.chain.link/data-streams)
*   [VRF](https://docs.chain.link/vrf)
*   [Automation](https://docs.chain.link/chainlink-automation)
*   [Functions](https://docs.chain.link/chainlink-functions)
*   [CCIP](https://docs.chain.link/ccip)

### Solutions

*   [Overview](https://chain.link/solutions)
*   [DeFi](https://chain.link/solutions/defi)
*   [Chainlink VRF](https://chain.link/vrf)

### Community

*   [Chainlink Hackathon](https://chain.link/hackathon/)
*   [Community overview](https://chain.link/community)
*   [Events](https://chain.link/community/events)
*   [Become an advocate](https://chain.link/community/advocates)
*   [Code of conduct](https://chain.link/code-of-conduct)

### Chainlink

*   [Ecosystem](https://chain.link/ecosystem)
*   [Press](https://chain.link/press)
*   [Blog](https://blog.chain.link/)
*   [Team](https://chain.link/team)
*   [Careers](https://chainlinklabs.com/careers)WE ARE HIRING!  
*   [Brand assets](https://chain.link/brand-assets)
*   [FAQs](https://chain.link/faqs)

### Contact

*   [Security](mailto:security@chain.link)
*   [Support](https://chain.link/support)
*   [Press inquiries](mailto:press@chain.link)

### Social

*   ![Image 30](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcc8de393ea2bffa0ff_twitter.svg)[Twitter](https://twitter.com/chainlink)
*   ![Image 31](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcc3830fc22d9bc18c8_youtube.svg)[YouTube](https://www.youtube.com/channel/UCnjkrlqaWEBSnKZQ71gdyFA)
*   ![Image 32](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcff3840d5ec8300b30_discord.svg)[Discord](https://discord.gg/aSK4zew)
*   ![Image 33](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcceaf22843cde97118_telegram.svg)[Telegram](https://t.me/chainlinkofficial)
*   ![Image 34](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcc8e9ff41b546f039f_wechat.svg)[WeChat](https://blog.chain.link/chainlink-chinese-communities/)
*   ![Image 35](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcc8f83d17d2d857106_reddit.svg)[Reddit](https://www.reddit.com/r/Chainlink/)

[![Image 36: Chainlink logo](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f7610da8f83d1e6028573c7_chainlink-logo-footer.svg)](https://docs.chain.link/)

Chainlink®

 © 2026 Chainlink Foundation 

[Privacy Policy](https://chain.link/privacy-policy)[Terms of Use](https://chain.link/terms)

Ask AI
