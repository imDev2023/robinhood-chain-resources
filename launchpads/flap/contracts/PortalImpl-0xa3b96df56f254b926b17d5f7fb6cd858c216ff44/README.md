# PortalImpl-0xa3b96df56f254b926b17d5f7fb6cd858c216ff44

**Portal implementation, unverified**

- Address: `0xa3b96df56f254b926b17d5f7fb6cd858c216ff44`
- Contract name on Blockscout: `unnamed`
- Verified: no
- Proxy type: `none`
- Creator: `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05`
- Creation tx: `0x8c8ab66539161c025f74113884574deafe610d81a1393cd7e08b624c14436bbe`
- Explorer: <https://robinhoodchain.blockscout.com/address/0xa3b96df56f254b926b17d5f7fb6cd858c216ff44>

The logic behind the Portal proxy.
Blockscout has no source for it, so `selectors.txt` is a PUSH4 scan of the runtime code and `selectors-decoded.txt` resolves 96 selectors through openchain.
That decoded list is what makes the rest of this archive possible: it names `newTokenV5`, `newTokenV6`, `newTokenV7`, `commitNewTokenV5`, `stageNewTokenV5`, `swapExactInput`, `getQuoteTokenConfiguration`, `getTokenV8Safe`, `getFeeRate`, `SALT_LOCK_FEE`, `claim`, `delegateClaim` and `setTokenBeneficiary`.

Argument types for those calls come from `IPortal.sol`, which ships verified inside `VaultPortalImpl` and `TaxProcessorUniV2Impl`.

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
