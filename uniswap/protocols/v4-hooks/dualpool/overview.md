<!-- source: https://developers.uniswap.org/docs/protocols/v4-hooks/dualpool/overview | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/protocols/v4-hooks/dualpool/overview.md (native markdown) -->
# Overview (/docs/protocols/v4-hooks/dualpool/overview)

Navigate DualPool concepts, integration guides, and references for the dual liquidity AMM built on Uniswap v4.

DualPool is a market-making protocol built as a [Uniswap v4 hook](/docs/protocols/v4/concepts/hooks). In a vanilla pool, liquidity sits in the pool at all times earning only swap fees. In a DualPool, capital rests in [ERC-4626](https://eips.ethereum.org/EIPS/eip-4626) vaults between swaps and is deployed as concentrated liquidity just-in-time, per swap. Liquidity providers can earn swap fees and vault yield on the same token.

From the outside, a DualPool is an ordinary v4 pool: swappers and routers execute standard v4 swaps at the pool's static fee. The difference is where the capital lives when no swap is in flight, and that the pool holds approximately zero resident v4 liquidity between swaps, so integrators discover capacity through the hook's quote views rather than through pool state.

## Concepts
* [Just-in-Time Liquidity](/docs/protocols/v4-hooks/dualpool/concepts/jit-liquidity)
* [Inventory and Yield](/docs/protocols/v4-hooks/dualpool/concepts/inventory-and-yield)
* [Liquidity Distributions](/docs/protocols/v4-hooks/dualpool/concepts/liquidity-distributions)
* [LP Shares](/docs/protocols/v4-hooks/dualpool/concepts/lp-shares)

## Guides
* [Swap Against a DualPool](/docs/protocols/v4-hooks/dualpool/guides/swap)
* [Provide Liquidity](/docs/protocols/v4-hooks/dualpool/guides/provide-liquidity)
* [Integrate as a Router or Aggregator](/docs/protocols/v4-hooks/dualpool/guides/router-integration)
* [Deploy a Hook](/docs/protocols/v4-hooks/dualpool/guides/deploy-hook)
* [Create and Operate a Pool](/docs/protocols/v4-hooks/dualpool/guides/create-pool)

## Repositories
* [v4-hooks-public](https://github.com/Uniswap/v4-hooks-public)
* [DualPoolHook.sol](https://github.com/Uniswap/v4-hooks-public/blob/main/src/alf/DualPoolHook.sol)

## Related Protocols
* [Uniswap v4](/docs/protocols/v4/overview)
* [Universal Router](/docs/protocols/universal-router/overview)
* [Permit2](/docs/protocols/permit2/overview)

## Deployments
* [DualPool deployment addresses](/docs/protocols/v4-hooks/dualpool/deployments)

## Security
DualPool was audited by OpenZeppelin in May-June 2026, with no critical or high-severity findings and all medium-severity findings resolved.

[Trust model, protocol invariants, and audit summary](/docs/protocols/v4-hooks/dualpool/security)
