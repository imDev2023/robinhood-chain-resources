## What it does

The fee engine and the liquidity lock.
`beforeInitialize` refuses any pool not opened by the factory, `beforeAddLiquidity` allows exactly one seed add per pool, and `beforeRemoveLiquidity` always reverts, which is what makes the liquidity permanent.
`beforeSwap`/`afterSwap` take the fee on the quote side and book it as ERC-6909 claims against the PoolManager.
`PROTOCOL_FEE_PIPS` is 10000, a fixed 1%; `MAX_CREATOR_FEE_BPS` is 900, a 9% creator add-on; `MAX_FEE_RATE` is 100000, a hard 10% ceiling including the anti-snipe surge.
The surge decays linearly to zero over `snipeWindow` blocks.
`settle` is permissionless and splits accrued fees into `creatorTab` and `platformTab`; only `feeRouter` may call `collectPlatform`.
Live state at capture: `owner` 0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862, `feeRouter` **0xbd40E13889Cd75D8019CfbaA4f3C5562ba242279, which is an EOA, not the FeeRouter contract in this archive** (`_raw/rpc/router-updates.txt`).
