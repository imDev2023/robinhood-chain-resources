# Sentry contract addresses, Robinhood Chain (chain id 4663)

Captured 2026-09-02 from `https://robinhoodchain.blockscout.com/api/v2` plus live `eth_call` reads.
Every row has a directory under `contracts/` with `metadata.json`, `abi.json` where verified, `sources/` at their original paths, and a generated `README.md` listing constructor arguments, events and functions.
Unverified contracts carry `bytecode.hex` instead of sources.
Ink addresses (chain id 57073) are listed in `pages/45-guide-chains-contracts.md` and were not fetched, because this archive exists to pick a Robinhood Chain launch venue.

## The live launch path, Robinhood Chain

| address | role | contract name | verified | proxy | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x472286b7d5c1b2a3ce1132ef73d3bccf446c5cc1` | LaunchFactoryWeth | TransparentUpgradeableProxy | yes | eip1967 -> `0x818FdD15Dbe95851a0bd8c5389c49ed6d4FE2bBf` | `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5` | `0xef1dbd691269`... | `contracts/LaunchFactoryWeth-0x472286b7d5c1b2a3ce1132ef73d3bccf446c5cc1/` |
| `0x818fdd15dbe95851a0bd8c5389c49ed6d4fe2bbf` | LaunchFactoryV4Impl | SentryLaunchFactoryV4 | yes | - | `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5` | `0x6ef7e9b4f966`... | `contracts/LaunchFactoryV4Impl-0x818fdd15dbe95851a0bd8c5389c49ed6d4fe2bbf/` |
| `0xd0a93885a387e3a8a14dd82776cf9104a3676b3a` | LaunchFactoryStock | TransparentUpgradeableProxy | yes | eip1967 -> `0x818FdD15Dbe95851a0bd8c5389c49ed6d4FE2bBf` | `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5` | `0x6471c12dd3a2`... | `contracts/LaunchFactoryStock-0xd0a93885a387e3a8a14dd82776cf9104a3676b3a/` |
| `0x35c0098836fa0d10a015a95bf02c16387814f0cc` | FeeHookWeth | SentryStockFeeHookV3 | yes | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x7121aa9c7395`... | `contracts/FeeHookWeth-0x35c0098836fa0d10a015a95bf02c16387814f0cc/` |
| `0x730abadbb4f328520e5350f59126fbe1d67f70cc` | FeeHookWethReflections | SentryStockFeeHookV3 | yes | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x5fa37e909d3e`... | `contracts/FeeHookWethReflections-0x730abadbb4f328520e5350f59126fbe1d67f70cc/` |
| `0x5daa88b65bd47199ec92d3cde01b56348e1270cc` | FeeHookStock | SentryStockFeeHookV3 | yes | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x8ab4813477a0`... | `contracts/FeeHookStock-0x5daa88b65bd47199ec92d3cde01b56348e1270cc/` |
| `0x3b778ccff74c2f21e771e1e951b1343108fc7080` | DynamicFeeHookDefault | SentryDynamicFeeHook | yes | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x83c5bb0da106`... | `contracts/DynamicFeeHookDefault-0x3b778ccff74c2f21e771e1e951b1343108fc7080/` |
| `0x0f0e601041ec765b8bab8c166840e291253f2df0` | LPVault | SentryLPVault | yes | - | `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5` | `0x53fde64d743d`... | `contracts/LPVault-0x0f0e601041ec765b8bab8c166840e291253f2df0/` |
| `0x75450496fe333a93e1327368aa3c4130bf008697` | TreasurySplitter | SentryTreasurySplitter | yes | - | `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5` | `0x0cbdb74b1590`... | `contracts/TreasurySplitter-0x75450496fe333a93e1327368aa3c4130bf008697/` |
| `0x8366a39cc670b4001a1121b8f6a443a643e40951` | PoolManagerV4 | PoolManager | yes | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x4fb28d493586`... | `contracts/PoolManagerV4-0x8366a39cc670b4001a1121b8f6a443a643e40951/` |
| `0x0bd7d308f8e1639fab988df18a8011f41eacad73` | WETH9 | TransparentUpgradeableProxy | yes | eip1967 -> `0xC6B81b429797E0f555440b70cD99e032D7AE947e` | `0xE83b11Faa5693E68388785FecA3595C6805dFb9a` | `0x05317cd173ba`... | `contracts/WETH9-0x0bd7d308f8e1639fab988df18a8011f41eacad73/` |

## The retired Uniswap V3 generation

| address | role | contract name | verified | proxy | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x9e8f6f8214b01fd4cf1d73fb1fb7cf9f811036cb` | LaunchFactoryLegacyV3 | TransparentUpgradeableProxy | yes | eip1967 -> `0x12a9c6498e8Cfd970E78F82410EA23809dd4c98B` | `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5` | `0xf754d755fdc2`... | `contracts/LaunchFactoryLegacyV3-0x9e8f6f8214b01fd4cf1d73fb1fb7cf9f811036cb/` |
| `0x12a9c6498e8cfd970e78f82410ea23809dd4c98b` | LaunchFactoryLegacyImpl | SentryLaunchFactory | yes | - | `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5` | `0x596ccfc8055a`... | `contracts/LaunchFactoryLegacyImpl-0x12a9c6498e8cfd970e78f82410ea23809dd4c98b/` |
| `0x7e6e258851575bd3f69e7a01981066a26329b0cc` | FeeHookStockLegacyV2 | - | no | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x423a5e23e4fb`... | `contracts/FeeHookStockLegacyV2-0x7e6e258851575bd3f69e7a01981066a26329b0cc/` |
| `0x1f7d7550b1b028f7571e69a784071f0205fd2efa` | UniswapV3Factory | UniswapV3Factory | yes | - | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0x8add72fbcad4`... | `contracts/UniswapV3Factory-0x1f7d7550b1b028f7571e69a784071f0205fd2efa/` |
| `0x73991a25c818bf1f1128deaab1492d45638de0d3` | UniswapV3PositionManager | NonfungiblePositionManager | yes | - | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0x9a8d07e70166`... | `contracts/UniswapV3PositionManager-0x73991a25c818bf1f1128deaab1492d45638de0d3/` |
| `0xcaf681a66d020601342297493863e78c959e5cb2` | UniswapV3SwapRouter02 | SwapRouter02 | yes | - | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0xeaa1bf6bd8e8`... | `contracts/UniswapV3SwapRouter02-0xcaf681a66d020601342297493863e78c959e5cb2/` |

## Routers, locker and the platform token

| address | role | contract name | verified | proxy | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x8bfdc6cc38db45bdaf2f254415251b109058a97c` | SwapRouterV2 | SentrySwapRouterV2 | yes | - | `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5` | `0xf76637fe2c86`... | `contracts/SwapRouterV2-0x8bfdc6cc38db45bdaf2f254415251b109058a97c/` |
| `0x5811a5c7c4f73290cc9aa2235245bc9f48523662` | SwapRouterV4 | - | no | - | `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5` | `0xe80309382b08`... | `contracts/SwapRouterV4-0x5811a5c7c4f73290cc9aa2235245bc9f48523662/` |
| `0x641f05602b3dee5b35bac08a1269827f2e84445d` | SwapRouterStockMultihop | - | no | - | `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5` | `0x04a57d520400`... | `contracts/SwapRouterStockMultihop-0x641f05602b3dee5b35bac08a1269827f2e84445d/` |
| `0x4415f2360bfd9b1bf55500cb28fa41df95cb2d2b` | SwapRouterPancakeV3 | SentrySwapRouter | yes | - | `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5` | `0x17f452d24b32`... | `contracts/SwapRouterPancakeV3-0x4415f2360bfd9b1bf55500cb28fa41df95cb2d2b/` |
| `0xbd0e7a242a323e5e4799abe09b7516d9da5ea81d` | TokenLocker | SentryTokenLocker | yes | - | `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5` | `0x582ad5e13d46`... | `contracts/TokenLocker-0xbd0e7a242a323e5e4799abe09b7516d9da5ea81d/` |
| `0x1eca20cfa4af2e2fa2f4ce2bf8d97bfa184fd4d7` | SentryToken | SentryTokenRelaunch | yes | - | `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5` | `0xd03ad7e3162d`... | `contracts/SentryToken-0x1eca20cfa4af2e2fa2f4ce2bf8d97bfa184fd4d7/` |
| `0xa695f84c86367d5aea445e8289dbc7c4c4e530cc` | SentryFeeHook | SentrySentryFeeHook | yes | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x7e44cc1da1a9`... | `contracts/SentryFeeHook-0xa695f84c86367d5aea445e8289dbc7c4c4e530cc/` |
| `0x0ba59e256b7657163a06eb900605688bb1e74b42` | RelaunchLauncher | SentryRelaunchLauncher | yes | - | `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5` | `0x4460fd2b5355`... | `contracts/RelaunchLauncher-0x0ba59e256b7657163a06eb900605688bb1e74b42/` |
| `0xffc93474d99f07e8d0f1c7c8c5b93baa2feddd07` | TreasurySafe | SafeProxy | yes | master_copy -> `0x29fcB43b46531BcA003ddC8FCB67FFE91900C762` | `0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67` | `0x3c5b2b23b8c4`... | `contracts/TreasurySafe-0xffc93474d99f07e8d0f1c7c8c5b93baa2feddd07/` |
| `0x5fc5360d0400a0fd4f2af552add042d716f1d168` | USDG | ERC1967Proxy | yes | eip1967 -> `0x68184C449E1a8f34fA18d289737129FD27B66f8F` | `0xBe498aad9c6fd0E4Cd6d1E3fBb395026c5D28215` | `0xc51b4ac115d1`... | `contracts/USDG-0x5fc5360d0400a0fd4f2af552add042d716f1d168/` |
| `0x8f95ed212f37cdc19f5c0716c24966d9019939ee` | ZNSConnectHood | ZNS Connect | no | - | `0x0E150Daa9184573E05f0691B55dDD3e993b0651B` | `0x67be3904b3e1`... | `contracts/ZNSConnectHood-0x8f95ed212f37cdc19f5c0716c24966d9019939ee/` |

## Example launches and stock base tokens

| address | role | contract name | verified | proxy | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x9b4434278976ccf6150a0ff113acc96d594cabac` | ExampleLaunchWeth | SentryTokenStandard | yes | - | `0x472286b7d5c1B2A3cE1132eF73d3BcCF446C5cc1` | `0xee98627a9986`... | `contracts/ExampleLaunchWeth-0x9b4434278976ccf6150a0ff113acc96d594cabac/` |
| `0xef3a80c82c1a5f12c3e16e79eae47c364e4fe669` | ExampleLaunchWethReflections | Baby Sentry | no | - | `-` | - | `contracts/ExampleLaunchWethReflections-0xef3a80c82c1a5f12c3e16e79eae47c364e4fe669/` |
| `0xf668b7002810313fd676862a8ec57f0975038692` | ExampleLaunchStock | SentryTokenizedStocks | no | - | `-` | - | `contracts/ExampleLaunchStock-0xf668b7002810313fd676862a8ec57f0975038692/` |
| `0xf699aea8a333202a7dc610abc664c213c9dc4111` | ExampleLaunchStockChill | SentryTokenizedStocks | yes | - | `0xd0A93885a387e3a8a14dd82776CF9104a3676b3A` | `0x863c18ba9081`... | `contracts/ExampleLaunchStockChill-0xf699aea8a333202a7dc610abc664c213c9dc4111/` |
| `0x411efb0e7f985935daec3d4c3ebaea0d0ad7d89f` | StockBaseSLV | BeaconProxy | yes | eip1967_beacon -> `0xb35490d6f9163DE4F80d88dc75c3516eb64C5aE2` | `0x4783C67b63dE2B358Ac5951a7D41F47A38F3C046` | `0x0dd6b844b00d`... | `contracts/StockBaseSLV-0x411efb0e7f985935daec3d4c3ebaea0d0ad7d89f/` |
| `0xe0444ef8bf4ed74f74fd73686e2ddf4c1c5591e8` | StockBaseNFLX | BeaconProxy | yes | eip1967_beacon -> `0xb35490d6f9163DE4F80d88dc75c3516eb64C5aE2` | `0x4783C67b63dE2B358Ac5951a7D41F47A38F3C046` | `0xebd6f2dceee4`... | `contracts/StockBaseNFLX-0xe0444ef8bf4ed74f74fd73686e2ddf4c1c5591e8/` |

## Quotrons, the sibling Mavrk product

| address | role | contract name | verified | proxy | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x40686524e56aff0f1446958725dcf6e6da5381e6` | Quotron404 | Quotron404 | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0x451deafae85c`... | `contracts/Quotron404-0x40686524e56aff0f1446958725dcf6e6da5381e6/` |
| `0xd1258efafa9d1b1d09c86403139db78465540760` | QuotronBurnVault | QuotronBurnVault | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0x8d15bf2e1478`... | `contracts/QuotronBurnVault-0xd1258efafa9d1b1d09c86403139db78465540760/` |
| `0x24e62dd5c7058cc41ad9c5375c137460ea1da2fe` | QuotronEpochConverter | QuotronEpochConverter | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0xf347e22c9b5a`... | `contracts/QuotronEpochConverter-0x24e62dd5c7058cc41ad9c5375c137460ea1da2fe/` |
| `0x077403e402b63da54a594cbd2cfc46dbc92927ad` | QuotronLegacyTokenSink | QuotronLegacyTokenSink | yes | - | `0x205E13e6Ec07baa4eD1c57d677DE9FeE1C88Cd6D` | `0x9473553cbb1e`... | `contracts/QuotronLegacyTokenSink-0x077403e402b63da54a594cbd2cfc46dbc92927ad/` |
| `0x205e13e6ec07baa4ed1c57d677de9fee1c88cd6d` | QuotronMigrator | QuotronMigrator | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0x9473553cbb1e`... | `contracts/QuotronMigrator-0x205e13e6ec07baa4ed1c57d677de9fee1c88cd6d/` |
| `0x027aca2794e44f24950d81227dcd516ffbb49d6e` | QuotronMirrorV2 | QuotronMirrorV2 | yes | - | `0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F` | `0x222e4f9f70c2`... | `contracts/QuotronMirrorV2-0x027aca2794e44f24950d81227dcd516ffbb49d6e/` |
| `0x666a51eb731a9cf79d97b4a9c64cd5a4806c877c` | QuotronReflections | QuotronReflections | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0xf10740e0fef1`... | `contracts/QuotronReflections-0x666a51eb731a9cf79d97b4a9c64cd5a4806c877c/` |
| `0xe04fba61fd54ba78dd450a30d8af40167af5d3ec` | QuotronReflectionsV2 | QuotronReflectionsV2 | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0x801cd3e38534`... | `contracts/QuotronReflectionsV2-0xe04fba61fd54ba78dd450a30d8af40167af5d3ec/` |
| `0xd8eb805e96b05cb412a1e48eb3a85b6267f901d7` | QuotronRoyaltySplitter | QuotronRoyaltySplitter | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0xf0565ecf04f4`... | `contracts/QuotronRoyaltySplitter-0xd8eb805e96b05cb412a1e48eb3a85b6267f901d7/` |
| `0xcc949c33860e0f695be3373628955d77dd922fee` | QuotronSeeder | QuotronSeeder | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0x8595d214ca99`... | `contracts/QuotronSeeder-0xcc949c33860e0f695be3373628955d77dd922fee/` |
| `0xc388e730807c6f69b959443ed497c731b8d138f9` | QuotronStonksIncinerator | QuotronStonksIncinerator | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0x540e264c26ef`... | `contracts/QuotronStonksIncinerator-0xc388e730807c6f69b959443ed497c731b8d138f9/` |
| `0xcf39cb2363f85d3adad4ff891bb357c1766ef292` | QuotronV2MigrationReserve | QuotronV2MigrationReserve | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0x6c06d08b1b48`... | `contracts/QuotronV2MigrationReserve-0xcf39cb2363f85d3adad4ff891bb357c1766ef292/` |
| `0x59b09a326984dd3c1076b864aa27f0bdd9876f0a` | QuotronV3ExactInputAdapter | QuotronV3ExactInputAdapter | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0xddebd2a788c5`... | `contracts/QuotronV3ExactInputAdapter-0x59b09a326984dd3c1076b864aa27f0bdd9876f0a/` |
| `0x62e200cc8e4d95cf622f40dd70f407c883ecb0cc` | QuotronWethHook | QuotronWethHook | yes | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x048c383f1cc3`... | `contracts/QuotronWethHook-0x62e200cc8e4d95cf622f40dd70f407c883ecb0cc/` |
| `0x4b7a4f53d9b7e4b4941bc9cf74e852d55444ccbe` | QuotronWethLpVault | QuotronWethLpVault | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0x67b7373a8711`... | `contracts/QuotronWethLpVault-0x4b7a4f53d9b7e4b4941bc9cf74e852d55444ccbe/` |
| `0xb8960fdc8a0be155d196c2795b75747763562df2` | QuotronWethQuoter | QuotronWethQuoter | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0x48a5d2235263`... | `contracts/QuotronWethQuoter-0xb8960fdc8a0be155d196c2795b75747763562df2/` |
| `0x42024fcfdb4f3089dd619a0cef0cd24e7b841c18` | QuotronWethRouter | QuotronWethRouter | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0x484a7ee76bed`... | `contracts/QuotronWethRouter-0x42024fcfdb4f3089dd619a0cef0cd24e7b841c18/` |
| `0x94cfc3798ca6320ac5e6af04484efe90bd04ac81` | QuotronWhitelist | QuotronWhitelist | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0x1fe077a2a637`... | `contracts/QuotronWhitelist-0x94cfc3798ca6320ac5e6af04484efe90bd04ac81/` |
| `0xbde7bec47cbfc689e5e952b6cdd113a500abcd83` | QuotronsNFT | QuotronMirror | yes | - | `0x40686524e56AfF0F1446958725dCF6e6dA5381E6` | `0x451deafae85c`... | `contracts/QuotronsNFT-0xbde7bec47cbfc689e5e952b6cdd113a500abcd83/` |
| `0x5a86828efd322bfb16d93cfed16ee9bc14940d7f` | QuotronsToken | Quotron404V2 | yes | - | `0x7171E64E979265aeD6588577D1c6b60A701d7866` | `0x222e4f9f70c2`... | `contracts/QuotronsToken-0x5a86828efd322bfb16d93cfed16ee9bc14940d7f/` |

## Live state read from these contracts on 2026-09-02

Full dumps: `_raw/rpc/derived-state-2026-09-02.txt`, `_raw/rpc/derived-poolkeys-2026-09-02.txt`, `_raw/rpc/derived-sentry-token-2026-09-02.txt`.

| contract | call | value |
| --- | --- | --- |
| LaunchFactoryWeth | `owner()` | `0xbf551eed83c7eaee63854a2013eb94f18600b7c5` |
| LaunchFactoryWeth | `treasury()` | `0x75450496fe333a93e1327368aa3c4130bf008697`, the splitter |
| LaunchFactoryWeth | `vault()` | `0x0f0e601041ec765b8bab8c166840e291253f2df0` |
| LaunchFactoryWeth | `hook()` | `0x35c0098836fa0d10a015a95bf02c16387814f0cc` |
| LaunchFactoryWeth | `reflectionHook()` | `0x730abadbb4f328520e5350f59126fbe1d67f70cc` |
| LaunchFactoryWeth | `creatorFeeBps()` | 7000 |
| LaunchFactoryWeth | `totalTokensDeployed()` | 76 |
| LaunchFactoryWeth | `TICK_SPACING()` | 200 |
| LaunchFactoryWeth | `getSupportedBaseTokens()` | one entry, WETH |
| LaunchFactoryStock | `hook()` | `0x3b778ccff74c2f21e771e1e951b1343108fc7080`, SentryDynamicFeeHook |
| LaunchFactoryStock | `baseTokenToHook(SLV/NFLX/AAPL)` | `0x5daa88b65bd47199ec92d3cde01b56348e1270cc` for all three |
| LaunchFactoryStock | `totalTokensDeployed()` | 16 |
| LaunchFactoryStock | `getSupportedBaseTokens()` | 88 tokenised stocks |
| LaunchFactoryLegacyV3 | `CREATOR_FEE_BPS()` | 7000 |
| LaunchFactoryLegacyV3 | `FEE_TIER()` | 10000, the Uniswap V3 1% tier |
| LaunchFactoryLegacyV3 | `totalTokensDeployed()` | 93 |
| LaunchFactoryLegacyV3 | `treasury()` | `0xcaafcf8e55f3b5e3d5f7957987db232f08d2367c`, the treasury wallet directly |
| FeeHookWeth | `startFee()` / `endFee()` | 400000 / 17000 pips, so 40% decaying to 1.7% |
| FeeHookWeth | `holdDuration()` / `halfLife()` | 180 / 180 seconds |
| FeeHookWeth | `earlyCreatorBps()` / `earlyTreasuryBps()` | 5882 / 0 |
| FeeHookWeth | `lateCreatorBps()` / `lateLpBps()` / `lateReflectionBps()` | 5882 / 1176 / 0 |
| FeeHookWethReflections | `reflectionStartDelay()` | 600 seconds |
| FeeHookWethReflections | early bps | creator 5000, treasury 2500, remainder to LP |
| FeeHookWethReflections | late bps | creator 2941, LP 1176, reflections 4706, remainder 1177 to treasury |
| FeeHookStock | all of the above | identical to FeeHookWethReflections, `factory()` points at the stock factory |
| SentryFeeHook | `startFee()` / `endFee()` | 400000 / 20000 pips, so 40% decaying to 2% |
| SentryFeeHook | `earlyExitFee()` | 800000 pips, 80%, on migration-locked sellers only |
| SentryFeeHook | `lpShareBps()` / `reflectionShareBps()` / `treasuryShareBps()` | 3750 / 3750 / 2500 |
| TreasurySplitter | `forwardBps()` | 6000 to `treasuryWallet()`, remainder compounded into SENTRY liquidity |
| TreasurySplitter | `keeper()` | the zero address |
| LPVault | `creatorFeeBps()` | 7000 |
| LPVault | `v4FactoryWeth()` / `v4FactoryStock()` / `v3Factory()` | the three factories above |
| TokenLocker | `lockCount()` | 509 |
| SentryToken | `totalSupply()` | 1,000,000,000 with 18 decimals |
| SentryToken | `TREASURY_CUT()` / `FOUNDER_CUT()` | 100,000,000 and 30,000,000, so 10% and 3% |
| SentryToken | `founder()` | `0x7171e64e979265aed6588577d1c6b60a701d7866`, the Quotrons deployer |
| SentryToken | `unlockTime()` | 1790985600, 2026-10-03, extended from 2026-08-03 by holder vote |
| SentryToken | `yesVotes()` / `noVotes()` | 291,961,250 vs 70,397,328 SENTRY, `extensionPassing() = true` |

## Pool keys of three example launches

Every live pool is a Uniswap v4 dynamic-fee pool: the `fee` field is `0x800000` (8388608) and `tickSpacing` is 200.

| token | base | hook | pool id |
| --- | --- | --- | --- |
| Hood Of Meme, plain WETH launch | WETH | `0x35c0098836fa0d10a015a95bf02c16387814f0cc` | `0x6b0fe4e9fe262f88759bb184f967bcbfd248e35332505d5c8de2ae426f93c66c` |
| Baby Sentry, WETH with reflections | WETH | `0x730abadbb4f328520e5350f59126fbe1d67f70cc` | `0xc18e89099bb91e1823f2914e3d34242dc51a50bbb61134609fc6adda4218b591` |
| Silver Inu, stock pair | SLV | `0x5daa88b65bd47199ec92d3cde01b56348e1270cc` | `0x057efd834864a0e92dbe44800c086e995908f3404c80ae6fcbe2941e4661ca4a` |

