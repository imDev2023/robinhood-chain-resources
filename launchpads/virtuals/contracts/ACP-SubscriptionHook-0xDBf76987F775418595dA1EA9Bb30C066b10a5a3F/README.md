# ACP-SubscriptionHook - 0xDBf76987F775418595dA1EA9Bb30C066b10a5a3F

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xDBf76987F775418595dA1EA9Bb30C066b10a5a3F
Role: ACP-SubscriptionHook.
Contract name: SubscriptionHook.
Verified: True (verified at 2026-07-13T21:19:35.705381Z).
Compiler: v0.8.28+commit.7893614a, EVM cancun, optimizer True runs 200.
Main file: contracts/hooks/SubscriptionHook.sol.
Source files written: 35 under `sources/`.
Creator: 0xb2d577260C08ee46D88726706871A9C3Cb74FE5d.
Creation tx: 0x0534ba989525dcb0bf0439caa2ec65665e442f1259a21250348280a4aa568f5c.
Proxy type: None; implementations: [].

ACP subscription hook.

## Constructor arguments

- `coreAddress` (address): `0x62891d58E1321D92f338901a433C2699AadaF2c1`
- `subscriptionState_` (address): `0x58c1B1287C4feA23Aec6CBbFa0EF32850525D777`

## Events

- `SubscriptionActivated(uint256,uint256,address,address,uint256)`
- `SubscriptionTermsProposed(uint256,uint256,uint256)`
- `SubscriptionTermsSkipped(uint256,uint256,uint256)`

## State-changing functions

- `afterAction(uint256,bytes4,bytes)`
- `beforeAction(uint256,bytes4,bytes)`

## View functions

- `acpContract()`
- `getProposedTerms(uint256)`
- `getSubscriptionExpiry(address,address,uint256)`
- `proposedTerms(uint256)`
- `requiredSelectors()`
- `subscriptionState()`
- `supportsInterface(bytes4)`
