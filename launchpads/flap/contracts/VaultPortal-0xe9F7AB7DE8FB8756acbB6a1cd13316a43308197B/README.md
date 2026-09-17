# VaultPortal-0xe9F7AB7DE8FB8756acbB6a1cd13316a43308197B

**VaultPortal (proxy), verified**

- Address: `0xe9F7AB7DE8FB8756acbB6a1cd13316a43308197B`
- Contract name on Blockscout: `TransparentUpgradeableProxy`
- Verified: yes
- Proxy type: `eip1967`, implementation `0xe5789d9D5616dd8eC66DE95BB31A29aC1c847769`
- Creator: `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05`
- Creation tx: `0x9b347fe0179ba6e4d61a0633dee6324dc2eee9ab61df312fc47c55e1a758af6c`
- Compiler: `v0.8.26+commit.8a97fa7a`, optimizer on (99999 runs), EVM `cancun`
- License: `none`
- Explorer: <https://robinhoodchain.blockscout.com/address/0xe9F7AB7DE8FB8756acbB6a1cd13316a43308197B>

The second launch entry point.
It creates a tax token and a Vault in one transaction, then forwards into `Portal.newTokenV6`.
Address matches the Robinhood table in the docs and `Portal.VAULT_PORTAL()`.

## Constructor arguments

- `_logic` (`address`): `0x2813CD0b6089f76F3407792f79276E5d4f80935A`
- `admin_` (`address`): `0x21f7f9B33dFD0dBc3a94C0EFA79F1546a1391FF5`
- `_data` (`bytes`): `0x8129fc1c`

## Events

- `AdminChanged(address,address)`
- `BeaconUpgraded(address)`
- `Upgraded(address)`

## Files in this directory

- `abi.json`
- `address.json`
- `bytecode.hex`
- `metadata.json`
- `methods-read.json`
- `selectors.txt`
- `sources`/
