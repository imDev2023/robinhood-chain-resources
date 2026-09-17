# AgentFactoryV7-Impl - 0xF0a8089da19568a37bCCacc4BFE3A2a9f1E71675

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xF0a8089da19568a37bCCacc4BFE3A2a9f1E71675
Role: AgentFactoryV7-Impl.
Contract name: AgentFactoryV7.
Verified: True (verified at 2026-07-02T06:08:38.452983Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/virtualPersona/AgentFactoryV7.sol.
Source files written: 32 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0x6ae496bde115e0d7522349d100b620b30c5ef45f28f75e149d4f3ca425b041f3.
Proxy type: None; implementations: [].

AgentFactoryV7 implementation.

## Constructor arguments

None decoded.

## Events

- `ApplicationThresholdUpdated(uint256)`
- `GovUpdated(address)`
- `ImplContractsUpdated(address,address)`
- `Initialized(uint64)`
- `LegacyAgentTokenV3ImplementationUpdated(address,address)`
- `NewApplication(uint256)`
- `NewPersona(uint256,address,address,address,address,address)`
- `Paused(address)`
- `RoleAdminChanged(bytes32,bytes32,bytes32)`
- `RoleGranted(bytes32,address,address)`
- `RoleRevoked(bytes32,address,address)`
- `Unpaused(address)`
- `V3ProjectTaxSwept(address,uint256,uint256)`

## State-changing functions

- `addBlacklistAddress(address,address)`
- `createNewAgentTokenAndApplication(string,string,bytes,uint8[],bytes32,address,uint32,uint256,uint256,address)`
- `executeBondingCurveApplicationSalt(uint256,uint256,uint256,address,bytes32)`
- `grantRole(bytes32,address)`
- `initialize(address,address,address,address,address,address,address,uint256)`
- `pause()`
- `removeBlacklistAddress(address,address)`
- `removeLpLiquidity(address,address,uint256,uint256,uint256,uint256)`
- `renounceRole(bytes32,address)`
- `revokeRole(bytes32,address)`
- `setImplementations(address,address,address)`
- `setLegacyAgentTokenV3Implementation(address)`
- `setParams(uint256,address,address,address)`
- `setTaxAccountingAdapter(address)`
- `setTokenParams(uint256,uint256,uint256,address)`
- `setV3SwapThresholdBasisPoints(uint256)`
- `setVault(address)`
- `sweepV3ProjectTaxToVirtualAndDeposit(address)`
- `unpause()`
- `updateApplicationThresholdWithApplicationId(uint256,uint256)`
- `withdraw(uint256)`

## View functions

- `BONDING_ROLE()`
- `DEFAULT_ADMIN_ROLE()`
- `REMOVE_LIQUIDITY_ROLE()`
- `SWEEP_V3_PROJECT_TAX_ROLE()`
- `WITHDRAW_ROLE()`
- `allDAOs(uint256)`
- `allTokens(uint256)`
- `allTradingTokens(uint256)`
- `assetToken()`
- `daoImplementation()`
- `defaultDelegatee()`
- `getApplication(uint256)`
- `getCloneImplementation(address)`
- `getRoleAdmin(bytes32)`
- `gov()`
- `hasRole(bytes32,address)`
- `legacyAgentTokenV3Implementation()`
- `maturityDuration()`
- `nextIdBase()`
- `nft()`
- `paused()`
- `supportsInterface(bytes4)`
- `taxAccountingAdapter()`
- `tbaRegistry()`
- `tokenImplementation()`
- `totalAgents()`
- `v3SwapThresholdBasisPoints()`
- `veTokenImplementation()`
