# HoodLiquidityLocker - 0x86083371c51654816518c35cc589871c24018a54

Role: HoodLiquidityLocker-classic.
Address: `0x86083371c51654816518c35cc589871c24018a54` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x86083371c51654816518c35cc589871c24018a54
Verified: True (fully verified: True, partially: False).
Compiler: v0.8.28+commit.7893614a, EVM prague, optimizer True runs 5000.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `src/HoodLiquidityLocker.sol`. Source files written: 5 under `sources/`.
Raw constructor args: `0x00000000000000000000000073991a25c818bf1f1128deaab1492d45638de0d3`.

Decoded constructor args:
- nfpm_ (address): `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3`

## Functions

- `collectRewards(uint256 tokenId)` -> uint256, uint256 [nonpayable]
- `nfpm()` -> address [view]
- `onERC721Received(address, address, uint256 tokenId, bytes data)` -> bytes4 [nonpayable]
- `rewards(uint256 tokenId)` -> address, address, uint16 [view]

## Events

- `Collected(uint256 tokenId, address caller, uint256 creatorAmount0, uint256 creatorAmount1, uint256 protocolAmount0, uint256 protocolAmount1)`
- `Locked(uint256 tokenId, address creator, address protocol, uint16 creatorShareBps)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
