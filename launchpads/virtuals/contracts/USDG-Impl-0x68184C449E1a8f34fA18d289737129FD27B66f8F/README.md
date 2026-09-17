# USDG-Impl - 0x68184C449E1a8f34fA18d289737129FD27B66f8F

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x68184C449E1a8f34fA18d289737129FD27B66f8F
Role: USDG-Impl.
Contract name: USDG.
Verified: True (verified at 2026-06-26T04:10:34.498250Z).
Compiler: v0.8.28+commit.7893614a, EVM paris, optimizer True runs 200.
Main file: contracts/stablecoins/USDG.sol.
Source files written: 90 under `sources/`.
Creator: 0xBe498aad9c6fd0E4Cd6d1E3fBb395026c5D28215.
Creation tx: 0x5a88b74f8ade975f0fbb8908b70cde112d64b263c9b60967996bb20314d48769.
Proxy type: None; implementations: [].

USDG implementation.

## Constructor arguments

None decoded.

## Events

- `AccountDeregistered(address,uint32,address)`
- `AccountRegistered(address,uint32,address)`
- `AdminChanged(address,address)`
- `Approval(address,address,uint256)`
- `BeaconUpgraded(address)`
- `ClaimAllExecuted(uint32,address,address,uint256)`
- `ClaimSourceSet(address,address)`
- `DefaultAdminDelayChangeCanceled()`
- `DefaultAdminDelayChangeScheduled(uint48,uint48)`
- `DefaultAdminTransferCanceled()`
- `DefaultAdminTransferScheduled(address,uint48)`
- `FacetUpdate(bytes4,address)`
- `FreezeAddress(address)`
- `FrozenAddressWiped(address)`
- `FrozenRewardsLost(address,uint32,uint256)`
- `Initialized(uint8)`
- `MaturityPeriodSet(uint32,uint256)`
- `MultiplierCreated(uint32,uint256,uint256)`
- `MultiplierDeleted(uint32)`
- `MultiplierRateScheduled(uint32,uint256,uint256)`
- `PartnerSignedRegistrationsEnabledSet(bool)`
- `Pause()`
- `PayoutClaimerUpdated(uint32,address,address)`
- `PayoutGroupCreated(uint32,address,uint32)`
- `PayoutGroupDeleted(uint32,address)`
- `PayoutGroupDestinationSet(uint32,address,address)`
- `PayoutGroupManagerSet(uint32,address,address)`
- `PayoutGroupMultiplierUpdated(uint32,address,uint32,uint32)`
- `RateBoundsSet(uint256,uint256)`
- `ReferenceTimeUpdated(uint40,uint40)`
- `RegistrationAccepted(address,uint32)`
- `RegistrationProposalCancelled(address,uint32,address)`
- `RegistrationProposed(address,uint32,address)`
- `RewardsClaimed(address,uint32,address,uint256)`
- `RewardsClaimedBatch(uint32,address,address,uint256,uint256)`
- `RewardsFrozen(address,uint32,uint256)`
- `RoleAdminChanged(bytes32,bytes32,bytes32)`
- `RoleGranted(bytes32,address,address)`
- `RoleRevoked(bytes32,address,address)`
- `SupplyControlSet(address)`
- `SupplyDecreased(address,uint256)`
- `SupplyIncreased(address,uint256)`
- `Transfer(address,address,uint256)`
- `UnfreezeAddress(address)`
- `Unpause()`
- `Upgraded(address)`

## State-changing functions

- `acceptDefaultAdminTransfer()`
- `approve(address,uint256)`
- `batchSetFacet(tuple[])`
- `beginDefaultAdminTransfer(address)`
- `burn(uint256)`
- `cancelDefaultAdminTransfer()`
- `changeDefaultAdminDelay(uint48)`
- `decreaseApproval(address,uint256)`
- `decreaseSupply(uint256)`
- `decreaseSupplyFromAddress(uint256,address)`
- `grantRole(bytes32,address)`
- `increaseApproval(address,uint256)`
- `increaseSupply(uint256)`
- `increaseSupplyToAddress(uint256,address)`
- `initialize(uint48,address,address,address,tuple[],address,uint256,uint256,tuple)`
- `initializeV3(tuple[],address,uint256,uint256,tuple)`
- `mint(address,uint256)`
- `renounceRole(bytes32,address)`
- `revokeRole(bytes32,address)`
- `rollbackDefaultAdminDelay()`
- `setFacet(bytes4,address)`
- `transfer(address,uint256)`
- `transferFrom(address,address,uint256)`
- `transferFromBatch(address[],address[],uint256[])`
- `upgradeTo(address)`
- `upgradeToAndCall(address,bytes)`

## View functions

- `DEFAULT_ADMIN_ROLE()`
- `DOMAIN_SEPARATOR()`
- `EIP712_DOMAIN_HASH_DEPRECATED()`
- `EIP712_VERSION_PREFIX()`
- `allowance(address,address)`
- `assetProtectionRoleDeprecated()`
- `balanceOf(address)`
- `betaDelegateWhitelisterDeprecated()`
- `decimals()`
- `defaultAdmin()`
- `defaultAdminDelay()`
- `defaultAdminDelayIncreaseWait()`
- `facets(bytes4)`
- `getFacet(bytes4)`
- `getRoleAdmin(bytes32)`
- `globalTransferSettings()`
- `hasRole(bytes32,address)`
- `name()`
- `owner()`
- `pendingDefaultAdmin()`
- `pendingDefaultAdminDelay()`
- `proposedOwnerDeprecated()`
- `proxiableUUID()`
- `supplyControl()`
- `supplyControllerDeprecated()`
- `supportsInterface(bytes4)`
- `symbol()`
- `totalSupply()`
