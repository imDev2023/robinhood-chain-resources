> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Reown / WalletConnect Project ID for Contract R/W

> Create a Reown (WalletConnect) project ID and set NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID to enable contract read and write in Blockscout.

<Info>
  The latest versions of Blockscout use Reown (previously WalletConnect) for Read and Write functionality with smart contracts. The frontend variable `NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID` must be enabled with your project ID for this feature to work.
</Info>

## Setting up a Reown Project ID

1\) Go to [https://cloud.reown.com/sign-in](https://cloud.reown.com/sign-in) and sign in or create an account.

2\) Create a new Project

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/ef662cf6-image.jpeg?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=30dc1b7c7051d91c21ca8cfc3b757a3d" width="2062" height="1228" data-path="images/ef662cf6-image.jpeg" />
</Frame>

3\) Add your project information (name and project homepage) and click continue.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/5aacc1da-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=eb18b2687b393d69a7ddade56a74625e" width="1460" height="1418" data-path="images/5aacc1da-image.jpeg" />
</Frame>

4\) Select **WalletKit** as the SDK.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/f1454996-image.jpeg?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=3f739b2f087ec3c070524dbb223ddce7" width="1630" height="1330" data-path="images/f1454996-image.jpeg" />
</Frame>

5\) Select **Javascript** as the platform and create your project.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/44eaa7e8-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=327cb7be66e0611ae2ea487a62595fe3" width="1482" height="1356" data-path="images/44eaa7e8-image.jpeg" />
</Frame>

6\) Scroll down to see your basic information, including your Project ID. Before using, however, **setup Project Domains**. Please include any urls which host your explorer(s) here.

<Warning>
  This step is important because the Project ID will be exposed in the browser. Setting allowed domains prevents unauthorized usage of your ID.
</Warning>

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/d46a2c33-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=f940b89e0f75586ab1b226a1da3a865e" width="2238" height="1324" data-path="images/d46a2c33-image.jpeg" />
</Frame>

You can also verify your domains. This is not required but is recommended for security. Instructions are included in the interface.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/7caa93d0-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=34fe368d06879aa0efcb828ee92c86e9" width="1982" height="1282" data-path="images/7caa93d0-image.jpeg" />
</Frame>

7\) Copy your project ID and add in the ENV.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/e49e1dc3-image.jpeg?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=8c420743a7ce352f29a5d90b2799e061" width="2288" height="1348" data-path="images/e49e1dc3-image.jpeg" />
</Frame>

```javascript theme={null}
$ export NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=54b4....8dd05
```

<Tip>
  Your Blockscout instance will now support the Reown Project ID for Contract Read and Write functionality. [-> See more front-end ENVs related to Blockchain and contract interaction](https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#blockchain-interaction-writing-to-contract-etc).
</Tip>
