<!-- source: https://developers.uniswap.org/docs/protocols/v4/concepts/subscribers | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/protocols/v4/concepts/subscribers.md (native markdown) -->
# Subscribers (/docs/protocols/v4/concepts/subscribers)

Learn how Uniswap v4 subscriber contracts receive position lifecycle notifications for custom integrations.

## What Subscribers Do
Subscribers, new in Uniswap v4, allow for liquidity-position owners to opt-in to a contract that receives *notifications*.
The new design is intended to support *liquidity mining*, additional rewards given to in-range liquidity providers. Through notification logic, position owners do not need
to risk their liquidity position and its underlying assets. In Uniswap v3, *liquidity mining* was supported by fully transferring the
liquidity position to an external contract; this old design would give the external contract full ownership and control of the liquidity position.

## Notification Lifecycle
When a position owner *subscribes* to a contract, the contract will receive notifications when:

* The position is initially subscribed

* The position increases or decreases its liquidity

* The position is transferred

* The position is unsubscribed
