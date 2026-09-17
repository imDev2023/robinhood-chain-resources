# Long contract addresses on Robinhood Chain

24 addresses with a directory, plus the accounts below.
Chain: Robinhood Chain, id 4663.
Captured 2026-09-02 from the Blockscout v2 API, from `eth_call` against the Alchemy archive RPC (`_raw/rpc/`), from the app bundle's chain config (`_raw/js/1d2db5e62a5a89a1.js`) and from 50 decoded `LongLauncher.create` calls (`_raw/api/decoded-launcher-recent-50.json`).
Every directory holds `metadata.json`, `abi.json`, `sources/` and a generated `README.md`; the AI token is an EIP-1167 clone and therefore has only `metadata.json`, `abi.json` and a README.

Four things to carry into any integration.

1. The app never calls the Airlock directly: it calls `LongLauncher.create(CreateParams)`, which forwards to `Airlock.create` unchanged after enforcing a 24 hour ticker reservation.
The launcher is not an Airlock module (`getModuleState` returns 0) and does not need to be, because it is a caller, not a plug-in.
2. Every Long launch is a Doppler multicurve pool with the Rehype hook attached through `InitData.dopplerHook`, using the non-canonical Rehype deployment `0x6f02324d...`, which `DopplerHookInitializer.isDopplerHookEnabled` reports as enabled (flags 3).
The Doppler archive's statement that Rehype is not whitelisted is true of the Airlock module registry only.
3. Two independent fee streams exist per pool: the Uniswap v4 dynamic LP fee, whose beneficiary shares (95% creator, 5% Doppler owner) live on `DopplerHookInitializer`, and the Rehype hook fee, whose proceeds are routed at swap time to `buybackDst`, which is Long's own address `0x92d435c9...` on standard launches.
4. Read live beneficiary state with `getShares(poolId, address)`, not `getBeneficiaries(asset)`.
`getBeneficiaries` returns the list stored at creation and does not change when a creator moves their slot with `updateBeneficiary`; `getShares` does (`_raw/rpc/getshares-check.txt`).

## Long's own contracts

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x22e99278308b393ea1260859b181ad7e78f5eeed` | The launcher the app calls (`tickerFactory`). Forwards `Airlock.create` unchanged, reserves the normalized ticker 24 h, takes no fee. 13,369 transactions | `LongLauncher` | yes | - | `0x1Ae51740cE21CAEbB8C92C457Ad7fc1bdAAe5305` | `0x717af93c...` | `contracts/LongLauncher-0x22e99278308b393ea1260859b181ad7e78f5eeed/` |
| `0x9c88f06b72fcd3cedbef3be7521ee5abd72d0845` | First-generation launcher, same logic, used for 10 launches on 2026-07-12 and 2026-07-13 | `TickerAirlockFactory` | yes | - | `0x1Ae51740cE21CAEbB8C92C457Ad7fc1bdAAe5305` | `0xdb6124d8...` | `contracts/TickerAirlockFactory-0x9c88f06b72fcd3cedbef3be7521ee5abd72d0845/` |
| `0xa97faace9a0222af631d8b25fc8c6df46d6555f4` | Stateless create-plus-first-buy wrapper deployed 2026-08-29, 8 test transactions from its deployer only; not called by the app | `LongLaunchHelper` | yes | - | `0x0e9f0E44dE744D5Ee86b8b8E3145d6901336D686` | `0xa7572fc3...` | `contracts/LongLaunchHelper-0xa97faace9a0222af631d8b25fc8c6df46d6555f4/` |
| `0xba85d8fad36c57f4890a0f3c414ed87a50b9319a` | `communityFactory` in the app config. Permissionless deployer of per-token LongFeeVaults (Community mode v2), 26 vaults so far | `LongFeeVaultFactory` | yes | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x839bc1f6...` | `contracts/LongFeeVaultFactory-0xba85d8fad36c57f4890a0f3c414ed87a50b9319a/` |
| `0x4a477bfb623a84a4a664f779cb0a202f6124b3e7` | Community mode v1: deploys splitter, Governor and TimelockController per token; used once, for AI | `LongCommunityFactory` | yes | - | `0xA85BC6f5bdB8D089b54Ffce61628bCBfDbE7A817` | `0x654dbb45...` | `contracts/LongCommunityFactory-0x4a477bfb623a84a4a664f779cb0a202f6124b3e7/` |
| `0xe8d46502e686ce3c6d381362c921d7e47924585a` | Governor deployer used by LongCommunityFactory | `LongCommunityGovernorDeployer` | yes | - | `0xA85BC6f5bdB8D089b54Ffce61628bCBfDbE7A817` | `0xba903655...` | `contracts/LongCommunityGovernorDeployer-0xe8d46502e686ce3c6d381362c921d7e47924585a/` |
| `0xd14d2eeb9648f53fa153a218eeed908789c28630` | OpenZeppelin TimelockController (2 day min delay) holding AI Community mode stock tokens, about $231K | `TimelockController` | yes | - | `0x4A477bFb623a84A4a664F779cB0A202F6124B3E7` | `0x35011eea...` | `contracts/AICommunityVault-0xd14d2eeb9648f53fa153a218eeed908789c28630/` |
| `0xd2ba46aeffec4bfddde62c2dd3e8c76c5c9aeedc` | Verified 2026-09-01; registry that pins a vault bytecode hash and reads DopplerHookInitializer beneficiaries; no launches observed using it | `LongetfFactory` | yes | - | `0xAb9a51Ca0f4eF8D131223D59aB17F944b1F85383` | `0x7307df6b...` | `contracts/LongetfFactory-0xd2ba46aeffec4bfddde62c2dd3e8c76c5c9aeedc/` |

## LongX (leveraged tokens, not part of the launch path)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x69fd4a2f26e08925d9e7101c00b5a021a9cca7ce` | Factory for LongX leveraged vault beacon proxies; 3 transactions | `LongXVaultFactory` | yes | - | `0x3260e7A806f7D5D6a85C7246FB059099F3bF0f2f` | `0xbb4555b8...` | `contracts/LongXVaultFactory-0x69fd4a2f26e08925d9e7101c00b5a021a9cca7ce/` |
| `0x50e11faae3c85f1ff7e38933c707ae5e0116de5f` | UpgradeableBeacon for LongX vaults | `LongXBeacon` | yes | basic_implementation -> 0xcfB0f21f200045B3c2EF8A20fB36498e32395C88 | `0x3260e7A806f7D5D6a85C7246FB059099F3bF0f2f` | `0xb163311a...` | `contracts/LongXBeacon-0x50e11faae3c85f1ff7e38933c707ae5e0116de5f/` |
| `0x3b2542ed1112e83a77497759752646ad8dca5564` | LongX vault implementation, current | `LongXVaultUpgradeable` | yes | - | `0x3260e7A806f7D5D6a85C7246FB059099F3bF0f2f` | `0xbec747eb...` | `contracts/LongXVaultUpgradeable-0x3b2542ed1112e83a77497759752646ad8dca5564/` |
| `0xe9d1e0d8c97bd8a3a758b2090773fc61b3c25c92` | LongX vault implementation, first deployment, the beacon constructor argument | `LongXVaultUpgradeable` | yes | - | `0x3260e7A806f7D5D6a85C7246FB059099F3bF0f2f` | `0xf21eeab9...` | `contracts/LongXVaultUpgradeableOld-0xe9d1e0d8c97bd8a3a758b2090773fc61b3c25c92/` |
| `0xf51fb54de60f6e16252e852a5ed0e60b8307606a` | The live NVDA 3x Long vault token, BeaconProxy, USDG collateral, 3x, $550K equity cap per the app | `BeaconProxy` | yes | eip1967_beacon -> 0xcfB0f21f200045B3c2EF8A20fB36498e32395C88 | `0x69Fd4A2F26e08925d9E7101C00B5a021a9CCA7cE` | `0x937c4971...` | `contracts/NVDAx3L-0xf51fb54de60f6e16252e852a5ed0e60b8307606a/` |
| `0xfa973da4f294085105b61c44e517e98e06d85b5a` | Earlier standalone NVDA 3x Long contract, 2026-08-20 alpha | `LongXVault` | yes | - | `0x3260e7A806f7D5D6a85C7246FB059099F3bF0f2f` | `0x80fdfc70...` | `contracts/NVDA3xLongOld-0xfa973da4f294085105b61c44e517e98e06d85b5a/` |

## The Doppler set a Long launch executes through

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0xeb7c034704ef8dcd2d32324c1545f62fb4ad0862` | Doppler entry point (see doppler archive) | `Airlock` | yes | - | `0x78C84FE5D1837244DC72D5B9DE7db930ab0C02b9` | `0x8ffd957b...` | `contracts/Airlock-0xeb7c034704ef8dcd2d32324c1545f62fb4ad0862/` |
| `0x1b37d3a72082029c44b35b604ea473617580b69a` | DopplerERC20V1Factory, the only factory LongLauncher accepts (see doppler archive) | `DopplerERC20V1Factory` | yes | - | `0x4482f353A46a4d4088F9550EB2C9cc92D0d5F768` | `0xb53eb826...` | `contracts/TokenFactory-0x1b37d3a72082029c44b35b604ea473617580b69a/` |
| `0x3be8b97fd0e713b5abe0649fa830223b6b4bc599` | Clone implementation behind every Long token (see doppler archive) | `DopplerERC20V1` | yes | - | `0x1B37D3a72082029c44B35B604Ea473617580b69a` | `0xb53eb826...` | `contracts/DopplerERC20V1-0x3be8b97fd0e713b5abe0649fa830223b6b4bc599/` |
| `0x4e3468951d49f2eea976ed0d6e75ffcb44a9a544` | Multicurve initializer, holds the LP-fee beneficiary shares (see doppler archive) | `DopplerHookInitializer` | yes | - | `0xdD429645eB203cAbffA48e56350f7F639e0a342b` | `0xd32e8ebb...` | `contracts/DopplerHookInitializer-0x4e3468951d49f2eea976ed0d6e75ffcb44a9a544/` |
| `0x6f02324d20cc679d0e585290caa6b16bacbc0f77` | The hook on every Long pool: decaying anti-snipe fee, buyback routing to Long's address, 5% to the Doppler owner. Non-canonical deployment, enabled as hook (flags 3), not an Airlock module | `RehypeDopplerHookInitializer` | yes | - | `0xF7483Cb279eb3AfB8db553787363C2990836b459` | `0xcf07d91c...` | `contracts/RehypeDopplerHookInitializer-0x6f02324d20cc679d0e585290caa6b16bacbc0f77/` |
| `0x3881e5246e81e1bf731a9fc1856268d381bb9bd7` | Quoter created by the Rehype hook constructor for buyback simulation | `Quoter` | yes | - | `0x6f02324d20CC679d0E585290CAa6b16baCbC0F77` | `0xcf07d91c...` | `contracts/RehypeQuoter-0x3881e5246e81e1bf731a9fc1856268d381bb9bd7/` |
| `0x85f37f74ef2478a770318bc810177a9835911ad7` | Governance module on every Long launch (see doppler archive) | `NoOpGovernanceFactory` | yes | - | `0x09EffE7ADe7F311cc5de032451CB17313997DBb9` | `0x1a1494e7...` | `contracts/NoOpGovernanceFactory-0x85f37f74ef2478a770318bc810177a9835911ad7/` |
| `0xba2f330edb16cd8056f5988d8ce19bbc63475a0e` | Migrator on every Long launch, never migrates (see doppler archive) | `NoOpMigrator` | yes | - | `0xa56c8401a0Fa8Ede03E0c28Fd3ca0e648eC8226A` | `0x3ba76830...` | `contracts/NoOpMigrator-0xba2f330edb16cd8056f5988d8ce19bbc63475a0e/` |
| `0x8366a39cc670b4001a1121b8f6a443a643e40951` | Uniswap v4 PoolManager (see doppler archive) | `PoolManager` | yes | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x4fb28d49...` | `contracts/PoolManager-0x8366a39cc670b4001a1121b8f6a443a643e40951/` |
| `0x2e8c31162b855a2ffa90f6f8634643ad6f111e18` | Artificial Inu, DopplerERC20V1 clone, Long's flagship, numeraire of a third of recent launches | `Artificial Inu` | no | eip1167 -> 0x3Be8B97Fd0e713B5aBE0649Fa830223B6B4BC599 | `0x1B37D3a72082029c44B35B604Ea473617580b69a` | `0x7632524c...` | `contracts/AIToken-0x2e8c31162b855a2ffa90f6f8634643ad6f111e18/` |

## Accounts and other addresses without a directory

| address | what it is | evidence |
| --- | --- | --- |
| `0x92d435c96e63c43e12d6d0ab28f6b0b04072f765` | Long's integrator and fee sink. EOA. `integratorAddress` in the app config, `integrator` on every Long launch, and `buybackDst` on standard launches. Holds about $4.48M (USDG $3.89M plus stock tokens) after 1.75M token transfers | `_raw/blockscout/tokens-held-0x92d4...json`, `_raw/rpc/hook-state-top-tokens.json` |
| `0x35d217b10f974a49f1bfd369fc5c85b597ae09a1` | `ROBINHOOD_AI_BUYBACK_DST`, the buyback destination for AI-paired launches. EOA with no code, 0 outgoing transactions and 214,546 incoming token transfers, so in practice a lock address for AI | `_raw/js/760859da30817643.js`, `_raw/blockscout/addresses-0x35d2...json` |
| `0x8aa7a1dfa6635af2979da4d2bdd51780842e3f99` | Long ops admin. Hardcoded `ADMIN` in every LongFeeVault, owner of TickerAirlockFactory, holds about $9.6K in stock tokens | `contracts/LongFeeVaultFactory-.../sources/src/community/LongFeeVault.sol:55`, `_raw/rpc/hook-state-top-tokens.txt` |
| `0x9b7f0d4dcf6a4baed39b2f4f5aeae6ca082bed47` | Owner of LongLauncher (can pause it and sweep stray funds). EOA with 0 transactions, so a cold key | `_raw/api/rpc-launcher-owner.json`, `_raw/blockscout/counters-0x9b7f...json` |
| `0x1ae51740ce21caebb8c92c457ad7fc1bdaae5305` | Long's deployer EOA. Deployed both launchers, sent all 10 TickerAirlockFactory launches and launched SPACEHOOD | `_raw/blockscout/addresses-0x22e9...json`, `_raw/api/decoded-launch-spacehood.json` |
| `0x9adf17b7d91731ed74c2502695794ec95b8f2a26` | A third party that launches through LongLauncher with its own `integrator` and `buybackDst` (5 of the 50 most recent launcher calls, all sent from `0x4ef489fd...`). It is the unlabelled integrator with 921 assets in the Doppler archive | `_raw/api/decoded-launcher-recent-50.json`, `_raw/indexer/counts-other-integrators.txt` |
| `0x6495687de156e602befd0cc9716dc4aed92ae23f` | A second non-app caller of LongLauncher: 4 of 50 recent launches with a distinct template (50% start fee, 15 s decay, 10% grant, fees routed to itself) | `_raw/api/decoded-launcher-recent-50.json` |
| `0x21e2ce70511e4fe542a97708e89520471daa7a66` | The Doppler Gnosis Safe, 5% LP-fee beneficiary on every launch since it became Airlock owner, and the only address that can call `claimAirlockOwnerFees` on the hook | doppler archive, `_raw/rpc/hook-state-top-tokens.json` |
| `0xedeaa06e2eb42a5c19ce27c6cffb36fd4fe1eda8` | The earlier Doppler owner address, still the 5% beneficiary on July launches such as AI, SPACEHOOD, MOO and CLIPPY | `_raw/rpc/hook-state-top-tokens.json` |
| `0x4f6c50a87bf234c45191f88ed4cbb9f021b7dc67` | AI's community-mode splitter, holder of AI's 95% LP-fee slot since 2026-07-27 | `_raw/rpc/community-mode-ai-deployment.txt`, `_raw/rpc/getshares-check.txt` |
| `0xfd73a919639ac340b07225a3595b5d701f790f64` | AI's community Governor | `_raw/rpc/community-mode-ai-deployment.txt` |
| `0x31a3edf92b49407c04215d4b744f231460a2da32` | MOO's LongFeeVault, activated, holds MOO's 95% slot | `_raw/rpc/lpfee-slot0-top-tokens.txt`, `_raw/rpc/community-mode-ai-deployment.txt` |
| `0x4a0cb7eef4b4dc31c75eac705e03463cfc3c5cb2` | AI's original fee receiver, an EIP-7702 account delegated to `CaliburEntry` `0x612373d7...` | `_raw/rpc/community-mode-ai.txt`, `_raw/blockscout/addresses-0x6123...json` |
| `0x79aeae6a47ff2e551f60bd87dbd6358efeaf4dc8` | BONER's fee receiver, also an EIP-7702 account delegated to a `CaliburEntry`; the app shows $213,689 claimed there | `_raw/rpc/community-mode-ai.txt`, `pages/08-app-token-boner.md` |
| `0x3881e5246e81e1bf731a9fc1856268d381bb9bd7` | Quoter created by the Rehype hook, has a directory above | `_raw/rpc/hook-state-top-tokens.txt` |
| `0xf3334192d15450cdd385c8b70e03f9a6bd9e673b` | Uniswap v4 StateView, used here to read each pool's live `lpFee` | `_raw/rpc/lpfee-slot0-top-tokens.txt`, doppler archive |
| `0xbf4195ab0b03e1eb3345dd1e83bed7650b1ed123` | `REHYPE_HOOK_ADDRESS` in the bundle: the Rehype hook Long uses on Base, not on 4663 | `_raw/js/760859da30817643.js` |

## Name collisions to ignore

Blockscout's contract search for `Long` also returns `Longbow*`, `Longwave*` and `LONGBOW` contracts (`_raw/blockscout/smart-contracts-search-Long.json`).
None shares a deployer, a source header, or an `@author` with Long, and none is referenced by the app bundle; they are unrelated projects.
