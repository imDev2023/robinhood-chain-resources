# HoodStockPairMigrator - 0xC14F3Be12F5c0f3eE544Fc4E8883be981197f0be

Role: HoodStockPairMigrator.
Address: `0xC14F3Be12F5c0f3eE544Fc4E8883be981197f0be` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xC14F3Be12F5c0f3eE544Fc4E8883be981197f0be
Verified: True (fully verified: True, partially: False).
Compiler: v0.8.28+commit.7893614a, EVM prague, optimizer True runs 200.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `src/HoodStockPairMigrator.sol`. Source files written: 12 under `sources/`.
Raw constructor args: `0x0000000000000000000000008c529f0a77c07ce0e6796f153d292501ee6f66f600000000000000000000000073991a25c818bf1f1128deaab1492d45638de0d3000000000000000000000000d2a7c92fcb240c755919e9230c8db066e9ca15000000000000000000000000000bd7d308f8e1639fab988df18a8011f41eacad73000000000000000000000000159089f48b4f0e51f430f7df6fe1064bec0258df0000000000000000000000000000000000000000000000000000000000001f40000000000000000000000000caf681a66d020601342297493863e78c959e5cb20000000000000000000000001f7d7550b1b028f7571e69a784071f0205fd2efa0000000000000000000000008e96a84adc54d04869ded92661a01f75e283741b`.

Decoded constructor args:
- launchpad_ (address): `0x8c529f0a77C07CE0e6796f153D292501eE6F66f6`
- nfpm_ (address): `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3`
- locker_ (address): `0xD2a7C92FcB240c755919E9230c8DB066E9Ca1500`
- weth_ (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- protocol_ (address): `0x159089F48b4F0e51f430f7df6fe1064bEc0258dF`
- creatorShareBps_ (uint16): `8000`
- swapRouter_ (address): `0xCaf681a66D020601342297493863E78C959E5cb2`
- v3Factory_ (address): `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`
- owner_ (address): `0x8E96a84AdC54d04869ded92661a01f75e283741B`

## Functions

- `FEE()` -> uint24 [view]
- `authorizedSelector(address)` -> bool [view]
- `creatorShareBps()` -> uint16 [view]
- `launchpad()` -> address [view]
- `locker()` -> address [view]
- `maxSlippageBps()` -> uint16 [view]
- `migrate(address token, address creator)` -> address [payable]
- `nfpm()` -> address [view]
- `owner()` -> address [view]
- `pathFor(address quote)` -> bytes [view]
- `protocol()` -> address [view]
- `quoteMigrate(address token, address creator, address quote, uint256 ethIn)` -> address [nonpayable]
- `quoteOf(address token)` -> address [view]
- `renounceOwnership()` ->  [nonpayable]
- `rescueETH(address to)` ->  [nonpayable]
- `rescueTokens(address token, uint256 amount, address to)` ->  [nonpayable]
- `selectQuote(address token, address quote)` ->  [nonpayable]
- `setAuthorizedSelector(address who, bool ok)` ->  [nonpayable]
- `setMaxSlippageBps(uint16 bps)` ->  [nonpayable]
- `setQuotePath(address quote, bytes path)` ->  [nonpayable]
- `setTwapWindow(uint32 secs)` ->  [nonpayable]
- `swapRouter()` -> address [view]
- `transferOwnership(address newOwner)` ->  [nonpayable]
- `twapWindow()` -> uint32 [view]
- `v3Factory()` -> address [view]
- `weth()` -> address [view]

## Events

- `OwnershipTransferred(address previousOwner, address newOwner)`
- `QuoteMigrateFellBack(address token, address quote)`
- `QuotePathSet(address quote, bytes path)`
- `QuoteSelected(address token, address quote)`
- `V3Migrated(address token, address pool, uint256 tokenId, uint256 tokenLiq, uint256 quoteLiq)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
