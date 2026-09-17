# UniswapV2Pool-MOON-0x55aED1a1406Ad8821B3CD0b3a189757aCF007447

**Graduated Uniswap V2 pair for $moon, verified**

- Address: `0x55aED1a1406Ad8821B3CD0b3a189757aCF007447`
- Contract name on Blockscout: `Uniswap V2`
- Verified: yes
- Proxy type: `none`
- Creator: `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f`
- Creation tx: `0x7bf1c44f42a0ce53f3ea3fcc5b184cd39aaca741eb454ce19afd14a31e77b584`
- Compiler: `v0.5.16+commit.9c3226ce`, optimizer on (999999 runs), EVM `istanbul`
- License: `none`
- Explorer: <https://robinhoodchain.blockscout.com/address/0x55aED1a1406Ad8821B3CD0b3a189757aCF007447>

The destination of a Robinhood-chain graduation.
`totalSupply()` is `44821502752390679081447` and `balanceOf(0x...dEaD)` is `44790004104703970611336`, so **99.93% of the LP is burned** (`_raw/rpc/lp-and-token-state.txt`).
Nothing on this chain locks LP for the creator to claim from; the position is destroyed.

## Functions that matter for launching

- `initialize(address,address)`  [nonpayable]
- `swap(uint256,uint256,address,bytes)`  [nonpayable]

## Events

- `Approval(address,address,uint256)`
- `Burn(address,uint256,uint256,address)`
- `Mint(address,uint256,uint256)`
- `Swap(address,uint256,uint256,uint256,uint256,address)`
- `Sync(uint112,uint112)`
- `Transfer(address,address,uint256)`

## Files in this directory

- `abi.json`
- `address.json`
- `metadata.json`
- `methods-read.json`
- `sources`/
