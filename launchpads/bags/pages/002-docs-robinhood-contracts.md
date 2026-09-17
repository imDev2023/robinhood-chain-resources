# Bags - Contracts Reference

> Source: https://docs.bags.fm/robinhood/contracts
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/robinhood/contracts.md)

---

# Contracts Reference

> Reference for the Bags smart contracts on Robinhood Chain: roles, addresses, key functions and events, custom errors, and ABI downloads.

This page is the reference for the Bags contracts on Robinhood Chain. For step-by-step usage, see the [Launch](/robinhood/launch-token), [Trade](/robinhood/trade-tokens), [Read State](/robinhood/read-state), and [Claim Fees](/robinhood/claim-fees) guides.

## Addresses

Protocol singletons and shared infrastructure on Robinhood Chain mainnet (chain ID `4663`):

| Contract                   | Address                                      |
| -------------------------- | -------------------------------------------- |
| `BagsFactory` (proxy)      | `0xe8Cc4431adF8b5A847C113EF0c6af9043219Cb37` |
| `BagsLens`                 | `0xC82Db941dAf90B754aecb5F7D14c683dc608d595` |
| `BagsV4Hook`               | `0x2380aBf72C17aABAb76480244759AC7E2932EEcC` |
| `BagsVault` (proxy)        | `0x4861446aa7fFd9e67a83cBbAcb1A4B70540B83Aa` |
| UniversalRouter (modified) | `0x8876789976dEcBfCbBbe364623C63652db8C0904` |
| V4Quoter                   | `0x8Dc178eFB8111BB0973Dd9d722ebeFF267c98F94` |
| StateView                  | `0xF3334192D15450CdD385c8B70e03f9A6bD9E673b` |
| PoolManager                | `0x8366a39CC670B4001A1121B8F6A443A643e40951` |
| PositionManager            | `0x58daec3116aae6D93017bAAea7749052E8a04fA7` |
| Permit2                    | `0x000000000022D473030F116dDEE9F6B43aC78BA3` |
| WETH (aeWETH proxy)        | `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73` |
| Multicall3                 | `0xcA11bde05977b3631167028862bE2a173976CA11` |

`BagsBondingCurve` and `BagsFeeShare` are per-token beacon proxies and `BagsToken` a per-token EIP-1167 clone — resolve them via the `TokenCreated` event, `factory.curveForToken` / `factory.feeShareForToken`, or `BagsLens.getTokenState`.

## Proxy Topology

Always integrate against the proxy addresses above — they are stable across upgrades. For upgrade monitoring (indexers should watch `Upgraded` events on all four):

| Contract                       | Pattern              | Upgrade surface                                                                                                        |
| ------------------------------ | -------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `BagsFactory`, `BagsVault`     | UUPS + ERC1967 proxy | `Upgraded` on the proxy address                                                                                        |
| `BagsBondingCurve` (per token) | Beacon proxy         | `Upgraded` on `BagsBondingCurveBeacon` `0x8DCEcaf516C828A493C2C449c1E25F92cF80207E` (retargets **all** curves at once) |
| `BagsFeeShare` (per token)     | Beacon proxy         | `Upgraded` on `BagsFeeShareBeacon` `0xdFf07d39C5332C602e06FA64f0A97C92fd8537e0` (retargets **all** fee-shares at once) |
| `BagsToken` (per token)        | EIP-1167 clone       | Immutable — never upgrades                                                                                             |
| `BagsV4Hook`                   | CREATE2 singleton    | Not upgradeable (a replacement would only affect future launches via `factory.setHook`)                                |
| `BagsLens`                     | Plain contract       | Redeployed freely — pin the address above                                                                              |

## ABI Downloads

The full ABIs (including custom `error` definitions used for revert decoding) are published in the [`robinhood-abi-v2`](https://github.com/bagsfm/bags-idl/tree/main/robinhood-abi-v2) directory of the public [`bagsfm/bags-idl`](https://github.com/bagsfm/bags-idl) repository:

| Contract           | ABI                                                                                                            |
| ------------------ | -------------------------------------------------------------------------------------------------------------- |
| `BagsFactory`      | [`BagsFactory.json`](https://github.com/bagsfm/bags-idl/blob/main/robinhood-abi-v2/BagsFactory.json)           |
| `BagsBondingCurve` | [`BagsBondingCurve.json`](https://github.com/bagsfm/bags-idl/blob/main/robinhood-abi-v2/BagsBondingCurve.json) |
| `BagsFeeShare`     | [`BagsFeeShare.json`](https://github.com/bagsfm/bags-idl/blob/main/robinhood-abi-v2/BagsFeeShare.json)         |
| `BagsLens`         | [`BagsLens.json`](https://github.com/bagsfm/bags-idl/blob/main/robinhood-abi-v2/BagsLens.json)                 |
| `BagsToken`        | [`BagsToken.json`](https://github.com/bagsfm/bags-idl/blob/main/robinhood-abi-v2/BagsToken.json)               |
| `BagsV4Hook`       | [`BagsV4Hook.json`](https://github.com/bagsfm/bags-idl/blob/main/robinhood-abi-v2/BagsV4Hook.json)             |
| `BagsVault`        | [`BagsVault.json`](https://github.com/bagsfm/bags-idl/blob/main/robinhood-abi-v2/BagsVault.json)               |
| `BagsBeacon`       | [`BagsBeacon.json`](https://github.com/bagsfm/bags-idl/blob/main/robinhood-abi-v2/BagsBeacon.json)             |

<Tip>
  Import the full ABIs so your EVM library can decode custom errors (e.g. `BagsBondingCurve_SlippageExceeded`) into readable messages instead of raw revert data.
</Tip>

## BagsFactory

Launch entry point and on-chain registry.

### Functions

```solidity theme={null}
// Launch (payable)
function create(string name, string symbol, string metadataURI, address partner, address[] claimers, uint16[] bps) payable returns (address token, address curve);
function createAndBuy(string name, string symbol, string metadataURI, address partner, address[] claimers, uint16[] bps) payable returns (address token, address curve);

// Registry (view)
function curveForToken(address token) returns (address);
function feeShareForToken(address token) returns (address);
function tokenForPoolId(bytes32 poolId) returns (address);
function getTokens(uint256 offset, uint256 limit) returns (address[]);
function allTokens(uint256 index) returns (address);
function allTokensLength() returns (uint256);

// Config (view) — owner-settable globals, snapshotted per launch
function creationFee() returns (uint256);
function graduationThreshold() returns (uint256);
function partnerFeeBps() returns (uint16);          // partner share of the protocol half

// Infrastructure wiring (view)
function hook() returns (address);
function vault() returns (address);
function weth() returns (address);
function permit2() returns (address);
function poolManager() returns (address);
function positionManager() returns (address);
function tokenImpl() returns (address);
function bondingCurveBeacon() returns (address);
function feeShareBeacon() returns (address);

// Owner only — affect FUTURE launches
function setCreationFee(uint256 newFee);
function setGraduationThreshold(uint256 newThreshold);
function setPartnerFeeBps(uint16 newPartnerFeeBps);
function setHook(address newHook);
function setTokenImpl(address newTokenImpl);
```

### Events

```solidity theme={null}
event TokenCreated(address indexed token, address indexed curve, address indexed creator, address feeShare, address partner, bytes32 poolId, string name, string symbol, string metadataURI);
event CreationFeeUpdated(uint256 newFee);
event GraduationThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
event PartnerFeeBpsUpdated(uint16 oldPartnerFeeBps, uint16 newPartnerFeeBps);
event HookUpdated(address indexed newHook);
event TokenImplUpdated(address indexed newTokenImpl);
event Upgraded(address indexed implementation); // UUPS implementation change
```

### Key errors

`BagsFactory_InsufficientCreationFee(required, sent)`, `BagsFactory_InvalidClaimers`, `BagsFactory_NoClaimers`, `BagsFactory_InvalidPartnerFeeBps(partnerFeeBps)`, `BagsFactory_InvalidGraduationThreshold(threshold)`, `BagsFactory_NoBuyValue`, `BagsFactory_BuyFailed(curve, value)`, `BagsFactory_RefundFailed(to, amount)`, `BagsFactory_FeeTransferFailed(to, amount)`.

## BagsBondingCurve

Per-token pre-migration AMM (virtual `x * y = k`). Resolve its address per token.

### Functions

```solidity theme={null}
// Trade
function buy(uint256 minTokensOut) payable;
function buyFor(address recipient, uint256 minTokensOut) payable;
function sell(uint256 tokensIn, uint256 minQuoteOut);
function sellFor(address recipient, uint256 tokensIn, uint256 minQuoteOut);
function migrate(); // manual migration if the threshold is already met

// Quotes (view)
function quoteBuy(uint256 quoteIn) returns (uint256 tokensOut, uint256 feeQuote, uint256 netQuoteIn, uint256 grossUsed, uint256 refundQuote);
function quoteSell(uint256 tokensIn) returns (uint256 quoteToSeller, uint256 feeQuote, uint256 grossQuoteOut);

// State (view)
function migrated() returns (bool);
function paused() returns (bool);
function currentPrice() returns (uint256);        // ETH wei per whole token
function bondingProgress() returns (uint256);      // 0-100
function thresholdQuote() returns (uint256);       // launch-snapshotted graduation target
function realQuoteReserves() returns (uint256);
function realTokenReserves() returns (uint256);
function getVirtualReserves() returns (uint256 vToken, uint256 vQuote);
function creator() returns (address);
function partner() returns (address);              // address(0) when none
function partnerFeeBps() returns (uint16);         // launch-snapshotted partner share of the protocol half
function lpQuoteAmount() returns (uint256);        // ETH earmarked for the migration LP
function TX_FEE_BPS() returns (uint256);           // 200 (2%)
function LP_TOKEN_AMOUNT() returns (uint256);      // 170M tokens seeded into the pool at migration
```

### Events

```solidity theme={null}
event TokensBought(address indexed buyer, address indexed recipient, uint256 grossQuoteIn, uint256 netQuoteIn, uint256 tokensOut, uint256 feeQuote, uint256 vaultFeeQuote, uint256 creatorFeeWETH, uint256 refundQuote, uint256 price, uint256 virtualTokenReserves, uint256 virtualQuoteReserves);
event TokensSold(address indexed seller, address indexed recipient, uint256 tokensIn, uint256 grossQuoteOut, uint256 netQuoteToRecipient, uint256 feeQuote, uint256 vaultFeeQuote, uint256 creatorFeeWETH, uint256 price, uint256 virtualTokenReserves, uint256 virtualQuoteReserves);
event Migrated(address indexed creator, address indexed platformAdmin, address indexed token, uint256 lpQuote, uint256 lpTokens, bytes32 poolId, uint160 sqrtPriceX96);
event FeesSplit(address indexed payer, address indexed vault, address indexed feeShare, uint256 vaultFeeQuote, uint256 creatorFeeWETH, uint256 partnerFeeWETH);
```

### Key errors

`BagsBondingCurve_SlippageExceeded(minExpected, actualOut)`, `BagsBondingCurve_AlreadyMigrated`, `BagsBondingCurve_NotInitialized`, `BagsBondingCurve_ThresholdNotReached(have, need)`, `BagsBondingCurve_NoQuoteSent`, `BagsBondingCurve_ZeroInputAmount`, `BagsBondingCurve_InvalidRecipient`, `EnforcedPause`.

## BagsFeeShare

Per-token fee ledger (accrues in WETH): the creator half for the claimers, plus the partner's cut of the protocol half. Resolve its address per token.

### Functions

```solidity theme={null}
function claim(bool unwrap);                        // unwrap = true pays native ETH; auto-pokes hook.sweep(poolId)
function claimable(address user) returns (uint256);
function getClaimers() returns (address[] addrs, uint16[] bps);
function claimerBps(address user) returns (uint16);
function PARTNER() returns (address);               // address(0) when none
function poolId() returns (bytes32);
function hook() returns (address);
function bondingCurve() returns (address);

// Owner only
function setClaimers(address[] claimers, uint16[] bps); // claimer list can change post-launch

// Curve / hook only — integrators cannot call these
function notifyFee(uint256 amount);
function notifyPartnerFee(uint256 amount);
```

### Events

```solidity theme={null}
event Claimed(address indexed user, uint256 amount, bool unwrap);
event FeeNotified(uint256 amount);         // creator half delivered, split among claimers
event PartnerFeeNotified(uint256 amount);  // partner cut of the protocol half delivered
event ClaimersUpdated(address[] claimers, uint16[] bps);
event SweepFailed(address indexed hook);   // claim proceeded, but the pre-claim sweep reverted
```

### Key errors

`BagsFeeShare_NothingToClaim`, `BagsFeeShare_NotAuthorized(caller)`, `BagsFeeShare_BpsSumInvalid(sum)`, `BagsFeeShare_DuplicateClaimer(claimer)`, `BagsFeeShare_TooManyClaimers(length, max)`, `BagsFeeShare_PartnerIsClaimer`, `BagsFeeShare_ClaimerHasUnpaid(claimer)`, `BagsFeeShare_NoPartner`.

## BagsLens

Stateless read aggregator. Preferred entry point for reads.

### Functions

```solidity theme={null}
function getTokenState(address token) returns (TokenState);
function getTokenStates(address[] tokens) returns (TokenState[]);
function claimableOf(address token, address user) returns (uint256);
function FACTORY() returns (address);
```

### TokenState struct

```solidity theme={null}
struct TokenState {
    bool exists;
    bool migrated;
    address curve;
    address feeShare;
    bytes32 poolId;
    uint256 thresholdQuote;
    uint256 realQuoteReserves;
    uint256 realTokenReserves;
    uint256 virtualTokenReserves;
    uint256 virtualQuoteReserves;
    uint256 priceQuotePerToken; // freezes at migration
    uint256 bondingProgressPct; // 0-99 bonding; 100 migrated
    uint256 totalRaised;
}
```

## BagsToken

Per-token ERC-20 with a fixed 1e9 supply (18 decimals). Standard ERC-20 surface (`name`, `symbol`, `decimals`, `totalSupply`, `balanceOf`, `approve`, `allowance`, `transfer`, `transferFrom`) plus:

```solidity theme={null}
function metadataURI() returns (string); // reverts on non-Bags ERC-20s

// EIP-2612 gasless approvals (enables one-transaction curve sells)
function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s);
function nonces(address owner) returns (uint256);
function DOMAIN_SEPARATOR() returns (bytes32);
```

## BagsV4Hook

Singleton Uniswap v4 hook shared by all Bags pools. It takes the 2% fee on the WETH leg of post-migration swaps, locks liquidity, and routes creator fees to each token's fee-share.

### Functions

```solidity theme={null}
function pools(bytes32 poolId) returns (address bondingCurve, address feeShare, uint128 pendingFees, bool minted, address partner, uint16 partnerFeeBps);
function sweep(bytes32 poolId);               // flush pending fees to vault + fee-share + partner (permissionless)
function register(bytes32 poolId, address bondingCurve, address feeShare, address partner, uint16 partnerFeeBps); // factory-only
function factory() returns (address);
```

### Events

```solidity theme={null}
event HookFeeTaken(bytes32 indexed poolId, uint256 amount);   // gross WETH volume = amount * 50
event FeesSwept(bytes32 indexed poolId, uint256 bagsShare, uint256 creatorShare, uint256 partnerShare);
event PoolRegistered(bytes32 indexed poolId, address indexed bondingCurve, address indexed feeShare, address partner, uint16 partnerFeeBps);
event PoolMinted(bytes32 indexed poolId, address indexed currency0, address indexed currency1);
```

### Key errors

`BagsV4Hook_ExactOutputWETHSpecifiedUnsupported` (exact-out WETH is rejected by design), `BagsV4Hook_LiquidityLocked`, `BagsV4Hook_PoolNotRegistered(poolId)`, `BagsV4Hook_AlreadyRegistered(poolId)`, `BagsV4Hook_NotFactory(caller)`, `BagsV4Hook_PoolMissingWETH`.

## BagsVault

Platform treasury holding native ETH (the vault portion of the protocol fee half and the launch fee). Owner-controlled withdrawals; no integrator-facing calls.

```solidity theme={null}
function balance() returns (uint256 nativeBalance);

// Owner only
function withdraw(address to, uint256 amount);
function withdrawToken(address token, address to, uint256 amount);
```

Events: `Received(from, amount)`, `Withdrawn(to, amount)`, `TokenWithdrawn(token, to, amount)`, `Upgraded(implementation)`.

## BagsBeacon

Two instances (curve + fee-share) each hold the implementation address for all their beacon proxies. Integrators only need these for **upgrade monitoring** — a single `upgradeTo` retargets every live launch at once.

```solidity theme={null}
function implementation() returns (address);
function upgradeTo(address newImplementation); // owner only
```

Event: `Upgraded(address indexed implementation)`.

## Periphery ABIs

The Uniswap-style infrastructure is not part of the Bags ABI export. These are the minimal fragments used by the [Trade Tokens](/robinhood/trade-tokens) and [Read State](/robinhood/read-state) guides.

### UniversalRouter (modified fork)

Only `execute` is called directly. The v4 swap struct carries an extra `uint256 minHopPriceX36` field vs vanilla Uniswap (set it to `0`), so encode the calldata manually.

```solidity theme={null}
function execute(bytes commands, bytes[] inputs, uint256 deadline) payable;
```

The v4 swap params tuple (encoded manually for `SWAP_EXACT_IN_SINGLE`):

```solidity theme={null}
struct SwapExactInSingle {
    PoolKey poolKey;        // (currency0, currency1, fee, tickSpacing, hooks)
    bool zeroForOne;
    uint128 amountIn;
    uint128 amountOutMinimum;
    uint256 minHopPriceX36; // Robinhood-only field — always 0
    bytes hookData;         // "0x"
}
```

Command / action bytes: command `V4_SWAP = 0x10`; actions `SWAP_EXACT_IN_SINGLE = 0x06`, `SETTLE_ALL = 0x0c`, `TAKE_ALL = 0x0f`.

### Permit2

```solidity theme={null}
function approve(address token, address spender, uint160 amount, uint48 expiration);
function allowance(address owner, address token, address spender) returns (uint160 amount, uint48 expiration, uint48 nonce);
```

### V4Quoter (call via `eth_call` / simulate, not on-chain)

```solidity theme={null}
function quoteExactInputSingle((PoolKey poolKey, bool zeroForOne, uint128 exactAmount, bytes hookData) params) returns (uint256 amountOut, uint256 gasEstimate);
```

`quoteExactInputSingle` is `nonpayable`, not `view` — it must be **simulated** via `eth_call` (viem's `simulateContract`), never called as a plain read. The [Trade Tokens](/robinhood/trade-tokens) guide does this. Output already includes the 2% hook fee — apply slippage only.

### StateView

```solidity theme={null}
function getSlot0(bytes32 poolId) returns (uint160 sqrtPriceX96, int24 tick, uint24 protocolFee, uint24 lpFee);
function getLiquidity(bytes32 poolId) returns (uint128 liquidity);
```

### WETH (aeWETH proxy)

WETH9-compatible interface. Never rely on its bytecode/codehash — it's an upgradeable proxy.

```solidity theme={null}
function deposit() payable;
function withdraw(uint256 amount);
function approve(address spender, uint256 amount) returns (bool);
function balanceOf(address account) returns (uint256);
```

## Pool key parameters

Bags pools use these exact values — they must match the factory or derived pool IDs will be wrong:

| Parameter     | Value                                   |
| ------------- | --------------------------------------- |
| `fee`         | `0x800000` (dynamic fee flag)           |
| `tickSpacing` | `60`                                    |
| `hooks`       | `BagsV4Hook` address                    |
| Pair          | token / WETH, sorted by numeric address |

`poolId = keccak256(abi.encode(currency0, currency1, fee, tickSpacing, hooks))`. Prefer the on-chain `poolId` from `TokenCreated` or `BagsLens.getTokenState`.
