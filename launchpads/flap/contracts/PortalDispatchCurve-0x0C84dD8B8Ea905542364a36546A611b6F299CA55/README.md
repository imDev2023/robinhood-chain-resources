# PortalDispatchCurve-0x0C84dD8B8Ea905542364a36546A611b6F299CA55

**Portal bonding-curve dispatch module, unverified**

- Address: `0x0C84dD8B8Ea905542364a36546A611b6F299CA55`
- Contract name on Blockscout: `unnamed`
- Verified: no
- Proxy type: `none`
- Creator: `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05`
- Creation tx: `0xf24c3969bc37133b01a23639c289070cfa150c3999fcc65947e0be24dc1a4bea`
- Explorer: <https://robinhoodchain.blockscout.com/address/0x0C84dD8B8Ea905542364a36546A611b6F299CA55>

Second delegatecall target on a native-ETH buy.
`_raw/blockscout/txinternal-0xec60221a...json` shows `Portal -> PortalImpl -> 0x0C84dD8B...`, and immediately after it the Portal sends exactly 1% of the trade to the FeeSafe.
This is where the bonding-curve fee split executes.

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
