# BondingV5-Impl-current - 0x66Fc520c7F316B8623eee2A5dA821c3b34D0539D

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x66Fc520c7F316B8623eee2A5dA821c3b34D0539D
Role: BondingV5-Impl-current.
Contract name: BondingV5.
Verified: True (verified at 2026-08-11T08:08:09.078264Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/launchpadv2/BondingV5.sol.
Source files written: 16 under `sources/`.
Creator: 0xc31Cf1168b2f6745650d7B088774041A10D76d55.
Creation tx: 0x32583f91dc9f12efa70b3ae53bceac433753f226477651325a410d1837c937bb.
Proxy type: None; implementations: [].

Current implementation behind the BondingV5 proxy (fourth implementation, deployed by the owner 0xc31C...).

## Constructor arguments

None decoded.

## Events

- `CancelledLaunch(address,address,uint256,uint256)`
- `FeeDelegationUpdated(address,bool)`
- `Graduated(address,address)`
- `Initialized(uint64)`
- `Launched(address,address,uint256,uint256,uint256,tuple)`
- `OwnershipTransferred(address,address)`
- `PreLaunchExtParams(address,bool,bool,uint8,bytes32)`
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
- `feeDelegationRecipient(address)`
- `feeDelegationType(address)`
- `isAcpSkillLaunch(address)`
- `isFeeDelegation(address)`
- `isProject60days(address)`
- `isProjectXLaunch(address)`
- `isRobotics(address)`
- `owner()`
- `router()`
- `tokenAntiSniperType(address)`
- `tokenFakeInitialVirtualLiq(address)`
- `tokenGradThreshold(address)`
- `tokenInfo(address)`
- `tokenInfos(uint256)`
- `tokenLaunchParams(address)`
- `tokenPreLaunchExtParams(address)`
