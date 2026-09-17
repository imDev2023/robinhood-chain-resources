<!-- source: https://developers.uniswap.org/docs/protocols/v4/guides/managing-liquidity/increase-liquidity | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/protocols/v4/guides/managing-liquidity/increase-liquidity.md (native markdown) -->
# Increase Liquidity (v4) (/docs/protocols/v4/guides/managing-liquidity/increase-liquidity)

Increase an existing Uniswap v4 position by encoding PositionManager actions and submitting `modifyLiquidities()`.

## Context
Please note that `PositionManager` is a command-based contract, where integrators will be encoding commands and their corresponding
parameters.

Increasing liquidity assumes the position already exists and the user wants to add more tokens to the position.

## Setup
See the [setup guide](/docs/protocols/v4/guides/managing-liquidity/getting-started)

## Guide
Below is a step-by-step guide for increasing a position's liquidity, in *solidity*.

## 1. Import and define IPositionManager
```solidity
import {IPositionManager} from "v4-periphery/src/interfaces/IPositionManager.sol";

// inside a contract, test, or foundry script:
IPositionManager posm = IPositionManager(<address>);
```

## 2. Encode actions
To increase a position's liquidity, the first action must be:

* *increase* operation - the addition of liquidity to an existing position.

For *delta resolving* operations, developers may need to choose between `SETTLE_PAIR`, `CLOSE_CURRENCY`, or `CLEAR_OR_TAKE` actions.

> In Uniswap v4, fee revenue is automatically credited to a position on increasing liquidity

> There are some cases, where the fee revenue can entirely "pay" for a liquidity increase, and remainder tokens need to be collected

If increasing the liquidity requires the transfer of both tokens:

* *settle pair* - pays a pair of tokens, to increase liquidity

**If increasing the liquidity for ETH positions, a third action is required:**

* *sweep* - to recover excess eth sent to the position manager

Otherwise:

* *close currency* - automatically determines if a currency should be settled or taken.
* OR *clear or take* - if the token amount to-be-collected is below a threshold, opt to forfeit the dust. Otherwise, claim the tokens

```solidity
import {Actions} from "v4-periphery/src/libraries/Actions.sol";
```

If both tokens need to be sent:

```solidity
bytes memory actions = abi.encodePacked(uint8(Actions.INCREASE_LIQUIDITY), uint8(Actions.SETTLE_PAIR));
```

If increasing liquidity for ETH positions:

```solidity
bytes memory actions = abi.encodePacked(uint8(Actions.INCREASE_LIQUIDITY), uint8(Actions.SETTLE_PAIR), uint8(Actions.SWEEP));
```

If converting fees to liquidity, and expect excess fees to be collected

```solidity
bytes memory actions = abi.encodePacked(uint8(Actions.INCREASE_LIQUIDITY), uint8(Actions.CLOSE_CURRENCY), uint8(Actions.CLOSE_CURRENCY));
```

If converting fees to liquidity, forfeiting dust:

```solidity
bytes memory actions = abi.encodePacked(uint8(Actions.INCREASE_LIQUIDITY), uint8(Actions.CLEAR_OR_TAKE), uint8(Actions.CLEAR_OR_TAKE));
```

## 3. Encoded parameters
When settling pair (for non-ETH positions):

```solidity
bytes[] memory params = new bytes[](2);
```

Otherwise:

```solidity
bytes[] memory params = new bytes[](3);
```

The `INCREASE_LIQUIDITY` action requires the following parameters:

| Parameter    | Type      | Description                                                            |
| ------------ | --------- | ---------------------------------------------------------------------- |
| `tokenId`    | *uint256* | position identifier                                                    |
| `liquidity`  | *uint256* | the amount of liquidity to add                                         |
| `amount0Max` | *uint128* | the maximum amount of currency0 liquidity msg.sender is willing to pay |
| `amount1Max` | *uint128* | the maximum amount of currency1 liquidity msg.sender is willing to pay |
| `hookData`   | *bytes*   | arbitrary data that will be forwarded to hook functions                |

```solidity
params[0] = abi.encode(tokenId, liquidity, amount0Max, amount1Max, hookData);
```

The `SETTLE_PAIR` action requires the following parameters:

* `currency0` - *Currency*, one of the tokens to be paid by msg.sender
* `currency1` - *Currency*, the other token to be paid by msg.sender

In the above case, the parameter encoding is:

```solidity
Currency currency0 = Currency.wrap(<tokenAddress1>); // tokenAddress1 = 0 for native ETH
Currency currency1 = Currency.wrap(<tokenAddress2>);
params[1] = abi.encode(currency0, currency1);
```

The `SWEEP` action requires the following parameters:

* `currency` - *Currency*, token to sweep - most commonly native Ether: `CurrencyLibrary.ADDRESS_ZERO`
* `recipient` - *address*, where to send excess tokens

In this case, the parameter encoding is:

```solidity
params[2] = abi.encode(currency, recipient);
```

The `CLOSE_CURRENCY` action requires only one `currency` parameter
and the encoding is:

```solidity
params[1] = abi.encode(currency0)
params[2] = abi.encode(currency1)
```

The `CLEAR_OR_TAKE` action requires one `currency` and:

* `amountMax` - *uint256*, the maximum threshold to concede dust,
  otherwise taking the dust.

In this case, the parameter encoding is:

```solidity
params[1] = abi.encode(currency0, amount0Max);
params[2] = abi.encode(currency1, amount1Max);
```

## 4. Submit call
The entrypoint for all liquidity operations is `modifyLiquidities()`.

```solidity
uint256 deadline = block.timestamp + 60;

uint256 valueToPass = currency0.isAddressZero() ? amount0Max : 0;

posm.modifyLiquidities{value: valueToPass}(
    abi.encode(actions, params),
    deadline
);
```
