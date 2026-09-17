> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Integration Guide

> Install and integrate the Blockscout global wallet SDK into your dapp with npm, connect to Rootstock or other supported chains, and enable WaaS features.

<Info>
  To learn about integrating with additional TypeScript frameworks, see our [wallet example repository.](https://github.com/blockscout/global-wallet-examples)
</Info>

<Note>
  Examples use the **Rootstock ecosystem** where our wallet is currently integrated. If you are interested in wallet support for your ecosystem, [Contact the Blockscout team](https://eaas.blockscout.com/?utm_medium=header#contact) today.
</Note>

## Resources

* WaaS Developer SDK npm package: [https://www.npmjs.com/package/@blockscout/rootstock-global-wallet](https://www.npmjs.com/package/@blockscout/rootstock-global-wallet)
* SDK integration use case examples: [https://github.com/blockscout/global-wallet-examples](https://github.com/blockscout/global-wallet-examples)
* Blockscout WaaS explainer: [https://www.blog.blockscout.com/what-is-wallet-as-a-service-waas-simplifying-web3-onboarding-ecosystem-approach](https://www.blog.blockscout.com/what-is-wallet-as-a-service-waas-simplifying-web3-onboarding-ecosystem-approach/)

## Installation

1. Install the global wallet SDK

```shellscript theme={null}
npm install @blockscout/rootstock-global-wallet
```

2. Import into your project

```shellscript theme={null}
import "@blockscout/rootstock-global-wallet/ethereum";
```

The wallet is now available for usage!

<img src="https://mintcdn.com/blockscout/1794lKjoCsptxzhE/images/image.png?fit=max&auto=format&n=1794lKjoCsptxzhE&q=85&s=1c5c4942d4db7f39eac5f155ff3f7a41" alt="Image" width="368" height="590" data-path="images/image.png" />

## Gas Sponsorship / Paymasters

Gas sponsorship is available through provider integrations. We will provide an update on [ZeroDev](https://docs.zerodev.app/sdk/infra/intro) integration shortly.
