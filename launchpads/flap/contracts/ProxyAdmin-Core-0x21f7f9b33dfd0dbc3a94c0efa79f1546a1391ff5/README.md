# ProxyAdmin-Core-0x21f7f9b33dfd0dbc3a94c0efa79f1546a1391ff5

**ProxyAdmin for Portal, VaultPortal, SwapRegistry and TaxTokenHelper, verified**

- Address: `0x21f7f9b33dfd0dbc3a94c0efa79f1546a1391ff5`
- Contract name on Blockscout: `ProxyAdmin`
- Verified: yes
- Proxy type: `none`
- Creator: `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05`
- Creation tx: `0x9686fdae7a9170361b424b48582ca26afa8fff2facd27c7ed776872a9f4192d0`
- Compiler: `v0.8.26+commit.8a97fa7a`, optimizer on (99999 runs), EVM `cancun`
- License: `none`
- Explorer: <https://robinhoodchain.blockscout.com/address/0x21f7f9b33dfd0dbc3a94c0efa79f1546a1391ff5>

Read from the EIP-1967 admin slot of each of those four proxies (`_raw/rpc/proxy-admins.txt`).
`owner()` is `0xc68f29bfe2f6c3d95adb5685592b9f86680968f2`, the `UpgradeSafe`.
Whoever controls that Safe can replace the Portal implementation, and the Portal custodies every bonding curve's reserve.

## Functions that matter for launching

- `changeProxyAdmin(address,address)`  [nonpayable]
- `getProxyAdmin(address)` returns `(address)`  [view]
- `owner()` returns `(address)`  [view]
- `renounceOwnership()`  [nonpayable]
- `transferOwnership(address)`  [nonpayable]
- `upgrade(address,address)`  [nonpayable]
- `upgradeAndCall(address,address,bytes)`  [payable]

## Events

- `OwnershipTransferred(address,address)`

## Files in this directory

- `abi.json`
- `address.json`
- `metadata.json`
- `selectors-decoded.txt`
- `selectors-openchain.json`
- `selectors.txt`
- `sources`/
