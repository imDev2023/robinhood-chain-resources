# FRouterV3-Impl-current - 0x09256b9D607c53fD946681F7C5a7a4381ba285A1

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x09256b9D607c53fD946681F7C5a7a4381ba285A1
Role: FRouterV3-Impl-current.
Contract name: FRouterV3.
Verified: True (verified at 2026-07-29T09:57:36.420643Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/launchpadv2/FRouterV3.sol.
Source files written: 24 under `sources/`.
Creator: 0x023d90298eDF920e989c3d7f89C49EB3007dB64b.
Creation tx: 0x9ad6a8ec66feab55e51c1bd3dc3ff6179a1a2a038ba5830337d059f101aecd83.
Proxy type: None; implementations: [].

Current FRouterV3 implementation.

## Constructor arguments

None decoded.

## Events

- `Initialized(uint64)`
- `PrivatePoolDrained(address,address,uint256,uint256)`
- `RoleAdminChanged(bytes32,bytes32,bytes32)`
- `RoleGranted(bytes32,address,address)`
- `RoleRevoked(bytes32,address,address)`
- `UniV2PoolDrained(address,address,address,uint256)`

## State-changing functions

- `addInitialLiquidity(address,uint256,uint256)`
- `approval(address,address,address,uint256)`
- `buy(uint256,address,address,bool)`
- `drainPrivatePool(address,address)`
- `drainUniV2Pool(address,address,address,uint256)`
- `graduate(address)`
- `grantRole(bytes32,address)`
- `initialize(address,address)`
- `renounceRole(bytes32,address)`
- `resetTime(address,uint256)`
- `revokeRole(bytes32,address)`
- `sell(uint256,address,address)`
- `setBondingV5(address,address)`
- `setTaxStartTime(address,uint256)`

## View functions

- `ADMIN_ROLE()`
- `BE_OPS_ROLE()`
- `DEFAULT_ADMIN_ROLE()`
- `EXECUTOR_ROLE()`
- `assetToken()`
- `bondingConfig()`
- `bondingV5()`
- `factory()`
- `getAmountsOut(address,address,uint256)`
- `getRoleAdmin(bytes32)`
- `hasAntiSniperTax(address)`
- `hasRole(bytes32,address)`
- `supportsInterface(bytes4)`
