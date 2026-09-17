<!-- source: https://developers.uniswap.org/docs/liquidity/liquidity-launchpad/deployments | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/liquidity/liquidity-launchpad/deployments.md (native markdown) -->
# Deployments (/docs/liquidity/liquidity-launchpad/deployments)

Find Uniswap Liquidity Launchpad, CCA, and strategy contract deployments across supported chains.

> [!NOTE]
> All Liquidity Launchpad deployment addresses are also available on the unified [Deployments](/deployments) page and its [deployments.json](/deployments.json) feed.

## ContinuousClearingAuctionFactory
The CCA factory has no constructor parameters so it is deployed to the same address across all compatible chains: Ethereum, Unichain, Base, Arbitrum, Robinhood Chain, and Sepolia. Versions before v2.0.0 should no longer be used or integrated with.

| Version | Address                                    | Commit Hash                              |
| ------- | ------------------------------------------ | ---------------------------------------- |
| v2.1.0  | 0x000000001F26a0044BaA66024e7b6599c61963F8 | 7d7602d257733315434570f2a0c2f94f1c7b207a |
| v2.0.0  | 0x00cCa200BF124dBfA848937c553864f4B4CE0632 | aee9bca51c92c24eb24a00d75ad98e678bac61d3 |

## LiquidityLauncher
The LiquidityLauncher is a singleton contract that shares one address across all supported networks except Robinhood Chain. Robinhood Chain runs the newer v3.2.0 deployment at its own address.

| Version | Chain                                                                         | Address                                    | Commit Hash                              |
| ------- | ----------------------------------------------------------------------------- | ------------------------------------------ | ---------------------------------------- |
| v3.0.0  | Ethereum, Base, Unichain, Arbitrum, Avalanche, X Layer, Sepolia, Base Sepolia | 0x00004c4ccc709Ef590F7C81102C0689F0263D4e9 | 3a3103543f50a13a0ae52a253bb98a925d72146f |
| v3.2.0  | Robinhood Chain                                                               | 0x0000FffFBE8efE702c8703aE3477FF5dE3d319C0 | dd8769cd45c0e9450e928513ee129b0af74f7f32 |

## LBPStrategy
The LBPStrategy contract is deployed to a different address on each chain because it must land on a valid v4 hook address.

## Current
| Version | Chain           | Address                                    | Commit Hash                              |
| ------- | --------------- | ------------------------------------------ | ---------------------------------------- |
| v3.1.0  | Ethereum        | 0x49380c4EfaB1b491006aF7FabAB8B3459F0E6000 | 873cbb23c5019a795193c5ad561edff2f78ba5a3 |
| v3.1.0  | Base            | 0x34385dD739FE5464892BF0bA4CC42492804dA000 | 873cbb23c5019a795193c5ad561edff2f78ba5a3 |
| v3.1.0  | Unichain        | 0x298eA05D0356B2Ae5cCAa3169E471783ee9EA000 | 873cbb23c5019a795193c5ad561edff2f78ba5a3 |
| v3.1.0  | Arbitrum        | 0x8Af0775a70Cc94D71DFc0fE809435e833F2Fe000 | 873cbb23c5019a795193c5ad561edff2f78ba5a3 |
| v3.1.1  | Robinhood Chain | 0x05d552391067389EE44fec3924157ed33F976000 | 5ef0262b8e191360a212aac864a525dcf7a06605 |
| v3.1.0  | Avalanche       | 0x57BD0A9Cd933c89Ba55e086D53031367b6406000 | 873cbb23c5019a795193c5ad561edff2f78ba5a3 |
| v3.1.0  | X Layer         | 0x58DF162fF41e5cB42B8515f75F90C1841938A000 | 873cbb23c5019a795193c5ad561edff2f78ba5a3 |
| v3.1.0  | Ink             | 0xd749FAe4D01E8fd85B9e26555cB300018aFEA000 | 873cbb23c5019a795193c5ad561edff2f78ba5a3 |
| v3.1.0  | Sepolia         | 0x96641d91e223c766F45b19d09494F5925C3cE000 | 873cbb23c5019a795193c5ad561edff2f78ba5a3 |
| v3.1.0  | Base Sepolia    | 0xB06428b62c259eE982cE3D9BED47391dC9A5E000 | 873cbb23c5019a795193c5ad561edff2f78ba5a3 |

## v3.0.0 (deprecated)
| Chain           | Address                                    |
| --------------- | ------------------------------------------ |
| Avalanche       | 0xcAcd77134b072b4AD5621f585b0b422C6Da4E000 |
| X Layer         | 0x95bcb80e3804a085d23778F2956c305d6488e000 |
| Robinhood Chain | 0x095e38a2135aeBcfFa98A5B6911591937f912000 |

## InstantLaunchStrategy
The InstantLaunchStrategy launches a fixed-supply token directly into a hookless native ETH Uniswap v4 pool as a single-sided LP position.

One deployment supports creator fees: it splits the fees from the pool position between auto-compounding and the creator. The other does not share funds with a creator. Launches that select a creator fee in the interface use the first deployment; launches without a creator fee use the second.

| Version | Chain           | Creator Fees | Address                                    | FeeSplitter                                | Commit Hash                              |
| ------- | --------------- | ------------ | ------------------------------------------ | ------------------------------------------ | ---------------------------------------- |
| v3.2.0  | Robinhood Chain | Yes          | 0x23f8209572b4a1C2AD88A42749E830791Fb027f1 | 0xeFF166AAf189323c58dc27eD1206EB2C37FaACDf | dd8769cd45c0e9450e928513ee129b0af74f7f32 |
| v3.2.0  | Robinhood Chain | No           | 0xAD44D55E7f8337C3cE113fBb591486E85be104b2 | 0x222D6d4f1ce59b0d48D5505114eC8Addc90A4359 | dd8769cd45c0e9450e928513ee129b0af74f7f32 |

## UniversalRouterStrategy
The UniversalRouterStrategy runs a caller-supplied Universal Router route, so a launch and a buy fit in one transaction.

| Version | Chain           | Address                                    | Commit Hash                              |
| ------- | --------------- | ------------------------------------------ | ---------------------------------------- |
| v3.2.0  | Robinhood Chain | 0x1242c9439d589cAE85E121B1f79f2aF51e91DCEE | dd8769cd45c0e9450e928513ee129b0af74f7f32 |

## InitializerHook
The InitializerHook is a base hook that restricts pool initialization to a preset address. Caller-specified hooks must inherit it to be used in LBPStrategy.

| Version | Chain           | Address                                    | Commit Hash                              |
| ------- | --------------- | ------------------------------------------ | ---------------------------------------- |
| v3.1.1  | Robinhood Chain | 0xD462a559337859369EF271814851A18F496ba000 | 5ef0262b8e191360a212aac864a525dcf7a06605 |

## TokenSplitter
The TokenSplitter is a minimal strategy that splits a token distribution across multiple recipients, such as EOAs or multisigs, pulling tokens directly from the caller so it never holds funds. It shares one address across all supported networks except Robinhood Chain, which runs the newer v3.2.0 deployment at its own address.

| Version | Chain                                                                         | Address                                    | Commit Hash                              |
| ------- | ----------------------------------------------------------------------------- | ------------------------------------------ | ---------------------------------------- |
| v3.0.0  | Ethereum, Base, Unichain, Arbitrum, Avalanche, X Layer, Sepolia, Base Sepolia | 0x8B7DCeb5639DB986FCf86606C74e6300C40FE3cd | 3a3103543f50a13a0ae52a253bb98a925d72146f |
| v3.2.0  | Robinhood Chain                                                               | 0x4F5E3FBb9745358A92Da5674305FAb8D2B8a73cE | dd8769cd45c0e9450e928513ee129b0af74f7f32 |

## FeeSplitter
The FeeSplitter permanently holds v4 native ETH LP positions, permissionlessly collects their fees, and pushes independent fixed splits for the native ETH and token side, set immutably at deployment. Multiple deployments may exist on the same chain.

| Version | Chain           | Address                                    | Fee Splits                                                                                                                                             | Commit Hash                              |
| ------- | --------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------- |
| v3.2.0  | Robinhood Chain | 0xeFF166AAf189323c58dc27eD1206EB2C37FaACDf | [UERC20BeneficiaryVault](#uerc20beneficiaryvault): 40% native ETH; [CompoundingClaimRecipient](#compoundingclaimrecipient): 60% native ETH, 100% token | dd8769cd45c0e9450e928513ee129b0af74f7f32 |
| v3.2.0  | Robinhood Chain | 0x222D6d4f1ce59b0d48D5505114eC8Addc90A4359 | [CompoundingClaimRecipient](#compoundingclaimrecipient): 100% native ETH, 100% token                                                                   | dd8769cd45c0e9450e928513ee129b0af74f7f32 |

## UERC20BeneficiaryVault
The UERC20BeneficiaryVault is a BeneficiaryVault that holds fee shares for registered beneficiaries. Registration mints a transferable ERC-721 whose holder can claim, and the creator of a UERC20 token can register an unregistered position via the token's graffiti.

| Version | Chain           | Address                                    | Commit Hash                              |
| ------- | --------------- | ------------------------------------------ | ---------------------------------------- |
| v3.2.0  | Robinhood Chain | 0xd35E9CA72F64C7F93BE30fad67524323396B36D7 | dd8769cd45c0e9450e928513ee129b0af74f7f32 |

## CompoundingClaimRecipient
The CompoundingClaimRecipient pays claimed fee amounts to an executor contract, which must compound them back into the claimed position as liquidity.

| Version | Chain           | Address                                    | Commit Hash                              |
| ------- | --------------- | ------------------------------------------ | ---------------------------------------- |
| v3.2.0  | Robinhood Chain | 0xf9526Dd3361fe0ba6b7a99533ed471D3E808E99a | dd8769cd45c0e9450e928513ee129b0af74f7f32 |

## BuybackAndBurnClaimRecipient
The BuybackAndBurnClaimRecipient pays claimed fee amounts to an executor contract, then pulls a fixed amount of the position's token from that executor and sends it to the burn address. The burn amount is fixed at deployment and the same for every call; read the live value from `minCurrency1BurnAmount()`. See [Buyback and Burn](/docs/liquidity/liquidity-launchpad/guides/buyback-and-burn).

| Version | Chain           | Address                                    | Burn Amount                      | Commit Hash                              |
| ------- | --------------- | ------------------------------------------ | -------------------------------- | ---------------------------------------- |
| v3.2.0  | Robinhood Chain | 0xa1ba4CC12654D2b188e3ba77dc86c75cA47f1A4e | 500,000 tokens (0.05% of supply) | dd8769cd45c0e9450e928513ee129b0af74f7f32 |

## VestingClaimRecipient
The VestingClaimRecipient holds the beneficiary NFT for a renounced position, claims that position's fees from an allowlisted beneficiary vault, and releases them to a downstream recipient at a capped rate per block. Both the rate and the downstream recipient are fixed at deployment. See [Buyback and Burn](/docs/liquidity/liquidity-launchpad/guides/buyback-and-burn).

| Chain           | Address                                    | Releases To                                                   | Commit Hash                              |
| --------------- | ------------------------------------------ | ------------------------------------------------------------- | ---------------------------------------- |
| Robinhood Chain | 0xeF451B293ED8C61d20f7d13ef336a496F0cc2c26 | [BuybackAndBurnClaimRecipient](#buybackandburnclaimrecipient) | 0b5ee0527af94a8c635b6af5b334a7d17c5ed719 |

## UERC20Factory
The UERC20Factory is a factory contract for new UERC20 tokens.

| Network  | Address                                    | Commit Hash                              | Version |
| -------- | ------------------------------------------ | ---------------------------------------- | ------- |
| Ethereum | 0x000000e200088D55C39a11F609E5F667729ad49b | de5bacd215f6aae50e524297c18fcf78b69b6312 | v2.0.0  |
| Sepolia  | 0x000000e200088D55C39a11F609E5F667729ad49b | de5bacd215f6aae50e524297c18fcf78b69b6312 | v2.0.0  |

## USUPERC20Factory
The USUPERC20Factory is a factory contract for Superchain compatible UERC20 tokens, deployed to the same address across Superchain compatible L2s.

| Network          | Address                                    | Commit Hash                              | Version |
| ---------------- | ------------------------------------------ | ---------------------------------------- | ------- |
| Base             | 0xeEeeEEE204Afb6BABb1287ffed52cCD6BA0b0fb2 | de5bacd215f6aae50e524297c18fcf78b69b6312 | v2.0.0  |
| Base Sepolia     | 0xeEeeEEE204Afb6BABb1287ffed52cCD6BA0b0fb2 | de5bacd215f6aae50e524297c18fcf78b69b6312 | v2.0.0  |
| Unichain         | 0xeEeeEEE204Afb6BABb1287ffed52cCD6BA0b0fb2 | de5bacd215f6aae50e524297c18fcf78b69b6312 | v2.0.0  |
| Unichain Sepolia | 0xeEeeEEE204Afb6BABb1287ffed52cCD6BA0b0fb2 | de5bacd215f6aae50e524297c18fcf78b69b6312 | v2.0.0  |

## Deprecated Strategy Factories
The following LBP strategy factories are superseded by LBPStrategy v3 and are not recommended for new launches. Addresses are retained for reference.

## FullRangeLBPStrategyFactory
| Chain        | Address                                    |
| ------------ | ------------------------------------------ |
| Ethereum     | 0x65aF3B62EE79763c704f04238080fBADD005B332 |
| Unichain     | 0xAa56d4d68646B4858A5A3a99058169D0100b38e2 |
| Base         | 0x39E5eB34dD2c8082Ee1e556351ae660F33B04252 |
| Sepolia      | 0x89Dd5691e53Ea95d19ED2AbdEdCf4cBbE50da1ff |
| Base Sepolia | 0xa3A236647c80BCD69CAD561ACf863c29981b6fbC |

## AdvancedLBPStrategyFactory
| Chain        | Address                                    |
| ------------ | ------------------------------------------ |
| Ethereum     | 0x982DC187cbeB4E21431C735B01Ecbd8A606129C5 |
| Unichain     | 0xeB44195e1847F23D4ff411B7d501b726C7620529 |
| Base         | 0x9C5A6fb9B0D9A60e665d93a3e6923bDe428c389a |
| Sepolia      | 0xdC3553B7Cea1ad3DAB35cBE9d40728C4198BCBb6 |
| Base Sepolia | 0x67E24586231D4329AfDbF1F4Ac09E081cFD1e6a6 |

## GovernedLBPStrategyFactory
| Chain        | Address                                    |
| ------------ | ------------------------------------------ |
| Base         | 0xBc869216dAD02E1A95c1478a459D064b16F41B24 |
| Base Sepolia | 0xB460228ACa3bbf8FaDB781d22Cf051f55e7460A9 |

## LBPStrategyBasicFactory
| Chain    | Address                                    |
| -------- | ------------------------------------------ |
| Ethereum | 0xbbbb6FFaBCCb1EaFD4F0baeD6764d8aA973316B6 |
| Base     | 0xC46143aE2801b21B8C08A753f9F6b52bEaD9C134 |
| Unichain | 0x435DDCFBb7a6741A5Cc962A95d6915EbBf60AE24 |

## VirtualLBPStrategyFactory
| Chain    | Address                                    |
| -------- | ------------------------------------------ |
| Ethereum | 0x00000010F37b6524617b17e66796058412bbC487 |
| Sepolia  | 0xC695ee292c39Be6a10119C70Ed783d067fcecfA4 |
