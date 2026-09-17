# CashCatFactory-proxy - 0x5bd1Fbe78a78fe8236fa00CF48fbEBA74ae34661

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x5bd1Fbe78a78fe8236fa00CF48fbEBA74ae34661
Role: CashCatFactory-proxy.
Contract name: ERC1967Proxy.
Verified: True (verified at 2026-07-10T13:24:57.599966Z).
Compiler: v0.8.28+commit.7893614a, EVM cancun, optimizer True runs 1000.
Main file: lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol.
Sources: none (unverified); `bytecode.hex` holds the deployed bytecode.
Creator: 0x0679f72DCC42d8fBEB19FC2e0215Be8e7C090881.
Creation tx: 0x2b90e5b780a0953828f000af8215bf583e98ef988f8827623f3a6acb9a8f9a5c.
Proxy type: eip1967; implementations: ['0x40250b4C73FC30f8F6ad077744B0124B3f111C28'].
External libraries: none.

## Context, not part of the HOOD10 Launchpad

This is letscash.fun's factory, an ERC-1967 proxy.
It is in this archive because it created the HOOD10 index token as an EIP-1167 clone.
Live state at capture (`_raw/rpc/cashcat-state.txt`): `owner` 0xd2DEfBd13aFF22d6989e8C14b4517eC308079e91, `treasury` 0x67cCBFb238047d62736265B3093a5989836794b0, `launchFee()` 500000000000000 wei (0.0005 ETH), `launchEnabled()` true, `nextConfigId()` 1064, `poolManager` the same Uniswap v4 PoolManager the HOOD10 pad uses.
EIP-1967 implementation slot reads 0x40250b4C73FC30f8F6ad077744B0124B3f111C28.

## Constructor arguments

- `implementation` (address): `0xB82D926821A092e8b18eF7A72aE86fD043fe7eE7`
- `_data` (bytes): `0xcf756fdf0000000000000000000000000679f72dcc42d8fbeb19fc2e0215be8e7c09088100000000000000000000000051ea3c46623feeed7994dd692083293c7088bf1d0000000000000000000000008366a39cc670b4001a1121b8f6a443a643e409510000000000000000000000000000000000000000000000000001c6bf52634000`

## Events

- `Upgraded(address)`

## State-changing functions

None.

## View functions

None.
