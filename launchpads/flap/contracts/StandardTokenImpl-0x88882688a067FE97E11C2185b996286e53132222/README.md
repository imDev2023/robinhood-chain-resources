# StandardTokenImpl-0x88882688a067FE97E11C2185b996286e53132222

**Non-tax token implementation (FlapNonTaxToken), verified**

- Address: `0x88882688a067FE97E11C2185b996286e53132222`
- Contract name on Blockscout: `FlapNonTaxToken`
- Verified: yes
- Proxy type: `none`
- Creator: `0x4e59b44847b379578588920cA78FbF26c0B4956C`
- Creation tx: `0x8b9f772c5d8139fd3394c5be0f81d71c0767a58a7a105bfaa534742c461f34b1`
- Compiler: `v0.8.26+commit.8a97fa7a`, optimizer on (99999 runs), EVM `cancun`
- License: `none`
- Explorer: <https://robinhoodchain.blockscout.com/address/0x88882688a067FE97E11C2185b996286e53132222>

The other accepted token type, reached through `Portal.newTokenV5`.
Vanity suffix `8888`.
`maxSupply()` is 1,000,000,000 ether for every launch.
Anti-farmer enforcement here is a hard revert on transfers to or from registered pools, not a fee: all pool transfers are blocked before graduation, and after graduation only `mainPool` is exempt until `antiFarmerExpirationTime`.

## Functions that matter for launching

- `initialize(tuple)`  [nonpayable]
- `owner()` returns `(address)`  [view]
- `renounceOwnership()`  [nonpayable]
- `transferOwnership(address)`  [nonpayable]

## Events

- `Approval(address,address,uint256)`
- `EIP712DomainChanged()`
- `Initialized(uint8)`
- `OwnershipTransferred(address,address)`
- `Transfer(address,address,uint256)`
- `TransferFlapToken(address,address,uint256)`

## Files in this directory

- `abi.json`
- `address.json`
- `metadata.json`
- `methods-read.json`
- `sources`/
