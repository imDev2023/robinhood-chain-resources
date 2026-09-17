# VaultPortalImpl-0xe5789d9d5616dd8ec66de95bb31a29ac1c847769

**VaultPortal implementation, verified**

- Address: `0xe5789d9d5616dd8ec66de95bb31a29ac1c847769`
- Contract name on Blockscout: `VaultPortal`
- Verified: yes
- Proxy type: `none`
- Creator: `0x8187F13ed6C7C9554AfE4Dd4C4D4960174846063`
- Creation tx: `0x8ce1948f451d5215a35c555b82aab70921d4bd08e67ccb8ee03a2dc68b2af669`
- Compiler: `v0.8.26+commit.8a97fa7a`, optimizer on (99999 runs), EVM `cancun`
- License: `none`
- Explorer: <https://robinhoodchain.blockscout.com/address/0xe5789d9d5616dd8ec66de95bb31a29ac1c847769>

Verified sources include `src/interfaces/IPortal.sol`, which is the only published copy of the Portal ABI: `NewTokenV5Params`, `NewTokenV6Params`, `NewTokenV7Params`, `TokenStateV8`, `TokenStateV8Safe`, `QuoteTokenConfiguration`, `CurveType`, `DexThreshType`, `MigratorType`, `TokenVersion` and `TokenStatus`.
Read this file rather than guessing at the unverified Portal.

## Constructor arguments

- `params` (`tuple`): `[['0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09', '0x0000000000000000000000000000000000000000', '0x0000000000000000000000000000000000000000', '0x8888F2eA44469f46798773D42cd6339F273f3333', '0x7777C8743C88B3aff3cf262135beF2c8b2e83333', '30583'], '0x48EbC0Ec3Ff266a458F48Ab674f3373be82d2035', '0x8B4329947e34B6d56D71A3385caC122BaDe7d78D', '0xd2479880507689e29AddcD6ff55003FC82356db6', '0x4f851820C2650Ffe57f507775Aa118fA3d5Dd0B6', '0xC6Ef24B94d86e1E082150591B743f851dC40871D', '150000000000000000', '0x65eA398b9EB6b7A75FD5A1018463039374A0b908']`

## Functions that matter for launching

- `AUDITOR_ROLE()` returns `(bytes32)`  [view]
- `AUDIT_FEE_RECEIVER()` returns `(address)`  [view]
- `DEFAULT_ADMIN_ROLE()` returns `(bytes32)`  [view]
- `NON_TAX_TOKEN_SUFFIX()` returns `(uint256)`  [view]
- `TAX_TOKEN_SUFFIX()` returns `(uint256)`  [view]
- `TOKEN_IMPL_TAXED()` returns `(address)`  [view]
- `TOKEN_IMPL_TAXED_V2()` returns `(address)`  [view]
- `TOKEN_IMPL_TAXED_V3()` returns `(address)`  [view]
- `VAULT_ADMIN_ROLE()` returns `(bytes32)`  [view]
- `VAULT_PORTAL_AUDIT()` returns `(address)`  [view]
- `VAULT_PORTAL_LAUNCH()` returns `(address)`  [view]
- `VAULT_PORTAL_TWEAK()` returns `(address)`  [view]
- `VAULT_PORTAL_UI_REGISTRY()` returns `(address)`  [view]
- `getRoleAdmin(bytes32)` returns `(bytes32)`  [view]
- `getSaltOwner()` returns `(address)`  [view]
- `getVault(address)` returns `(tuple)`  [view]
- `getVaultCategory(address)` returns `(uint8)`  [view]
- `grantRole(bytes32,address)`  [nonpayable]
- `hasRole(bytes32,address)` returns `(bool)`  [view]
- `initialize()`  [nonpayable]
- `newTaxTokenWithVault(tuple)` returns `(address)`  [payable]
- `newTokenV6WithVault(tuple)` returns `(address)`  [payable]
- `newTokenV7WithVault(tuple)` returns `(address)`  [payable]
- `predictTaxTokenV1Address(bytes32)` returns `(address)`  [view]
- `refreshTokenVault(address)`  [nonpayable]
- `registerVaultFactory(address,bool,bool,uint8)`  [nonpayable]
- `registerVaultFactory(address,bool,bool,uint8,uint8)`  [nonpayable]
- `renounceRole(bytes32,address)`  [nonpayable]
- `revokeRole(bytes32,address)`  [nonpayable]
- `setVaultCategory(address,uint8)`  [nonpayable]
- `tryGetVault(address)` returns `(bool,tuple)`  [view]
- `vaultFactories(address)` returns `(bool,bool,uint8,bytes29)`  [view]
- `version()` returns `(string)`  [pure]

## Events

- `AdapterRegistered(address,address)`
- `ArtifactBindingChanged(uint8,address,uint8,bool,string,bytes32,address)`
- `AuditOrderPaid(bytes32,string,address,uint256,uint256)`
- `AuditReportSubmitted(address,address,uint8,string)`
- `FactoryAuditReportSubmitted(address,address,uint8,string)`
- `FactoryCategoryUpdated(address,uint8)`
- `FactoryPermissionPolicySet(address,uint8)`
- `FlapTaxVaultFactoryCategorySet(address,uint8)`
- `FlapTaxVaultFactoryRegistered(address,bool,bool,uint8)`
- `FlapTaxVaultTokenCreated(address,address,address)`
- `Initialized(uint8)`
- `RoleAdminChanged(bytes32,bytes32,bytes32)`
- `RoleGranted(bytes32,address,address)`
- `RoleRevoked(bytes32,address,address)`
- `TokenVaultRefreshed(address,address,address)`
- `VaultCategoryUpdated(address,uint8)`

## Files in this directory

- `abi.json`
- `address.json`
- `bytecode.hex`
- `metadata.json`
- `methods-read.json`
- `selectors.txt`
- `sources`/
