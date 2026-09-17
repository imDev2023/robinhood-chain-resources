# CashCatFactory-current-impl-unverified - 0x40250b4C73FC30f8F6ad077744B0124B3f111C28

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x40250b4C73FC30f8F6ad077744B0124B3f111C28
Role: CashCatFactory-current-impl-unverified.
Contract name: unknown (unverified).
Verified: None (verified at None).
Compiler: None, EVM None, optimizer None runs None.
Main file: None.
Sources: none (unverified); `bytecode.hex` holds the deployed bytecode.
Creator: 0x0679f72DCC42d8fBEB19FC2e0215Be8e7C090881.
Creation tx: 0x12ded6362aeede695b33cb9c48f9defa41d2b149b7412b27897f813bcbf7fbb5.
Proxy type: None; implementations: [].
External libraries: none.

## Identified by selector matching

The current implementation behind the CashCat proxy, unverified.
Selectors were extracted from `bytecode.hex` and resolved against openchain.xyz (`_raw/blockscout/selectors-cashcatfactoryimpl.txt` and `selectors-cashcatfactoryimpl-resolved.json`): 97 of 162 candidates resolved.

It is a UUPS-upgradeable launch factory: `upgradeToAndCall`, `proxiableUUID`, `UPGRADE_INTERFACE_VERSION`, `initializeVNext()`, `MODULE_GENERATION()`, `publishModuleSet`, `getModuleSet`, `publishConfig`, `getLaunchConfig`, `setLaunchConfigEnabled`, `launchFee`/`setLaunchFee`, `launchEnabled`/`setLaunchEnabled`, `approvedQuote`/`setApprovedQuote`, `airdropVaultMaster`/`airdropVaultOf`, `launchSplitterOf`, `currentSplitterOf`, `treasury`/`setTreasury`, plus `VanityAddressRequired()`, `QuoteNotApproved()` and the v4 `unlockCallback`/`modifyLiquidity`/`swap` surface.

`approvedQuote(address)` is the allowlist the HOOD10 `QuoteRegistry` natspec refers to when it says "the incumbent pad on this chain restricts launches to an approved ERC-20".

## Constructor arguments

None decoded.

## Events

None.

## State-changing functions

None.

## View functions

None.
