Title: GitHub - whetstoneresearch/doppler-demo-app: Demo App for the Doppler Protocol

URL Source: https://github.com/whetstoneresearch/doppler-demo-app

Markdown Content:
## Doppler V4 Miniapp

[](https://github.com/whetstoneresearch/doppler-demo-app#doppler-v4-miniapp)
This is a demo app for the Doppler protocol. It showcases deploying and interacting with Doppler auctions on EVM, plus devnet Solana launches and CPMM pool reads. It uses `@whetstone-research/doppler-sdk@1.0.22` through the EVM and Solana package entrypoints.

*   Doppler protocol on GitHub: [https://github.com/whetstoneresearch/doppler](https://github.com/whetstoneresearch/doppler)

## Get started

[](https://github.com/whetstoneresearch/doppler-demo-app#get-started)

```
git clone https://github.com/whetstoneresearch/doppler-demo-app.git
cd doppler-demo-app
pnpm install
pnpm dev
```

Optional Solana configuration:

```
VITE_SOLANA_RPC_URL=https://api.devnet.solana.com
VITE_SOLANA_INDEXER_URL=https://your-solana-indexer.example
VITE_DOPPLER_API_URL=https://your-doppler-api.example
VITE_DOPPLER_API_KEY=...
```

## What This Demo Uses From the [SDK](https://github.com/whetstoneresearch/doppler-sdk-alpha)

[](https://github.com/whetstoneresearch/doppler-demo-app#what-this-demo-uses-from-the-sdk)
*   **`DopplerSDK.factory`**: unified entry to create static (V3) and dynamic (V4) auctions.
*   **Solana SDK entrypoint**: `@whetstone-research/doppler-sdk/solana` for devnet initializer and CPMM account reads.
*   **Builder pattern**: `StaticAuctionBuilder` and `DynamicAuctionBuilder` to construct deployments.
*   **Quoter**: high-level quoting for V2/V3 and a V4 fallback.
*   **DopplerLens**: ABI-driven quoting path for dynamic auctions.
*   **Unified addresses**: one call to resolve addresses across chains.
*   **Bytecode exports**: `DopplerBytecode`/`DERC20Bytecode` for deterministic address computation.
*   **Bundled pre-buy (static/V3)**: simulate and atomically create + pre-buy via Bundler using Universal Router commands.

## Code Samples

[](https://github.com/whetstoneresearch/doppler-demo-app#code-samples)
All samples link to the exact source lines in this repo (GitHub-style anchors).

### Initialize SDK + Factory

[](https://github.com/whetstoneresearch/doppler-demo-app#initialize-sdk--factory)

// Use the unified SDK
const sdk = new DopplerSDK({
  walletClient,
  publicClient,
  chainId: 84532, // Base Sepolia
});

const factory = sdk.factory;
const addresses = getAddresses(84532);

[Source: `src/pages/CreatePool.tsx#L55-L63`](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/CreatePool.tsx#L55-L63)

### Static Auction (V3)

[](https://github.com/whetstoneresearch/doppler-demo-app#static-auction-v3)

const staticParams = new StaticAuctionBuilder()
  .saleConfig({ initialSupply, numTokensToSell, numeraire: weth })
  .poolByTicks({ startTick, endTick, fee: 10000 })
  .withMigration({ type: 'uniswapV2' })
  .withUserAddress(account.address)
  .withIntegrator(account.address)
  .build();

// Option A: plain create
const result = await factory.createStaticAuction(staticParams);

// Option B: create + pre-buy (bundle)
const { createParams, asset } = await sdk.factory.simulateCreateStaticAuction(staticParams)
const amountOut = staticParams.sale.numTokensToSell / 100n // 1%
const amountIn = await sdk.factory.simulateBundleExactOutput(createParams, { tokenIn: weth, tokenOut: asset, amount: amountOut, fee: staticParams.pool.fee, sqrtPriceLimitX96: 0n })
const { universalRouter } = getAddresses(84532)
const encoder = new SwapRouter02Encoder()
const encodedPath = encoder.encodePathExactOutput([weth, asset])
const builder = new CommandBuilder()
builder.addWrapEth(universalRouter, amountIn)
builder.addV3SwapExactOut(user, amountOut, amountIn, encodedPath, false)
const [commands, inputs] = builder.build()
const txHash = await sdk.factory.bundle(createParams, commands, inputs, { value: amountIn })

[Source: `src/pages/CreatePool.tsx#L111-L131`](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/CreatePool.tsx#L111-L131)

### Dynamic Auction (V4) with Streaming Fees

[](https://github.com/whetstoneresearch/doppler-demo-app#dynamic-auction-v4-with-streaming-fees)

const dynamicParams = new DynamicAuctionBuilder()
  .saleConfig({ initialSupply, numTokensToSell })
  .poolConfig({ fee: 20000, tickSpacing: 2 })
  .auctionByTicks({
    // Align with pure-markets-interface V4 defaults
    startTick: 174_312,
    endTick: 186_840,
    minProceeds: parseEther("100"),
    maxProceeds: parseEther("600"),
    // Omit duration/epoch/gamma to use SDK defaults
  })
  .withMigration({
    type: 'uniswapV4', fee: 3000, tickSpacing: 60,
    streamableFees: {
      lockDuration: 60 * 60 * 24 * 30,
      beneficiaries: [{ address: airlockOwner, percentage: 500 }, { address: account.address, percentage: 9500 }]
    }
  })
  .withGovernance({ useDefaults: true })
  .withUserAddress(account.address)
  .withIntegrator()
  .withTime({ blockTimestamp: Number(adjustedTimestamp) })
  .build();

const result = await factory.createDynamicAuction(dynamicParams);

[Source: `src/pages/CreatePool.tsx#L187-L238`](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/CreatePool.tsx#L187-L238)

### Doppler404 (DN404) Token Config

[](https://github.com/whetstoneresearch/doppler-demo-app#doppler404-dn404-token-config)

dynamicBuilder.tokenConfig({
  type: 'doppler404' as const,
  name: formData.tokenName,
  symbol: formData.tokenSymbol,
  baseURI: formData.baseURI || `https://metadata.example.com/${formData.tokenSymbol.toLowerCase()}/`,
})

[Source: `src/pages/CreatePool.tsx#L172-L178`](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/CreatePool.tsx#L172-L178)

### Quoting

[](https://github.com/whetstoneresearch/doppler-demo-app#quoting)

// V4 quoting
const quoter = new Quoter(publicClient, chainId)
const quoteV4 = await quoter.quoteExactInputV4({ poolKey: key, zeroForOne, exactAmount: amountIn, hookData: "0x" })

// V3 quoting 
const quoteV3 = await quoter.quoteExactInputV3({
  tokenIn, tokenOut, amountIn, fee: pool.fee, sqrtPriceLimitX96: 0n,
})

[Source: `src/pages/PoolDetails.tsx#L529-L537`](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/PoolDetails.tsx#L529-L537), [and `#L569-L575`](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/PoolDetails.tsx#L569-L575)

### Addresses

[](https://github.com/whetstoneresearch/doppler-demo-app#addresses)

import { getAddresses } from "@whetstone-research/doppler-sdk/evm";

const addresses = getAddresses(84532); // or your chainId

[Source: `src/pages/CreatePool.tsx#L5-L5`](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/CreatePool.tsx#L5-L5), [and `#L63-L63`](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/CreatePool.tsx#L63-L63)

## Questions or issues?

[](https://github.com/whetstoneresearch/doppler-demo-app#questions-or-issues)
File an issue on this repository or join the community [Discord](https://discord.gg/JcrH65zXK3).

Links/Buttons:
- [Skip to content](https://github.com/whetstoneresearch/doppler-demo-app#start-of-content)
- [](https://github.com/claude)
- [Sign in](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fwhetstoneresearch%2Fdoppler-demo-app)
- [GitHub CopilotWrite better code with AI](https://github.com/features/copilot)
- [GitHub Copilot appDirect agents from issue to merge](https://github.com/features/ai/github-app)
- [MCP RegistryIntegrate external tools](https://github.com/mcp)
- [ActionsAutomate any workflow](https://github.com/features/actions)
- [CodespacesInstant dev environments](https://github.com/features/codespaces)
- [IssuesPlan and track work](https://github.com/features/issues)
- [Code ReviewManage code changes](https://github.com/features/code-review)
- [Code QualityEnforce quality at merge](https://github.com/features/code-quality)
- [GitHub Advanced SecurityFind and fix vulnerabilities](https://github.com/security/advanced-security)
- [Code securitySecure your code as you build](https://github.com/security/advanced-security/code-security)
- [Secret protectionStop leaks before they start](https://github.com/security/advanced-security/secret-protection)
- [Why GitHub](https://github.com/why-github)
- [Documentation](https://docs.github.com/)
- [Blog](https://github.blog/)
- [Changelog](https://github.blog/changelog)
- [Marketplace](https://github.com/marketplace)
- [View all features](https://github.com/features)
- [Enterprises](https://github.com/enterprise)
- [Small and medium teams](https://github.com/team)
- [Startups](https://github.com/enterprise/startups)
- [Nonprofits](https://github.com/solutions/industry/nonprofits)
- [App Modernization](https://github.com/solutions/use-case/app-modernization)
- [DevSecOps](https://github.com/solutions/use-case/devsecops)
- [DevOps](https://github.com/resources/articles?topic=devops)
- [CI/CD](https://github.com/solutions/use-case/ci-cd)
- [View all use cases](https://github.com/solutions/use-case)
- [Healthcare](https://github.com/solutions/industry/healthcare)
- [Financial services](https://github.com/solutions/industry/financial-services)
- [Manufacturing](https://github.com/solutions/industry/manufacturing)
- [Government](https://github.com/solutions/industry/government)
- [View all industries](https://github.com/solutions/industry)
- [View all solutions](https://github.com/solutions)
- [AI](https://github.com/resources/articles?topic=ai)
- [Software Development](https://github.com/resources/articles?topic=software-development)
- [Security](https://github.com/security)
- [View all topics](https://github.com/resources/articles)
- [Customer stories](https://github.com/customer-stories)
- [Events & webinars](https://github.com/resources/events)
- [Ebooks & reports](https://github.com/resources/whitepapers)
- [Business insights](https://github.com/solutions/executive-insights)
- [GitHub Skills](https://skills.github.com/)
- [Customer support](https://support.github.com/)
- [Community forum](https://github.com/orgs/community/discussions)
- [Trust center](https://github.com/trust-center)
- [Partners](https://github.com/partners)
- [View all resources](https://github.com/resources)
- [GitHub SponsorsFund open source developers](https://github.com/open-source/sponsors)
- [Security Lab](https://securitylab.github.com/)
- [Maintainer Community](https://maintainers.github.com/)
- [GitHub Stars](https://stars.github.com/)
- [Archive Program](https://archiveprogram.github.com/)
- [Topics](https://github.com/topics)
- [Trending](https://github.com/trending)
- [Collections](https://github.com/collections)
- [Copilot for BusinessEnterprise-grade AI features](https://github.com/features/copilot/copilot-business)
- [Premium SupportEnterprise-grade 24/7 support](https://github.com/enterprise/premium-support)
- [Pricing](https://github.com/pricing)
- [Sign up](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E&source=header-repo&source_repo=whetstoneresearch%2Fdoppler-demo-app)
- [whetstoneresearch](https://github.com/whetstoneresearch)
- [doppler-demo-app](https://github.com/whetstoneresearch/doppler-demo-app)
- [Notifications](https://github.com/login?return_to=%2Fwhetstoneresearch%2Fdoppler-demo-app)
- [Issues 1](https://github.com/whetstoneresearch/doppler-demo-app/issues)
- [Pull requests 0](https://github.com/whetstoneresearch/doppler-demo-app/pulls)
- [Actions](https://github.com/whetstoneresearch/doppler-demo-app/actions)
- [Projects](https://github.com/whetstoneresearch/doppler-demo-app/projects)
- [Security and quality 0](https://github.com/whetstoneresearch/doppler-demo-app/security)
- [Insights](https://github.com/whetstoneresearch/doppler-demo-app/pulse)
- [5 Branches](https://github.com/whetstoneresearch/doppler-demo-app/branches)
- [0 Tags](https://github.com/whetstoneresearch/doppler-demo-app/tags)
- [Cooper-Kunz](https://github.com/whetstoneresearch/doppler-demo-app/commits?author=Cooper-Kunz)
- [Merge pull request](https://github.com/whetstoneresearch/doppler-demo-app/commit/3ff6b27aac49ecb4663e5886cb716f5dda1632a7)
- [#4](https://github.com/whetstoneresearch/doppler-demo-app/pull/4)
- [96 Commits](https://github.com/whetstoneresearch/doppler-demo-app/commits/main/)
- [public](https://github.com/whetstoneresearch/doppler-demo-app/tree/main/public)
- [v0 doppler-v4-miniapp](https://github.com/whetstoneresearch/doppler-demo-app/commit/69493bc515c1fc6e1c651cab4f4f94d449b1e36e)
- [src](https://github.com/whetstoneresearch/doppler-demo-app/tree/main/src)
- [feat: add Solana launch flow](https://github.com/whetstoneresearch/doppler-demo-app/commit/713d3724a61c9a4d350f6d3cff409b7d7bd9e5e9)
- [.gitignore](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/.gitignore)
- [Add Doppler API support](https://github.com/whetstoneresearch/doppler-demo-app/commit/0e0c1059ce769c564bed8e8a8e5b0ab03d843785)
- [LICENSE](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/LICENSE)
- [add MIT license, update readme](https://github.com/whetstoneresearch/doppler-demo-app/commit/c2ba7b8cd843ce840e29229dc4c5f43c45570fca)
- [README.md](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/README.md)
- [add solana support](https://github.com/whetstoneresearch/doppler-demo-app/commit/dd793dc85933b819d68479ea18c8f34ff813b0e1)
- [components.json](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/components.json)
- [eslint.config.js](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/eslint.config.js)
- [index.html](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/index.html)
- [package.json](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/package.json)
- [pnpm-lock.yaml](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/pnpm-lock.yaml)
- [tailwind.config.js](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/tailwind.config.js)
- [tsconfig.app.json](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/tsconfig.app.json)
- [tsconfig.json](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/tsconfig.json)
- [tsconfig.node.json](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/tsconfig.node.json)
- [vercel.json](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/vercel.json)
- [no comments in json](https://github.com/whetstoneresearch/doppler-demo-app/commit/a3a1abe8390aa1b1be07bde7949ddc85434216d9)
- [vite.config.ts](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/vite.config.ts)
- [README](https://github.com/whetstoneresearch/doppler-demo-app#)
- [https://github.com/whetstoneresearch/doppler](https://github.com/whetstoneresearch/doppler)
- [SDK](https://github.com/whetstoneresearch/doppler-sdk-alpha)
- [Source: src/pages/CreatePool.tsx#L55-L63](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/CreatePool.tsx#L55-L63)
- [Source: src/pages/CreatePool.tsx#L111-L131](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/CreatePool.tsx#L111-L131)
- [Source: src/pages/CreatePool.tsx#L187-L238](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/CreatePool.tsx#L187-L238)
- [Source: src/pages/CreatePool.tsx#L172-L178](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/CreatePool.tsx#L172-L178)
- [Source: src/pages/PoolDetails.tsx#L529-L537](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/PoolDetails.tsx#L529-L537)
- [and #L569-L575](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/PoolDetails.tsx#L569-L575)
- [Source: src/pages/CreatePool.tsx#L5-L5](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/CreatePool.tsx#L5-L5)
- [and #L63-L63](https://github.com/whetstoneresearch/doppler-demo-app/blob/main/src/pages/CreatePool.tsx#L63-L63)
- [Discord](https://discord.gg/JcrH65zXK3)
- [doppler-demo-app.vercel.app](https://doppler-demo-app.vercel.app/)
- [Readme](https://github.com/whetstoneresearch/doppler-demo-app#readme-ov-file)
- [MIT license](https://github.com/whetstoneresearch/doppler-demo-app#MIT-1-ov-file)
- [Activity](https://github.com/whetstoneresearch/doppler-demo-app/activity)
- [Custom properties](https://github.com/whetstoneresearch/doppler-demo-app/custom-properties)
- [4 forks](https://github.com/whetstoneresearch/doppler-demo-app/forks)
- [Report repository](https://github.com/contact/report-content?content_url=https%3A%2F%2Fgithub.com%2Fwhetstoneresearch%2Fdoppler-demo-app&report=whetstoneresearch+%28user%29)
- [Releases](https://github.com/whetstoneresearch/doppler-demo-app/releases)
- [Contributors](https://github.com/whetstoneresearch/doppler-demo-app/graphs/contributors)
- [TypeScript97.6%](https://github.com/whetstoneresearch/doppler-demo-app/search?l=typescript)
- [CSS1.6%](https://github.com/whetstoneresearch/doppler-demo-app/search?l=css)
- [Other0.8%](https://github.com/whetstoneresearch/doppler-demo-app/search?l=Other)
- [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
- [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
- [Status](https://www.githubstatus.com/)
- [Community](https://github.community/)
- [Contact](https://support.github.com/?tags=dotcom-footer)
