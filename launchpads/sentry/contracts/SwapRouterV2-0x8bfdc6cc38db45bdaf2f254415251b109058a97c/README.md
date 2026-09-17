# SwapRouterV2 - 0x8bfdc6cc38db45bdaf2f254415251b109058a97c

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x8bfdc6cc38db45bdaf2f254415251b109058a97c
Role: SwapRouterV2.
Contract name: SentrySwapRouterV2.
Verified: True (verified at 2026-07-11T15:23:49.930428Z).
Compiler: v0.8.20+commit.a1b79de6, EVM paris, optimizer True runs 200.
Main file: src/SentrySwapRouterV2.sol.
Source files written: 8 under `sources/`.
Creator: 0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5.
Creation tx: 0xf76637fe2c8623e5edd0665eab66ebbe4ff974aa127883fe06eb47490c4641a3.
Proxy type: None; implementations: [].

Sentry aggregating swap router over Uniswap V2 and V3 venues.

## Constructor arguments

- `swapRouter_` (address): `0xCaf681a66D020601342297493863E78C959E5cb2`
- `v2Factory_` (address): `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f`
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
- `buyExactEthForTokensV2(address,uint256)`
- `buyExactEthForTokensV2(address,uint256,address)`
- `renounceOwnership()`
- `rescueEth(uint256)`
- `rescueToken(address,uint256)`
- `sellExactTokensForEth(address,uint24,uint256,uint256)`
- `sellExactTokensForEth(address,uint24,uint256,uint256,address)`
- `sellExactTokensForEthV2(address,uint256,uint256)`
- `sellExactTokensForEthV2(address,uint256,uint256,address)`
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
- `v2Factory()`
- `weth9()`
