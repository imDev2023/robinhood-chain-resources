# Doppler

Archive captured 2026-09-02.
Scope: Doppler as a place to launch a token on Robinhood Chain (chain id 4663).
Doppler is deployed on six chains; everything below is about 4663 unless it says otherwise.

---

## 1. Identity

| field | value |
| --- | --- |
| Name | Doppler, also written Doppler Protocol |
| Legal entity | Local Group, Inc, trading as Doppler and as Whetstone Research, incorporated in the United States (`pages/59-app-privacy.md`, `pages/60-app-terms.md`) |
| App | <https://app.doppler.lol/> |
| Marketing site | <https://doppler.lol/> |
| Docs | <https://docs.doppler.lol/> |
| Company site | <https://whetstone.cc/> |
| X | <https://x.com/dopplerprotocol> |
| Telegram | <https://t.me/pure_markets>, reached from <https://doppler.lol/telegram> |
| Core contracts | <https://github.com/whetstoneresearch/doppler> |
| TypeScript SDK | <https://github.com/whetstoneresearch/doppler-sdk>, npm `@whetstone-research/doppler-sdk` |
| Indexer, dev | <https://test.indexer.doppler.lol/> (Base Sepolia only) |
| Indexer, production | <https://indexer-prod.doppler.lol/> (all chains, undocumented, publicly readable) |
| Security contact | security@whetstone.cc |
| Bug bounty | <https://cantina.xyz/bounties/2c7af549-c36c-4432-bae6-3f4b1fa6b217> |
| Chains, per the docs contract table (`pages/25`) | Ethereum Mainnet (1), Monad Mainnet (143), **Robinhood Mainnet (4663)**, Base (8453), Arbitrum One (42161), Base Sepolia (84532) |
| Chains, per the app's own chain filter (`pages/51`) | Base, Robinhood, Monad, Unichain, Ink, Solana |
| Chains you can launch on from the app (`pages/53`) | Base, Robinhood, Monad, Solana |
| Chains in the SDK (`_raw/github/doppler-sdk/src/evm/addresses.ts`) | 1, 143, 4663, 8453, 42161, 84532, 130 Unichain, 1301 Unichain Sepolia, 57073 Ink, 10143 Monad Testnet, plus Solana |
| Capture date | 2026-09-02 |

Named team handles found: `@dopplerprotocol` (the protocol), `@aadams` (`x-status-aadams-1889362777791168877.json`, the launch thread), `@cooper_kunz` (`socials/04-third-party-robinhood-coverage.md`).
No team page or named roster exists on whetstone.cc or in the docs (`pages/64-whetstone-cc.md`).

Governance of the deployment on 4663 sits with a Gnosis Safe, `0x21e2ce70511e4fe542a97708e89520471daa7a66`, a 3-of-6.
It is the Airlock's `owner()` and therefore controls the module whitelist and receives the protocol fee share.
Signers are listed in `contracts/ADDRESSES.md`.

## 2. What it is

Doppler is not a launchpad.
It is the contract set that other launchpads are built out of, plus a first-party app that is one such launchpad among many.

The unit of the protocol is the **Airlock**.
`Airlock.create()` takes one module of each of four kinds and wires them into a single token launch:

1. a **TokenFactory**, which mints the asset,
2. a **PoolInitializer**, which puts the supply on a bonding curve,
3. a **LiquidityMigrator**, which decides what happens when the curve is exhausted,
4. a **GovernanceFactory**, which decides whether the token gets governance.

Every module must be whitelisted on the Airlock by its owner Safe.
An integrator picks a combination, passes its own address as `integrator`, and gets a share of the fees.
That is the whole business model: Doppler earns a floor share on every launch made through anybody's front end.

On Robinhood Chain this matters more than the first-party app does.
Of the 1,000 most recent Doppler assets on chain 4663 at capture, roughly four in five were created by a single integrator, Long (`0x92d435c96e63c43e12d6d0ab28f6b0b04072f765`), with Bankr (`0xf60633d02690e2a15a54ab919925f3d038df163e`) a distant second and the Doppler Safe itself third.
Cumulatively the order is reversed: Bankr created 88,764 of 109,404 assets (81%) and Long 13,802 (13%), so Long leads the current launch rate, not the total (corrected 2026-09-02 from the Long session, `resources/launchpads/long/_raw/indexer/counts-other-integrators.txt`).
The Doppler app's own feed carries `Long` and `Bankr` badges on almost every Robinhood row (`pages/52-app-home-robinhood.md`).

Who it is for: an application that wants to offer token launches without writing curve, migration and fee-splitting contracts, and a creator who is happy to launch through one of those applications.
For a creator, using `app.doppler.lol` directly is the plainest of the options on this chain: no launch fee, no graduation threshold to clear, no LP to seed.

## 3. How a launch works, step by step

Two paths exist: the app, and the SDK.
They call the same contracts.

### 3.1 Through the app, which is the only path that needs no code

`pages/53` to `pages/55`, walked live on 2026-09-02 with no wallet connected.

**Step 0, pick a chain and a mode.** `Create token` opens `Choose your launch mode` with Base, Robinhood, Monad, Solana.
Two modes are offered: Dynamic and Multicurve. **Selecting Robinhood removes the Dynamic card.** On chain 4663 the app will only build a Multicurve launch (`pages/53-app-create-launch-mode.md`).

That is not an arbitrary UI choice.
It matches the chain: 108,698 of 109,159 assets sampled went through `DopplerHookInitializer` (multicurve), 457 through `LockableUniswapV3Initializer` (static v3) and 4 through `UniswapV4Initializer` (dynamic Dutch auction).

**Step 1, Quick launch or Standard launch.** Quick launch asks for five things and uses defaults for the rest.

| field | required | default |
| --- | --- | --- |
| Token image | yes, Continue stays disabled without it | none |
| Token name | yes | none |
| Token symbol | yes | none |
| Network | pre-set | Robinhood |
| Numeraire | pre-set | ETH |
| Social links | no | none |

The numeraire dropdown offers **98 assets**: ETH, USDG, and 96 tokenized Robinhood stock tokens from AAOI to ZS (`pages/54-app-create-quick-multicurve-robinhood.md`, list captured in `_raw/network/app-create-numeraire-options.json`).
Pairing against a stock token is a first-class option, not a workaround, and the indexer shows it is what most launches on this chain actually do: in a 1,000-asset sample only 82 used WETH as numeraire, while NVDA, AAPL, SNAP, SPCX, USDG and other launched tokens took the rest.

Standard launch turns the same form into a five-step wizard: Basics, Details, Pricing, Economics, Review.

**Step 2, Details.** Description, team members, fundraising rounds, milestones, documents.
All optional, all off-chain launch-page metadata.

**Step 3, Pricing.** Three editable supply curves plus a locked tail curve.
Defaults:

| curve | start market cap | end market cap | share of supply |
| --- | --- | --- | --- |
| 1 | $5,000 | $10,000,000 | 75% |
| 2 | $100,000 | $40,000,000 | 12.5% |
| 3 | $1,000,000 | $1,000,000,000 | 11.5% |
| tail, read-only | $1,000,000,000 | infinity | 1% |

Curves must be contiguous or overlapping and their shares must sum to exactly 1e18 (`pages/13-docs-reference-examples-multicurve.md`).
The first curve's start is the launch price, so a default launch opens at a $5,000 market cap.

**Step 4, Economics.**

| field | default | notes |
| --- | --- | --- |
| Total supply | 1,000,000,000 | |
| Tokens to sell | 100% | anything unallocated is burned |
| Vesting duration | 365 days | applies to grants, not to the sale |
| Recipients (grants) | none | ceiling is `100% - tokens to sell`, so 0% at the default |
| Fee tier | 1%, with 2% and 3% presets | custom allowed, UI validates `between 0% and 10%` |
| Fee earnings mode | Default, or Buy & Burn | |
| Fee currency | ETH | fees accrue in both the token and the numeraire |
| Fee beneficiaries | none | `5% is reserved for Doppler Protocol. The remaining 95% can be distributed among fee beneficiaries.` A disabled placeholder row shows the Doppler Protocol share at 5 |

**Step 5, Review.** Summary, an `Add governance` switch (off by default), and the warning `This action launches a new token on Robinhood and cannot be undone.`
The submit button reads `Connect wallet`.
With no wallet the flow stops here, so nothing past the signature was captured.

### 3.2 What the contracts actually do

Read from the verified sources in `contracts/`.

`Airlock.create(CreateParams)` is `external` and not `payable`, so no fee can be attached to the call.
It takes `initialSupply`, `numTokensToSell`, `numeraire`, the four modules with an opaque `bytes` blob each, an `integrator` address and a `salt`, and returns `(asset, pool, governance, timelock, migrationPool)`.
It reverts unless every module is in the right whitelist slot, then emits `Create(address asset, address indexed numeraire, address initializer, address poolOrHook)` (`contracts/Airlock-0xeb7c034704ef8dcd2d32324c1545f62fb4ad0862/sources/src/Airlock.sol`).

`DopplerERC20V1Factory.create()` decodes name, symbol, vesting schedules, grant beneficiaries and amounts, `tokenURI`, and three anti-snipe fields: `maxBalanceLimit`, `balanceLimitEnd` and a `controller`, plus an exclusion list.
The balance cap is a per-wallet ceiling that expires at a timestamp, which is how the launch is protected from a single buyer taking the curve.
The token itself is a minimal clone of `DopplerERC20V1` deployed at a mined salt.

`DopplerHookInitializer.initialize()` takes `InitData { uint24 fee; int24 tickSpacing; int24 farTick; Curve[] curves; BeneficiaryData[] beneficiaries; address dopplerHook; bytes onInitializationDopplerHookCalldata; bytes graduationDopplerHookCalldata; }`, lays the supply out as multiple concentrated-liquidity positions in one Uniswap v4 pool, and stores the beneficiary split.
A pool moves through `Uninitialized -> Initialized -> Locked -> Graduated -> Exited`.

Graduation is a **price** condition, not a raised-amount condition.
`graduate(address asset)` and `exitLiquidity(address asset)` both call `_canGraduateOrMigrate`, which requires the live pool tick to have reached `farTick`.
There is no ETH threshold anywhere in this path.
The tail curve extending to infinity means a multicurve pool never runs out of liquidity, which is why the default migrator does nothing.

`Doppler Hooks` are optional callbacks on `initialization`, `swap` and `graduation` for pools created by `DopplerHookInitializer`.
They can be attached or detached after the fact with `setDopplerHook`, and each one has to be approved by the protocol multisig (`pages/08-docs-advanced-features-doppler-hooks.md`).

### 3.3 What actually happens after the curve, on this chain

Nothing, almost always.
109,129 of 109,159 sampled assets on 4663 use `NoOpMigrator`, which never migrates.
Their `timelock` and `governance` are both `0x...dead`.
The multicurve pool is the permanent home and the token trades there forever.

The indexer's `migrationPools` count for chain 4663 is **0**, and no asset has `migrated: true`.
`DopplerHookMigrator` (4 assets) and `UniswapV2MigratorSplit` (26 assets) are configured on a handful of launches but none has fired.

The practical reading: on Robinhood Chain, Doppler is a permanent-AMM launcher, not a bonding-curve-then-graduate launcher.

### 3.4 Through the SDK

`npm install @whetstone-research/doppler-sdk viem`, version 1.0.39 at the cloned commit `6bc20400`.

```typescript
import { DopplerSDK, getAddresses } from '@whetstone-research/doppler-sdk/evm';
import { parseEther, createPublicClient, createWalletClient, http } from 'viem';

const ROBINHOOD = 4663;
const addresses = getAddresses(ROBINHOOD);      // resolves the whole 4663 set
const sdk = new DopplerSDK({ publicClient, walletClient, chainId: ROBINHOOD });

const params = sdk
  .buildMulticurveAuction()
  .tokenConfig({ name: 'My Token', symbol: 'MTK', tokenURI: 'ipfs://...' })
  .saleConfig({
    initialSupply: parseEther('1000000000'),
    numTokensToSell: parseEther('1000000000'),
    numeraire: addresses.weth,                   // or USDG, or any stock token
  })
  .withCurves({
    numerairePrice: 2386,                        // numeraire in USD, for the market-cap maths
    curves: [
      { marketCap: { start: 5_000,     end: 10_000_000 },    numPositions: 10, shares: parseEther('0.75')  },
      { marketCap: { start: 100_000,   end: 40_000_000 },    numPositions: 15, shares: parseEther('0.125') },
      { marketCap: { start: 1_000_000, end: 1_000_000_000 }, numPositions: 10, shares: parseEther('0.115') },
      { marketCap: { start: 1_000_000_000, end: 'max' },     numPositions: 1,  shares: parseEther('0.01')  },
    ],
  })
  .withGovernance({ type: 'noOp' })
  .withMigration({ type: 'noOp' })
  .withUserAddress(account.address)
  .build();

const { poolId, tokenAddress } = await sdk.factory.createMulticurve(params);
```

The curve values above are the app's own defaults restated in SDK terms; the docs example (`pages/13`) uses different ones and targets Base with `withMigration({ type: 'uniswapV2' })`.

Two things the docs do not say and that matter on 4663:

- `getAddresses(4663).tokenFactory` is the zero address.
Use `dopplerERC20V1Factory`.
The generic `tokenFactory` slot was never filled for this chain (`_raw/github/doppler-sdk/src/evm/addresses.ts`).
- `rehypeDopplerHookInitializer` resolves to `0x5F9eB5f6726Fe88D5e39867967F5b833d2fA3215`, and that contract is **not whitelisted as an Airlock module**, so passing it as `poolInitializer` reverts.
It is however **enabled as a Doppler Hook** (`isDopplerHookEnabled` returns 3), which is how rehypothecation is actually used on this chain: attached through `InitData.dopplerHook` on a normal `DopplerHookInitializer` launch.
See section 5.4.

## 4. Economics

Everything here is per launch on chain 4663, cited to a file.

| item | value | source |
| --- | --- | --- |
| Fee to create a token | none. The app charges nothing and `Airlock.create` is not payable in a fee sense | `pages/54`, `contracts/Airlock-0xeb7c034704ef8dcd2d32324c1545f62fb4ad0862/sources/src/Airlock.sol` |
| Minimum raise | none | `pages/54`, `pages/55` |
| LP the creator must seed | none. The bonding curve is the initial liquidity | `pages/13`, `contracts/DopplerHookInitializer-0x4e3468951d49f2eea976ed0d6e75ffcb44a9a544/sources/src/initializers/DopplerHookInitializer.sol` |
| Default total supply | 1,000,000,000 | `pages/55` step 4 |
| Default share on the curve | 100% of supply. Unallocated tokens are burned | `pages/55` step 4 |
| Default pool fee tier | 1%. Presets 1%, 2%, 3% | `pages/55` step 4 |
| Pool fee tier ceiling, UI | 10%, validated as `Custom fee must be between 0% and 10%.` | `pages/55` step 4 |
| Pool fee tier ceiling, contract | `MAX_LP_FEE = 100_000`, that is 10%, in `DopplerHookInitializer`. `DopplerHookMigrator` allows 150_000, that is 15%, on the migrated pool | `contracts/DopplerHookInitializer-0x4e3468951d49f2eea976ed0d6e75ffcb44a9a544/sources/src/initializers/DopplerHookInitializer.sol:171`, `contracts/DopplerHookMigrator-0x7bf319d8e969f7596b1bc171da9ce322f67ae0c4/sources/src/migrators/DopplerHookMigrator.sol:157` |
| Doppler's share of pool fees | **5% floor**, non-negotiable, and confirmed live at exactly `5e16` on a real token (`_raw/wallet/fee-beneficiaries-johndog.txt`). `MIN_PROTOCOL_OWNER_SHARES = WAD / 20` and the protocol owner must appear in the beneficiary list or the call reverts | `contracts/DopplerHookMigrator-0x7bf319d8e969f7596b1bc171da9ce322f67ae0c4/sources/src/types/BeneficiaryData.sol:22-23`, `pages/55` step 4 |
| Creator's share of pool fees | up to 95%, split however the creator wants across beneficiaries, and confirmed live at exactly `9.5e17`. Shares must total exactly 1e18. Claimed with `DopplerHookInitializer.collectFees(bytes32 poolId)` | same file, `storeBeneficiaries` |
| Protocol fee taken at migration | `max(5% of trading fees, 0.1% of proceeds)`, capped at 20% of trading fees. The remainder goes to the integrator | `contracts/Airlock-0xeb7c034704ef8dcd2d32324c1545f62fb4ad0862/sources/src/Airlock.sol:237-252`, `_handleFees` |
| Integrator's share | whatever is left of the migration fee after the protocol cut. The integrator is whoever passed their address into `create` | same |
| Proceeds split ceiling | `MAX_SPLIT_SHARE = 0.5e18`, 50% | `contracts/DopplerHookMigrator-0x7bf319d8e969f7596b1bc171da9ce322f67ae0c4/sources/src/base/ProceedsSplitter.sol:21` |
| Default vesting | 365 days, cliff 0, applied to grant recipients only | `pages/55` step 4, `pages/13` |
| Grant ceiling | `100% - tokens to sell`. At the 100% default it is 0% | `pages/55` step 4 |
| Graduation threshold | a price, `farTick`, not an amount raised. No ETH threshold exists | `contracts/DopplerHookInitializer-0x4e3468951d49f2eea976ed0d6e75ffcb44a9a544/sources/src/initializers/DopplerHookInitializer.sol:490-492` |
| Destination on graduation | whatever migrator was chosen. On this chain, in practice, none | indexer counts, section 3.3 |
| Anti-snipe | two mechanisms exist. The token-level one (`maxBalanceLimit` per wallet until `balanceLimitEnd`, with an exclusion list) is **off by default**: a real app launch sets `maxBalanceLimit = 0` (`_raw/wallet/app-native-create-decoded.txt`). `SwapRestrictorDopplerHook` is not an enabled hook (`isDopplerHookEnabled` returns 0). The hook-level one is the Rehype fee schedule (`startFee`, `endFee`, `durationSeconds`), and it is in production: every Long launch opens at an 80% hook fee decaying to about 1% over ten seconds (`resources/launchpads/long/README.md` section 3.3) | `contracts/DopplerERC20V1Factory-0x1b37d3a72082029c44b35b604ea473617580b69a/sources/src/tokens/DopplerERC20V1Factory.sol:40-79` |
| Wallet requirement | any EVM wallet announcing over EIP-6963. Privy is the identity layer and requires a SIWE signature bound to Chain ID 4663 before anything wallet-gated renders | `pages/62-app-connect-wallet-gate.md`, `_raw/wallet/siwe-message.txt` |
| KYC | none. A wallet signature is the only identity check | `pages/62-app-connect-wallet-gate.md`, `pages/60-app-terms.md` |

One caveat about the 5%.
It is a floor on the *beneficiary shares of pool fees*, enforced by `StreamableFeesLockerV2` and the migrator.
The Airlock's separate `_handleFees` split only runs on migration, and since nothing on 4663 has migrated, that path has collected almost nothing: `Airlock.getProtocolFees(WETH)` reads 0.0000178 WETH, and 0 USDG.

## 5. Smart contracts

Full table with creators, creation transactions and source directories: **`contracts/ADDRESSES.md`**.
33 addresses, all verified on Blockscout, each with `metadata.json`, `abi.json`, `sources/` and a per-contract `README.md`.

### 5.1 The launch path, in call order

| step | contract | address |
| --- | --- | --- |
| entry | Airlock | `0xeb7c034704ef8dcd2d32324c1545f62fb4ad0862` |
| mint | DopplerERC20V1Factory -> DopplerERC20V1 clone | `0x1b37d3a72082029c44b35b604ea473617580b69a` -> `0x3be8b97fd0e713b5abe0649fa830223b6b4bc599` |
| curve | DopplerHookInitializer | `0x4e3468951d49f2eea976ed0d6e75ffcb44a9a544` |
| pool | Uniswap v4 PoolManager | `0x8366a39cc670b4001a1121b8f6a443a643e40951` |
| governance | NoOpGovernanceFactory | `0x85f37f74ef2478a770318bc810177a9835911ad7` |
| migration | NoOpMigrator | `0xba2f330edb16cd8056f5988d8ce19bbc63475a0e` |

Alternative initializers are `UniswapV4Initializer` (dynamic, via `DopplerDeployer`) and `LockableUniswapV3Initializer` (static v3, via the chain's `UniswapV3Factory` `0x1f7d7550b1b028f7571e69a784071f0205fd2efa`).
Alternative migrators are `DopplerHookMigrator` (into v4 behind a hook, fees streamed by `StreamableFeesLockerV2`) and `UniswapV2MigratorSplit` (into v2, LP locked by `UniswapV2Locker`).

### 5.2 The docs table matches the chain

The Doppler docs list 25 contracts for Robinhood Mainnet (`pages/25-docs-reference-contract-addresses.md`).
All 25 exist on chain, are verified, and match the SDK's generated deployments file byte for byte (`_raw/github/doppler-sdk/src/evm/deployments.generated.ts`).
No discrepancy.

### 5.3 What the docs table does not tell you

Being listed in the docs is not the same as being usable.
`getModuleState(address)` was read live against the Airlock for all 25 documented addresses plus 111 look-alike contracts found by Blockscout name search (`_raw/blockscout/airlock-getModuleState.json`).
Only eleven are whitelisted:

| state | whitelisted |
| --- | --- |
| TokenFactory | DopplerERC20V1Factory, DN404Factory |
| GovernanceFactory | GovernanceFactory, LaunchpadGovernanceFactory, NoOpGovernanceFactory |
| PoolInitializer | DopplerHookInitializer, UniswapV4Initializer, LockableUniswapV3Initializer |
| LiquidityMigrator | NoOpMigrator, DopplerHookMigrator, UniswapV2MigratorSplit |

`RehypeDopplerHookInitializer` and `RehypeDopplerHookMigrator` are in the docs table for this chain and are **not** whitelisted.
Fee rehypothecation cannot be selected as the *pool initializer* on Robinhood Chain today.
It is used on this chain every day by the other route, as a Doppler Hook attached through `InitData.dopplerHook` on a `DopplerHookInitializer` launch; see 5.4 and the correction at the end of this file.

### 5.4 Two Rehype initializers

`0x5f9eb5f6726fe88d5e39867967f5b833d2fa3215` is the canonical one, in the docs and in the SDK, not whitelisted.

`0x6f02324d20cc679d0e585290caa6b16bacbc0f77` is a second, verified `RehypeDopplerHookInitializer` at a different address, deployed by a different EOA (`0xF7483Cb279eb3AfB8db553787363C2990836b459`).
It is not in the docs, not in the SDK, and not whitelisted as an Airlock *module*.
It is, however, enabled as a Doppler *hook*: `DopplerHookInitializer.isDopplerHookEnabled` returns 3 for it, the same as for the canonical address (`resources/launchpads/long/_raw/rpc/hook-state-top-tokens.txt`).
`app.doppler.lol` calls `getState(address)` on it through its own RPC proxy, and every one of Long's 13,802 launches attaches it as `dopplerHook` (`resources/launchpads/long/README.md` section 5.2).
So the non-canonical deployment is the production one on this chain, and the canonical `0x5f9eb5f6...` has no observed use here.
The plan's note that Long's Rehype address differs from Doppler's is confirmed: they are two separate deployments of the same source, and only Doppler's is in the docs.
Both have directories here.

### 5.5 Ownership

`Airlock.owner()` returns the Gnosis Safe `0x21e2ce70511e4fe542a97708e89520471daa7a66`, threshold 3 of 6.
The constructor argument was a different address, `0xEDeAa06E2eB42A5c19ce27c6cfFb36fd4fE1eDa8`, so ownership was transferred after deployment.
`StreamableFeesLockerV2.owner()` is still the constructor address.
That Safe is also the `integrator` on 6 of 1,000 sampled assets, meaning direct launches through the Doppler app credit fees to Doppler itself.

### 5.6 Claiming fees

For a multicurve launch the fee accounting lives on `DopplerHookInitializer`, not on `StreamableFeesLockerV2`.
The locker only ever holds migrated Uniswap v4 positions, and nothing on chain 4663 has migrated, so a creator on this chain never touches it.

| function | mutability | purpose |
| --- | --- | --- |
| `getBeneficiaries(address asset)` | view | the split **as stored at creation**, as `(address, uint96 shares)` pairs in WAD. It does not change when a beneficiary calls `updateBeneficiary`, so it goes stale; for AI on Long it still names the original receiver at 95% while `getShares` shows a community splitter holding the slot and the original receiver at 0 (`resources/launchpads/long/_raw/rpc/getshares-check.txt`) |
| `getShares(bytes32 poolId, address beneficiary)` | view | the **live** share of one address. Use this, not `getBeneficiaries`, to find who currently receives a pool's fees |
| `getCumulatedFees0(bytes32 poolId)` | view | lifetime fees accrued to the pool in currency0 |
| `getCumulatedFees1(bytes32 poolId)` | view | same for currency1 |
| `getLastCumulatedFees0(bytes32 poolId, address beneficiary)` | view | that beneficiary's watermark |
| `getLastCumulatedFees1(bytes32 poolId, address beneficiary)` | view | same for currency1 |
| `collectFees(bytes32 poolId)` | nonpayable | pays out `(cumulated - lastCumulated) * shares / WAD` and moves the watermark |
| `updateBeneficiary(bytes32 poolId, address newBeneficiary)` | nonpayable | hands a beneficiary slot to another address |
| `updateDynamicLPFee(address asset, uint24 fee)` | nonpayable | changes the pool fee, timelock or delegate only |

Worked example, JOHNDOG, read live on 2026-09-02 (`_raw/wallet/fee-beneficiaries-johndog.txt`):

- beneficiaries are the Doppler Safe at `50000000000000000` (5.0000%) and the creator `0x9b9849762f9be27d5546117c12ac6d7cf1dfbb38` at `950000000000000000` (95.0000%)
- `getCumulatedFees0` is 1,295,237.886989 JOHNDOG and `getCumulatedFees1` is 3.844611 SGOV
- the creator's two watermarks equal those figures exactly, so nothing is outstanding at capture time

Two things follow for a creator planning a launch.
Fees accrue in **both** sides of the pair, so a launch paired against a stock token pays the creator in that stock token as well as in their own token.
And the accounting is a watermark, not an escrowed balance, so `collectFees` is safe to call at any cadence and there is nothing to lose by claiming rarely.

### 5.7 Audits

Two audits are claimed on `pages/48-docs-reference-security-and-bug-bounties.md`: OpenZeppelin (Nov 2024) and Certora (dated "Nov. 204", a typo for 2024).
Both link to the same Google Drive folder, which needs a session to read and was not captured.
There was also a public Cantina audit contest (`pages/65`) and there is a live Cantina bug bounty (`pages/64`).
All of that predates the Robinhood Chain deployment, which the docs date to commit `bda077cf`.

## 6. Backend APIs

None of these are documented.
All were found in a HAR of a full app session (`_raw/network/app-session.har`, 2,598 requests) and sampled into `_raw/har-api/`.

### 6.1 app.doppler.lol

`GET /api/explore` is the main feed.
It is public, needs no key, and takes the chain and integrator filters straight from the UI.

```
GET https://app.doppler.lol/api/explore
  ?chains=eip155:4663
  &sortBy=percent_day_change&sortDirection=desc
  &offset=0&limit=30&tokenVariantFilter=standard
```

```json
{
  "offset": 0,
  "hasNextPage": true,
  "nextCursor": "eyJraW5kIjoidmVyaWZpZWQtY3VycmVudC1tYXJrZXQtdjEi...",
  "pools": [
    {
      "address": "0xa9349400def8a8fb8b96763c52870fcadbc8775361dd49e95291486be5141e0a",
      "chainId": "4663",
      "percentDayChange": 4792.857,
      "lastSwapTimestamp": "1788363291",
      "migrated": false,
      "liquidity": "283411412488892050454967",
      "createdAt": "1788312314",
      "marketCapUsd": "993613029538168973912709",
      "volume": "5883878279524399812715950",
      "integrator": "0x92d435c96e63c43e12d6d0ab28f6b0b04072f765",
      "baseToken": { "address": "0x64bcF4aA...1E18", "symbol": "JOHNDOG", "name": "John Dog", "tokenVariant": "standard" },
      "indexerSource": "consolidated",
      "previewBase64": "data:image/png;base64,..."
    }
  ]
}
```

`address` is the Uniswap v4 pool id, 32 bytes, not an address.
Sample: `_raw/api/probe-app-api-explore-4663.json`.

The rest:

| endpoint | what it returns |
| --- | --- |
| `GET /api/trendingPools` | same row shape, trending set. `_raw/har-api/app-api-trendingPools.json` |
| `GET /api/metadata/<chain>/<token>` | off-chain launch metadata: name, symbol, description, `attributes` including `launch_provider`, `initial_deployer` and `initial_fee_recipient` with X usernames, `tweet_url`. `_raw/har-api/app-api-metadata.json` |
| `GET /api/social/recent-buyers/<chain>/<token>` | recent buyer and seller addresses with signed dollar amounts |
| `GET /api/upcoming-auctions?tokenAddress=` | scheduled launches; returned `[]` for every token tried |
| `GET /api/native-price?assets=eth` | `{"eth":{"usd":2386.1}}` |
| `GET /api/image/<chain>/<token>` | token image proxy |
| `POST /api/rpc/4663` | an unauthenticated JSON-RPC proxy to Robinhood Chain. This is how the app reads `UniswapV3Factory.getPool`, `QuoterV2`, `V4Quoter`, and the initializers. It accepts arbitrary JSON-RPC from any origin, so it doubles as a free public RPC for chain 4663 |

The chain slug in these paths is `robinhood`; the RPC proxy uses the numeric id.

### 6.2 indexer-prod.doppler.lol

A Ponder GraphQL endpoint at `POST /`.
The docs only publish `test.indexer.doppler.lol` for Base Sepolia and say "Production endpoints are available upon request" (`pages/23-docs-reference-api-usage.md`), but the production endpoint is reachable without a key.

Query fields include `assets`, `pools`, `v4pools`, `v4PoolConfigs`, `migrationPools`, `swaps`, `positions`, `positionLedgers`, `modules`, `tokens`, `tokenVestingSchedules`, `hourBuckets`, `volumeBucket24h`, `cumulatedFees`, `userAssets`, `ethPrices` and per-pair price feeds.
Full list in `_raw/api/probe-indexer-prod-schema-queries.json`.

```graphql
{
  assets(where: { chainId: 4663 }, limit: 3, orderBy: "createdAt", orderDirection: "desc") {
    totalCount
    items {
      address chainId numeraire integrator
      poolInitializer liquidityMigrator governance timelock
      poolAddress migrationPool migrated migratedAt createdAt
      marketCapUsd percentDayChange
    }
  }
}
```

```json
{"data":{"assets":{"items":[{
  "address": "0xa0a55dd67716ace7693c4fcc2bfd8dc744151e18",
  "chainId": 4663,
  "numeraire": "0x47f93d52cbec7c6d2cfc080e154002370a60daea",
  "timelock": "0x000000000000000000000000000000000000dead",
  "governance": "0x000000000000000000000000000000000000dead",
  "liquidityMigrator": "0xba2f330edb16cd8056f5988d8ce19bbc63475a0e",
  "poolInitializer": "0x4e3468951d49f2eea976ed0d6e75ffcb44a9a544",
  "migrationPool": "0xdeaddeaddeaddeaddeaddeaddeaddeaddeaddead",
  "integrator": "0x92d435c96e63c43e12d6d0ab28f6b0b04072f765",
  "createdAt": "1788362698",
  "migrated": false,
  "poolAddress": "0x26e061dd66e5de9970d8e9b5b2233b760c173c7363cd1bf290ce489f9ef18061",
  "marketCapUsd": "28926202690820163043840"
}]}}}
```

`chainId` must be an integer, not a string, or the query fails validation.
Samples in `_raw/api/probe-indexer-prod-*.json`.

This endpoint is the cheapest way to answer any "who launched what on 4663" question and is what the rest of this README's counts come from.

### 6.3 Third-party services the app depends on

| host | use |
| --- | --- |
| `rc-api-rc.up.railway.app` | `/api/tokens/eip155:4663/<addr>`, `/api/launches/eip155:4663/<addr>/state`, `/api/markets/eip155:4663/<v4 pool id>`. A Robinhood-Chain-specific service, not Doppler's; samples in `_raw/har-api/rc-api-*.json` |
| `app.geckoterminal.com` | candlestick data for the price chart |
| `auth.privy.io` | identity. A SIWE signature bound to Chain ID 4663 is required before any wallet-gated view renders (`pages/62-app-connect-wallet-gate.md`) |
| `xc0avq1bsov25qyj.public.blob.vercel-storage.com` | token images |
| `gateway.umami.is`, `sessions.bugsnag.com`, `bam.nr-data.net`, `static.cloudflareinsights.com`, `prompts.maze.co` | analytics and error reporting |

## 7. Ecosystem

Read from `indexer-prod.doppler.lol` on 2026-09-02.
These counts move by the minute.

### 7.1 Doppler across chains

| chain | assets created |
| --- | --- |
| Base (8453) | 2,291,255 |
| **Robinhood Chain (4663)** | **109,177** |
| Monad (143) | 930 |
| Unichain (130) | 496 |
| Ethereum (1) | 41 |
| Ink (57073) | 22 |
| total | 2,401,922 |

Robinhood Chain is Doppler's second-largest deployment by a wide margin, and its share is about 4.5% of all Doppler launches.

### 7.2 On Robinhood Chain

| metric | value |
| --- | --- |
| Assets created | 109,177 |
| Pools | 109,178 |
| Swaps indexed | 3,581,109 |
| Assets migrated | 0 |
| Migration pools | 0 |

By pool initializer, on a 109,159-asset snapshot: DopplerHookInitializer 108,698, LockableUniswapV3Initializer 457, UniswapV4Initializer 4.
By migrator: NoOpMigrator 109,129, UniswapV2MigratorSplit 26, DopplerHookMigrator 4, RehypeDopplerHookMigrator 0.

### 7.3 Who is launching

From a 1,000-asset sample of the most recent launches (`_raw/api/probe-indexer-prod-assets-4663-sample1000.json`):

| integrator | assets in sample | who |
| --- | --- | --- |
| `0x92d435c96e63c43e12d6d0ab28f6b0b04072f765` | 821 | Long. Confirmed by cross-checking JOHNDOG and DEBTCOIN, which carry the `Long` badge in the app |
| `0xf60633d02690e2a15a54ab919925f3d038df163e` | 89 | Bankr. Confirmed by GIST, whose `/api/metadata` says `launch_provider: bankr` |
| `0x9adf17b7d91731ed74c2502695794ec95b8f2a26` | 36 | an EOA that launches **through Long's `LongLauncher`** with its own `integrator` and Rehype `buybackDst`, always sent from `0x4ef489fd...`; 921 assets in total. Who operates it is still unknown (`resources/launchpads/long/README.md` section 3.4) |
| `0x3879b1ee8389ffefb7afd51b1bafb9faf23d6699` | 12 | **Feel** (feel.cash). Identified by decoding a real `Airlock.create`, whose `tokenURI` is `https://feel.cash/chart-2` (`_raw/wallet/real-create-decoded.txt`) |
| `0x76303a76b6344d635903438b3b4e7affb6e021f5` | 8 | unidentified EOA |
| `0x21e2ce70511e4fe542a97708e89520471daa7a66` | 6 | the Doppler Safe itself, that is a direct launch through `app.doppler.lol` |

The app's `/api/explore` request exposes its full integrator allowlist, 14 addresses plus the literal string `zora`, in the query string captured in `_raw/har-api/app-api-explore.json`.

One warning about third-party attribution.
GeckoTerminal, which the app embeds for charts, titles the JOHNDOG chart `Bankr (Robinhood)` even though the Doppler app badges that token `Long` and the indexer's integrator is Long's address.
GeckoTerminal appears to label every Doppler pool on this chain `Bankr`.
Use the app badge or the indexer's `integrator` field, not the chart title.

### 7.4 Numeraires actually used

Same 1,000-asset sample:

| numeraire | assets | what it is |
| --- | --- | --- |
| `0x2e8c31162b855a2ffa90f6f8634643ad6f111e18` | 267 | AI, "Artificial Inu", itself a Doppler-launched token |
| `0x0bd7d308f8e1639fab988df18a8011f41eacad73` | 82 | WETH |
| `0xd0601ce157db5bdc3162bbac2a2c8af5320d9eec` | 80 | NVDA, tokenized stock |
| `0x5d2e81cb3a6fece856b824dfd7e1d6d3dbad8cd9` | 29 | FAMI, Farmmi Inc |
| `0xaf3d76f1834a1d425780943c99ea8a608f8a93f9` | 29 | AAPL, tokenized stock |
| `0x5fc5360d0400a0fd4f2af552add042d716f1d168` | 27 | USDG, Global Dollar |
| `0xf6589f11bc40b669e584073f428b05562f568733` | 25 | SNAP, tokenized stock |
| `0x4a0e65a3eccec6dbe60ae065f2e7bb85fae35eea` | 23 | SPCX, SpaceX |

Pairing against something other than ETH is the norm here, not the exception.
That is Robinhood Chain's whole point and Doppler supports it without any special casing: `numeraire` is just an address.

### 7.5 Notable tokens seen in the app

All on chain 4663, all `Long` badge unless noted: JOHNDOG (John Dog, $947K market cap, +4,853% day), DEBTCOIN ($432K), BOMBA (Bombardilo, $318K), CUM (Cummingtonite, $304K), KOLI ($205K), AAPLDOG (Apple Dog, $195K), MEOW (AMD, $185K), MONITOR (The Situation, $129K), BALD ($127K).

Doppler does not appear on DefiLlama at all: no `doppler` protocol slug, and no Doppler entry in the 143 protocols DefiLlama tracks on Robinhood Chain (`_raw/api/llama-fees-robinhood-chain.json`, `resources/launchpads/_market/_raw/llama-fees-robinhood.txt`).
Neither does Long.
So the fee league table in `_market` understates the Doppler stack by whatever Long's volume is worth.

## 8. Link inventory summary

Full table: `LINKS.md`.

- **49 of 49** docs pages captured, one `pages/` file each.
The sitemap has 49 URLs; the `tvly map` used in the earlier session found only 21, so the sitemap is the source of truth.
- **13 app views** captured as pages, with 34 screenshots, covering the Privy login gate, the SIWE challenge, and every authenticated view.
Every route and every modal reachable without a wallet.
- **12 Doppler-owned or Doppler-cited external properties** captured as pages: doppler.lol, whetstone.cc, both Cantina pages, four GitHub repos, both papers, Telegram, the test indexer.
- **18 GitHub repositories** cloned into `_raw/github/` with commit hashes in `COMMITS.txt`.
- **11 backend endpoints** documented with sample requests and responses.
- **105 token detail pages** recorded but not individually written up (91 on `robinhood`, 14 on `base`); they are listings, not pages about the platform.
- **6 dead links found in the docs**: one 404 (`/how-it-works/airlock-and-modules`), two unresolved GitBook `broken://` references published as-is, and three GitHub 404s into a restructured `doppler-docs` repo.
- Explorer links for the five non-Robinhood networks in the contract-addresses page are recorded in `_raw/links-extracted.tsv` but not followed.

## 9. Gaps

1. **The Privy login was completed; two small things behind it were not.** `Connect wallet` is gated by a Privy SIWE challenge bound to Chain ID 4663, not by a bare wallet connection.
An injected EIP-6963 provider plus a signature produced outside the browser gets through it, and the authenticated portfolio, Receive dialog, Instant buy controls and account menu are all captured in `pages/62-app-connect-wallet-gate.md`.
Notable there: Privy silently provisions an **embedded EVM and Solana wallet pair** on first login, alongside whatever wallet you connected.
The gate itself is fully documented in `pages/62-app-connect-wallet-gate.md`: the login modal, the EIP-6963 wallet list, and the verbatim SIWE message bound to Chain ID 4663.
An injected read-only provider (`_raw/tools/inject-readonly-wallet.js`) does reach the signature prompt, which proves the app will accept any EIP-6963 provider, but completing an authenticated session against a live third-party service was out of bounds for this run.
What the UI would have shown was instead recovered by decoding a real launch made through `app.doppler.lol` itself, one of 17 in the cached set (`_raw/wallet/app-native-create-decoded.txt`).
That settles the open questions: the app calls **`Airlock.create` directly, not through `Bundler`**, from the creator's own wallet, with `value = 0` and about 3.16M gas, and its on-chain parameters match the create form's defaults exactly.
Genuinely still uncaptured: the client-side salt mining that produces the `1e18` vanity suffix, and any post-launch creator dashboard.
A throwaway wallet funded with 0.001 ETH on 4663 (`0xTEST_WALLET_ADDRESS_REDACTED`) is available if a later session wants to walk the live flow.
2. **Portfolio and fee claiming, as a UI.** `Claimable fees`, the `Fees` column and the Instant buy controls all render empty or disabled without a session.
The underlying mechanism is not a gap: it was read directly from chain and is more precise than the dashboard would have been.
For a live token, `DopplerHookInitializer.getBeneficiaries(asset)` returns the Doppler Safe at exactly `5e16` (5%) and the creator at `9.5e17` (95%), and the claim path is `collectFees(bytes32 poolId)` with watermark accounting through `getCumulatedFees0/1` and `getLastCumulatedFees0/1`.
Evidence and worked numbers: `_raw/wallet/fee-beneficiaries-johndog.txt` and `pages/62-app-connect-wallet-gate.md`.
Note that `StreamableFeesLockerV2` is the wrong contract to look at for a multicurve launch on this chain; it only holds *migrated* v4 positions, and nothing on 4663 has migrated.
3. **Both audit PDFs.** OpenZeppelin and Certora both link to one Google Drive folder that needs a signed-in session.
Not captured.
The Certora entry is dated "Nov. 204" in the docs, an obvious typo.
4. **`Fees & economics` is an empty docs page.** `https://docs.doppler.lol/core-concepts/fees-and-economics` renders a heading and nothing else, in both the `.md` endpoint and the rendered HTML (`_raw/jina/docs-core-concepts_fees-and-economics.rendered.md`).
Every fee number in section 4 therefore comes from the contracts or the app UI, not from the docs.
5. **Integrator identities.** Two of the six integrators active on 4663 remain unlabelled EOAs with no Blockscout tag.
Long, Bankr and Feel were identified by cross-referencing token badges, `/api/metadata` and a decoded `tokenURI`; `0x76303a76...` was not, and `0x9adf17b7...` is known only as a third party routing through Long's launcher.
The reliable method is decoding a launch's `tokenFactoryData` and reading its `tokenURI` domain.
6. **The app's application-to-address map.** The Filters panel names 13 applications; `/api/explore` sends 14 integrator addresses plus the string `zora`.
The mapping between the two lives in the app bundle and was not extracted.
7. **No Doppler announcement of Robinhood Chain.** Nothing in the captured `@dopplerprotocol` timeline mentions chain 4663.
Every confirmation is second-hand, from `@cooper_kunz` and `@bankrbot` (`socials/04-third-party-robinhood-coverage.md`).
The chain first appears in the docs at commit `bda077cf`.
8. **`rc-api-rc.up.railway.app`.** A Robinhood-Chain service the app depends on, with no documentation and no obvious owner.
Three endpoints captured; its scope is unknown.
9. **Volume and fee totals.** Doppler is not on DefiLlama, so there is no independent revenue figure.
The indexer returns per-asset `volume` and `marketCapUsd`, but the top-by-market-cap query returns obviously broken values on a handful of test tokens, so no chain-level total is quoted here.
10. **The Solana side** was captured as docs pages only (`pages/17` to `pages/21`).
    It is out of scope for a Robinhood Chain launch.

---

## Corrections merged from the Long session, 2026-09-02

Applied in place above; listed here so the diff is visible.

1. Section 2: the `four in five` share is of the most recent 1,000 assets only; cumulatively Bankr has 88,764 assets and Long 13,802 of 109,404.
2. Section 4: anti-snipe has a second, live path, the Rehype hook fee schedule, which Long opens at 80% for ten seconds.
3. Sections 5.3 and 5.4: `not whitelisted` refers to the Airlock module registry; the non-canonical Rehype `0x6f02324d...` is enabled as a hook and is the one in production on every Long pool.
4. Section 5.6: `getBeneficiaries` is stale after `updateBeneficiary`; `getShares(poolId, address)` is the live view.
5. Section 7.3 and gap 5: `0x9adf17b7...` is a third party launching through `LongLauncher` with its own integrator address.

Everything Long-specific (its launcher, fee templates, community vaults, LongX) stays in `resources/launchpads/long/`.
