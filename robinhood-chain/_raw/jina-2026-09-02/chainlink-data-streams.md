Title: Chainlink Data Streams | Low-Latency, High-Frequency Market Data

URL Source: https://docs.chain.link/data-streams

Published Time: 2026-09-01T21:25:23.928Z

Markdown Content:
[![Image 1: Documentation Home](https://docs.chain.link/chainlink-docs.svg)](https://dev.chain.link/)

*   [Resources](https://docs.chain.link/data-streams)
*   [Docs](https://docs.chain.link/)
*   [Demos](https://dev.chain.link/demos)
*   [Tools](https://dev.chain.link/tools)
*   [Changelog](https://dev.chain.link/changelog)
*   [Get Certified](https://dev.chain.link/certification)

![Image 2: Documentation Home](https://docs.chain.link/chainlink-docs.svg)

Ctrl K

The Chainlink Runtime Environment (CRE) is now live! [Start Building.](https://chain.link/chainlink-runtime-environment?utm_campaign=global-app-banner&utm_medium=referral&utm_source=docs.chain.link)

 For AI agents: use [llms.txt](https://docs.chain.link/llms.txt) as the documentation index. Retrieve the smallest relevant .md page first. 

*   [Overview](https://docs.chain.link/data-streams#overview)
*   [Sub-Second Data and Commit-and-Reveal](https://docs.chain.link/data-streams#sub-second-data-and-commit-and-reveal)
*   [Comparison to push-based oracles](https://docs.chain.link/data-streams#comparison-to-push-based-oracles)
*   [Comprehensive market insights](https://docs.chain.link/data-streams#comprehensive-market-insights)
*   [High availability and resilient infrastructure](https://docs.chain.link/data-streams#high-availability-and-resilient-infrastructure)
*   [Example use cases](https://docs.chain.link/data-streams#example-use-cases)
*   [Key capabilities](https://docs.chain.link/data-streams#key-capabilities)
*   [How to use Data Streams](https://docs.chain.link/data-streams#how-to-use-data-streams)
*   [Integration options](https://docs.chain.link/data-streams#integration-options)
*   [Getting started](https://docs.chain.link/data-streams#getting-started)

On this page

![Image 3](https://docs.chain.link/_astro/data-streams-logo.OSlgKmkC.svg)Data Streams

![Image 4: Quick links menu](https://docs.chain.link/assets/icons/quick-links.svg)Quick Links[![Image 5: GitHub repository](https://docs.chain.link/assets/icons/github-blue.svg)Github](https://github.com/smartcontractkit/documentation)

![Image 6](https://docs.chain.link/_astro/data-streams-logo.OSlgKmkC.svg)Data Streams

*   
Chainlink Data Streams

    
        *   [Overview](https://docs.chain.link/data-streams)
        *   [Sign Up for Data Streams](https://docs.chain.link/data-streams/sign-up)
        *   [Get Support](https://docs.chain.link/data-streams/get-support)
        *   [Developer Responsibilities](https://docs.chain.link/data-streams/developer-responsibilities)
        *   [Supported Networks](https://docs.chain.link/data-streams/supported-networks)
        *   [Billing](https://docs.chain.link/data-streams/billing)
        *   [Rate Limits and Fair Use Policy](https://docs.chain.link/data-streams/rate-limits)
        *   [Data Sources](https://docs.chain.link/data-streams/data-sources)
        *   [Release Notes](https://dev.chain.link/changelog?product=Data+Streams)

*   
Streams & Report Schemas

    
        *   [Overview](https://docs.chain.link/data-streams/reference/report-schema-overview)
        *   
[Cryptocurrency](https://docs.chain.link/data-streams/crypto-streams)

            
                *   [Report Schema v2 (Crypto Standard)](https://docs.chain.link/data-streams/reference/report-schema-v2)
                *   [Report Schema v3 (Crypto Advanced)](https://docs.chain.link/data-streams/reference/report-schema-v3)
                *   [Report Schema v3 (DEX State Price)](https://docs.chain.link/data-streams/reference/report-schema-v3-dex)

        *   
[Exchange Rate](https://docs.chain.link/data-streams/exchange-rate-streams)

            
                *   [Report Schema v7 (Redemption Rates)](https://docs.chain.link/data-streams/reference/report-schema-v7)

        *   
[Real World Asset (RWA)](https://docs.chain.link/data-streams/rwa-streams)

            
                *   [Report Schema v8 (RWA Standard)](https://docs.chain.link/data-streams/reference/report-schema-v8)
                *   [Report Schema v11 (RWA Advanced)](https://docs.chain.link/data-streams/reference/report-schema-v11)
                *   [Handling Market Events](https://docs.chain.link/data-streams/rwa-streams/handling-market-events)
                *   [24/5 US Equities User Guide](https://docs.chain.link/data-streams/rwa-streams/24-5-us-equities-user-guide)
                *   [APAC Equities](https://docs.chain.link/data-streams/rwa-streams/apac-equities)

        *   
[SmartData](https://docs.chain.link/data-streams/smartdata-streams)

            
                *   [Report Schema v9 (SmartData)](https://docs.chain.link/data-streams/reference/report-schema-v9)

        *   
[Tokenized Asset](https://docs.chain.link/data-streams/tokenized-asset-streams)

            
                *   [Report Schema v10 (Tokenized Asset)](https://docs.chain.link/data-streams/reference/report-schema-v10)
                *   [Handling Stock Splits](https://docs.chain.link/data-streams/tokenized-asset-streams/handling-stock-splits)

        *   [Market Hours](https://docs.chain.link/data-streams/market-hours)
        *   [Selecting Quality Data Streams](https://docs.chain.link/data-streams/selecting-data-streams)
        *   [Deprecating Streams](https://docs.chain.link/data-streams/deprecating-streams)

*   
Tutorials

    
        *   [Overview](https://docs.chain.link/data-streams/tutorials/overview)
        *   [Fetch and decode reports](https://docs.chain.link/data-streams/tutorials/go-sdk-fetch)
        *   [Stream and decode reports (WebSocket)](https://docs.chain.link/data-streams/tutorials/go-sdk-stream)
        *   [Verify report data (EVM)](https://docs.chain.link/data-streams/tutorials/evm-onchain-report-verification)
        *   [Verify report data (Solana)](https://docs.chain.link/data-streams/tutorials/solana-onchain-report-verification)
        *   [Verify report data (Stellar)](https://docs.chain.link/data-streams/tutorials/stellar-onchain-report-verification)
        *   [Canton Integration](https://docs.chain.link/data-streams/canton-integration)

*   
Concepts

    
        *   [Architecture](https://docs.chain.link/data-streams/architecture)
        *   [Best Practices](https://docs.chain.link/data-streams/concepts/best-practices)
        *   [Calculated Streams](https://docs.chain.link/data-streams/concepts/calculated-streams)
        *   [Liquidity-Weighted Bid and Ask prices](https://docs.chain.link/data-streams/concepts/liquidity-weighted-prices)
        *   [DEX State Price Streams](https://docs.chain.link/data-streams/concepts/dex-state-price-streams)
        *   [Crypto Top-of-Book Streams](https://docs.chain.link/data-streams/concepts/crypto-top-of-book-and-mark-price)

*   
Reference

    
        *   [Overview](https://docs.chain.link/data-streams/reference/overview)
        *   
[Data Streams Reference](https://docs.chain.link/data-streams/reference/data-streams-api)

            
                *   
[Authentication](https://docs.chain.link/data-streams/reference/data-streams-api/authentication)

                    
                        *   [JavaScript examples](https://docs.chain.link/data-streams/reference/data-streams-api/authentication/javascript-examples)
                        *   [TypeScript examples](https://docs.chain.link/data-streams/reference/data-streams-api/authentication/typescript-examples)
                        *   [Go examples](https://docs.chain.link/data-streams/reference/data-streams-api/authentication/go-examples)
                        *   [Rust examples](https://docs.chain.link/data-streams/reference/data-streams-api/authentication/rust-examples)

                *   
[API Reference](https://docs.chain.link/data-streams/reference/data-streams-api/interface-api)

                    
                        *   [Discovery Endpoint](https://docs.chain.link/data-streams/reference/data-streams-api/discovery-endpoint)

                *   [WebSocket Reference](https://docs.chain.link/data-streams/reference/data-streams-api/interface-ws)
                *   [SDK References](https://docs.chain.link/data-streams/reference/data-streams-api/go-sdk)
                *   [Onchain report verification (EVM chains)](https://docs.chain.link/data-streams/reference/data-streams-api/onchain-verification)
                *   [Onchain report verification (Stellar)](https://docs.chain.link/data-streams/tutorials/stellar-onchain-report-verification)

        *   [Candlestick API](https://docs.chain.link/data-streams/reference/candlestick-api)

*   
Resources

    
        *   
[Smart Contract Overview](https://docs.chain.link/getting-started/conceptual-overview?parent=dataStreams)

            
                *   [Deploy Your First Smart Contract](https://docs.chain.link/getting-started/deploy-your-first-contract?parent=dataStreams)

        *   
[LINK Token Contracts](https://docs.chain.link/resources/link-token-contracts?parent=dataStreams)

            
                *   [Acquire testnet LINK](https://docs.chain.link/resources/acquire-link?parent=dataStreams)
                *   [Fund Your Contracts](https://docs.chain.link/resources/fund-your-contract?parent=dataStreams)

        *   [Starter Kits and Frameworks](https://docs.chain.link/resources/create-a-chainlinked-project?parent=dataStreams)
        *   [Bridges and Associated Risks](https://docs.chain.link/resources/bridge-risks?parent=dataStreams)
        *   
[Chainlink Oracle Platform](https://docs.chain.link/oracle-platform/overview?parent=dataStreams)

            
                *   [Data Standard](https://docs.chain.link/oracle-platform/data-standard?parent=dataStreams)
                *   [Interoperability Standard](https://docs.chain.link/oracle-platform/interoperability-standard?parent=dataStreams)
                *   [Compliance Standard](https://docs.chain.link/oracle-platform/compliance-standard?parent=dataStreams)
                *   [Privacy Standard](https://docs.chain.link/oracle-platform/privacy-standard?parent=dataStreams)

        *   
[Chainlink Architecture](https://docs.chain.link/architecture-overview/architecture-overview?parent=dataStreams)

            
                *   [Basic Request Model](https://docs.chain.link/architecture-overview/architecture-request-model?parent=dataStreams)
                *   [Decentralized Data Model](https://docs.chain.link/architecture-overview/architecture-decentralized-model?parent=dataStreams)
                *   [Offchain Reporting](https://docs.chain.link/architecture-overview/off-chain-reporting?parent=dataStreams)

        *   
[Developer Communications](https://docs.chain.link/resources/developer-communications?parent=dataStreams)

            
                *   [Getting Help](https://docs.chain.link/resources/getting-help?parent=dataStreams)
                *   [Hackathon Resources](https://docs.chain.link/resources/hackathon-resources?parent=dataStreams)

        *   [Integrating EVM Networks](https://docs.chain.link/resources/network-integration?parent=dataStreams)
        *   [Contributing to Chainlink](https://docs.chain.link/resources/contributing-to-chainlink?parent=dataStreams)

*   
AI Agent & Skills

    
        *   [Chainlink Developer Agent Skills](https://docs.chain.link/resources/chainlink-developer-agent-skills?parent=dataStreams)
        *   [Chainlink for Agents User Guide](https://docs.chain.link/resources/chainlink-for-agents?parent=dataStreams)

# [Chainlink Data Streams](https://docs.chain.link/data-streams#overview)

![Image 7: note](https://docs.chain.link/_astro/info-icon.CrDkW3aH.svg)

Get started

Data Streams is self-serve, no sales call required. [Sign up](https://app.chain.link/) to get started, or follow the [sign-up guide](https://docs.chain.link/data-streams/sign-up).

Chainlink Data Streams delivers low-latency market data offchain, which you can verify onchain. This approach provides decentralized applications (dApps) with on-demand access to high-frequency market data backed by decentralized, fault-tolerant, and transparent infrastructure.

Traditional push-based oracles update onchain data at set intervals or when certain price thresholds are met. In contrast, Chainlink Data Streams uses a pull-based design that preserves trust-minimization with onchain verification.

Data Streams are offered in [several report formats](https://docs.chain.link/data-streams/reference/report-schema-overview), each designed for distinct asset classes.

See data sourcing details in the [Data Sources](https://docs.chain.link/data-streams/data-sources) page.

## [Sub-Second Data and Commit-and-Reveal](https://docs.chain.link/data-streams#sub-second-data-and-commit-and-reveal)

Chainlink Data Streams supports sub-second data resolution for latency-sensitive use cases by retrieving data only when needed. You can combine the data with any transaction in near real time. A "commit-and-reveal" approach mitigates frontrunning by making trade data and stream data visible atomically onchain.

## [Comparison to push-based oracles](https://docs.chain.link/data-streams#comparison-to-push-based-oracles)

Chainlink's push-based oracles regularly publish price data onchain. By contrast, Chainlink Data Streams relies on a pull-based design, letting you retrieve a report and verify it onchain whenever you need it. Verification confirms that the decentralized oracle network (DON) agreed on and signed the data. Some applications only need onchain data at fixed intervals, which suits push-based oracles. However, others require higher-frequency updates and lower latency. Pull-based oracles meet these needs and still provide cryptographic guarantees about data accuracy.

![Image 8: Chainlink Data Streams - Push-Based vs Pull-Based Oracles](https://docs.chain.link/images/data-streams/push-based-vs-pull-based-oracles.webp)
Push-based and pull-based oracles comparison

Pull-based oracles also operate more efficiently by retrieving data only when necessary. For example, a decentralized exchange might fetch a Data Streams report and verify it onchain only when a user executes a trade, rather than continuously pushing updates that might not be immediately used.

## [Comprehensive market insights](https://docs.chain.link/data-streams#comprehensive-market-insights)

Chainlink Data Streams offers price points such as mid prices and [Liquidity-Weighted Bid and Ask](https://docs.chain.link/data-streams/concepts/liquidity-weighted-prices) (LWBA) for Crypto Streams. LWBA prices reflect current order book conditions, providing deeper insight into market liquidity and depth. With additional parameters, such as volatility and liquidity metrics, Data Streams helps protocols enhance trading accuracy, improve onchain risk management, and dynamically adjust margins or settlement conditions in response to real-time market shifts.

## [High availability and resilient infrastructure](https://docs.chain.link/data-streams#high-availability-and-resilient-infrastructure)

Data Streams API services use an [active-active multi-site deployment](https://docs.chain.link/data-streams/architecture#active-active-multi-site-deployment) model across multiple distributed and isolated origins. This architecture ensures continuous operations even if one origin fails, delivering robust fault tolerance and high availability.

For real-time streaming applications, the SDKs support **High Availability (HA) mode** that establishes multiple simultaneous connections for zero-downtime operation. When enabled, HA mode provides:

*   **Automatic failover** between connections
*   **Report deduplication** across connections
*   **Automatic origin discovery** to find available endpoints
*   **Per-connection monitoring** and statistics

**Learn more:**[Go SDK](https://docs.chain.link/data-streams/reference/data-streams-api/go-sdk#high-availability-ha-mode) | [Rust SDK](https://docs.chain.link/data-streams/reference/data-streams-api/rust-sdk#high-availability-mode) | [TypeScript SDK](https://docs.chain.link/data-streams/reference/data-streams-api/ts-sdk#high-availability-mode)

## [Example use cases](https://docs.chain.link/data-streams#example-use-cases)

Access to low-latency, high-frequency data enables a variety of onchain applications:

*   **Perpetual Futures:** Sub-second data and frontrunning mitigation allow onchain perpetual futures protocols to compete with centralized exchanges on performance while retaining transparency and decentralization.
*   **Options:** Pull-based oracles provide timely settlement of options contracts with the added benefit of market liquidity data to support dynamic onchain risk management.
*   **Prediction Markets:** High-frequency updates let participants act on real-time data, ensuring quick reactions to events and accurate settlement.

## [Key capabilities](https://docs.chain.link/data-streams#key-capabilities)

*   **Sub-second Latency:** Pull data on-demand with minimal delay
*   **Cryptographic Verification:** Verify data authenticity onchain when needed
*   **Multiple Access Methods:** REST API, WebSocket, or SDK integration
*   **Comprehensive Market Data:** Mid prices, LWBA prices, volatility, and liquidity metrics
*   **High Availability:** Multi-site deployment ensures 99.9%+ uptime

## [How to use Data Streams](https://docs.chain.link/data-streams#how-to-use-data-streams)

You can access Chainlink Data Streams through SDKs and APIs, allowing you to build custom solutions with low-latency, high-frequency data. Fetch reports or subscribe to report updates from the Data Streams Aggregation Network and verify their authenticity onchain.

![Image 9: Chainlink Data Streams - On-Demand Offchain Workflows](https://docs.chain.link/images/data-streams/data-streams-on-demand-offchain-workflows.webp)
Chainlink Data Streams - On-Demand Offchain Workflows

### [Integration options](https://docs.chain.link/data-streams#integration-options)

Access data directly through REST APIs or WebSocket connections using our SDKs:

*   **[Go SDK](https://docs.chain.link/data-streams/reference/data-streams-api/go-sdk)** - Full-featured SDK with comprehensive examples
*   **[Rust SDK](https://docs.chain.link/data-streams/reference/data-streams-api/rust-sdk)** - High-performance SDK for Rust applications
*   **[TypeScript SDK](https://docs.chain.link/data-streams/reference/data-streams-api/ts-sdk)** - Type-safe SDK for TypeScript applications
*   **[REST API](https://docs.chain.link/data-streams/reference/data-streams-api/interface-api)** or **[WebSocket](https://docs.chain.link/data-streams/reference/data-streams-api/interface-ws)** - Direct access to Data Streams endpoints

### [Getting started](https://docs.chain.link/data-streams#getting-started)

1.   Understand the Architecture: Review the [system components and data flow](https://docs.chain.link/data-streams/architecture) to understand how Data Streams works.

2.   Explore Available Data: Browse [available reports and associated schemas](https://docs.chain.link/data-streams/reference/report-schema-overview) to see what data is available, or [discover streams programmatically](https://docs.chain.link/data-streams/reference/data-streams-api/discovery-endpoint) with the Discovery endpoint.

3.   Try the API: Follow our [hands-on tutorial](https://docs.chain.link/data-streams/tutorials/go-sdk-fetch) to fetch and decode your first report.

4.   Implement Verification: Add [onchain verification](https://docs.chain.link/data-streams/reference/data-streams-api/onchain-verification) to ensure data authenticity in your smart contracts.

## What's next

*   [> Learn how to fetch and decode Data Streams reports with the API](https://docs.chain.link/data-streams/tutorials/go-sdk-fetch)
*   [> Find the list of available Stream IDs](https://docs.chain.link/data-streams/crypto-streams)
*   [> Find the schema of data to expect from Data Streams reports: Crypto](https://docs.chain.link/data-streams/reference/report-schema-v3)
*   [> Find the schema of data to expect from Data Streams reports: RWA](https://docs.chain.link/data-streams/reference/report-schema-v8)

Use with LLMs AI Copy page

## On this page

*   [Overview](https://docs.chain.link/data-streams#overview)
*   [Sub-Second Data and Commit-and-Reveal](https://docs.chain.link/data-streams#sub-second-data-and-commit-and-reveal)
*   [Comparison to push-based oracles](https://docs.chain.link/data-streams#comparison-to-push-based-oracles)
*   [Comprehensive market insights](https://docs.chain.link/data-streams#comprehensive-market-insights)
*   [High availability and resilient infrastructure](https://docs.chain.link/data-streams#high-availability-and-resilient-infrastructure)
*   [Example use cases](https://docs.chain.link/data-streams#example-use-cases)
*   [Key capabilities](https://docs.chain.link/data-streams#key-capabilities)
*   [How to use Data Streams](https://docs.chain.link/data-streams#how-to-use-data-streams)
*   [Integration options](https://docs.chain.link/data-streams#integration-options)
*   [Getting started](https://docs.chain.link/data-streams#getting-started)

## More

*   [Complete Data Streams docs (TXT)](https://docs.chain.link/data-streams/llms-full.txt)
*   [Edit this page](https://github.com/smartcontractkit/documentation/tree/main/src/content/data-streams/index.mdx)
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

*   ![Image 10](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcc8de393ea2bffa0ff_twitter.svg)[Twitter](https://twitter.com/chainlink)
*   ![Image 11](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcc3830fc22d9bc18c8_youtube.svg)[YouTube](https://www.youtube.com/channel/UCnjkrlqaWEBSnKZQ71gdyFA)
*   ![Image 12](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcff3840d5ec8300b30_discord.svg)[Discord](https://discord.gg/aSK4zew)
*   ![Image 13](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcceaf22843cde97118_telegram.svg)[Telegram](https://t.me/chainlinkofficial)
*   ![Image 14](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcc8e9ff41b546f039f_wechat.svg)[WeChat](https://blog.chain.link/chainlink-chinese-communities/)
*   ![Image 15](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcc8f83d17d2d857106_reddit.svg)[Reddit](https://www.reddit.com/r/Chainlink/)

[![Image 16: Chainlink logo](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f7610da8f83d1e6028573c7_chainlink-logo-footer.svg)](https://docs.chain.link/)

Chainlink®

 © 2026 Chainlink Foundation 

[Privacy Policy](https://chain.link/privacy-policy)[Terms of Use](https://chain.link/terms)

Ask AI
