# DopplerERC20V1 - 0x3be8b97fd0e713b5abe0649fa830223b6b4bc599

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x3be8b97fd0e713b5abe0649fa830223b6b4bc599
Role: DopplerERC20V1.
Verified: True (verified at 2026-07-01T19:42:07.028313Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 0.
Main file: src/tokens/DopplerERC20V1.sol.
Source files written: 7 under `sources/`.
Creator: 0x1B37D3a72082029c44B35B604Ea473617580b69a.
Creation tx: 0xb53eb8261ef8e76f3bb89c08dd5ca742408ec9911ed5cb0a32ac3a92dc59f7c9.
Proxy type: None; implementations: [].

## Constructor arguments

Raw: `None`

## Events

- Approval
- BalanceLimitDisabled
- DelegateChanged
- DelegateVotesChanged
- Initialized
- OwnershipHandoverCanceled
- OwnershipHandoverRequested
- OwnershipTransferred
- TokensReleased
- Transfer
- UpdateTokenURI
- VestingAllocated
- VestingScheduleCreated

## State-changing functions

- `approve(address,uint256)`
- `burn(uint256)`
- `cancelOwnershipHandover()`
- `completeOwnershipHandover(address)`
- `delegate(address)`
- `delegateBySig(address,uint256,uint256,uint8,bytes32,bytes32)`
- `disableBalanceLimit()`
- `initialize(string,string,uint256,address,address,tuple[],address[],uint256[],uint256[],string,uint256,uint48,address,address[])`
- `lockPool(address)`
- `permit(address,address,uint256,uint256,uint8,bytes32,bytes32)`
- `release(uint256,uint256)`
- `release(uint256)`
- `releaseFor(address,uint256)`
- `releaseFor(address,uint256,uint256)`
- `renounceOwnership()`
- `requestOwnershipHandover()`
- `transfer(address,uint256)`
- `transferFrom(address,address,uint256)`
- `transferOwnership(address)`
- `unlockPool()`
- `updateTokenURI(string)`

## View functions

- `CLOCK_MODE()`
- `DOMAIN_SEPARATOR()`
- `allowance(address,address)`
- `balanceLimitEnd()`
- `balanceOf(address)`
- `checkpointAt(address,uint256)`
- `checkpointCount(address)`
- `clock()`
- `computeAvailableVestedAmount(address,uint256)`
- `computeAvailableVestedAmount(address)`
- `controller()`
- `decimals()`
- `delegates(address)`
- `getPastVotes(address,uint256)`
- `getPastVotesTotalSupply(uint256)`
- `getScheduleIdsOf(address)`
- `getVotes(address)`
- `getVotesTotalSupply()`
- `isBalanceLimitActive()`
- `isExcludedFromBalanceLimit(address)`
- `isPoolLocked()`
- `maxBalanceLimit()`
- `name()`
- `nonces(address)`
- `owner()`
- `ownershipHandoverExpiresAt(address)`
- `pool()`
- `symbol()`
- `tokenURI()`
- `totalAllocatedOf(address)`
- `totalSupply()`
- `vestedTotalAmount()`
- `vestingOf(address,uint256)`
- `vestingScheduleCount()`
- `vestingSchedules(uint256)`
- `vestingStart()`
