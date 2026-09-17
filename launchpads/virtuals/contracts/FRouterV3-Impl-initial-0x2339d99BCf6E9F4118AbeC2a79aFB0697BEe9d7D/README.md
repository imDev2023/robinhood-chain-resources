# FRouterV3-Impl-initial - 0x2339d99BCf6E9F4118AbeC2a79aFB0697BEe9d7D

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x2339d99BCf6E9F4118AbeC2a79aFB0697BEe9d7D
Role: FRouterV3-Impl-initial.
Contract name: FRouterV3.
Verified: True (verified at 2026-07-02T07:02:31.423840Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/launchpadv2/FRouterV3.sol.
Source files written: 24 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0x61ce0ce96274728e94a7e05d93fcb9c60c8ff0980f92caded0c079f046f0a7cc.
Proxy type: None; implementations: [].

First FRouterV3 implementation (2026-06-25); superseded.

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
