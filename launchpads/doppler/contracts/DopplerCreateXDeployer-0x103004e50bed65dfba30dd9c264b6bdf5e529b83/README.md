# DopplerCreateXDeployer - 0x103004e50bed65dfba30dd9c264b6bdf5e529b83

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x103004e50bed65dfba30dd9c264b6bdf5e529b83
Role: DopplerCreateXDeployer.
Verified: True (verified at 2026-07-01T19:43:21.100575Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 0.
Main file: src/DopplerCreateXDeployer.sol.
Source files written: 4 under `sources/`.
Creator: 0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed.
Creation tx: 0x24996e26139cad95831f3112ed727ed9fd2f5b9b8b057916df166ba291cf1a6a.
Proxy type: None; implementations: [].

## Constructor arguments

- `newOwner` (address): `0xEDeAa06E2eB42A5c19ce27c6cfFb36fd4fE1eDa8`

## Events

- AdminAdded
- AdminRemoved
- Deployed
- DeployerAdded
- DeployerRemoved
- OwnershipHandoverCanceled
- OwnershipHandoverRequested
- OwnershipTransferred
- RolesRevoked
- RolesUpdated

## State-changing functions

- `addAdmins(address[])`
- `addDeployers(address[])`
- `cancelOwnershipHandover()`
- `completeOwnershipHandover(address)`
- `deployCreate2(bytes32,bytes)`
- `deployCreate2(bytes32,bytes,address)`
- `deployCreate3(bytes32,bytes)`
- `deployCreate3(bytes32,bytes,address)`
- `execute(address,bytes)`
- `execute(address[],uint256[],bytes[])`
- `grantRoles(address,uint256)`
- `removeAdmins(address[])`
- `removeDeployers(address[])`
- `renounceOwnership()`
- `renounceRoles(uint256)`
- `requestOwnershipHandover()`
- `revokeRoles(address,uint256)`
- `revokeRoles(address[])`
- `transferOwnership(address)`

## View functions

- `CreateX()`
- `computeCreate2Address(bytes32,bytes32)`
- `computeCreate3Address(bytes32)`
- `computeGuardedSalt(bytes32)`
- `generateSalt(string,uint256)`
- `hasAllRoles(address,uint256)`
- `hasAnyRole(address,uint256)`
- `owner()`
- `ownershipHandoverExpiresAt(address)`
- `rolesOf(address)`
