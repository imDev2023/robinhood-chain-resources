# LaunchLockerV2 - 0x9a6931e371b62048c7543c7002c99d83685bd44d

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x9a6931e371b62048c7543c7002c99d83685bd44d
Role: LaunchLockerV2.
Contract name: LaunchLocker.
Verified: True.
Compiler: v0.8.30+commit.73712a01, EVM cancun, optimizer True runs 200.
Main file: src/LaunchLocker.sol.
Source files written: 10 under `sources/`.
Creator: 0x63CD726Ccc6560F571861BbAb925f9AF4a6095B2.
Creation tx: 0x5788253e28133dd0da45e30f9a9eb38f0708a91c9091be7b41289d721e3b0867.
Proxy type: None; implementations: [].

The live locker. Holds every V2 launch's Uniswap V3 position NFT and pays trading fees out. Verified.

## Constructor arguments

- `_protocolFeeRecipient` (address): `0x4977307cF8fa1fb5Ce45873717164c872BAD6f23`
- `_protocolFeeShare` (uint256): `50`
- `_weth` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `_swapRouter` (address): `0xCaf681a66D020601342297493863E78C959E5cb2`

## Events

- `CancelCreatorReassign(address)`
- `ExecuteCreatorReassign(address,address)`
- `FactoryUpdated(address)`
- `FeeCollectorUpdated(address,bool)`
- `FeeRedirectUpdated(address,address)`
- `FeesClaimed(address,address,uint256,uint256,uint256,uint256,uint256,uint256)`
- `MaxSlippageUpdated(uint256)`
- `OwnershipTransferred(address,address)`
- `PayoutFailed(address,uint256)`
- `PositionLocked(address,address,uint256,address,uint256,address)`
- `ProposeCreatorReassign(address,address,uint256)`
- `ProtocolFeeRecipientUpdated(address)`
- `ProtocolFeeUpdated(uint256)`
- `TokenSwapSkipped(address,uint256)`
- `TwapWindowUpdated(uint32)`

## State-changing functions

- `cancelCreatorReassign(address)`
- `collectFees(address)`
- `collectFees(address,uint256)`
- `collectFeesWethOnly(address)`
- `executeCreatorReassign(address)`
- `initialize(address)`
- `lockPosition(address)`
- `proposeCreatorReassign(address,address)`
- `renounceOwnership()`
- `setFeeCollector(address,bool)`
- `setFeeRedirect(address,address)`
- `setMaxSlippageBps(uint256)`
- `setProtocolFeeRecipient(address)`
- `setProtocolFeeShare(uint256)`
- `setTwapWindow(uint32)`
- `transferOwnership(address)`

## View functions

- `BPS_DENOMINATOR()`
- `MAX_SLIPPAGE_BPS()`
- `MIN_SLIPPAGE_BPS()`
- `REASSIGN_DELAY()`
- `creatorPayoutOverride(address)`
- `deployerTokens(address,uint256)`
- `factory()`
- `feeCollectors(address)`
- `feeRedirects(address)`
- `getLaunchedToken(address)`
- `maxSlippageBps()`
- `onERC721Received(address,address,uint256,bytes)`
- `owner()`
- `pendingReassign(address)`
- `protocolFeeRecipient()`
- `protocolFeeShare()`
- `swapRouter()`
- `twapWindow()`
- `weth()`
