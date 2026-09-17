# CashCatRevenueSplitter - 0x6D3d822F6e625c59804F47cf2Cc1d53B8301016F

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x6D3d822F6e625c59804F47cf2Cc1d53B8301016F
Role: CashCatRevenueSplitter.
Contract name: CashCatRevenueSplitter.
Verified: True (verified at 2026-08-08T17:30:19.710833Z).
Compiler: v0.8.28+commit.7893614a, EVM cancun, optimizer True runs 800.
Main file: src/v4/CashCatRevenueSplitter.sol.
Source files on disk: 17 under `sources/`.
Creator: 0x0679f72DCC42d8fBEB19FC2e0215Be8e7C090881.
Creation tx: 0x366e7972de517f43d52b5bb5017624ad74ed8586f5a7cbdadd14680392d12859.
Proxy type: None; implementations: [].
External libraries: none.

## Context, not part of the HOOD10 Launchpad

letscash.fun's own revenue splitter, shipped alongside `CashCatBuybackBurner`.
Included for the CASHCAT comparison in the README; no HOOD10 Launchpad contract calls it.

## Constructor arguments

- `pool_` (address): `0xA70fc67C9F69da90B63a0e4C05D229954574E313`
- `poolFee_` (uint24): `10000`
- `cashcat_` (address): `0x020bfC650A365f8BB26819deAAbF3E21291018b4`
- `weth_` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `cashcatTreasury_` (address): `0xAb2F34f77b396B6B1DaD6eC2fb1aB5550a3b7903`
- `burnShareBps_` (uint16): `2500`
- `cashcatTreasuryShareBps_` (uint16): `2500`
- `participants_` (tuple[]): `[['0x3EA937589eA5eE0FBcCbcCeF29473E7f957a19a5', '1250'], ['0xb1C7b62F9B623d23a1401f8849F25E8cE0CB6dF2', '1250'], ['0xA6DAB37220aC3B74dB0E227e4D520898545F1904', '1250'], ['0xB9B15eec5Ba6b0582fFe1153d26d54fF6C7a95C6', '1250']]`
- `maxBuyPerCall_` (uint256): `500000000000000000`
- `owner_` (address): `0xD2DeFbd13aFF22D6989E8C14B4517Ec308079E91`

## Events

- `Allocated(uint256,uint256,uint256)`
- `Bought(address,address,uint256,uint256,uint256)`
- `CashcatTreasuryUpdated(address,address)`
- `Collected(address,uint256)`
- `MaxBuyPerCallUpdated(uint256,uint256)`
- `Migrated(address,uint256)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `SplitUpdated(uint16,uint16,uint256)`

## State-changing functions

- `acceptOwnership()`
- `allocate()`
- `buyAndBurn()`
- `buyForCashcatTreasury()`
- `collect(address)`
- `migrate(address)`
- `renounceOwnership()`
- `setCashcatTreasury(address)`
- `setMaxBuyPerCall(uint256)`
- `setSplit(uint16,uint16,tuple[])`
- `transferOwnership(address)`
- `uniswapV3SwapCallback(int256,int256,bytes)`

## View functions

- `BOUNTY_BPS()`
- `BPS_DENOMINATOR()`
- `BURN_ADDRESS()`
- `burnShareBps()`
- `burnTank()`
- `cashcat()`
- `cashcatTreasury()`
- `cashcatTreasuryShareBps()`
- `cashcatTreasuryTank()`
- `maxBuyPerCall()`
- `owed(address)`
- `owner()`
- `participantCount()`
- `participants()`
- `pendingOwner()`
- `pool()`
- `totalOwed()`
- `unallocated()`
- `weth()`
