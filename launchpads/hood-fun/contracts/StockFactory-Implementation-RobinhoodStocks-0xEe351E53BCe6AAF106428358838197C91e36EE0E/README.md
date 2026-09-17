# StockFactory - 0xEe351E53BCe6AAF106428358838197C91e36EE0E

Role: StockFactory-Implementation-RobinhoodStocks.
Address: `0xEe351E53BCe6AAF106428358838197C91e36EE0E` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xEe351E53BCe6AAF106428358838197C91e36EE0E
Verified: True (fully verified: True, partially: False).
Compiler: v0.8.33+commit.64118f21, EVM cancun, optimizer True runs 200.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `src/StockFactory.sol`. Source files written: 22 under `sources/`.
Raw constructor args: `0x000000000000000000000000e10b6f6b275de231345c20d14ab812db62151b00`.

Decoded constructor args:
- registryAndBeacon (address): `0xe10b6f6B275de231345c20D14Ab812db62151b00`

## Functions

- `ACCESS_CONTROLLED_REGISTRY()` -> address [view]
- `UPGRADE_INTERFACE_VERSION()` -> string [view]
- `beacon()` -> address [view]
- `deploy(bytes32 uid_, string name_, string symbol_)` -> address [nonpayable]
- `initialize()` ->  [nonpayable]
- `proxiableUUID()` -> bytes32 [view]
- `tokenAddress(bytes32 uid_)` -> address [view]
- `upgradeToAndCall(address newImplementation, bytes data)` ->  [payable]

## Events

- `Deployed(bytes32 uid, address stock, string name, string symbol)`
- `Initialized(uint64 version)`
- `Upgraded(address implementation)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
