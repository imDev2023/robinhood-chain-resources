> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# User FAQs

> User FAQs for the Blockscout explorer covering transactions, addresses, tokens, verified contracts, My Account features, and common troubleshooting.

If you have a question that isn't answered here, please contact us in [our Discord](https://discord.gg/blockscout) and the team and community can help troubleshoot your issue.

## User FAQs

<AccordionGroup>
  <Accordion title="What does the &#x22;in&#x22; or &#x22;out&#x22; label mean on a transaction?">
    This label appears next to a transaction to signify whether a transaction was sent or received by a particular address.

    * **In:** A transaction was sent to the address
    * **Out:** A transaction was initiated from the address

    <Frame>
      <img src="https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/827b5c51-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=fa3b205d5062420b0610f2dab9f13ccd" alt="" width="900" height="264" data-path="images/827b5c51-image.jpeg" />
    </Frame>
  </Accordion>

  <Accordion title="What are the different transaction types?">
    **There are 3 transaction types which can be accessed from the tabs menu for an EOA (Externally Owned Address) or Smart Contract.**

    **Transactions:**

    An EOA, commonly known as a wallet address, initiates a transaction. Both incoming and outgoing transactions are recorded here, and include any transaction that requires a gas fee (in the native token ETH, xDai etc) for execution.

    **Token Transfers:**

    Transactions of ERC-20 or ERC-721 tokens. This can include DeFi transactions (like adding or removing liquidity), EOA transfers, airdrops or other transactions where non-native tokens are sent and received.

    **Internal Transactions:**

    Transactions initiated and executed between smart contracts. Internal transactions are the result of an external transaction (EOA to contract). This initial transaction can then trigger many internal transactions between contracts as functions are called.

    <Frame>
      <img src="https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/d7ee3177-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=7c36eab04283c832631d9c544af246c8" alt="" width="900" height="593" data-path="images/d7ee3177-image.jpeg" />
    </Frame>
  </Accordion>

  <Accordion title="What is CSV export error 504?">
    If you request too much data at the same time you may receive a timeout. Decreasing the period of time for an export (**1 week timeframe** is recommended for addresses with lots of transactions) can reduce these errors.
  </Accordion>

  <Accordion title="How can I access and read/write contract methods?">
    Yes! The contract should be verified (or the bytecode matches an existing contract) to enable reading and writing to contracts and proxy contracts. [More info here](/devs/verification/interacting-with-smart-contracts).
  </Accordion>

  <Accordion title="How do I verify a smart contract?">
    There are multiple methods including options from the Blockscout UI as well as an integration directly with Hardhat.

    **Blockscout UI:**

    * [Via flattened source code (Solidity)](/devs/verification#via-flattened-source-code)
    * [Via standard JSON input](/faqs/faqs#via-standard-json-input)
    * [Via Sourcify: Sources and metadata JSON file](/devs/verification/contracts-verification-via-sourcify)
    * [Vyper contract](/devs/verification#vyper-contract)

    **Hardhat:**

    * [Hardhat Verification Plugin](/devs/verification/hardhat-verification-plugin)
    * [Sourcify Plugin for Hardhat](/devs/verification/hardhat-verification-plugin/sourcify-plugin-for-hardhat)
  </Accordion>

  <Accordion title="Where can I find a list of all Blockscout explorers?">
    At [<u>https://chains.blockscout.com</u>](https://chains.blockscout.com)
  </Accordion>

  <Accordion title="How can I swap or bridge tokens?">
    Tokens can be swapped using [<u>https://swap.blockscout.com</u>](https://swap.blockscout.com)
  </Accordion>
</AccordionGroup>
