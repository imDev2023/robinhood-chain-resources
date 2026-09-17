# HoodStockFactory - 0x1811F54e2964758641AaC993cA91F9189a8BdA2d

Role: HoodStockFactory.
Address: `0x1811F54e2964758641AaC993cA91F9189a8BdA2d` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x1811F54e2964758641AaC993cA91F9189a8BdA2d
Verified: True (fully verified: True, partially: False).
Compiler: v0.8.28+commit.7893614a, EVM prague, optimizer True runs 200.
Language: solidity. License: none.
Proxy type: basic_implementation. Implementations: ['0xECF1533F94EB3547FdFF9B50b6173529Aa4E0a33'].
Main source file: `src/HoodStockRewards.sol`. Source files written: 16 under `sources/`.
Raw constructor args: `0x0000000000000000000000008c529f0a77c07ce0e6796f153d292501ee6f66f60000000000000000000000008e96a84adc54d04869ded92661a01f75e283741b00000000000000000000000095b02ad7dd7eb6bdeff56cc57b0bda601862ad8300000000000000000000000078f3556b67e17df817d51ef5a990cdaf09e8d3a90000000000000000000000000000000000000000000000000000000000003840000000000000000000000000000000000000000000000000000000000000012c0000000000000000000000000000000000000000000000000000000000000e1000000000000000000000000000000000000000000000000000000000000009c4000000000000000000000000379ec4f7c378f34a1b47e4f3cbebcbac3e8e9f150000000000000000000000000000000000000000000000000000000000000e10`.

Decoded constructor args:
- launchpad_ (address): `0x8c529f0a77C07CE0e6796f153D292501eE6F66f6`
- owner_ (address): `0x8E96a84AdC54d04869ded92661a01f75e283741B`
- publisher_ (address): `0x95b02Ad7DD7EB6Bdeff56cC57B0Bda601862aD83`
- ethUsdFeed_ (address): `0x78F3556b67E17Df817D51Ef5a990cDaF09E8d3A9`
- ethUsdMaxStaleness_ (uint32): `14400`
- premiumBps_ (uint16): `300`
- epochLength_ (uint32): `3600`
- epochReleaseBps_ (uint16): `2500`
- marketHeartbeatFeed_ (address): `0x379EC4f7C378F34a1B47E4F3cbeBCbAC3E8E9F15`
- marketHeartbeatMaxAge_ (uint32): `3600`

## Functions

- `MAX_HEARTBEAT_AGE()` -> uint32 [view]
- `MAX_PREMIUM_BPS()` -> uint16 [view]
- `MAX_STALENESS_CEILING()` -> uint32 [view]
- `allStockTokens(uint256)` -> address [view]
- `assetConfig(address token)` -> bool, address, uint32, uint8 [view]
- `assetCount()` -> uint256 [view]
- `assetList(uint256)` -> address [view]
- `assetOf(address token)` -> address [view]
- `assets(address stockToken)` -> bool, address, uint32, uint8 [view]
- `epochConfig()` -> uint32, uint16 [view]
- `epochLength()` -> uint32 [view]
- `epochReleaseBps()` -> uint16 [view]
- `ethUsdConfig()` -> address, uint32 [view]
- `ethUsdFeed()` -> address [view]
- `ethUsdMaxStaleness()` -> uint32 [view]
- `implementation()` -> address [view]
- `isStockCoin(address token)` -> bool [view]
- `launchStockCoin(string name, string symbol, string metadataURI, bytes32 salt, uint16 tradeFeeBps, uint256 totalSupply_, address targetAsset, uint256 devBuyEth, uint256 minDevTokensOut)` -> address, address [payable]
- `launchpad()` -> address [view]
- `marketHeartbeat()` -> address, uint32 [view]
- `marketHeartbeatFeed()` -> address [view]
- `marketHeartbeatMaxAge()` -> uint32 [view]
- `maxDistributeBps()` -> uint16 [view]
- `owner()` -> address [view]
- `predictVault(address caller, bytes32 salt)` -> address [view]
- `premiumBps()` -> uint16 [view]
- `publisher()` -> address [view]
- `renounceOwnership()` ->  [nonpayable]
- `sellPaused()` -> bool [view]
- `setAsset(address token, bool enabled, address usdFeed, uint32 maxStaleness)` ->  [nonpayable]
- `setConfig(uint16 premiumBps_, uint32 epochLength_, uint16 epochReleaseBps_)` ->  [nonpayable]
- `setEthUsdFeed(address feed, uint32 maxStaleness)` ->  [nonpayable]
- `setMarketHeartbeat(address feed, uint32 maxAge)` ->  [nonpayable]
- `setMaxDistributeBps(uint16 bps)` ->  [nonpayable]
- `setPublisher(address publisher_)` ->  [nonpayable]
- `setSellPaused(bool paused)` ->  [nonpayable]
- `stockCoinCount()` -> uint256 [view]
- `stockVaultOf(address token)` -> address [view]
- `transferOwnership(address newOwner)` ->  [nonpayable]

## Events

- `AssetSet(address token, bool enabled, address usdFeed, uint32 maxStaleness)`
- `ConfigSet(uint16 premiumBps, uint32 epochLength, uint16 epochReleaseBps)`
- `EthUsdFeedSet(address feed, uint32 maxStaleness)`
- `MarketHeartbeatSet(address feed, uint32 maxAge)`
- `MaxDistributeBpsSet(uint16 bps)`
- `OwnershipTransferred(address previousOwner, address newOwner)`
- `PublisherSet(address publisher)`
- `SellPausedSet(bool paused)`
- `StockCoinLaunched(address token, address vault, address launcher, address asset)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
