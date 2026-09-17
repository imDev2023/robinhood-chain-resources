# FlapCore-0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09

**Portal, the protocol entry point (proxy)**

- Address: `0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09`
- Contract name on Blockscout: `TransparentUpgradeableProxy`
- Verified: yes
- Proxy type: `eip1967`, implementation `0xa3b96Df56f254B926B17D5f7FB6CD858c216ff44`
- Creator: `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05`
- Creation tx: `0x66ab432afa53aca015e57d94b4c0057d02e5a02600343dff6e66e6ea1281cdbc`
- Compiler: `v0.8.26+commit.8a97fa7a`, optimizer on (99999 runs), EVM `cancun`
- License: `none`
- Explorer: <https://robinhoodchain.blockscout.com/address/0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09>

This is the contract the Flap docs and the app both call `Portal`.
The archive directory is named `FlapCore` from an earlier guess; the address is the one the Robinhood integration guide lists as `Portal (proxy)` and the one `robinhood-chain-config.js` sets as `portal`.

Everything a creator or a trader does goes through here: `newTokenV5` (non-tax launch), `newTokenV6` (tax launch), `swapExactInput` (buy and sell on the curve), `claim` (revenue share), `getTokenV8Safe` (token state), `getQuoteTokenConfiguration` (which quote assets are enabled).
It is a `TransparentUpgradeableProxy` over `PortalImpl-0xa3b96df56f254b926b17d5f7fb6cd858c216ff44`, which is **not verified**; the callable surface is recovered from a PUSH4 selector scan in that directory.

Live reads on 2026-09-02 (`_raw/rpc/portal-config.txt`):

| call | value |
| --- | --- |
| `version()` | `v5.21.2` |
| `getFeeRate()` | `(100, 100)`, that is 1% buy and 1% sell on the bonding curve |
| `SALT_LOCK_FEE()` | `3000000000000000` wei, 0.003 ETH |
| `flapCurvePairFactory()` | `0x0d1eBb179cdbcA88D74C923C4255Cb2B17474AfD` |
| `VAULT_PORTAL()` | `0xe9F7AB7DE8FB8756acbB6a1cd13316a43308197B` |
| `nonce()` | `295537` |
| `hasRole(DEFAULT_ADMIN_ROLE, FeeSafe)` | `true` |

## Constructor arguments

- `_logic` (`address`): `0xc1F4dE40D3818E1c840Dc754A423edA3b56bD47C`
- `admin_` (`address`): `0x21f7f9B33dFD0dBc3a94C0EFA79F1546a1391FF5`
- `_data` (`bytes`): `0xc4d66de80000000000000000000000003bfc05a8b9e48fdfd6a443657cac5d983b664a05`

## Events

- `AdminChanged(address,address)`
- `BeaconUpgraded(address)`
- `Upgraded(address)`

## Files in this directory

- `abi.json`
- `address.json`
- `metadata.json`
- `methods-read.json`
- `sources`/
