# UniversalRouter - 0x8876789976dEcBfCbBbe364623C63652db8C0904

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x8876789976dEcBfCbBbe364623C63652db8C0904
Role: UniversalRouter.
Contract name: UniversalRouter.
Verified: True (verified at 2026-05-26T22:27:38.385068Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 4444.
Main file: src/pkgs/universal-router/contracts/UniversalRouter.sol.
Source files written: 110 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x422569c99e80a452d45680fbf16cf04cd4ae79cd2b0d7a6a89cf6603009ed1fa.
Proxy type: None; implementations: [].

Robinhood-modified Uniswap UniversalRouter used for post-graduation swaps.

## Constructor arguments

- `params` (tuple): `['0x000000000022D473030F116dDEE9F6B43aC78BA3', '0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73', '0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f', '0x1f7d7550B1b028f7571E69A784071F0205FD2EfA', '0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f', '0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54', '0x8366a39CC670B4001A1121B8F6A443A643e40951', '0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3', '0x58daec3116aae6D93017bAAea7749052E8a04fA7', '0x7332D11BD10d18A04B119Cd4671a96f3148002c4']`

## Events

- `EIP712DomainChanged()`

## State-changing functions

- `execute(bytes,bytes[])`
- `execute(bytes,bytes[],uint256)`
- `executeSigned(bytes,bytes[],bytes32,bytes32,bool,bytes32,bytes,uint256)`
- `uniswapV3SwapCallback(int256,int256,bytes)`
- `unlockCallback(bytes)`

## View functions

- `SPOKE_POOL()`
- `V3_POSITION_MANAGER()`
- `V4_POSITION_MANAGER()`
- `eip712Domain()`
- `msgSender()`
- `noncesUsed(address,bytes32)`
- `poolManager()`
- `signedRouteContext()`
