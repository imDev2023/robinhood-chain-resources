# AgentNftV2-Impl - 0x5967bABc9B7F57CbF5826053955520ab528aC0AF

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x5967bABc9B7F57CbF5826053955520ab528aC0AF
Role: AgentNftV2-Impl.
Contract name: AgentNftV2.
Verified: True (verified at 2026-07-02T06:56:36.003459Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/virtualPersona/AgentNftV2.sol.
Source files written: 48 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0x36092aea5082924d1bff0a9945ea374da301441d9a7b784aff3ac6c758e4f010.
Proxy type: None; implementations: [].

AgentNftV2 implementation.

## Constructor arguments

None decoded.

## Events

- `AgentBlacklisted(uint256,bool)`
- `Approval(address,address,uint256)`
- `ApprovalForAll(address,address,bool)`
- `BatchMetadataUpdate(uint256,uint256)`
- `CoresUpdated(uint256,uint8[])`
- `Initialized(uint64)`
- `MetadataUpdate(uint256)`
- `NewCoreType(uint8,string)`
- `NewValidator(uint256,address)`
- `RoleAdminChanged(bytes32,bytes32,bytes32)`
- `RoleGranted(bytes32,address,address)`
- `RoleRevoked(bytes32,address,address)`
- `Transfer(address,address,uint256)`

## State-changing functions

- `addCoreType(string)`
- `addValidator(uint256,address)`
- `approve(address,uint256)`
- `grantRole(bytes32,address)`
- `initialize(address)`
- `migrateScoreFunctions()`
- `migrateVirtual(uint256,address,address,address,address)`
- `mint(uint256,address,string,address,address,uint8[],address,address)`
- `renounceRole(bytes32,address)`
- `revokeRole(bytes32,address)`
- `safeTransferFrom(address,address,uint256)`
- `safeTransferFrom(address,address,uint256,bytes)`
- `setApprovalForAll(address,bool)`
- `setBlacklist(uint256,bool)`
- `setContributionService(address,address)`
- `setCoreTypes(uint256,uint8[])`
- `setDAO(uint256,address)`
- `setEloCalculator(address)`
- `setTBA(uint256,address)`
- `setTokenURI(uint256,string)`
- `transferFrom(address,address,uint256)`

## View functions

- `ADMIN_ROLE()`
- `DEFAULT_ADMIN_ROLE()`
- `MINTER_ROLE()`
- `VALIDATOR_ADMIN_ROLE()`
- `balanceOf(address)`
- `coreTypes(uint8)`
- `getAllServices(uint256)`
- `getApproved(uint256)`
- `getContributionNft()`
- `getEloCalculator()`
- `getPastValidatorScore(uint256,address,uint256)`
- `getRoleAdmin(bytes32)`
- `getServiceNft()`
- `getVotes(uint256,address)`
- `hasRole(bytes32,address)`
- `isApprovedForAll(address,address)`
- `isBlacklisted(uint256)`
- `isValidator(uint256,address)`
- `name()`
- `nextVirtualId()`
- `ownerOf(uint256)`
- `stakingTokenToVirtualId(address)`
- `supportsInterface(bytes4)`
- `symbol()`
- `tokenURI(uint256)`
- `totalProposals(uint256)`
- `totalStaked(uint256)`
- `totalSupply()`
- `totalUptimeScore(uint256)`
- `validatorAt(uint256,uint256)`
- `validatorCount(uint256)`
- `validatorScore(uint256,address)`
- `virtualInfo(uint256)`
- `virtualInfos(uint256)`
- `virtualLP(uint256)`
- `virtualLPs(uint256)`
