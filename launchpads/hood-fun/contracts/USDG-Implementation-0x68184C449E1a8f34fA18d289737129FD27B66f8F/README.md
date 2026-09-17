# USDG - 0x68184C449E1a8f34fA18d289737129FD27B66f8F

Role: USDG-Implementation.
Address: `0x68184C449E1a8f34fA18d289737129FD27B66f8F` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x68184C449E1a8f34fA18d289737129FD27B66f8F
Verified: True (fully verified: True, partially: False).
Compiler: v0.8.28+commit.7893614a, EVM paris, optimizer True runs 200.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `contracts/stablecoins/USDG.sol`. Source files written: 90 under `sources/`.
Raw constructor args: `None`.

## Functions

- `DEFAULT_ADMIN_ROLE()` -> bytes32 [view]
- `DOMAIN_SEPARATOR()` -> bytes32 [view]
- `EIP712_DOMAIN_HASH_DEPRECATED()` -> bytes32 [view]
- `EIP712_VERSION_PREFIX()` -> bytes2 [view]
- `acceptDefaultAdminTransfer()` ->  [nonpayable]
- `allowance(address owner, address spender)` -> uint256 [view]
- `approve(address spender, uint256 value)` -> bool [nonpayable]
- `assetProtectionRoleDeprecated()` -> address [view]
- `balanceOf(address addr)` -> uint256 [view]
- `batchSetFacet(tuple[] facetCuts)` ->  [nonpayable]
- `beginDefaultAdminTransfer(address newAdmin)` ->  [nonpayable]
- `betaDelegateWhitelisterDeprecated()` -> address [view]
- `burn(uint256 amount)` ->  [nonpayable]
- `cancelDefaultAdminTransfer()` ->  [nonpayable]
- `changeDefaultAdminDelay(uint48 newDelay)` ->  [nonpayable]
- `decimals()` -> uint8 [view]
- `decreaseApproval(address spender, uint256 subtractedValue)` -> bool [nonpayable]
- `decreaseSupply(uint256 value)` -> bool [nonpayable]
- `decreaseSupplyFromAddress(uint256 value, address burnFromAddress)` -> bool [nonpayable]
- `defaultAdmin()` -> address [view]
- `defaultAdminDelay()` -> uint48 [view]
- `defaultAdminDelayIncreaseWait()` -> uint48 [view]
- `facets(bytes4)` -> address [view]
- `getFacet(bytes4 selector)` -> address [view]
- `getRoleAdmin(bytes32 role)` -> bytes32 [view]
- `globalTransferSettings()` -> uint40, uint32, bool, bytes10, bool [view]
- `grantRole(bytes32 role, address account)` ->  [nonpayable]
- `hasRole(bytes32 role, address account)` -> bool [view]
- `increaseApproval(address spender, uint256 addedValue)` -> bool [nonpayable]
- `increaseSupply(uint256 value)` -> bool [nonpayable]
- `increaseSupplyToAddress(uint256 value, address mintToAddress)` -> bool [nonpayable]
- `initialize(uint48 initialDelay, address initialOwner, address pauser, address assetProtector, tuple[] facetCuts, address claimSource, uint256 minRate, uint256 maxRate, tuple v3Roles)` ->  [nonpayable]
- `initializeV3(tuple[] facetCuts, address claimSource, uint256 minRate, uint256 maxRate, tuple v3Roles)` ->  [nonpayable]
- `mint(address account, uint256 amount)` ->  [nonpayable]
- `name()` -> string [view]
- `owner()` -> address [view]
- `pendingDefaultAdmin()` -> address, uint48 [view]
- `pendingDefaultAdminDelay()` -> uint48, uint48 [view]
- `proposedOwnerDeprecated()` -> address [view]
- `proxiableUUID()` -> bytes32 [view]
- `renounceRole(bytes32 role, address account)` ->  [nonpayable]
- `revokeRole(bytes32 role, address account)` ->  [nonpayable]
- `rollbackDefaultAdminDelay()` ->  [nonpayable]
- `setFacet(bytes4 selector, address facetAddress)` ->  [nonpayable]
- `supplyControl()` -> address [view]
- `supplyControllerDeprecated()` -> address [view]
- `supportsInterface(bytes4 interfaceId)` -> bool [view]
- `symbol()` -> string [view]
- `totalSupply()` -> uint256 [view]
- `transfer(address to, uint256 value)` -> bool [nonpayable]
- `transferFrom(address from, address to, uint256 value)` -> bool [nonpayable]
- `transferFromBatch(address[] from, address[] to, uint256[] value)` -> bool [nonpayable]
- `upgradeTo(address newImplementation)` ->  [nonpayable]
- `upgradeToAndCall(address newImplementation, bytes data)` ->  [payable]

## Events

- `AccountDeregistered(address account, uint32 payoutGroupId, address claimer)`
- `AccountRegistered(address account, uint32 payoutGroupId, address claimer)`
- `AdminChanged(address previousAdmin, address newAdmin)`
- `Approval(address owner, address spender, uint256 value)`
- `BeaconUpgraded(address beacon)`
- `ClaimAllExecuted(uint32 payoutGroupId, address executor, address destination, uint256 amount)`
- `ClaimSourceSet(address oldSource, address newSource)`
- `DefaultAdminDelayChangeCanceled()`
- `DefaultAdminDelayChangeScheduled(uint48 newDelay, uint48 effectSchedule)`
- `DefaultAdminTransferCanceled()`
- `DefaultAdminTransferScheduled(address newAdmin, uint48 acceptSchedule)`
- `FacetUpdate(bytes4 selector, address facet)`
- `FreezeAddress(address addr)`
- `FrozenAddressWiped(address addr)`
- `FrozenRewardsLost(address addr, uint32 payoutGroupId, uint256 rewards)`
- `Initialized(uint8 version)`
- `MaturityPeriodSet(uint32 multiplierId, uint256 maturityPeriod)`
- `MultiplierCreated(uint32 multiplierId, uint256 apr, uint256 timestamp)`
- `MultiplierDeleted(uint32 multiplierId)`
- `MultiplierRateScheduled(uint32 multiplierId, uint256 newRate, uint256 scheduledTime)`
- `PartnerSignedRegistrationsEnabledSet(bool enabled)`
- `Pause()`
- `PayoutClaimerUpdated(uint32 payoutGroupId, address oldClaimer, address newClaimer)`
- `PayoutGroupCreated(uint32 payoutGroupId, address claimer, uint32 multiplierId)`
- `PayoutGroupDeleted(uint32 payoutGroupId, address claimer)`
- `PayoutGroupDestinationSet(uint32 payoutGroupId, address oldDestination, address newDestination)`
- `PayoutGroupManagerSet(uint32 payoutGroupId, address oldManager, address newManager)`
- `PayoutGroupMultiplierUpdated(uint32 payoutGroupId, address claimer, uint32 oldMultiplierId, uint32 newMultiplierId)`
- `RateBoundsSet(uint256 minRate, uint256 maxRate)`
- `ReferenceTimeUpdated(uint40 oldReferenceTime, uint40 newReferenceTime)`
- `RegistrationAccepted(address account, uint32 payoutGroupId)`
- `RegistrationProposalCancelled(address account, uint32 payoutGroupId, address proposer)`
- `RegistrationProposed(address account, uint32 payoutGroupId, address proposer)`
- `RewardsClaimed(address account, uint32 payoutGroupId, address recipient, uint256 amount)`
- `RewardsClaimedBatch(uint32 payoutGroupId, address executor, address destination, uint256 totalAmount, uint256 accountCount)`
- `RewardsFrozen(address addr, uint32 payoutGroupId, uint256 rewards)`
- `RoleAdminChanged(bytes32 role, bytes32 previousAdminRole, bytes32 newAdminRole)`
- `RoleGranted(bytes32 role, address account, address sender)`
- `RoleRevoked(bytes32 role, address account, address sender)`
- `SupplyControlSet(address supplyControlAddress)`
- `SupplyDecreased(address from, uint256 value)`
- `SupplyIncreased(address to, uint256 value)`
- `Transfer(address from, address to, uint256 value)`
- `UnfreezeAddress(address addr)`
- `Unpause()`
- `Upgraded(address implementation)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
