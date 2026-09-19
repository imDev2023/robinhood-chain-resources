# RaiseHood

Archived 2026-09-19.
Site `raisehood.xyz`, X `@RaiseHood`, DefiLlama slug `raisehood`, category Launchpad.

One of only two pads in the survey recorded as pairing against USDG or tokenized stocks rather than ETH, which is why it was a priority target.

## What is archived

| Role | Address | Verified |
| --- | --- | --- |
| Factory | `0xde540a7d140e27e50305fae78e736fe00f4a917f` | **no** |

The factory is **unverified**, so there are no sources.
Its function surface was recovered by a PUSH4 scan of the 20,575-byte runtime per `PLAYBOOK.md` section 4: 132 candidates, 67 resolved, written to `_raw/rpc/`.

## What the selectors show

A presale model with vesting, and the widest admin surface of anything archived in this pass.

**Presale and vesting:** `allSales`, `allSalesLength`, `salesByCreator`, `saleImplementation`, `start`, `cliff`, `duration`, `released`, `releasable`, `vested`, `tgeBps`, `beneficiary`, `total`.
That confirms the catalog's "fixed-price presales" description and adds on-chain vesting, which only Virtuals otherwise offers.

**Launch guard:** `initGuard`, `guarded`, `guardBlocks`, `guardInitialized`, `maxWalletDuringGuard`, `tradingOpen`, `openTrading`, `forceOpenTrading`.
Anti-snipe is a hard per-wallet cap over a block window, like Flap's, not a decaying fee.

**Owner surface:** `setCreationFee`, `setPlatformFee`, `setReferralFee`, `setFeeReceiver`, `setBeneficiary`, `setLpLocker`, `setCreatorApproval`, `setAdapterApproval`, `setExempt`, `setPaused`, `transferOwnership`, `acceptOwnership`, `renounceLaunchAdmin`, `launchAdmin`.

Three of those matter more than the rest.

- **`setLpLocker(address)`** means the locker itself is swappable. Every other pad in the survey fixes the locker at deploy or in the launch struct. This is the weakest lock posture recorded anywhere in the 22.
- **`setCreatorApproval(address,bool)` and `approvedCreator(address)`** mean launching is **permissioned**. RaiseHood is the only pad in the survey that gates who may create.
- **`forceOpenTrading()`** lets the admin open trading out of schedule.

Whether `setPlatformFee` is read at collection time or snapshotted per sale is the question that decides whether RaiseHood has Noxa's retroactive-knob problem.
The selector list cannot answer it; the bytecode or a traced collection can.

## Gaps

The contract is unverified, so every mechanism above is inferred from selector names rather than read from source.
No fee levels, no creator share, no launch counts, no docs capture.
