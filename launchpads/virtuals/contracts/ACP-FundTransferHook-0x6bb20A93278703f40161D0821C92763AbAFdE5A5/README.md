# ACP-FundTransferHook - 0x6bb20A93278703f40161D0821C92763AbAFdE5A5

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x6bb20A93278703f40161D0821C92763AbAFdE5A5
Role: ACP-FundTransferHook.
Contract name: FundTransferHook.
Verified: True (verified at 2026-07-27T09:02:56.902647Z).
Compiler: v0.8.28+commit.7893614a, EVM cancun, optimizer True runs 200.
Main file: contracts/hooks/FundTransferHook.sol.
Source files written: 33 under `sources/`.
Creator: 0x62Fa606E7825E0601f3c003e6e361779c37C584b.
Creation tx: 0xc60a91a161891981e76a7d7445d1955ee1bfb3fc8254ca728a6596e79646e79d.
Proxy type: None; implementations: [].

ACP payment hook.

## Constructor arguments

- `coreAddress` (address): `0x62891d58E1321D92f338901a433C2699AadaF2c1`

## Events

- `IntentSigned(uint256,address,bool)`
- `NewIntent(uint256,address,uint256)`
- `PayableFundsRefunded(uint256,uint256,address,address,uint256)`
- `PayableTransferExecuted(uint256,uint256,address,address,address,uint256)`

## State-changing functions

- `afterAction(uint256,bytes4,bytes)`
- `beforeAction(uint256,bytes4,bytes)`
- `claimEscrowRefund(uint256)`

## View functions

- `acpContract()`
- `fundRequestIntentId(uint256)`
- `getIntent(uint256)`
- `intentCounter()`
- `intents(uint256)`
- `providerEscrowIntentId(uint256)`
- `requiredSelectors()`
- `supportsInterface(bytes4)`
