# CCIP-BurnMintTokenPool - 0x78680385fcb8187ac1b28E0d6b1e0ACf5e0d0992

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x78680385fcb8187ac1b28E0d6b1e0ACf5e0d0992
Role: CCIP-BurnMintTokenPool.
Contract name: BurnMintTokenPool.
Verified: True (verified at 2026-07-02T08:29:54.298893Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 80000.
Main file: contracts/pools/BurnMintTokenPool.sol.
Source files written: 18 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0xa54172603544a37df0e16c9eaf110add587e141a7c40f5ec80d5182bdcf39d6d.
Proxy type: None; implementations: [].

Chainlink CCIP token pool that mints and burns VIRTUAL on Robinhood Chain. This is how VIRTUAL reached chain 4663 (no canonical Arbitrum bridge wrapper).

## Constructor arguments

- `token` (address): `0xc6911796042b15d7Fa4F6CDe69e245DdCd3d9c31`
- `localTokenDecimals` (uint8): `18`
- `allowlist` (address[]): `[]`
- `rmnProxy` (address): `0xe8464c353210Cc398A45dB2454FBc5BCd25fFf20`
- `router` (address): `0x06fC836cf9839B1cd891C440A0a45242DA6Ae1c9`

## Events

- `AllowListAdd(address)`
- `AllowListRemove(address)`
- `ChainAdded(uint64,bytes,tuple,tuple)`
- `ChainConfigured(uint64,tuple,tuple)`
- `ChainRemoved(uint64)`
- `ConfigChanged(tuple)`
- `InboundRateLimitConsumed(uint64,address,uint256)`
- `LockedOrBurned(uint64,address,address,uint256)`
- `OutboundRateLimitConsumed(uint64,address,uint256)`
- `OwnershipTransferRequested(address,address)`
- `OwnershipTransferred(address,address)`
- `RateLimitAdminSet(address)`
- `ReleasedOrMinted(uint64,address,address,address,uint256)`
- `RemotePoolAdded(uint64,bytes)`
- `RemotePoolRemoved(uint64,bytes)`
- `RouterUpdated(address,address)`

## State-changing functions

- `acceptOwnership()`
- `addRemotePool(uint64,bytes)`
- `applyAllowListUpdates(address[],address[])`
- `applyChainUpdates(uint64[],tuple[])`
- `lockOrBurn(tuple)`
- `releaseOrMint(tuple)`
- `removeRemotePool(uint64,bytes)`
- `setChainRateLimiterConfig(uint64,tuple,tuple)`
- `setChainRateLimiterConfigs(uint64[],tuple[],tuple[])`
- `setRateLimitAdmin(address)`
- `setRouter(address)`
- `transferOwnership(address)`

## View functions

- `getAllowList()`
- `getAllowListEnabled()`
- `getCurrentInboundRateLimiterState(uint64)`
- `getCurrentOutboundRateLimiterState(uint64)`
- `getRateLimitAdmin()`
- `getRemotePools(uint64)`
- `getRemoteToken(uint64)`
- `getRmnProxy()`
- `getRouter()`
- `getSupportedChains()`
- `getToken()`
- `getTokenDecimals()`
- `isRemotePool(uint64,bytes)`
- `isSupportedChain(uint64)`
- `isSupportedToken(address)`
- `owner()`
- `supportsInterface(bytes4)`
- `typeAndVersion()`
