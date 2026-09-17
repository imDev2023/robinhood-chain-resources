# Pons contract addresses

52 addresses. Chain: Robinhood Chain, id 4663. Captured 2026-09-02 from the Blockscout v2 API and from `eth_call`, `eth_getCode` and `eth_getStorageAt` against the Alchemy archive RPC.
Every row has a directory under `contracts/` holding `metadata.json` plus either verified `sources/` and `abi.json`, or `bytecode.hex` with a selector match written into its `README.md`.

Three things to carry into any integration.

1. A pons v2 hook binds to one factory permanently, so the launchpad is replaced as a whole set rather than upgraded in place (`pages/11-docs-v2.md`, Contracts). Look up which stack a token belongs to; do not assume.
2. Each launch's own bonding curve and token are created per launch. Resolve them from `PonsV2LaunchFactory.getLaunchedToken(token)`, never hardcode them.
3. The vault-factory addresses printed in the PonsVault docs (`pages/18-ponsvault-docs.md`) are one generation behind what the live site calls. Both generations are below, with the evidence in README section 5.3.

Deployer EOAs: `0xda4bCee76B29EFEc9697Fcf663601c2042043968` (pons v1), `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36` (pons v2), `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` (every PonsVault contract), `0x45e9E2A1BB0798dd3722c24f6bb31112dAf6DcD5` (PonsVault v1 registry and vault factory).
Owner of the pons v2 set and of the retired `0xA5aAb3F0…` v1 factory: the Gnosis Safe `0x263ed295dAFaE1d9AAdD6E56c4B6F9f38eE019Dd`, which is also the protocol fee recipient.

## pons v2  (12)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x263ed295dAFaE1d9AAdD6E56c4B6F9f38eE019Dd` | Owner-Safe | `SafeProxy` | yes | `0x29fcB43b46531BcA003ddC8FCB67FFE91900C762` | `0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67` | `0x2077d65951…` | `contracts/Owner-Safe-0x263ed295dAFaE1d9AAdD6E56c4B6F9f38eE019Dd/` |
| `0x6a7a7F7cd83719f47f6fd15b580d24A9A8e6df2f` | V2BondingCurve-Example-COPPERINU | `PonsV2BondingCurve` | yes | - | `0x3711ceA4feaDE896C913C68F01Eda97Cb06D1A42` | `0x376cad198a…` | `contracts/V2BondingCurve-Example-COPPERINU-0x6a7a7F7cd83719f47f6fd15b580d24A9A8e6df2f/` |
| `0x42df2a798f82289E177311362e8f5ccC45c1219c` | V2BuybackVault | `V2BuybackVault` | yes | - | `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36` | `0x4ceb1e809d…` | `contracts/V2BuybackVault-0x42df2a798f82289E177311362e8f5ccC45c1219c/` |
| `0xd3AFEB2a57f70eF218Aa82451c51B2fb0416Ac9e` | V2FeeEscrow | `V2FeeEscrow` | yes | - | `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36` | `0xf0a6e026cb…` | `contracts/V2FeeEscrow-0xd3AFEB2a57f70eF218Aa82451c51B2fb0416Ac9e/` |
| `0xC7819B64A1dAECD7eC19856d026cb14EfBd89046` | V2GraduationExecutor | `V2GraduationExecutor` | yes | - | `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36` | `0x21d0b8698b…` | `contracts/V2GraduationExecutor-0xC7819B64A1dAECD7eC19856d026cb14EfBd89046/` |
| `0xf5695117b99B6f6401e67d4195BD653628176C6C` | V2GraduationGuard | `PonsV2GraduationGuard` | yes | - | `0x7eD598BcEf8bd9Edd8C97A195C6d13f40801EC7e` | `0x3817f297aa…` | `contracts/V2GraduationGuard-0xf5695117b99B6f6401e67d4195BD653628176C6C/` |
| `0xe33E9E479dF8802cb0866d5d05258bEc4cF62948` | V2LaunchAndBuy | `PonsV2LaunchAndBuy` | yes | - | `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36` | `0x4be522d489…` | `contracts/V2LaunchAndBuy-0xe33E9E479dF8802cb0866d5d05258bEc4cF62948/` |
| `0x3711ceA4feaDE896C913C68F01Eda97Cb06D1A42` | V2LaunchDeployer | `PonsV2LaunchDeployer` | yes | - | `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36` | `0x849d092ee4…` | `contracts/V2LaunchDeployer-0x3711ceA4feaDE896C913C68F01Eda97Cb06D1A42/` |
| `0x7eD598BcEf8bd9Edd8C97A195C6d13f40801EC7e` | V2LaunchFactory | `PonsV2LaunchFactory` | yes | - | `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36` | `0x3817f297aa…` | `contracts/V2LaunchFactory-0x7eD598BcEf8bd9Edd8C97A195C6d13f40801EC7e/` |
| `0x267444D099b10fB5Ed7c3Cc7B7c767AdcA574952` | V2LaunchLocker | `V2LaunchLocker` | yes | - | `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36` | `0x7b2f3e9dee…` | `contracts/V2LaunchLocker-0x267444D099b10fB5Ed7c3Cc7B7c767AdcA574952/` |
| `0x5317C0d077D2eEB639448939b930D49c4984B63B` | V2LauncherToken-Example-COPPERINU | `PonsV2LauncherToken` | yes | - | `0x3711ceA4feaDE896C913C68F01Eda97Cb06D1A42` | `0x376cad198a…` | `contracts/V2LauncherToken-Example-COPPERINU-0x5317C0d077D2eEB639448939b930D49c4984B63B/` |
| `0xE5e702641Ea86F4ae6cC3cDaeD2B886f976Be044` | V2MemeHook | `V2MemeHook` | yes | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x220a9825bb…` | `contracts/V2MemeHook-0xE5e702641Ea86F4ae6cC3cDaeD2B886f976Be044/` |

## pons v1  (9)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0xA5aAb3F0c6EeadF30Ef1D3Eb997108E976351feB` | V1LaunchFactory | `PonsLaunchFactory` | yes | - | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` | `0x836c5e41d4…` | `contracts/V1LaunchFactory-0xA5aAb3F0c6EeadF30Ef1D3Eb997108E976351feB/` |
| `0x0c37a24F5D23A486FA692d1500881d698B1F77a4` | V1LaunchFactory-Implementation | `-` | no | - | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` | `0xec8a7f6d96…` | `contracts/V1LaunchFactory-Implementation-0x0c37a24F5D23A486FA692d1500881d698B1F77a4/` |
| `0x02081d3DEc43F816b145672cfC65029948d396AE` | V1LaunchFactory-Legacy | `PonsLaunchFactory` | yes | - | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` | `0x742f17d293…` | `contracts/V1LaunchFactory-Legacy-0x02081d3DEc43F816b145672cfC65029948d396AE/` |
| `0xF4fC0CD27fC8EcF17E55eE4c3f7201897dF3eb75` | V1LaunchFactory-Proxy | `ERC1967Proxy` | yes | `0x02081d3Dec43f816b145672cFc65029948D396AE` | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` | `0x2bef55ac95…` | `contracts/V1LaunchFactory-Proxy-0xF4fC0CD27fC8EcF17E55eE4c3f7201897dF3eb75/` |
| `0x736D76699C26D0d966744cAe304C000d471f7F35` | V1LaunchLocker | `PonsLaunchLocker` | yes | - | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` | `0xb12910e168…` | `contracts/V1LaunchLocker-0x736D76699C26D0d966744cAe304C000d471f7F35/` |
| `0x10f2756e373bab14999fdc9177587d51d30a1cf5` | V1LaunchLocker-Live | `ERC1967Proxy` | yes | `0xd4af1dfB098402182875e7f966c01eaAc512Bd22` | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` | `0x47faab1925…` | `contracts/V1LaunchLocker-Live-0x10f2756e373bab14999fdc9177587d51d30a1cf5/` |
| `0xd4af1dfb098402182875e7f966c01eaac512bd22` | V1LaunchLocker-Live-Implementation | `PonsLaunchLocker` | yes | - | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` | `0x2fd104cc82…` | `contracts/V1LaunchLocker-Live-Implementation-0xd4af1dfb098402182875e7f966c01eaac512bd22/` |
| `0x31ca5E101941A93A7DD6d0497928700625CF54B5` | V1LaunchLocker-Upgradeable | `-` | no | - | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` | `0x6632319ccf…` | `contracts/V1LaunchLocker-Upgradeable-0x31ca5E101941A93A7DD6d0497928700625CF54B5/` |
| `0x39dBED3a2bd333467115dE45665cC57F813C4571` | V1LauncherToken-Example-PONS | `PonsLauncherToken` | yes | - | `0x0c37a24F5D23A486FA692d1500881d698B1F77a4` | `0x1f54f25fec…` | `contracts/V1LauncherToken-Example-PONS-0x39dBED3a2bd333467115dE45665cC57F813C4571/` |

## PonsVault v2  (20)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0xB56579797dD1c6aeA45a6b0F71210a95a3E6D85e` | PV2BuybackBurnVault-Implementation | `-` | no | - | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0xc38f505c78…` | `contracts/PV2BuybackBurnVault-Implementation-0xB56579797dD1c6aeA45a6b0F71210a95a3E6D85e/` |
| `0xdE4670A2Be85Baa3f6a2C1F6443101EA041362aB` | PV2BuybackBurnVaultFactory | `-` | no | `0xB56579797dD1c6aeA45a6b0F71210a95a3E6D85e` | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0x8663f6848e…` | `contracts/PV2BuybackBurnVaultFactory-0xdE4670A2Be85Baa3f6a2C1F6443101EA041362aB/` |
| `0x0Ee057fcb7C5192AF04874D9E023B75E70A93B92` | PV2BuybackHelper | `-` | no | - | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0x167b97506e…` | `contracts/PV2BuybackHelper-0x0Ee057fcb7C5192AF04874D9E023B75E70A93B92/` |
| `0xbE1d309Fe9B6929333e9c16a9751F8c75c7D7735` | PV2RwaVault-Implementation | `-` | no | - | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0xc0ed9f861a…` | `contracts/PV2RwaVault-Implementation-0xbE1d309Fe9B6929333e9c16a9751F8c75c7D7735/` |
| `0xcd5a5eaefbc504ccded34b882889383255d6f9e3` | PV2RwaVault-Implementation-Live | `-` | no | - | `0x64946A452d9e1f5F47Cef448CAB6aD5322f1a9F9` | `0x741e50b2f1…` | `contracts/PV2RwaVault-Implementation-Live-0xcd5a5eaefbc504ccded34b882889383255d6f9e3/` |
| `0xe3847a778bbe852879bcc755f9fa7bfafda5314b` | PV2RwaVaultBeacon | `-` | no | `0xcd5a5EaEfBc504CcDed34B882889383255D6f9e3` | `0x64946A452d9e1f5F47Cef448CAB6aD5322f1a9F9` | `0x741e50b2f1…` | `contracts/PV2RwaVaultBeacon-0xe3847a778bbe852879bcc755f9fa7bfafda5314b/` |
| `0x64946a452d9e1f5f47cef448cab6ad5322f1a9f9` | PV2RwaVaultBeaconOwner | `-` | no | `0xcd5a5EaEfBc504CcDed34B882889383255D6f9e3` | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0x741e50b2f1…` | `contracts/PV2RwaVaultBeaconOwner-0x64946a452d9e1f5f47cef448cab6ad5322f1a9f9/` |
| `0xE3Dd55a527D7408d21f6Cc2aA66A488a0177C164` | PV2RwaVaultFactory | `-` | no | `0xbE1d309Fe9B6929333e9c16a9751F8c75c7D7735` | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0xf41b3ad145…` | `contracts/PV2RwaVaultFactory-0xE3Dd55a527D7408d21f6Cc2aA66A488a0177C164/` |
| `0x7e344f13a42c8ae4C6c7e2D9d48f98deBeCd82aB` | PV2RwaVaultFactory-Live | `-` | no | `0xcd5a5EaEfBc504CcDed34B882889383255D6f9e3` | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0x395179e7b3…` | `contracts/PV2RwaVaultFactory-Live-0x7e344f13a42c8ae4C6c7e2D9d48f98deBeCd82aB/` |
| `0x65b2eAaA7ae4eCC144494070aD6F2A3AD13A47d9` | PV2StakeBurnVault-Implementation | `-` | no | - | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0xd1a6bbd622…` | `contracts/PV2StakeBurnVault-Implementation-0x65b2eAaA7ae4eCC144494070aD6F2A3AD13A47d9/` |
| `0x537483c5B33e2192CfB202d7C50d58975524B047` | PV2StakeBurnVaultFactory | `-` | no | `0x65b2eAaA7ae4eCC144494070aD6F2A3AD13A47d9` | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0x8c828f5f2b…` | `contracts/PV2StakeBurnVaultFactory-0x537483c5B33e2192CfB202d7C50d58975524B047/` |
| `0xC8e0a4fE58918c47F66CF630c6A7205741C11FD4` | PV2StakingVault-Implementation | `-` | no | - | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0xdb05086f1c…` | `contracts/PV2StakingVault-Implementation-0xC8e0a4fE58918c47F66CF630c6A7205741C11FD4/` |
| `0xef9f80d2f51ec6aecab284e778f328e9f0982a6f` | PV2StakingVaultBeacon | `-` | no | `0xC8e0a4fE58918c47F66CF630c6A7205741C11FD4` | `0x1488473464F2C6E6c5C412f05d805c619322E7EB` | `0xd3453bf8a4…` | `contracts/PV2StakingVaultBeacon-0xef9f80d2f51ec6aecab284e778f328e9f0982a6f/` |
| `0x1488473464F2C6E6c5C412f05d805c619322E7EB` | PV2StakingVaultFactory | `-` | no | `0xC8e0a4fE58918c47F66CF630c6A7205741C11FD4` | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0xd3453bf8a4…` | `contracts/PV2StakingVaultFactory-0x1488473464F2C6E6c5C412f05d805c619322E7EB/` |
| `0x3422A17c3A85f751Acb7F978f7333F93ea39CB48` | PV2StakingVaultFactory-Live | `-` | no | `0xC8e0a4fE58918c47F66CF630c6A7205741C11FD4` | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0xb63e77be3f…` | `contracts/PV2StakingVaultFactory-Live-0x3422A17c3A85f751Acb7F978f7333F93ea39CB48/` |
| `0x8b6a7475A35a3cB9B2FE82f7d9778e279F5a0905` | PV2Vault-Example-Staking-PAPERHANDS | `-` | no | `0xC8e0a4fE58918c47F66CF630c6A7205741C11FD4` | `0x3422A17c3A85f751Acb7F978f7333F93ea39CB48` | `0xa2fd067d86…` | `contracts/PV2Vault-Example-Staking-PAPERHANDS-0x8b6a7475A35a3cB9B2FE82f7d9778e279F5a0905/` |
| `0x1770c356eB9312079b9A00e26a8CF4b0a1473dBA` | PV2VaultLauncher | `-` | no | - | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0x9245f5b57d…` | `contracts/PV2VaultLauncher-0x1770c356eB9312079b9A00e26a8CF4b0a1473dBA/` |
| `0xaA9C86049A258D4A076d3eF367F69C231C9746D5` | PV2VaultRegistry | `PonsVaultRegistry` | yes | - | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0xe205d77a7f…` | `contracts/PV2VaultRegistry-0xaA9C86049A258D4A076d3eF367F69C231C9746D5/` |
| `0x9cc3207EC932f65fd83A514633802B4CdBB888E0` | PVSeatSeriesRegistry-A | `-` | no | - | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0x61b76e9886…` | `contracts/PVSeatSeriesRegistry-A-0x9cc3207EC932f65fd83A514633802B4CdBB888E0/` |
| `0x278FFA5A46283A05635A3d33d820D9Cc7D7E67E2` | PVSeatSeriesRegistry-B | `-` | no | - | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` | `0x55d54284b3…` | `contracts/PVSeatSeriesRegistry-B-0x278FFA5A46283A05635A3d33d820D9Cc7D7E67E2/` |

## PonsVault v1  (4)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x3926af4490b4ba5af78D785DD9BA527b383c1B1e` | PV1BuybackBurnVaultFactory | `PonsBuybackBurnVaultFactory` | yes | `0x6396c3cD9eA6fD621e7f41DaD72ca56dFe069414` | `0x45e9E2A1BB0798dd3722c24f6bb31112dAf6DcD5` | `0x993a5b0d42…` | `contracts/PV1BuybackBurnVaultFactory-0x3926af4490b4ba5af78D785DD9BA527b383c1B1e/` |
| `0x4a95863226826701031c282b611493AFfBfA096E` | PV1Vault-Example-VAULT | `BeaconProxy` | yes | `0x6396c3cD9eA6fD621e7f41DaD72ca56dFe069414` | `0x3926af4490B4BA5Af78d785DD9Ba527B383C1B1e` | `0x5d99d7dae0…` | `contracts/PV1Vault-Example-VAULT-0x4a95863226826701031c282b611493AFfBfA096E/` |
| `0x9dDE735093d92EAAD379BE685E62c6d449628f64` | PV1VaultLauncher | `PonsVaultLauncher` | yes | - | `0x45e9E2A1BB0798dd3722c24f6bb31112dAf6DcD5` | `0xa80e85067e…` | `contracts/PV1VaultLauncher-0x9dDE735093d92EAAD379BE685E62c6d449628f64/` |
| `0x770c1AA562f7DfA60934959585DaECf2d9AD32be` | PV1VaultRegistry | `PonsVaultRegistry` | yes | - | `0x45e9E2A1BB0798dd3722c24f6bb31112dAf6DcD5` | `0x9b0972682c…` | `contracts/PV1VaultRegistry-0x770c1AA562f7DfA60934959585DaECf2d9AD32be/` |

## Uniswap  (7)

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0x000000000022D473030F116dDEE9F6B43aC78BA3` | Permit2 | `Permit2` | yes | - | - | - | `contracts/Permit2-0x000000000022D473030F116dDEE9F6B43aC78BA3/` |
| `0x1f7d7550B1b028F7571e69A784071F0205FD2efa` | UniswapV3Factory | `UniswapV3Factory` | yes | - | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0x8add72fbca…` | `contracts/UniswapV3Factory-0x1f7d7550B1b028F7571e69A784071F0205FD2efa/` |
| `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3` | UniswapV3PositionManager | `NonfungiblePositionManager` | yes | - | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0x9a8d07e701…` | `contracts/UniswapV3PositionManager-0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3/` |
| `0xCaf681a66D020601342297493863E78C959E5cb2` | UniswapV3SwapRouter02 | `SwapRouter02` | yes | - | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0xeaa1bf6bd8…` | `contracts/UniswapV3SwapRouter02-0xCaf681a66D020601342297493863E78C959E5cb2/` |
| `0x8366a39CC670B4001A1121B8F6A443A643e40951` | UniswapV4PoolManager | `PoolManager` | yes | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x4fb28d4935…` | `contracts/UniswapV4PoolManager-0x8366a39CC670B4001A1121B8F6A443A643e40951/` |
| `0x58daec3116aae6D93017bAAea7749052E8a04fA7` | UniswapV4PositionManager | `PositionManager` | yes | - | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | `0x228c18ada6…` | `contracts/UniswapV4PositionManager-0x58daec3116aae6D93017bAAea7749052E8a04fA7/` |
| `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73` | WETH | `TransparentUpgradeableProxy` | yes | `0xC6B81b429797E0f555440b70cD99e032D7AE947e` | `0xE83b11Faa5693E68388785FecA3595C6805dFb9a` | `0x05317cd173…` | `contracts/WETH-0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73/` |

## Addresses seen but not given a directory

| address | what it is | evidence |
| --- | --- | --- |
| `0x49BbF2b70955Fb3a106e084D4BFDa92d334573d2` | EOA. `V2MemeHook.feeSweepOperator()` | on-chain read |
| `0x15AC1f0b2C1e10E1cCB4dF2eD24E0D0D9dF2f060` | EOA. Treasury of the VAULT token's Buyback and Burn vault | `pages/23-ponsvault-token-vault.md` |
| `0x1b1eA76A09C5f3cb18F656aD08a90f339FdE4B1F` | An EIP-7702 delegated user account, not project infrastructure. The `from` of the worked launch example | `_raw/blockscout-tx/0xa2fd067d…json` |
| `0x35b4E2C475eced13C918DdBa57fec750bE225E49` | The PAPERHANDS bonding curve, created inside the worked launch example | same tx |
| `0x0a51eb39037e904BD2A21aD454539f06413Ca35b` | The PAPERHANDS token | same tx |
| 42 Vault Seats per-series contracts across 6 series | Enumerable from either seats registry with `0xdc22cb6a(uint256)` | README section 5.4 |
| 25 approved v2 quote assets: ETH, USDG and 23 tokenized stocks | Listed in full in README section 4.2 | `_raw/api/pv-v2-status.json` |

