# LPVault - 0x0f0e601041ec765b8bab8c166840e291253f2df0

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x0f0e601041ec765b8bab8c166840e291253f2df0
Role: LPVault.
Contract name: SentryLPVault.
Verified: True (verified at 2026-07-24T20:11:27.622840Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/SentryLPVault.sol.
Source files written: 26 under `sources/`.
Creator: 0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5.
Creation tx: 0x53fde64d743d4e489aec5eafe68bf8a69a784536d75f877f5c60443292620663.
Proxy type: None; implementations: [].

Immutable custodian of every launch's liquidity. No withdrawal function; `collectV3Fees` and `collectV4Fees` only move fees.

## Constructor arguments

- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_v4FactoryWeth` (address): `0x472286b7d5c1B2A3cE1132eF73d3BcCF446C5cc1`
- `_v4FactoryStock` (address): `0xd0A93885a387e3a8a14dd82776CF9104a3676b3A`
- `_v3Npm` (address): `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3`
- `_v3Factory` (address): `0x9e8f6f8214b01Fd4Cf1d73FB1fb7cf9f811036Cb`
- `_admin` (address): `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5`
- `_treasury` (address): `0xcaAfCf8E55f3B5e3D5F7957987db232f08d2367c`
- `_creatorFeeBps` (uint256): `7000`

## Events

- `AdminTransferStarted(address,address)`
- `AdminTransferred(address,address)`
- `CreatorFeeBpsUpdated(uint256,uint256)`
- `TreasuryUpdated(address,address)`
- `V3CreatorFeePaid(uint256,address,address,uint256)`
- `V3FeeRecipientUpdated(uint256,address,address)`
- `V3FeesCollected(uint256,uint256,uint256)`
- `V3PositionReceived(uint256,address,address)`
- `V4CreatorFeePaid(address,address,address,uint256)`
- `V4FeesCollected(address,uint256,uint256)`
- `V4LiquidityLocked(address,bytes32,uint128)`
- `VaultCustodyAccepted(address)`

## State-changing functions

- `acceptAdmin()`
- `acceptVaultRole(address)`
- `adminSetV3FeeRecipient(uint256,address)`
- `collectV3Fees(uint256)`
- `collectV4Fees(address)`
- `lockLaunchLiquidity(address,tuple,int24,int24,uint256,uint256)`
- `migrateV3FeeRecipient(uint256,address)`
- `onERC721Received(address,address,uint256,bytes)`
- `setCreatorFeeBps(uint256)`
- `setTreasury(address)`
- `transferAdmin(address)`
- `unlockCallback(bytes)`

## View functions

- `admin()`
- `creatorFeeBps()`
- `isV4Locked(address)`
- `pendingAdmin()`
- `poolManager()`
- `treasury()`
- `v3Creator(uint256)`
- `v3Factory()`
- `v3FeeRecipient(uint256)`
- `v3FeeRecipientMigrated(uint256)`
- `v3FeeRecipientOf(uint256)`
- `v3Held(uint256)`
- `v3Npm()`
- `v4FactoryStock()`
- `v4FactoryWeth()`
- `v4Positions(address)`
