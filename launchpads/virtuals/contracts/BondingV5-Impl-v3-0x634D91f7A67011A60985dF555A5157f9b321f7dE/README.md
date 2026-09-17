# BondingV5-Impl-v3 - 0x634D91f7A67011A60985dF555A5157f9b321f7dE

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x634D91f7A67011A60985dF555A5157f9b321f7dE
Role: BondingV5-Impl-v3.
Contract name: BondingV5.
Verified: True (verified at 2026-07-13T14:15:56.638817Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/launchpadv2/BondingV5.sol.
Source files written: 16 under `sources/`.
Creator: 0xc31Cf1168b2f6745650d7B088774041A10D76d55.
Creation tx: 0x0fd125d0835cd9a0e3e440af4b65cebf15a4819cac8613ebf2bec165136bf9f6.
Proxy type: None; implementations: [].

Intermediate BondingV5 implementation deployed by the owner 0xc31C...; superseded.

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
