# PortalQuoteSwapModule-0xe5F72d6F9dDAB579317A4FeBD2FfB8ec3d73497b

**Portal quote-swap module, unverified**

- Address: `0xe5F72d6F9dDAB579317A4FeBD2FfB8ec3d73497b`
- Contract name on Blockscout: `unnamed`
- Verified: no
- Proxy type: `none`
- Creator: `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05`
- Creation tx: `0x64577d302341209b7e79c8ec92068b17c7da4a06b3ec4e9d583ee7b92169b4ec`
- Explorer: <https://robinhoodchain.blockscout.com/address/0xe5F72d6F9dDAB579317A4FeBD2FfB8ec3d73497b>

Called by the Portal on trades whose quote token is not native ETH (the HOODon trade in `_raw/blockscout/txinternal-0x0c7e01c9...json`).
It is the `nativeToQuoteSwapType` path from `QuoteTokenConfiguration`, which is set to `7` for most of the enabled stock-token quotes.

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
