# ACP-AgenticCommerceV3-Impl - 0xA1572Efb913F7c3Ca64825eB96906E9a1945ecDe

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xA1572Efb913F7c3Ca64825eB96906E9a1945ecDe
Role: ACP-AgenticCommerceV3-Impl.
Contract name: AgenticCommerceV3.
Verified: True (verified at 2026-07-07T14:51:49.320270Z).
Compiler: v0.8.28+commit.7893614a, EVM cancun, optimizer True runs 200.
Main file: contracts/AgenticCommerceV3.sol.
Source files written: 28 under `sources/`.
Creator: 0x794aa81b4B5ba936742C699DD767F37ba7b51D87.
Creation tx: 0x652af8d8913a23b1e9c26d9e1208e1f3c2d1fe5999062dd98fecc33920b165d3.
Proxy type: None; implementations: [].

AgenticCommerceV3 implementation.

## Constructor arguments

None decoded.

## Events

- `BudgetSet(uint256,uint256)`
- `EmergencyWithdraw(address,address,uint256)`
- `EvaluatorFeePaid(uint256,address,uint256)`
- `EvaluatorFeeUpdated(uint256)`
- `HookDetached(uint256,address)`
- `HookWhitelistUpdated(address,bool)`
- `Initialized(uint64)`
- `JobCompleted(uint256,address,bytes32)`
- `JobCreated(uint256,address,address,address,uint256,address)`
- `JobExpired(uint256)`
- `JobFunded(uint256,address,uint256)`
- `JobRejected(uint256,address,bytes32)`
- `JobSubmitted(uint256,address,bytes32)`
- `Paused(address)`
- `PaymentReleased(uint256,address,uint256)`
- `PlatformFeeUpdated(uint256,address)`
- `ProviderSet(uint256,address)`
- `Refunded(uint256,address,uint256)`
- `RoleAdminChanged(bytes32,bytes32,bytes32)`
- `RoleGranted(bytes32,address,address)`
- `RoleRevoked(bytes32,address,address)`
- `Unpaused(address)`
- `Upgraded(address)`

## State-changing functions

- `batchDetachHook(uint256[])`
- `claimRefund(uint256)`
- `complete(uint256,bytes32,bytes)`
- `createJob(address,address,uint256,string,address)`
- `emergencyWithdraw(address,address,uint256)`
- `fund(uint256,uint256,bytes)`
- `grantRole(bytes32,address)`
- `initialize(address,address,address)`
- `pause()`
- `reject(uint256,bytes32,bytes)`
- `renounceRole(bytes32,address)`
- `revokeRole(bytes32,address)`
- `setBudget(uint256,uint256,bytes)`
- `setEvaluatorFee(uint256)`
- `setHookWhitelist(address,bool)`
- `setPlatformFee(uint256,address)`
- `setProvider(uint256,address)`
- `submit(uint256,bytes32,bytes)`
- `unpause()`
- `upgradeToAndCall(address,bytes)`

## View functions

- `ADMIN_ROLE()`
- `DEFAULT_ADMIN_ROLE()`
- `EVALUATOR_GRACE_PERIOD()`
- `UPGRADE_INTERFACE_VERSION()`
- `evaluatorFeeBP()`
- `getJob(uint256)`
- `getRoleAdmin(bytes32)`
- `hasRole(bytes32,address)`
- `jobCounter()`
- `jobs(uint256)`
- `paused()`
- `paymentToken()`
- `platformFeeBP()`
- `platformTreasury()`
- `proxiableUUID()`
- `supportsInterface(bytes4)`
- `whitelistedHooks(address)`
