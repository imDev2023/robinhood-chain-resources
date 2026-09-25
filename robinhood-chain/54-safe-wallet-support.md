# Safe on Robinhood Chain: the contracts and Safe{Wallet}, checked

> Original writing, checked 2026-09-25 for the token-launchpad project, read-only on mainnet and with one testnet transaction.
> Which Safe contracts are on 4663 and 46630, how to tell a real Safe from a contract that answers like one, and whether Safe's hosted interface serves the chain.
> Complements `19-account-abstraction.md` (the 4337 module addresses) and `31-onchain-verification.md` (the Lighter upgrade Safe).

## 1. Safe{Wallet} serves both chains

Safe's client gateway lists Robinhood Chain and its testnet, so `https://app.safe.global` opens a Safe on either.
Read from `https://safe-client.safe.global/v1/chains` on 2026-09-25.
The endpoint answers HTTP 403 from CloudFront to a bare `curl`; a browser `User-Agent` header clears it.

| | Mainnet 4663 | Testnet 46630 |
| --- | --- | --- |
| `chainName` | Robinhood Chain | Robinhood Testnet |
| `shortName`, used in the app's URLs | `robinhood` | `robinhood-testnet` |
| Transaction service | `https://api.safe.global/tx-service/robinhood` | `https://api.safe.global/tx-service/robinhood-testnet` |
| App RPC | `https://rpc.safe.global/4663/` | `https://rpc.safe.global/46630/` |
| Explorer template | `robinhoodchain.blockscout.com` | `explorer.testnet.chain.robinhood.com` |
| `recommendedMasterCopyVersion` | 1.5.0 | 1.5.0 |
| Features | BRIDGE, EIP1559, MULTI_CHAIN_SAFE_ADD_NETWORK, MULTI_CHAIN_SAFE_CREATION, NATIVE_SWAPS, NATIVE_SWAPS_FEE_ENABLED, PORTFOLIO_ENDPOINT, POSITIONS, TX_SIMULATION | none |

URLs that work, each opened in a headless browser on 2026-09-25:

- A Safe's dashboard: `https://app.safe.global/home?safe=<shortName>:<address>`.
- Its transaction builder: `https://app.safe.global/apps/open?safe=<shortName>:<address>&appUrl=https%3A%2F%2Fapps-portal.safe.global%2Ftx-builder`.
- Create a Safe: `https://app.safe.global/new-safe/create?chain=<shortName>`.

The transaction service indexes existing Safes on both chains.
`GET /api/v1/safes/<checksummed address>/` answered for the launchpad's testnet admin Safe (`0x551951B25e999214E87Be78dbA91c4F6366078CC`, nonce 6, 2 of 3, `version` `1.4.1+L2`) and for Lighter's upgrade Safe on mainnet (`0x8Caf9FF9392F39E87cBC65A130c026caaCD321ef`, nonce 21, 3 of 5, `1.4.1+L2`).
The service rejects a lower-case address with "Checksum address validation failed", so checksum before asking.
`GET /api/v1/owners/<address>/safes/` lists a signer's Safes; on mainnet it found the Lighter Safe from its first owner.

The testnet entry disables every wallet type in its `disabledWallets` list, MetaMask included, and turns on no features; the mainnet entry disables Coinbase, Ledger v2, Trezor, Trust and WalletConnect among others.
What that means for connecting a signer was not tested.

## 2. The Safe 1.4.1 stack is the canonical one on both chains

Read with `eth_getCode` through each chain's official RPC on 2026-09-25, mainnet at about block 72,595,279 and testnet at about block 124,307,546, and hashed with keccak-256.
Every address below has code, and the hash is the same on the two chains.

| Contract | Address | Code hash |
| --- | --- | --- |
| SafeProxyFactory 1.4.1 | `0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67` | `0x50c3cdc4074750a7a974204a716c999edd37482f907608d960b2b025ee0b3317` |
| SafeL2 1.4.1 (singleton) | `0x29fcB43b46531BcA003ddC8FCB67FFE91900C762` | `0xb1f926978a0f44a2c0ec8fe822418ae969bd8c3f18d61e5103100339894f81ff` |
| Safe 1.4.1 (singleton) | `0x41675C099F32341bf84BFc5382aF534df5C7461a` | `0x1fe2df852ba3299d6534ef416eefa406e56ced995bca886ab7a553e6d0c5e1c4` |
| CompatibilityFallbackHandler 1.4.1 | `0xfd0732Dc9E303f09fCEf3a7388Ad10A83459Ec99` | `0x7c6007a5d711cea8dfd5d91f5940ec29c7f200fe511eb1fc1397b367af3c42f9` |
| SafeToL2Setup 1.4.1 | `0x9641d764fc13c8B624c04430C7356C1C7C8102e2` | `0xecd5bd14a08c5d2122379900b2f272bdf107a7e92423c10dd5fe3254386c9939` |
| MultiSend 1.4.1 | `0x38869bf66a61cF6bDB996A6aE40D5853Fd43B526` | `0x0e4f7fc66550a322d1e7688e181b75e217e662a4f3f4d6a29b22bc61217c4b77` |
| Safe Module Setup v0.3.0 | `0x2dd68b007B46fBe91B9A7c3EDa5A7a1063cB5b47` | `0xaf2d170bb766d2773c3fa88717f5b3599827478074d3767d1dee55e5c2f3fbcb` |
| Safe 4337 Module v0.3.0 | `0x75cf11467937ce3F2f357CE24ffc3DBF8fD5c226` | `0x2aea997c4e3cf0e2f333025372e219abcfde81c21fc2f8fb066414a5685dd3e0` |

`safe-deployments` (npm 1.37.63) marks both chains `canonical` for `safe_l2` 1.4.1, which agrees.

## 3. How to tell a Safe from a contract that answers like one

Any contract can answer `getThreshold()` and `getOwners()`.
A Safe made by the factory is a `SafeProxy` whose runtime code is fixed and whose storage slot 0 holds the singleton, so the test is three reads:

1. `keccak256(eth_getCode(address))` equals **`0xd7d408ebcd99b2b70be43e20253d6d92a8ea8fab29bd3be7f55b10032331fb4c`**, the SafeProxy 1.4.1 runtime code.
   Measured on the two testnet Safes of the launchpad and on Lighter's mainnet Safe, all identical.
2. `eth_getStorageAt(address, 0)`, or the Safe's own `getStorageAt(0, 1)`, names one of the two singletons above.
3. Then read what else can act: `getModulesPaginated(0x1, n)` lists the modules, each of which can call `execTransactionFromModule` with no owner's signature, and the guard sits in slot `keccak256("guard_manager.guard.address")` = `0x4a204f620c8c5ccdca3fd54d003badd85ba500436a431f0cbda4f558c93c34c8`; 1.4.1 has no public getter for it.

Both launchpad Safes on testnet and the Lighter Safe on mainnet name the SafeL2 singleton, have no module and no guard.

A Safe with a module was created on testnet for the launchpad's tests: `0x4e74b51D15fA8bB89a1228A912B0522B732720aC`, 1 of 1, with the 4337 module enabled at setup through Safe Module Setup (`setup(..., to = 0x2dd68b…, data = enableModules([0x75cf11…]), ...)`), transaction `0xa0d075d0f5b25171ab6b707a381b8760c2bd9c94247d568d551b75d3f629fb44`, 304,576 gas.
`createProxyWithNonce` on the factory can be dry-run with `eth_call` to learn the address before sending.
