# PairImpl-0xF9ADbAfF5610FFCe26855747049c69973A8176e5

**FlapCurvePair beacon implementation, unverified**

- Address: `0xF9ADbAfF5610FFCe26855747049c69973A8176e5`
- Contract name on Blockscout: `unnamed`
- Verified: no
- Proxy type: `none`
- Creator: `0x0d1eBb179cdbcA88D74C923C4255Cb2B17474AfD`
- Creation tx: `0x578bade084be67a9722e8bcc1ce7472ca1578ab1ebbb07e407d0927c172756e3`
- Explorer: <https://robinhoodchain.blockscout.com/address/0xF9ADbAfF5610FFCe26855747049c69973A8176e5>

Every curve pair is a `BeaconProxy` onto this address.
Decoded selectors include `token0()`, `token1()`, `getReserves()`, `graduated()`, `portal()`, `initialize(address,address,address)` and `recoverToken(address)`.
`graduated()` is the cheapest per-token graduation check on this chain.

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
