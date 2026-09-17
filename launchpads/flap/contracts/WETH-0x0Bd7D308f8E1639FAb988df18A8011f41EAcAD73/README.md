# WETH-0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73

**Wrapped ETH on Robinhood Chain (proxy)**

- Address: `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- Contract name on Blockscout: `TransparentUpgradeableProxy`
- Verified: yes
- Proxy type: `eip1967`, implementation `0xC6B81b429797E0f555440b70cD99e032D7AE947e`
- Creator: `0xE83b11Faa5693E68388785FecA3595C6805dFb9a`
- Creation tx: `0x05317cd173ba8e973c7e88aeb7f7e56eb22cf05c12552d4283c993dbb1f56b12`
- Compiler: `v0.8.16+commit.07a7930e`, optimizer on (100 runs), EVM `london`
- License: `none`
- Explorer: <https://robinhoodchain.blockscout.com/address/0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73>

Chain infrastructure, `aeWETH` behind its own proxy admin.
The TaxProcessor holds quote balances in it (`isWeth = true`).

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
