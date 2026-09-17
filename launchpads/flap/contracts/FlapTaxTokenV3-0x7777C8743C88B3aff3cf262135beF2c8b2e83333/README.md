# FlapTaxTokenV3-0x7777C8743C88B3aff3cf262135beF2c8b2e83333

**Tax Token V3 implementation, verified**

- Address: `0x7777C8743C88B3aff3cf262135beF2c8b2e83333`
- Contract name on Blockscout: `FlapTaxTokenV3`
- Verified: yes
- Proxy type: `none`
- Creator: `0x4e59b44847b379578588920cA78FbF26c0B4956C`
- Creation tx: `0x09355cf1d4b5791d36388442870bffa30f9891f1ed0a13dd6713c2a54a01e09d`
- Compiler: `v0.8.26+commit.8a97fa7a`, optimizer on (99999 runs), EVM `cancun`
- License: `none`
- Explorer: <https://robinhoodchain.blockscout.com/address/0x7777C8743C88B3aff3cf262135beF2c8b2e83333>

One of the two token implementations Robinhood Chain accepts, reached through `Portal.newTokenV6` with `tokenVersion = TOKEN_TAXED_V3` (enum value 6).
Vanity suffix `7777`: every clone's address is mined to end in 7777.
Supports asymmetric buy and sell tax, a commission receiver, and a dividend token that can be the quote token, the tax token itself, or an arbitrary ERC-20.

## Constructor arguments

- `minLiqThreshold_` (`uint256`): `50000000000000000000000`
- `startLiqThreshold_` (`uint256`): `400000000000000000000000`

## Functions that matter for launching

- `buyTaxRate()` returns `(uint16)`  [view]
- `dividendContract()` returns `(address)`  [view]
- `finalizeMigration()`  [nonpayable]
- `initialize(tuple)`  [nonpayable]
- `owner()` returns `(address)`  [view]
- `quoteToken()` returns `(address)`  [view]
- `renounceOwnership()`  [nonpayable]
- `sellTaxRate()` returns `(uint16)`  [view]
- `startMigration()`  [nonpayable]
- `taxExpirationTime()` returns `(uint256)`  [view]
- `taxProcessor()` returns `(address)`  [view]
- `taxRate()` returns `(uint16)`  [view]
- `transferOwnership(address)`  [nonpayable]

## Events

- `Approval(address,address,uint256)`
- `EIP712DomainChanged()`
- `Initialized(uint8)`
- `OwnershipTransferred(address,address)`
- `PoolStateChanged(uint8,uint8)`
- `TaxLiquidationError(bytes)`
- `TokensBurned(uint256)`
- `Transfer(address,address,uint256)`
- `TransferFlapToken(address,address,uint256)`

## Files in this directory

- `abi.json`
- `address.json`
- `metadata.json`
- `methods-read.json`
- `sources`/
