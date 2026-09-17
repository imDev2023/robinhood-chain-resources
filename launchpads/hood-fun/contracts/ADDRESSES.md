# hood.fun contract addresses

Chain: Robinhood Chain, chain id 4663.
Explorer: <https://robinhoodchain.blockscout.com>.
Read on 2026-09-03.
Verification flags come from `addresses/<addr>`, sources from `smart-contracts/<addr>`.

Every address below has a directory under `contracts/`.
Verified contracts carry `metadata.json`, `abi.json`, `sources/` and a generated `README.md`; unverified ones carry `metadata.json`, `bytecode.hex` and a note naming the verified contract that explains them.

Grouped by role rather than alphabetically, because the useful question is which contracts a launch actually touches.

## The live launch path (a coin launched today touches these, in this order)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x8c529f0a77c07ce0e6796f153d292501ee6f66f6` | HoodCustomLaunchpad-v2-default | HoodCustomLaunchpad | yes | - | `0x0F307b093dafB55B2a0C12D53d5640D00D9a7836` | `0x84bf91a3...de9edd` | `contracts/HoodCustomLaunchpad-v2-default-0x8c529f0a77c07ce0e6796f153d292501ee6f66f6/` |
| `0xC14F3Be12F5c0f3eE544Fc4E8883be981197f0be` | HoodStockPairMigrator | HoodStockPairMigrator | yes | - | `0xb5DBceC5533AA954320a5FdFc95cA745c6425EFD` | `0x21509fa3...01011a` | `contracts/HoodStockPairMigrator-0xC14F3Be12F5c0f3eE544Fc4E8883be981197f0be/` |
| `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3` | UniswapNonfungiblePositionManager | NonfungiblePositionManager | yes | - | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0x9a8d07e7...718d4e` | `contracts/UniswapNonfungiblePositionManager-0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3/` |
| `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA` | UniswapV3Factory | UniswapV3Factory | yes | - | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0x8add72fb...ff8977` | `contracts/UniswapV3Factory-0x1f7d7550B1b028f7571E69A784071F0205FD2EfA/` |
| `0xd2a7c92fcb240c755919e9230c8db066e9ca1500` | HoodBurnLocker | HoodBurnLocker | yes | - | `0x0F307b093dafB55B2a0C12D53d5640D00D9a7836` | `0xe19348ed...0f89ad` | `contracts/HoodBurnLocker-0xd2a7c92fcb240c755919e9230c8db066e9ca1500/` |
| `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73` | WETH-Proxy | TransparentUpgradeableProxy | yes | eip1967 -> `0xC6B81b429797E0f555440b70cD99e032D7AE947e` | `0xE83b11Faa5693E68388785FecA3595C6805dFb9a` | `0x05317cd1...f56b12` | `contracts/WETH-Proxy-0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73/` |
| `0xC6B81b429797E0f555440b70cD99e032D7AE947e` | WETH-Implementation-aeWETH | aeWETH | yes | - | `0xE83b11Faa5693E68388785FecA3595C6805dFb9a` | `0x05317cd1...f56b12` | `contracts/WETH-Implementation-aeWETH-0xC6B81b429797E0f555440b70cD99e032D7AE947e/` |

What each one is:

- `0x8c529f0a77c07ce0e6796f153d292501ee6f66f6` - Launchpad in use today. `LAUNCHPAD_ADDRESS` in the app bundle. Holds the curve, the fees and the CTO and migrator timelocks.
- `0xC14F3Be12F5c0f3eE544Fc4E8883be981197f0be` - The live `migrator()` of the launchpad above. Seeds and locks the Uniswap v3 1% pool and, if the creator opted in, swaps the raise into a stock or USDG quote first.
- `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3` - Uniswap v3 position manager the migrator mints the locked position through.
- `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA` - Uniswap v3 factory the graduation pool is created on.
- `0xd2a7c92fcb240c755919e9230c8db066e9ca1500` - Ownerless locker that receives the LP NFT forever and pays out the pool fee. `creatorShareBps` 8000 on the WETH side, `BURN_BPS` 8000 on the token side.
- `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73` - WETH, the default quote asset and the only asset the locker pays a creator in.
- `0xC6B81b429797E0f555440b70cD99e032D7AE947e` - WETH implementation behind the proxy above.

## Optional launch modes, reached through an approved platform contract

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x6d188c21f99a7578d4E3fD449b67d740ff97eb4d` | HoodCommunityFactory | HoodCommunityFactory | yes | basic_implementation -> `0x6b8Efd1713B020Ea0C01557Dc3fCFEa266cc048f` | `0x0F307b093dafB55B2a0C12D53d5640D00D9a7836` | `0xbc30fffc...760250` | `contracts/HoodCommunityFactory-0x6d188c21f99a7578d4E3fD449b67d740ff97eb4d/` |
| `0x6b8Efd1713B020Ea0C01557Dc3fCFEa266cc048f` | HoodCommunityFactory-Implementation | - | no | - | `0x6d188c21F99a7578D4e3fD449B67D740FF97EB4D` | `0xbc30fffc...760250` | `contracts/HoodCommunityFactory-Implementation-0x6b8Efd1713B020Ea0C01557Dc3fCFEa266cc048f/` |
| `0x1811F54e2964758641AaC993cA91F9189a8BdA2d` | HoodStockFactory | HoodStockFactory | yes | basic_implementation -> `0xECF1533F94EB3547FdFF9B50b6173529Aa4E0a33` | `0x78b531f1394863964978Dc57d21c07B89e1CEeBd` | `0x3dd48ab6...dd6d4d` | `contracts/HoodStockFactory-0x1811F54e2964758641AaC993cA91F9189a8BdA2d/` |
| `0xECF1533F94EB3547FdFF9B50b6173529Aa4E0a33` | HoodStockFactory-Implementation | - | no | - | `0x1811F54e2964758641AaC993cA91F9189a8BdA2d` | `0x3dd48ab6...dd6d4d` | `contracts/HoodStockFactory-Implementation-0xECF1533F94EB3547FdFF9B50b6173529Aa4E0a33/` |
| `0xed2d2a46E64Bc84355eE3CD6A02ab470EA42147E` | HoodCommunityGuarded | HoodCommunityGuarded | yes | basic_implementation -> `0xAb0B12005275cA53C649f360119b9C23F60faAb8` | `0x0F307b093dafB55B2a0C12D53d5640D00D9a7836` | `0xfc86ba80...ac53fe` | `contracts/HoodCommunityGuarded-0xed2d2a46E64Bc84355eE3CD6A02ab470EA42147E/` |
| `0xAb0B12005275cA53C649f360119b9C23F60faAb8` | HoodCommunityGuarded-Implementation | - | no | - | `0xed2d2a46E64Bc84355eE3CD6A02ab470EA42147E` | `0xfc86ba80...ac53fe` | `contracts/HoodCommunityGuarded-Implementation-0xAb0B12005275cA53C649f360119b9C23F60faAb8/` |
| `0xd71f61Ee12c9bb7Faf001267Af17e1118856fA29` | HoodProfiles | HoodProfiles | yes | - | `0x90655172A3F8C73C2D664F372e1be0339702bFa7` | `0xcddaa54c...cdd389` | `contracts/HoodProfiles-0xd71f61Ee12c9bb7Faf001267Af17e1118856fA29/` |

What each one is:

- `0x6d188c21f99a7578d4E3fD449b67d740ff97eb4d` - Community-coin factory. Approved platform on the live launchpad with `feeShareBps` 2000. Clones a rewards vault per coin and makes the vault the coin's creator.
- `0x6b8Efd1713B020Ea0C01557Dc3fCFEa266cc048f` - `HoodCommunityRewards` implementation the factory clones per community coin.
- `0x1811F54e2964758641AaC993cA91F9189a8BdA2d` - Stock-rewards factory. Approved platform on the live launchpad with `feeShareBps` 2000.
- `0xECF1533F94EB3547FdFF9B50b6173529Aa4E0a33` - `HoodStockRewards` implementation the stock factory clones per coin.
- `0xed2d2a46E64Bc84355eE3CD6A02ab470EA42147E` - Second community factory in the app bundle's list. `platforms()` on the live launchpad reports it **not approved**, so it cannot launch.
- `0xAb0B12005275cA53C649f360119b9C23F60faAb8` - Implementation behind `HoodCommunityGuarded`.
- `0xd71f61Ee12c9bb7Faf001267Af17e1118856fA29` - On-chain creator profiles used by the coin pages. Not in the launch path.

## Superseded launchpads and their migrators and lockers (still live, still holding LP)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x5Fcc1DF0dC020CF454e742E9a8Ae2554C37A452C` | HoodCustomLaunchpad | HoodCustomLaunchpad | yes | - | `0x4fc2c986e3dBA46D7Ce6B60919c78E48ae52188b` | `0xec35eb04...b85629` | `contracts/HoodCustomLaunchpad-0x5Fcc1DF0dC020CF454e742E9a8Ae2554C37A452C/` |
| `0x6a63d96ef77ae569fcb85934cf1bd1ec7fe9b33d` | HoodLaunchpad-classic | HoodLaunchpad | yes | - | `0x90655172A3F8C73C2D664F372e1be0339702bFa7` | `0x53fc0579...a6be62` | `contracts/HoodLaunchpad-classic-0x6a63d96ef77ae569fcb85934cf1bd1ec7fe9b33d/` |
| `0x3d1c455f81ec131cc91b000b42fccbf45a132026` | HoodCustomLaunchpad-c | HoodCustomLaunchpad | yes | - | `0x860C93251C121Bd3dF12c7B52aD522edE1AB99FF` | `0xb0be8a7b...8b5c2c` | `contracts/HoodCustomLaunchpad-c-0x3d1c455f81ec131cc91b000b42fccbf45a132026/` |
| `0x5790Ef23bE2E1543442C12F4550FaE147ba8eDBe` | HoodV3Migrator-a | HoodV3Migrator | yes | - | `0x4fc2c986e3dBA46D7Ce6B60919c78E48ae52188b` | `0xd7f7be6f...934af1` | `contracts/HoodV3Migrator-a-0x5790Ef23bE2E1543442C12F4550FaE147ba8eDBe/` |
| `0x88B4cde518272033F48862CEF728203aF219D02e` | HoodV3Migrator-b | HoodV3Migrator | yes | - | `0x90655172A3F8C73C2D664F372e1be0339702bFa7` | `0xf58e6637...13a7ed` | `contracts/HoodV3Migrator-b-0x88B4cde518272033F48862CEF728203aF219D02e/` |
| `0x86c6FAF889eBAC8621BBb6dd8CA86aa6d51c9e6C` | HoodV3MigratorV2-a | HoodV3MigratorV2 | yes | - | `0x0F307b093dafB55B2a0C12D53d5640D00D9a7836` | `0x2749915e...808de5` | `contracts/HoodV3MigratorV2-a-0x86c6FAF889eBAC8621BBb6dd8CA86aa6d51c9e6C/` |
| `0x6d36DcD6fab842a2B29896c5c58f32304B824711` | HoodV3MigratorV2-b | HoodV3MigratorV2 | yes | - | `0x860C93251C121Bd3dF12c7B52aD522edE1AB99FF` | `0x759e4b01...2f6bd5` | `contracts/HoodV3MigratorV2-b-0x6d36DcD6fab842a2B29896c5c58f32304B824711/` |
| `0xad69d8a00564f4a2365cc74594925f95281706aa` | HoodBurnLocker-customV1 | HoodBurnLocker | yes | - | `0x4fc2c986e3dBA46D7Ce6B60919c78E48ae52188b` | `0xcec294b4...2f976c` | `contracts/HoodBurnLocker-customV1-0xad69d8a00564f4a2365cc74594925f95281706aa/` |
| `0x86083371c51654816518c35cc589871c24018a54` | HoodLiquidityLocker-classic | HoodLiquidityLocker | yes | - | `0x90655172A3F8C73C2D664F372e1be0339702bFa7` | `0xd26800f8...f751d0` | `contracts/HoodLiquidityLocker-classic-0x86083371c51654816518c35cc589871c24018a54/` |
| `0x5e27754b2cdf4fe3715451d2d3d267801e0f4934` | HoodBurnLocker-c | HoodBurnLocker | yes | - | `0x860C93251C121Bd3dF12c7B52aD522edE1AB99FF` | `0x1c4060c4...2c23e0` | `contracts/HoodBurnLocker-c-0x5e27754b2cdf4fe3715451d2d3d267801e0f4934/` |

What each one is:

- `0x5Fcc1DF0dC020CF454e742E9a8Ae2554C37A452C` - The launchpad that carried almost all of hood.fun's history: 10,575 launches, 19 graduations. Still live, no longer what the app points at.
- `0x6a63d96ef77ae569fcb85934cf1bd1ec7fe9b33d` - The original launchpad. 85 launches, 2 graduations. `creatorFeeShareBps` 5000, not 8000.
- `0x3d1c455f81ec131cc91b000b42fccbf45a132026` - A third `HoodCustomLaunchpad` deployment, 14 launches, 0 graduations. Not referenced anywhere in the app bundle; found by reading `launchpad()` off `HoodV3MigratorV2-b`.
- `0x5790Ef23bE2E1543442C12F4550FaE147ba8eDBe` - Migrator of the custom-v1 launchpad. `creatorShareBps` 8000, locker `0xad69d8...`.
- `0x88B4cde518272033F48862CEF728203aF219D02e` - Migrator of the classic launchpad. `creatorShareBps` 5000, locker `0x860833...`.
- `0x86c6FAF889eBAC8621BBb6dd8CA86aa6d51c9e6C` - Migrator generation 2 for the live launchpad. Superseded by `HoodStockPairMigrator`; not pointed at by anything today.
- `0x6d36DcD6fab842a2B29896c5c58f32304B824711` - Migrator of the third launchpad `0x3d1c455f...`.
- `0xad69d8a00564f4a2365cc74594925f95281706aa` - Locker holding the 19 LP positions of the custom-v1 launchpad's graduations.
- `0x86083371c51654816518c35cc589871c24018a54` - `HoodLiquidityLocker`, the pre-burn locker holding the classic launchpad's 2 positions. Different contract from `HoodBurnLocker` and a different `Collected` event shape.
- `0x5e27754b2cdf4fe3715451d2d3d267801e0f4934` - Locker of the third launchpad's migrator. Zero positions locked.

## Control

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x8E96a84AdC54d04869ded92661a01f75e283741B` | ProtocolOwner-GnosisSafe-current | SafeProxy | yes | master_copy -> `0x29fcB43b46531BcA003ddC8FCB67FFE91900C762` | `0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67` | `0x0633d515...aa850c` | `contracts/ProtocolOwner-GnosisSafe-current-0x8E96a84AdC54d04869ded92661a01f75e283741B/` |
| `0xB3f3B54E11217F4F73e7a766B7CAA187390d700D` | ProtocolOwner-GnosisSafe-legacy | - | no | master_copy -> `0x29fcB43b46531BcA003ddC8FCB67FFE91900C762` | `0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67` | `0x78c0f742...25212c` | `contracts/ProtocolOwner-GnosisSafe-legacy-0xB3f3B54E11217F4F73e7a766B7CAA187390d700D/` |
| `0x29fcB43b46531BcA003ddC8FCB67FFE91900C762` | GnosisSafe-MasterCopy | SafeL2 | yes | - | `-` | - | `contracts/GnosisSafe-MasterCopy-0x29fcB43b46531BcA003ddC8FCB67FFE91900C762/` |

What each one is:

- `0x8E96a84AdC54d04869ded92661a01f75e283741B` - Live `owner()` of the current launchpad, the migrator, the community factory and the stock factory. Safe 1.4.1, `getThreshold()` 2, `getOwners()` returns 3 addresses.
- `0xB3f3B54E11217F4F73e7a766B7CAA187390d700D` - Live `owner()` of the classic, custom-v1 and third launchpads. Also a 2-of-3 Safe, with a **different owner set** from the current one.
- `0x29fcB43b46531BcA003ddC8FCB67FFE91900C762` - `SafeL2` master copy both Safes delegate to.

## Quote assets a coin can be paired against at graduation

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168` | USDG-Proxy | ERC1967Proxy | yes | eip1967 -> `0x68184C449E1a8f34fA18d289737129FD27B66f8F` | `0xBe498aad9c6fd0E4Cd6d1E3fBb395026c5D28215` | `0xc51b4ac1...a54930` | `contracts/USDG-Proxy-0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168/` |
| `0x68184C449E1a8f34fA18d289737129FD27B66f8F` | USDG-Implementation | USDG | yes | - | `0xBe498aad9c6fd0E4Cd6d1E3fBb395026c5D28215` | `0x5a88b74f...d48769` | `contracts/USDG-Implementation-0x68184C449E1a8f34fA18d289737129FD27B66f8F/` |
| `0xd0601CE157Db5bdC3162BbaC2a2C8aF5320D9EEC` | StockBeaconProxy-NVDA | BeaconProxy | yes | eip1967_beacon -> `0xb35490d6f9163DE4F80d88dc75c3516eb64C5aE2` | `0x4783C67b63dE2B358Ac5951a7D41F47A38F3C046` | `0xcdb797c5...cb755f` | `contracts/StockBeaconProxy-NVDA-0xd0601CE157Db5bdC3162BbaC2a2C8aF5320D9EEC/` |
| `0xb35490d6f9163DE4F80d88dc75c3516eb64C5aE2` | Stock-Implementation | Stock | yes | - | `0x074377a78A9710A1D47244f89797718b4f491279` | `0xd58cebeb...06420f` | `contracts/Stock-Implementation-0xb35490d6f9163DE4F80d88dc75c3516eb64C5aE2/` |
| `0x4783C67b63dE2B358Ac5951a7D41F47A38F3C046` | StockFactory-Proxy-RobinhoodStocks | ERC1967Proxy | yes | eip1967 -> `0xEe351E53BCe6AAF106428358838197C91e36EE0E` | `0x074377a78A9710A1D47244f89797718b4f491279` | `0x13c99b31...9e131c` | `contracts/StockFactory-Proxy-RobinhoodStocks-0x4783C67b63dE2B358Ac5951a7D41F47A38F3C046/` |
| `0xEe351E53BCe6AAF106428358838197C91e36EE0E` | StockFactory-Implementation-RobinhoodStocks | StockFactory | yes | - | `0x074377a78A9710A1D47244f89797718b4f491279` | `0xe6fa8879...02a2c5` | `contracts/StockFactory-Implementation-RobinhoodStocks-0xEe351E53BCe6AAF106428358838197C91e36EE0E/` |

What each one is:

- `0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168` - USDG. `pathFor(USDG)` on the migrator is set, so a creator may pair against it.
- `0x68184C449E1a8f34fA18d289737129FD27B66f8F` - USDG implementation.
- `0xd0601CE157Db5bdC3162BbaC2a2C8aF5320D9EEC` - NVDA tokenized stock. One of the five quotes with a configured path.
- `0xb35490d6f9163DE4F80d88dc75c3516eb64C5aE2` - Implementation behind every tokenized-stock beacon proxy.
- `0x4783C67b63dE2B358Ac5951a7D41F47A38F3C046` - Robinhood's own tokenized-stock factory proxy. Not a hood.fun contract; it mints the assets hood.fun can pair against.
- `0xEe351E53BCe6AAF106428358838197C91e36EE0E` - Implementation behind the stock factory proxy above.

## Uniswap and example launches

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f` | UniswapV2Factory | UniswapV2Factory | yes | - | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0x2fc08b6c...1edaf7` | `contracts/UniswapV2Factory-0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f/` |
| `0xCaf681a66D020601342297493863E78C959E5cb2` | UniswapSwapRouter02 | SwapRouter02 | yes | - | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0xeaa1bf6b...0cdf92` | `contracts/UniswapSwapRouter02-0xCaf681a66D020601342297493863E78C959E5cb2/` |
| `0x72081aDC58bdb794b989d424a65948c16848600d` | HoodToken-FEATHER | HoodToken | yes | - | `0x5Fcc1DF0dC020CF454e742E9a8Ae2554C37A452C` | `0xd015d2ef...78d672` | `contracts/HoodToken-FEATHER-0x72081aDC58bdb794b989d424a65948c16848600d/` |
| `0x67AF360b375DC86aE5Ad620693bfCD916A31600D` | HoodToken-Robin | HoodToken | yes | - | `0x5Fcc1DF0dC020CF454e742E9a8Ae2554C37A452C` | `0xc280d098...99c7f3` | `contracts/HoodToken-Robin-0x67AF360b375DC86aE5Ad620693bfCD916A31600D/` |
| `0x72d74dAd7135d5e183A3d3FBE1E8358bBC143A9b` | UniswapV3Pool-FEATHER-WETH | UniswapV3Pool | yes | - | `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA` | `0xb1b2c151...4adfae` | `contracts/UniswapV3Pool-FEATHER-WETH-0x72d74dAd7135d5e183A3d3FBE1E8358bBC143A9b/` |

What each one is:

- `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f` - Uniswap v2 factory. Constructor argument of every launchpad and the fallback destination if `migrator()` were ever zero. No live coin migrates through it.
- `0xCaf681a66D020601342297493863E78C959E5cb2` - Uniswap `SwapRouter02`, used by the migrator's WETH-to-quote swap and by the app's /swap page.
- `0x72081aDC58bdb794b989d424a65948c16848600d` - Example graduated coin, FEATHER. A community coin, so its creator fees go to holders.
- `0x67AF360b375DC86aE5Ad620693bfCD916A31600D` - Example graduated coin, Robin.
- `0x72d74dAd7135d5e183A3d3FBE1E8358bBC143A9b` - FEATHER's locked Uniswap v3 1% pool.
