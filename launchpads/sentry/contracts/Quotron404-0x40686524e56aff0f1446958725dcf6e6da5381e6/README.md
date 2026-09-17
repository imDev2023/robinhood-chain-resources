# Quotron404 - 0x40686524e56aff0f1446958725dcf6e6da5381e6

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x40686524e56aff0f1446958725dcf6e6da5381e6
Role: Quotron404.
Contract name: Quotron404.
Verified: True (verified at 2026-08-12T13:02:34.679877Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/Quotron404.sol.
Source files written: 3 under `sources/`.
Creator: 0x7171E64E979265aeD6588577D1c6b60A701d7866.
Creation tx: 0x451deafae85c0849f2150b425657e7a91b88bf4ccf807aa9c571468c314bb9ef.
Proxy type: None; implementations: [].

Quotrons ERC-404 style terminal contract.

## Constructor arguments

- `assignmentHash_` (bytes32): `0xd385f0257ffb1ca15f9fb7bafba1896d1c0af0cc413d552e46145f1b36200fd0`

## Events

- `Approval(address,address,uint256)`
- `Hardwired(uint256,address)`
- `Launched(uint256)`
- `PoolRoutingConfigured(address,address)`
- `SetupAllowed(address,bool)`
- `TerminalDissolved(uint256,address)`
- `TerminalMaterialized(uint256,address)`
- `Transfer(address,address,uint256)`
- `VenueCodehashBanned(bytes32,bool)`

## State-changing functions

- `approve(address,uint256)`
- `authorizePoolTransfer()`
- `banVenueCodehash(bytes32,bool)`
- `configurePoolRouting(address,address)`
- `freezeMetadata()`
- `hardwire(uint256)`
- `launch()`
- `mirrorTransfer(address,address,uint256)`
- `setBaseURIs(string,string)`
- `setExempt(address,bool)`
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
- `assignmentHash()`
- `balanceOf(address)`
- `bannedVenueCodehash(bytes32)`
- `darkBaseURI()`
- `decimals()`
- `erc721TransferExempt(address)`
- `floorHook()`
- `isHardwired(uint256)`
- `isLaunched()`
- `launchedAt()`
- `litBaseURI()`
- `metadataFrozen()`
- `mirror()`
- `name()`
- `nftBalanceOf(address)`
- `ownedIds(address)`
- `owner()`
- `ownerOfId(uint256)`
- `poolManager()`
- `poolSize()`
- `reflections()`
- `royaltyInfo(uint256,uint256)`
- `royaltyReceiver()`
- `setupAllowed(address)`
- `symbol()`
- `tokenURI(uint256)`
- `totalHardwired()`
- `totalSupply()`
- `transfersLocked()`
