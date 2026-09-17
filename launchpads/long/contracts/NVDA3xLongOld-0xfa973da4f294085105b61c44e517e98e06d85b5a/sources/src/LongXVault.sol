// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ILighterBridge, StoredBatchInfo} from "./ILighterBridge.sol";
import {LighterProofV2 as LighterProof} from "./LighterProofV2.sol";
import {LighterStateVerifierV2 as LighterStateVerifier} from "./LighterStateVerifierV2.sol";

/// ============================================================================
/// ██  LongXVault — proof-gated leveraged-token vault on a Lighter L2 account. ██
/// ============================================================================
///
/// LongXVault mints an ERC20 leveraged token backed by a single Lighter perp
/// position held in a contract-owned L2 account. All pricing and accountability
/// derive from zk-verified account state (LighterStateVerifier over the bridge's
/// committed roots) — there is no owner-trusted price feed.
///
/// EXPOSURE MANAGEMENT — two proof-gated paths:
///
///   - KEY LEASE (main path, both directions). When proven leverage exits the
///     band, anyone may `acquireLease(pubKey, w, batch)` against an out-of-band
///     proof and post a bond; the vault installs the caller's L2 API key via
///     `changePubKey`. The lessee then trades the leased key freely — buys and
///     sells, resting or marketable — until leverage is back in band, when
///     `parkKey(w, batch)` proves in-band and parks the key to a non-signing
///     constant (K∅). Growth (re-levering) requires a key: L1-forced orders are
///     circuit-restricted to reduce-only.
///
///   - KEYLESS BACKSTOP. `rebalance()` force-sells an out-of-band account with
///     no key at all, so de-leveraging and stop-out never wait on an executor
///     that is absent, wedged, or hostile. It cannot open a position
///     (reduce-only), which is exactly why it is a safety net, not the main
///     path. Holder protection is keyless; only growth is keyed.
///
/// LEASE ACCOUNTABILITY — bond + position-divergence. `acquireLease` posts a
/// bond priced at `bondBps` of the proven equity (the CVaR of the lease's
/// worst-case drag). `parkKey` records the proven target-market position as a
/// snapshot and opens a challenge window; a permissionless `challenge` proving
/// the position later DIVERGED from the snapshot — beyond the vault's own order
/// allowance — slashes the bond into holder equity. A position only moves when
/// someone ACTS, so a single snapshot is sound evidence, unlike leverage, which
/// moves with price. `expireLease` force-parks a lease that overruns its
/// execution window (slashing only an above-band overrun); `releaseBond`
/// returns the bond after an honest park's window lapses.
///
/// SETTLEMENT — permissionless. `proveState` proves the account at the committed
/// head, derives NAV = TRUE equity / supply, and settles queued mint/redeem
/// requests FIFO at that NAV (anti-MEV: a request settles only at a proof
/// strictly following its acceptance). Redemptions are made deliverable by a
/// reduce-before-withdraw leg, an owed-shortfall NAV deduction, and
/// permissionless retry (see `_settle`).
///
/// ADMIN — the only privileged role, structurally bounded (it can never route
/// user funds to a privileged address): `pause`/`unpause` freeze the
/// risk-increasing entrypoints while the accountability surface stays open;
/// `raiseCap` loosens the equity cap monotonically; `forceUnwind` (paused-only)
/// closes the position and withdraws so holders exit pro-rata via
/// `redeemUnwound`; `withdrawFees` drains only the mint-fee pool.
///
/// Definitions (all from zk-proven pub-data facts):
///   N6 := |positionSize| × markPrice scaled to 6-decimal USD, single target
///         market (venue decimals fixed at construction).
///   E  := balances[3] + signed position value — TRUE equity (the trie nets a
///         position's entry cost out of the cash balance).
///   L  := N6 / E, 1e18-scaled; E ≤ 0 with N > 0 reads as L = ∞.
///
/// Order policy: MARKET orders only (a resting limit order would be invisible
/// to the account witness and a second rebalance would double the exposure).
/// dN6 = λ·E − N with λ the in-band target leverage; a correction under the
/// venue minimum notional is clamped UP when the overshoot still lands in band,
/// else refused. The order price is a slippage clamp on the proven mark.
/// Long-only: a short position is a hard refusal; E ≤ 0 with N > 0 (stop-out)
/// emits a full close (`baseAmount = 0` = whole position). An L2-side rejection
/// is a SILENT NOOP, never state corruption — the next proof shows unchanged
/// state and the crank retries.
///
/// Serial lanes: rebalance orders use their own in-flight serial
/// (`rebalanceOpSerial`), independent of the settlement lane
/// (`lastBridgeOpSerial`). Settlement ops block rebalance (they change equity,
/// so sizing must postdate them), but a pending rebalance does NOT block
/// `proveState`: a fill moves balance and position atomically inside the leaf,
/// so NAV at any committed root is exact regardless of what is still queued.
contract LongXVault is ERC20, Pausable {
    using SafeERC20 for IERC20;

    // ------------------------------------------------------------ config
    IERC20 public immutable usdg; // 6 decimals
    ILighterBridge public immutable bridge;
    LighterStateVerifier public immutable verifier;
    uint16 public immutable assetIndex;
    uint8 public immutable routeType;
    /// @dev The api-key slot the lease installs/parks (v2 lease surface).
    uint8 public immutable apiKeyIndex;
    /// @dev Nothing-up-my-sleeve nonzero constant expressing "no key" (K∅):
    ///      a hash-derived non-curve-point the L2 accepts and cannot sign
    ///      with (validated live in v1). Parking to it ends a lease.
    bytes public parkPubKey;
    /// @dev The single market whose bucket witnesses open raw.
    uint16 public immutable targetMarket;
    /// @dev Venue size/price decimals for targetMarket — NOT in pubdata.
    uint8 public immutable sizeDecimals;
    uint8 public immutable priceDecimals;
    /// @dev Leverage band [lo, hi], 1e18-scaled. In-band is CLOSED: lo ≤ L ≤ hi.
    uint256 public immutable bandLo1e18;
    uint256 public immutable bandHi1e18;
    /// @dev Rebalance target λ, 1e18-scaled, strictly inside [lo, hi] so a
    ///      correctly-sized order always terminates the out-of-band condition.
    uint256 public immutable targetLeverage1e18;
    /// @dev Slippage clamp on the forced order's price, bps of proven mark.
    uint16 public immutable maxSlippageBps;
    /// @dev Venue minimum order notional (min_quote_amount), 6d USD.
    uint64 public immutable minOrderNotional6;
    /// @dev Redemptions settle at nav × (1 − haircut): the reduce that frees
    ///      the withdrawal realizes taker fees and slippage AFTER the anchor
    ///      priced the claim, and on a full exit no remaining holders absorb
    ///      that gap — a full exit can strand owed against realized
    ///      collateral exactly this way. Sized to cover taker fee +
    ///      the maxSlippageBps clamp + rounding; the surplus accrues to
    ///      remaining holders.
    uint16 public immutable exitHaircutBps;
    /// @dev The L1 address the account leaf is bound to. address(this) in a
    ///      real deployment; overridable so a fork harness can prove the live
    ///      account 1368 (owned by the v1 vault) from a fresh instance.
    address public immutable expectedL1Owner;
    /// @dev v5.1: how many committed batches a released lessee stays liable
    ///      for. Sized on the FULL challenge chain, not the anchor lag: a
    ///      challenge cannot land until the park op COMMITS (~10-30s), then
    ///      `finalizeKeyChange` opens the window, then the challenger BUILDS a
    ///      proof (mirror warming ~30-45s) and submits it — ~1-1.5 min minimum,
    ///      measured live in the v5.1 validation. A window sized only to the
    ///      1-2 batch anchor lag is UNCHALLENGEABLE in practice and would
    ///      silently render this whole layer inert.
    ///
    ///      v5.3: this is now the challengeable ANCHOR range, counted from
    ///      `parkAnchorBatch` (not from a finalize crank), so the lessee can
    ///      compute their own bond-release batch deterministically. Default 60.
    uint64 public immutable challengeBatches;
    /// @dev ~60 batches ≈ 10 min at the observed ~10s commit cadence: covers the
    ///      challenge chain with margin. NB: the verifier's `freshnessBatches`
    ///      must be >= this or a late-window challenge would revert `StaleBatch`
    ///      (constructor-checked).
    uint64 public constant DEFAULT_CHALLENGE_BATCHES = 60;

    /// @dev v5.3: T_E — committed batches a lease is valid for, from
    ///      `leaseStartBatch`. After it, `expireLease` force-parks the key.
    ///      Sized at ~3x the measured acquire→release cycle (build acquire proof
    ///      ~30-45s, trade, build in-band park proof ~30-45s) so an honest
    ///      executor has real margin.
    uint64 public immutable executionBatches;
    /// @dev ~90 batches ≈ 15 min at ~10s cadence.
    uint64 public constant DEFAULT_EXECUTION_BATCHES = 90;

    /// @dev v5.3 fee/bounty rates (bps). All 0 by default → the whole
    ///      fee/bounty layer is inert. `mintFeeBps` skims each mint into the L1
    ///      fee pool; `rescuerBountyBps` pays a `rebalance` caller (bps of the
    ///      corrected notional); `executorBountyBps` pays a lessee on a clean
    ///      `releaseBond` (bps of their bond). Bounties are paid only from the
    ///      pool, never the L2 leaf.
    uint16 public immutable mintFeeBps;
    uint16 public immutable rescuerBountyBps;
    uint16 public immutable executorBountyBps;

    /// @dev v5.3.1: cap on the vault's equity, USDG 6d. `requestMint` reverts
    ///      once the PROJECTED equity — last proven equity + queued mint escrow
    ///      + pending slash deposits + the incoming principal — would exceed it.
    ///      The bond model's friction bound (S2) is measured against finite
    ///      venue depth, so V must stay bounded relative to it for the priced
    ///      bond to cover the tail. 0 = uncapped (harness deployments only).
    ///      v5.3.3: STORAGE, not immutable — the admin may loosen it via the
    ///      raise-only `raiseCap`.
    uint256 public equityCapUsdg;

    /// @dev TxTypes.OrderType.MarketOrder on the bridge.
    uint8 public constant ORDER_TYPE_MARKET = 1;

    /// @dev Tokens minted to the burn address at genesis: a permanent supply
    ///      floor. Hardens against donation/inflation attacks (inflating NAV
    ///      requires donating value that partly accrues to unredeemable
    ///      shares) and guarantees the supply==0 state — and with it the
    ///      1.0 genesis price — can occur at most once in the vault's life.
    ///      0.001 tokens ≈ 0.001 USDG at genesis: negligible cost.
    uint256 public constant DEAD_SHARES = 1e15;
    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    /// @dev Minimum genesis deposit: below ~10 USDG of openable notional the
    ///      rebalancer could never bootstrap leverage (venue min notional).
    uint256 public constant MIN_GENESIS_USDG = 5e6;

    struct VaultConfig {
        LighterStateVerifier verifier;
        uint16 targetMarket;
        uint8 sizeDecimals;
        uint8 priceDecimals;
        uint256 bandLo1e18;
        uint256 bandHi1e18;
        uint256 targetLeverage1e18; // 0 → (lo+hi)/2; else must lie in [lo, hi]
        uint16 maxSlippageBps; // < 10000
        uint64 minOrderNotional6; // venue min notional, 6d (10e6 on RH)
        uint16 exitHaircutBps; // redeem realization haircut, ≤ 1000 (~60 = fee+slippage)
        address expectedL1Owner; // address(0) → address(this)
        uint8 apiKeyIndex; // lease key slot
        bytes parkKey; // K∅ constant (nonzero, non-curve-point)
        uint64 challengeBatches; // T_c challenge-anchor window; 0 → default (60)
        uint64 executionBatches; // T_E lease-validity window; 0 → default (90)
        uint16 bondBps; // bond as bps of proven equity at acquire; 0 = no penalty (harness only)
        uint16 mintFeeBps; // fee skimmed to the pool on mint; 0 = off
        uint16 rescuerBountyBps; // rebalance-caller bounty; 0 = off
        uint16 executorBountyBps; // clean-release lessee bounty; 0 = off
        uint256 equityCapUsdg; // mint cap on projected equity, 6d; 0 = uncapped
        address admin; // v5.3.3 ops role; address(0) = the deployer
    }

    // ------------------------------------------------------------ account
    uint48 public accountIndex;
    bool public accountOpened;

    // ------------------------------------------------------------ NAV
    /// @dev USDG (6 decimals) per 1e18 vault tokens. Bootstrapped to 1e6 (1.0).
    uint256 public navPerToken = 1e6;
    uint256 public lastNavTimestamp;
    /// @dev Batch number of the last accepted proof (monotonic).
    uint64 public lastProvenBatch;
    /// @dev All-time priority serial of our latest settlement bridge ops;
    ///      0 = nothing in flight. proveState blocks until these are
    ///      committed on L2 — otherwise NAV would be computed from an equity
    ///      that excludes forwarded deposits whose tokens have already minted
    ///      (or still includes withdrawn USDG whose tokens have already
    ///      burned).
    uint64 public lastBridgeOpSerial;
    /// @dev Head batch at the moment our in-flight ops were confirmed
    ///      committed. The ops are in SOME batch <= this, so any proof
    ///      anchored at or after it reflects them in the proven equity.
    uint64 public bridgeOpsClearedAtBatch;

    // ------------------------------------------------------------ rebalance lane
    /// @dev All-time priority serial of our latest forced order; 0 = none in
    ///      flight. A new rebalance blocks until the previous order is
    ///      committed AND the anchor postdates its commit — otherwise a
    ///      second order would be sized from state that ignores the first
    ///      (double-correction). proveState deliberately does NOT read this:
    ///      a fill moves balance and position atomically inside the leaf, so
    ///      NAV at any committed root stays exact.
    uint64 public rebalanceOpSerial;
    /// @dev Head batch when the last order was confirmed committed; any
    ///      anchor at or after it reflects the order's effect (fill or noop).
    uint64 public rebalanceClearedAtBatch;

    /// @dev All-time priority serial of the newest redemption withdrawal;
    ///      monotonic, never cleared. Once `executedPriorityRequestCount`
    ///      passes it, a SUCCESSFUL withdrawal has credited the bridge
    ///      pending balance — so any owed USDG still unaccounted for on L1
    ///      is provably sitting in the leaf (the withdrawal was nooped) and
    ///      must be deducted from equity and re-withdrawn.
    uint64 public lastRedeemWithdrawSerial;

    // ------------------------------------------------------------ request queue
    enum RequestKind {
        Mint,
        Redeem
    }

    enum RequestStatus {
        None,
        Pending,
        Settled,
        Claimed
    }

    struct Request {
        RequestKind kind;
        RequestStatus status;
        address receiver;
        uint128 amountIn; // Mint: USDG (6d). Redeem: vault tokens (18d).
        uint128 amountOut; // Set at settlement. Mint: tokens. Redeem: USDG.
        uint64 requestedAt;
        /// @dev committedBatchesCount at acceptance. The request may only
        ///      settle at a proof whose batch is STRICTLY greater — the
        ///      anti-MEV rule ("first committed root following acceptance").
        uint64 acceptedAtBatch;
    }

    mapping(uint256 => Request) public requests;
    uint256 public nextRequestId;
    uint256 public nextSettleId;

    /// @dev USDG held for requested-but-unsettled mints (not spendable for payouts).
    uint256 public escrowedMintUsdg;
    /// @dev USDG owed to settled-but-unclaimed redeems.
    uint256 public owedRedeemUsdg;

    // ------------------------------------------------------------ key lease
    /// @dev v5.3: the four-state machine (Parked/AcquirePending/Leased/
    ///      ReleasePending) collapses to two. The priority-queue latency of the
    ///      acquire `changePubKey` no longer needs an explicit state: the lease
    ///      simply runs for `executionBatches`, which dwarfs the ~1-3 batch
    ///      commit lag. The park leg's commit IS still tracked, but as a
    ///      `releaseBond` precondition (`parkKeySerial`) rather than a state +
    ///      finalize crank — see `releaseBond`.
    enum KeyState {
        Parked,
        Leased
    }

    KeyState public keyState; // Parked by default
    address public lessee;
    bytes public leasedKey;

    /// @dev committedBatchesCount at `acquireLease`. The lease is valid for
    ///      `executionBatches` (T_E) committed batches from here; after that
    ///      `expireLease` is permissionlessly callable.
    uint64 public leaseStartBatch;

    // ------------------------------------------ v5.3 bond + divergence accountability
    /// @dev v5.3 replaces the v5.1/v5.2.2 LEVERAGE-based challenge (which could
    ///      not tell a lessee who moved the position from mere price drift) with
    ///      a POSITION-DIVERGENCE one. At `parkKey` the vault records the proven
    ///      target-market position; a `challenge` proving the position later
    ///      DIVERGED from that snapshot slashes the lessee's bond. A position
    ///      only moves when someone ACTS, so a single snapshot is sound evidence
    ///      of an act — unlike leverage, which moves with price alone.
    ///
    ///      Bond posted at acquire, held past the park, and either returned by
    ///      `releaseBond` after the window lapses or slashed into vault equity.
    ///
    ///      v5.3.1: the bond is PRICED, not fixed — `bondBps` of the PROVEN true
    ///      equity in the acquire witness (Bond Pricing Model v5: B/V = 6.46% at
    ///      alpha 0.99 over the venue-wide worst reachable market → 650 bps
    ///      deployed). Equity moves between leases, so the posted amount is
    ///      computed per lease and recorded in `leaseBond` / `parkBond`.
    uint16 public immutable bondBps; // bps of proven equity; 0 = no penalty (harness only)

    /// @dev v5.3.3 ops role: raiseCap / pause / unpause / forceUnwind /
    ///      withdrawFees — since v5.4 the ONLY privileged role (the owner
    ///      emergency surface is gone). Defaults to the deployer when the
    ///      config passes address(0).
    address public immutable admin;
    /// @dev TERMINAL: set by `forceUnwind`. The vault stays paused forever and
    ///      shareholders exit pro-rata via `redeemUnwound`.
    bool public unwound;

    /// @dev Bond posted for the LIVE lease (USDG 6d). Moves to `parkBond` when
    ///      the park opens the challenge window. Both slots are EXCLUDED from
    ///      `_availableUsdg` — neither holder equity nor redeemer collateral
    ///      while at risk.
    uint256 public leaseBond;
    /// @dev Bond held for the OPEN park liability (`parkLessee`'s). Returned by
    ///      `releaseBond` or slashed by the challenge paths.
    uint256 public parkBond;
    /// @dev Slashed USDG awaiting the forward to L2. NAV is proven-L2-equity /
    ///      supply, so a slash only reaches holders once deposited into the
    ///      leaf; `_settle` forwards it with the next round's deposit. Also
    ///      excluded from `_availableUsdg`.
    uint256 public pendingSlashDeposit;

    /// @dev The party whose bond is at risk for the open park window.
    ///      address(0) = no open liability (and `acquireLease` may lease freely).
    address public parkLessee;
    /// @dev The batch the park proof anchored at: both the divergence baseline
    ///      and the origin of the challenge window (`parkAnchorBatch +
    ///      challengeBatches`), computable off-chain the instant the park lands.
    uint64 public parkAnchorBatch;
    /// @dev Root-authenticated target-market `positionSize` at `parkAnchorBatch`
    ///      (P_n). THE divergence baseline. Deliberately a size scalar, never a
    ///      bucket-digest fingerprint (the digest commits funding too, and
    ///      funding accrues every batch).
    int128 public parkPositionSize;
    /// @dev The park `changePubKey`'s priority serial. `releaseBond` waits for
    ///      `committedPriorityRequestCount` to reach it — a commit-basis proof
    ///      the key is DEAD before the bond is returned. Batch height and
    ///      priority-queue depth are decoupled, so batch arithmetic alone could
    ///      let the window lapse while the key is still live.
    uint64 public parkKeySerial;
    /// @dev Max challengeable anchor. type(uint64).max while a fresh park's
    ///      window is fully open; a new `acquireLease` during the window lowers
    ///      it to the new lease's start batch, so evidence from before the new
    ///      lessee held the key stays attributable to the OLD lessee (this is
    ///      what lets a new lease proceed during T_c without lapsing liability
    ///      or reintroducing the v5.1 collusion hole).
    uint64 public liabilityAnchorCap;

    /// @dev Vault-originated target-market order quantities enqueued since the
    ///      park (the false-slash guard). A `challenge` divergence is judged
    ///      against [P_n - vaultSellAllowance, P_n + vaultBuyAllowance], so the
    ///      vault's OWN permissionless `rebalance`/reduce cannot manufacture a
    ///      divergence that slashes an honest lessee.
    uint48 public vaultSellAllowance;
    uint48 public vaultBuyAllowance;
    /// @dev A vault order with baseAmount==0 ("whole position") was enqueued —
    ///      an unbounded decrease, so the decrease side of the band is disabled.
    bool public vaultFullCloseIssued;

    /// @dev L1 USDG pool funding rescuer/executor bounties (sourced from the
    ///      mint fee). EXCLUDED from `_availableUsdg`: it is neither holder
    ///      equity nor redeemer collateral. Bounties are paid only from here,
    ///      never from the L2 leaf. Admin-withdrawable via `withdrawFees`.
    uint256 public feePoolUsdg;

    // ------------------------------------------------------------ events
    event GenesisSettled(uint256 usdgForwarded, uint48 accountIndex, uint256 deadShares);
    event NAVProven(uint64 indexed batchNumber, uint256 navPerToken, int256 equity6, uint256 supply);
    event MintRequested(uint256 indexed requestId, address indexed sender, address indexed receiver, uint256 usdgIn);
    event RedeemRequested(
        uint256 indexed requestId, address indexed sender, address indexed receiver, uint256 tokensIn
    );
    event RequestSettled(uint256 indexed requestId, uint256 amountOut, uint256 navPerToken);
    event Claimed(uint256 indexed requestId, address indexed receiver, uint256 amountOut);
    event DepositForwarded(uint256 usdgAmount);
    event WithdrawInitiated(uint64 baseAmount);
    event Swept(uint128 amount);
    event RedeemReduce(uint48 baseAmount, uint32 price, uint256 wantNotional6);
    event WithdrawClamped(uint256 wantedUsdg, uint256 sentUsdg);
    event Rebalanced(
        uint64 indexed batchNumber,
        uint256 leverage1e18,
        bool infinite,
        uint48 baseAmount,
        uint32 price,
        uint8 isAsk,
        uint64 serial
    );
    event RebalanceOpConfirmed(uint64 clearedAtBatch);
    event LeaseAcquired(
        address indexed lessee,
        bytes pubKey,
        uint256 leverage1e18,
        bytes32 stateRoot,
        uint256 bond,
        uint64 leaseStartBatch,
        uint64 leaseExpiryBatch
    );
    /// @dev v5.3: the key was parked and the divergence snapshot recorded. The
    ///      window runs to `parkAnchorBatch + challengeBatches`.
    event KeyParked(
        address indexed lessee, uint64 anchorBatch, int128 positionSize, uint256 leverage1e18, uint64 deadlineBatch
    );
    /// @dev v5.3: bond slashed. reason: 1 = divergence, 2 = foreign position,
    ///      3 = out-of-band at expiry.
    event BondSlashed(address indexed lessee, uint256 amount, uint8 reason);
    event PositionDiverged(address indexed lessee, uint64 batchNumber, int128 snapshotSize, int256 provenSize);
    event BondReleased(address indexed lessee, uint256 amount);
    event LeaseExpired(address indexed lessee, uint64 batchNumber, uint256 leverage1e18, bool slashed);
    event VaultOrderRecorded(uint64 batchNumber, uint48 baseAmount, uint8 isAsk);
    event SlashDepositForwarded(uint256 amount);
    event MintFeeTaken(uint256 fee);
    event RescuerBountyPaid(address indexed rescuer, uint256 amount);
    event ExecutorBountyPaid(address indexed lessee, uint256 amount);
    event FeesWithdrawn(address indexed to, uint256 amount);
    // v5.3.3
    event CapRaised(uint256 oldCap, uint256 newCap);
    event ForceUnwound(uint32 closePrice, uint64 withdrawAmount6);
    event UnwoundRedemption(address indexed holder, uint256 tokens, uint256 payout);
    event ForeignPositionChallenged(address indexed lessee, uint16 market, int256 positionSize, uint64 batchNumber);
    event ForeignPositionClosed(uint16 market, int256 positionSize, uint32 price, uint8 isAsk, uint64 serial);

    // ------------------------------------------------------------ errors
    error AccountNotOpened();
    error AccountAlreadyOpened();
    error GenesisTooSmall(uint256 forwarded, uint256 minimum);
    error ZeroAmount();
    error InvalidNav();
    error ProofNotRecent(uint64 batchNumber, uint64 committedHead);
    error AnchorPredatesBridgeOps(uint64 batchNumber, uint64 clearedAtBatch);
    error ProofNotNewer(uint64 batchNumber, uint64 lastProven);
    error BridgeOpsInFlight(uint64 committed, uint64 required);
    error NonPositiveEquity(int256 equity6);
    error NotSettled();
    error SettlesToZero();
    error LeverageInBand(uint256 leverage1e18);
    error RebalanceInFlight(uint64 committed, uint64 required);
    error AnchorPredatesRebalance(uint64 batchNumber, uint64 clearedAtBatch);
    error ShortPosition(int256 positionSize);
    error OrderTooSmall(uint256 wantNotional6, uint256 minNotional6);
    error AmountExceedsUint48(uint256 baseAmount);
    error PriceExceedsUint32(uint256 price);
    error ZeroMarkPrice();
    error AmountExceedsUint64();
    error InvalidBand();
    error InvalidConfig();
    error InsufficientPayoutBalance();
    error WrongKeyState(KeyState current);
    error LeverageNotInBand(uint256 leverage1e18, bool infinite);
    error InvalidParkKey();
    error ChallengeWindowClosed(uint64 batchNumber, uint64 deadlineBatch);
    // v5.2 / v5.2.1 (ForeignPositionPresent removed: the precise library
    // errors UnclearedForeignBucket / ForeignPositionInBucket surface instead)
    error NoForeignPosition();
    error NoLesseeToSlash();
    // v5.3
    error InsufficientBond();
    error ChallengeWindowOpen(uint64 head, uint64 deadlineBatch);
    error KeyChangeNotCommitted(uint64 committed, uint64 required);
    error NoOpenPark();
    error AnchorNotAfterPark(uint64 batchNumber, uint64 parkAnchor);
    error AnchorPastLiabilityCap(uint64 batchNumber, uint64 cap);
    error NoDivergence(int256 provenSize, int128 snapshotSize);
    error LeaseNotExpired(uint64 head, uint64 expiryBatch);
    error NotLessee(address caller);
    // v5.3.3
    error NotAdmin(address caller);
    error NotUnwound();
    error VaultUnwound();
    error CapNotRaised(uint256 newCap, uint256 currentCap);
    // v5.3.1
    error EquityCapExceeded(uint256 projectedEquity6, uint256 cap6);

    constructor(
        IERC20 usdg_,
        ILighterBridge bridge_,
        uint16 assetIndex_,
        uint8 routeType_,
        VaultConfig memory cfg,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        if (cfg.bandLo1e18 > cfg.bandHi1e18) revert InvalidBand();
        if (cfg.maxSlippageBps >= 10000) revert InvalidConfig();
        if (cfg.exitHaircutBps > 1000) revert InvalidConfig();
        if (
            cfg.bondBps >= 10000 || cfg.mintFeeBps >= 10000 || cfg.rescuerBountyBps >= 10000
                || cfg.executorBountyBps >= 10000
        ) {
            revert InvalidConfig();
        }
        // A nonzero cap below the genesis minimum could never bootstrap.
        if (cfg.equityCapUsdg != 0 && cfg.equityCapUsdg < MIN_GENESIS_USDG) revert InvalidConfig();
        if (cfg.parkKey.length == 0 || _isAllZero(cfg.parkKey)) revert InvalidParkKey();
        uint256 target = cfg.targetLeverage1e18;
        if (target == 0) {
            target = (cfg.bandLo1e18 + cfg.bandHi1e18) / 2;
        } else if (target < cfg.bandLo1e18 || target > cfg.bandHi1e18) {
            revert InvalidConfig();
        }
        usdg = usdg_;
        bridge = bridge_;
        assetIndex = assetIndex_;
        routeType = routeType_;
        verifier = cfg.verifier;
        targetMarket = cfg.targetMarket;
        sizeDecimals = cfg.sizeDecimals;
        priceDecimals = cfg.priceDecimals;
        bandLo1e18 = cfg.bandLo1e18;
        bandHi1e18 = cfg.bandHi1e18;
        targetLeverage1e18 = target;
        maxSlippageBps = cfg.maxSlippageBps;
        exitHaircutBps = cfg.exitHaircutBps;
        minOrderNotional6 = cfg.minOrderNotional6;
        expectedL1Owner = cfg.expectedL1Owner == address(0) ? address(this) : cfg.expectedL1Owner;
        apiKeyIndex = cfg.apiKeyIndex;
        parkPubKey = cfg.parkKey;
        uint64 tc = cfg.challengeBatches == 0 ? DEFAULT_CHALLENGE_BATCHES : cfg.challengeBatches;
        challengeBatches = tc;
        executionBatches = cfg.executionBatches == 0 ? DEFAULT_EXECUTION_BATCHES : cfg.executionBatches;
        // v5.3: a challenge anchored at parkAnchor+1 may be submitted up to T_c
        // batches later; the verifier rejects any anchor older than
        // `freshnessBatches` behind head. If freshness < T_c the window is
        // silently truncated — deploy a verifier sized for the window.
        if (cfg.verifier.freshnessBatches() < tc) revert InvalidConfig();
        bondBps = cfg.bondBps;
        equityCapUsdg = cfg.equityCapUsdg;
        admin = cfg.admin == address(0) ? msg.sender : cfg.admin;
        mintFeeBps = cfg.mintFeeBps;
        rescuerBountyBps = cfg.rescuerBountyBps;
        executorBountyBps = cfg.executorBountyBps;
        liabilityAnchorCap = type(uint64).max;
    }

    // ========================================================================
    // Genesis (permissionless account bootstrap)
    // ========================================================================

    /// @notice Settles the genesis round: before the Lighter account exists
    ///         there is no leaf to prove and supply is zero, so every pending
    ///         mint prices at exactly 1.0 — no state proof is meaningful and
    ///         no stale-price MEV is possible against a constant price. Mints
    ///         the dead shares, settles pending mints FIFO at 1.0, and
    ///         forwards the aggregate deposit — which CREATES the vault's
    ///         Lighter account (first deposit is account creation).
    ///
    ///         The follow-up `proveState` is automatically held back until
    ///         the genesis deposit is committed on L2 (the in-flight guard),
    ///         i.e. until the account leaf provably exists.
    function settleGenesis(uint256 maxSettle) external whenNotPaused {
        if (accountOpened) revert AccountAlreadyOpened();
        uint256 escrowBefore = escrowedMintUsdg;
        _mint(DEAD_ADDRESS, DEAD_SHARES);
        // Pre-genesis requests are mints by construction (redeems need
        // tokens); eligibility is waived — 1.0 is constant for the round.
        // Empty facts: no account leaf exists yet, no reduce is possible.
        LighterProof.AccountFacts memory f;
        _settle(1e6, type(uint64).max, maxSettle, f, 0);
        uint256 forwarded = escrowBefore - escrowedMintUsdg;
        if (forwarded < MIN_GENESIS_USDG) revert GenesisTooSmall(forwarded, MIN_GENESIS_USDG);
        accountOpened = true;
        syncAccountIndex();
        emit GenesisSettled(forwarded, accountIndex, DEAD_SHARES);
    }

    /// @notice Re-reads the account index from the bridge. Separate + permissionless
    ///         in case index assignment turns out to be asynchronous.
    function syncAccountIndex() public {
        accountIndex = bridge.addressToAccountIndex(address(this));
    }

    // ========================================================================
    // Mint / redeem request queue (unchanged from v2)
    // ========================================================================

    /// @notice Escrows USDG; tokens are minted to `receiver` at the next posted
    ///         NAV. v5.3: a `mintFeeBps` skim is taken off the top into the L1
    ///         fee pool — it never enters the escrowed principal, so it does not
    ///         dilute shares or touch NAV. The receiver is priced on the net.
    function requestMint(uint256 usdgIn, address receiver) external whenNotPaused returns (uint256 requestId) {
        if (usdgIn == 0) revert ZeroAmount();
        uint256 fee = mintFeeBps == 0 ? 0 : (usdgIn * mintFeeBps) / 10000;
        uint256 principal = usdgIn - fee;
        if (principal == 0) revert ZeroAmount();
        // v5.3.1: cap the vault's size. Projected equity = last proven equity
        // (nav x supply) + escrow already queued toward the leaf + slash
        // deposits in flight + this principal (the fee accrues to the pool,
        // not equity). Counting the escrow means many small requests cannot
        // collectively pass the cap; proven-equity (PnL) growth past the cap
        // blocks new mints the same way. Redemptions are never capped.
        if (equityCapUsdg != 0) {
            uint256 projected =
                (navPerToken * totalSupply()) / 1e18 + escrowedMintUsdg + pendingSlashDeposit + principal;
            if (projected > equityCapUsdg) revert EquityCapExceeded(projected, equityCapUsdg);
        }
        usdg.safeTransferFrom(msg.sender, address(this), usdgIn);
        if (fee > 0) {
            feePoolUsdg += fee;
            emit MintFeeTaken(fee);
        }
        escrowedMintUsdg += principal;
        requestId = _enqueue(RequestKind.Mint, receiver, principal);
        emit MintRequested(requestId, msg.sender, receiver, principal);
    }

    /// @notice Escrows vault tokens; a USDG payout to `receiver` is queued at the
    ///         next posted NAV (payout claimable after bridge withdrawal finalizes).
    function requestRedeem(uint256 tokensIn, address receiver) external whenNotPaused returns (uint256 requestId) {
        if (tokensIn == 0) revert ZeroAmount();
        _transfer(msg.sender, address(this), tokensIn); // burned at settlement
        requestId = _enqueue(RequestKind.Redeem, receiver, tokensIn);
        emit RedeemRequested(requestId, msg.sender, receiver, tokensIn);
    }

    /// @notice Claims the output of a settled request.
    function claim(uint256 requestId) external whenNotPaused returns (uint256 amountOut) {
        Request storage req = requests[requestId];
        if (req.status != RequestStatus.Settled) revert NotSettled();
        amountOut = req.amountOut;
        req.status = RequestStatus.Claimed; // effects before interactions

        if (req.kind == RequestKind.Mint) {
            // Minted to the vault at settlement (so NAV's supply term is
            // exact); the claim just delivers them.
            _transfer(address(this), req.receiver, amountOut);
        } else {
            // Redeemers must never be paid out of unsettled mint escrow.
            if (_availableUsdg() < amountOut) revert InsufficientPayoutBalance();
            owedRedeemUsdg -= amountOut;
            usdg.safeTransfer(req.receiver, amountOut);
        }
        emit Claimed(requestId, req.receiver, amountOut);
    }

    function requestStatus(uint256 requestId)
        external
        view
        returns (
            RequestKind kind,
            RequestStatus status,
            address receiver,
            uint256 amountIn,
            uint256 amountOut,
            bool claimable
        )
    {
        Request storage req = requests[requestId];
        kind = req.kind;
        status = req.status;
        receiver = req.receiver;
        amountIn = req.amountIn;
        amountOut = req.amountOut;
        claimable = status == RequestStatus.Settled && (kind == RequestKind.Mint || _availableUsdg() >= req.amountOut);
    }

    // ========================================================================
    // Proof-based settlement (unchanged from v2)
    // ========================================================================

    /// @notice Confirms that the last settlement's bridge ops are committed
    ///         on L2, recording the head batch at confirmation: any proof
    ///         anchored at or after it reflects the ops in its equity.
    ///         Permissionless; the keeper cranks it the batch after a
    ///         settlement so the next round can anchor at head-1.
    function confirmBridgeOps() public {
        if (lastBridgeOpSerial == 0) return;
        if (bridge.committedPriorityRequestCount() >= lastBridgeOpSerial) {
            bridgeOpsClearedAtBatch = bridge.committedBatchesCount();
            lastBridgeOpSerial = 0;
        }
    }

    /// @notice Permissionless settlement crank: proves the account state at
    ///         the committed head (or head-1), derives NAV = E / supply from
    ///         it, and settles all eligible queued requests FIFO at that NAV.
    ///
    ///         Eligibility is the anti-MEV rule: a request settles only at a
    ///         proof whose batch strictly follows the request's acceptance —
    ///         a price nobody could know at request time.
    ///
    ///         head-1 is accepted because the head batch's StoredBatchInfo
    ///         preimage only becomes extractable from calldata when the NEXT
    ///         batch commits (it rides the next commitBatch as
    ///         `lastStoredBatch`); a keeper therefore proves batch N the
    ///         moment N+1 lands. Anchor soundness for in-flight bridge ops is
    ///         enforced via `confirmBridgeOps` + `bridgeOpsClearedAtBatch`.
    ///
    ///         A pending rebalance order (`rebalanceOpSerial != 0`) is
    ///         deliberately NOT a blocker: an unfilled order changes nothing,
    ///         and a fill moves balance and position atomically inside the
    ///         leaf — NAV at any committed root is exact either way.
    /// @param maxSettle Bound on requests settled this call (gas valve);
    ///        pass type(uint256).max normally.
    /// @param clearings v5.2.1 — one opening per bucket flagged in
    ///        `possiblyForeignMask`, each proving that bucket holds NO position
    ///        (all 16 sizes zero). Pass an empty array for a clean account.
    ///        A flagged bucket may be flagged only because of
    ///        `funding_prefix_sum` residue left by a CLOSED position, which
    ///        never clears — refusing on the flag alone would permanently brick
    ///        settlement, so a clearing proof is required instead.
    function proveState(
        LighterProof.AccountWitness calldata w,
        StoredBatchInfo calldata batch,
        uint256 maxSettle,
        LighterProof.ForeignClearing[] calldata clearings
    ) external whenNotPaused {
        // CHEAP guards first: when concurrent keepers race to prove the same
        // batch, the losers must revert BEFORE paying for the ~15M-gas
        // verification, not after.
        if (!accountOpened) revert AccountNotOpened();
        uint64 head = bridge.committedBatchesCount();
        if (batch.batchNumber > head || batch.batchNumber + 1 < head) {
            revert ProofNotRecent(batch.batchNumber, head);
        }
        if (batch.batchNumber <= lastProvenBatch) {
            revert ProofNotNewer(batch.batchNumber, lastProvenBatch);
        }
        confirmBridgeOps();
        if (lastBridgeOpSerial != 0) {
            revert BridgeOpsInFlight(bridge.committedPriorityRequestCount(), lastBridgeOpSerial);
        }
        if (batch.batchNumber < bridgeOpsClearedAtBatch) {
            revert AnchorPredatesBridgeOps(batch.batchNumber, bridgeOpsClearedAtBatch);
        }

        LighterProof.AccountFacts memory f =
            verifier.verifyAccount(w, batch, accountIndex, expectedL1Owner, targetMarket);
        // v5.2.1: a LIVE foreign position is not priced by _trueEquity6 (the
        // trie nets its entry cost out of balances[3] while its mark value is
        // never added back), so NAV would be UNDERSTATED. Require proof that
        // every flagged bucket is position-free rather than refusing on the
        // flag alone — the flag also fires on funding residue from a closed
        // position, which never clears.
        LighterProof.requireForeignClear(w, f.possiblyForeignMask, clearings);

        // Owed money that never left the leaf (a nooped redemption
        // withdrawal): it belongs to burned shares, so it is deducted from
        // equity below AND re-withdrawn by _settle. 0 while the last
        // withdrawal is still in transit — see owedShortfall.
        uint256 shortfall = owedShortfall();

        // NAV = proven TRUE equity / supply (cash + marked position value —
        // the trie nets entry cost out of the cash balance). In production
        // supply can never be 0 here (settleGenesis minted the dead shares
        // before accountOpened was set); the 1.0 branch survives only for
        // fork-harness vaults attached by writing accountIndex storage
        // directly (v5.4 removed emergencySetAccountIndex). Fail closed
        // on non-positive equity with supply outstanding.
        uint256 supply = totalSupply();
        uint256 nav;
        if (supply == 0) {
            nav = 1e6;
        } else {
            int256 equity = _trueEquity6(f.usdgBalance, f.positionSize, f.markPrice);
            if (equity <= 0) revert NonPositiveEquity(equity);
            // Saturate the shortfall deduction: a legacy mispriced round
            // (owed > realizable, pre-haircut) must degrade NAV toward zero,
            // never wedge the crank with NonPositiveEquity — proveState is
            // also the retry vehicle that drains what IS available.
            uint256 ded = shortfall;
            if (ded >= uint256(equity)) ded = uint256(equity) - 1;
            equity -= int256(ded);
            nav = (uint256(equity) * 1e18) / supply;
            if (nav == 0) revert InvalidNav();
        }
        navPerToken = nav;
        lastNavTimestamp = block.timestamp;
        lastProvenBatch = batch.batchNumber;

        _settle(nav, batch.batchNumber, maxSettle, f, shortfall);
        emit NAVProven(batch.batchNumber, nav, f.usdgBalance, supply);
    }

    /// @dev FIFO settlement at `nav`, stopping at the first request accepted
    ///      at or after the proven batch (FIFO order makes acceptedAtBatch
    ///      non-decreasing, so a single break is exact).
    /// @param f Proven facts for the reduce-before-withdraw leg (empty at
    ///        genesis — no account leaf exists, no reduce possible).
    /// @param extraWithdraw6 Owed USDG whose earlier withdrawal was nooped
    ///        (proveState's `shortfall`) — re-withdrawn with this round.
    function _settle(
        uint256 nav,
        uint64 provenBatch,
        uint256 maxSettle,
        LighterProof.AccountFacts memory f,
        uint256 extraWithdraw6
    ) internal {
        uint256 id = nextSettleId;
        uint256 mintUsdgToForward;
        uint256 redeemUsdgToWithdraw;
        uint256 settled;

        while (id < nextRequestId && settled < maxSettle) {
            Request storage req = requests[id];
            if (req.acceptedAtBatch >= provenBatch) break; // anti-MEV rule
            uint256 amountOut;
            if (req.kind == RequestKind.Mint) {
                amountOut = (uint256(req.amountIn) * 1e18) / nav; // rounds down
                if (amountOut == 0) revert SettlesToZero();
                // Mint to the vault NOW: settled-but-unclaimed tokens must be
                // part of totalSupply, or the next NAV = E/n would overstate.
                _mint(address(this), amountOut);
                mintUsdgToForward += req.amountIn;
            } else {
                amountOut = (uint256(req.amountIn) * nav) / 1e18; // rounds down
                // Realization haircut: price the exit below the anchor NAV so
                // owed can never exceed what the reduce actually frees.
                amountOut = (amountOut * (10000 - uint256(exitHaircutBps))) / 10000;
                _burn(address(this), req.amountIn);
                redeemUsdgToWithdraw += amountOut;
                owedRedeemUsdg += amountOut;
            }
            if (amountOut == 0) revert SettlesToZero();
            req.amountOut = uint128(amountOut);
            req.status = RequestStatus.Settled;
            emit RequestSettled(id, amountOut, nav);
            unchecked {
                ++id;
                ++settled;
            }
        }
        nextSettleId = id;

        // One aggregated bridge deposit / reduce / withdraw per settlement
        // round, in FIFO-favorable order: the deposit lands first (adds
        // collateral), then the reduce frees margin, then the withdrawal
        // executes against freed collateral.
        uint256 totalWithdraw = redeemUsdgToWithdraw + extraWithdraw6;
        bool sentOps;
        // v5.3: a slashed bond becomes vault equity only by reaching the L2
        // leaf (NAV is proven L2 equity / supply). Fold it into this round's
        // deposit so it rides the existing lastBridgeOpSerial bookkeeping — a
        // bare bridge.deposit inside challenge() would race proveState. No
        // shares are minted against it, so NAV rises for existing holders.
        uint256 slash = pendingSlashDeposit;
        uint256 toDeposit = mintUsdgToForward + slash;
        if (toDeposit > 0) {
            if (mintUsdgToForward > 0) escrowedMintUsdg -= mintUsdgToForward;
            if (slash > 0) {
                pendingSlashDeposit = 0;
                emit SlashDepositForwarded(slash);
            }
            usdg.forceApprove(address(bridge), toDeposit);
            bridge.deposit(address(this), assetIndex, routeType, toDeposit);
            emit DepositForwarded(toDeposit);
            sentOps = true;
        }
        // Reduce-before-withdraw: at target leverage nearly all collateral is
        // margin, so a bare withdrawal is silently nooped by the L2. Selling
        // down to targetLeverage on the post-withdrawal equity frees it
        // (λ·imf < 1 post-bootstrap). Long-only: a short (never ours) or a
        // flat account skips the reduce.
        uint256 reduceWant6;
        if (totalWithdraw > 0 && f.positionSize > 0 && f.markPrice > 0) {
            (uint48 rba, uint32 rprice, uint256 want6, bool needed) = _redeemReduce(f, totalWithdraw);
            if (needed) {
                reduceWant6 = want6;
                bridge.createOrder(accountIndex, targetMarket, rba, rprice, 1, ORDER_TYPE_MARKET);
                _recordVaultOrder(rba, 1); // v5.3: sell — feeds the challenge allowance
                emit RedeemReduce(rba, rprice, want6);
                sentOps = true;
            }
        }
        // Clamp the withdrawal to what the leaf can provably deliver: proven
        // equity minus the realization headroom of the reduce that precedes
        // it in the queue (slippage clamp + fee margin). The circuit noops
        // (never partially fills) an over-sized withdrawal, so sending more
        // than is realizable strands the whole amount — the full-exit
        // gap. Binds only in pathological rounds: the exit haircut
        // keeps the normal path under the cap. Residual owed stays booked and
        // is retried (or topped up) later.
        if (totalWithdraw > 0 && f.markPrice > 0) {
            int256 e6 = _trueEquity6(f.usdgBalance, f.positionSize, f.markPrice);
            uint256 headroom = (reduceWant6 * (uint256(maxSlippageBps) + 10)) / 10000;
            uint256 cap = e6 > 0 && uint256(e6) > headroom ? uint256(e6) - headroom : 0;
            if (totalWithdraw > cap) {
                emit WithdrawClamped(totalWithdraw, cap);
                totalWithdraw = cap;
            }
        }
        bool withdrew;
        if (totalWithdraw > 0) {
            if (totalWithdraw > type(uint64).max) revert AmountExceedsUint64();
            bridge.withdraw(accountIndex, assetIndex, routeType, uint64(totalWithdraw));
            emit WithdrawInitiated(uint64(totalWithdraw));
            sentOps = true;
            withdrew = true;
        }
        if (sentOps) {
            // Serial of our newest op; future proofs wait until it commits.
            uint64 serial = bridge.executedPriorityRequestCount() + bridge.openPriorityRequestCount();
            lastBridgeOpSerial = serial;
            // The withdraw is the last op sent, so `serial` is exactly its
            // position in the all-time ordering.
            if (withdrew) lastRedeemWithdrawSerial = serial;
        }
    }

    /// @dev Sell order that frees `withdraw6` of collateral: reduces notional
    ///      to targetLeverage on the post-withdrawal equity, so the forced
    ///      withdrawal queued right after it clears the venue's margin check.
    ///      Over-reduction (min-notional clamp, mark drift) is benign — the
    ///      rebalance loop buys it back. `needed` is false when the position
    ///      is already at or under the post-withdrawal target.
    function _redeemReduce(LighterProof.AccountFacts memory f, uint256 withdraw6)
        internal
        view
        returns (uint48 baseAmount, uint32 price, uint256 want6, bool needed)
    {
        uint256 n6 = _notional6(f.positionSize, f.markPrice);
        int256 remaining = _trueEquity6(f.usdgBalance, f.positionSize, f.markPrice) - int256(withdraw6);
        uint256 targetN6 = remaining > 0 ? (targetLeverage1e18 * uint256(remaining)) / 1e18 : 0;
        if (n6 <= targetN6) return (0, 0, 0, false);
        want6 = n6 - targetN6;
        if (want6 < minOrderNotional6) want6 = minOrderNotional6;
        price = _clampPrice(f.markPrice, true);
        if (want6 >= n6) return (0, price, want6, true); // full close (baseAmount 0)
        uint256 num = want6 * (10 ** (uint256(sizeDecimals) + uint256(priceDecimals)));
        uint256 den = f.markPrice * 1e6;
        uint256 ba = (num + den - 1) / den; // ceil: venue notional check can't reject
        if (ba >= uint256(f.positionSize)) return (0, price, want6, true); // ceil-dust: full close
        if (ba > type(uint48).max) revert AmountExceedsUint48(ba);
        return (uint48(ba), price, want6, true);
    }

    /// @notice Owed redemption USDG that is provably still in the account
    ///         leaf — i.e. a withdrawal the L2 silently nooped. Every owed
    ///         dollar is on L1 observably in one of three places: the bridge
    ///         pending balance (withdrawal executed, not swept), the vault's
    ///         free balance (swept, unclaimed), or nowhere-yet (still in the
    ///         leaf, or in transit). Returns 0 while the newest withdrawal is
    ///         in transit (committed on L2 — where the leaf already dropped —
    ///         but not yet EXECUTED on L1, so the pending credit hasn't
    ///         landed): deducting then would double-count the successful
    ///         case. Once `executedPriorityRequestCount` passes the serial, a
    ///         successful withdrawal has credited the pending balance, so any
    ///         residue is leaf-resident owed money: deduct it from NAV and
    ///         re-withdraw it.
    function owedShortfall() public view returns (uint256) {
        uint256 owed = owedRedeemUsdg;
        if (owed == 0) return 0;
        if (bridge.executedPriorityRequestCount() < lastRedeemWithdrawSerial) return 0;
        uint256 delivered = uint256(bridge.getPendingBalance(address(this), assetIndex)) + _availableUsdg();
        return owed > delivered ? owed - delivered : 0;
    }

    /// @notice Pulls finalized bridge withdrawals into the vault for payout.
    ///         Permissionless: it can only move funds bridge->vault.
    function sweepWithdrawals(uint128 amount) external {
        bridge.withdrawPendingBalance(address(this), assetIndex, amount);
        emit Swept(amount);
    }

    // ========================================================================
    // Proof-gated forced-order rebalancing (the keyless backstop)
    // ========================================================================

    /// @notice Confirms that the last forced order is committed on L2,
    ///         recording the head batch at confirmation: any anchor at or
    ///         after it reflects the order's effect (fill, partial, or noop).
    ///         Permissionless crank, mirror of `confirmBridgeOps`.
    function confirmRebalanceOp() public {
        if (rebalanceOpSerial == 0) return;
        if (bridge.committedPriorityRequestCount() >= rebalanceOpSerial) {
            rebalanceClearedAtBatch = bridge.committedBatchesCount();
            rebalanceOpSerial = 0;
            emit RebalanceOpConfirmed(rebalanceClearedAtBatch);
        }
    }

    /// @notice Permissionless rebalance crank: proves the account state at
    ///         the committed head (or head-1); if leverage is OUTSIDE the
    ///         band, computes the corrective MARKET order on-chain
    ///         (dN6 = λ·E − N, price clamped to mark ± maxSlippageBps) and
    ///         submits it through the bridge's priority queue. The caller
    ///         supplies no trading parameters — the proof is the gate and
    ///         the witness is the sole input.
    ///
    ///         The L2 gives no fill feedback on L1: a rejected order is a
    ///         silent noop. The next provable anchor then still shows
    ///         out-of-band leverage and this function fires again — retries
    ///         are the intended convergence loop, one commit cycle each.
    function rebalance(LighterProof.AccountWitness calldata w, StoredBatchInfo calldata batch) external whenNotPaused {
        // CHEAP guards first (racing executors revert before the ~15M-gas
        // verification), mirroring proveState's ordering.
        if (!accountOpened) revert AccountNotOpened();
        uint64 head = bridge.committedBatchesCount();
        if (batch.batchNumber > head || batch.batchNumber + 1 < head) {
            revert ProofNotRecent(batch.batchNumber, head);
        }
        // Settlement ops in flight change equity, and the priority queue is
        // FIFO — an order enqueued now would execute AFTER them while being
        // sized from pre-op proven equity. Block until they are committed
        // and the anchor reflects them.
        confirmBridgeOps();
        if (lastBridgeOpSerial != 0) {
            revert BridgeOpsInFlight(bridge.committedPriorityRequestCount(), lastBridgeOpSerial);
        }
        if (batch.batchNumber < bridgeOpsClearedAtBatch) {
            revert AnchorPredatesBridgeOps(batch.batchNumber, bridgeOpsClearedAtBatch);
        }
        // Our own previous order must be committed AND reflected in the
        // anchor — otherwise this order double-corrects.
        confirmRebalanceOp();
        if (rebalanceOpSerial != 0) {
            revert RebalanceInFlight(bridge.committedPriorityRequestCount(), rebalanceOpSerial);
        }
        if (batch.batchNumber < rebalanceClearedAtBatch) {
            revert AnchorPredatesRebalance(batch.batchNumber, rebalanceClearedAtBatch);
        }

        LighterProof.AccountFacts memory f =
            verifier.verifyAccount(w, batch, accountIndex, expectedL1Owner, targetMarket);

        (uint256 l, bool infinite) = _leverage1e18(f.usdgBalance, f.positionSize, f.markPrice);
        if (!infinite && l >= bandLo1e18 && l <= bandHi1e18) revert LeverageInBand(l);
        // Long-only mandate: a short position is never ours to manage.
        if (f.positionSize < 0) revert ShortPosition(f.positionSize);
        if (f.markPrice == 0) revert ZeroMarkPrice();

        uint48 baseAmount;
        uint32 price;
        uint8 isAsk;
        if (infinite) {
            // E <= 0 with N > 0: stop-out territory. Full close — baseAmount
            // 0 means "whole position" on the bridge. Harmless if the venue
            // already liquidated (position 0 → L2 noop).
            (baseAmount, price, isAsk) = (0, _clampPrice(f.markPrice, true), 1);
        } else {
            (baseAmount, price, isAsk) = _sizeOrder(f);
        }

        bridge.createOrder(accountIndex, targetMarket, baseAmount, price, isAsk, ORDER_TYPE_MARKET);
        rebalanceOpSerial = bridge.executedPriorityRequestCount() + bridge.openPriorityRequestCount();
        // v5.3: feed the challenge allowance so this order can never manufacture
        // a divergence that slashes an honest parked lessee.
        _recordVaultOrder(baseAmount, isAsk);
        emit Rebalanced(batch.batchNumber, l, infinite, baseAmount, price, isAsk, rebalanceOpSerial);

        // v5.3: pay the keyless backstop's caller from the fee pool (bps of the
        // corrected notional). Throttled to the commit cadence by the one-order
        // -in-flight rebalance lane; capped at the pool balance.
        if (rescuerBountyBps > 0 && feePoolUsdg > 0) {
            uint256 orderN6 = infinite
                ? _notional6(f.positionSize, f.markPrice)
                : _notional6(int256(uint256(baseAmount)), f.markPrice);
            uint256 want = (orderN6 * rescuerBountyBps) / 10000;
            uint256 paid = _payFromPool(msg.sender, want);
            if (paid > 0) emit RescuerBountyPaid(msg.sender, paid);
        }
    }

    /// @dev Corrective order from proven facts. Precondition: leverage finite
    ///      and out of band, position >= 0, mark > 0 (checked by caller), so
    ///      E > 0 and dN6 != 0 (target lies inside the closed band:
    ///      l < lo <= λ ⇒ N < λE ⇒ buy; l > hi >= λ ⇒ sell).
    ///
    ///      Overflow: |balances| < 2^96 bounds e6 and n6 below 2^97;
    ///      λ·e6 < 2^62·2^97; want6·10^(sd+pd) stays far under 2^256.
    function _sizeOrder(LighterProof.AccountFacts memory f)
        internal
        view
        returns (uint48 baseAmount, uint32 price, uint8 isAsk)
    {
        uint256 n6 = _notional6(f.positionSize, f.markPrice);
        int256 e6 = _trueEquity6(f.usdgBalance, f.positionSize, f.markPrice);
        // Reachable only on a FLAT account with non-positive cash (any open
        // position with E <= 0 reads as infinite and full-closes instead):
        // nothing sensible to size — no equity to lever, nothing to sell.
        if (e6 <= 0) revert NonPositiveEquity(e6);

        int256 dN6 = int256((targetLeverage1e18 * uint256(e6)) / 1e18) - int256(n6);
        isAsk = dN6 < 0 ? 1 : 0;
        uint256 want6 = dN6 < 0 ? uint256(-dN6) : uint256(dN6);

        // Venue min-notional: clamp UP when the overshoot still lands inside
        // the band (the wedge-prevention rule validated live in v2.7), else
        // refuse — a sub-minimum order would be rejected at matching anyway.
        if (want6 < minOrderNotional6) {
            uint256 newN6;
            if (isAsk == 1) {
                if (n6 < minOrderNotional6) revert OrderTooSmall(want6, minOrderNotional6);
                newN6 = n6 - minOrderNotional6;
            } else {
                newN6 = n6 + minOrderNotional6;
            }
            uint256 newL = (newN6 * 1e18) / uint256(e6);
            if (newL < bandLo1e18 || newL > bandHi1e18) {
                revert OrderTooSmall(want6, minOrderNotional6);
            }
            want6 = minOrderNotional6;
        }

        // want6 [USD 6d] → raw base units: size = want6·10^(sd+pd−6)/mark,
        // as one ceil-div so the venue's own notional check cannot reject on
        // floor rounding; sells then cap at the position so ceil-dust can
        // never flip the account short.
        uint256 num = want6 * (10 ** (uint256(sizeDecimals) + uint256(priceDecimals)));
        uint256 den = f.markPrice * 1e6;
        uint256 ba = (num + den - 1) / den;
        if (isAsk == 1 && ba > uint256(f.positionSize)) ba = uint256(f.positionSize);
        if (ba == 0) revert OrderTooSmall(want6, minOrderNotional6);
        if (ba > type(uint48).max) revert AmountExceedsUint48(ba);
        baseAmount = uint48(ba);
        price = _clampPrice(f.markPrice, isAsk == 1);
    }

    /// @dev Slippage clamp on the forced order's price: buys cap at
    ///      mark·(1+bps) (floor — tighter cap), sells floor at mark·(1−bps)
    ///      (ceil, min 1 — the bridge rejects price 0). Whether the L2
    ///      honors it as a protective limit on MARKET orders is gate (c)/(d)
    ///      territory; if inert, fills take book impact.
    function _clampPrice(uint256 mark, bool sell) internal view returns (uint32) {
        uint256 p;
        if (sell) {
            p = (mark * (10000 - uint256(maxSlippageBps)) + 9999) / 10000;
            if (p == 0) p = 1;
        } else {
            p = (mark * (10000 + uint256(maxSlippageBps))) / 10000;
            if (p > type(uint32).max) revert PriceExceedsUint32(p);
        }
        return uint32(p);
    }

    /// @notice Leverage from a verified witness, exposed for bots/inspection.
    function currentLeverage1e18(LighterProof.AccountWitness calldata w, StoredBatchInfo calldata batch)
        external
        view
        returns (uint256 leverage1e18, bool infinite)
    {
        (leverage1e18, infinite,) = _provenLeverage(w, batch);
    }

    /// @dev Verifies the witness against the committed batch root and computes L.
    function _provenLeverage(LighterProof.AccountWitness calldata w, StoredBatchInfo calldata batch)
        internal
        view
        returns (uint256 l, bool infinite, LighterProof.AccountFacts memory f)
    {
        f = verifier.verifyAccount(w, batch, accountIndex, expectedL1Owner, targetMarket);
        (l, infinite) = _leverage1e18(f.usdgBalance, f.positionSize, f.markPrice);
    }

    /// @dev Position value in 6-decimal USD: |size|·mark·10^(6-sd-pd)
    ///      (or ÷ when sd+pd > 6).
    function _notional6(int256 positionSize, uint256 markPrice) internal view returns (uint256) {
        uint256 absSize = positionSize < 0 ? uint256(-positionSize) : uint256(positionSize);
        uint256 raw = absSize * markPrice; // < 2^96, no overflow
        uint256 dec = uint256(sizeDecimals) + uint256(priceDecimals);
        return dec <= 6 ? raw * (10 ** (6 - dec)) : raw / (10 ** (dec - 6));
    }

    /// @dev TRUE equity: cash balance + signed position value. The trie nets
    ///      the entry cost out of balances[3] when a position opens
    ///      (balance goes negative past cost basis), so cash + marked
    ///      holdings = collateral + unrealized PnL.
    function _trueEquity6(int256 balance6, int256 positionSize, uint256 markPrice) internal view returns (int256) {
        int256 value = int256(_notional6(positionSize, markPrice));
        return balance6 + (positionSize < 0 ? -value : value);
    }

    /// @dev L = N6 * 1e18 / E where E = trueEquity. E ≤ 0 with N > 0 →
    ///      infinite. N = 0 → L = 0.
    function _leverage1e18(int256 balance6, int256 positionSize, uint256 markPrice)
        internal
        view
        returns (uint256 l, bool infinite)
    {
        uint256 n6 = _notional6(positionSize, markPrice);
        if (n6 == 0) return (0, false);
        int256 equity = _trueEquity6(balance6, positionSize, markPrice);
        if (equity <= 0) return (0, true);
        l = (n6 * 1e18) / uint256(equity);
    }

    // ========================================================================
    // Proof-gated key lease (v5.3: bond + position-divergence accountability)
    // ========================================================================

    /// @notice Acquires the trading-key lease and posts the bond. Permissionless
    ///         — the witness is the gate: it must verify against the bridge's
    ///         published root, be recent (head or head-1, an action-sizing
    ///         path), and show leverage OUTSIDE the band (either side).
    ///
    ///         v5.3: instead of LAPSING any open prior liability (the v5.1
    ///         collusion/self-succession hole), a new lease during an open
    ///         challenge window CAPS that liability's challengeable anchor at
    ///         this lease's start batch — evidence from before the new lessee
    ///         held the key stays attributable to the OLD lessee. If the prior
    ///         window has already lapsed, the prior bond is returned here.
    function acquireLease(
        bytes calldata pubKey,
        LighterProof.AccountWitness calldata w,
        StoredBatchInfo calldata batch,
        LighterProof.ForeignClearing[] calldata clearings
    ) external whenNotPaused {
        if (keyState != KeyState.Parked) revert WrongKeyState(keyState);
        if (!accountOpened) revert AccountNotOpened();
        uint64 head = bridge.committedBatchesCount();
        if (batch.batchNumber > head || batch.batchNumber + 1 < head) {
            revert ProofNotRecent(batch.batchNumber, head);
        }
        // Resolve any prior liability: pay it out if its window has lapsed,
        // else cap its challengeable anchor at this lease's start (no lapse,
        // no lockout). Non-reverting — the acquire is never blocked.
        if (parkLessee != address(0)) {
            if (_bondWindowClosed(head)) {
                _payBondOut();
            } else {
                liabilityAnchorCap = head;
            }
        }
        // Cheap bond-affordability pre-check before the ~15M-gas verify. The
        // exact bond is priced on the PROVEN equity below; this estimate uses
        // the last proven NAV, so lessees should approve with margin.
        if (bondBps > 0) {
            uint256 est = estimatedBond();
            if (usdg.allowance(msg.sender, address(this)) < est || usdg.balanceOf(msg.sender) < est) {
                revert InsufficientBond();
            }
        }

        (uint256 l, bool infinite, LighterProof.AccountFacts memory f) = _provenLeverage(w, batch);
        // v5.2.1: a lease may only START from an account with no foreign
        // POSITION (funding residue is fine) — what makes attribution sound.
        LighterProof.requireForeignClear(w, f.possiblyForeignMask, clearings);
        bool outOfBand = infinite || l < bandLo1e18 || l > bandHi1e18;
        if (!outOfBand) revert LeverageInBand(l);

        // v5.3.1: size the bond on the equity the lease is entrusted with —
        // bondBps of the PROVEN true equity at this anchor ("V at lease
        // acquisition" in the pricing model; the anchor lag is the Delta the
        // model already prices). E <= 0 (a stop-out acquire) posts nothing:
        // there is no equity left to indemnify.
        uint256 bond;
        if (bondBps > 0) {
            int256 e6 = _trueEquity6(f.usdgBalance, f.positionSize, f.markPrice);
            if (e6 > 0) bond = (uint256(e6) * bondBps) / 10000;
        }
        if (bond > 0 && (usdg.allowance(msg.sender, address(this)) < bond || usdg.balanceOf(msg.sender) < bond)) {
            revert InsufficientBond();
        }

        keyState = KeyState.Leased; // v5.3: no AcquirePending
        lessee = msg.sender;
        leasedKey = pubKey;
        leaseStartBatch = head;
        leaseBond = bond;
        if (bond > 0) usdg.safeTransferFrom(msg.sender, address(this), bond);
        bridge.changePubKey(accountIndex, apiKeyIndex, pubKey);
        emit LeaseAcquired(msg.sender, pubKey, l, f.stateRoot, bond, head, head + executionBatches);
    }

    /// @notice Parks the key and records the divergence snapshot. LESSEE-ONLY
    ///         while the lease is live (a permissionless park + a bond is a
    ///         griefing weapon — a third party could end the lease on a stale
    ///         in-band anchor mid-trade and start the slash clock). The keyless
    ///         backstop still de-risks throughout; `expireLease` is the
    ///         permissionless force-park after T_E.
    ///
    ///         Requires an IN-BAND proof (catches "left it wrecked"), and — like
    ///         `rebalance` — a CLEAN vault-order lane, so no vault-originated
    ///         order committing after the park anchor can invalidate the
    ///         snapshot. Records (parkLessee, parkAnchorBatch, parkPositionSize)
    ///         and opens the T_c window; the bond stays held.
    function parkKey(
        LighterProof.AccountWitness calldata w,
        StoredBatchInfo calldata batch,
        LighterProof.ForeignClearing[] calldata clearings
    ) external {
        if (keyState != KeyState.Leased) revert WrongKeyState(keyState);
        if (msg.sender != lessee) revert NotLessee(msg.sender);
        uint64 head = bridge.committedBatchesCount();
        if (batch.batchNumber > head || batch.batchNumber + 1 < head) {
            revert ProofNotRecent(batch.batchNumber, head);
        }
        // A park anchor must be at least as trustworthy as a rebalance anchor:
        // both vault lanes clear and the anchor postdates every vault order, so
        // resetting the post-park order allowances to 0 below is sound.
        _requireCleanVaultLanes(batch.batchNumber);
        // Free the liability slot (reverts ChallengeWindowOpen if a PRIOR
        // capped window is still open — the one-slot constraint; T_E > T_c
        // makes this non-binding in the common path).
        _releaseBond();

        (uint256 l, bool infinite, LighterProof.AccountFacts memory f) = _provenLeverage(w, batch);
        LighterProof.requireForeignClear(w, f.possiblyForeignMask, clearings);
        bool inBand = !infinite && l >= bandLo1e18 && l <= bandHi1e18;
        if (!inBand) revert LeverageNotInBand(l, infinite);

        address who = lessee;
        keyState = KeyState.Parked;
        lessee = address(0);
        delete leasedKey;
        // Q-A1: flush the book with the key, then park to K∅. changePubKey is
        // the LAST op enqueued, so _openPark reads its serial as parkKeySerial.
        bridge.cancelAllOrders(accountIndex);
        bridge.changePubKey(accountIndex, apiKeyIndex, parkPubKey);
        _openPark(who, batch.batchNumber, f.positionSize, l);
    }

    /// @notice Permissionless divergence challenge. Proves that at a batch
    ///         strictly after the park anchor and within T_c the target-market
    ///         position DIVERGED from the recorded snapshot (outside the band
    ///         the vault's own orders can account for) → slash the bond.
    ///
    ///         Divergence, not out-of-band leverage, is the predicate: a
    ///         position only moves when someone ACTS, so one snapshot is sound
    ///         evidence, whereas leverage moves with PRICE and attributes
    ///         nothing. Takes NO clearings and never calls `requireForeignClear`
    ///         — a lessee opening a foreign position must not become
    ///         unchallengeable (handled by `challengeForeignPosition`).
    ///
    ///         No head/head-1 bound: this records guilt, sizes no action, and
    ///         the anchor is already pinned below (park anchor), above (T_c) and
    ///         by the vault-order floor.
    function challenge(LighterProof.AccountWitness calldata w, StoredBatchInfo calldata batch) external {
        if (parkLessee == address(0)) revert NoOpenPark();
        if (batch.batchNumber <= parkAnchorBatch) revert AnchorNotAfterPark(batch.batchNumber, parkAnchorBatch);
        uint64 deadline = parkAnchorBatch + challengeBatches;
        if (batch.batchNumber > deadline) revert ChallengeWindowClosed(batch.batchNumber, deadline);
        if (batch.batchNumber > liabilityAnchorCap) {
            revert AnchorPastLiabilityCap(batch.batchNumber, liabilityAnchorCap);
        }
        LighterProof.AccountFacts memory f =
            verifier.verifyAccount(w, batch, accountIndex, expectedL1Owner, targetMarket);
        // Divergence band: the snapshot widened by the vault's OWN post-park
        // order quantities, so vault-originated fills can never false-slash.
        // A full-close (baseAmount==0) vault order is an unbounded decrease, so
        // the decrease side is then unbounded.
        int256 lo =
            vaultFullCloseIssued ? type(int256).min : int256(parkPositionSize) - int256(uint256(vaultSellAllowance));
        int256 hi = int256(parkPositionSize) + int256(uint256(vaultBuyAllowance));
        if (f.positionSize >= lo && f.positionSize <= hi) {
            revert NoDivergence(f.positionSize, parkPositionSize);
        }
        address who = parkLessee;
        emit PositionDiverged(who, batch.batchNumber, parkPositionSize, f.positionSize);
        uint256 amt = parkBond;
        _clearLiability(); // slot was this park; a successful slash closes it early
        _slash(who, amt, 1);
    }

    /// @notice Permissionless force-park after the execution window T_E lapses.
    ///         NOT self-callable (a dirty lessee must not cherry-pick an in-band
    ///         anchor to exit clean). Force-parks unconditionally; slashes ONLY
    ///         if the account is provably ABOVE band at expiry — an honest
    ///         executor who fixed the position but forgot to park loses nothing,
    ///         and neither a below-band state (the vault's own redemption reduce
    ///         can cause it) nor a min-notional wedge (no legal in-band order
    ///         exists) is the lessee's fault.
    function expireLease(
        LighterProof.AccountWitness calldata w,
        StoredBatchInfo calldata batch,
        LighterProof.ForeignClearing[] calldata clearings
    ) external {
        if (keyState != KeyState.Leased) revert WrongKeyState(keyState);
        if (msg.sender == lessee) revert NotLessee(msg.sender);
        uint64 head = bridge.committedBatchesCount();
        uint64 expiry = leaseStartBatch + executionBatches;
        if (head <= expiry) revert LeaseNotExpired(head, expiry);
        if (batch.batchNumber > head || batch.batchNumber + 1 < head) {
            revert ProofNotRecent(batch.batchNumber, head);
        }
        _requireCleanVaultLanes(batch.batchNumber);
        _releaseBond(); // free the slot if a prior window lapsed; revert if open

        (uint256 l, bool infinite, LighterProof.AccountFacts memory f) = _provenLeverage(w, batch);
        LighterProof.requireForeignClear(w, f.possiblyForeignMask, clearings);

        address who = lessee;
        // Force-park unconditionally.
        keyState = KeyState.Parked;
        lessee = address(0);
        delete leasedKey;
        bridge.cancelAllOrders(accountIndex);
        bridge.changePubKey(accountIndex, apiKeyIndex, parkPubKey);

        // Slash only on the ABOVE-band side (no vault order aims there and it is
        // the harmful direction); below-band and the min-notional wedge are not the
        // lessee's fault. Above band → close liability, no window.
        bool aboveBand = infinite || l > bandHi1e18;
        bool wedged = !aboveBand && _noLegalInBandOrder(f);
        if (aboveBand && !wedged) {
            emit LeaseExpired(who, batch.batchNumber, l, true);
            uint256 amt = leaseBond;
            leaseBond = 0;
            _slash(who, amt, 3);
        } else {
            // In/below band (or wedged): open the divergence window like a park,
            // so an in-lag trade before this forced park is still challengeable.
            _openPark(who, batch.batchNumber, f.positionSize, l);
            emit LeaseExpired(who, batch.batchNumber, l, false);
        }
    }

    /// @notice Returns the bond to the recorded lessee once the challenge window
    ///         has lapsed AND the park's changePubKey has COMMITTED (the key is
    ///         provably dead — batch height and priority-queue depth are
    ///         decoupled, so batch arithmetic alone is not enough). Pays the
    ///         clean-release executor bounty from the fee pool. Permissionless
    ///         (funds go to the recorded lessee); a no-op when nothing is open.
    function releaseBond() external whenNotPaused {
        _releaseBond();
    }

    /// @dev Internal, pause-exempt body: parkKey/expireLease run it as part of
    ///      ending a lease (freeing the liability slot), which must keep
    ///      working while paused — only the EXTERNAL bond-outflow entry is
    ///      gated.
    function _releaseBond() internal {
        if (parkLessee == address(0)) return; // nothing outstanding
        uint64 head = bridge.committedBatchesCount();
        uint64 deadline = parkAnchorBatch + challengeBatches;
        if (head <= deadline) revert ChallengeWindowOpen(head, deadline);
        uint64 committed = bridge.committedPriorityRequestCount();
        if (committed < parkKeySerial) revert KeyChangeNotCommitted(committed, parkKeySerial);
        _payBondOut();
    }

    // ========================================================================
    // Foreign-position accountability + self-healing
    // ========================================================================

    /// @notice Permissionless: proves the account holds a position OUTSIDE the
    ///         target market and slashes whoever put it there.
    ///
    ///         Attribution is sound without forensics: `acquireLease` rejects a
    ///         witness with `foreignBucketMask != 0`, so a lease can only begin
    ///         from a single-market account — any foreign position seen during
    ///         (or immediately after) a lease is the lessee's doing. v5.3 pins
    ///         the anchor to AFTER the relevant lease/park so a PREVIOUS
    ///         lessee's foreign position cannot be attributed to the current
    ///         one, and a hit force-parks a sitting lessee (their bond is gone,
    ///         so the key must die with it).
    /// @param opFunding/opSize raw slots of the foreign bucket, authenticated
    ///        against the root-bound `w.bucketDigests[bucketIndex]`.
    function challengeForeignPosition(
        LighterProof.AccountWitness calldata w,
        StoredBatchInfo calldata batch,
        uint8 bucketIndex,
        int128[16] calldata opFunding,
        int128[16] calldata opSize,
        uint8 slot
    ) external {
        // Anchor attribution: a live lease pins to > leaseStartBatch; an open
        // park liability pins to (parkAnchorBatch, parkAnchorBatch + T_c].
        address culprit;
        if (lessee != address(0)) {
            if (batch.batchNumber <= leaseStartBatch) {
                revert AnchorNotAfterPark(batch.batchNumber, leaseStartBatch);
            }
            culprit = lessee;
        } else if (parkLessee != address(0)) {
            if (batch.batchNumber <= parkAnchorBatch) {
                revert AnchorNotAfterPark(batch.batchNumber, parkAnchorBatch);
            }
            uint64 deadline = parkAnchorBatch + challengeBatches;
            if (batch.batchNumber > deadline) revert ChallengeWindowClosed(batch.batchNumber, deadline);
            culprit = parkLessee;
        } else {
            revert NoLesseeToSlash();
        }

        LighterProof.AccountFacts memory f =
            verifier.verifyAccount(w, batch, accountIndex, expectedL1Owner, targetMarket);
        if (f.possiblyForeignMask == 0) revert NoForeignPosition();
        (uint16 market, int256 size) = LighterProof.openForeign(w, targetMarket, bucketIndex, opFunding, opSize, slot);

        emit ForeignPositionChallenged(culprit, market, size, batch.batchNumber);
        if (lessee == culprit) {
            // Force-park the sitting lessee and slash the live bond. Any
            // separate open-park liability (a capped prior lessee) is untouched.
            keyState = KeyState.Parked;
            lessee = address(0);
            delete leasedKey;
            bridge.cancelAllOrders(accountIndex);
            bridge.changePubKey(accountIndex, apiKeyIndex, parkPubKey);
            uint256 amt = leaseBond;
            leaseBond = 0;
            _slash(culprit, amt, 2);
        } else {
            // Open-park liability: slash the held bond and close the window.
            uint256 amt = parkBond;
            _clearLiability();
            _slash(culprit, amt, 2);
        }
    }

    /// @notice Permissionless SELF-HEALING: force-closes a proven foreign
    ///         position so the account becomes single-market (and therefore
    ///         settleable) again. Before v5.2 only the owner could do this,
    ///         because the keyless backstop needed the very proof that a
    ///         foreign position was breaking.
    ///
    ///         `baseAmount = 0` means "whole position" and L1 orders are
    ///         circuit-enforced reduce-only, so this can only ever CLOSE.
    ///         Reuses the rebalance serial lane (it is an order like any other).
    function forceCloseForeign(
        LighterProof.AccountWitness calldata w,
        StoredBatchInfo calldata batch,
        uint8 bucketIndex,
        int128[16] calldata opFunding,
        int128[16] calldata opSize,
        uint8 slot
    ) external {
        if (!accountOpened) revert AccountNotOpened();
        confirmRebalanceOp();
        if (rebalanceOpSerial != 0) {
            revert RebalanceInFlight(bridge.committedPriorityRequestCount(), rebalanceOpSerial);
        }
        LighterProof.AccountFacts memory f =
            verifier.verifyAccount(w, batch, accountIndex, expectedL1Owner, targetMarket);
        if (f.possiblyForeignMask == 0) revert NoForeignPosition();
        (uint16 market, int256 size) = LighterProof.openForeign(w, targetMarket, bucketIndex, opFunding, opSize, slot);

        // The witness carries marks for ALL 255 markets, so the foreign leg's
        // price clamp needs no extra data.
        uint256 mark = w.markPrices[market];
        if (mark == 0) revert ZeroMarkPrice();
        uint8 isAsk = size > 0 ? 1 : 0; // sell a long, buy back a short
        uint32 price = _clampPrice(mark, isAsk == 1);

        bridge.createOrder(accountIndex, market, 0, price, isAsk, ORDER_TYPE_MARKET);
        rebalanceOpSerial = bridge.executedPriorityRequestCount() + bridge.openPriorityRequestCount();
        emit ForeignPositionClosed(market, size, price, isAsk, rebalanceOpSerial);
    }

    // ========================================================================
    // Admin ops surface (v5.3.3): raiseCap / pause / unpause / forceUnwind
    // ========================================================================

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdmin(msg.sender);
        _;
    }

    /// @notice RAISE-ONLY loosening of the equity cap. Requires a capped vault
    ///         (0 = uncapped is a harness configuration, not a raisable state)
    ///         and a strictly higher cap — the admin can let the vault grow,
    ///         never squeeze it (a lower cap only blocks mints anyway, but the
    ///         name is the spec).
    function raiseCap(uint256 newCap) external onlyAdmin {
        uint256 current = equityCapUsdg;
        if (current == 0 || newCap <= current) revert CapNotRaised(newCap, current);
        equityCapUsdg = newCap;
        emit CapRaised(current, newCap);
    }

    /// @notice Freezes the risk-increasing entrypoints (mint/redeem/claim/
    ///         settlement/rebalance/acquire + external releaseBond). The
    ///         risk-reducing and accountability surface stays OPEN — see the
    ///         v5.3.3 header note.
    function pause() external onlyAdmin {
        _pause();
    }

    /// @notice Lifts the freeze. Refused after a forceUnwind: unwound is
    ///         terminal, and unpausing would reopen mint/settlement paths
    ///         whose NAV accounting no longer describes anything (the funds
    ///         left the leaf).
    function unpause() external onlyAdmin {
        if (unwound) revert VaultUnwound();
        _unpause();
    }

    /// @notice Emergency unwind: end any live lease (slashed — the force-park
    ///         is itself evidence the lease ended badly), flush the book,
    ///         enqueue a full reduce-only
    ///         close and then the withdrawal (FIFO: the close frees the margin
    ///         first), and flip the TERMINAL `unwound` flag. Shareholders then
    ///         exit pro-rata via `redeemUnwound` once the funds are swept.
    ///
    ///         `closePrice` (slippage floor for the sell) and `withdrawAmount6`
    ///         are ADMIN-SUPPLIED by design: this path must work when the
    ///         proof pipeline is exactly what broke, so it can depend on no
    ///         witness. An oversized withdrawal is silently nooped by the L2 —
    ///         retry with corrected numbers (the call is repeatable; pass
    ///         withdrawAmount6 = 0 for a close-only pass).
    function forceUnwind(uint32 closePrice, uint64 withdrawAmount6) external onlyAdmin whenPaused {
        if (!accountOpened) revert AccountNotOpened();
        if (closePrice == 0) revert ZeroMarkPrice();
        address who = lessee;
        if (who != address(0)) {
            keyState = KeyState.Parked;
            lessee = address(0);
            delete leasedKey;
            bridge.changePubKey(accountIndex, apiKeyIndex, parkPubKey);
            uint256 amt = leaseBond;
            leaseBond = 0;
            _slash(who, amt, 3);
        }
        bridge.cancelAllOrders(accountIndex);
        bridge.createOrder(accountIndex, targetMarket, 0, closePrice, 1, ORDER_TYPE_MARKET);
        if (withdrawAmount6 > 0) {
            bridge.withdraw(accountIndex, assetIndex, routeType, withdrawAmount6);
        }
        unwound = true;
        emit ForceUnwound(closePrice, withdrawAmount6);
    }

    /// @notice Post-unwind exit: burns the caller's tokens for a PRO-RATA share
    ///         of the recovered L1 USDG. Pro-rata, not NAV: the unwind moved
    ///         every dollar off the L2 leaf, so proven-equity NAV no longer
    ///         prices anything. `_availableUsdg` keeps bonds, the fee pool and
    ///         unsettled mint escrow out of the distributable pot. Documented
    ///         Residuals: the dead shares' and vault-held (settled-
    ///         unclaimed mint) tokens' slice stays stranded, and unsettled
    ///         mint escrow stays escrowed (its requests can never settle) —
    ///         both bounded by the equity cap; accepted for this design.
    function redeemUnwound(uint256 tokens) external returns (uint256 payout) {
        if (!unwound) revert NotUnwound();
        if (tokens == 0) revert ZeroAmount();
        payout = (tokens * _availableUsdg()) / totalSupply();
        _burn(msg.sender, tokens); // effects before interactions
        if (payout > 0) usdg.safeTransfer(msg.sender, payout);
        emit UnwoundRedemption(msg.sender, tokens, payout);
    }

    // ========================================================================
    // Internals
    // ========================================================================

    function _enqueue(RequestKind kind, address receiver, uint256 amountIn) internal returns (uint256 requestId) {
        require(amountIn <= type(uint128).max, "amountIn too large");
        requestId = nextRequestId++;
        requests[requestId] = Request({
            kind: kind,
            status: RequestStatus.Pending,
            receiver: receiver,
            amountIn: uint128(amountIn),
            amountOut: 0,
            requestedAt: uint64(block.timestamp),
            acceptedAtBatch: bridge.committedBatchesCount()
        });
    }

    /// @dev USDG spendable for redeem payouts. Excludes unsettled mint escrow
    ///      AND (v5.3) held/slashed bonds and the fee pool — none of which is
    ///      redeemer collateral. Without this, `claim` could pay a redeemer out
    ///      of a lessee's bond and `owedShortfall` would count it as delivered.
    function _availableUsdg() internal view returns (uint256) {
        uint256 bal = usdg.balanceOf(address(this));
        uint256 reserved = escrowedMintUsdg + leaseBond + parkBond + pendingSlashDeposit + feePoolUsdg;
        return bal > reserved ? bal - reserved : 0;
    }

    function _isAllZero(bytes memory data) internal pure returns (bool) {
        for (uint256 i = 0; i < data.length; i++) {
            if (data[i] != 0) return false;
        }
        return true;
    }

    // ------------------------------------------------------------ v5.3 helpers

    /// @dev Total bond USDG at risk (live lease + open park window). Kept as a
    ///      view so the external surface (Status, keeper) survives
    ///      the v5.3.1 split into per-slot amounts.
    function bondHeld() public view returns (uint256) {
        return leaseBond + parkBond;
    }

    /// @notice The bond a prospective lessee should budget for: `bondBps` of
    ///         the last PROVEN equity (nav x supply). The exact bond is priced
    ///         on the acquire witness's equity, which can drift from this
    ///         between proofs — approve with margin (or unlimited).
    function estimatedBond() public view returns (uint256) {
        return (((navPerToken * totalSupply()) / 1e18) * bondBps) / 10000;
    }

    /// @dev The batch after which `releaseBond` may return the bond (the
    ///      challenge-anchor deadline). NB: the park changePubKey must ALSO have
    ///      committed — see `releaseBond`.
    function bondReleaseBatch() external view returns (uint64) {
        return parkAnchorBatch + challengeBatches;
    }

    /// @dev The batch after which `expireLease` becomes callable.
    function leaseExpiryBatch() external view returns (uint64) {
        return leaseStartBatch + executionBatches;
    }

    /// @dev True while a park's divergence/bond liability is open.
    function challengeOpen() external view returns (bool) {
        return parkLessee != address(0);
    }

    /// @dev True once the open park's window has fully lapsed AND its key change
    ///      committed — i.e. `releaseBond` would pay out.
    function _bondWindowClosed(uint64 head) internal view returns (bool) {
        if (parkLessee == address(0)) return false;
        if (head <= parkAnchorBatch + challengeBatches) return false;
        return bridge.committedPriorityRequestCount() >= parkKeySerial;
    }

    /// @dev Records the divergence snapshot and opens the T_c window. Called
    ///      AFTER the park changePubKey is enqueued, so `parkKeySerial` captures
    ///      it (the last priority op).
    function _openPark(address who, uint64 anchor, int256 posSize, uint256 l) internal {
        // v5.3.1: the live lease's bond becomes the park liability's. The prior
        // parkBond is provably 0 here — every caller runs releaseBond() first,
        // which pays it out or reverts while its window is open.
        parkBond = leaseBond;
        leaseBond = 0;
        parkLessee = who;
        parkAnchorBatch = anchor;
        parkPositionSize = int128(posSize);
        parkKeySerial = bridge.executedPriorityRequestCount() + bridge.openPriorityRequestCount();
        liabilityAnchorCap = type(uint64).max;
        vaultSellAllowance = 0;
        vaultBuyAllowance = 0;
        vaultFullCloseIssued = false;
        emit KeyParked(who, anchor, int128(posSize), l, anchor + challengeBatches);
    }

    /// @dev Clears the open-park liability slot. Callers that slash or return
    ///      the bond capture `parkBond` BEFORE calling this (it is zeroed here).
    function _clearLiability() internal {
        parkBond = 0;
        parkLessee = address(0);
        parkAnchorBatch = 0;
        parkPositionSize = 0;
        parkKeySerial = 0;
        vaultSellAllowance = 0;
        vaultBuyAllowance = 0;
        vaultFullCloseIssued = false;
        liabilityAnchorCap = type(uint64).max;
    }

    /// @dev Slash a bond into the pending L2 deposit. Callers detach `amt`
    ///      from its slot (leaseBond / parkBond) first — the slashed party is
    ///      not always the open-park lessee (a live lease's bond may be
    ///      slashed while a separate capped liability stays open). v5.3.1:
    ///      slashing is the WHOLE penalty — no barring; a re-acquiring
    ///      offender simply posts (and forfeits) a fresh bond.
    function _slash(address who, uint256 amt, uint8 reason) internal {
        if (amt > 0) pendingSlashDeposit += amt;
        emit BondSlashed(who, amt, reason);
    }

    /// @dev Return the open-park bond to its lessee and clear the slot; pay the
    ///      clean-release executor bounty (bps of the returned bond) from the
    ///      pool. Effects before transfer.
    function _payBondOut() internal {
        address who = parkLessee;
        uint256 amt = parkBond;
        _clearLiability();
        if (amt > 0) usdg.safeTransfer(who, amt);
        emit BondReleased(who, amt);
        if (executorBountyBps > 0 && feePoolUsdg > 0) {
            uint256 paid = _payFromPool(who, (amt * executorBountyBps) / 10000);
            if (paid > 0) emit ExecutorBountyPaid(who, paid);
        }
    }

    /// @dev Pay up to `want` from the fee pool; returns the amount actually paid.
    function _payFromPool(address to, uint256 want) internal returns (uint256 paid) {
        paid = want > feePoolUsdg ? feePoolUsdg : want;
        if (paid > 0) {
            feePoolUsdg -= paid;
            usdg.safeTransfer(to, paid);
        }
    }

    /// @dev Accumulate a vault-originated target-market order into the challenge
    ///      allowance (the false-slash guard). Only matters while a park window
    ///      is open. baseAmount==0 ("whole position") disables the decrease side.
    function _recordVaultOrder(uint48 baseAmount, uint8 isAsk) internal {
        if (parkLessee == address(0)) return;
        if (baseAmount == 0) {
            vaultFullCloseIssued = true;
        } else if (isAsk == 1) {
            vaultSellAllowance = _satAddU48(vaultSellAllowance, baseAmount);
        } else {
            vaultBuyAllowance = _satAddU48(vaultBuyAllowance, baseAmount);
        }
        emit VaultOrderRecorded(bridge.committedBatchesCount(), baseAmount, isAsk);
    }

    function _satAddU48(uint48 a, uint48 b) private pure returns (uint48) {
        uint256 s = uint256(a) + uint256(b);
        return s > type(uint48).max ? type(uint48).max : uint48(s);
    }

    /// @dev The vault-order-lane cleanliness block shared by `parkKey` and
    ///      `expireLease` (verbatim from `rebalance`): both lanes clear and the
    ///      anchor postdates every vault order, so the snapshot is untainted and
    ///      resetting the post-park allowances to 0 is sound.
    function _requireCleanVaultLanes(uint64 anchorBatch) internal {
        confirmBridgeOps();
        if (lastBridgeOpSerial != 0) {
            revert BridgeOpsInFlight(bridge.committedPriorityRequestCount(), lastBridgeOpSerial);
        }
        if (anchorBatch < bridgeOpsClearedAtBatch) {
            revert AnchorPredatesBridgeOps(anchorBatch, bridgeOpsClearedAtBatch);
        }
        confirmRebalanceOp();
        if (rebalanceOpSerial != 0) {
            revert RebalanceInFlight(bridge.committedPriorityRequestCount(), rebalanceOpSerial);
        }
        if (anchorBatch < rebalanceClearedAtBatch) {
            revert AnchorPredatesRebalance(anchorBatch, rebalanceClearedAtBatch);
        }
    }

    /// @dev True iff NO legal in-band correcting order exists (the min-notional
    ///      wedge). Mirrors `_sizeOrder`'s clamp-or-refuse test without
    ///      reverting. Used by `expireLease` to exempt an honest lessee who
    ///      physically cannot bring the account in band.
    function _noLegalInBandOrder(LighterProof.AccountFacts memory f) internal view returns (bool) {
        if (f.markPrice == 0) return false;
        int256 e6 = _trueEquity6(f.usdgBalance, f.positionSize, f.markPrice);
        if (e6 <= 0) return false; // stop-out: a full close is always legal
        uint256 n6 = _notional6(f.positionSize, f.markPrice);
        int256 dN6 = int256((targetLeverage1e18 * uint256(e6)) / 1e18) - int256(n6);
        uint256 want6 = dN6 < 0 ? uint256(-dN6) : uint256(dN6);
        if (want6 >= minOrderNotional6) return false; // a legal order exists
        uint256 newN6;
        if (dN6 < 0) {
            if (n6 < minOrderNotional6) return true; // can't even place a min sell
            newN6 = n6 - minOrderNotional6;
        } else {
            newN6 = n6 + minOrderNotional6;
        }
        uint256 newL = (newN6 * 1e18) / uint256(e6);
        return newL < bandLo1e18 || newL > bandHi1e18;
    }

    /// @notice Admin withdraws accrued fee-pool USDG to the admin. Bounties are
    ///         paid from the same pool; this drains the residual. v5.3.3: fees
    ///         are the ops role's revenue — its gate and destination.
    function withdrawFees(uint256 amount) external onlyAdmin {
        if (amount > feePoolUsdg) amount = feePoolUsdg;
        feePoolUsdg -= amount;
        usdg.safeTransfer(admin, amount);
        emit FeesWithdrawn(admin, amount);
    }
}
