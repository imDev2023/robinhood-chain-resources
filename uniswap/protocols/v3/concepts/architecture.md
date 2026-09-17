<!-- source: https://developers.uniswap.org/docs/protocols/v3/concepts/architecture | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/protocols/v3/concepts/architecture.md (native markdown) -->
# Architecture (/docs/protocols/v3/concepts/architecture)

Understand Uniswap v3 architecture, including core contracts, factory design, and pool interaction patterns.

Uniswap v3 is a binary smart contract system comprised of many libraries, which together make the Core and Periphery.

Core contracts provide fundamental safety guarantees for all parties interacting with Uniswap. They define the logic of pool generation, the pools themselves, and the interactions involving the respective assets therein.

Periphery contracts interact with one or more Core contracts but are not part of the core. They are designed to provide methods of interacting with the core that increase clarity and user safety.

External calls will primarily call the periphery interfaces. Externally available functions are all viewable in the reference documentation. Internal functions are viewable on the Uniswap v3 GitHub repo.

## Core
The core consists of a single factory, a pool deployer, and the many pools the factory will create.

A significant amount of care and attention has been given to gas optimization in the core contracts. The result is a substantial reduction in gas costs for all protocol interactions compared to v2, at the cost of a reduction in code clarity.

> [!NOTE]
> **Source Code**
>
> [uniswap-v3-core](https://github.com/Uniswap/uniswap-v3-core)

## Factory
The factory defines the logic for generating pools. A pool is defined by two tokens, which make up the asset pair, and a fee. There can be multiple pools of the same asset pair, distinguished only by their swap fee.

> [!NOTE]
> Source code: [UniswapV3Factory.sol](https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/UniswapV3Factory.sol)

## Pools
Pools primarily serve as automated market makers for the paired assets. Additionally, they expose price oracle data and may be used as an asset source for flash transactions.

> [!NOTE]
> Source code: [UniswapV3Pool.sol](https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/UniswapV3Pool.sol)

## Periphery
The periphery is a constellation of smart contracts designed to support domain-specific interactions with the core. As the Uniswap protocol is a permissionless system, the contracts described below have no special privileges and are only a small subset of possible periphery-like contracts.

## SwapRouter
The swap router supports all the basic requirements of a front-end offering trading. It natively supports single trades (x to y) and multihop trades (e.g. x to y to z).

> [!NOTE]
> Source code: [SwapRouter.sol](https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/SwapRouter.sol)

## Nonfungible Position Manager
The position manager handles the logic transactions involving the creation, adjustment, or exiting of positions.

> [!NOTE]
> Source code: [NonfungiblePositionManager.sol](https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/NonfungiblePositionManager.sol)

## Oracle
The oracle provides price and liquidity data useful for a wide variety of system designs, and is available in every deployed pool.

> [!NOTE]
> Source code: [Oracle.sol](https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/libraries/Oracle.sol)

## Periphery libraries
The libraries provide a variety of helper functions developers may need, like calculating pool addresses, safe transfer functions, and more.

> [!NOTE]
> Source code: [libraries/](https://github.com/Uniswap/uniswap-v3-periphery/tree/main/contracts/libraries)
