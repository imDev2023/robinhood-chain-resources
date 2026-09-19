# PermanentV4PositionCustody - 0x418ece71c4ece08b71db8c53d59b6bc345efc659

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x418ece71c4ece08b71db8c53d59b6bc345efc659
Role: PermanentV4PositionCustody.
Contract name: PermanentV4PositionCustody.
Verified: True (verified at 2026-09-04T17:27:30.175374Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/robinhood/v4/PermanentV4PositionCustody.sol.
Source files written: 33 under `sources/`.
Creator: 0x30e4B6dc3139e28b5C5E493D395a0aca4f1CddBa.
Creation tx: 0x9967fd91ef6f163396583e76b79094285e438450b51d219f53fb72a4cc59f7ec.
Proxy type: None; implementations: [].

## Constructor arguments

- `positionManager_` (address): `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `weth_` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `feeHandler_` (address): `0x685C85DF6836Df5713EFe89Ab1348183651cE9e1`

## Events

- `FeesHarvested(address,uint256,uint256,uint256)`
- `PositionSecured(address,uint256)`

## State-changing functions

- `collect(address,uint256)`
- `register(address,uint256)`

## View functions

- `feeHandler()`
- `onERC721Received(address,address,uint256,bytes)`
- `positionManager()`
- `positionTokens(uint256)`
- `weth()`
