# PairFactory-0x0d1eBb179cdbcA88D74C923C4255Cb2B17474AfD

**FlapCurvePairFactory, unverified**

- Address: `0x0d1eBb179cdbcA88D74C923C4255Cb2B17474AfD`
- Contract name on Blockscout: `unnamed`
- Verified: no
- Proxy type: `none`
- Creator: `0x8187F13ed6C7C9554AfE4Dd4C4D4960174846063`
- Creation tx: `0x578bade084be67a9722e8bcc1ce7472ca1578ab1ebbb07e407d0927c172756e3`
- Explorer: <https://robinhoodchain.blockscout.com/address/0x0d1eBb179cdbcA88D74C923C4255Cb2B17474AfD>

Confirmed as the curve-pair factory by `Portal.flapCurvePairFactory()`.
It deploys one beacon-proxy `FlapCurvePair` per launched token, so `allPairsLength()` is the exact count of tokens ever launched on this chain through Flap.

Live reads on 2026-09-02 (`_raw/rpc/ecosystem-counts.txt`):

| call | value |
| --- | --- |
| `allPairsLength()` | `173798` |
| `allPairs(0)` | `0x936937eebbc581b9baf5d542497dccf6648759fe` |
| `allPairs(173797)` | `0xa057908591c047bb9db816abbd7c5868b940cd2a` |

Sampling `graduated()` over 3,000 evenly spaced pairs returned 2 true (`_raw/rpc/graduation-sample.txt`).

## Callable surface

No verified source.
`bytecode.hex` holds the runtime code, `selectors.txt` is a PUSH4 scan of it, and `selectors-decoded.txt` resolves those selectors through openchain.

## Files in this directory

- `address.json`
- `bytecode.hex`
- `metadata.json`
- `selectors-decoded.txt`
- `selectors-openchain.json`
- `selectors.txt`
