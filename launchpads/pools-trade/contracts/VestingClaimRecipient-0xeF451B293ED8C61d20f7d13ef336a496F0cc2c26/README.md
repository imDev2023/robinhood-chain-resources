# VestingClaimRecipient - 0xeF451B293ED8C61d20f7d13ef336a496F0cc2c26

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xeF451B293ED8C61d20f7d13ef336a496F0cc2c26
Role: VestingClaimRecipient.
Contract name: VestingClaimRecipient.
Verified: True (sources from `smart-contracts`, flag from `addresses`).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/periphery/VestingClaimRecipient.sol.
Source files written: 38 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x13fde174ddf647aba0352815a79e47ba29a6a842930473ad406d66a76211386c.
Proxy type: None; implementations: [].

## Constructor arguments

- `_positionManager` (address): `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `_maxCurrency0PerBlock` (uint128): `125000000000000`
- `_maxCurrency1PerBlock` (uint128): `50000000000000000000000`
- `_recipient` (address): `0xa1ba4CC12654D2b188e3ba77dc86c75cA47f1A4e`
- `_beneficiaryVaults` (address[]): `['0x587D2fDDDF14F6f84022b51e8c3a473eB88C4544', '0xa5889CaFCB1757218eA71730bee381Cc2a3F2CCC', '0xd35E9CA72F64C7F93BE30fad67524323396B36D7']`

## Events

- `AmountsReceived(uint256,uint256,uint256)`
- `Claimed(uint256,uint256,uint256,tuple)`
- `VestingStarted(uint256,uint256)`

## State-changing functions

- `claim(uint256,uint256,uint256)`
- `claimFrom(address,uint256,uint128,uint128)`
- `onAmountsReceived(uint256,uint256,uint256)`

## View functions

- `amounts(uint256)`
- `isAllowlisted(address)`
- `lastClaimed(uint256)`
- `maxCurrency0PerBlock()`
- `maxCurrency1PerBlock()`
- `onERC721Received(address,address,uint256,bytes)`
- `positionManager()`
- `recipient()`
- `totalAmounts(address)`
