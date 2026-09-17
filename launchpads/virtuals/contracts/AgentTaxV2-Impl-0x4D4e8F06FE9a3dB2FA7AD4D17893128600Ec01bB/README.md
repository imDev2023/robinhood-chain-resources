# AgentTaxV2-Impl - 0x4D4e8F06FE9a3dB2FA7AD4D17893128600Ec01bB

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x4D4e8F06FE9a3dB2FA7AD4D17893128600Ec01bB
Role: AgentTaxV2-Impl.
Contract name: AgentTaxV2.
Verified: True (verified at 2026-07-02T06:59:58.587227Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/tax/AgentTaxV2.sol.
Source files written: 12 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0xa9915d1b7ab149b97b49b750aa852b4bafd45f95a247a5dcb68381cb3a9433b8.
Proxy type: None; implementations: [].

AgentTaxV2 implementation.

## Constructor arguments

None decoded.

## Events

- `CreatorUpdated(address,address,address)`
- `FeeSplitUpdated(uint16,uint16)`
- `Initialized(uint64)`
- `PartnerFeeDistributed(address,bytes32,address,uint256)`
- `PartnerRecipientUpdated(bytes32,address,address)`
- `RoleAdminChanged(bytes32,bytes32,bytes32)`
- `RoleGranted(bytes32,address,address)`
- `RoleRevoked(bytes32,address,address)`
- `SwapExecuted(address,uint256,uint256)`
- `SwapFailed(address,uint256)`
- `SwapParamsUpdated(address,address,address,address,uint16,uint16)`
- `SwapThresholdUpdated(uint256,uint256,uint256,uint256)`
- `TaxDeposited(address,uint256)`
- `TokenPartnerConfigUpdated(address,bytes32,uint16)`
- `TokenRegistered(address,address,address)`
- `TreasuryUpdated(address,address)`

## State-changing functions

- `batchSwapForTokenAddress(address[],uint256[])`
- `depositTax(address,uint256)`
- `grantRole(bytes32,address)`
- `initialize(address,address,address,address,address,uint256,uint256,uint16)`
- `registerToken(address,address,address)`
- `renounceRole(bytes32,address)`
- `revokeRole(bytes32,address)`
- `setBondingV5(address)`
- `setPartnerRecipient(bytes32,address)`
- `setTokenPartnerConfig(address,bytes32,uint16)`
- `swapForTokenAddress(address,uint256)`
- `updateCreator(address,address)`
- `updateCreatorForSpecialLaunchAgents(address,address,address)`
- `updateSwapParams(address,address,uint16)`
- `updateSwapThresholds(uint256,uint256)`
- `updateTreasury(address)`
- `withdraw(address)`

## View functions

- `ADMIN_ROLE()`
- `DEFAULT_ADMIN_ROLE()`
- `EXECUTOR_ROLE()`
- `REGISTER_ROLE()`
- `SWAP_ROLE()`
- `assetToken()`
- `bondingV5()`
- `feeRate()`
- `getRoleAdmin(bytes32)`
- `getTokenPartnerConfig(address)`
- `getTokenRecipient(address)`
- `getTokenTaxAmounts(address)`
- `hasRole(bytes32,address)`
- `maxPartnerFeeRate()`
- `maxSwapThreshold()`
- `minSwapThreshold()`
- `partnerRecipients(bytes32)`
- `router()`
- `supportsInterface(bytes4)`
- `taxToken()`
- `tokenPartnerConfigs(address)`
- `tokenRecipients(address)`
- `tokenTaxAmounts(address)`
- `treasury()`
