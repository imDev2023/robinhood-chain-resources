<!-- source: https://developers.uniswap.org/docs/protocols/v4/guides/managing-liquidity/batch-liquidity | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/protocols/v4/guides/managing-liquidity/batch-liquidity.md (native markdown) -->
# Batch Modify (/docs/protocols/v4/guides/managing-liquidity/batch-liquidity)

Batch multiple Uniswap v4 liquidity operations in one PositionManager execution flow.

## Context
As seen in previous guides, `PositionManager` is a command-based contract. This design is conducive to
batching complex liquidity operations. For example, developers can encode efficient logic to move
liquidity between two positions on entirely different Pools.

## Setup
See the [setup guide](/docs/protocols/v4/guides/managing-liquidity/getting-started)

## Guide
Below is a general reference guide for batch-operating on multiple liquidity positions, in *solidity*.
This guide does *not* focus on a specific batch sequence, and is intended to be a general guide for `PositionManager`'s command-based interface.

## 1. Encoded actions
Actions are divided into two types: *liquidity-operations* and *delta-resolving*.

* *liquidity-operations* - actions which that incur a *balance-change*, a change in the pool's liquidity
* *delta-resolving* - actions which facilitate token transfers, such as *settling* and *taking*

The *ordering* of `actions` determines the sequence of operations. The minimum number of actions is roughly two actions; and the maximum is limited by block gas limit.
Additionally, *liquidity-operations* do not have to happen prior to *delta-resolving* actions. Developers can mix / alternate between
the two types of actions.

> **However** is good practice to perform *liquidity-operations* before *delta-resolving* actions. Minimizing token transfers
> and leveraging [*flash accounting*](/docs/protocols/v4/concepts/flash-accounting) is more gas efficient

Example: `Action.Y` happens after `Action.X` but before `Action.Z`

```solidity
import {Actions} from "v4-periphery/src/libraries/Actions.sol";

bytes memory actions = abi.encodePacked(uint8(Actions.X), uint8(Actions.Y), uint8(Actions.Z), ...);
```

**A Note on Special Actions**:

`PositionManager` supports a few *delta-resolving* actions beyond the standard `SETTLE` and `TAKE` actions

* `CLOSE_CURRENCY` - automatically determines if a currency should be settled (paid) or taken. Used for cases where callers may not know the final delta
* `CLEAR_OR_TAKE`- forfeit tokens if the amount is below a specified threshold, otherwise take the tokens. Used for cases where callers may expect to produce dust
* `SWEEP` - return any excess token balances to a recipient. Used for cases where callers may conversatively overpay tokens

## 2. Encoded parameters
Each action has its own parameters to encode. Generally:

* *liquidity-operations* - encode tokenIds, liquidity amounts, and slippage

* *delta-resolving* - encode currencies, amounts, and recipients

Because actions are ordered, the parameters "zip" with their corresponding actions. The second parameter corresponds to the second action.
Every action has its own encoded parameters

```solidity
bytes[] memory params = new bytes[](3);

params[0] = abi.encode(...); // parameters for the first action
params[1] = abi.encode(...); // parameters for the second action
params[2] = abi.encode(...); // parameters for the third action
```

## 3. Submit call
The entrypoint for all liquidity operations is `modifyLiquidities()`

```solidity
uint256 deadline = block.timestamp + 60;

posm.modifyLiquidities(
    abi.encode(actions, params),
    deadline
);
```
