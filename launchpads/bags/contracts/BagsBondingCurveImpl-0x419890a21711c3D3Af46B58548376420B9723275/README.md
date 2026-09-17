# BagsBondingCurveImpl - 0x419890a21711c3D3Af46B58548376420B9723275

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x419890a21711c3D3Af46B58548376420B9723275
Role: BagsBondingCurveImpl.
Contract name: BagsBondingCurve.
Verified: True (verified at 2026-07-12T15:03:04.829965Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/BagsBondingCurve.sol.
Source files written: 56 under `sources/`.
Creator: 0xDEf671F11C8a30818eb3D9Cc9476EEEc805f9058.
Creation tx: 0xcb66521f14d39cb399eef4d1f8cad236980e542457f36111daa12ff788d71f67.
Proxy type: None; implementations: [].

Beacon implementation that every per-token curve delegates to.

## Constructor arguments

- `poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `positionManager` (address): `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `weth` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `vault_` (address): `0x4861446aa7fFd9e67a83cBbAcb1A4B70540B83Aa`
- `permit2` (address): `0x000000000022D473030F116dDEE9F6B43aC78BA3`

## Events

- `FeesSplit(address,address,address,uint256,uint256,uint256)`
- `Initialized(address,uint256)`
- `Initialized(uint64)`
- `Migrated(address,address,address,uint256,uint256,bytes32,uint160)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `Paused(address)`
- `RoleAdminChanged(bytes32,bytes32,bytes32)`
- `RoleGranted(bytes32,address,address)`
- `RoleRevoked(bytes32,address,address)`
- `TokensBought(address,address,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256)`
- `TokensSold(address,address,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256)`
- `Unpaused(address)`

## State-changing functions

- `acceptOwnership()`
- `buy(uint256)`
- `buyFor(address,uint256)`
- `grantRole(bytes32,address)`
- `initialize(address,address,address,address,address,address,address,uint16,uint256)`
- `initializeAfterMint()`
- `migrate()`
- `pause()`
- `renounceOwnership()`
- `renounceRole(bytes32,address)`
- `revokeRole(bytes32,address)`
- `sell(uint256,uint256)`
- `sellFor(address,uint256,uint256)`
- `transferOwnership(address)`
- `unpause()`

## View functions

- `ADMIN_ROLE()`
- `DEAD()`
- `DEFAULT_ADMIN_ROLE()`
- `FEE_SHARE()`
- `HOOK()`
- `INITIAL_VIRTUAL_TOKEN_RESERVES()`
- `LP_TOKEN_AMOUNT()`
- `PERMIT2()`
- `POOL_MANAGER()`
- `POSITION_MANAGER()`
- `TOKEN()`
- `TX_FEE_BPS()`
- `VAULT()`
- `WETH()`
- `bondingProgress()`
- `creator()`
- `currentPrice()`
- `getRoleAdmin(bytes32)`
- `getVirtualReserves()`
- `hasRole(bytes32,address)`
- `initialVirtualQuoteReserves()`
- `initialized()`
- `lpQuoteAmount()`
- `migrated()`
- `owner()`
- `partner()`
- `partnerFeeBps()`
- `paused()`
- `pendingOwner()`
- `platformAdmin()`
- `quoteBuy(uint256)`
- `quoteSell(uint256)`
- `realQuoteReserves()`
- `realTokenReserves()`
- `supportsInterface(bytes4)`
- `thresholdQuote()`
