# Stock - 0xb35490d6f9163DE4F80d88dc75c3516eb64C5aE2

Role: Stock-Implementation.
Address: `0xb35490d6f9163DE4F80d88dc75c3516eb64C5aE2` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xb35490d6f9163DE4F80d88dc75c3516eb64C5aE2
Verified: True (fully verified: True, partially: False).
Compiler: v0.8.33+commit.64118f21, EVM cancun, optimizer True runs 200.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `src/Stock.sol`. Source files written: 33 under `sources/`.
Raw constructor args: `0x000000000000000000000000e10b6f6b275de231345c20d14ab812db62151b00`.

Decoded constructor args:
- registry (address): `0xe10b6f6B275de231345c20D14Ab812db62151b00`

## Functions

- `ACCESS_CONTROLLED_REGISTRY()` -> address [view]
- `DOMAIN_SEPARATOR()` -> bytes32 [view]
- `adminBurn(address from, uint256 amount)` ->  [nonpayable]
- `allowance(address owner, address spender)` -> uint256 [view]
- `approve(address spender, uint256 value)` -> bool [nonpayable]
- `balanceOf(address account)` -> uint256 [view]
- `balanceOfUI(address account)` -> uint256 [view]
- `burn(address from, uint256 amount)` ->  [nonpayable]
- `decimals()` -> uint8 [view]
- `effectiveAt()` -> uint256 [view]
- `eip712Domain()` -> bytes1, string, string, uint256, address, bytes32, uint256[] [view]
- `initialize(bytes32 uid_, string name_, string symbol_)` ->  [nonpayable]
- `mint(address to, uint256 amount)` ->  [nonpayable]
- `name()` -> string [view]
- `newUIMultiplier()` -> uint256 [view]
- `nonces(address owner)` -> uint256 [view]
- `oraclePaused()` -> bool [view]
- `pause()` ->  [nonpayable]
- `pauseOracle()` ->  [nonpayable]
- `paused()` -> bool [view]
- `permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)` ->  [nonpayable]
- `setMetadata(string _name, string _symbol)` ->  [nonpayable]
- `supportsInterface(bytes4 interfaceId)` -> bool [view]
- `symbol()` -> string [view]
- `terms()` -> string [pure]
- `tokenPaused()` -> bool [view]
- `totalSupply()` -> uint256 [view]
- `totalSupplyUI()` -> uint256 [view]
- `transfer(address to, uint256 value)` -> bool [nonpayable]
- `transferFrom(address from, address to, uint256 value)` -> bool [nonpayable]
- `uiMultiplier()` -> uint256 [view]
- `uid()` -> bytes32 [view]
- `unpause()` ->  [nonpayable]
- `unpauseOracle()` ->  [nonpayable]
- `updateMultiplier(uint256 newMultiplier)` ->  [nonpayable]
- `updateMultiplier(uint256 newMultiplier, uint256 effectiveAt_)` ->  [nonpayable]

## Events

- `Approval(address owner, address spender, uint256 value)`
- `EIP712DomainChanged()`
- `Initialized(uint64 version)`
- `MetaDataUpdated(string name, string symbol)`
- `OraclePaused()`
- `OracleUnpaused()`
- `Paused()`
- `Transfer(address from, address to, uint256 value)`
- `TransferWithScaledUI(address from, address to, uint256 value, uint256 uiValue)`
- `UIMultiplierUpdated(uint256 oldMultiplier, uint256 newMultiplier, uint256 effectiveAtTimestamp)`
- `Unpaused()`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
