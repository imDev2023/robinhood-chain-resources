# SwapRouterPancakeV3 - 0x4415f2360bfd9b1bf55500cb28fa41df95cb2d2b

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x4415f2360bfd9b1bf55500cb28fa41df95cb2d2b
Role: SwapRouterPancakeV3.
Contract name: SentrySwapRouter.
Verified: True (verified at 2026-07-11T15:28:48.079510Z).
Compiler: v0.8.20+commit.a1b79de6, EVM paris, optimizer True runs 200.
Main file: src/SentrySwapRouter.sol.
Source files written: 8 under `sources/`.
Creator: 0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5.
Creation tx: 0x17f452d24b328bde0d01dbb161d8690a131d944e882e9bba3d7e97c32e22604d.
Proxy type: None; implementations: [].

Sentry router for PancakeSwap V3 venues.

## Constructor arguments

- `swapRouter_` (address): `0x13f4EA83D0bd40E75C8222255bc855a974568Dd4`
- `weth9_` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `treasury_` (address): `0xcaAfCf8E55f3B5e3D5F7957987db232f08d2367c`
- `feeBps_` (uint16): `100`

## Events

- `FeeBpsUpdated(uint16,uint16)`
- `OwnershipTransferred(address,address)`
- `ReferralBpsUpdated(uint16,uint16)`
- `ReferralPaid(address,address,address,bool,uint256)`
- `SwapExecuted(address,address,bool,uint256,uint256,uint256)`
- `TreasuryUpdated(address,address)`

## State-changing functions

- `buyExactEthForTokens(address,uint24,uint256)`
- `buyExactEthForTokens(address,uint24,uint256,address)`
- `renounceOwnership()`
- `rescueEth(uint256)`
- `rescueToken(address,uint256)`
- `sellExactTokensForEth(address,uint24,uint256,uint256)`
- `sellExactTokensForEth(address,uint24,uint256,uint256,address)`
- `setFeeBps(uint16)`
- `setReferralBps(uint16)`
- `setTreasury(address)`
- `transferOwnership(address)`

## View functions

- `MAX_FEE_BPS()`
- `feeBps()`
- `owner()`
- `referralBps()`
- `swapRouter()`
- `treasury()`
- `weth9()`
