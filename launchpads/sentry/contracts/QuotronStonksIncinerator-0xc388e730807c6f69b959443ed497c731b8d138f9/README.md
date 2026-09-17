# QuotronStonksIncinerator - 0xc388e730807c6f69b959443ed497c731b8d138f9

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xc388e730807c6f69b959443ed497c731b8d138f9
Role: QuotronStonksIncinerator.
Contract name: QuotronStonksIncinerator.
Verified: True (verified at 2026-08-22T16:09:38.304669Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/v2/QuotronStonksIncinerator.sol.
Source files written: 19 under `sources/`.
Creator: 0x7171E64E979265aeD6588577D1c6b60A701d7866.
Creation tx: 0x540e264c26efb3b174bc0042b20d5ea6cc607efc834e0b25cf32ad93aefd9af7.
Proxy type: None; implementations: [].

Quotrons incinerator.

## Constructor arguments

- `converter_` (address): `0x24e62Dd5C7058CC41ad9c5375C137460ea1Da2FE`
- `router_` (address): `0x42024fCFdB4F3089Dd619A0cEF0Cd24E7b841C18`
- `routes_` (tuple[10]): `[['0xd0601CE157Db5bdC3162BbaC2a2C8aF5320D9EEC', '500', '0', '0x0000000000000000000000000000000000000000', '1'], ['0xaF3D76f1834A1d425780943C99Ea8A608f8a93f9', '3000', '60', '0x0000000000000000000000000000000000000000', '0'], ['0x322F0929c4625eD5bAd873c95208D54E1c003b2d', '3000', '0', '0x0000000000000000000000000000000000000000', '1'], ['0x1b0E319c6A659F002271B69dB8A7df2F911c153E', '10000', '0', '0x0000000000000000000000000000000000000000', '1'], ['0x4a0E65A3EcceC6dBe60AE065F2e7bb85Fae35eEa', '10000', '200', '0x0000000000000000000000000000000000000000', '0'], ['0x117cc2133c37B721F49dE2A7a74833232B3B4C0C', '500', '5', '0x0000000000000000000000000000000000000000', '0'], ['0x894E1EC2D74FFE5AEF8Dc8A9e84686acCB964F2A', '10000', '200', '0x0000000000000000000000000000000000000000', '0'], ['0xE0444EF8BF4eD74f74FD73686e2ddF4C1c5591E8', '10000', '100', '0x0000000000000000000000000000000000000000', '0'], ['0x05b37Fb53A299a1b874A619e1c4C404D52C36F4C', '10000', '0', '0x0000000000000000000000000000000000000000', '1'], ['0xec262a75e413fAfD0dF80480274532C79D42da09', '10000', '0', '0x0000000000000000000000000000000000000000', '1']]`

## Events

- `Incinerated(address,uint256,uint256,uint256,bool)`
- `IncineratedForQuotron(address,uint256,uint256,uint256,uint256)`
- `Rescued(address,uint256)`
- `StockIncinerated(address,address,uint256,uint256)`

## State-changing functions

- `incinerate(uint256[10],bool,uint256,uint256,uint256)`
- `incinerateAny(tuple[],bool,uint256,uint256,uint256)`
- `incinerateAnyForQuotron(tuple[],tuple[],uint256,uint256,uint256,uint256)`
- `incinerateAnyWithPermits(tuple[],tuple[],bool,uint256,uint256,uint256)`
- `incinerateForQuotron(uint256[10],tuple[10],uint256,uint256,uint256,uint256)`
- `incinerateWithPermits(uint256[10],tuple[10],bool,uint256,uint256,uint256)`
- `rescue(address)`
- `rescueNative()`
- `unlockCallback(bytes)`

## View functions

- `FEE_BPS()`
- `FEE_RECIPIENT()`
- `VENUE_V3()`
- `VENUE_V4()`
- `poolManager()`
- `quotronRouter()`
- `routes(uint256)`
- `usdg()`
- `v3Router()`
- `weth()`
- `wethUsdgFee()`
