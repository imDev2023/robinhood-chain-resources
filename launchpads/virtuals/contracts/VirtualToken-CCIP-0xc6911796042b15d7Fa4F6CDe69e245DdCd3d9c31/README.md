# VirtualToken-CCIP - 0xc6911796042b15d7Fa4F6CDe69e245DdCd3d9c31

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xc6911796042b15d7Fa4F6CDe69e245DdCd3d9c31
Role: VirtualToken-CCIP.
Contract name: CrossChainToken.
Verified: True (verified at 2026-07-01T23:08:08.537667Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 80000.
Main file: contracts/tokens/CrossChainToken.sol.
Source files written: 20 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0xc43a8dba6d79883350356858cf8c2434d5c4d19142f10fd127e65ebc124ad40a.
Proxy type: None; implementations: [].

VIRTUAL on Robinhood Chain is a Chainlink CCIP burn-and-mint CrossChainToken, minted only by the CCIP token pool. It is the quote asset of every Virtuals bonding curve and every graduated Uniswap V2 pool on this chain.

## Constructor arguments

- `args` (tuple): `['Virtuals Protocol', 'VIRTUAL', '0', '0', '0x0000000000000000000000000000000000000000', '18', '0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F']`
- `burnMintRoleAdmin` (address): `0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F`
- `owner` (address): `0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F`

## Events

- `Approval(address,address,uint256)`
- `CCIPAdminTransferred(address,address)`
- `DefaultAdminDelayChangeCanceled()`
- `DefaultAdminDelayChangeScheduled(uint48,uint48)`
- `DefaultAdminTransferCanceled()`
- `DefaultAdminTransferScheduled(address,uint48)`
- `RoleAdminChanged(bytes32,bytes32,bytes32)`
- `RoleGranted(bytes32,address,address)`
- `RoleRevoked(bytes32,address,address)`
- `Transfer(address,address,uint256)`

## State-changing functions

- `acceptDefaultAdminTransfer()`
- `approve(address,uint256)`
- `beginDefaultAdminTransfer(address)`
- `burn(address,uint256)`
- `burn(uint256)`
- `burnFrom(address,uint256)`
- `cancelDefaultAdminTransfer()`
- `changeDefaultAdminDelay(uint48)`
- `grantMintAndBurnRoles(address)`
- `grantRole(bytes32,address)`
- `mint(address,uint256)`
- `renounceRole(bytes32,address)`
- `revokeRole(bytes32,address)`
- `rollbackDefaultAdminDelay()`
- `setCCIPAdmin(address)`
- `transfer(address,uint256)`
- `transferFrom(address,address,uint256)`

## View functions

- `BURNER_ROLE()`
- `BURN_MINT_ADMIN_ROLE()`
- `DEFAULT_ADMIN_ROLE()`
- `MINTER_ROLE()`
- `allowance(address,address)`
- `balanceOf(address)`
- `decimals()`
- `defaultAdmin()`
- `defaultAdminDelay()`
- `defaultAdminDelayIncreaseWait()`
- `getCCIPAdmin()`
- `getRoleAdmin(bytes32)`
- `hasRole(bytes32,address)`
- `maxSupply()`
- `name()`
- `owner()`
- `pendingDefaultAdmin()`
- `pendingDefaultAdminDelay()`
- `supportsInterface(bytes4)`
- `symbol()`
- `totalSupply()`
- `typeAndVersion()`
