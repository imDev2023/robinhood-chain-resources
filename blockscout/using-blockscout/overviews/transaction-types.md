> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Transaction Types: Blob, Coin, Contract, and Token

> How Blockscout categorizes transactions including blob (EIP-4844), coin transfer, contract call, contract creation, token transfer, minting, and burning.

Different types of transactions are categorized in the Blockscout UI to allow for quick identification. Types include:

* **Blob txn:** 4844-type transactions which include large amounts of data
* **Coin transfer**: value transfer, value >= 0, no tx input
* **Contract call**: tx input is present (any value including 0)
* **Contract creation**: creation of a smart-contract
* **Token burning**: recognized token transfer of any of ERC-20, 721, 1155 token instance (single or bulk) to 0x0000... address
* **Token creation**: creation of token instance in ERC-1155
* **Token minting**: token transfer of any of ERC-20, 721, 1155 token instance (single or bulk) from 0x0000... address
* **Token transfer**: token transfer of any of ERC-20, 721, 1155 token instance (single or bulk)
* **Transaction**: A contract call where the contract has not yet been identified by Blockscout.

<Frame caption="Transaction types in UI v2">
  <img src="https://mintcdn.com/blockscout/JTppjXqh5Q4u166M/images/10a1708b-image.jpeg?fit=max&auto=format&n=JTppjXqh5Q4u166M&q=85&s=38975e60d186b7125808bbc984b03a4e" alt="" width="2304" height="1485" data-path="images/10a1708b-image.jpeg" />
</Frame>

<Frame caption="Transaction types in UI v1">
  <img src="https://mintcdn.com/blockscout/JTppjXqh5Q4u166M/images/11e455a3-image.jpeg?fit=max&auto=format&n=JTppjXqh5Q4u166M&q=85&s=7e8953cc16f54f76264a55c57c93be3f" alt="" width="2056" height="1084" data-path="images/11e455a3-image.jpeg" />
</Frame>
