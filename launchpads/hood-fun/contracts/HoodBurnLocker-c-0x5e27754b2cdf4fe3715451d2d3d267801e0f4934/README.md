# HoodBurnLocker - 0x5e27754b2cdf4fe3715451d2d3d267801e0f4934

Role: HoodBurnLocker-c.
Address: `0x5e27754b2cdf4fe3715451d2d3d267801e0f4934` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x5e27754b2cdf4fe3715451d2d3d267801e0f4934
Verified: True (fully verified: True, partially: False).
Compiler: v0.8.28+commit.7893614a, EVM prague, optimizer True runs 200.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `src/HoodBurnLocker.sol`. Source files written: 5 under `sources/`.
Raw constructor args: `0x00000000000000000000000073991a25c818bf1f1128deaab1492d45638de0d30000000000000000000000000bd7d308f8e1639fab988df18a8011f41eacad73`.

Decoded constructor args:
- nfpm_ (address): `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3`
- weth_ (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`

## Functions

- `BURN_BPS()` -> uint256 [view]
- `WETH()` -> address [view]
- `collectRewards(uint256 tokenId)` -> uint256, uint256 [nonpayable]
- `nfpm()` -> address [view]
- `onERC721Received(address, address, uint256 tokenId, bytes data)` -> bytes4 [nonpayable]
- `rewards(uint256 tokenId)` -> address, address, uint16 [view]

## Events

- `Collected(uint256 tokenId, address caller, uint256 creatorWeth, uint256 protocolWeth, uint256 burnedTokens, uint256 protocolTokens)`
- `Locked(uint256 tokenId, address creator, address protocol, uint16 creatorShareBps)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
