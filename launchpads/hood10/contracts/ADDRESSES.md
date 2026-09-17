# HOOD10 - contract addresses

Chain: Robinhood Chain, id 4663.
Explorer: <https://robinhoodchain.blockscout.com/>.
Captured 2026-09-02.

Every row links to a directory in this folder.
`verified` is Blockscout's `is_verified` for that exact address.

## The HOOD10 Launchpad (launch.hood10.xyz)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x718633252AA8329495Df8BBa8fF7c9e8378CFC63` | launch entry point | LaunchFactory | yes | none | `0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862` | `0x6f4fdf8495...` | [LaunchFactory-0x718633252AA8329495Df8BBa8fF7c9e8378CFC63](LaunchFactory-0x718633252AA8329495Df8BBa8fF7c9e8378CFC63/) |
| `0xe6234a98fF84220CcDA12985548ddAb36327Aacc` | v4 hook, fee engine, liquidity lock | LaunchHook | yes | none | `0x4e59b44847b379578588920cA78FbF26c0B4956C` (CREATE2 deployer) | `0x8ff15fcd04...` | [LaunchHook-0xe6234a98fF84220CcDA12985548ddAb36327Aacc](LaunchHook-0xe6234a98fF84220CcDA12985548ddAb36327Aacc/) |
| `0xEb0C797DaDd23A7AD0d00187A976143C8AF8972A` | linked library, price and tick geometry | LaunchGeometry | no (linked library) | none | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0xc0b90d4285...` | [LaunchGeometry-library-0xEb0C797DaDd23A7AD0d00187A976143C8AF8972A](LaunchGeometry-library-0xEb0C797DaDd23A7AD0d00187A976143C8AF8972A/) |
| `0x5D8b610E39156d2cFeF3c1ceCC3c22f4990A1298` | quote tiering and lot sizing | QuoteRegistry | yes | none | `0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862` | `0x061ce64a94...` | [QuoteRegistry-0x5D8b610E39156d2cFeF3c1ceCC3c22f4990A1298](QuoteRegistry-0x5D8b610E39156d2cFeF3c1ceCC3c22f4990A1298/) |
| `0xe1c046571e69Ae2408C21605f2ff657A23977C4c` | fee router, 70/30 split (**no longer wired in**) | FeeRouter | yes | none | `0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862` | `0x2b047f1407...` | [FeeRouter-0xe1c046571e69Ae2408C21605f2ff657A23977C4c](FeeRouter-0xe1c046571e69Ae2408C21605f2ff657A23977C4c/) |
| `0x3087cFD761D679Ded5d0a2baf4d3577aE447d5E3` | reflection-launch pair deployer | DividendDeployer | yes | none | `0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862` | `0xafda2c80ee...` | [DividendDeployer-0x3087cFD761D679Ded5d0a2baf4d3577aE447d5E3](DividendDeployer-0x3087cFD761D679Ded5d0a2baf4d3577aE447d5E3/) |
| `0x0E57Ef4Cb77362b3d69EB348735b38534104d237` | reflection treasury, sample (GOONER) | LaunchDividendTreasury | no (deployed with `new`) | none | `0x3087cFD761D679Ded5d0a2baf4d3577aE447d5E3` | `0xec241d073f...` | [LaunchDividendTreasury-sample-GOONER-unverified-0x0E57Ef4Cb77362b3d69EB348735b38534104d237](LaunchDividendTreasury-sample-GOONER-unverified-0x0E57Ef4Cb77362b3d69EB348735b38534104d237/) |
| `0x669D54EC9D475AdD053B50CdaC31fa13558553DB` | reflection splitter, sample (GOONER) | CreatorFeeSplitter | no (deployed with `new`) | none | `0x3087cFD761D679Ded5d0a2baf4d3577aE447d5E3` | `0xec241d073f...` | [CreatorFeeSplitter-sample-GOONER-unverified-0x669D54EC9D475AdD053B50CdaC31fa13558553DB](CreatorFeeSplitter-sample-GOONER-unverified-0x669D54EC9D475AdD053B50CdaC31fa13558553DB/) |
| `0x4E17C658b0ccFB5ba0168cf6FF43DA5Ced9afc07` | launched token, sample (FLYWHEEL) | LaunchToken | yes | none | `0x718633252AA8329495Df8BBa8fF7c9e8378CFC63` | `0x10bd2fba92...` | [LaunchToken-sample-FLYWHEEL-0x4E17C658b0ccFB5ba0168cf6FF43DA5Ced9afc07](LaunchToken-sample-FLYWHEEL-0x4E17C658b0ccFB5ba0168cf6FF43DA5Ced9afc07/) |
| `0x8366a39CC670B4001A1121B8F6A443A643e40951` | Uniswap v4 core, shared with the whole chain | PoolManager | yes | none | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x4fb28d4935...` | [UniswapV4PoolManager-0x8366a39CC670B4001A1121B8F6A443A643e40951](UniswapV4PoolManager-0x8366a39CC670B4001A1121B8F6A443A643e40951/) |

## The HOOD10 index token (hood10.xyz)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x0D257cA40d40090BE60C2d2Ed5bB3535392838cc` | the HOOD10 index token, 5% tax | Robinhood10 Index | no (clone stub) | eip1167 to `0xd6Da7f07eE822C8538C901217b37D1e7d86c76E5` | `0x5bd1Fbe78a78fe8236fa00CF48fbEBA74ae34661` (CashCat factory) | `0xb508e76ec5...` | [HOOD10Token-proxy-0x0D257cA40d40090BE60C2d2Ed5bB3535392838cc](HOOD10Token-proxy-0x0D257cA40d40090BE60C2d2Ed5bB3535392838cc/) |
| `0x9f3edbfAE8014d55E328b6Dd966C6C95E75f6210` | epoch settlement and dividend payout | unnamed, `SimpleRewardTreasury` family | no | none | `0xb3e36d3a6Bbc264cc5DD54F75B4B6ac495F6679d` | `0x01383b0b81...` | [HOOD10Distributor-unverified-0x9f3edbfAE8014d55E328b6Dd966C6C95E75f6210](HOOD10Distributor-unverified-0x9f3edbfAE8014d55E328b6Dd966C6C95E75f6210/) |

## letscash.fun / CASHCAT, the venue the index token itself launched on

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x5bd1Fbe78a78fe8236fa00CF48fbEBA74ae34661` | CashCat launch factory | ERC1967Proxy | yes | eip1967 to `0x40250b4C73FC30f8F6ad077744B0124B3f111C28` | `0x0679f72DCC42d8fBEB19FC2e0215Be8e7C090881` | `0x2b90e5b780...` | [CashCatFactory-proxy-0x5bd1Fbe78a78fe8236fa00CF48fbEBA74ae34661](CashCatFactory-proxy-0x5bd1Fbe78a78fe8236fa00CF48fbEBA74ae34661/) |
| `0x40250b4C73FC30f8F6ad077744B0124B3f111C28` | current CashCat factory logic | unnamed, UUPS launch factory | no | none | `0x0679f72DCC42d8fBEB19FC2e0215Be8e7C090881` | `0x12ded6362a...` | [CashCatFactory-current-impl-unverified-0x40250b4C73FC30f8F6ad077744B0124B3f111C28](CashCatFactory-current-impl-unverified-0x40250b4C73FC30f8F6ad077744B0124B3f111C28/) |
| `0x3dFd73A63E15920aDd4B6c5C6a4b1b4B768b2c1A` | earlier CashCat factory logic, readable source | CashCatFactoryVNext | yes | none | `0x0679f72DCC42d8fBEB19FC2e0215Be8e7C090881` | `0xf087110620...` | [CashCatFactoryVNext-impl-0x3dFd73A63E15920aDd4B6c5C6a4b1b4B768b2c1A](CashCatFactoryVNext-impl-0x3dFd73A63E15920aDd4B6c5C6a4b1b4B768b2c1A/) |
| `0x75A54357D9C78a2Db19004a5FDc76c50F9242AEC` | CashCat v4 hook, charges HOOD10's 5% | CashCatHookV2 | yes | none | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x8e562b482d...` | [CashCatHookV2-0x75A54357D9C78a2Db19004a5FDc76c50F9242AEC](CashCatHookV2-0x75A54357D9C78a2Db19004a5FDc76c50F9242AEC/) |
| `0xd6Da7f07eE822C8538C901217b37D1e7d86c76E5` | CashCat token master, HOOD10's implementation | CashCatTokenV2 | yes | none | `0x0679f72DCC42d8fBEB19FC2e0215Be8e7C090881` | `0x77b0c5d77b...` | [CashCatTokenV2-impl-0xd6Da7f07eE822C8538C901217b37D1e7d86c76E5](CashCatTokenV2-impl-0xd6Da7f07eE822C8538C901217b37D1e7d86c76E5/) |
| `0x6D3d822F6e625c59804F47cf2Cc1d53B8301016F` | CashCat revenue splitter and buyback burner | CashCatRevenueSplitter | yes | none | `0x0679f72DCC42d8fBEB19FC2e0215Be8e7C090881` | `0x366e7972de...` | [CashCatRevenueSplitter-0x6D3d822F6e625c59804F47cf2Cc1d53B8301016F](CashCatRevenueSplitter-0x6D3d822F6e625c59804F47cf2Cc1d53B8301016F/) |

## Addresses with no code, and why they matter

These are not contracts, so they have no directory.
They are in the money path and cannot be left out of an honest map.

| address | role | evidence |
| --- | --- | --- |
| `0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862` | owner of LaunchFactory, LaunchHook, QuoteRegistry, FeeRouter and DividendDeployer; `protocolTreasury` on the FeeRouter; the `deployer` and `owner` in `/api/health` | `_raw/rpc/live-state.txt`, `_raw/api-launch-health.json` |
| `0xbd40E13889Cd75D8019CfbaA4f3C5562ba242279` | **the hook's current `feeRouter`**, and an EOA. It calls `collectPlatform` and `settleMany` directly and forwards everything to the address below | `_raw/rpc/router-updates.txt`, `_raw/rpc/hook-fee-events.txt`, `_raw/blockscout/eoa-bd40-transactions.json` |
| `0x7e8ADA37D066a124Cd0A044c1209c48338c962fe` | receives every collected platform fee, and is `DividendDeployer.feeRecipient`. Trades the proceeds through a router at `0x8876789976dEcBfCbBbe364623C63652db8C0904` | `_raw/blockscout/eoa-7e8a-transactions.json`, `_raw/blockscout/eoa-7e8a-token-transfers.json` |
| `0xEE5cC579a0A6D90bFF4c481387b39BA655caC728` | the index keeper: `owner` and `protocolFeeRecipient` of the distributor, and the sender of every `claim` | `_raw/rpc/distributor-state.txt`, `_raw/blockscout/distributor-transactions.json` |
| `0xb3e36d3a6Bbc264cc5DD54F75B4B6ac495F6679d` | deployed the index distributor | `_raw/blockscout/tx-distributor-creation.json` |
| `0x639D6Faa4DAf85d4ccc4291D1134C83867df5d82` | the HOOD10 pool's fee recipient on CashCatHookV2, an EOA between the 5% tax and the distributor | `_raw/rpc/hood10-token-state.txt` |
| `0xd2DEfBd13aFF22d6989e8C14b4517eC308079e91` | owner of the CashCat factory and hook | `_raw/rpc/cashcat-state.txt` |
| `0x67cCBFb238047d62736265B3093a5989836794b0` | CashCat treasury | `_raw/rpc/cashcat-state.txt` |
| `0x4e59b44847b379578588920cA78FbF26c0B4956C` | the standard deterministic CREATE2 deployer, not a party to anything | Blockscout creator field on several rows above |

## Quote assets the launch form offers

The 21 assets `/api/vault` returns are listed in the README's economics section.
They are a UI convenience list, not an on-chain allowlist: `LaunchFactory._assertQuoteLaunchable` accepts any contract with a working `decimals()` that the QuoteRegistry does not classify `UNSUPPORTED`.
