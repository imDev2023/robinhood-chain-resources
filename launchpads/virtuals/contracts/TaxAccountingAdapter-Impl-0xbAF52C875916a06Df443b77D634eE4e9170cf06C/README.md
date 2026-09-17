# TaxAccountingAdapter-Impl - 0xbAF52C875916a06Df443b77D634eE4e9170cf06C

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xbAF52C875916a06Df443b77D634eE4e9170cf06C
Role: TaxAccountingAdapter-Impl.
Contract name: TaxAccountingAdapter.
Verified: True (verified at 2026-07-02T07:07:04.216798Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/tax/TaxAccountingAdapter.sol.
Source files written: 11 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0xd12a4dfa20e3c8afccd10c4c99e3e32b46d9fe7ad2a3b06126281802ef0bc99e.
Proxy type: None; implementations: [].

TaxAccountingAdapter implementation.

## Constructor arguments

None decoded.

## Events

- `Initialized(uint64)`
- `OwnershipTransferred(address,address)`
- `TaxRecipientUpdated(address,address)`
- `TaxSwapDeposited(address,address,uint256)`

## State-changing functions

- `emergencyWithdrawERC20(address,address,uint256)`
- `emergencyWithdrawNative(address,uint256)`
- `initialize(address,address)`
- `renounceOwnership()`
- `setTaxRecipient(address)`
- `swapTaxAndDeposit(address,address,address,uint256,uint256)`
- `transferOwnership(address)`

## View functions

- `owner()`
- `taxRecipient()`
