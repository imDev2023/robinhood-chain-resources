# DividendDeployer - 0x3087cFD761D679Ded5d0a2baf4d3577aE447d5E3

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x3087cFD761D679Ded5d0a2baf4d3577aE447d5E3
Role: DividendDeployer.
Contract name: DividendDeployer.
Verified: True (verified at 2026-08-31T12:31:13.025733Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 800.
Main file: src/DividendDeployer.sol.
Source files on disk: 24 under `sources/`.
Creator: 0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862.
Creation tx: 0xafda2c80ee02a0707375fca553c2bcf65d5f60608f0587854ada922976090787.
Proxy type: None; implementations: [].
External libraries: none.

## What it does

The reflection-launch path.
`deployFor(poolId, minDistribution, maxCutBps)` deploys a `LaunchDividendTreasury` and a `CreatorFeeSplitter` for one pool, deriving the token and quote from `LaunchFactory.launches(poolId)` so a caller cannot point a pair at somebody else's launch.
The creator then calls `LaunchHook.transferCreator(poolId, splitter)` and the splitter accepts, which is the second and third transaction the create form warns about.
`MAX_CUT_BPS` is 3000: the pad may take up to 30% of the creator's fee lane on the way to holders.
Live state at capture: `owner` 0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862, `feeRecipient` 0x7e8ADA37D066a124Cd0A044c1209c48338c962fe.
Seven pairs deployed at capture (`_raw/blockscout/dividenddeployer-logs.json`).

## Constructor arguments

- `launchFactory_` (address): `0x718633252AA8329495Df8BBa8fF7c9e8378CFC63`
- `hook_` (address): `0xe6234a98fF84220CcDA12985548ddAb36327Aacc`
- `quotes_` (address): `0x5D8b610E39156d2cFeF3c1ceCC3c22f4990A1298`
- `weth_` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `initialOwner` (address): `0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862`
- `feeRecipient_` (address): `0x7e8ADA37D066a124Cd0A044c1209c48338c962fe`
- `keeper_` (address): `0xAdf62968f34Aae03bF242AbF95dB48b9B080FFE6`

## Events

- `FeeRecipientSet(address)`
- `KeeperSet(address)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `PairDeployed(bytes32,address,address,address,address)`

## State-changing functions

- `acceptOwnership()`
- `deployFor(bytes32,uint256,uint256)`
- `setFeeRecipient(address)`
- `setKeeper(address)`
- `transferOwnership(address)`

## View functions

- `feeRecipient()`
- `hook()`
- `keeper()`
- `launchFactory()`
- `owner()`
- `pairOf(bytes32)`
- `pendingOwner()`
- `quotes()`
- `renounceOwnership()`
- `weth()`
