# UpCLBoxLocker - 0xc1AfA59e2aBC1C868C51a1F799a7578EaCfEa076

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xc1AfA59e2aBC1C868C51a1F799a7578EaCfEa076
Role: UpCLBoxLocker.
Contract name: StonkUpLockerCL.
Verified: True (verified at 2026-08-10T10:05:32.678747Z).
Compiler: v0.8.24+commit.e11b9ed9, EVM paris, optimizer True runs 200.
Main file: contracts/locker/up/StonkUpLockerCL.sol.
Source files written: 25 under `sources/`.
Creator: 0x5209b3ab7CFdcc5d006f4441bE9D94BCe0541856.
Creation tx: 0x5553e74ca5cbeb46309ff8f51d8c8cc2e1c2bc81b52d33715e275c6e2650f158.
Proxy type: None; implementations: [].

## Constructor arguments

- `initialOwner` (address): `0x5209b3ab7CFdcc5d006f4441bE9D94BCe0541856`
- `_positionManager` (address): `0x07F44c47743A2f36414A82b9F558ECFCf0EEdCEf`
- `_voter` (address): `0x7F749fDD351C1Ceed82d76d7699CB631Eb8332a7`
- `_lockNft` (address): `0x3e45e90d83D87F961561968709D5AB844EB7422f`
- `_protocolFeeRecipient` (address): `0x55642A3F10F1Af5145D3d59021B1D6b03BB8692c`

## Events

- `FeeExemptUpdated(address,bool)`
- `LockFeesCollected(uint256,uint256,uint256,uint256,uint256)`
- `LockLiquidityDecreased(uint256,uint128,uint256,uint256,uint256,uint256)`
- `LockTokensPaid(uint256,address,uint256,uint256)`
- `OwnershipTransferred(address,address)`
- `PositionLocked(uint256,uint256,address,uint64,uint64,uint8,uint128)`
- `PositionReleased(uint256,uint256,address)`
- `PositionStakedInGauge(uint256,address,uint256)`
- `PositionUnstakedFromGauge(uint256,address,uint256)`
- `ProtocolFeeRecipientUpdated(address,address)`

## State-changing functions

- `claimEmissions(uint256)`
- `collectFees(uint256,uint128,uint128)`
- `decreaseLockedLiquidity(uint256,uint128,uint256,uint256)`
- `lockByTransfer(uint256,uint64,uint64,uint8)`
- `onERC721Received(address,address,uint256,bytes)`
- `releasePosition(uint256)`
- `renounceOwnership()`
- `setFeeExempt(address,bool)`
- `setProtocolFeeRecipient(address)`
- `stake(uint256)`
- `transferOwnership(address)`
- `unstake(uint256)`

## View functions

- `canRelease(uint256)`
- `clFactory()`
- `feeExempt(address)`
- `gaugeFor(uint256)`
- `isStaked(uint256)`
- `lockNft()`
- `lockPositions(uint256)`
- `owner()`
- `pendingEmissions(uint256)`
- `positionManager()`
- `positionToLockTokenId(uint256)`
- `protocolFeeRecipient()`
- `voter()`
- `withdrawableLiquidity(uint256)`
