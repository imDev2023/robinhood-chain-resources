> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Interacting with Smart Contracts

> Read from and write to verified smart contracts directly in the Blockscout UI by connecting a web3 wallet like MetaMask to any supported chain.

Once a contract is verified, contract methods are exposed and contract interaction is possible directly from Blockscout.

<Info>
  In the following examples we use Blockscout on Gnosis Chain. You can interact with verified contracts on any supported chain. Make sure your web3 wallet (like MetaMask) is also connected to that chain when reading / writing to a contract.
</Info>

## Read Contract

Read actions let you check various contract attributes. You will need to connect a web3 wallet to make a query, though a query does not require a transaction or any gas costs.

1\) Find the contract address you want to interact with and enter it into the search bar. In this example we search for USDC on Gnosis Chain.

<Frame caption="Search bar results">
  <img src="https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/9916e191-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=5a147b4f169e988935abe89bc9ae7c1e" width="1186" height="468" data-path="images/9916e191-image.jpeg" />
</Frame>

2\) We select the first option in search and are taken to the token page. We can interact from here, but would prefer to see more information about the contract, so we click through to the contract page.

<Frame caption="Read and Write methods are available, but we click on the Contract to see more.">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/4dd1d029-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=5bbb8f3cdbe681c20b4b32f506274ef0" width="2230" height="1324" data-path="images/4dd1d029-image.jpeg" />
</Frame>

3\) Scrolling down past the contract details we see the code is verified by the checkmark✅. If the code is not verified, it is not possible to read or write to a contract (unless a verified contract with the same bytecode is located in the Blockscout database. In this case read/write will also be available).

<Frame caption="Code is verified">
  <img src="https://mintcdn.com/blockscout/JTppjXqh5Q4u166M/images/1e54b929-image.jpeg?fit=max&auto=format&n=JTppjXqh5Q4u166M&q=85&s=129112de2d01bce32562f612deeb9c5e" width="2182" height="1402" data-path="images/1e54b929-image.jpeg" />
</Frame>

4\) We know this is a proxy implementation by the fact that there are options to either read/write to the contract or to the proxy. Proxy means that the contract is upgradeable, and the admin can set a new implementation address for the proxy contract if upgrades are required.

We will choose to **Read Proxy**, since it contains all the relevant methods for the current contract implementation.

<Frame caption="Read proxy to find relevant methods. Read contract will only show implementation address.">
  <img src="https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/ae795246-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=418c5b9b72887abb1ff78ad770acbf9a" width="2244" height="446" data-path="images/ae795246-image.jpeg" />
</Frame>

5\) We can see the various methods within the proxy contract. Some show current values and others are queryable. An easy example to query is 8) `balanceOf` method.

<Frame caption="Scroll down to find balanceOf method">
  <img src="https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/acd63efe-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=514582d6183de5c057d4ba241c4ad2be" width="2188" height="1232" data-path="images/acd63efe-image.jpeg" />
</Frame>

6\) This method expects an address and will output an integer. Simply paste in an 0x address and press **Query** to see the balance in USDC held by that particular address. If your web3 wallet is not connected at this point, you will be prompted to connect.

<Frame caption="Query directly from Blockscout">
  <img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/fa347589-image.jpeg?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=b5bbefb2df3dde459c626582231f42a2" width="2154" height="494" data-path="images/fa347589-image.jpeg" />
</Frame>

The result shows this address holds 1,000,000 of the token, which converts to 1 USDC. *(Note ERC20 tokens allow for custom decimal point precision. USDC uses 6 decimal precision. Many others use 18 (to denote wei) so be sure to check the token implementation for conversion info).*

## Write Contract

<Info>
  Many write functions can only be performed by an approved owner. Connect the owner wallet when performing gated functions.
</Info>

1\) We'll use Blockscout to transfer 0.50 USDC from 1 address to another. You can perform this action directly through a wallet UI, we use the Blockscout interface here for demonstration purposes. See steps 1-3 above for accessing USDC on Gnosis Chain, or simply type the contract address (*0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83*) into the search bar. Scroll down and select **Write Proxy**.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/9b0fee53-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=adf22a38be5c0aea88a6d66cc2d8f559" width="2228" height="1462" data-path="images/9b0fee53-image.jpeg" />
</Frame>

2\) We scroll down to find the `transferFrom` method.

<Frame caption="Empty fields with prompts">
  <img src="https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/b176701d-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=bfdb93d4c9ca12f2bf3f556405187a0c" width="2076" height="406" data-path="images/b176701d-image.jpeg" />
</Frame>

Boxes are filled with the following information:

1. `_sender(address)`: The `0x` address sending the USDC. Note this account is the one to connect to Blockscout to write to the contract.

2. `_recipient(address)`: The `0x` address receiving the USDC.

3. `_amount(uint256)`: Amount to transfer. We use 6 decimals of precision for USDC - for other tokens this can differ. Here we enter 500000 to denote \$0.50.

<Frame caption="Filled fields">
  <img src="https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/93796754-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=64ee3ec862d091d1cfb65473be06dccd" width="2070" height="396" data-path="images/93796754-image.jpeg" />
</Frame>

3\) We press the **Write** button, and MetaMask or another web3 wallet takes us through the transaction. If a wallet is not connected, there will be several prompts to connect an account to Blockscout. Once connected, we confirm the transaction.

<Info>
  The connected wallet must contain enough native tokens (in this case xDai) to pay gas for the transaction.
</Info>

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/3838e550-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=c979475196d452b34364c63e285247ad" width="1288" height="855" data-path="images/3838e550-image.jpeg" />
</Frame>

4\) We can check our wallet to confirm the transaction, and can view tx details in Blockscout (or return to the [Read Contract](/devs/verification/interacting-with-smart-contracts#read-contract) `balanceOf` method to view new balances for the addresses).

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/2a4d35f8-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=95f1e2cd4da10a3a432d6844022c8284" width="1330" height="639" data-path="images/2a4d35f8-image.jpeg" />
</Frame>

Transaction hash: [0x2c93c4e6618b30c552b95ce2eef16b6e663d99aa2f4a8ea55a70b693de70f113](https://gnosis.blockscout.com/tx/0x2c93c4e6618b30c552b95ce2eef16b6e663d99aa2f4a8ea55a70b693de70f113)

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/dcd22c90-image.jpeg?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=f64051d01c5573af3ef616bdb0a101b1" width="2304" height="1280" data-path="images/dcd22c90-image.jpeg" />
</Frame>
