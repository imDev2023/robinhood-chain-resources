# V1LaunchFactory-Implementation

`0x0c37a24F5D23A486FA692d1500881d698B1F77a4`

Group: pons v1.
Unverified. `launchEnabled()` false, `locker()` = `0x31ca5E10…` (protocolFeeShare 10, the legacy 90/10 split). This is a standalone earlier factory, not the proxy's implementation. 12 launches in the archived feed, and the factory behind the PONS token's own locker.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Creator | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` |
| Creation tx | `0xec8a7f6d96e30abdf5e4fb1aceaba014cd9bffce82c09337cf6ec3545c01aa45` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (24192 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 101. Matched against every verified Pons ABI in this archive plus the names the docs use:

- `acceptOwnership()`
- `allowance(address,address)`
- `approve(address,uint256)`
- `balanceOf(address)`
- `decimals()`
- `deployer()`
- `description()`
- `dexConfigCount()`
- `dexFactory()`
- `fee()`
- `getDexConfig(uint256)`
- `getLaunchConfig(uint256)`
- `getLaunchedToken(address)`
- `getTokenInfo()`
- `graduationStatus(address)`
- `launchBlock()`
- `launchConfigCount()`
- `launchEnabled()`
- `launchFactory()`
- `launchFee()`
- `liquidityPool()`
- `lockPosition(address)`
- `locker()`
- `logo()`
- `maxTxAmount()`
- `maxTxBps()`
- `maxTxLimit()`
- `maxWalletAmount()`
- `maxWalletBps()`
- `maxWalletLimit()`
- `name()`
- `owner()`
- `pairToken()`
- `pendingOwner()`
- `poolFee()`
- `positionManager()`
- `renounceOwnership()`
- `restrictionBlocks()`
- `restrictionEndBlock()`
- `setDexStatus(uint256,bool)`
- `setInitialBuyRecipient(address)`
- `setLaunchEnabled(bool)`
- `setLaunchFee(uint256)`
- `setWhitelistedLauncher(address,bool)`
- `slot0()`
- `socials()`
- `symbol()`
- `totalSupply()`
- `transfer(address,uint256)`
- `transferFrom(address,address,uint256)`
- `transferOwnership(address)`
- `whitelistedLaunchers(address)`

Unmatched selectors are recoverable from `bytecode.hex` with the same PUSH4 scan.
