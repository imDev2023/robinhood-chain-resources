# LongCommunityFactory - 0x4a477bfb623a84a4a664f779cb0a202f6124b3e7

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x4a477bfb623a84a4a664f779cb0a202f6124b3e7
Role: LongCommunityFactory.
Contract name: LongCommunityFactory.
Verified: True (verified at 2026-07-27T19:45:50.632906Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/community/LongCommunityFactory.sol.
Source files written: 68 under `sources/`.
Creator: 0xA85BC6f5bdB8D089b54Ffce61628bCBfDbE7A817.
Creation tx: 0x654dbb45910dc534704403e086f26fda593fb930cf3272bfc8f3c9dc9b7a0dbf.
Proxy type: None; implementations: [].

Earlier community-mode factory. Created the AI Community Vault TimelockController on 2026-07-27.

## Constructor arguments

- `initializer_` (address): `0x4e3468951D49f2EEa976eD0D6e75fFCb44a9a544`
- `governorDeployer_` (address): `0xE8D46502E686Ce3C6D381362c921d7E47924585A`

## Events

- `CommunityModeDeployed(address,bytes32,address,address,address,address)`

## State-changing functions

- `deployCommunityMode(address)`

## View functions

- `GOVERNOR_DEPLOYER()`
- `INITIALIZER()`
- `MIN_DEPLOY_SHARES()`
- `TIMELOCK_MIN_DELAY()`
- `getDeployment(address)`
- `isActivated(address)`
