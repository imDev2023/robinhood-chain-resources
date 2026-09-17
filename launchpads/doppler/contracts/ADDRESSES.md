# Doppler contract addresses on Robinhood Chain

33 addresses.
Chain: Robinhood Chain, id 4663.
Captured 2026-09-02 from the Blockscout v2 API, from `eth_call` against the Alchemy archive RPC, and from the app's own RPC proxy traffic (`_raw/network/app-session.har`).
Every row has a directory under `contracts/` holding `metadata.json`, `abi.json` and verified `sources/`.
Every contract in this table is verified on Blockscout.

Four things to carry into any integration.

1. `Airlock.create()` is the only entry point.
   It takes one module of each of four kinds and reverts on anything not whitelisted on the Airlock itself, so the whitelist below, read live with `getModuleState(address)`, is the authoritative list of what can actually be used (`_raw/blockscout/airlock-getModuleState.json`).
2. The Doppler docs' table for chain 4663 lists 25 contracts (`pages/25-docs-reference-contract-addresses.md`) and all 25 match on-chain.
   The eight extra rows here are the Uniswap infrastructure those 25 are wired to, plus one non-canonical Rehype initializer the app calls; see section 5 of `README.md`.
3. There is no per-launch factory state to look up.
   Each launch gets its own DopplerERC20V1 clone and its own Uniswap v4 hook, both mined to a salt at create time.
   Resolve them from the `Create(address asset, address indexed numeraire, address initializer, address poolOrHook)` event or from the indexer, never by hardcoding.
4. The Airlock's owner controls the whitelist, and it is not the address in the constructor.
   Constructor `owner_` was `0xEDeAa06E2eB42A5c19ce27c6cfFb36fd4fE1eDa8`; `owner()` today returns the Gnosis Safe `0x21e2ce70511e4fe542a97708e89520471daa7a66`, a 3-of-6.

Safe signers, read with `getOwners()`: `0xf5b75474d006495c82dbbf010e230d5d2f86226f`, `0x2c6c52b00d7360a8f82f3e8d27369f75c47306f9`, `0xb8aa608671a639873c63ccd02548706aa8be2ff7`, `0xdf95cc445469816234ad95f702c79d25bce401a7`, `0xd39475c553cc86f0a569001f22b79f693ea92f0e`, `0xc2b3a6e720c5f4e422caa6026bb9c3d1813a7ddb`.
Threshold 3.
`StreamableFeesLockerV2.owner()` is still the deployer-era `0xEDeAa06E2eB42A5c19ce27c6cfFb36fd4fE1eDa8`.
Every contract in the Doppler set was placed through deterministic deployers, which is why each row shows a different one-shot creator EOA rather than a single team wallet.

## Core

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0xeb7c034704ef8dcd2d32324c1545f62fb4ad0862` | Entry point. Holds the module whitelist, collects protocol and integrator fees, owns migration | `Airlock` | yes | - | `0x78C84FE5D1837244DC72D5B9DE7db930ab0C02b9` | `0x8ffd957b...` | `contracts/Airlock-0xeb7c034704ef8dcd2d32324c1545f62fb4ad0862/` |
| `0xf45588e8e0b1df9db9ae7e20ece5726ae931357c` | Optional helper that bundles create plus a first buy in one transaction. Not an Airlock module | `Bundler` | yes | - | `0x9ab85deFdFCD9a229F94202099818E54325B6B75` | `0x24d3b8fa...` | `contracts/Bundler-0xf45588e8e0b1df9db9ae7e20ece5726ae931357c/` |
| `0x103004e50bed65dfba30dd9c264b6bdf5e529b83` | Deterministic deployer used to place the set at matching addresses across chains | `DopplerCreateXDeployer` | yes | - | `0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed` | `0x24996e26...` | `contracts/DopplerCreateXDeployer-0x103004e50bed65dfba30dd9c264b6bdf5e529b83/` |

## Token factories (Airlock module state 1, TokenFactory)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x1b37d3a72082029c44b35b604ea473617580b69a` | Whitelisted. Clones DopplerERC20V1 for a normal ERC-20 launch | `DopplerERC20V1Factory` | yes | - | `0x4482f353A46a4d4088F9550EB2C9cc92D0d5F768` | `0xb53eb826...` | `contracts/DopplerERC20V1Factory-0x1b37d3a72082029c44b35b604ea473617580b69a/` |
| `0x3be8b97fd0e713b5abe0649fa830223b6b4bc599` | Clone implementation behind every DopplerERC20V1Factory token. Not itself a module | `DopplerERC20V1` | yes | - | `0x1B37D3a72082029c44B35B604Ea473617580b69a` | `0xb53eb826...` | `contracts/DopplerERC20V1-0x3be8b97fd0e713b5abe0649fa830223b6b4bc599/` |
| `0x37a9fa204a4d3a429fded7e3469ab076c854bc9d` | Whitelisted. Doppler404 launches, an ERC-20 and ERC-721 pair (ERC-7631) | `DN404Factory` | yes | - | `0xf4287C4Fd31ccccb69EA4Aa3e52ea8e41fb26897` | `0x33f9d082...` | `contracts/DN404Factory-0x37a9fa204a4d3a429fded7e3469ab076c854bc9d/` |

## Governance factories (Airlock module state 2, GovernanceFactory)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0xdeb0447dae3eb177c4dba8bbccca25c8f273b7ef` | Whitelisted. OpenZeppelin Governor plus timelock | `GovernanceFactory` | yes | - | `0xFd1AcfD99D6727d6E92AAD8C8241d9F592faeAe2` | `0x56ebbeba...` | `contracts/GovernanceFactory-0xdeb0447dae3eb177c4dba8bbccca25c8f273b7ef/` |
| `0xdb036746d65dd52126b1915f1adf555e6c5237cf` | Whitelisted. Lighter launchpad-flavoured governance | `LaunchpadGovernanceFactory` | yes | - | `0x179D8a78e667B89bc8AC09fce018F83a0C16Bc3E` | `0xb76ed227...` | `contracts/LaunchpadGovernanceFactory-0xdb036746d65dd52126b1915f1adf555e6c5237cf/` |
| `0x85f37f74ef2478a770318bc810177a9835911ad7` | Whitelisted. No governance; sets governance and timelock to `0x...dead`. This is what every launch on 4663 actually uses | `NoOpGovernanceFactory` | yes | - | `0x09EffE7ADe7F311cc5de032451CB17313997DBb9` | `0x1a1494e7...` | `contracts/NoOpGovernanceFactory-0x85f37f74ef2478a770318bc810177a9835911ad7/` |
| `0x6076fddfcac0dd980e0350dff5239fec3f86c578` | Deploys the timelock GovernanceFactory pairs with. Not itself a module | `TimelockFactory` | yes | - | `0xDeb0447DAE3EB177c4dbA8bBCCCa25c8F273B7ef` | `0x56ebbeba...` | `contracts/TimelockFactory-0x6076fddfcac0dd980e0350dff5239fec3f86c578/` |

## Pool initializers (Airlock module state 3, PoolInitializer)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x4e3468951d49f2eea976ed0d6e75ffcb44a9a544` | Whitelisted. Multicurve. 108,698 of 109,159 assets on this chain were created through it | `DopplerHookInitializer` | yes | - | `0xdD429645eB203cAbffA48e56350f7F639e0a342b` | `0xd32e8ebb...` | `contracts/DopplerHookInitializer-0x4e3468951d49f2eea976ed0d6e75ffcb44a9a544/` |
| `0x6cce158b6d1747617fc218592b4d60b239b957ea` | Whitelisted. Dynamic Dutch-auction bonding curve, aka Doppler v4. 4 assets on this chain | `UniswapV4Initializer` | yes | - | `0x2fbF1FA0540652FB6C474B0FE60Fe376C254073E` | `0x2ad4f96e...` | `contracts/UniswapV4Initializer-0x6cce158b6d1747617fc218592b4d60b239b957ea/` |
| `0xde8886a0019ea060b8378ee37b8a23b8117f29a3` | Whitelisted. Static v3 bonding curve, aka Doppler v3. 457 assets on this chain | `LockableUniswapV3Initializer` | yes | - | `0x583ffb503dDBB222672c89Af42AF17593ba91928` | `0x6506158f...` | `contracts/LockableUniswapV3Initializer-0xde8886a0019ea060b8378ee37b8a23b8117f29a3/` |
| `0x4389ad34938b14f25cff7ed983c53f5a42a2573f` | Mines the salt and deploys the per-launch v4 hook for UniswapV4Initializer. Not itself a module | `DopplerDeployer` | yes | - | `0x4F178006CEe1B26251Dc12Fbf46eB6E7dc09De24` | `0xa87d3dff...` | `contracts/DopplerDeployer-0x4389ad34938b14f25cff7ed983c53f5a42a2573f/` |
| `0x5f9eb5f6726fe88d5e39867967f5b833d2fa3215` | Canonical fee-rehypothecation wrapper. NotWhitelisted as an Airlock *module*, but `isDopplerHookEnabled` returns 3, so it is live and usable as a *hook* inside `InitData` | `RehypeDopplerHookInitializer` | yes | - | `0xE923E166B265e7E309Ed73Eb118eB8fddce9774d` | `0x016c8824...` | `contracts/RehypeDopplerHookInitializer-0x5f9eb5f6726fe88d5e39867967f5b833d2fa3215/` |
| `0x6f02324d20cc679d0e585290caa6b16bacbc0f77` | A second, non-canonical RehypeDopplerHookInitializer. Not in the docs, not in the SDK, not whitelisted. `app.doppler.lol` calls `getState(address)` on it and the Long archive records LongLauncher using it | `RehypeDopplerHookInitializer` | yes | - | `0xF7483Cb279eb3AfB8db553787363C2990836b459` | `0xcf07d91c...` | `contracts/RehypeDopplerHookInitializerAlt-0x6f02324d20cc679d0e585290caa6b16bacbc0f77/` |
| `0xc16c826f75338a5ea626f94f8992191b4ce5aba2` | Anti-snipe helper bound to DopplerHookInitializer. Not itself a module | `SwapRestrictorDopplerHook` | yes | - | `0xB840Db4aBAeE713DaB27946F33DBD3743e1Eb282` | `0x01165638...` | `contracts/SwapRestrictorDopplerHook-0xc16c826f75338a5ea626f94f8992191b4ce5aba2/` |

## Liquidity migrators (Airlock module state 4, LiquidityMigrator)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0xba2f330edb16cd8056f5988d8ce19bbc63475a0e` | Whitelisted. Never migrates; the multicurve pool is the permanent home. 109,129 of 109,159 assets use it | `NoOpMigrator` | yes | - | `0xa56c8401a0Fa8Ede03E0c28Fd3ca0e648eC8226A` | `0x3ba76830...` | `contracts/NoOpMigrator-0xba2f330edb16cd8056f5988d8ce19bbc63475a0e/` |
| `0x7bf319d8e969f7596b1bc171da9ce322f67ae0c4` | Whitelisted. Migrates into a Uniswap v4 pool behind a Doppler hook, with streamed fees. 4 assets | `DopplerHookMigrator` | yes | - | `0x39c61afDC68423483847afB2E5c592A80Dd6095F` | `0x7e76a2e3...` | `contracts/DopplerHookMigrator-0x7bf319d8e969f7596b1bc171da9ce322f67ae0c4/` |
| `0xb05046cea797c993fb5b583098b1c4682e9da333` | Whitelisted. Migrates into Uniswap v2 with a proceeds split. 26 assets | `UniswapV2MigratorSplit` | yes | - | `0x3213996297CAB8A81952c3F92F7330121A19Ad2C` | `0x6bb59b4e...` | `contracts/UniswapV2MigratorSplit-0xb05046cea797c993fb5b583098b1c4682e9da333/` |
| `0x660740d7d6fb2c8998fa3fff459cceb9ac12c84b` | Rehypothecation migrator. Deployed but NotWhitelisted; 0 assets | `RehypeDopplerHookMigrator` | yes | - | `0x11536E93dCEE32d5FaB0950865fc02204D6AC354` | `0x17f08a11...` | `contracts/RehypeDopplerHookMigrator-0x660740d7d6fb2c8998fa3fff459cceb9ac12c84b/` |
| `0x63f6efe03f25a8c6650b38d05c5a454051d642a5` | Locks the v2 LP minted by UniswapV2MigratorSplit. Not itself a module | `UniswapV2Locker` | yes | - | `0xB05046cEa797c993FB5b583098B1c4682e9Da333` | `0x6bb59b4e...` | `contracts/UniswapV2Locker-0x63f6efe03f25a8c6650b38d05c5a454051d642a5/` |
| `0x7b6147ac3f615bdb764e7ebd5f517dac1ad163b8` | Holds migrated v4 positions and streams fees to beneficiaries. Enforces the 5% protocol-owner floor. Not itself a module | `StreamableFeesLockerV2` | yes | - | `0x6C852852BFa632d00CF5A91DFF466Cc1b8dB194f` | `0x8ff7d1d8...` | `contracts/StreamableFeesLockerV2-0x7b6147ac3f615bdb764e7ebd5f517dac1ad163b8/` |
| `0x46adee7595d48b1ec53090e9bc78e1e69fa0ef06` | Tops up migration liquidity. Constructor argument of DopplerHookMigrator and UniswapV2MigratorSplit | `TopUpDistributor` | yes | - | `0x319D83cc3B6572D9e8F4f709B2CBc3376e1069b2` | `0xb65238e8...` | `contracts/TopUpDistributor-0x46adee7595d48b1ec53090e9bc78e1e69fa0ef06/` |

## Quoting and reads (not modules)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0xce6cd4e35447e05a39a50a4bcf61f2dcd93a8f0d` | Doppler v4 quoter | `Quoter` | yes | - | `0x5F9eB5f6726Fe88D5e39867967F5b833d2fA3215` | `0x016c8824...` | `contracts/Quoter-0xce6cd4e35447e05a39a50a4bcf61f2dcd93a8f0d/` |
| `0xf4c22465532f64777ffcd7770831aeca38f35c04` | Reads live auction state for the app and the SDK | `DopplerLensQuoter` | yes | - | `0x720Ce7914B0e6D8547c0AC8D3547FcB6354b59E6` | `0xc846bbac...` | `contracts/DopplerLensQuoter-0xf4c22465532f64777ffcd7770831aeca38f35c04/` |
| `0x33e885ed0ec9bf04ecfb19341582aadcb4c8a9e7` | Uniswap v3 QuoterV2. Called by the app through `/api/rpc/4663` | `QuoterV2` | yes | - | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0x62f59304...` | `contracts/QuoterV2-0x33e885ed0ec9bf04ecfb19341582aadcb4c8a9e7/` |
| `0x8dc178efb8111bb0973dd9d722ebeff267c98f94` | Uniswap v4 Quoter. Called by the app through `/api/rpc/4663` | `V4Quoter` | yes | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x6bf436d7...` | `contracts/V4Quoter-0x8dc178efb8111bb0973dd9d722ebeff267c98f94/` |
| `0xf3334192d15450cdd385c8b70e03f9a6bd9e673b` | Uniswap v4 periphery read helper. Constructor argument of DopplerLensQuoter | `StateView` | yes | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x3d61e2c9...` | `contracts/StateView-0xf3334192d15450cdd385c8b70e03f9a6bd9e673b/` |

## Uniswap and chain infrastructure Doppler is wired to (not Doppler contracts)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x8366a39cc670b4001a1121b8f6a443a643e40951` | Uniswap v4 singleton. Every Doppler v4 pool and hook on this chain lives here | `PoolManager` | yes | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x4fb28d49...` | `contracts/PoolManager-0x8366a39cc670b4001a1121b8f6a443a643e40951/` |
| `0x1f7d7550b1b028f7571e69a784071f0205fd2efa` | Uniswap v3 factory. Constructor argument of LockableUniswapV3Initializer | `UniswapV3Factory` | yes | - | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0x8add72fb...` | `contracts/UniswapV3Factory-0x1f7d7550b1b028f7571e69a784071f0205fd2efa/` |
| `0x8bceaa40b9acdfaedf85adf4ff01f5ad6517937f` | Uniswap v2 factory. Constructor argument of UniswapV2MigratorSplit | `UniswapV2Factory` | yes | - | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0x2fc08b6c...` | `contracts/UniswapV2Factory-0x8bceaa40b9acdfaedf85adf4ff01f5ad6517937f/` |
| `0x0bd7d308f8e1639fab988df18a8011f41eacad73` | Canonical WETH, a TransparentUpgradeableProxy. Default numeraire and constructor argument of UniswapV2MigratorSplit | `TransparentUpgradeableProxy` | yes | 0xC6B81b429797E0f555440b70cD99e032D7AE947e | `0xE83b11Faa5693E68388785FecA3595C6805dFb9a` | `0x05317cd1...` | `contracts/WETH-0x0bd7d308f8e1639fab988df18a8011f41eacad73/` |

Two more addresses the SDK hardcodes for chain 4663 but that have no directory here, because nothing in the launch path calls them and neither is a Doppler contract:

| address | role | source |
| --- | --- | --- |
| `0x8876789976decbfcbbbe364623c63652db8c0904` | Uniswap UniversalRouter | `_raw/github/doppler-sdk/src/evm/addresses.ts` |
| `0x000000000022D473030F116dDEE9F6B43aC78BA3` | Permit2 | `_raw/github/doppler-sdk/src/evm/addresses.ts` |

## Airlock whitelist as read on 2026-09-02

`getModuleState(address)` on `0xeb7c034704ef8dcd2d32324c1545f62fb4ad0862`, over the 25 documented addresses plus 111 look-alike contracts found by Blockscout name search.
Raw: `_raw/blockscout/airlock-getModuleState.json`.

| state | meaning | whitelisted modules |
| --- | --- | --- |
| 1 | TokenFactory | DopplerERC20V1Factory, DN404Factory |
| 2 | GovernanceFactory | GovernanceFactory, LaunchpadGovernanceFactory, NoOpGovernanceFactory |
| 3 | PoolInitializer | DopplerHookInitializer, UniswapV4Initializer, LockableUniswapV3Initializer |
| 4 | LiquidityMigrator | NoOpMigrator, DopplerHookMigrator, UniswapV2MigratorSplit |

Everything else returns 0, NotWhitelisted.
That includes both Rehype contracts. That does **not** mean rehypothecation is off.
There are two independent registries and only the first is the Airlock's:

| registry | governs | Rehype |
| --- | --- | --- |
| `Airlock.getModuleState(address)` | what may be passed as a module to `create` | `0`, NotWhitelisted |
| `DopplerHookInitializer.isDopplerHookEnabled(address)` | what may be attached as `InitData.dopplerHook` | `3`, enabled |

Rehypothecation is therefore live in production on this chain, attached as a hook on an otherwise standard multicurve launch rather than swapped in as an initializer module.
A decoded real example is in `_raw/wallet/real-create-decoded.txt`.
The 111 look-alikes searched (RamenLiquidityLocker, StonkBrokerMigrator, AirlockLaunchpad, AirlockGate, DopplerDN404, TickerAirlockFactory, MultiPoolsTokenFactoryV2 and the rest) are other projects' forks and copies.
None is whitelisted on the Doppler Airlock.
