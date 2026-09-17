Title: Whetstone / doppler-contracts competition | Cantina

URL Source: https://cantina.xyz/competitions/57b00aab-8f8b-4d62-9378-41b6460ce6aa

Markdown Content:
Doppler is a customizable liquidity-bootstrapping Protocol designed for the Uniswap Ecosystem. The entire Protocol is designed for use onchain and eliminates value leakage of value.

### Prize distribution and scoring

*   **Total Prize Pool:** $65,000

*   Scoring described in the [competition scoring page](https://docs.cantina.xyz/cantina-docs/cantina-competitions/judging-process/scoring).

*   Findings Severities described in detail on [our docs page](https://docs.cantina.xyz/cantina-docs/cantina-competitions/judging-process/finding-severity-criteria).

## Documentation

*   [Technical Documentation](https://github.com/whetstoneresearch/docs/blob/main/whitepapers/doppler/Dutch_auction_Dynamic_Bonding_Curves.pdf)

*   Doppler v4/v3 refer to the corresponding uniswap version, where v4 is the uniswap v4 hook implementation and v3 is a simplified version of the protocol built on uniswap v3

*   V4 readme: [https://github.com/whetstoneresearch/doppler/blob/main/README.md](https://github.com/whetstoneresearch/doppler/blob/main/README.md)

*   For v3 refer to natspec/video (video tbd)

## Scope

*   **Repository:**[https://github.com/whetstoneresearch/doppler](https://github.com/whetstoneresearch/doppler)
*   **Commit:**`338d39d6890a6bb98fba92d117c8e69465f9caa5`
*   **Total LOC:** approx. 2300 (incl whitespace/imports/comments)
*   **Files:**
    *   Airlock.sol 
        *   TokenFactory.sol
        *   DERC20.sol
        *   UniswapV2Migrator.sol
        *   Doppler.sol
        *   UniswapV3Initializer.sol
        *   Governance.sol
        *   UniswapV4Initializer.sol
        *   GovernanceFactory.sol
        *   interfaces

### Build Instructions

*   Project uses foundry, must compile with via-ir
*   Default profile settings include the foundry configuration required to build the contracts
*   Additional utility in `TestScenarios.sh` bash script for varying doppler v4 pool configuration
*   For v3 integration tests it is recommended to include `MAINNET_RPC_URL` in .env, can use public rpc such as [https://eth.llamarpc.com](https://eth.llamarpc.com/)
*   Optional v4 initializer integration test uses unichain sepolia deployments, can use public rpc [https://sepolia.unichain.org](https://sepolia.unichain.org/) exported as `UNICHAIN_SEPOLIA_RPC_URL`

### Basic POC test

*   Mandatory POC rule applies for this competition
*   [V3PocTest.sol](https://github.com/whetstoneresearch/doppler/blob/main/test/shared/V3PocTest.sol)
*   [V4PocTest.sol](https://github.com/whetstoneresearch/doppler/blob/main/test/shared/V4PocTest.sol)

### Out of scope

*   [Previous security reports](https://drive.google.com/drive/folders/1ybG515FNEhiXw_BruP0unO-OoGdMzvz6?dmr=1&ec=wgc-drive-globalnav-goto)
*   Expected behaviors such as trusted/untrusted roles and/or any accepted risks: 
    *   Doppler Owner can set trusted modules and take out fees. Additionally, we accept that there is an edge-case where all assets are sold back, and funds could be locked. We believe this is unsolvable and economically impossible.
    *   UniswapV3Initializer - price can be manipulated prior to initialization [https://hackmd.io/@eQvUMjVEQhKY3brAjTH98A/BJyoA2WPye](https://hackmd.io/@eQvUMjVEQhKY3brAjTH98A/BJyoA2WPye)
    *   The `create` function in the Airlock contract expects a salt that will be passed to the different modules to deploy several contracts using `CREATE2`. However, a malicious actor could "steal" the salt and frontrun the token deployment, allowing them to manipulate the parameters they want stealthy, without changing the final token address. A potential exploit here would be to include themselves as a recipient of some extra vested tokens, for example.
    *   simply lockPool() is not invoked by the airlock contract
    *   Few more Known Issues to be added

*   Automated findings by [Lightchaser](https://www.lightchaser.online/)[https://gist.github.com/ChaseTheLight01/5049f6aebe28ae798bf442f29ece8768](https://gist.github.com/ChaseTheLight01/5049f6aebe28ae798bf442f29ece8768)

For any issues or concerns regarding this competition, please reach out to the Cantina core team through the Cantina Discord.

Links/Buttons:
- [](https://www.youtube.com/@cantina-xyz)
- [Opportunities](https://cantina.xyz/opportunities)
- [Leaderboard](https://cantina.xyz/competitions/57b00aab-8f8b-4d62-9378-41b6460ce6aa/leaderboard)
- [Discover Cantina](https://cantina.xyz/welcome)
- [Log in](https://cantina.xyz/login)
- [Sign up](https://cantina.xyz/signup)
- [Instructions](https://cantina.xyz/competitions/57b00aab-8f8b-4d62-9378-41b6460ce6aa)
- [competition scoring page](https://docs.cantina.xyz/cantina-docs/cantina-competitions/judging-process/scoring)
- [our docs page](https://docs.cantina.xyz/cantina-docs/cantina-competitions/judging-process/finding-severity-criteria)
- [Technical Documentation](https://github.com/whetstoneresearch/docs/blob/main/whitepapers/doppler/Dutch_auction_Dynamic_Bonding_Curves.pdf)
- [https://github.com/whetstoneresearch/doppler/blob/main/README.md](https://github.com/whetstoneresearch/doppler/blob/main/README.md)
- [https://github.com/whetstoneresearch/doppler](https://github.com/whetstoneresearch/doppler)
- [https://eth.llamarpc.com](https://eth.llamarpc.com/)
- [https://sepolia.unichain.org](https://sepolia.unichain.org/)
- [V3PocTest.sol](https://github.com/whetstoneresearch/doppler/blob/main/test/shared/V3PocTest.sol)
- [V4PocTest.sol](https://github.com/whetstoneresearch/doppler/blob/main/test/shared/V4PocTest.sol)
- [Previous security reports](https://drive.google.com/drive/folders/1ybG515FNEhiXw_BruP0unO-OoGdMzvz6?dmr=1&ec=wgc-drive-globalnav-goto)
- [https://hackmd.io/@eQvUMjVEQhKY3brAjTH98A/BJyoA2WPye](https://hackmd.io/@eQvUMjVEQhKY3brAjTH98A/BJyoA2WPye)
- [Lightchaser](https://www.lightchaser.online/)
- [https://gist.github.com/ChaseTheLight01/5049f6aebe28ae798bf442f29ece8768](https://gist.github.com/ChaseTheLight01/5049f6aebe28ae798bf442f29ece8768)
- [Terms of Use](https://cantina.xyz/terms/general)
- [Privacy Policy](https://cantina.xyz/privacy-policy)
- [Contact Form](https://cantina.xyz/contact)
- [Support](https://docs.cantina.xyz/)
- [Security Contact](https://cantina.xyz/security)
- [Status](https://status.cantina.xyz/)
