# Noxa contract addresses on Robinhood Chain (4663)

Captured 2026-09-03.
Verification flags come from the Blockscout `addresses/<addr>` response, sources from `smart-contracts/<addr>`, per playbook section 4.

There are **three separate Noxa launchpad deployments** on this chain, not one.
They are labelled V1, V2 and noxa.io below; section 5 of `../README.md` explains the split.

| address | role | name | verified | proxy/impl | creator | creation tx | source dir |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0xD9eC2db5f3D1b236843925949fe5bd8a3836FCcB` | V1 launch factory, disabled | unnamed | no | none | `0x7E035Fb048a31e0481b88074557415b1C187242B` (dev.noxa.eth) | `0x5e512a7f9a931c4dc9b5b09d8dd5c80b66968cf393474b21e5613769df656b37` | `LaunchFactoryV1-0xd9ec2db5f3d1b236843925949fe5bd8a3836fccb/` |
| `0x0742D64925E4C78cb1bAFfce2fA1dceBa8Cf133c` | V1 launch factory, second deployment, disabled | unnamed | no | none | `0x7E035Fb048a31e0481b88074557415b1C187242B` | `0xe6366d7e8cccaee0936136b07024adb61074cbed70b1adbcfbbce29b945881b9` | `LaunchFactoryV1Test-0x0742d64925e4c78cb1baffce2fa1dceba8cf133c/` |
| `0x7F03effbd7ceB22A3f80Dd468f67eF27826acD85` | V1 LP locker and fee payer | `LaunchLocker` | yes | none | `0x7E035Fb048a31e0481b88074557415b1C187242B` | `0x359a038b1f9c4295cb9c10011743abe5127fd28796ddede900f78d61c71695f8` | `LaunchLockerV1-0x7f03effbd7ceb22a3f80dd468f67ef27826acd85/` |
| `0xeC4a56061d86955D0Df883efb2E5791d99Ea71f2` | V1 LP locker paired with the second factory | `LaunchLocker` | yes | none | `0x7E035Fb048a31e0481b88074557415b1C187242B` | `0x1a6b676e9f1d491868d29e2a45b62f1b7d0ebe1ed406b505a31bd9a84b66fa56` | `LaunchLockerV1Test-0xec4a56061d86955d0df883efb2e5791d99ea71f2/` |
| `0x9eFdC1A8e6E94f16A228e44f3025E1f346EE0417` | V1 fee collector, the V1 locker's `protocolFeeRecipient` | unnamed | no | none | `0x7E035Fb048a31e0481b88074557415b1C187242B` | `0x338d16cd49e88979f826774bb32cfa88d6eea591e17332419cb0c7fe0cdae303` | `FeeCollector-0x9efdc1a8e6e94f16a228e44f3025e1f346ee0417/` |
| `0xDd84fDdEA1206115B37dbBC0ba5721530E1bA9C5` | **V2 launch factory, live** | unnamed | no | none | `0x63CD726Ccc6560F571861BbAb925f9AF4a6095B2` | `0x1b7e0ad721a7b388b632b1cc8a91ee5189d767661597d99032a656a3f9a19ee3` | `LaunchFactoryV2-0xdd84fddea1206115b37dbbc0ba5721530e1ba9c5/` |
| `0x9A6931E371b62048C7543C7002C99D83685BD44d` | **V2 LP locker and fee payer, live** | `LaunchLocker` | yes | none | `0x63CD726Ccc6560F571861BbAb925f9AF4a6095B2` | `0x5788253e28133dd0da45e30f9a9eb38f0708a91c9091be7b41289d721e3b0867` | `LaunchLockerV2-0x9a6931e371b62048c7543c7002c99d83685bd44d/` |
| `0xA24D48D50Fd7985c6dE816EaF77C1A17D3593BBE` | noxa.io launch factory, live | `LaunchFactory` | yes | none | `0x407Fe47FA03617062E9cD27DCACe8DAB006322d8` | `0xef86f678a24c5424ebfb9d166139bf6ef370e02509c0a25226147a4a6582de81` | `NoxaIO-LaunchFactory-0xa24d48d50fd7985c6de816eaf77c1a17d3593bbe/` |
| `0x90331A631123bD2493Ba962c4304dcb49f3A5d4A` | noxa.io LP locker | `LauncherLocker` | yes | none | `0x407Fe47FA03617062E9cD27DCACe8DAB006322d8` | `0x7a17db9af6c9322a1c52a7d26fcfb5ee297b63abbffc4df53df017a7fb258d18` | `NoxaIO-LauncherLocker-0x90331a631123bd2493ba962c4304dcb49f3a5d4a/` |
| `0x28A5328B61E00dD75F1d0C8A1831A65890E42d36` | noxa.io fee router, three-way split | `FeeRouter` | yes | none | `0x407Fe47FA03617062E9cD27DCACe8DAB006322d8` | `0x0abd644aa80ff852b8821395121266600f1dcbdcb69b195381d9b23ce6141e4b` | `NoxaIO-FeeRouter-0x28a5328b61e00dd75f1d0c8a1831a65890e42d36/` |
| `0xA2dA74831c34D396Be9a42FbeCc54C561184BCb1` | noxa.io protocol fee splitter | `FeeSplitter` | yes | none | `0x407Fe47FA03617062E9cD27DCACe8DAB006322d8` | `0xe9c8f173acfa7acdcfb188a1b47203ec5021774190e82478776e69ea1ebd9862` | `NoxaIO-FeeSplitter-0xa2da74831c34d396be9a42fbecc54c561184bcb1/` |
| `0x020bfC650A365f8BB26819deAAbF3E21291018b4` | V1 launch token, CASHCAT | `LaunchToken` | yes | none | `0xD9eC2db5f3D1b236843925949fe5bd8a3836FCcB` | `0x0e6d23f0babd02ede4aefaa923486591d783e1180c277c71e2f2a39fc74a4661` | `LaunchTokenV1-CASHCAT-0x020bfc650a365f8bb26819deaabf3e21291018b4/` |
| `0x39E0D9057BD9039Cd14590f54dE20B9D3457c56E` | V1 launch token named NOXA, disowned by the team | `LaunchToken` | yes | none | `0xD9eC2db5f3D1b236843925949fe5bd8a3836FCcB` | `0x3ac20c7feab15d4b0e7569ea69704ed83928f18b9cd6a5773dffb2959ad7d0ed` | `LaunchTokenV1-NOXA-0x39e0d9057bd9039cd14590f54de20b9d3457c56e/` |
| `0xBF3e53713a53E9C3d5d1dDc25dd2C65669244663` | V2 launch token, PCC | `LaunchToken` | yes | none | `0xDd84fDdEA1206115B37dbBC0ba5721530E1bA9C5` | `0xa9edad9d3406bbce09b2d0b6944aabca81b90320e935b94580e2f439c08884f5` | `LaunchTokenV2-PCC-0xbf3e53713a53e9c3d5d1ddc25dd2c65669244663/` |
| `0x9852d8ACd4Ace9ef27Aed43b57b741ACFd894663` | V2 launch token, the newest at capture time | `LaunchToken` | yes | none | `0xDd84fDdEA1206115B37dbBC0ba5721530E1bA9C5` | `0x272618b6766f9e51953d4b6f15dd978239d1fa83d2366a35c4adc19edba8cf76` | `LaunchTokenV2-latest-0x9852d8acd4ace9ef27aed43b57b741acfd894663/` |
| `0x0EC130c6258534663b67c131A5a6719B4F614663` | V2 launch token, the decoded launch example | unnamed on chain | no | none | `0xDd84fDdEA1206115B37dbBC0ba5721530E1bA9C5` | `0xc23889a4004a56c5ae7a4fb8e79af69b89ddc903cdf0bca597ff3688dd2a9e2c` | `LaunchTokenV2-MissHim-0x0ec130c6258534663b67c131a5a6719b4f614663/` |
| `0xA70fc67C9F69da90B63a0e4C05D229954574E313` | the CASHCAT 1% Uniswap V3 pool | `UniswapV3Pool` | yes | none | `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA` | `0x0e6d23f0babd02ede4aefaa923486591d783e1180c277c71e2f2a39fc74a4661` | `UniswapV3Pool-CASHCAT-0xa70fc67c9f69da90b63a0e4c05d229954574e313/` |
| `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA` | Uniswap V3 factory, the launch destination | `UniswapV3Factory` | yes | none | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0x8add72fbcad4bf7732336de35dcd06b582c1501d0832c4710a30850a7cff8977` | `UniswapV3Factory-0x1f7d7550b1b028f7571e69a784071f0205fd2efa/` |
| `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3` | position manager that mints the locked LP NFT | `NonfungiblePositionManager` | yes | none | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0x9a8d07e70166be68c325939e2cece936f3ce5b16c580f49291f844d7cd718d4e` | `NonfungiblePositionManager-0x73991a25c818bf1f1128deaab1492d45638de0d3/` |
| `0xCaf681a66D020601342297493863E78C959E5cb2` | router used for the dev buy and for fee conversion | `SwapRouter02` | yes | none | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` | `0xeaa1bf6bd8e86ab33150936414780779800a2aa04a98667f4059ef5dfc0cdf92` | `SwapRouter02-0xcaf681a66d020601342297493863e78c959e5cb2/` |
| `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73` | WETH, the only pair token in every launch config | `TransparentUpgradeableProxy` | yes | EIP-1967, impl `0xC6B81b429797E0f555440b70cD99e032D7AE947e` (`aeWETH`) | `0xE83b11Faa5693E68388785FecA3595C6805dFb9a` | `0x05317cd173ba8e973c7e88aeb7f7e56eb22cf05c12552d4283c993dbb1f56b12` | `WETH-0x0bd7d308f8e1639fab988df18a8011f41eacad73/` |
| `0x4cD00E387622C35bDDB9b4c962C136462338BC31` | Relay depository, used by the app's Bridge tab and by the V2 treasury | `RelayDepository` | yes | none | `0x4e59b44847b379578588920cA78FbF26c0B4956C` (CREATE2 deployer) | `0x3dce830a05a70f0526775bbdeddd2d2df16281f2310582938bad39334f9cc928` | `RelayDepository-0x4cd00e387622c35bddb9b4c962c136462338bc31/` |
| `0x08241c8F618a932dAd58d9ef3098300A7CAFAF2f` | unidentified contract deployed by the V2 owner | unnamed | no | none | `0x63CD726Ccc6560F571861BbAb925f9AF4a6095B2` | `0x05067285e65d7ea6dcd112175a123015bdbb460ff18cec9175415598b55652dc` | `UnknownOwnerContract-0x08241c8f618a932dad58d9ef3098300a7cafaf2f/` |

## Externally owned accounts and named recipients

| address | role | evidence |
| --- | --- | --- |
| `0x7E035Fb048a31e0481b88074557415b1C187242B` | V1 deployer and owner, ENS `dev.noxa.eth` | Blockscout `ens_domain_name`, and @Noxa_Fi published this address as its own deploy address on 2026-02-28 (`socials/02-x-noxa-fi-timeline.md`) |
| `0x71f2F1c2dc94cDaBFE29Cb355119f8683AE0969b` | V1 protocol fee recipient, ENS `treasury.noxa.eth` | `LaunchLockerV1` constructor argument, Blockscout ENS |
| `0x63CD726Ccc6560F571861BbAb925f9AF4a6095B2` | V2 deployer and owner, no ENS | `owner()` on the V2 factory and locker |
| `0x4977307cF8fa1fb5Ce45873717164c872BAD6f23` | V2 treasury and locker `protocolFeeRecipient` | `treasury()` on the V2 factory, `protocolFeeRecipient()` on the V2 locker |
| `0x407Fe47FA03617062E9cD27DCACe8DAB006322d8` | noxa.io deployer and owner | creator of all four noxa.io contracts, `owner()` on the factory |
| `0x667070fA9B91a70E4542AE5B33c1F68721787342` | second noxa.io fee-splitter recipient, 30% | `FeeSplitter` constructor arguments |
| `0xee0a9B71e3def2A5c4d141AD1B97CE0Dd1E87748` | noxa.io burner recipient, one third of every fee collection | `burnerRecipient()` on the noxa.io FeeRouter |
| `0xadA5bb90d0de0bD1b6F3938708F49295A8D1F7CB` | funded the V2 owner 14 minutes before the V2 deployment | `blockscout-newowner-incoming.json`; a high-throughput hot wallet, not identified |

## Quote assets and DEX

Every launch config on every one of the three factories pairs against WETH `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73` at the Uniswap V3 1% fee tier with 200 tick spacing.
No stablecoin or stock-token quote path exists on any of them.
The frontend also names a QuoterV2 at `0x33e885eD0Ec9bF04EcfB19341582aADCb4c8A9E7`, which has code on chain but is a read-only quoting helper and is not in the launch path.
