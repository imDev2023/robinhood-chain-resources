# SinjohFlapAdapterImpl-0x4c34af31ef8962317497Cc558612a48443971243

**SinjohFlapAdapter implementation, verified**

- Address: `0x4c34af31ef8962317497Cc558612a48443971243`
- Contract name on Blockscout: `SinjohFlapAdapter`
- Verified: yes
- Proxy type: `none`
- Creator: `0x77748D07CAD323A7f6EFa54968aCF69de743be61`
- Creation tx: `0x89e4b482f1e8666d0727c5bac134f50f1cce0cf08edee4e643963e36381e4c16`
- Compiler: `v0.8.28+commit.7893614a`, optimizer on (20000 runs), EVM `cancun`
- License: `apache_2_0`
- Explorer: <https://robinhoodchain.blockscout.com/address/0x4c34af31ef8962317497Cc558612a48443971243>

A third-party launcher that wraps `Portal.newTokenV6`.
It hardcodes the Flap constants it expects (`flapFeeRate` 300, `flapCommissionBps` 60) and exposes `feeRoutingIntact()` so an integrator can check that Flap has not changed them underneath it.
Useful as an independent confirmation of the tax-side protocol rates.

## Constructor arguments

- `portal_` (`address`): `0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09`
- `taxTokenImplementation_` (`address`): `0x7777C8743C88B3aff3cf262135beF2c8b2e83333`
- `flapWrappedNative_` (`address`): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `weth_` (`address`): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `chainId_` (`uint256`): `4663`

## Functions that matter for launching

- `feeRoutingIntact()` returns `(bool)`  [view]
- `flapFeeRate()` returns `(uint16)`  [view]
- `initialize(address,address)`  [nonpayable]
- `initialized()` returns `(bool)`  [view]
- `launch(tuple,bytes32,uint16,uint256)` returns `(address)`  [payable]
- `launched()` returns `(bool)`  [view]
- `taxProcessor()` returns `(address)`  [view]
- `taxTokenImplementation()` returns `(address)`  [view]

## Events

- `Collected(address,address,uint256,address)`
- `DeveloperBuyDelivered(address,address,uint256)`
- `Forwarded(address,address,uint256,address)`
- `Initialized(address,address)`
- `LaunchValueRefunded(address,uint256)`
- `Launched(address,address,uint256,uint256)`

## Files in this directory

- `abi.json`
- `address.json`
- `metadata.json`
- `methods-read.json`
- `sources`/
