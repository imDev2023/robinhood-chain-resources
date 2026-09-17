# QuotronsToken - 0x5a86828efd322bfb16d93cfed16ee9bc14940d7f

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x5a86828efd322bfb16d93cfed16ee9bc14940d7f
Role: QuotronsToken.
Contract name: Quotron404V2.
Verified: True (verified at 2026-08-13T15:18:16.460218Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/v2/Quotron404V2.sol.
Source files written: 3 under `sources/`.
Creator: 0x7171E64E979265aeD6588577D1c6b60A701d7866.
Creation tx: 0x222e4f9f70c27861cc7cde992d73f8ce19b1db1910978c27cdb99c3fd444b13c.
Proxy type: None; implementations: [].

QUOTRONS ERC-20, the sibling Mavrk product's token and the largest market on Sentry's Discover list.

## Constructor arguments

- `assignmentHash_` (bytes32): `0xd385f0257ffb1ca15f9fb7bafba1896d1c0af0cc413d552e46145f1b36200fd0`

## Events

- `Approval(address,address,uint256)`
- `BlacklistUpdated(address,bool,address)`
- `EmergencyControlsConfigured(address,address)`
- `Hardwired(uint256,address)`
- `Launched(uint256)`
- `MigratedDark(uint256,address)`
- `MigratedFractional(address,uint256)`
- `MigratedHardwired(uint256,address)`
- `MigrationConfigured(address,address)`
- `Paused(bool)`
- `PoolRoutingConfigured(address,address,address)`
- `QuotronRecovered(address,address,uint256)`
- `SetupAllowed(address,bool)`
- `TerminalDissolved(uint256,address)`
- `TerminalMaterialized(uint256,address)`
- `TerminalRecovered(address,address,uint256,bool)`
- `Transfer(address,address,uint256)`
- `VenueCodehashBanned(bytes32,bool)`

## State-changing functions

- `adminTransferQuotron(address,address,uint256)`
- `adminTransferTerminal(address,address,uint256)`
- `approve(address,uint256)`
- `authorizePoolTransfer(int128)`
- `banVenueCodehash(bytes32,bool)`
- `configureEmergencyControls(address,address)`
- `configureMigration(address,address)`
- `configurePoolRouting(address,address,address)`
- `freezeMetadata()`
- `hardwire(uint256)`
- `launch()`
- `migrateDark(address,uint256)`
- `migrateFractional(address,uint256)`
- `migrateHardwired(address,uint256)`
- `mirrorTransfer(address,address,uint256)`
- `setBaseURIs(string,string)`
- `setBlacklisted(address,bool)`
- `setExempt(address,bool)`
- `setPaused(bool)`
- `setReflections(address)`
- `setRoyaltyReceiver(address)`
- `setSetupAllowed(address,bool)`
- `transfer(address,uint256)`
- `transferFrom(address,address,uint256)`
- `transferOwnership(address)`

## View functions

- `MAX_ID()`
- `ROYALTY_BPS()`
- `UNIT()`
- `allowance(address,address)`
- `assertPoolTransferAuthorizationConsumed()`
- `assignmentHash()`
- `balanceOf(address)`
- `bannedVenueCodehash(bytes32)`
- `blacklistGuardian()`
- `blacklisted(address)`
- `canonicalRouter()`
- `darkBaseURI()`
- `darkOwned(address)`
- `decimals()`
- `economicUnits()`
- `emergencyControlsConfigured()`
- `erc721TransferExempt(address)`
- `floorHook()`
- `hardwiredOwned(address)`
- `isHardwired(uint256)`
- `isIdAvailable(uint256)`
- `isLaunched()`
- `isProtectedAccount(address)`
- `launchedAt()`
- `litBaseURI()`
- `metadataFrozen()`
- `migrationConfigured()`
- `migrationOperator()`
- `migrationReserve()`
- `mirror()`
- `name()`
- `nftBalanceOf(address)`
- `ownedIds(address)`
- `owner()`
- `ownerOfId(uint256)`
- `paused()`
- `poolManager()`
- `poolSize()`
- `recoveryAdmin()`
- `reflections()`
- `royaltyInfo(uint256,uint256)`
- `royaltyReceiver()`
- `setupAllowed(address)`
- `setupAllowedCount()`
- `symbol()`
- `tokenURI(uint256)`
- `totalHardwired()`
- `totalSupply()`
- `transfersLocked()`
