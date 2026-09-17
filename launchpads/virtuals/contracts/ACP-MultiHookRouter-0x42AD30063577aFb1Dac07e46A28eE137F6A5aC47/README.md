# ACP-MultiHookRouter - 0x42AD30063577aFb1Dac07e46A28eE137F6A5aC47

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x42AD30063577aFb1Dac07e46A28eE137F6A5aC47
Role: ACP-MultiHookRouter.
Contract name: MultiHookRouter.
Verified: True (verified at 2026-07-27T08:55:46.151407Z).
Compiler: v0.8.28+commit.7893614a, EVM cancun, optimizer True runs 200.
Main file: contracts/hooks/MultiHookRouter.sol.
Source files written: 31 under `sources/`.
Creator: 0xe661a05ce4CcF69E668b4A7bF08Dd4336c7F6e72.
Creation tx: 0x1a1c9bf2983bcd5c2afba30650d4f7a6730fd2a6a6c348f02dc225049b0d6344.
Proxy type: None; implementations: [].

ACP hook router.

## Constructor arguments

- `acpContract_` (address): `0x62891d58E1321D92f338901a433C2699AadaF2c1`
- `maxHooksPerJob_` (uint256): `5`

## Events

- `DewhitelistedHookSkipped(uint256,bytes4,address)`
- `HookAdded(uint256,bytes4,address,uint256)`
- `HookRemoved(uint256,bytes4,address)`
- `HooksConfigured(uint256,bytes4,address[])`
- `HooksReordered(uint256,bytes4,address[])`
- `MaxHooksPerJobUpdated(uint256,uint256)`

## State-changing functions

- `addHook(uint256,bytes4,address)`
- `afterAction(uint256,bytes4,bytes)`
- `batchConfigureHooks(uint256,bytes4[],address[][])`
- `beforeAction(uint256,bytes4,bytes)`
- `configureHooks(uint256,bytes4,address[])`
- `removeHook(uint256,bytes4,address)`
- `reorderHooks(uint256,bytes4,address[])`
- `setMaxHooksPerJob(uint256)`

## View functions

- `acpContract()`
- `getHooks(uint256,bytes4)`
- `getJob(uint256)`
- `hookCount(uint256,bytes4)`
- `maxHooksPerJob()`
- `paymentToken()`
- `supportsInterface(bytes4)`
