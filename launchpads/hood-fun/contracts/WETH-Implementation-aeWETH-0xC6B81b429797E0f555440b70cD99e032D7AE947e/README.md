# aeWETH - 0xC6B81b429797E0f555440b70cD99e032D7AE947e

Role: WETH-Implementation-aeWETH.
Address: `0xC6B81b429797E0f555440b70cD99e032D7AE947e` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xC6B81b429797E0f555440b70cD99e032D7AE947e
Verified: True (fully verified: True, partially: False).
Compiler: v0.8.16+commit.07a7930e, EVM default, optimizer True runs 100.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `contracts/tokenbridge/libraries/aeWETH.sol`. Source files written: 22 under `sources/`.
Raw constructor args: `None`.

## Functions

- `DOMAIN_SEPARATOR()` -> bytes32 [view]
- `allowance(address owner, address spender)` -> uint256 [view]
- `approve(address spender, uint256 amount)` -> bool [nonpayable]
- `balanceOf(address account)` -> uint256 [view]
- `bridgeBurn(address account, uint256 amount)` ->  [nonpayable]
- `bridgeMint(address, uint256)` ->  [nonpayable]
- `decimals()` -> uint8 [view]
- `decreaseAllowance(address spender, uint256 subtractedValue)` -> bool [nonpayable]
- `deposit()` ->  [payable]
- `depositTo(address account)` ->  [payable]
- `increaseAllowance(address spender, uint256 addedValue)` -> bool [nonpayable]
- `initialize(string name_, string symbol_, uint8 decimals_, address l2Gateway_, address l1Address_)` ->  [nonpayable]
- `l1Address()` -> address [view]
- `l2Gateway()` -> address [view]
- `name()` -> string [view]
- `nonces(address owner)` -> uint256 [view]
- `permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)` ->  [nonpayable]
- `symbol()` -> string [view]
- `totalSupply()` -> uint256 [view]
- `transfer(address to, uint256 amount)` -> bool [nonpayable]
- `transferAndCall(address _to, uint256 _value, bytes _data)` -> bool [nonpayable]
- `transferFrom(address from, address to, uint256 amount)` -> bool [nonpayable]
- `withdraw(uint256 amount)` ->  [nonpayable]
- `withdrawTo(address account, uint256 amount)` ->  [nonpayable]

## Events

- `Approval(address owner, address spender, uint256 value)`
- `Initialized(uint8 version)`
- `Transfer(address from, address to, uint256 value, bytes data)`
- `Transfer(address from, address to, uint256 value)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
