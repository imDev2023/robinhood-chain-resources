# NoxaIO-FeeSplitter - 0xa2da74831c34d396be9a42fbecc54c561184bcb1

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xa2da74831c34d396be9a42fbecc54c561184bcb1
Role: NoxaIO-FeeSplitter.
Contract name: FeeSplitter.
Verified: True.
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/FeeSplitter.sol.
Source files written: 13 under `sources/`.
Creator: 0x407Fe47FA03617062E9cD27DCACe8DAB006322d8.
Creation tx: 0xe9c8f173acfa7acdcfb188a1b47203ec5021774190e82478776e69ea1ebd9862.
Proxy type: None; implementations: [].

The FeeRouter's protocol recipient. Epoch-based release to two addresses, constructed 70/30 between 0x407Fe47FA03617062E9cD27DCACe8DAB006322d8 and 0x667070fA9B91a70E4542AE5B33c1F68721787342.

## Constructor arguments

- `feeRouter_` (address): `0x28A5328B61E00dD75F1d0C8A1831A65890E42d36`
- `owner_` (address): `0x407Fe47FA03617062E9cD27DCACe8DAB006322d8`
- `recipients_` (address[]): `['0x407Fe47FA03617062E9cD27DCACe8DAB006322d8', '0x667070fA9B91a70E4542AE5B33c1F68721787342']`
- `shares_` (uint16[]): `['7000', '3000']`

## Events

- `DepositRecorded(uint256,address,uint256)`
- `EpochClosed(uint256)`
- `EpochOpened(uint256,address)`
- `EpochRecipientConfigured(uint256,address,uint16)`
- `OwnershipTransferred(address,address)`
- `PaymentReleased(uint256,address,address,uint256)`

## State-changing functions

- `deposit(address,uint256)`
- `release(uint256,address)`
- `releaseFor(uint256,address,address)`
- `renounceOwnership()`
- `setConfig(address[],uint16[])`
- `transferOwnership(address)`

## View functions

- `MAX_BPS()`
- `MAX_RECIPIENTS()`
- `accountedBalance(address)`
- `currentEpoch()`
- `currentShareBps(address)`
- `epochClosed(uint256)`
- `epochDeposited(uint256,address)`
- `epochRoundingRecipient(uint256)`
- `epochShareBps(uint256,address)`
- `feeRouter()`
- `getRecipients(uint256)`
- `owner()`
- `recipientAt(uint256,uint256)`
- `recipientCount(uint256)`
- `releasable(uint256,address,address)`
- `released(uint256,address,address)`
- `roundingRemainder(uint256,address)`
- `totalRecorded(address)`
- `totalReleased(address)`
- `unallocatedBalance(address)`
