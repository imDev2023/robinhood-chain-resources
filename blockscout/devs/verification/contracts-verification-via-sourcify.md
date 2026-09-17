> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Verify contracts via Sourcify on Blockscout

> Verify smart contracts on Blockscout using the Sourcify verification option, matching metadata and source files against Sourcify's decentralized repo.

Along with contract verification through a flattened source file (the default option in Blockscout), a [Sourcify](https://sourcify.dev/) verification option through their UI is also available.

## Usage Example

Verify your contract using Sourcify:

1\) Go to the Verify contract page *(Other -> Verify contract)*

<Frame caption="Go to Other -> Verify contract">
  <img src="https://mintcdn.com/blockscout/1h4J9dipJke_YkFi/images/sourcify-step-1.jpg?fit=max&auto=format&n=1h4J9dipJke_YkFi&q=85&s=bfd7a923e0068335c8c0bd776d0a2efa" width="1344" height="862" data-path="images/sourcify-step-1.jpg" />
</Frame>

2\) Enter the deployed contract address, select Sourcify (Solidity or Vyper) from the Verification method dropdown.

<Frame caption="Enter contract address and select Sourcify as verification method">
  <img src="https://mintcdn.com/blockscout/1h4J9dipJke_YkFi/images/sourcify-step-2.jpg?fit=max&auto=format&n=1h4J9dipJke_YkFi&q=85&s=d745918e4b267f639361a0cf2193d914" width="1344" height="862" data-path="images/sourcify-step-2.jpg" />
</Frame>

3\) Now follow the instructions inside the Sourcify widget. Select the smart contract language of the source code and a verification method.

<Frame caption="Select source code language and verification method inside the Sourcify widget">
  <img src="https://mintcdn.com/blockscout/1h4J9dipJke_YkFi/images/sourcify-step-3.jpg?fit=max&auto=format&n=1h4J9dipJke_YkFi&q=85&s=5eed7ec295543f5408f307cd2283b9fd" width="1344" height="862" data-path="images/sourcify-step-3.jpg" />
</Frame>

4\) Upload or paste your contract source code according to the selected verification method. In the example, we paste the contract sources as Std JSON into the text box. Select the compiler version and contract identifier.

Once all information is provided, start the verification by clicking the Verify Contract button.

<Frame caption="Input source code, and select compiler version and contract identifier">
  <img src="https://mintcdn.com/blockscout/1h4J9dipJke_YkFi/images/sourcify-step-4.jpg?fit=max&auto=format&n=1h4J9dipJke_YkFi&q=85&s=46be20213e0d2fb28d3717baba665d81" width="1348" height="911" data-path="images/sourcify-step-4.jpg" />
</Frame>

5\) You can follow the verification process by clicking on the View Job Status button.

After several seconds your contract should be verified through Sourcify's API (If verification fails, you will see the reason in the job status page). Verification metadata will be saved in the Blockscout DB and you will see the verified contract page with the link to the same metadata in the [Sourcify contract repository](https://repo.sourcify.dev/).

<Frame caption="View job status and verification result">
  <img src="https://mintcdn.com/blockscout/1h4J9dipJke_YkFi/images/sourcify-step-5.jpg?fit=max&auto=format&n=1h4J9dipJke_YkFi&q=85&s=406e7c3522c8892979667b2b79f4fda6" width="1348" height="904" data-path="images/sourcify-step-5.jpg" />
</Frame>

### Example Contract:

* Contract [verified in Blockscout](https://gnosis.blockscout.com/address/0x4f15a6e74CFC2F80D5967a8aB75F3c83D8043cF4?tab=contract)

* The same contract in the [Sourcify contract repository](https://repo.sourcify.dev/contracts/full_match/100/0x4f15a6e74CFC2F80D5967a8aB75F3c83D8043cF4/).
