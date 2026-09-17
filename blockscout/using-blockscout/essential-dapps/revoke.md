> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Revoke

> Use the Blockscout Revoke Essential Dapp to review and revoke ERC-20 and NFT token approvals across Ethereum, OP Mainnet, Gnosis, Base, and Ink.

<Warning>
  Revoke is currently being updated for inclusion in Essential Dapps. It will be released shortly.
</Warning>

Many applications require you to grant approvals so that their contracts can interact with tokens in your wallet. This can be a security issue if you have granted unlimited or high allowances, or have granted approvals and forgotten about them. If an application is hacked or misused in some way, this can result in funds being quickly drained from your wallet.

The Revoke app lets you manage your approvals from a single interface. Easily check, update, and revoke token allowances you may have granted to different applications.

## Access the App

Revoke can be accessed directly via the Essential Dapps menu or as an app via the Dappscout interface in Blockscout on supported chains.

<Warning>
  Revoke supports a subset of chains including Ethereum, OP Mainnet, Gnosis, Base and Ink.
</Warning>

<Frame caption="Accessing Revoke via the Dapps menu">
  <img src="https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/5b607960-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=e877f4233f9f67ed47122076ef19c1ca" alt="" width="1922" height="1010" data-path="images/5b607960-image.jpeg" />
</Frame>

## Check and Revoke

1. Select the chain you want to check.

2. Connect the wallet you want to revoke allowances for.

<Frame caption>
  <img src="https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/bc1825e5-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=cf12c008049d7e503086f1d8b7cae85a" alt="" width="1958" height="1232" data-path="images/bc1825e5-image.jpeg" />
</Frame>

3. Review any allowances and click the Revoke button for those you want to revoke.

<Frame caption>
  <img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/df898b5c-image.jpeg?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=591622845ebefe676ed37b238044fc46" alt="" width="1996" height="1160" data-path="images/df898b5c-image.jpeg" />
</Frame>

4. Confirm the transaction in your web3 wallet. This does not require any gas or transaction fees.

<Frame caption>
  <img src="https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/7149ce5f-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=4d29aa66b5e41a0ae5f5f99e93e5ab24" alt="" width="2144" height="1436" data-path="images/7149ce5f-image.jpeg" />
</Frame>

5. Your permissions will update momentarily.

<Frame caption="Success message - takes a moment for permission to be removed from UI">
  <img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/fa186fad-image.jpeg?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=87425bec3b82d5c10fda1571f7627cd8" alt="" width="2008" height="1152" data-path="images/fa186fad-image.jpeg" />
</Frame>

<Frame caption="Permissions updated">
  <img src="https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/bc74d5d4-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=868f142063720f9a016ac492e0fe09d3" alt="" width="2018" height="1266" data-path="images/bc74d5d4-image.jpeg" />
</Frame>

## **FAQ**

<AccordionGroup>
  <Accordion title="Why can't I see the _Value at Risk_ for the approved amount?">
    This usually happens when the price information in USD is not available for a particular token. In these cases, the token amount is displayed without an associated USD conversion.
  </Accordion>

  <Accordion title="Can I revoke multiple approvals at once?">
    Not yet. We're still working on this functionality, and it will be added in future releases.
  </Accordion>

  <Accordion title="Can I use a hardware wallet with Revoke?">
    Yes, you can use any wallet that **WalletConnect** supports.
  </Accordion>

  <Accordion title="Why should I revoke access to my tokens?">
    It's always a good practice to **limit token approvals** when you're not actively using a dapp, especially on **NFT marketplaces**. This reduces the risk of losing funds due to hacks or exploits and helps mitigate the damage caused by phishing scams.
  </Accordion>

  <Accordion title="Why should I use Revoke?">
    Revoke is designed to provide valuable insights about your tokens and account. Instead of only allowing you to revoke token approvals, we offer a **comprehensive overview** of spender accounts. This way, you can make informed decisions and better understand **who has access** to your tokens.
  </Accordion>
</AccordionGroup>

## **Roadmap**

1. **Public Tags**

   We plan to highlight key information about **approved spender contracts**, ensuring users are aware of **who has access** to their tokens. If an approved spender gets hacked or is flagged as a scam, this information will be added to Blockscout, allowing users to react promptly.
2. **Sorting**

   To improve user experience, we're introducing sorting options for approvals. Users will be able to sort approvals by **amount, date, and value at risk**.
3. **Bulk Revoke for Multiple Tokens**

   We're working on adding a **multi-token revoke feature** in upcoming releases to speed up the process.
