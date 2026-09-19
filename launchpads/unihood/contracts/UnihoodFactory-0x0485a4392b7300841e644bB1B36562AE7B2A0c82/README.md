# UnihoodFactory - 0x0485a4392b7300841e644bB1B36562AE7B2A0c82

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x0485a4392b7300841e644bB1B36562AE7B2A0c82
Role: UnihoodFactory.
Contract name: UnihoodFactory.
Verified: True (verified at 2026-08-03T08:08:42.995129Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 800.
Main file: src/UnihoodFactory.sol.
Source files written: 31 under `sources/`.
Creator: 0x64900b69E56583C12900F3458525a3fdB6f274D7.
Creation tx: 0x570bc9a8518aae9981c079417a67d231244a22b5b1a3afa4016353a69de92525.
Proxy type: None; implementations: [].

## Constructor arguments

- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `hook_` (address): `0xec392C2b716C4B46df67cA6196ff92f7Dc2De8Cc`
- `startTick_` (int24): `197600`

## Events

- `Launched(address,bytes32,address,string,string,string,int24,uint256,uint256,uint256)`

## State-changing functions

- `launch(string,string,string)`
- `unlockCallback(bytes)`

## View functions

- `LP_FEE_PIPS()`
- `MAX_METAURI_BYTES()`
- `MAX_NAME_BYTES()`
- `MAX_SYMBOL_BYTES()`
- `TICK_SPACING()`
- `TOKEN_SUPPLY()`
- `allTokens(uint256)`
- `hook()`
- `poolIdFor(address)`
- `poolKeyFor(address)`
- `poolManager()`
- `startTick()`
- `tokenCount()`
- `tokensSlice(uint256,uint256)`
