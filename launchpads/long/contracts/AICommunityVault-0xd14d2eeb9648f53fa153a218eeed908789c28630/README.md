# AICommunityVault - 0xd14d2eeb9648f53fa153a218eeed908789c28630

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xd14d2eeb9648f53fa153a218eeed908789c28630
Role: AICommunityVault.
Contract name: TimelockController.
Verified: True (verified at 2026-07-31T09:43:17.956035Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/governance/TimelockController.sol.
Source files written: 13 under `sources/`.
Creator: 0x4A477bFb623a84A4a664F779cB0A202F6124B3E7.
Creation tx: 0x35011eead3b0a122a72ee20096abda1de744e53972cbb3569271601e109c0833.
Proxy type: None; implementations: [].

OpenZeppelin TimelockController created by LongCommunityFactory. Linked from the AI token page as `AI Community Vault`; holds the stock tokens routed there by Community mode.

## Constructor arguments

- `minDelay` (uint256): `172800`
- `proposers` (address[]): `[]`
- `executors` (address[]): `['0x0000000000000000000000000000000000000000']`
- `admin` (address): `0x4A477bFb623a84A4a664F779cB0A202F6124B3E7`

## Events

- `CallExecuted(bytes32,uint256,address,uint256,bytes)`
- `CallSalt(bytes32,bytes32)`
- `CallScheduled(bytes32,uint256,address,uint256,bytes,bytes32,uint256)`
- `Cancelled(bytes32)`
- `MinDelayChange(uint256,uint256)`
- `RoleAdminChanged(bytes32,bytes32,bytes32)`
- `RoleGranted(bytes32,address,address)`
- `RoleRevoked(bytes32,address,address)`

## State-changing functions

- `cancel(bytes32)`
- `execute(address,uint256,bytes,bytes32,bytes32)`
- `executeBatch(address[],uint256[],bytes[],bytes32,bytes32)`
- `grantRole(bytes32,address)`
- `onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)`
- `onERC1155Received(address,address,uint256,uint256,bytes)`
- `onERC721Received(address,address,uint256,bytes)`
- `renounceRole(bytes32,address)`
- `revokeRole(bytes32,address)`
- `schedule(address,uint256,bytes,bytes32,bytes32,uint256)`
- `scheduleBatch(address[],uint256[],bytes[],bytes32,bytes32,uint256)`
- `updateDelay(uint256)`

## View functions

- `CANCELLER_ROLE()`
- `DEFAULT_ADMIN_ROLE()`
- `EXECUTOR_ROLE()`
- `PROPOSER_ROLE()`
- `getMinDelay()`
- `getOperationState(bytes32)`
- `getRoleAdmin(bytes32)`
- `getTimestamp(bytes32)`
- `hasRole(bytes32,address)`
- `hashOperation(address,uint256,bytes,bytes32,bytes32)`
- `hashOperationBatch(address[],uint256[],bytes[],bytes32,bytes32)`
- `isOperation(bytes32)`
- `isOperationDone(bytes32)`
- `isOperationPending(bytes32)`
- `isOperationReady(bytes32)`
- `supportsInterface(bytes4)`
