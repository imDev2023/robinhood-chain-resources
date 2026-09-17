# Flap contract addresses on Robinhood Chain (chain id 4663)

Captured 2026-09-02 and 2026-09-03 from `https://robinhoodchain.blockscout.com/api/v2` and live `eth_call`.

Grouped by role.
Every row has a directory under `contracts/` with a `README.md`, and either verified `sources/` or `bytecode.hex` plus a decoded selector list.


## Launch and trade

| address | role | contract name | verified | proxy / impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09` | Portal, protocol entry point | `TransparentUpgradeableProxy` | yes | eip1967 to `0xa3b96Df56f254B926B17D5f7FB6CD858c216ff44` | `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05` | `0x66ab432afa53aca015e57d94b4c0057d02e5a02600343dff6e66e6ea1281cdbc` | `contracts/FlapCore-0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09/` |
| `0x0C84dD8B8Ea905542364a36546A611b6F299CA55` | Portal curve dispatch module, takes the 1% fee | `unnamed` | no | no | `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05` | `0xf24c3969bc37133b01a23639c289070cfa150c3999fcc65947e0be24dc1a4bea` | `contracts/PortalDispatchCurve-0x0C84dD8B8Ea905542364a36546A611b6F299CA55/` |
| `0xA90B476c97c7d57582236e4BFA844fE400D517c2` | Portal trade dispatch module | `unnamed` | no | no | `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05` | `0xeda59ac0e12710a8d27d421e94b50a5833edd8c05f44a7458d366b3220633bba` | `contracts/PortalDispatchTrade-0xA90B476c97c7d57582236e4BFA844fE400D517c2/` |
| `0xa3b96df56f254b926b17d5f7fb6cd858c216ff44` | Portal implementation | `unnamed` | no | no | `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05` | `0x8c8ab66539161c025f74113884574deafe610d81a1393cd7e08b624c14436bbe` | `contracts/PortalImpl-0xa3b96df56f254b926b17d5f7fb6cd858c216ff44/` |
| `0xe5F72d6F9dDAB579317A4FeBD2FfB8ec3d73497b` | Portal non-ETH quote swap module | `unnamed` | no | no | `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05` | `0x64577d302341209b7e79c8ec92068b17c7da4a06b3ec4e9d583ee7b92169b4ec` | `contracts/PortalQuoteSwapModule-0xe5F72d6F9dDAB579317A4FeBD2FfB8ec3d73497b/` |
| `0xe9F7AB7DE8FB8756acbB6a1cd13316a43308197B` | VaultPortal, vault-backed launch entry point | `TransparentUpgradeableProxy` | yes | eip1967 to `0xe5789d9D5616dd8eC66DE95BB31A29aC1c847769` | `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05` | `0x9b347fe0179ba6e4d61a0633dee6324dc2eee9ab61df312fc47c55e1a758af6c` | `contracts/VaultPortal-0xe9F7AB7DE8FB8756acbB6a1cd13316a43308197B/` |
| `0xe5789d9d5616dd8ec66de95bb31a29ac1c847769` | VaultPortal implementation, carries IPortal.sol | `VaultPortal` | yes | no | `0x8187F13ed6C7C9554AfE4Dd4C4D4960174846063` | `0x8ce1948f451d5215a35c555b82aab70921d4bd08e67ccb8ee03a2dc68b2af669` | `contracts/VaultPortalImpl-0xe5789d9d5616dd8ec66de95bb31a29ac1c847769/` |

## Bonding curve

| address | role | contract name | verified | proxy / impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0xE80C7e58d392253a16A82f4A535E79679632dFaf` | Curve pair for $PRISM, example | `BeaconProxy` | no | no | `0x0d1eBb179cdbcA88D74C923C4255Cb2B17474AfD` | `0xc0d404e546520ffd8db7dd700bb8e8f9f93f0702b59f0284a6ae21e8033e5bef` | `contracts/FlapCurvePair-PRISM-example-0xE80C7e58d392253a16A82f4A535E79679632dFaf/` |
| `0xad683374A2013CBf9680a12E7e77Ccf2Ebf39e0d` | Curve pair, example | `BeaconProxy` | no | eip1967_beacon to `0xF9ADbAfF5610FFCe26855747049c69973A8176e5` | `0x0d1eBb179cdbcA88D74C923C4255Cb2B17474AfD` | `0xcf12b7e5eff03861824b465cc39129ed6fcf32a0ffab500042e1257c4b5b3778` | `contracts/Pair-ETF-0xad683374A2013CBf9680a12E7e77Ccf2Ebf39e0d/` |
| `0x0d1eBb179cdbcA88D74C923C4255Cb2B17474AfD` | FlapCurvePairFactory | `unnamed` | no | no | `0x8187F13ed6C7C9554AfE4Dd4C4D4960174846063` | `0x578bade084be67a9722e8bcc1ce7472ca1578ab1ebbb07e407d0927c172756e3` | `contracts/PairFactory-0x0d1eBb179cdbcA88D74C923C4255Cb2B17474AfD/` |
| `0xF9ADbAfF5610FFCe26855747049c69973A8176e5` | FlapCurvePair beacon implementation | `unnamed` | no | no | `0x0d1eBb179cdbcA88D74C923C4255Cb2B17474AfD` | `0x578bade084be67a9722e8bcc1ce7472ca1578ab1ebbb07e407d0927c172756e3` | `contracts/PairImpl-0xF9ADbAfF5610FFCe26855747049c69973A8176e5/` |

## Token

| address | role | contract name | verified | proxy / impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x7777C8743C88B3aff3cf262135beF2c8b2e83333` | FlapTaxTokenV3 implementation, vanity 7777 | `FlapTaxTokenV3` | yes | no | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x09355cf1d4b5791d36388442870bffa30f9891f1ed0a13dd6713c2a54a01e09d` | `contracts/FlapTaxTokenV3-0x7777C8743C88B3aff3cf262135beF2c8b2e83333/` |
| `0x88882688a067FE97E11C2185b996286e53132222` | FlapNonTaxToken implementation, vanity 8888 | `FlapNonTaxToken` | yes | no | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x8b9f772c5d8139fd3394c5be0f81d71c0767a58a7a105bfaa534742c461f34b1` | `contracts/StandardTokenImpl-0x88882688a067FE97E11C2185b996286e53132222/` |
| `0x862cDCCB67C8a22FDb247D09A08B1dAD09447777` | $moon, live Tax Token V3 clone | `mooncat` | yes | eip1167 to `0x7777C8743C88B3aff3cf262135beF2c8b2e83333` | `0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09` | `0x1831e2cd89cd8263bf6dc30f561b5bff242db1f7c67d1bc6ae213e0f3bee1c40` | `contracts/Token-mooncat-example-0x862cDCCB67C8a22FDb247D09A08B1dAD09447777/` |

## Tax

| address | role | contract name | verified | proxy / impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0xA9af2890153E6B9731232b4cB7B0F712179D7FE8` | DividendClaimHelper | `TransparentUpgradeableProxy` | yes | eip1967 to `0x72AbECEA09FA12454672C5CB0A195E9bb5608d1B` | `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05` | `0xb3d81b592bf6bff647f2ee21adb06954b4c8095b8e8bb9e5b795afac19604354` | `contracts/DividendClaimHelper-0xA9af2890153E6B9731232b4cB7B0F712179D7FE8/` |
| `0x72abecea09fa12454672c5cb0a195e9bb5608d1b` | DividendClaimHelper implementation | `unnamed` | no | no | `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05` | `0xb4b8a134a17664a3d10998439886a778039b63553f3df17c823fca66ea252ba0` | `contracts/DividendClaimHelperImpl-0x72abecea09fa12454672c5cb0a195e9bb5608d1b/` |
| `0x95Ddb566F9B48e3E9Ac53E2bDC02dE28DD5Dafd7` | Dividend implementation | `Dividend` | yes | no | `0x8187F13ed6C7C9554AfE4Dd4C4D4960174846063` | `0x51e6a049625c464de1d590d60a50f3ce779d4e68d728871d09c47f5e75fd5918` | `contracts/DividendImpl-0x95Ddb566F9B48e3E9Ac53E2bDC02dE28DD5Dafd7/` |
| `0xAd5B720aEa26151af334866712b5A8a85377afa0` | Dividend clone for one tax token | `unnamed` | yes | eip1167 to `0x95Ddb566F9B48e3E9Ac53E2bDC02dE28DD5Dafd7` | `0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09` | `0xcf12b7e5eff03861824b465cc39129ed6fcf32a0ffab500042e1257c4b5b3778` | `contracts/DividendTracker-0xAd5B720aEa26151af334866712b5A8a85377afa0/` |
| `0x35Bae0b77753a586f68f9C4CD0E8d1a468169031` | SwapRegistry | `TransparentUpgradeableProxy` | yes | eip1967 to `0x789cab818E776568793618CCAd8D0b8087f0127D` | `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05` | `0xdff3defd5074a2a608141084ea0b7e4eca544e7921b91aca8bb877998ca44384` | `contracts/SwapRegistry-0x35Bae0b77753a586f68f9C4CD0E8d1a468169031/` |
| `0x789cab818e776568793618ccad8d0b8087f0127d` | SwapRegistry implementation | `unnamed` | no | no | `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05` | `0x69f7fdbe23fca7003ee57e88ed00415d9ff73de1d3cb9f7f6acb0bf15018cb47` | `contracts/SwapRegistryImpl-0x789cab818e776568793618ccad8d0b8087f0127d/` |
| `0xCaf681a66D020601342297493863E78C959E5cb2` | Uniswap SwapRouter02, used by the tax path | `SwapRouter02` | yes | no | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0xeaa1bf6bd8e86ab33150936414780779800a2aa04a98667f4059ef5dfc0cdf92` | `contracts/SwapRouter02-0xCaf681a66D020601342297493863E78C959E5cb2/` |
| `0xd62198DC5aA79754D36DD07B90393C96f2B72EB4` | TaxProcessor clone for one tax token | `unnamed` | yes | eip1167 to `0x92C7ed364CB74B13D0C0168CDb2195e569811dF2` | `0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09` | `0xcf12b7e5eff03861824b465cc39129ed6fcf32a0ffab500042e1257c4b5b3778` | `contracts/TaxProcessor-0xd62198DC5aA79754D36DD07B90393C96f2B72EB4/` |
| `0x92C7ed364CB74B13D0C0168CDb2195e569811dF2` | TaxProcessor implementation, the tax split | `TaxProcessorUniV2` | yes | no | `0x8187F13ed6C7C9554AfE4Dd4C4D4960174846063` | `0x5a4284db8b09e15805acd12a535a04ac791da13aa6ea9525657b75f17f2a6641` | `contracts/TaxProcessorUniV2Impl-0x92C7ed364CB74B13D0C0168CDb2195e569811dF2/` |
| `0xb10bD2672aE63735d677164A54B573a016f0203C` | TaxTokenHelper | `TransparentUpgradeableProxy` | yes | eip1967 to `0x4F0511d8a00a74d8DdB4bFB3a97282e4A39252Af` | `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05` | `0x2f95523576ec890c5f82b1e87504562647d666e6cc14023dbd9235efd77a5cf2` | `contracts/TaxTokenHelper-0xb10bD2672aE63735d677164A54B573a016f0203C/` |
| `0x4f0511d8a00a74d8ddb4bfb3a97282e4a39252af` | TaxTokenHelper implementation | `TaxTokenHelper` | yes | no | `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05` | `0xac8f0d87d468dda11b0090bb115f5994e20568f8b6d0188adf034a6296fdb2cd` | `contracts/TaxTokenHelperImpl-0x4f0511d8a00a74d8ddb4bfb3a97282e4a39252af/` |

## Automation

| address | role | contract name | verified | proxy / impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0xD3421B1b616a72bB88993A0cf75709BB8D532cc1` | TriggerService automation | `TransparentUpgradeableProxy` | yes | eip1967 to `0xFEc4Ee5ac7F92938eF1E88C094a939195394ee4f` | `0x8187F13ed6C7C9554AfE4Dd4C4D4960174846063` | `0x47ac3f38d6a3821d1b421fda2335d2485c94b3f49dceca87f1eb0e6a21fbfa04` | `contracts/TriggerService-0xD3421B1b616a72bB88993A0cf75709BB8D532cc1/` |
| `0xfec4ee5ac7f92938ef1e88c094a939195394ee4f` | TriggerService implementation | `unnamed` | no | no | `0x8187F13ed6C7C9554AfE4Dd4C4D4960174846063` | `0x67dbcda7baa8382a08d1573ef556e29b7295b890a942cac3e66115e84213fbc3` | `contracts/TriggerServiceImpl-0xfec4ee5ac7f92938ef1e88c094a939195394ee4f/` |

## Graduation

| address | role | contract name | verified | proxy / impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f` | Uniswap V2 factory, graduation destination | `UniswapV2Factory` | yes | no | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0x2fc08b6c72d5f2120cec9f3be8ed0b45c210d51adbc87f33b2135886681edaf7` | `contracts/UniswapV2Factory-0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f/` |
| `0x55aED1a1406Ad8821B3CD0b3a189757aCF007447` | Graduated $moon pair, 99.93% LP burned | `Uniswap V2` | yes | no | `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f` | `0x7bf1c44f42a0ce53f3ea3fcc5b184cd39aaca741eb454ce19afd14a31e77b584` | `contracts/UniswapV2Pool-MOON-0x55aED1a1406Ad8821B3CD0b3a189757aCF007447/` |

## Governance

| address | role | contract name | verified | proxy / impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0xa4A727E0918cf9B39639Fc4cB7D742d39C5352a4` | Flap fee Safe, 2 of 3, and Portal DEFAULT_ADMIN | `SafeProxy` | yes | master_copy to `0x29fcB43b46531BcA003ddC8FCB67FFE91900C762` | `0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67` | `0x2a415435bde7faaa32dba55a8853a452148f675f2ab9825ea139b10c1ece4db5` | `contracts/FeeSafe-0xa4A727E0918cf9B39639Fc4cB7D742d39C5352a4/` |
| `0x49b0f3b3c2b4f92000dd8e5b89efbf4956ed8ddb` | ProxyAdmin for TriggerService and DividendClaimHelper | `ProxyAdmin` | no | no | `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05` | `0x86a9f1736cfc3f8fa985d6929dbcd698634332a1ae66ae2848d7937e9fa90cc9` | `contracts/ProxyAdmin-Aux-0x49b0f3b3c2b4f92000dd8e5b89efbf4956ed8ddb/` |
| `0x21f7f9b33dfd0dbc3a94c0efa79f1546a1391ff5` | ProxyAdmin for Portal, VaultPortal, SwapRegistry, TaxTokenHelper | `ProxyAdmin` | yes | no | `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05` | `0x9686fdae7a9170361b424b48582ca26afa8fff2facd27c7ed776872a9f4192d0` | `contracts/ProxyAdmin-Core-0x21f7f9b33dfd0dbc3a94c0efa79f1546a1391ff5/` |
| `0xc68f29bfe2f6c3d95adb5685592b9f86680968f2` | Owner of ProxyAdmin-Core, Safe 2 of 5 | `SafeProxy` | yes | master_copy to `0x29fcB43b46531BcA003ddC8FCB67FFE91900C762` | `0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67` | `0xeaf8c9a66e90d90ec8da8d0b9f48ac483d345c50c708650878e197ff9cf748b7` | `contracts/UpgradeSafe-0xc68f29bfe2f6c3d95adb5685592b9f86680968f2/` |

## Third party

| address | role | contract name | verified | proxy / impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0xd35e36Df9fDE27293dA1623c99FCd013464D3a80` | SinjohFlapAdapter clone, third-party launcher (misnamed dir) | `unnamed` | yes | eip1167 to `0x4c34af31ef8962317497Cc558612a48443971243` | `0x77748D07CAD323A7f6EFa54968aCF69de743be61` | `0x4d12f1da137ba48434dd065099f047ff3e3b3c64dd478f902b1ac2d8b07cfac2` | `contracts/Portal-0xd35e36Df9fDE27293dA1623c99FCd013464D3a80/` |
| `0x77748D07CAD323A7f6EFa54968aCF69de743be61` | SinjohFlapAdapterFactory | `SinjohFlapAdapterFactory` | yes | basic_implementation to `0x4c34af31ef8962317497Cc558612a48443971243` | `0x1A0925c9651836281FFe3EBD1D99d5D9739967EA` | `0x89e4b482f1e8666d0727c5bac134f50f1cce0cf08edee4e643963e36381e4c16` | `contracts/SinjohFlapAdapterFactory-0x77748D07CAD323A7f6EFa54968aCF69de743be61/` |
| `0x4c34af31ef8962317497Cc558612a48443971243` | SinjohFlapAdapter implementation | `SinjohFlapAdapter` | yes | no | `0x77748D07CAD323A7f6EFa54968aCF69de743be61` | `0x89e4b482f1e8666d0727c5bac134f50f1cce0cf08edee4e643963e36381e4c16` | `contracts/SinjohFlapAdapterImpl-0x4c34af31ef8962317497Cc558612a48443971243/` |

## Quote asset

| address | role | contract name | verified | proxy / impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0xfB5b5778d45AE47F15323fb59B666c655174A79C` | HOODon quote token, Ondo-tokenized HOOD | `ClonableBeaconProxy` | yes | eip1967_beacon to `0xEf3b461697C6bd38c5458AFa31e1250C98fd0f5F` | `0xc302CcbC357A39a7231A681C61943b2DC032Dd51` | `0x3e33db4b2a46c43bfd36f57bec3ae661a1bfd4f3723c7fcbb8b12f1b0865d313` | `contracts/HOODon-0xfB5b5778d45AE47F15323fb59B666c655174A79C/` |

## Chain

| address | role | contract name | verified | proxy / impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73` | Wrapped ETH | `TransparentUpgradeableProxy` | yes | eip1967 to `0xC6B81b429797E0f555440b70cD99e032D7AE947e` | `0xE83b11Faa5693E68388785FecA3595C6805dFb9a` | `0x05317cd173ba8e973c7e88aeb7f7e56eb22cf05c12552d4283c993dbb1f56b12` | `contracts/WETH-0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73/` |
| `0xc6b81b429797e0f555440b70cd99e032d7ae947e` | aeWETH implementation | `aeWETH` | yes | no | `0xE83b11Faa5693E68388785FecA3595C6805dFb9a` | `0x05317cd173ba8e973c7e88aeb7f7e56eb22cf05c12552d4283c993dbb1f56b12` | `contracts/WETHImpl-0xc6b81b429797e0f555440b70cd99e032d7ae947e/` |
