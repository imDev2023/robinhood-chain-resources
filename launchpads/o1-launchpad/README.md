# o1 Launchpad

Archived 2026-09-19.
DefiLlama category Launchpad.
$463,085 in 24h against $656,777 in 30d on the 2026-09-02 pull, which is what made it a priority target: most of its lifetime fees had landed on the capture date.

**Five generations are live on Robinhood Chain**, not one, and all five are verified.
o1 also runs on Base (six suites) and Monad, so this is a multi-chain deployment and the Robinhood numbers are a slice of a larger operation.

The fee adapter cites a **public source repo**, `github.com/o1exchange/o1-launch`, pinned at commit `756a75cef544369ac57f0092898a64300b168ab9`.
That makes o1 one of very few pads on this chain whose code is published rather than only verified on chain, and the repo was not cloned in this pass.

## 1. Generations on chain 4663

| Suite | Factory | Contract name | Route | Launch fee |
| --- | --- | --- | --- | --- |
| `robinhood-block-v1` | `0x8b40fc20c405d47d725c9723d056a1c6f62bbccf` | `ERC20LaunchpadFactory` | standard | none |
| `robinhood-block-v2` | `0x76f0923ac4df0a079a10f628a7bce6426ccd344a` | `ERC20LaunchpadFactory` | standard | none |
| `robinhood-timestamp-v3` | `0x411f21283d3e492bc395027329e08f9f4f560ba5` | `ERC20LaunchpadFactory` | standard | quote |
| `robinhood-rwa-timestamp-v4` | `0xe64ac4113848bbc1a6dde1a6d1da96720a36f297` | `RWAERC20LaunchpadFactory` | rwa | native |
| `robinhood-mainnet-launchpad-v4-minimal` | `0xce9c48cfa068947f77738c81be406b53338e5b0d` | `RWAERC20LaunchpadFactory` | dual | native |

Each suite is a factory plus a `LaunchHook` plus a `FeeEscrow`.
Twelve contracts are archived under `contracts/`, 389 `.sol` files, every one verified.

The generation names encode a real migration: `block` suites anchored their anti-snipe window to block numbers, `timestamp` suites to the wall clock.
That is the same correction Sentry and Unihood made, and for the same reason.

## 2. Model

Direct pool seed into Uniswap v4, no bonding curve.
The hook's natspec describes the whole design:

> gates pool creation to the launchpad factory (`beforeInitialize`), blocks all third-party liquidity adds/removes, and owns the one permanently-locked single-sided position (no code path ever passes a negative liquidityDelta), on every swap takes a fee on the quote currency as an ERC-6909 claim minted to the FeeEscrow, split through bounded per-pool fee components, plus a timestamp-anchored anti-snipe surcharge routed to the pool's mandatory platform component.

Two properties are worth naming.

**"No code path ever passes a negative liquidityDelta"** is a stronger statement of the lock than "removeLiquidity reverts", because it is a claim about the whole contract rather than about one guard.

**Per-pool economics are frozen at launch** in `poolConfig`, so an owner cannot re-price a launched token.
That matches HOOD10 and hood.fun, and is the opposite of Noxa's retroactive global knob.

The `rwa` and `dual` routes pair against tokenized equities, which puts o1 in the same group as Doppler, Long, Flap, Pons, Sentry and HOOD10.

## 3. Custody

The hook and the escrow are ownerless.
`LaunchpadFactoryCore.sol` carries **10 `onlyOwner` functions** across 641 lines, so the privileged surface sits entirely in the factory.
What those ten do was not enumerated in this pass, and it is the main open question: on HOOD10 the equivalent surface was two functions and one of them still took the documented fee router out of the path.

## 4. Gaps

1. **The ten owner functions are not enumerated.** Until they are, o1's custody cannot be ranked against Unihood or HOOD10.
2. **`o1exchange/o1-launch` was not cloned.** It would answer 1 directly and is cheap.
3. **Per-suite launch counts not pulled**, so which of the five generations is actually live is unknown.
4. **Fee levels not read.** The hook takes "bounded per-pool fee components" but the bounds and the platform's mandatory share were not read off chain.
5. No docs capture, no screenshots, no socials.

## Sources

- Addresses and suite metadata: `DefiLlama/dimension-adapters/fees/o1-launchpad/config.ts`.
- `contracts/` built by `scripts/bsfetch.py` from Blockscout, 2026-09-19.
