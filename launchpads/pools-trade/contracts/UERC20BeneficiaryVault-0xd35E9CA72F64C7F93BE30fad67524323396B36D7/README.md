# UERC20BeneficiaryVault - 0xd35E9CA72F64C7F93BE30fad67524323396B36D7

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xd35E9CA72F64C7F93BE30fad67524323396B36D7
Role: UERC20BeneficiaryVault.
Contract name: UERC20BeneficiaryVault.
Verified: True (sources from `smart-contracts`, flag from `addresses`).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/periphery/UERC20BeneficiaryVault.sol.
Source files written: 38 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x3f69bc106e72f99dbda62a93ca9427a1a6a329de7981f799e2c2ec8168248bf8.
Proxy type: None; implementations: [].

## Constructor arguments

- `_positionManager` (address): `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `_nativeFallback` (address): `0x2aC03e14Cfe755426DaAEe0a4994184Ce81482F8`
- `_tokenFallback` (address): `0x000000000000000000000000000000000000dEaD`

## Events

- `AmountsReceived(uint256,uint256,uint256)`
- `Approval(address,address,uint256)`
- `ApprovalForAll(address,address,bool)`
- `Claimed(uint256,uint256,uint256,tuple)`
- `Transfer(address,address,uint256)`

## State-changing functions

- `approve(address,uint256)`
- `claim(uint256,uint256,uint256)`
- `onAmountsReceived(uint256,uint256,uint256)`
- `registerBeneficiary(uint256,address)`
- `safeTransferFrom(address,address,uint256)`
- `safeTransferFrom(address,address,uint256,bytes)`
- `setApprovalForAll(address,bool)`
- `transferFrom(address,address,uint256)`

## View functions

- `amounts(uint256)`
- `balanceOf(address)`
- `getApproved(uint256)`
- `isApprovedForAll(address,address)`
- `name()`
- `nativeFallback()`
- `ownerOf(uint256)`
- `positionManager()`
- `supportsInterface(bytes4)`
- `symbol()`
- `tokenFallback()`
- `tokenURI(uint256)`
- `totalAmounts(address)`
