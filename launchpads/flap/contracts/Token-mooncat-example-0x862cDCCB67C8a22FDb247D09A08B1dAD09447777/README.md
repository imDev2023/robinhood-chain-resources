# Token-mooncat-example-0x862cDCCB67C8a22FDb247D09A08B1dAD09447777

**$moon, a live Tax Token V3 clone**

- Address: `0x862cDCCB67C8a22FDb247D09A08B1dAD09447777`
- Contract name on Blockscout: `mooncat`
- Verified: yes
- Proxy type: `eip1167`, implementation `0x7777C8743C88B3aff3cf262135beF2c8b2e83333`
- Creator: `0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09`
- Creation tx: `0x1831e2cd89cd8263bf6dc30f561b5bff242db1f7c67d1bc6ae213e0f3bee1c40`
- Explorer: <https://robinhoodchain.blockscout.com/address/0x862cDCCB67C8a22FDb247D09A08B1dAD09447777>

EIP-1167 clone of `FlapTaxTokenV3`, kept as a worked example of a graduated launch.
`Portal.getTokenV8Safe` for it (`_raw/rpc/lp-and-token-state.txt`): status 4 (DEX), tokenVersion 6, r `1.9189797e18`, h `1.07036752e26`, k `2.1243810542419344e27`, `dexSupplyThresh` 800,000,000e18, quote token the zero address, buy and sell tax 500 bps, pool `0x55aED1a1...`, progress `1e18`.

## Callable surface

No verified source.
`bytecode.hex` holds the runtime code, `selectors.txt` is a PUSH4 scan of it, and `selectors-decoded.txt` resolves those selectors through openchain.

## Files in this directory

- `address.json`
- `bytecode.hex`
- `metadata.json`
- `selectors.txt`
