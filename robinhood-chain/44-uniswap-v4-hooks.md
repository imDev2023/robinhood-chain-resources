# Uniswap v4 hooks on Robinhood Chain

> Original writing. Verified 2026-09-19 at L2 block 66,716,100 against the public RPC and Alchemy `robinhood-mainnet`.
> Complements `12-differences-from-ethereum.md`, which lists the Nitro semantics generally; this page covers only what reaches **hook** code.
> Pool and liquidity data is in `45-v4-pools-and-liquidity.md`.

## v4 is deployed and is the dominant venue

Every address below was confirmed to hold code by direct `eth_getCode` on 2026-09-19, not read from a table.

| Contract | Address | Code |
| --- | --- | --- |
| PoolManager | `0x8366a39cc670b4001a1121b8f6a443a643e40951` | 24,009 bytes, verified, tagged `PoolManager` |
| PositionManager | `0x58daec3116aae6d93017baaea7749052e8a04fa7` | 23,877 bytes |
| Universal Router | `0x8876789976decbfcbbbe364623c63652db8c0904` | 24,546 bytes |
| Permit2 | `0x000000000022D473030F116dDEE9F6B43aC78BA3` | 9,152 bytes |
| CREATE2 deployer | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | 69 bytes |

PoolManager's first transaction was 2026-06-03.
As of 2026-09-19 the chain carries 123 v4 pools against 49 v3 pools, so v4 is the primary venue rather than a new arrival.

Two entries deserve comment.

The **CREATE2 deployer** is the canonical Arachnid factory.
v4 encodes a hook's permissions in the low 14 bits of its address, so deploying a hook means mining a salt through this factory.
Without it, hooks cannot be deployed at all. It is also what deployed the PoolManager here.

**EIP-1153 transient storage is available.**
No Robinhood doc states this, but v4's flash accounting is built on transient storage and the PoolManager is demonstrably transacting, so support is implied by a working deployment.
Foundry projects targeting this chain need `evm_version = "cancun"`.

## `block.number` is the trap

Nitro returns an estimate of the **L1** block number from Solidity's `block.number`.
`12-differences-from-ethereum.md` records this generally; the measured magnitude is what matters for hooks.

Measured 2026-09-19 across three windows, comparing the L2 header `number` against `l1BlockNumber`:

| Window | L2 blocks | `block.number` advanced | L2 blocks per tick |
| --- | ---: | ---: | ---: |
| 100 s | 1,000 | 8 | 125.0 |
| 1,210 s | 12,000 | 100 | 120.0 |
| 12,078 s | 120,000 | 1,001 | 119.9 |

L2 block time is 0.10 s and `block.number` ticks roughly once per 12 s.
**About 120 consecutive L2 blocks share one `block.number`.**
At the sampled block, L2 height was 66,716,100 while `block.number` read 26,008,494.

Real L2 height comes from `ArbSys(0x64).arbBlockNumber()`.

### Two widely used hooks are affected

OpenZeppelin's `uniswap-hooks` library is the base every current hook inherits from.

> **Two things about the library itself, checked 2026-09-20 against v1.2.1, the current release.**
>
> **Override `_afterSwap`, not `afterSwap`.** Since v1.2.0 the ten `IHooks` entry points on `BaseHook` are non-virtual and permanently `onlyPoolManager`, and each forwards to an internal `_beforeSwap` or `_afterSwap` that the hook overrides instead. Overriding the external one fails to compile with "Trying to override non-virtual function". Almost every tutorial predates this and teaches the old form. It is worth the migration: a `BaseHook` subclass can no longer drop the caller guard, so an entire access-control defect class stops being expressible.
>
> **`onlyValidPools` is not in any release yet.** It and `onlySelf` were removed on 2025-10-17 as "unused", so v1.2.0 and v1.2.1 ship without them. `onlyValidPools` was re-added on 2026-08-28 when `LimitOrderHook` needed to validate a pool, and sits on `main` unreleased. Until it ships, write the check by hand: any public or external function taking a caller-supplied `PoolKey` must reject a key whose `hooks` is not the contract itself, because the PoolManager accepts any initialized pool and a pool configured with a different hook never calls into yours.

Two of the library's ready-made hooks key state on `block.number`:

- `src/general/AntiSandwichHook.sol:131`
- `src/general/LiquidityPenaltyHook.sol:186`

Neither is wrong. Both assume a chain where `block.number` is the block height.

`LiquidityPenaltyHook` penalises liquidity added and removed within a configured block offset, to deter just-in-time liquidity.
Here an offset of 1 spans about 12 seconds and 120 L2 blocks, so the parameter means something entirely different and ordinary liquidity management inside a 12-second window is treated as JIT.

`AntiSandwichHook` checkpoints pool state at the start of each block and prices against that snapshot.
Here the snapshot persists across roughly 120 L2 blocks of real trading.
Whether that ends up more or less protective has not been analysed and should not be assumed either way.

Both expose the accessor as `internal view virtual` precisely so it can be replaced:

```solidity
interface IArbSys {
    function arbBlockNumber() external view returns (uint256);
}

function _getBlockNumber() internal view override returns (uint48) {
    return uint48(IArbSys(address(0x64)).arbBlockNumber());
}
```

Treat any hook reading `block.number` on this chain as needing the override until shown otherwise, and assert it in a fork test.

## Stock tokens are not elastic supply

> Corrected 2026-09-19. This section previously called stock tokens elastic supply and the classic rebasing-token hazard. That was wrong; `46-uimultiplier-is-display-only.md` has the measurements.

Robinhood Stock Tokens carry an ERC-8056 `uiMultiplier()` that rises as corporate actions land.
Between 2026-09-03 and 2026-09-19, 18 of the 194 multipliers moved (see `45-v4-pools-and-liquidity.md`).

The multiplier is display-only.
It scales `balanceOfUI()` and `totalSupplyUI()` and never touches `balanceOf` or `totalSupply`, so at the accounting layer a stock token is an ordinary fixed-supply ERC-20.
The rebasing hazard in Uniswap's security framework, where `PoolManager.sync` and `PoolManager.settle` credit the difference between two balance reads, does not apply to these tokens.

A further data point, read 2026-09-19 through the Alchemy archive RPC: SGOV (`0x92FD66527192E3e61d4DDd13322Aa222DE86F9B5`) moved from 1.002981519346766532 to 1.005101770003214918 at `effectiveAt` 1788220826, between L2 blocks 51,274,907 and 51,274,926.
`totalSupply()` held at 7401.66265947 and the v4 PoolManager's raw `balanceOf` held at 52.574071334340010176, identical to the wei on both sides.

What a hook author should price in instead is the issuer's powers over the tokens, all documented in file 46: a central blocklist checked on every transfer and approval, `adminBurn` from any address including a pool's reserves, a global pause, and one shared upgrade beacon behind all 194 tokens that could change this behaviour in a single upgrade.
These are the pausable and blocklist token hazards from the same framework, and they are reasons to cap exposure rather than reasons the accounting breaks.

The dominant quote asset is **USDG**, the Paxos Global Dollar, not a wrapped native token.

## Other Nitro semantics that reach hook code

| Behaviour | Here | Consequence for a hook |
| --- | --- | --- |
| `block.prevrandao`, `block.difficulty` | constant | No randomness. Never derive a fee, ordering or selection from it. |
| `blockhash(n)` | reliable only for recent blocks | Not a randomness source. |
| `block.coinbase` | network fee account | Not a validator or builder address. |
| `gasleft()`, gas estimation | fees carry an L1 data component | Never hardcode gas in a callback. |
| Max contract size | 96 KB code, 192 KB init | A hook too large for Ethereum can deploy here. 24 KB is not the ceiling. |
| Transaction ordering | first-come, first-served at the sequencer | Fee bumping does not reprioritise, so the mempool-reordering assumption behind classic sandwich attacks does not hold in its usual form. Revisit the threat model before assuming an anti-sandwich hook is needed or that it behaves as designed. |
| L1 data fee scales with calldata | yes | Keep `hookData` small; it is calldata the user pays for. |

`block.timestamp` advances normally at 0.1 s block time, so deadline checks such as `BaseCustomAccounting.sol:111` behave.
A deadline measured in blocks would not.

## Swapping against a delta-returning hook through the Universal Router

> Verified 2026-09-20 on testnet 46630 near L2 block 121,920,000, by `eth_call` and then by real swaps.
> The hook under test sets both `beforeSwapReturnDelta` and `afterSwapReturnDelta` and takes its fee on the native side of a native-ETH pool.

Most aggregators and the Uniswap Labs interface will not route a pool whose hook returns deltas.
The contracts themselves have no such objection, which matters to anyone building their own swap page for such a pool.

**The Universal Router and the V4 Quoter both work against a delta-returning hook.**
`quoteExactInputSingle` returns amounts with the hook's fee already taken out, in both directions, and a real swap then delivered the quoted amount to the wei.
So a frontend for such a pool needs no router of its own.

**The periphery is on testnet 46630 at the mainnet addresses.**
Compared by bytecode: the V4 Quoter (`0x8Dc178eFB8111BB0973Dd9d722ebeFF267c98F94`), StateView (`0xF3334192D15450CdD385c8B70e03f9A6bD9E673b`) and PoolManager are byte-identical across 4663 and 46630.
The Universal Router (`0x8876789976dEcBfCbBbe364623C63652db8C0904`) and Permit2 have the same length and differ only in hash, which is what chain-specific immutables produce.
Multicall3 is on both as well.

### The struct trap: both layouts appear to work

Universal Router 2.1.1 takes this for `SWAP_EXACT_IN_SINGLE`:

```solidity
struct ExactInputSingleParams {
    PoolKey poolKey;
    bool zeroForOne;
    uint128 amountIn;
    uint128 amountOutMinimum;
    uint256 minHopPriceX36; // absent from most tutorials and from older periphery
    bytes hookData;
}
```

**Sending the older five-field struct does not revert.**
The router reads the struct straight from calldata rather than ABI-decoding it, so under the wrong layout the word where `minHopPriceX36` belongs is read as the `hookData` offset, lands on a zero length, and decodes as empty bytes.
The swap succeeds, and the per-hop price guard has been silently dropped.
A success is therefore not evidence that the encoding is right.

To tell the layouts apart on chain, set the floor either side of the real price.
With the new layout a floor just below the quoted price passes and one just above reverts `V4TooLittleReceivedPerHopSingle(uint256 minPrice, uint256 price)`, selector `0x4713c18b`.
The price it reports is exactly `amountOut * 1e36 / amountIn`, which is also how to compute a floor: derive it from the minimum amount out, not from the quoted price, or it can reject a fill the minimum would have accepted.

### Shape of a working swap

`execute(commands, inputs, deadline)` with command `0x10` (`V4_SWAP`) and actions `0x06 0x0c 0x0f`: `SWAP_EXACT_IN_SINGLE`, `SETTLE_ALL`, `TAKE_ALL`.
Buying with native ETH sends it as `msg.value` and settles currency `address(0)`.

Selling an ERC-20 goes through Permit2, because the router pulls the token with `permit2.transferFrom`.
The holder approves Permit2 on the token once, then signs a `PermitSingle`, and the signature rides in the same call: commands `0x0a10`, `PERMIT2_PERMIT` then `V4_SWAP`.
After that a sale is one transaction until the permit expires.
An unpermitted sell reverts `InsufficientAllowance(uint256)` (`0xf96fb071`) or `AllowanceExpired(uint256)` (`0xd81b2f2e`) from Permit2, unwrapped.

Reverts from the swap itself also arrive unwrapped, for example `V4TooLittleReceived(uint256,uint256)` (`0x8b063d73`) and `TransactionDeadlinePassed()` (`0x5bf6f916`).
A revert raised inside a hook arrives inside the PoolManager's `WrappedError(address,bytes4,bytes,bytes)` (`0x90bfb865`), so an error decoder has to look through that wrapper.

Gas on testnet was about 176k for the buy and 201k for the permit-and-sell.

## Tooling notes

Alchemy is first-class for this chain as `robinhood-mainnet`, confirmed 2026-09-19 returning chain id `0x1237`.
Free-tier `eth_getLogs` is still capped at a 10 block range, which matters because finding the hook attached to a pool means reading `Initialize` events from the PoolManager.
Use `alchemy_getAssetTransfers`, the Blockscout PRO API at `api.blockscout.com/4663`, or a Goldsky subgraph for any real scan.

The public RPC `https://rpc.mainnet.chain.robinhood.com` returns **403** to clients without a browser `User-Agent`.
`curl` works; Python `urllib` with its default agent does not.

Contract verification through the public Blockscout instance hits the Cloudflare challenge documented in `32-explorer-and-data-apis.md`, which is what breaks `forge verify-contract`.
Point Foundry's `[etherscan]` block at `https://api.blockscout.com/4663/api` instead.
