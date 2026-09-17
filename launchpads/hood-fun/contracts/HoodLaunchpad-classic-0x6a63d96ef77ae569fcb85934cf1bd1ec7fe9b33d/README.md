# HoodLaunchpad - 0x6a63d96ef77ae569fcb85934cf1bd1ec7fe9b33d

Role: HoodLaunchpad-classic.
Address: `0x6a63d96ef77ae569fcb85934cf1bd1ec7fe9b33d` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x6a63d96ef77ae569fcb85934cf1bd1ec7fe9b33d
Verified: True (fully verified: True, partially: False).
Compiler: v0.8.28+commit.7893614a, EVM prague, optimizer True runs 5000.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `src/HoodLaunchpad.sol`. Source files written: 13 under `sources/`.
Raw constructor args: `0x0000000000000000000000008bceaa40b9acdfaedf85adf4ff01f5ad6517937f0000000000000000000000000bd7d308f8e1639fab988df18a8011f41eacad73000000000000000000000000b3f3b54e11217f4f73e7a766b7caa187390d700d`.

Decoded constructor args:
- uniswapFactory_ (address): `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f`
- weth_ (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- owner_ (address): `0xB3f3B54E11217F4F73e7a766B7CAA187390d700D`

## Functions

- `CURVE_SUPPLY()` -> uint256 [view]
- `LP_SUPPLY()` -> uint256 [view]
- `MAX_MIGRATION_FEE_BPS()` -> uint256 [view]
- `MAX_TRADE_FEE_BPS()` -> uint256 [view]
- `MIN_TRADE_FEE_BPS()` -> uint256 [view]
- `TOTAL_SUPPLY()` -> uint256 [view]
- `VIRTUAL_TOKEN_SEED()` -> uint256 [view]
- `acceptOwnership()` ->  [nonpayable]
- `allTokens(uint256)` -> address [view]
- `buy(address token, uint256 minTokensOut)` ->  [payable]
- `buyFor(address token, address recipient, uint256 minTokensOut)` ->  [payable]
- `claimCreatorFees(address token)` ->  [nonpayable]
- `claimPlatformFees()` ->  [nonpayable]
- `config()` -> uint128, uint64, uint16, uint64, uint16, uint16, uint16, uint16, bool [view]
- `createToken(string name, string symbol, string metadataURI, uint256 minTokensOut, bytes32 salt, uint16 tradeFeeBps)` -> address [payable]
- `createTokenFor(address creator, string name, string symbol, string metadataURI, uint256 minTokensOut, bytes32 salt, uint16 tradeFeeBps)` -> address [payable]
- `creatorFees(address token)` -> uint256 [view]
- `currentPrice(address token)` -> uint256 [view]
- `curves(address token)` -> uint128, uint128, uint128, uint128, address, uint48, bool, bool, uint16 [view]
- `getCurve(address token)` -> tuple [view]
- `guardBought(address token, address wallet)` -> uint256 [view]
- `isHoodToken(address token)` -> bool [view]
- `migrate(address token)` -> address [nonpayable]
- `migrator()` -> address [view]
- `owner()` -> address [view]
- `pendingOwner()` -> address [view]
- `platformFees(address platform)` -> uint256 [view]
- `platforms(address platform)` -> bool, uint16 [view]
- `predictTokenAddress(address creator, bytes32 salt, string name, string symbol)` -> address [view]
- `progressBps(address token)` -> uint256 [view]
- `protocolFeesAccrued()` -> uint256 [view]
- `quoteBuy(address token, uint256 ethIn)` -> uint256, uint256, uint256 [view]
- `quoteSell(address token, uint256 tokenAmount)` -> uint256, uint256 [view]
- `renounceOwnership()` ->  [nonpayable]
- `sell(address token, uint256 tokenAmount, uint256 minEthOut)` ->  [nonpayable]
- `setConfig(tuple newConfig)` ->  [nonpayable]
- `setMigrator(address migrator_)` ->  [nonpayable]
- `setPlatform(address platform, bool approved, uint16 feeShareBps)` ->  [nonpayable]
- `tokenCount()` -> uint256 [view]
- `tokenInitCodeHash(string name, string symbol)` -> bytes32 [pure]
- `tokenPlatform(address token)` -> address [view]
- `tokens(uint256 offset, uint256 limit)` -> address[] [view]
- `transferOwnership(address newOwner)` ->  [nonpayable]
- `uniswapFactory()` -> address [view]
- `weth()` -> address [view]
- `withdrawFees(address to)` ->  [nonpayable]

## Events

- `ConfigUpdated(tuple config)`
- `CreatorFeesClaimed(address token, address creator, uint256 amount)`
- `FeesWithdrawn(address to, uint256 amount)`
- `Graduated(address token, uint256 raisedEth)`
- `Migrated(address token, address pair, uint256 ethLiquidity, uint256 tokenLiquidity, uint256 lpBurned)`
- `MigratorSet(address migrator)`
- `OwnershipTransferStarted(address previousOwner, address newOwner)`
- `OwnershipTransferred(address previousOwner, address newOwner)`
- `PlatformFeesClaimed(address platform, uint256 amount)`
- `PlatformLaunch(address token, address platform, address creator)`
- `PlatformSet(address platform, bool approved, uint16 feeShareBps)`
- `TokenCreated(address token, address creator, string name, string symbol, string metadataURI, uint256 virtualEth, uint256 virtualTokens, uint256 curveSupply)`
- `Trade(address token, address trader, bool isBuy, uint256 ethAmount, uint256 tokenAmount, uint256 fee, uint256 virtualEthAfter, uint256 virtualTokensAfter)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
