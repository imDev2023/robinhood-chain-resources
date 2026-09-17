## Identified by selector matching

The current implementation behind the CashCat proxy, unverified.
Selectors were extracted from `bytecode.hex` and resolved against openchain.xyz (`_raw/blockscout/selectors-cashcatfactoryimpl.txt` and `selectors-cashcatfactoryimpl-resolved.json`): 97 of 162 candidates resolved.

It is a UUPS-upgradeable launch factory: `upgradeToAndCall`, `proxiableUUID`, `UPGRADE_INTERFACE_VERSION`, `initializeVNext()`, `MODULE_GENERATION()`, `publishModuleSet`, `getModuleSet`, `publishConfig`, `getLaunchConfig`, `setLaunchConfigEnabled`, `launchFee`/`setLaunchFee`, `launchEnabled`/`setLaunchEnabled`, `approvedQuote`/`setApprovedQuote`, `airdropVaultMaster`/`airdropVaultOf`, `launchSplitterOf`, `currentSplitterOf`, `treasury`/`setTreasury`, plus `VanityAddressRequired()`, `QuoteNotApproved()` and the v4 `unlockCallback`/`modifyLiquidity`/`swap` surface.

`approvedQuote(address)` is the allowlist the HOOD10 `QuoteRegistry` natspec refers to when it says "the incumbent pad on this chain restricts launches to an approved ERC-20".
