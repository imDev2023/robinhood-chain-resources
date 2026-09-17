# QuotronMirrorV2 - 0x027aca2794e44f24950d81227dcd516ffbb49d6e

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x027aca2794e44f24950d81227dcd516ffbb49d6e
Role: QuotronMirrorV2.
Contract name: QuotronMirrorV2.
Verified: True (verified at 2026-08-13T15:21:14.675152Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/v2/QuotronMirrorV2.sol.
Source files written: 1 under `sources/`.
Creator: 0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F.
Creation tx: 0x222e4f9f70c27861cc7cde992d73f8ce19b1db1910978c27cdb99c3fd444b13c.
Proxy type: None; implementations: [].

Quotrons V2 NFT mirror.

## Constructor arguments

- `base_` (address): `0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F`

## Events

- `Approval(address,address,uint256)`
- `ApprovalForAll(address,address,bool)`
- `Transfer(address,address,uint256)`
- `TransferValidatorUpdated(address,address)`

## State-changing functions

- `approve(address,uint256)`
- `clearApproval(address,uint256)`
- `emitTransfer(address,address,uint256)`
- `safeTransferFrom(address,address,uint256)`
- `safeTransferFrom(address,address,uint256,bytes)`
- `setApprovalForAll(address,bool)`
- `setTransferValidator(address)`
- `transferFrom(address,address,uint256)`

## View functions

- `balanceOf(address)`
- `base()`
- `getApproved(uint256)`
- `getTransferValidationFunction()`
- `getTransferValidator()`
- `isApprovedForAll(address,address)`
- `name()`
- `owner()`
- `ownerOf(uint256)`
- `royaltyInfo(uint256,uint256)`
- `supportsInterface(bytes4)`
- `symbol()`
- `tokenURI(uint256)`
