Title: REST API Endpoints - Blockscout

URL Source: https://docs.blockscout.com/devs/apis/rest

Markdown Content:
> ## Documentation Index
> 
> 
> Fetch the complete documentation index at:[/llms.txt](https://docs.blockscout.com/llms.txt)
> 
> 
> Use this file to discover all available pages before exploring further.

[Skip to main content](https://docs.blockscout.com/devs/apis/rest#content-area)

[Blockscout home page![Image 1: light logo](https://mintcdn.com/blockscout/cNJj4Zpe0FBD2sXC/logo/Color_BS_logo_hor.svg?fit=max&auto=format&n=cNJj4Zpe0FBD2sXC&q=85&s=7cffdcbb354b1aa090d9f7d3ca4f3452)![Image 2: dark logo](https://mintcdn.com/blockscout/cNJj4Zpe0FBD2sXC/logo/White_BS_logo_hor.svg?fit=max&auto=format&n=cNJj4Zpe0FBD2sXC&q=85&s=79d28502f70131c02702daa820d2345b)](https://www.blockscout.com/)

Search...

Ctrl K Ask Assistant CTRL I

*   [Support](https://discord.gg/blockscout)
*   [blockscout/blockscout](https://github.com/blockscout/blockscout "blockscout/blockscout")
*   [blockscout/blockscout](https://github.com/blockscout/blockscout "blockscout/blockscout")

Search...

Navigation

REST API Endpoints

REST API Endpoints

[Guides](https://docs.blockscout.com/)[API Reference](https://docs.blockscout.com/devs/apis)[About Blockscout](https://docs.blockscout.com/about/features)

*   [Community](https://discord.gg/blockscout)
*   [Blog](https://www.blog.blockscout.com/)
*   [API Docs](https://docs.blockscout.com/devs/apis)

### Blockscout APIs

*   [Overview](https://docs.blockscout.com/devs/apis)
*    PRO API  
*   [Dev Portal](https://docs.blockscout.com/devs/dev-portal)
*   [Migrate from Etherscan to Blockscout PRO API](https://docs.blockscout.com/devs/migrate-from-etherscan)
*    Use Cases  

### PRO API Endpoints

*   MultichainDomains  
*   DomainsExtractor  
*   Metadata  
*   ClusterExplorerService  
*   MultichainAggregatorService  
*   legacy  
*   search  
*   addresses  
*   advanced-filters  
*   arbitrum  
*   beacon_deposits  
*   blocks  
*   celo  
*   csv-export  
*   internal-transactions  
*   main-page  
*   optimism  
*   zksync  
*   account-abstraction  
*   scroll  
*   shibarium  
*   smart-contracts  
*   stats  
*   token-transfers  
*   tokens  
*   transactions  
*   stability  
*   zilliqa  
*   withdrawals  
*   StatsService  

### Additional Service APIs

*   [Swagger Hub](https://docs.blockscout.com/devs/apis/swagger-hub)
*   [Autoscout API](https://docs.blockscout.com/devs/apis/autoscout-api)
*    Test Merits APIs  
*    Verification APIs  

## On this page

*   [Pagination](https://docs.blockscout.com/devs/apis/rest#pagination)

REST API Endpoints

# REST API Endpoints

Copy page Copy page

REST API methods that power the Blockscout UI, exposing transactions, blocks, addresses, tokens, stats, and interpreter data per instance.

Copy page Copy page

REST API methods are now available via the [multichain PRO API.](https://docs.blockscout.com/devs/pro-api)

REST API methods are used to render the UI for new versions of Blockscout. These can be accessed per instance and used to get many types of information. Methods parameters and schemas are available at _[https://instance-name/api-docs](https://instance-name/api-docs)_ (ie [https://eth.blockscout.com/api-docs](https://eth.blockscout.com/api-docs))

Additional information:
*   [Stats queries](https://docs.blockscout.com/devs/apis/rest/stats-api): Access pre-calculated statistics for a chain
*   [Interpreter queries](https://docs.blockscout.com/devs/apis/rest/interpreter-api): Transactions populated with contract names, methods, etc for easy interpretation

![Image 3](https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/851df441-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=5ef902f8c15b7cec19e0e89dd93feb3e)

![Image 4](https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/ac3d021a-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=2a7fe610755af4f9403997df4284f304)

## [​](https://docs.blockscout.com/devs/apis/rest#pagination)

Pagination

Blockscout uses the keyset pagination method to quickly return results. By default an API response returns the first 50 results. To access additional results (in groups of 50), add the `next_page_params` to your query.For example, open [https://eth.blockscout.com/api/v2/transactions](https://eth.blockscout.com/api/v2/transactions) and scroll to the bottom of the response.

![Image 5](https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/d5bea84e-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=f1fe7cd290d34ec60ff6c8a3cfdb1c1d)

Example response from transactions query

You will see the `next_page_params` object. Add the parameters from this object to your next query to receive the next 50 results.[https://eth.blockscout.com/api/v2/transactions?block_number=18678766&index=119&items_count=50](https://eth.blockscout.com/api/v2/transactions?block_number=18678766&index=119&items_count=50)Repeat this process to continue receiving results in groups of 50 (remove params and substitute the new `next_page_params` found in the body of the query).

![Image 6](https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/520935a2-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=9984f6ddfda915edd4698ec9d087a84b)

In this example, the query to receive the next 50 results would be:[https://eth.blockscout.com/api/v2/transactions?block_number=18678766&index=69&items_count=100](https://eth.blockscout.com/api/v2/transactions?block_number=18678766&index=69&items_count=100)

Was this page helpful?

Yes No

[github](https://github.com/blockscout/blockscout)[telegram](https://t.me/blockscoutcommunity)[discord](https://discord.gg/blockscout)[x](https://x.com/blockscout)

[Powered by This documentation is built and hosted on Mintlify, a developer documentation platform](https://www.mintlify.com/?utm_campaign=poweredBy&utm_medium=referral&utm_source=blockscout)

Assistant

Responses are generated using AI and may contain mistakes.

![Image 7](https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/851df441-image.jpeg?w=840&fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=62b78e55164f241b35d64cbe59c6d140)

![Image 8](https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/ac3d021a-image.jpeg?w=840&fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=3cda6b8553bfc9e2298b4cebaefe487a)

![Image 9](https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/d5bea84e-image.jpeg?w=840&fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=ff8769219d95602ff9ed3a276fa398c8)

![Image 10](https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/520935a2-image.jpeg?w=840&fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=f2734a27a4c0bc368d6e2167dbbc03e9)
