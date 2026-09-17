## What it is

One example of what `LaunchFactory` deploys: a plain fixed-supply ERC-20 with no mint, no owner and no transfer hook.
The tax lives in the pool hook, not in the token, and the token only reports it: `buyTaxRate()` and `sellTaxRate()` proxy through to `LaunchHook.currentFeeRate(poolId, ...)` so tax scanners read a live number.
Included because it is the shape every HOOD10 Launchpad coin has.
