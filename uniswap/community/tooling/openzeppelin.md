<!-- source: https://developers.uniswap.org/docs/community/tooling/openzeppelin | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/community/tooling/openzeppelin.md (native markdown) -->
# OpenZeppelin Uniswap Hooks (/docs/community/tooling/openzeppelin)

Modular Solidity hooks and base contracts for Uniswap v4 from OpenZeppelin.

[OpenZeppelin Uniswap Hooks](https://docs.openzeppelin.com/uniswap-hooks) is a Solidity library of secure, modular building blocks for Uniswap v4 hooks. It bundles base contracts, ready-to-use hooks, and utilities so teams can ship custom pool extensions on top of audited primitives.

> [!NOTE]
> This library is maintained by [OpenZeppelin](https://www.openzeppelin.com/) and is not an official Uniswap Labs product. It is provided as is, without warranties of any kind, including backward compatibility. Pin and audit any version used in production, and review release notes before upgrading.

## What it provides
* **Base implementations** for custom accounting, async swaps, and custom curves
* **Fee management** contracts such as `BaseDynamicFee` to update LP fees programmatically
* **Ready-to-use hooks** such as sandwich protection
* **Utilities and libraries** for common hook development patterns

## Installation
```bash
forge install OpenZeppelin/uniswap-hooks
```

Add the remapping to `remappings.txt`:

```text
@openzeppelin/uniswap-hooks/=lib/uniswap-hooks/src/
```

## Quick start
The example below uses `BaseDynamicFee` together with `Ownable` to let an owner update the LP fee at runtime.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseDynamicFee, IPoolManager, PoolKey} from "src/fee/BaseDynamicFee.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev A hook that allows the owner to dynamically update the LP fee.
 */
contract DynamicLPFeeHook is BaseDynamicFee, Ownable {
    uint24 public fee;

    constructor(IPoolManager _poolManager) BaseDynamicFee(_poolManager) Ownable(msg.sender) {
    }

    /**
     * @inheritdoc BaseDynamicFee
     */
    function _getFee(PoolKey calldata) internal view override returns (uint24) {
        return fee;
    }

    /**
     * @notice Sets the LP fee, denominated in hundredths of a bip.
     */
    function setFee(uint24 _fee) external onlyOwner {
        fee = _fee;
    }
}
```

> [!NOTE]
> `BaseDynamicFee.poke()` is publicly callable. If your fee logic depends on external conditions, restrict access or design `_getFee` to resist short-term manipulation.

## Resources
* [Documentation](https://docs.openzeppelin.com/uniswap-hooks)
* [GitHub repository](https://github.com/OpenZeppelin/uniswap-hooks)
* [OpenZeppelin](https://www.openzeppelin.com/)
