Title: L2 Sequencer Uptime Feeds

URL Source: https://docs.chain.link/data-feeds/l2-sequencer-feeds

Published Time: 2026-09-01T21:25:17.213Z

Markdown Content:
[![Image 1: Documentation Home](https://docs.chain.link/chainlink-docs.svg)](https://dev.chain.link/)

*   [Resources](https://docs.chain.link/data-feeds/l2-sequencer-feeds)
*   [Docs](https://docs.chain.link/)
*   [Demos](https://dev.chain.link/demos)
*   [Tools](https://dev.chain.link/tools)
*   [Changelog](https://dev.chain.link/changelog)
*   [Get Certified](https://dev.chain.link/certification)

![Image 2: Documentation Home](https://docs.chain.link/chainlink-docs.svg)

Ctrl K

The Chainlink Runtime Environment (CRE) is now live! [Start Building.](https://chain.link/chainlink-runtime-environment?utm_campaign=global-app-banner&utm_medium=referral&utm_source=docs.chain.link)

 For AI agents: use [llms.txt](https://docs.chain.link/llms.txt) as the documentation index. Retrieve the smallest relevant .md page first. 

*   [Overview](https://docs.chain.link/data-feeds/l2-sequencer-feeds#overview)
*   [Supported Networks](https://docs.chain.link/data-feeds/l2-sequencer-feeds#supported-networks)
*   [Arbitrum](https://docs.chain.link/data-feeds/l2-sequencer-feeds#arbitrum)
*   [BASE](https://docs.chain.link/data-feeds/l2-sequencer-feeds#base)
*   [Celo](https://docs.chain.link/data-feeds/l2-sequencer-feeds#celo)
*   [Mantle](https://docs.chain.link/data-feeds/l2-sequencer-feeds#mantle)
*   [MegaETH](https://docs.chain.link/data-feeds/l2-sequencer-feeds#megaeth)
*   [Metis](https://docs.chain.link/data-feeds/l2-sequencer-feeds#metis)
*   [OP](https://docs.chain.link/data-feeds/l2-sequencer-feeds#op)
*   [Scroll](https://docs.chain.link/data-feeds/l2-sequencer-feeds#scroll)
*   [Soneium](https://docs.chain.link/data-feeds/l2-sequencer-feeds#soneium)
*   [X Layer](https://docs.chain.link/data-feeds/l2-sequencer-feeds#x-layer)
*   [ZKsync](https://docs.chain.link/data-feeds/l2-sequencer-feeds#zksync)
*   [Real-time Monitoring Process](https://docs.chain.link/data-feeds/l2-sequencer-feeds#real-time-monitoring-process)
*   [Arbitrum](https://docs.chain.link/data-feeds/l2-sequencer-feeds#arbitrum-1)
*   [Handling Arbitrum Outages](https://docs.chain.link/data-feeds/l2-sequencer-feeds#handling-arbitrum-outages)
*   [Other Supported Networks](https://docs.chain.link/data-feeds/l2-sequencer-feeds#other-supported-networks)
*   [Handling Other Supported Network Outages](https://docs.chain.link/data-feeds/l2-sequencer-feeds#handling-other-supported-network-outages)
*   [Example Consumer Contract](https://docs.chain.link/data-feeds/l2-sequencer-feeds#example-consumer-contract)

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

# [L2 Sequencer Uptime Feeds](https://docs.chain.link/data-feeds/l2-sequencer-feeds#overview)

![Image 7: caution](https://docs.chain.link/_astro/alert-icon.CcK7cCMv.svg)

Availability notice

Chainlink is no longer expanding L2 Sequencer Uptime Feeds to additional networks. Existing feeds on the supported networks listed below will continue to operate and be supported.

Optimistic rollups (e.g., Arbitrum, Optimism) and many ZK-rollups rely on sequencers to efficiently manage transaction ordering, execution, and batching before submitting them to Layer 1 (L1) blockchains like Ethereum. The sequencer plays a crucial role in optimizing transaction throughput, reducing fees, and ensuring fast transaction confirmations on L2 networks, making it a key component of their scalability and performance.

However, if the sequencer becomes unavailable, users will lose access to the standard read/write APIs, preventing them from interacting with applications on the L2 network. Although the L2 chain's security and state commitments remain enforced by Layer 1, no new batched blocks will be produced by the sequencer. Users with sufficient technical expertise can still interact directly with the network through the underlying rollup contracts on L1. However, this process is more complex and costly, creating an unfair advantage for those who can bypass the sequencer. This imbalance in access can lead to disruptions or distortions in applications, such as liquidations or market operations that rely on timely transactions.

To mitigate these risks, your applications can integrate a **Sequencer Uptime Data Feed**, which continuously monitors and records the last known status of the sequencer. By utilizing this feed, you can:

*   Detect sequencer downtime in real time.
*   Implement a grace period to prevent mass liquidations or unexpected disruptions.
*   Ensure fair access to services by temporarily pausing operations during sequencer failures.

This proactive approach enhances the resilience and fairness of applications operating on L2 networks, ensuring a more stable and equitable user experience.

## [Supported Networks](https://docs.chain.link/data-feeds/l2-sequencer-feeds#supported-networks)

You can find proxy addresses for the L2 sequencer feeds at the following addresses:

### [![Image 8](https://docs.chain.link/assets/chains/arbitrum.svg)Arbitrum](https://docs.chain.link/data-feeds/l2-sequencer-feeds#arbitrum)

Arbitrum Mainnet: [0xFdB631F5EE196F0ed6FAa767959853A9F217697D](https://arbiscan.io/address/0xFdB631F5EE196F0ed6FAa767959853A9F217697D)

### [![Image 9](https://docs.chain.link/assets/chains/base.svg)BASE](https://docs.chain.link/data-feeds/l2-sequencer-feeds#base)

BASE Mainnet: [0xBCF85224fc0756B9Fa45aA7892530B47e10b6433](https://basescan.org/address/0xBCF85224fc0756B9Fa45aA7892530B47e10b6433)

### [![Image 10](https://docs.chain.link/assets/chains/celo.svg)Celo](https://docs.chain.link/data-feeds/l2-sequencer-feeds#celo)

Celo Mainnet: [0x4CD491Dc27C8B0BbD10D516A502856B786939d18](https://celoscan.io/address/0x4CD491Dc27C8B0BbD10D516A502856B786939d18)

### [![Image 11](https://docs.chain.link/assets/chains/mantle.svg)Mantle](https://docs.chain.link/data-feeds/l2-sequencer-feeds#mantle)

Mantle Mainnet: [0xaDE1b9AbB98c6A542E4B49db2588a3Ec4bF7Cdf0](https://mantlescan.xyz/address/0xaDE1b9AbB98c6A542E4B49db2588a3Ec4bF7Cdf0)

### [![Image 12](https://docs.chain.link/assets/chains/megaeth.svg)MegaETH](https://docs.chain.link/data-feeds/l2-sequencer-feeds#megaeth)

MegaETH Mainnet: [0x78B2195A21B8BBe82acaB43F90F9180E9513FD0C](https://mega.etherscan.io/address/0x78B2195A21B8BBe82acaB43F90F9180E9513FD0C)

### [![Image 13](https://docs.chain.link/assets/chains/metis.svg)Metis](https://docs.chain.link/data-feeds/l2-sequencer-feeds#metis)

Andromeda Mainnet: [0x58218ea7422255EBE94e56b504035a784b7AA204](https://andromeda-explorer.metis.io/address/0x58218ea7422255EBE94e56b504035a784b7AA204)

### [![Image 14](https://docs.chain.link/assets/chains/optimism.svg)OP](https://docs.chain.link/data-feeds/l2-sequencer-feeds#op)

OP Mainnet: [0x371EAD81c9102C9BF4874A9075FFFf170F2Ee389](https://optimistic.etherscan.io/address/0x371EAD81c9102C9BF4874A9075FFFf170F2Ee389)

### [![Image 15](https://docs.chain.link/assets/chains/scroll.svg)Scroll](https://docs.chain.link/data-feeds/l2-sequencer-feeds#scroll)

Scroll Mainnet: [0x45c2b8C204568A03Dc7A2E32B71D67Fe97F908A9](https://scrollscan.com/address/0x45c2b8C204568A03Dc7A2E32B71D67Fe97F908A9)

### [![Image 16](https://docs.chain.link/assets/chains/soneium.svg)Soneium](https://docs.chain.link/data-feeds/l2-sequencer-feeds#soneium)

Soneium Mainnet: [0xaDE1b9AbB98c6A542E4B49db2588a3Ec4bF7Cdf0](https://soneium.blockscout.com/address/0xaDE1b9AbB98c6A542E4B49db2588a3Ec4bF7Cdf0)

### [![Image 17](https://docs.chain.link/assets/chains/xlayer.svg)X Layer](https://docs.chain.link/data-feeds/l2-sequencer-feeds#x-layer)

X Layer Mainnet: [0x45c2b8C204568A03Dc7A2E32B71D67Fe97F908A9](https://www.okx.com/web3/explorer/xlayer/address/0x45c2b8C204568A03Dc7A2E32B71D67Fe97F908A9)

### [![Image 18](https://docs.chain.link/assets/chains/zksync.svg)ZKsync](https://docs.chain.link/data-feeds/l2-sequencer-feeds#zksync)

zkSync Mainnet: [0x0E6AC8B967393dcD3D36677c126976157F993940](https://explorer.zksync.io/address/0x0E6AC8B967393dcD3D36677c126976157F993940)

## [Real-time Monitoring Process](https://docs.chain.link/data-feeds/l2-sequencer-feeds#real-time-monitoring-process)

### [Arbitrum](https://docs.chain.link/data-feeds/l2-sequencer-feeds#arbitrum-1)

The diagram below shows how these feeds update and how a consumer retrieves the status of the Arbitrum sequencer.

![Image 19](https://docs.chain.link/images/data-feed/l2-diagram-arbitrum.webp)

1.   Chainlink nodes trigger an OCR round every 30s and update the sequencer status by calling the `validate` function in the [`ArbitrumValidator` contract](https://github.com/smartcontractkit/chainlink/blob/contracts-v1.3.0/contracts/src/v0.8/l2ep/dev/arbitrum/ArbitrumValidator.sol) by calling it through the [`ValidatorProxy` contract](https://github.com/smartcontractkit/chainlink/blob/contracts-v1.0.0/contracts/src/v0.8/ValidatorProxy.sol).
2.   The `ArbitrumValidator` checks to see if the latest update is different from the previous update. If it detects a difference, it places a message in the [Arbitrum inbox contract](https://docs.arbitrum.io/how-arbitrum-works/inside-arbitrum-nitro).
3.   The inbox contract sends the message to the [`ArbitrumSequencerUptimeFeed` contract](https://github.com/smartcontractkit/chainlink/blob/contracts-v1.3.0/contracts/src/v0.8/l2ep/dev/arbitrum/ArbitrumSequencerUptimeFeed.sol). The message calls the `updateStatus` function in the `ArbitrumSequencerUptimeFeed` contract and updates the latest sequencer status to 0 if the sequencer is up and 1 if it is down. It also records the block timestamp to indicate when the message was sent from the L1 network.
4.   A consumer contract on the L2 network can read these values from the [`ArbitrumUptimeFeedProxy` contract](https://github.com/smartcontractkit/chainlink/blob/contracts-v1.0.0/contracts/src/v0.6/EACAggregatorProxy.sol), which reads values from the `ArbitrumSequencerUptimeFeed` contract.

#### [Handling Arbitrum Outages](https://docs.chain.link/data-feeds/l2-sequencer-feeds#handling-arbitrum-outages)

If the Arbitrum network becomes unavailable, the `ArbitrumValidator` contract continues to send messages to the L2 network through the delayed inbox on L1. This message stays there until the sequencer is back up again. When the sequencer comes back online after downtime, it processes all transactions from the delayed inbox before it accepts new transactions. The message that signals when the sequencer is down will be processed before any new messages with transactions that require the sequencer to be operational.

### [Other Supported Networks](https://docs.chain.link/data-feeds/l2-sequencer-feeds#other-supported-networks)

On BASE, Celo, Mantle, Metis, OP, Scroll, Soneium and zkSync, the sequencer's status is relayed from L1 to L2 where the consumer can retrieve it.

![Image 20](https://docs.chain.link/images/data-feed/l2-diagram-optimism-metis.webp)

**On the L1 network:**

1.   A network of node operators runs the external adapter to post the latest sequencer status to the `AggregatorProxy` contract and relays the status to the `Aggregator` contract. The `Aggregator` contract calls the `validate` function in the `OptimismValidator` contract.

2.   The `OptimismValidator` contract calls the `sendMessage` function in the `L1CrossDomainMessenger` contract. This message contains instructions to call the `updateStatus(bool status, uint64 timestamp)` function in the sequencer uptime feed deployed on the L2 network.

3.   The `L1CrossDomainMessenger` contract calls the `enqueue` function to enqueue a new message to the `CanonicalTransactionChain`.

4.   The `Sequencer` processes the transaction enqueued in the `CanonicalTransactionChain` contract to send it to the L2 contract.

**On the L2 network:**

1.   The `Sequencer` posts the message to the `L2CrossDomainMessenger` contract.

2.   The `L2CrossDomainMessenger` contract relays the message to the `OptimismSequencerUptimeFeed` contract.

3.   The message relayed by the `L2CrossDomainMessenger` contains instructions to call `updateStatus` in the `OptimismSequencerUptimeFeed` contract.

4.   Consumers can then read from the `AggregatorProxy` contract, which fetches the latest round data from the `OptimismSequencerUptimeFeed` contract.

#### [Handling Other Supported Network Outages](https://docs.chain.link/data-feeds/l2-sequencer-feeds#handling-other-supported-network-outages)

If the sequencer is down, messages cannot be transmitted from L1 to L2 and **no L2 transactions are executed**. Instead, messages are enqueued in the `CanonicalTransactionChain` on L1 and only processed in the order they arrived later when the sequencer comes back up. As long as the message from the validator on L1 is already enqueued in the `CTC`, the flag on the sequencer uptime feed on L2 will be guaranteed to be flipped prior to any subsequent transactions. The transaction that flips the flag on the uptime feed will be executed before transactions that were enqueued after it. This is further explained in the diagrams below.

When the Sequencer is down, all L2 transactions sent from the L1 network wait in the pending queue.

1.   **Transaction 3** contains Chainlink's transaction to set the status of the sequencer as being down on L2.
2.   **Transaction 4** is a transaction made by a consumer that is dependent on the sequencer status.

![Image 21](https://docs.chain.link/images/data-feed/seq-down-1.webp)

After the sequencer comes back up, it moves all transactions in the pending queue to the processed queue.

1.   Transactions are processed in the order they arrived so **Transaction 3** is processed before **Transaction 4**.
2.   Because **Transaction 3** happens before **Transaction 4**, **Transaction 4** will read the status of the Sequencer as being down and responds accordingly.

![Image 22](https://docs.chain.link/images/data-feed/seq-down-2.webp)

## [Example Consumer Contract](https://docs.chain.link/data-feeds/l2-sequencer-feeds#example-consumer-contract)

This example code works on any network that supports Solidity. Create the consumer contract for sequencer uptime feeds similarly to the contracts that you use for other [Chainlink Data Feeds](https://docs.chain.link/data-feeds/using-data-feeds). Configure the constructor using the following variables:

*   Configure the `sequencerUptimeFeed` object with the [sequencer uptime feed proxy address](https://docs.chain.link/data-feeds/l2-sequencer-feeds#supported-networks) for your L2 network.
*   Configure the `dataFeed` object with one of the [Data Feed proxy addresses](https://docs.chain.link/data-feeds/price-feeds/addresses) that are available for your network.

![Image 23: copy to clipboard](https://docs.chain.link/assets/icons/copyIcon.svg)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {AggregatorV2V3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV2V3Interface.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract DataConsumerWithSequencerCheck {
  AggregatorV2V3Interface internal dataFeed;
  AggregatorV2V3Interface internal sequencerUptimeFeed;

  uint256 private constant GRACE_PERIOD_TIME = 3600;

  error SequencerDown();
  error GracePeriodNotOver();

  /**
   * Network: OP Mainnet
   * Data Feed: BTC/USD
   * Data Feed address: 0xD702DD976Fb76Fffc2D3963D037dfDae5b04E593
   * Uptime Feed address: 0x371EAD81c9102C9BF4874A9075FFFf170F2Ee389
   * For a list of available Sequencer Uptime Feed proxy addresses, see:
   * https://docs.chain.link/docs/data-feeds/l2-sequencer-feeds
   */
  constructor() {
    dataFeed = AggregatorV2V3Interface(0xD702DD976Fb76Fffc2D3963D037dfDae5b04E593);
    sequencerUptimeFeed = AggregatorV2V3Interface(0x371EAD81c9102C9BF4874A9075FFFf170F2Ee389);
  }

  // Check the sequencer status and return the latest data
  function getChainlinkDataFeedLatestAnswer() public view returns (int256) {
    // prettier-ignore
    (
      /*uint80 roundID*/
      ,
      int256 answer,
      uint256 startedAt,
      /*uint256 updatedAt*/
      ,
      /*uint80 answeredInRound*/
    ) = sequencerUptimeFeed.latestRoundData();

    // Answer == 0: Sequencer is up
    // Answer == 1: Sequencer is down
    bool isSequencerUp = answer == 0;
    if (!isSequencerUp) {
      revert SequencerDown();
    }

    // Make sure the grace period has passed after the
    // sequencer is back up.
    uint256 timeSinceUp = block.timestamp - startedAt;
    if (timeSinceUp <= GRACE_PERIOD_TIME) {
      revert GracePeriodNotOver();
    }

    // prettier-ignore
    (
      /*uint80 roundID*/
      ,
      int256 data,
      /*uint startedAt*/
      ,
      /*uint timeStamp*/
      ,
      /*uint80 answeredInRound*/
    ) = dataFeed.latestRoundData();

    return data;
  }
}
```

[Open in Remix](https://remix.ethereum.org/#url=https://docs.chain.link/samples/DataFeeds/DataConsumerWithSequencerCheck.sol&autoCompile=true)[What is Remix?](https://docs.chain.link/getting-started/conceptual-overview#what-is-remix)

The `sequencerUptimeFeed` object returns the following values:

*   `answer`: A variable with a value of either `0` or `1`
    *   0: The sequencer is up
    *   1: The sequencer is down

*   `startedAt`: This timestamp indicates when the sequencer feed changed status. When the sequencer comes back up after an outage, wait for the `GRACE_PERIOD_TIME` to pass before accepting answers from the data feed. Subtract `startedAt` from `block.timestamp` and revert the request if the result is less than the `GRACE_PERIOD_TIME`. 
    *   The `startedAt` variable returns `0` only on Arbitrum when the Sequencer Uptime contract is not yet initialized. For L2 chains other than Arbitrum, `startedAt` is set to `block.timestamp` on construction and `startedAt` is never `0`. After the feed begins rounds, the `startedAt` timestamp will always indicate when the sequencer feed last changed status.

If the sequencer is up and the `GRACE_PERIOD_TIME` has passed, the function retrieves the latest answer from the data feed using the `dataFeed` object.

Use with LLMs AI Copy page

## On this page

*   [Overview](https://docs.chain.link/data-feeds/l2-sequencer-feeds#overview)
*   [Supported Networks](https://docs.chain.link/data-feeds/l2-sequencer-feeds#supported-networks)
*   [Arbitrum](https://docs.chain.link/data-feeds/l2-sequencer-feeds#arbitrum)
*   [BASE](https://docs.chain.link/data-feeds/l2-sequencer-feeds#base)
*   [Celo](https://docs.chain.link/data-feeds/l2-sequencer-feeds#celo)
*   [Mantle](https://docs.chain.link/data-feeds/l2-sequencer-feeds#mantle)
*   [MegaETH](https://docs.chain.link/data-feeds/l2-sequencer-feeds#megaeth)
*   [Metis](https://docs.chain.link/data-feeds/l2-sequencer-feeds#metis)
*   [OP](https://docs.chain.link/data-feeds/l2-sequencer-feeds#op)
*   [Scroll](https://docs.chain.link/data-feeds/l2-sequencer-feeds#scroll)
*   [Soneium](https://docs.chain.link/data-feeds/l2-sequencer-feeds#soneium)
*   [X Layer](https://docs.chain.link/data-feeds/l2-sequencer-feeds#x-layer)
*   [ZKsync](https://docs.chain.link/data-feeds/l2-sequencer-feeds#zksync)
*   [Real-time Monitoring Process](https://docs.chain.link/data-feeds/l2-sequencer-feeds#real-time-monitoring-process)
*   [Arbitrum](https://docs.chain.link/data-feeds/l2-sequencer-feeds#arbitrum-1)
*   [Handling Arbitrum Outages](https://docs.chain.link/data-feeds/l2-sequencer-feeds#handling-arbitrum-outages)
*   [Other Supported Networks](https://docs.chain.link/data-feeds/l2-sequencer-feeds#other-supported-networks)
*   [Handling Other Supported Network Outages](https://docs.chain.link/data-feeds/l2-sequencer-feeds#handling-other-supported-network-outages)
*   [Example Consumer Contract](https://docs.chain.link/data-feeds/l2-sequencer-feeds#example-consumer-contract)

## More

*   [Complete Data Feeds docs (TXT)](https://docs.chain.link/data-feeds/llms-full.txt)
*   [Edit this page](https://github.com/smartcontractkit/documentation/tree/main/src/content/data-feeds/l2-sequencer-feeds.mdx)
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

*   ![Image 24](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcc8de393ea2bffa0ff_twitter.svg)[Twitter](https://twitter.com/chainlink)
*   ![Image 25](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcc3830fc22d9bc18c8_youtube.svg)[YouTube](https://www.youtube.com/channel/UCnjkrlqaWEBSnKZQ71gdyFA)
*   ![Image 26](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcff3840d5ec8300b30_discord.svg)[Discord](https://discord.gg/aSK4zew)
*   ![Image 27](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcceaf22843cde97118_telegram.svg)[Telegram](https://t.me/chainlinkofficial)
*   ![Image 28](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcc8e9ff41b546f039f_wechat.svg)[WeChat](https://blog.chain.link/chainlink-chinese-communities/)
*   ![Image 29](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f760fcc8f83d17d2d857106_reddit.svg)[Reddit](https://www.reddit.com/r/Chainlink/)

[![Image 30: Chainlink logo](https://assets-global.website-files.com/5f6b7190899f41fb70882d08/5f7610da8f83d1e6028573c7_chainlink-logo-footer.svg)](https://docs.chain.link/)

Chainlink®

 © 2026 Chainlink Foundation 

[Privacy Policy](https://chain.link/privacy-policy)[Terms of Use](https://chain.link/terms)

Ask AI
