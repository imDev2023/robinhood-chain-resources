# ACP-SubscriptionState - 0x58C1B1287c4FEA23AEc6CBBfa0ef32850525d777

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x58C1B1287c4FEA23AEc6CBBfa0ef32850525d777
Role: ACP-SubscriptionState.
Contract name: SubscriptionState.
Verified: True (verified at 2026-07-29T11:59:40.509714Z).
Compiler: v0.8.28+commit.7893614a, EVM cancun, optimizer True runs 200.
Main file: contracts/hooks/SubscriptionState.sol.
Source files written: 6 under `sources/`.
Creator: 0x9249A3E66942251BB613CBc89348eA1dFbA60C2b.
Creation tx: 0x28f34ee3fe25e42a0d3f21d3bba2ba08dcc1564b1d2bbd2201f57aec8cfc77a0.
Proxy type: None; implementations: [].

ACP subscription state.

## Constructor arguments

- `admin_` (address): `0xE220329659D41B2a9F26E83816B424bDAcF62567`

## Events

- `RoleAdminChanged(bytes32,bytes32,bytes32)`
- `RoleGranted(bytes32,address,address)`
- `RoleRevoked(bytes32,address,address)`

## State-changing functions

- `activateSubscription(address,address,uint256,uint256)`
- `grantRole(bytes32,address)`
- `renounceRole(bytes32,address)`
- `revokeRole(bytes32,address)`

## View functions

- `DEFAULT_ADMIN_ROLE()`
- `WRITER_ROLE()`
- `getRoleAdmin(bytes32)`
- `getSubscriptionExpiry(address,address,uint256)`
- `hasRole(bytes32,address)`
- `subscriptionExpiry(bytes32)`
- `supportsInterface(bytes4)`
