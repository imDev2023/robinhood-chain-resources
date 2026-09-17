# HoodCustomLaunchpad - 0x3d1c455f81ec131cc91b000b42fccbf45a132026

Role: HoodCustomLaunchpad-c.
Address: `0x3d1c455f81ec131cc91b000b42fccbf45a132026` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x3d1c455f81ec131cc91b000b42fccbf45a132026
Verified: True (fully verified: True, partially: False).
Compiler: v0.8.28+commit.7893614a, EVM prague, optimizer True runs 200.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `src/HoodCustomLaunchpad.sol`. Source files written: 13 under `sources/`.
Raw constructor args: `0x0000000000000000000000008bceaa40b9acdfaedf85adf4ff01f5ad6517937f0000000000000000000000000bd7d308f8e1639fab988df18a8011f41eacad73000000000000000000000000b3f3b54e11217f4f73e7a766b7caa187390d700d`.

Decoded constructor args:
- uniswapFactory_ (address): `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f`
- weth_ (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- owner_ (address): `0xB3f3B54E11217F4F73e7a766B7CAA187390d700D`

## Functions

- `ANTI_SNIPE_MAX_WALLET_BPS()` -> uint256 [view]
- `ANTI_SNIPE_WINDOW()` -> uint256 [view]
- `CTO_TIMELOCK()` -> uint256 [view]
- `CURVE_BPS()` -> uint256 [view]
- `DEFAULT_TOTAL_SUPPLY()` -> uint256 [view]
- `DEFAULT_VIRTUAL_TOKEN_SEED()` -> uint256 [view]
- `MAX_MIGRATION_FEE_BPS()` -> uint256 [view]
- `MAX_PROTOCOL_MIGRATION_FEE()` -> uint256 [view]
- `MAX_TOTAL_SUPPLY()` -> uint256 [view]
- `MAX_TRADE_FEE_BPS()` -> uint256 [view]
- `MAX_WALLET_BPS()` -> uint256 [view]
- `MIN_TOTAL_SUPPLY()` -> uint256 [view]
- `MIN_TRADE_FEE_BPS()` -> uint256 [view]
- `acceptOwnership()` ->  [nonpayable]
- `allTokens(uint256)` -> address [view]
- `antiSnipeEnabled(address token)` -> bool [view]
- `buy(address token, uint256 minTokensOut)` ->  [payable]
- `buyFor(address token, address recipient, uint256 minTokensOut)` ->  [payable]
- `cancelCto(address token)` ->  [nonpayable]
- `claimCreatorFees(address token)` ->  [nonpayable]
- `claimPendingCreatorFees()` ->  [nonpayable]
- `claimPlatformFees()` ->  [nonpayable]
- `config()` -> uint128, uint64, uint16, uint64, uint16, uint16, uint16, uint16, bool [view]
- `createToken(string name, string symbol, string metadataURI, uint256 minTokensOut, bytes32 salt, uint16 tradeFeeBps, uint256 totalSupply_)` -> address [payable]
- `createTokenFor(address creator, string name, string symbol, string metadataURI, uint256 minTokensOut, bytes32 salt, uint16 tradeFeeBps, uint256 totalSupply_)` -> address [payable]
- `createTokenForGuarded(address creator, string name, string symbol, string metadataURI, uint256 minTokensOut, bytes32 salt, uint16 tradeFeeBps, uint256 totalSupply_, bool antiSnipe, bool maxWallet)` -> address [payable]
- `createTokenGuarded(string name, string symbol, string metadataURI, uint256 minTokensOut, bytes32 salt, uint16 tradeFeeBps, uint256 totalSupply_, bool antiSnipe, bool maxWallet)` -> address [payable]
- `creatorFees(address token)` -> uint256 [view]
- `ctoPending(address token)` -> address [view]
- `ctoUnlockAt(address token)` -> uint256 [view]
- `currentPrice(address token)` -> uint256 [view]
- `curves(address token)` -> uint128, uint128, uint128, uint128, address, uint48, bool, bool, uint16 [view]
- `executeCto(address token)` ->  [nonpayable]
- `getCurve(address token)` -> tuple [view]
- `guardBought(address token, address wallet)` -> uint256 [view]
- `isHoodToken(address token)` -> bool [view]
- `launchTime(address token)` -> uint48 [view]
- `maxWalletEnabled(address token)` -> bool [view]
- `migrate(address token)` -> address [nonpayable]
- `migrator()` -> address [view]
- `owner()` -> address [view]
- `pendingCreatorClaim(address creator)` -> uint256 [view]
- `pendingOwner()` -> address [view]
- `platformFees(address platform)` -> uint256 [view]
- `platforms(address platform)` -> bool, uint16 [view]
- `predictTokenAddress(address caller, bytes32 salt, string name, string symbol, uint256 totalSupply_)` -> address [view]
- `progressBps(address token)` -> uint256 [view]
- `proposeCto(address token, address newCreator)` ->  [nonpayable]
- `protocolFeesAccrued()` -> uint256 [view]
- `protocolMigrationFee()` -> uint256 [view]
- `quoteBuy(address token, uint256 ethIn)` -> uint256, uint256, uint256 [view]
- `quoteSell(address token, uint256 tokenAmount)` -> uint256, uint256 [view]
- `renounceOwnership()` ->  [nonpayable]
- `sell(address token, uint256 tokenAmount, uint256 minEthOut)` ->  [nonpayable]
- `setConfig(tuple newConfig)` ->  [nonpayable]
- `setMigrator(address migrator_)` ->  [nonpayable]
- `setPlatform(address platform, bool approved, uint16 feeShareBps)` ->  [nonpayable]
- `setProtocolMigrationFee(uint256 fee)` ->  [nonpayable]
- `tokenCount()` -> uint256 [view]
- `tokenCurveSupply(address token)` -> uint256 [view]
- `tokenInitCodeHash(string name, string symbol, uint256 totalSupply_)` -> bytes32 [pure]
- `tokenLpSupply(address token)` -> uint256 [view]
- `tokenPlatform(address token)` -> address [view]
- `tokens(uint256 offset, uint256 limit)` -> address[] [view]
- `totalSupplyOf(address token)` -> uint256 [view]
- `transferCreator(address token, address to)` ->  [nonpayable]
- `transferOwnership(address newOwner)` ->  [nonpayable]
- `uniswapFactory()` -> address [view]
- `walletBought(address token, address wallet)` -> uint256 [view]
- `weth()` -> address [view]
- `withdrawFees(address to)` ->  [nonpayable]

## Events

- `ConfigUpdated(tuple config)`
- `CreatorFeesClaimed(address token, address creator, uint256 amount)`
- `CreatorTransferred(address token, address from, address to)`
- `CtoCancelled(address token)`
- `CtoExecuted(address token, address newCreator)`
- `CtoProposed(address token, address from, address newCreator, uint256 unlockAt)`
- `FeesWithdrawn(address to, uint256 amount)`
- `Graduated(address token, uint256 raisedEth)`
- `Migrated(address token, address pair, uint256 ethLiquidity, uint256 tokenLiquidity, uint256 lpBurned)`
- `MigratorSet(address migrator)`
- `OwnershipTransferStarted(address previousOwner, address newOwner)`
- `OwnershipTransferred(address previousOwner, address newOwner)`
- `PendingCreatorFeesClaimed(address creator, uint256 amount)`
- `PlatformFeesClaimed(address platform, uint256 amount)`
- `PlatformLaunch(address token, address platform, address creator)`
- `PlatformSet(address platform, bool approved, uint16 feeShareBps)`
- `ProtocolMigrationFeeSet(uint256 fee)`
- `TokenCreated(address token, address creator, string name, string symbol, string metadataURI, uint256 virtualEth, uint256 virtualTokens, uint256 curveSupply)`
- `Trade(address token, address trader, bool isBuy, uint256 ethAmount, uint256 tokenAmount, uint256 fee, uint256 virtualEthAfter, uint256 virtualTokensAfter)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
