## What it is

The index token itself, and it is **not** a HOOD10 Launchpad launch.
It is an EIP-1167 minimal clone of `CashCatTokenV2` (0xd6Da7f07eE822C8538C901217b37D1e7d86c76E5), created by the CashCat factory proxy 0x5bd1Fbe78a78fe8236fa00CF48fbEBA74ae34661 in tx 0xb508e76ec585225f317cd821dfa58acf0839c91c1937a65fe859bd9acb128538.
That factory is letscash.fun, which is why the docs list a 0.30% "letscash.fun platform fee" inside the 5% tax.

Live state at capture (`_raw/rpc/hood10-token-state.txt`): `buyTaxRate()` and `sellTaxRate()` 500 bps, `taxRatePips()` 50000, `totalSupply` 1e27, `hook()` CashCatHookV2 0x75A54357D9C78a2Db19004a5FDc76c50F9242AEC, `poolId()` 0x2e152bc12f30bd46eb39f0ead2367df62b9572ba3a2d54ea3e3aca43c00ae9f6, `tokenURI()` ipfs://bafkreie5flhu3xfz4j5qrw4r3pgs6pqz5db4scc5dtdp72piwfsu4zqbbu.
`CashCatHookV2.poolConfigs(poolId)` names the fee recipient for that pool as the EOA 0x639D6Faa4DAf85d4ccc4291D1134C83867df5d82, not the distributor.

`bytecode.hex` is the 45-byte EIP-1167 clone stub, which embeds the implementation address literally.
`abi.json` here is a copy of `CashCatTokenV2`'s ABI, which is what the clone actually exposes; the readable sources are in `../CashCatTokenV2-impl-0xd6Da7f07eE822C8538C901217b37D1e7d86c76E5/sources/`.
