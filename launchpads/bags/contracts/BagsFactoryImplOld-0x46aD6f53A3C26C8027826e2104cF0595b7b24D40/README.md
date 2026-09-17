# BagsFactoryImplOld - 0x46aD6f53A3C26C8027826e2104cF0595b7b24D40

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x46aD6f53A3C26C8027826e2104cF0595b7b24D40
Role: BagsFactoryImplOld.
Contract name: BagsFactory.
Verified: True (verified at 2026-07-10T15:36:10.203953Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/BagsFactory.sol.
Source files written: 86 under `sources/`.
Creator: 0xC6c66AeEbe18e3d1027a4b0b38cE0071616D6464.
Creation tx: 0x5c291dcc915485e505aa0491a046f902f78fb9d6f3e6890b99f1965c2f3aa096.
Proxy type: None; implementations: [].

Earlier BagsFactory implementation deployed by 0xC6c66AeEbe18e3d1027a4b0b38cE0071616D6464 before the production deploy. Not referenced by the live proxy.

## Constructor arguments

- `poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `positionManager` (address): `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `weth` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `vault` (address): `0x26e421917aeA64B615A3127A2BA3AC3051C3ab80`
- `permit2` (address): `0x000000000022D473030F116dDEE9F6B43aC78BA3`
- `hook` (address): `0x208378dDc05eD5De1833624a30EB9C1d26f86EcC`
- `tokenImpl` (address): `0xF3647a59a90A0d4E22309404dDE4E66f5c4Af8E0`
- `feeShareImpl` (address): `0x1eddf882308C5B9D863267a81E4e61e8C5414eD7`
- `bondingCurveImpl` (address): `0xA84725B1Be87642b487E000a10B50ec0b804779E`
- `graduationThreshold_` (uint256): `5000000000000000000`

## Events

- `CreationFeeUpdated(uint256)`
- `GraduationThresholdUpdated(uint256,uint256)`
- `OwnershipTransferred(address,address)`
- `Rescued(address,address,uint256)`
- `TokenCreated(address,address,address,address,bytes32,string,string,string)`

## State-changing functions

- `create(string,string,string,address,uint16,address[],uint16[])`
- `createAndBuy(string,string,string,address,uint16,address[],uint16[])`
- `renounceOwnership()`
- `rescue(address,uint256)`
- `setCreationFee(uint256)`
- `setGraduationThreshold(uint256)`
- `transferOwnership(address)`

## View functions

- `BONDING_CURVE_IMPL()`
- `FEE_SHARE_IMPL()`
- `HOOK()`
- `PERMIT2()`
- `POOL_MANAGER()`
- `POSITION_MANAGER()`
- `TOKEN_IMPL()`
- `VAULT()`
- `WETH()`
- `allTokens(uint256)`
- `allTokensLength()`
- `creationFee()`
- `curveForToken(address)`
- `feeShareForToken(address)`
- `getTokens(uint256,uint256)`
- `graduationThreshold()`
- `owner()`
- `tokenForPoolId(bytes32)`
