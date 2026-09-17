> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Sourcify plugin for Hardhat

> Submit deployed contract sources to Sourcify from your Hardhat project so Blockscout can display verified metadata alongside on-chain contracts.

Similar to the [hardhat verification plugin](/devs/verification/hardhat-verification-plugin), this plugin submits the contract source and other info of all deployed contracts to Sourcify.

### Verify

Similar to the verification approach described in the [hardhat verification plugin](/devs/verification/hardhat-verification-plugin), you can verify the contract source code in Sourcify as well by setting the following in the hardhat config file:

```javascript theme={null}
// ...
const config: HardhatUserConfig = {
  // ...
  sourcify: {
    enabled: true
  },
  // ...
};

export default config;
```

```sh theme={null}
npx hardhat verify --network <network> DEPLOYED_CONTRACT_ADDRESS "Constructor argument 1"
```

Optimism Sepolia example:

```sh theme={null}
> npx hardhat verify --network optimism-sepolia 0xCD562a6426b474390A9E7e554b9B4f9f62Ea38Ba 1234
Successfully submitted source code for contract
contracts/Lock.sol:Lock at 0xCD562a6426b474390A9E7e554b9B4f9f62Ea38Ba
for verification on the block explorer. Waiting for verification result...

Successfully verified contract Lock on the block explorer.
https://optimism-sepolia.blockscout.com/address/0xCD562a6426b474390A9E7e554b9B4f9f62Ea38Ba#code

Successfully verified contract Lock on Sourcify.
https://repo.sourcify.dev/contracts/full_match/11155420/0xCD562a6426b474390A9E7e554b9B4f9f62Ea38Ba/
```

## Confirm Verification on Blockscout

Go to your BlockScout instance and paste the contract address into the search bar.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/fc3fb8d9-image.jpeg?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=2fc1cecaf730ea7fbf4fd566fd413e83" alt="" width="2304" height="769" data-path="images/fc3fb8d9-image.jpeg" />
</Frame>

Scroll down to see verified status. A green checkmark ✅ means the contract is verified.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/d9dab800-image.jpeg?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=ee2eb70382b67af5ff3b2c25c88ab45a" alt="" width="2304" height="1265" data-path="images/d9dab800-image.jpeg" />
</Frame>

If your screen size is limited, you may need to click the 3 dots to view and click through to the contract.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/47a3a81c-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=2bd1af7338892a842cfc74d0e8c25a01" alt="" width="1960" height="338" data-path="images/47a3a81c-image.jpeg" />
</Frame>

Scroll down to see and interact with the contract code.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/9ae7288e-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=bb40b3bb2184da91894d59d91af2d268" alt="" width="2304" height="1468" data-path="images/9ae7288e-image.jpeg" />
</Frame>
