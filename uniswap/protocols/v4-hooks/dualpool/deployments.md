<!-- source: https://developers.uniswap.org/docs/protocols/v4-hooks/dualpool/deployments | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/protocols/v4-hooks/dualpool/deployments.md (native markdown) -->
# Deployments (/docs/protocols/v4-hooks/dualpool/deployments)

Find DualPool factory and contract addresses on Uniswap v4.

## Mainnet Deployments
## Ethereum: 1
| Contract                              | Address                                                                                                                 |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| AllowlistedFactory (DualPool factory) | [`0x0000000000077769C332e0D3ed8bC8E02A0cE108`](https://etherscan.io/address/0x0000000000077769C332e0D3ed8bC8E02A0cE108) |

The factory is the canonical deployer and discovery registry for DualPool hooks: it only deploys allowlisted, bit-exact builds of the audited bytecode, emits a `Deployed` event for every hook, and answers `isFromFactory(hook)` onchain. Every hook it deploys reports the factory from its `factory()` getter. To deploy a hook through it, see [Deploy a Hook](/docs/protocols/v4-hooks/dualpool/guides/deploy-hook).

> [!NOTE]
> For contract addresses across all Uniswap protocols, see the [deployments explorer](/deployments).

## Example: USDC/USDT Test Deployment
> [!NOTE]
> **Example only**
>
> The contract and pool below are a test deployment operated for protocol validation. Treat them as an example of a live DualPool configuration, not as canonical protocol addresses. This hook predates the factory and is not registered in it, so factory-anchored discovery will not surface it.

The hook address encodes DualPool's [permission flags](/docs/protocols/v4-hooks/dualpool/concepts/jit-liquidity#hook-permissions) per the v4 convention. The hook source code is available at [DualPoolHook.sol](https://github.com/Uniswap/v4-hooks-public/blob/main/src/alf/DualPoolHook.sol).

| Contract (example) | Address                                                                                                                 |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------- |
| DualPoolHook       | [`0x00000078BD49D5279a99b5F4011a5C61eE8caaC0`](https://etherscan.io/address/0x00000078BD49D5279a99b5F4011a5C61eE8caaC0) |

## Pool Parameters
| Parameter                             | Value                                                                                                                   |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| Pool ID                               | `0xf32349cbc41fec9d3194f2b4e9ee72ded0bfda412427be9cb8a4087f74bdb065`                                                    |
| Fee                                   | `10` pips (0.001%)                                                                                                      |
| Tick spacing                          | `10`                                                                                                                    |
| Steakhouse High Yield USDC (ERC-4626) | [`0xbeeff2C5bF38f90e3482a8b19F12E5a6D2FCa757`](https://etherscan.io/address/0xbeeff2C5bF38f90e3482a8b19F12E5a6D2FCa757) |
| Steakhouse USDT Prime (ERC-4626)      | [`0xbeef003C68896c7D2c3c60d363e8d71a49Ab2bf9`](https://etherscan.io/address/0xbeef003C68896c7D2c3c60d363e8d71a49Ab2bf9) |
| External deposits                     | Enabled                                                                                                                 |

The `PoolKey` is `(USDC, USDT, 10, 10, DualPoolHook)`, and the pool ID is `keccak256(abi.encode(poolKey))`. Both tokens use 6 decimals.

> [!NOTE]
> Do not hardcode derived values the chain can tell you: read vault addresses from [`vaults(poolId, currency)`](https://github.com/Uniswap/v4-hooks-public/blob/main/src/alf/base/PoolVault.sol#L323) on the hook, and compute pool IDs by hashing the key.
