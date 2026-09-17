# LaunchLockerV1Test - 0xec4a56061d86955d0df883efb2e5791d99ea71f2

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xec4a56061d86955d0df883efb2e5791d99ea71f2
Role: LaunchLockerV1Test.
Contract name: LaunchLocker.
Verified: True.
Compiler: v0.8.30+commit.73712a01, EVM shanghai, optimizer True runs 200.
Main file: contracts/LaunchLocker.sol.
Source files written: 6 under `sources/`.
Creator: 0x7E035Fb048a31e0481b88074557415b1C187242B.
Creation tx: 0x1a6b676e9f1d491868d29e2a45b62f1b7d0ebe1ed406b505a31bd9a84b66fa56.
Proxy type: None; implementations: [].

The locker paired with the test V1 factory. Verified.

## Constructor arguments

- `_protocolFeeRecipient` (address): `0x71f2F1c2dc94cDaBFE29Cb355119f8683AE0969b`
- `_protocolFeeShare` (uint256): `65`

## Events

- `FactoryUpdated(address)`
- `FeeCollectorUpdated(address,bool)`
- `FeeRedirectUpdated(address,address)`
- `FeesClaimed(address,address,address,address,uint256,uint256,uint256,uint256)`
- `OwnershipTransferred(address,address)`
- `PositionLocked(address,address,uint256,address,uint256,address)`
- `ProtocolFeeRecipientUpdated(address)`
- `ProtocolFeeUpdated(uint256)`

## State-changing functions

- `collectFees(address)`
- `initialize(address)`
- `lockPosition(address)`
- `renounceOwnership()`
- `setFeeCollector(address,bool)`
- `setFeeRedirect(address,address)`
- `setProtocolFeeRecipient(address)`
- `setProtocolFeeShare(uint256)`
- `transferOwnership(address)`

## View functions

- `deployerTokens(address,uint256)`
- `factory()`
- `feeCollectors(address)`
- `feeRedirects(address)`
- `getLaunchedToken(address)`
- `onERC721Received(address,address,uint256,bytes)`
- `owner()`
- `protocolFeeRecipient()`
- `protocolFeeShare()`
