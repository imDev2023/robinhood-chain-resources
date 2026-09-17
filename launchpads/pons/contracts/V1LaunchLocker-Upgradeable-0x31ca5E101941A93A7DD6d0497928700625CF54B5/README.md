# V1LaunchLocker-Upgradeable

`0x31ca5E101941A93A7DD6d0497928700625CF54B5`

Group: pons v1.
Unverified. `factory()` = `0x0c37a24F…`, `protocolFeeShare()` = 10, which is the legacy 90/10 creator/protocol split the v1 docs describe for launches from block 8600612. The live V1 token API reports this address as the `locker` of the PONS token.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Creator | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` |
| Creation tx | `0x6632319ccf609a9926385d667db85263ea38dc65400a159808baf92770936de9` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (4861 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 43. Matched against every verified Pons ABI in this archive plus the names the docs use:

- `MAX_PROTOCOL_FEE_SHARE()`
- `acceptOwnership()`
- `collectFees(address)`
- `deployerTokenCount(address)`
- `deployerTokens(address,uint256)`
- `factory()`
- `feeCollectors(address)`
- `feeRedirects(address)`
- `getLaunchedToken(address)`
- `initialize(address)`
- `lockPosition(address)`
- `onERC721Received(address,address,uint256,bytes)`
- `owner()`
- `pendingOwner()`
- `protocolFeeRecipient()`
- `protocolFeeShare()`
- `renounceOwnership()`
- `setFeeCollector(address,bool)`
- `setFeeRedirect(address,address)`
- `setProtocolFeeRecipient(address)`
- `setProtocolFeeShare(uint256)`
- `tokenProtocolFeeShares(address)`
- `transfer(address,uint256)`
- `transferOwnership(address)`

Unmatched selectors are recoverable from `bytecode.hex` with the same PUSH4 scan.
