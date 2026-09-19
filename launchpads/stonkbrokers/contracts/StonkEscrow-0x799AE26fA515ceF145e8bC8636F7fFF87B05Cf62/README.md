# StonkEscrow - 0x799AE26fA515ceF145e8bC8636F7fFF87B05Cf62

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x799AE26fA515ceF145e8bC8636F7fFF87B05Cf62
Role: StonkEscrow.
Contract name: TokenEscrowReserve.
Verified: True (verified at 2026-07-17T23:37:49.587710Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/market/TokenEscrowReserve.sol.
Source files written: 16 under `sources/`.
Creator: 0xb668382cF44038a3E8140E789060F6A809787CDa.
Creation tx: 0xd3cced58994ef6cbe74073ae6c70dbff5569bbbbe48b608e2ef6a50092cac3dc.
Proxy type: None; implementations: [].

## Constructor arguments

- `token_` (address): `0xe934e36A439C94017B64a3FecE66AF12099aBF50`
- `ammCap_` (uint256): `2399997600000000000000000000`
- `loanCap_` (uint256): `266666400000000000000000000`
- `rewardCap_` (uint256): `0`
- `admin_` (address): `0xb668382cF44038a3E8140E789060F6A809787CDa`

## Events

- `BucketRebalanced(uint8,uint8,uint256)`
- `EscrowReleased(address,uint256,uint8)`
- `EscrowReturned(address,uint256,uint8)`
- `Paused(address)`
- `RoleAdminChanged(bytes32,bytes32,bytes32)`
- `RoleGranted(bytes32,address,address)`
- `RoleRevoked(bytes32,address,address)`
- `Unpaused(address)`

## State-changing functions

- `grantRole(bytes32,address)`
- `initializeVaults(address,address,address)`
- `initializeVaultsBatch(address[])`
- `pause()`
- `rebalanceBuckets(uint256,uint8,uint8)`
- `release(address,uint256,uint8)`
- `renounceRole(bytes32,address)`
- `returnTokens(uint256,uint8)`
- `revokeRole(bytes32,address)`
- `unpause()`

## View functions

- `DEFAULT_ADMIN_ROLE()`
- `PAUSER_ROLE()`
- `authorizedVaults(address)`
- `bucketBalance(uint8)`
- `checkInvariant()`
- `getRoleAdmin(bytes32)`
- `hasRole(bytes32,address)`
- `paused()`
- `supportsInterface(bytes4)`
- `token()`
- `totalReleased()`
- `totalSupply()`
- `vaultsInitialized()`
