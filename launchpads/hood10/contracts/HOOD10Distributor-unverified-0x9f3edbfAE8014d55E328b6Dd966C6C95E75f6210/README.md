# HOOD10Distributor-unverified - 0x9f3edbfAE8014d55E328b6Dd966C6C95E75f6210

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x9f3edbfAE8014d55E328b6Dd966C6C95E75f6210
Role: HOOD10Distributor-unverified.
Contract name: unknown (unverified).
Verified: None (verified at None).
Compiler: None, EVM None, optimizer None runs None.
Main file: None.
Sources: none (unverified); `bytecode.hex` holds the deployed bytecode.
Creator: 0xb3e36d3a6Bbc264cc5DD54F75B4B6ac495F6679d.
Creation tx: 0x01383b0b81d73cef3d850a5b17e3dcb11e7f6f7deb2a5c6a70620283ea01c49f.
Proxy type: None; implementations: [].
External libraries: none.

## Identified by selector matching

Unverified on Blockscout.
Deployed 2026-08-24 by the EOA 0xb3e36d3a6Bbc264cc5DD54F75B4B6ac495F6679d.
Selectors were extracted from the deployed bytecode and resolved against openchain.xyz (`_raw/blockscout/selectors-distributor.txt` and `selectors-distributor-resolved.json`).

It is the `SimpleRewardTreasury` family that `LaunchDividendTreasury` says it was adapted from, in that contract's own natspec:
"the deployment at 0x9f3edbfAE8014d55E328b6Dd966C6C95E75f6210 has settled twenty-two periods".

Resolved surface: `commitRoot(uint256,bytes32,uint256)`, `openClaims`, `claim(uint256,address,uint256,bytes32[])`, `previewClaim`, `closePeriod`, `settleExpired`, `getPeriod`, `getPeriodRewards`, `getBasket`, `currentPeriodId`, `reserved`, `sweep(address,address,uint256)`, `feeToken`, `protocolFeeRecipient`, `CLAIM_WINDOW`, `MAX_BASKET_ASSETS`, `TOTAL_FEE_BPS`, `BPS`, Ownable2Step.

Live state at capture (`_raw/rpc/distributor-state.txt`): `owner` and `protocolFeeRecipient` are both the keeper EOA 0xEE5cC579a0A6D90bFF4c481387b39BA655caC728, `currentPeriodId` 34, `feeToken` WETH, `CLAIM_WINDOW` 15552000 seconds (180 days), `MAX_BASKET_ASSETS` 10, `TOTAL_FEE_BPS` 4700, and `getBasket()` returns ten assets at 1000 bps each.

**It is a Merkle-claim contract, not a push airdrop.**
Every one of its recent transactions is `claim(...)` sent by the keeper on a holder's behalf, which is how the docs' "nothing to claim" is delivered.
The site serves the proofs itself at `/api/dividendProof`.

## Constructor arguments

None decoded.

## Events

None.

## State-changing functions

None.

## View functions

None.
