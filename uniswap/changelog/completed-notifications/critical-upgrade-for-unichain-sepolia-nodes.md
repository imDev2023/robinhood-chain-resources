<!-- source: https://developers.uniswap.org/docs/changelog/completed-notifications/critical-upgrade-for-unichain-sepolia-nodes | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/changelog/completed-notifications/critical-upgrade-for-unichain-sepolia-nodes.md (native markdown) -->
# Critical Upgrade for Unichain-Sepolia Nodes (/docs/changelog/completed-notifications/critical-upgrade-for-unichain-sepolia-nodes)

Posted: March 15, 2025 | Effective: March 20, 2025

OP Labs identified a bug affecting OP Stack Sepolia chains (not mainnet), causing temporary L1 fee overcharging.

This issue was fixed in the [latest `op-node` release](https://github.com/ethereum-optimism/optimism/releases/tag/op-node%2Fv1.12.0).

> [!NOTE]
> **Action Required by March 20!**
>
> Please upgrade to:
> 
>   * `op-node version v1.12.0`
>   * `op-geth version v1.101503.0`
> 
>   If you use the network flag `--network=unichain-sepolia`, the upgrade activates automatically.
> 
>   Otherwise, add this to your `rollup.json`: `"pectra_blob_schedule_time": 1742486400`
> 
>   **All node and chain operators must update before the Ethereum Pectra activation.**

> [!NOTE]
> Full release notes and instructions: [OP release notes](https://github.com/ethereum-optimism/optimism/releases/tag/op-node%2Fv1.12.0) and [OP Labs announcement](https://x.com/OPLabsPBC/status/1901677186693636284).
