# TaxTokenHelperImpl-0x4f0511d8a00a74d8ddb4bfb3a97282e4a39252af

**TaxTokenHelper implementation, verified**

- Address: `0x4f0511d8a00a74d8ddb4bfb3a97282e4a39252af`
- Contract name on Blockscout: `TaxTokenHelper`
- Verified: yes
- Proxy type: `none`
- Creator: `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05`
- Creation tx: `0xac8f0d87d468dda11b0090bb115f5994e20568f8b6d0188adf034a6296fdb2cd`
- Compiler: `v0.8.26+commit.8a97fa7a`, optimizer on (99999 runs), EVM `cancun`
- License: `none`
- Explorer: <https://robinhoodchain.blockscout.com/address/0x4f0511d8a00a74d8ddb4bfb3a97282e4a39252af>

Logic behind the helper proxy.

## Constructor arguments

- `_portal` (`address`): `0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09`
- `_vaultPortal` (`address`): `0x0000000000000000000000000000000000000000`
- `_flapAIProvider` (`address`): `0x0000000000000000000000000000000000000000`

## Functions that matter for launching

- `claimDividend(address)`  [nonpayable]
- `claimDividend(address,bool)`  [nonpayable]
- `claimDividendForUser(address,bool,address)`  [nonpayable]
- `getDividendInfo(address,address)` returns `(uint256,uint256)`  [view]
- `getTaxTokenInfo(address)` returns `(tuple)`  [view]
- `getTaxTokenInfoV2(address)` returns `(tuple)`  [view]
- `vaultPortal()` returns `(address)`  [view]
- `version()` returns `(string)`  [pure]

## Files in this directory

- `abi.json`
- `address.json`
- `metadata.json`
- `methods-read.json`
- `sources`/
