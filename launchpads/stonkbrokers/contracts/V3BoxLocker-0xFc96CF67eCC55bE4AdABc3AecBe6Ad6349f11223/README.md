# V3BoxLocker - 0xFc96CF67eCC55bE4AdABc3AecBe6Ad6349f11223

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xFc96CF67eCC55bE4AdABc3AecBe6Ad6349f11223
Role: V3BoxLocker.
Contract name: StonkLiquidityLocker.
Verified: True (verified at 2026-07-26T00:22:16.232009Z).
Compiler: v0.8.24+commit.e11b9ed9, EVM paris, optimizer True runs 200.
Main file: contracts/locker/StonkLiquidityLocker.sol.
Source files written: 25 under `sources/`.
Creator: 0xf2bA469e492A4484733EF3c1B89826553347cbda.
Creation tx: 0x5311c35fc1b7798ec0f417d299044938c2a5b1791310c899d29ef3d1a864b7c2.
Proxy type: None; implementations: [].

## Constructor arguments

- `initialOwner` (address): `0xf2bA469e492A4484733EF3c1B89826553347cbda`
- `_positionManager` (address): `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3`
- `_lockNft` (address): `0xE460dA1a77CAe75EeD8b355d05b6fCBFA4b2A360`
- `_protocolFeeRecipient` (address): `0x55642A3F10F1Af5145D3d59021B1D6b03BB8692c`

## Events

- `FeeExemptUpdated(address,bool)`
- `LockFeesCollected(uint256,uint256,uint256,uint256,uint256)`
- `LockLiquidityDecreased(uint256,uint128,uint256,uint256,uint256,uint256)`
- `OwnershipTransferred(address,address)`
- `PositionLocked(uint256,uint256,address,uint64,uint64,uint8,uint128)`
- `PositionReleased(uint256,uint256,address)`
- `ProtocolFeeRecipientUpdated(address,address)`

## State-changing functions

- `collectFees(uint256,uint128,uint128)`
- `decreaseLockedLiquidity(uint256,uint128,uint256,uint256)`
- `lockByTransfer(uint256,uint64,uint64,uint8)`
- `onERC721Received(address,address,uint256,bytes)`
- `releasePosition(uint256)`
- `renounceOwnership()`
- `setFeeExempt(address,bool)`
- `setProtocolFeeRecipient(address)`
- `transferOwnership(address)`

## View functions

- `canRelease(uint256)`
- `feeExempt(address)`
- `lockNft()`
- `lockPositions(uint256)`
- `owner()`
- `positionManager()`
- `positionToLockTokenId(uint256)`
- `protocolFeeRecipient()`
- `withdrawableLiquidity(uint256)`
