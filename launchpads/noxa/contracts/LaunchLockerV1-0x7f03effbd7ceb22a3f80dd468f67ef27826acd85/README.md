# LaunchLockerV1 - 0x7f03effbd7ceb22a3f80dd468f67ef27826acd85

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x7f03effbd7ceb22a3f80dd468f67ef27826acd85
Role: LaunchLockerV1.
Contract name: LaunchLocker.
Verified: True.
Compiler: v0.8.30+commit.73712a01, EVM shanghai, optimizer True runs 200.
Main file: contracts/LaunchLocker.sol.
Source files written: 6 under `sources/`.
Creator: 0x7E035Fb048a31e0481b88074557415b1C187242B.
Creation tx: 0x359a038b1f9c4295cb9c10011743abe5127fd28796ddede900f78d61c71695f8.
Proxy type: None; implementations: [].

The V1 locker, still holding every pre-halt position. Verified.

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
