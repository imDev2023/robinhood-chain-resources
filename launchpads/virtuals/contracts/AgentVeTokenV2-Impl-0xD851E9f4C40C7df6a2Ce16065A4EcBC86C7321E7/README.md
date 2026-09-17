# AgentVeTokenV2-Impl - 0xD851E9f4C40C7df6a2Ce16065A4EcBC86C7321E7

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xD851E9f4C40C7df6a2Ce16065A4EcBC86C7321E7
Role: AgentVeTokenV2-Impl.
Contract name: AgentVeTokenV2.
Verified: True (verified at 2026-07-02T06:56:53.140569Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/virtualPersona/AgentVeTokenV2.sol.
Source files written: 44 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0x3d41035e2a30166ee212bf31d163aa0b0d30ad73072115fe2501a27c37ccbce9.
Proxy type: None; implementations: [].

Implementation cloned for every graduated token's staked-LP token (sTOKEN). Holds the LP with a 10-year maturity.

## Constructor arguments

None decoded.

## Events

- `Approval(address,address,uint256)`
- `DelegateChanged(address,address,address)`
- `DelegateVotesChanged(address,uint256,uint256)`
- `EIP712DomainChanged()`
- `Initialized(uint64)`
- `LiquidityRemoved(address,uint256,uint256,uint256,address)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `Transfer(address,address,uint256)`

## State-changing functions

- `acceptOwnership()`
- `approve(address,uint256)`
- `delegate(address)`
- `delegateBySig(address,uint256,uint256,uint8,bytes32,bytes32)`
- `initialize(string,string,address,address,uint256,address,bool)`
- `removeLpLiquidity(address,uint256,address,uint256,uint256,uint256)`
- `renounceOwnership()`
- `setCanStake(bool)`
- `setMatureAt(uint256)`
- `stake(uint256,address,address)`
- `transfer(address,uint256)`
- `transferFrom(address,address,uint256)`
- `transferOwnership(address)`
- `withdraw(uint256)`

## View functions

- `CLOCK_MODE()`
- `agentNft()`
- `allowance(address,address)`
- `assetToken()`
- `balanceOf(address)`
- `canStake()`
- `checkpoints(address,uint32)`
- `clock()`
- `decimals()`
- `delegates(address)`
- `eip712Domain()`
- `founder()`
- `getPastBalanceOf(address,uint256)`
- `getPastDelegates(address,uint256)`
- `getPastTotalSupply(uint256)`
- `getPastVotes(address,uint256)`
- `getVotes(address)`
- `initialLock()`
- `matureAt()`
- `name()`
- `nonces(address)`
- `numCheckpoints(address)`
- `owner()`
- `pendingOwner()`
- `symbol()`
- `totalSupply()`
