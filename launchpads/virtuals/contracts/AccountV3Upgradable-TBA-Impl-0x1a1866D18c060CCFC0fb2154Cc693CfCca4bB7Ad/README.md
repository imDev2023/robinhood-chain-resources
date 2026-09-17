# AccountV3Upgradable-TBA-Impl - 0x1a1866D18c060CCFC0fb2154Cc693CfCca4bB7Ad

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x1a1866D18c060CCFC0fb2154Cc693CfCca4bB7Ad
Role: AccountV3Upgradable-TBA-Impl.
Contract name: AccountV3Upgradable.
Verified: True (verified at 2026-07-02T07:08:55.041755Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/tba/AccountV3Upgradable.sol.
Source files written: 55 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0x08b6c692ffa166d5268e8424965efb145dff36d2a42b227cd578f2d41ffb579e.
Proxy type: None; implementations: [].

Tokenbound AccountV3 implementation referenced by BondingConfig.deployParams.

## Constructor arguments

- `entryPoint_` (address): `0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789`
- `multicallForwarder` (address): `0x0000000000000000000000000000000000000000`
- `erc6551Registry` (address): `0xf504AB63fD11871f2A4d356989273F02c219B467`
- `guardian` (address): `0x0000000000000000000000000000000000000000`

## Events

- `LockUpdated(uint256)`
- `OverrideUpdated(address,bytes4,address)`
- `PermissionUpdated(address,address,bool)`
- `Upgraded(address)`

## State-changing functions

- `execute(address,uint256,bytes,uint8)`
- `executeBatch(tuple[])`
- `executeNested(address,uint256,bytes,uint8,tuple[])`
- `extcall(address,uint256,bytes)`
- `extcreate(uint256,bytes)`
- `extcreate2(uint256,bytes32,bytes)`
- `lock(uint256)`
- `onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)`
- `onERC1155Received(address,address,uint256,uint256,bytes)`
- `onERC721Received(address,address,uint256,bytes)`
- `setOverrides(bytes4[],address[])`
- `setPermissions(address[],bool[])`
- `upgradeToAndCall(address,bytes)`
- `validateUserOp(tuple,bytes32,uint256)`

## View functions

- `UPGRADE_INTERFACE_VERSION()`
- `entryPoint()`
- `erc6551Registry()`
- `extsload(bytes32)`
- `getNonce()`
- `isLocked()`
- `isTrustedForwarder(address)`
- `isValidSignature(bytes32,bytes)`
- `isValidSigner(address,bytes)`
- `lockedUntil()`
- `overrides(address,bytes4)`
- `owner()`
- `permissions(address,address)`
- `proxiableUUID()`
- `state()`
- `supportsInterface(bytes4)`
- `token()`
- `trustedForwarder()`
