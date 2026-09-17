# BondingV5-Impl-initial - 0xFFB470f3a2De124b918Ee412FEDd79CF6ACb6265

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xFFB470f3a2De124b918Ee412FEDd79CF6ACb6265
Role: BondingV5-Impl-initial.
Contract name: BondingV5.
Verified: True (verified at 2026-07-02T07:06:57.155926Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/launchpadv2/BondingV5.sol.
Source files written: 16 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0x2665dff26a4a2c00b9a42f16a71bd291357fec2d6e941556d7303cce376c9434.
Proxy type: None; implementations: [].

First BondingV5 implementation deployed 2026-06-25 by the deployer 0xe4a0...; superseded.

## Constructor arguments

None decoded.

## Events

- `CancelledLaunch(address,address,uint256,uint256)`
- `FeeDelegationUpdated(address,bool)`
- `Graduated(address,address)`
- `Initialized(uint64)`
- `Launched(address,address,uint256,uint256,uint256,tuple)`
- `OwnershipTransferred(address,address)`
- `PreLaunched(address,address,uint256,uint256,tuple)`

## State-changing functions

- `buy(uint256,address,uint256,uint256)`
- `cancelLaunch(address)`
- `initialize(address,address,address,address)`
- `launch(address)`
- `preLaunch(string,string,uint8[],string,string,string[4],uint256,uint256,uint8,uint16,bool,uint8,bool,bytes)`
- `renounceOwnership()`
- `sell(uint256,address,uint256,uint256)`
- `setBondingConfig(address)`
- `setFeeDelegation(address,bool)`
- `transferOwnership(address)`

## View functions

- `VirtualIdBase()`
- `agentFactory()`
- `bondingConfig()`
- `factory()`
- `isAcpSkillLaunch(address)`
- `isFeeDelegation(address)`
- `isProject60days(address)`
- `isProjectXLaunch(address)`
- `owner()`
- `router()`
- `tokenAntiSniperType(address)`
- `tokenFakeInitialVirtualLiq(address)`
- `tokenGradThreshold(address)`
- `tokenInfo(address)`
- `tokenInfos(uint256)`
- `tokenLaunchParams(address)`
- `tokenPreLaunchExtParams(address)`
