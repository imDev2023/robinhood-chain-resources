# PairCandidate3 - 0xd1BcbCCa41f3bdb6b4812652959c6dF725ea2Ac0

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xd1BcbCCa41f3bdb6b4812652959c6dF725ea2Ac0
Role: PairCandidate3.
Contract name: DualPoolHook.
Verified: True (verified at 2026-09-05T13:32:46.470334Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: lib/v4-hooks-public/src/alf/DualPoolHook.sol.
Source files written: 74 under `sources/`.
Creator: 0xa9ab194FB74dFD9991047839aE23A576c8403d95.
Creation tx: 0x30438a3fac4e8c8413a93422e1759d8beae105322085126c946bd6e6d9774c8b.
Proxy type: None; implementations: [].

## Constructor arguments

- `_pm` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `maxGas_` (uint32): `500000`
- `owner_` (address): `0xC8720447712e6C4c851B3884b4Ec93F9cE8aD5fD`
- `_maxMinDepositBlocks` (uint64): `300`

## Events

- `Bootstrap(bytes32,address,uint256,uint256,uint256)`
- `Deposit(bytes32,address,uint256,uint256,uint256)`
- `DistributionUpdated(bytes32)`
- `EmergencyVaultRevoked(bytes32)`
- `ExternalDepositsUpdated(bytes32,bool)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `PoolCreated(bytes32)`
- `PoolLivenessUpdated(bytes32,bool)`
- `VaultBound(bytes32,address)`
- `VaultDepositSkipped(bytes32,address,uint256,bytes)`
- `VaultDrainSkipped(bytes32,address,uint256,bytes)`
- `VaultDrained(bytes32,address,uint256,uint256)`
- `Withdraw(bytes32,address,uint256,uint256,uint256)`

## State-changing functions

- `acceptOwnership()`
- `addLiquidity(tuple,uint256,uint256,uint256,uint256)`
- `afterAddLiquidity(address,tuple,tuple,int256,int256,bytes)`
- `afterDonate(address,tuple,uint256,uint256,bytes)`
- `afterInitialize(address,tuple,uint160,int24)`
- `afterRemoveLiquidity(address,tuple,tuple,int256,int256,bytes)`
- `afterSwap(address,tuple,tuple,int256,bytes)`
- `beforeAddLiquidity(address,tuple,tuple,bytes)`
- `beforeDonate(address,tuple,uint256,uint256,bytes)`
- `beforeInitialize(address,tuple,uint160)`
- `beforeRemoveLiquidity(address,tuple,tuple,bytes)`
- `beforeSwap(address,tuple,tuple,bytes)`
- `bootstrap(tuple,uint256,uint256)`
- `emergencyRevokeVault(tuple)`
- `initializePool(tuple,tuple)`
- `refreshVaultApproval(tuple,address)`
- `removeLiquidity(tuple,uint256,uint256,uint256,uint256)`
- `setDistribution(tuple,tuple[])`
- `setExternalDeposits(tuple,bool)`
- `setPoolLive(tuple,bool)`
- `transferOwnership(address)`
- `unlockCallback(bytes)`

## View functions

- `decimalsOffset(bytes32)`
- `externalDepositsEnabled(bytes32)`
- `factory()`
- `getDistribution(bytes32)`
- `getEffectiveLiquidity(tuple)`
- `getHookPermissions()`
- `getIndicativeQuote(tuple,bool,int256,bytes)`
- `getReserves(tuple)`
- `isLive()`
- `livePools(bytes32)`
- `maxGas()`
- `maxMinDepositBlocks()`
- `minDepositBlocks(bytes32)`
- `owner()`
- `pendingOwner()`
- `poolManager()`
- `previewDeposit(tuple,uint256)`
- `previewWithdraw(tuple,uint256)`
- `renounceOwnership()`
- `sharesOf(tuple,address)`
- `supportsInterface(bytes4)`
- `swapToPrice(tuple,bool,int256,uint160,bytes)`
- `totalAssets(tuple)`
- `totalShares(bytes32)`
- `userShares(bytes32,address)`
- `vaults(bytes32,address)`
