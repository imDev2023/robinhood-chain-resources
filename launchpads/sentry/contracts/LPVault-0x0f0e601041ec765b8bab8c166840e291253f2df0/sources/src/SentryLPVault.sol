// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title SentryLPVault
 * @dev Immutable, non-upgradeable custody vault for every Sentry launch
 * position, both Uniswap v4 (PoolManager singleton positions) and the
 * deprecated Uniswap v3 (LP NFTs).
 *
 * WHY THIS EXISTS
 * ---------------
 * The v3 and v4 launch factories sit behind upgradeable proxies. Today
 * they custody the LP themselves, so whoever can upgrade a factory could
 * add a withdrawal path and pull the liquidity. This vault removes that
 * risk by holding the LP in a contract that is NOT a proxy and that has
 * NO code path to move an NFT, decrease v3 liquidity, or remove v4
 * liquidity. Principal is locked for EVERYONE, including this contract's
 * admin. The admin role can only ever redirect FEE routing for v3
 * positions; it can never touch principal.
 *
 * WHAT THE VAULT DOES / DOES NOT DO
 * ---------------------------------
 *  - v4: holds the single locked position per launch, owned by the vault
 *    inside the PoolManager. There is no fee-collection path because the
 *    Sentry hooks force the pool LP fee to 0 and pay the app fee out to
 *    creator/treasury PER SWAP; the locked position never accrues fees.
 *    The only v4 entrypoint is lockLaunchLiquidity, callable only by the
 *    two v4 launch factories — the WETH stack and the stock stack (new
 *    launches mint straight here; existing pools migrate here). Each
 *    position records which factory owns its fee config. No removal, ever.
 *  - v3: receives swept LP NFTs from the v3 factory (authenticated via
 *    onERC721Received) and lets the recorded creator / fee recipient /
 *    admin collect the position's real trading fees, split creator/
 *    treasury exactly like the old factory did. The NFT can never leave
 *    and liquidity can never be decreased.
 *
 * ADMIN
 * -----
 * A single `admin` role (initially the Sentry deployer) may redirect v3
 * fee recipients and transfer itself to a multisig later. It is a fee
 * lever only. The vault is never upgradeable.
 */

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "v4-core/interfaces/callback/IUnlockCallback.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {ModifyLiquidityParams} from "v4-core/types/PoolOperation.sol";
import {StateLibrary} from "v4-core/libraries/StateLibrary.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {LiquidityAmounts} from "./libraries/LiquidityAmounts.sol";

interface IERC20Minimal {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/// @dev v4 fee routing lives on the launch factory: the immutable Sentry
/// hooks read creator/treasury/split from it per swap, so the vault reads
/// the same source when collecting any accrued v4 fees. This keeps a
/// single source of truth for v4 routing and preserves the factory's
/// migrateFeeRecipient / admin-redirect levers.
/// @dev The factory side of the two-step vault handover.
interface ISentryFactoryVaultHandshake {
    function acceptVault() external;
}

interface ISentryV4FactoryConfig {
    function feeRecipientOf(address token) external view returns (address);
    function getCreator(address token) external view returns (address);
    function treasury() external view returns (address);
    function creatorFeeBps() external view returns (uint256);
}

/// @dev Minimal Uniswap v3 NonfungiblePositionManager surface. The vault
/// only ever READS positions and COLLECTS fees; it never decreases
/// liquidity or transfers the NFT out. The absence of those calls is what
/// makes v3 principal permanently locked.
interface IV3PositionManager {
    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    function collect(CollectParams calldata params) external returns (uint256 amount0, uint256 amount1);
}

contract SentryLPVault is IUnlockCallback {
    using PoolIdLibrary for PoolKey;
    using StateLibrary for IPoolManager;

    /* ─────────────────────── Immutable config ───────────────────── */

    /// @notice Canonical Uniswap v4 PoolManager.
    address public immutable poolManager;
    /// @notice The WETH-base v4 launch factory allowed to lock positions here.
    address public immutable v4FactoryWeth;
    /// @notice The stock-base v4 launch factory allowed to lock positions here.
    /// Both are permanent proxy addresses, so the vault stays fully immutable
    /// while custodying LP from either launch stack.
    address public immutable v4FactoryStock;
    /// @notice Uniswap v3 NonfungiblePositionManager (swept NFTs live here).
    address public immutable v3Npm;
    /// @notice The v3 launch factory whose sweeps this vault trusts.
    address public immutable v3Factory;

    uint256 private constant BPS_DENOMINATOR = 10_000;

    /* ───────────────────────── Admin / routing ──────────────────── */

    /// @notice Fee-routing lever only; can never move principal. Starts as
    /// the Sentry deployer, transferable to a multisig (two-step).
    address public admin;
    /// @notice Admin candidate awaiting acceptAdmin().
    address public pendingAdmin;
    /// @notice Non-creator share destination for v3 fee collection.
    address public treasury;
    /// @notice Creator's share of collected v3 fees, in bps (default 65%).
    uint256 public creatorFeeBps;

    /* ─────────────────────────── v4 state ───────────────────────── */

    struct V4Position {
        bool locked;
        int24 tickLower;
        int24 tickUpper;
        /// @dev Which launch factory owns this position's fee config. Fee
        /// routing (recipient/treasury/split) is read from THIS factory, so
        /// WETH and stock launches each keep their own source of truth.
        address factory;
        PoolKey key;
    }

    /// @notice The locked v4 position per launched token.
    mapping(address => V4Position) public v4Positions;

    enum Action {
        LOCK,
        COLLECT
    }

    struct CallbackData {
        Action action;
        PoolKey key;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Max;
        uint256 amount1Max;
    }

    /* ─────────────────────────── v3 state ───────────────────────── */

    /// @notice Recorded creator per swept v3 tokenId (snapshotted at sweep).
    mapping(uint256 => address) public v3Creator;
    /// @notice Optional admin override of a v3 position's fee recipient
    /// (zero = pay the recorded creator).
    mapping(uint256 => address) public v3FeeRecipient;
    /// @notice Whether the vault holds this v3 tokenId.
    mapping(uint256 => bool) public v3Held;
    /// @notice Whether a position's creator has used their one-time
    /// self-service fee-recipient migration (mirrors the v3 factory, so
    /// sweeping does not strip creators of that escape hatch).
    mapping(uint256 => bool) public v3FeeRecipientMigrated;

    /* ─────────────────────── Reentrancy guard ───────────────────── */

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    /* ──────────────────────────── Events ────────────────────────── */

    event AdminTransferStarted(address indexed currentAdmin, address indexed candidate);
    event AdminTransferred(address indexed oldAdmin, address indexed newAdmin);
    event VaultCustodyAccepted(address indexed factory);
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event CreatorFeeBpsUpdated(uint256 oldBps, uint256 newBps);

    event V4LiquidityLocked(address indexed token, PoolId indexed poolId, uint128 liquidity);
    event V4FeesCollected(address indexed token, uint256 amount0, uint256 amount1);
    event V4CreatorFeePaid(address indexed token, address indexed recipient, address currency, uint256 amount);

    event V3PositionReceived(uint256 indexed tokenId, address indexed creator, address feeRecipient);
    event V3FeesCollected(uint256 indexed tokenId, uint256 amount0, uint256 amount1);
    event V3CreatorFeePaid(uint256 indexed tokenId, address indexed recipient, address token, uint256 amount);
    event V3FeeRecipientUpdated(uint256 indexed tokenId, address indexed oldRecipient, address indexed newRecipient);

    /* ─────────────────────────── Errors ─────────────────────────── */

    error ZeroAddress();
    error NotAdmin();
    error NotV4Factory();
    error NotPoolManager();
    error NotV3Sweep();
    error AlreadyLocked();
    error UnknownToken();
    error UnknownPosition();
    error NotAuthorized();
    error ZeroLiquidity();
    error InvalidFee();
    error Reentrancy();
    error TokenNotInPool();
    error OverspendBlocked();
    error AlreadyMigrated();

    /* ─────────────────────────── Modifiers ──────────────────────── */

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdmin();
        _;
    }

    modifier nonReentrant() {
        if (_status == _ENTERED) revert Reentrancy();
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    /* ──────────────────────────── Constructor ───────────────────── */

    constructor(
        address _poolManager,
        address _v4FactoryWeth,
        address _v4FactoryStock,
        address _v3Npm,
        address _v3Factory,
        address _admin,
        address _treasury,
        uint256 _creatorFeeBps
    ) {
        if (
            _poolManager == address(0) || _v4FactoryWeth == address(0) || _v4FactoryStock == address(0)
                || _v3Npm == address(0) || _v3Factory == address(0) || _admin == address(0) || _treasury == address(0)
        ) revert ZeroAddress();
        if (_creatorFeeBps == 0 || _creatorFeeBps > BPS_DENOMINATOR) revert InvalidFee();

        poolManager = _poolManager;
        v4FactoryWeth = _v4FactoryWeth;
        v4FactoryStock = _v4FactoryStock;
        v3Npm = _v3Npm;
        v3Factory = _v3Factory;
        admin = _admin;
        treasury = _treasury;
        creatorFeeBps = _creatorFeeBps;
        _status = _NOT_ENTERED;
    }

    /* ══════════════════════════ v4 custody ═══════════════════════ */

    /// @notice Complete the factory's two-step vault handover by calling
    /// acceptVault() on it. Restricted to the admin and to the two
    /// factories this vault was built for, so the vault can only ever be
    /// installed on a stack it already trusts. This is what makes the
    /// factory's handshake meaningful: an EOA or unrelated contract can
    /// never accept, so a mistyped setVault target cannot take custody of
    /// a launch's supply.
    function acceptVaultRole(address factory) external onlyAdmin {
        if (factory != v4FactoryWeth && factory != v4FactoryStock) revert NotV4Factory();
        ISentryFactoryVaultHandshake(factory).acceptVault();
        emit VaultCustodyAccepted(factory);
    }

    /**
     * @notice Lock a launch's single-sided liquidity under this vault's
     * ownership inside the PoolManager. Callable ONLY by the v4 factory.
     * The factory must have already transferred the position's token
     * amounts to this vault before calling; the vault computes the
     * liquidity for the current pool price from the supplied maxes,
     * adds it as owner = vault, and settles what it owes from its own
     * balance. Any leftover dust stays in the vault.
     *
     * There is no counterpart removal function anywhere in this contract,
     * so the position is locked the instant it is added.
     *
     * @param token       The campaign token this position belongs to.
     * @param key         The pool key of the (already initialized) launch pool.
     * @param tickLower   Lower tick of the launch range.
     * @param tickUpper   Upper tick of the launch range.
     * @param amount0Max  Max currency0 the vault may spend (its balance covers it).
     * @param amount1Max  Max currency1 the vault may spend.
     */
    function lockLaunchLiquidity(
        address token,
        PoolKey calldata key,
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0Max,
        uint256 amount1Max
    ) external nonReentrant returns (uint128 liquidity) {
        if (msg.sender != v4FactoryWeth && msg.sender != v4FactoryStock) revert NotV4Factory();
        if (token == address(0)) revert ZeroAddress();
        // The position must actually belong to `token`. Without this a
        // compromised factory could point the vault at an unrelated pool
        // (with an attacker-controlled hook) and settle the vault's
        // balances into it.
        if (token != Currency.unwrap(key.currency0) && token != Currency.unwrap(key.currency1)) {
            revert TokenNotInPool();
        }
        if (v4Positions[token].locked) revert AlreadyLocked();

        bytes memory res = IPoolManager(poolManager).unlock(
            abi.encode(
                CallbackData({
                    action: Action.LOCK,
                    key: key,
                    tickLower: tickLower,
                    tickUpper: tickUpper,
                    amount0Max: amount0Max,
                    amount1Max: amount1Max
                })
            )
        );
        liquidity = abi.decode(res, (uint128));
        if (liquidity == 0) revert ZeroLiquidity();

        v4Positions[token] = V4Position({
            locked: true,
            tickLower: tickLower,
            tickUpper: tickUpper,
            factory: msg.sender,
            key: key
        });
        emit V4LiquidityLocked(token, key.toId(), liquidity);
    }

    /**
     * @notice Collect any accrued v4 trading fees on a locked launch
     * position and route them creator/treasury, reading the split from the
     * v4 factory (same source the hooks use). This is a delta-0 poke: it
     * moves NO principal and cannot decrease liquidity.
     *
     * For pools on the per-swap fee hook (the live default) the position
     * never accrues fees, so this is a harmless no-op. It exists so that
     * positions on the older accrue-then-collect hook keep a working
     * collection path after migration. Callable by the admin, the token's
     * creator, or its current fee recipient.
     */
    function collectV4Fees(address token) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        V4Position memory pos = v4Positions[token];
        if (!pos.locked) revert UnknownToken();

        address srcFactory = pos.factory;
        address recipient = ISentryV4FactoryConfig(srcFactory).feeRecipientOf(token);
        address creator = ISentryV4FactoryConfig(srcFactory).getCreator(token);
        if (msg.sender != admin && msg.sender != creator && msg.sender != recipient) {
            revert NotAuthorized();
        }

        bytes memory res = IPoolManager(poolManager).unlock(
            abi.encode(
                CallbackData({
                    action: Action.COLLECT,
                    key: pos.key,
                    tickLower: pos.tickLower,
                    tickUpper: pos.tickUpper,
                    amount0Max: 0,
                    amount1Max: 0
                })
            )
        );
        (amount0, amount1) = abi.decode(res, (uint256, uint256));
        emit V4FeesCollected(token, amount0, amount1);
        if (amount0 == 0 && amount1 == 0) return (0, 0);

        _routeV4Fees(token, srcFactory, pos.key, amount0, amount1, recipient);
    }

    /// @dev PoolManager unlock callback. Computes liquidity for the
    /// current price from the supplied maxes, adds it as owner = vault,
    /// and settles every owed currency from the vault's balance. Only
    /// ever ADDS; there is no branch that removes or takes principal.
    function unlockCallback(bytes calldata rawData) external returns (bytes memory) {
        if (msg.sender != poolManager) revert NotPoolManager();
        CallbackData memory data = abi.decode(rawData, (CallbackData));

        if (data.action == Action.COLLECT) {
            // Delta-0 poke: liquidityDelta 0 credits accrued fees only.
            // Never removes principal.
            (BalanceDelta feeDelta,) = IPoolManager(poolManager).modifyLiquidity(
                data.key,
                ModifyLiquidityParams({
                    tickLower: data.tickLower,
                    tickUpper: data.tickUpper,
                    liquidityDelta: 0,
                    salt: bytes32(0)
                }),
                ""
            );
            int128 f0 = feeDelta.amount0();
            int128 f1 = feeDelta.amount1();
            uint256 fees0 = f0 > 0 ? uint256(uint128(f0)) : 0;
            uint256 fees1 = f1 > 0 ? uint256(uint128(f1)) : 0;
            if (fees0 > 0) IPoolManager(poolManager).take(data.key.currency0, address(this), fees0);
            if (fees1 > 0) IPoolManager(poolManager).take(data.key.currency1, address(this), fees1);
            return abi.encode(fees0, fees1);
        }

        // Action.LOCK: add liquidity for the current price from the
        // supplied maxes and settle what we owe. Only ever ADDS.
        (uint160 sqrtPriceX96,,,) = IPoolManager(poolManager).getSlot0(data.key.toId());
        uint128 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            sqrtPriceX96,
            TickMath.getSqrtPriceAtTick(data.tickLower),
            TickMath.getSqrtPriceAtTick(data.tickUpper),
            data.amount0Max,
            data.amount1Max
        );
        if (liquidity == 0) return abi.encode(uint128(0));

        (BalanceDelta delta,) = IPoolManager(poolManager).modifyLiquidity(
            data.key,
            ModifyLiquidityParams({
                tickLower: data.tickLower,
                tickUpper: data.tickUpper,
                liquidityDelta: int256(uint256(liquidity)),
                salt: bytes32(0)
            }),
            ""
        );

        // A fresh add only ever owes currency (negative delta). Settle
        // each owed side from the vault's balance, but never more than the
        // caller declared it was funding: a hook with return-delta
        // permissions can inflate what the position appears to owe and
        // siphon the difference, so cap the spend at the declared maxes.
        int128 amount0 = delta.amount0();
        int128 amount1 = delta.amount1();
        if (amount0 < 0) {
            uint256 owed0 = uint256(uint128(-amount0));
            if (owed0 > data.amount0Max) revert OverspendBlocked();
            _settle(data.key.currency0, owed0);
        }
        if (amount1 < 0) {
            uint256 owed1 = uint256(uint128(-amount1));
            if (owed1 > data.amount1Max) revert OverspendBlocked();
            _settle(data.key.currency1, owed1);
        }

        return abi.encode(liquidity);
    }

    function _settle(Currency currency, uint256 amount) internal {
        IPoolManager(poolManager).sync(currency);
        require(IERC20Minimal(Currency.unwrap(currency)).transfer(poolManager, amount), "settle transfer failed");
        IPoolManager(poolManager).settle();
    }

    /// @dev Split collected v4 fees creator/treasury using the v4 factory's
    /// live config (the same numbers the hooks use). A zero recipient sends
    /// everything to treasury.
    function _routeV4Fees(
        address token,
        address srcFactory,
        PoolKey memory key,
        uint256 amount0,
        uint256 amount1,
        address recipient
    ) internal {
        // Both values come from an UPGRADEABLE factory, so treat them as
        // untrusted input: an out-of-range split would underflow
        // treasuryCut and brick collection, and a zero treasury would burn
        // the treasury share. Clamp and fall back to the vault's own
        // treasury rather than reverting or burning.
        uint256 bps = ISentryV4FactoryConfig(srcFactory).creatorFeeBps();
        if (bps > BPS_DENOMINATOR) bps = BPS_DENOMINATOR;
        address treasury_ = ISentryV4FactoryConfig(srcFactory).treasury();
        if (treasury_ == address(0)) treasury_ = treasury;
        _routeV4Side(token, Currency.unwrap(key.currency0), amount0, recipient, treasury_, bps);
        _routeV4Side(token, Currency.unwrap(key.currency1), amount1, recipient, treasury_, bps);
    }

    function _routeV4Side(
        address token,
        address currency,
        uint256 amount,
        address recipient,
        address treasury_,
        uint256 bps
    ) internal {
        if (amount == 0) return;
        uint256 creatorCut = recipient == address(0) ? 0 : (amount * bps) / BPS_DENOMINATOR;
        uint256 treasuryCut = amount - creatorCut;
        if (creatorCut > 0) {
            require(IERC20Minimal(currency).transfer(recipient, creatorCut), "creator transfer failed");
            emit V4CreatorFeePaid(token, recipient, currency, creatorCut);
        }
        if (treasuryCut > 0) {
            require(IERC20Minimal(currency).transfer(treasury_, treasuryCut), "treasury transfer failed");
        }
    }

    /* ══════════════════════════ v3 custody ═══════════════════════ */

    /**
     * @notice ERC-721 receive hook. Accepts a v3 LP NFT ONLY when it is
     * swept in by the trusted v3 factory, and records the routing
     * (creator + optional fee-recipient override) the factory encodes in
     * `data`. Any other inbound NFT reverts, so the vault never holds a
     * position it cannot account for.
     * @param from  Previous owner; must be the v3 factory.
     * @param tokenId The LP NFT id.
     * @param data  abi.encode(address creator, address feeRecipientOverride).
     */
    function onERC721Received(address, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        if (msg.sender != v3Npm) revert NotV3Sweep();
        if (from != v3Factory) revert NotV3Sweep();

        (address creator, address feeRecipientOverride) = abi.decode(data, (address, address));
        if (creator == address(0)) revert ZeroAddress();

        v3Creator[tokenId] = creator;
        v3Held[tokenId] = true;
        if (feeRecipientOverride != address(0) && feeRecipientOverride != creator) {
            v3FeeRecipient[tokenId] = feeRecipientOverride;
        }
        emit V3PositionReceived(tokenId, creator, feeRecipientOverride);
        return this.onERC721Received.selector;
    }

    /// @notice Where a v3 position's creator-side fees go: the admin
    /// override when set, otherwise the recorded creator.
    function v3FeeRecipientOf(uint256 tokenId) public view returns (address) {
        address override_ = v3FeeRecipient[tokenId];
        return override_ == address(0) ? v3Creator[tokenId] : override_;
    }

    /**
     * @notice Collect a v3 position's accrued trading fees and split them
     * creator/treasury exactly like the old factory (creatorFeeBps to the
     * fee recipient, remainder to treasury). Callable by the admin, the
     * recorded creator, or the current fee recipient. Routing is identical
     * regardless of caller, so no caller can redirect a payout by
     * collecting. Never decreases liquidity.
     */
    function collectV3Fees(uint256 tokenId) external nonReentrant {
        if (!v3Held[tokenId]) revert UnknownPosition();
        address recipient = v3FeeRecipientOf(tokenId);
        if (msg.sender != admin && msg.sender != v3Creator[tokenId] && msg.sender != recipient) {
            revert NotAuthorized();
        }

        (,, address token0, address token1,,,,,,,,) = IV3PositionManager(v3Npm).positions(tokenId);
        (uint256 amount0, uint256 amount1) = IV3PositionManager(v3Npm).collect(
            IV3PositionManager.CollectParams({
                tokenId: tokenId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );
        emit V3FeesCollected(tokenId, amount0, amount1);

        _routeV3Side(tokenId, token0, amount0, recipient);
        _routeV3Side(tokenId, token1, amount1, recipient);
    }

    function _routeV3Side(uint256 tokenId, address token, uint256 amount, address recipient) internal {
        if (amount == 0) return;
        uint256 creatorCut = recipient == address(0) ? 0 : (amount * creatorFeeBps) / BPS_DENOMINATOR;
        uint256 treasuryCut = amount - creatorCut;

        if (creatorCut > 0) {
            require(IERC20Minimal(token).transfer(recipient, creatorCut), "creator transfer failed");
            emit V3CreatorFeePaid(tokenId, recipient, token, creatorCut);
        }
        if (treasuryCut > 0) {
            require(IERC20Minimal(token).transfer(treasury, treasuryCut), "treasury transfer failed");
        }
    }

    /// @notice One-time self-service migration of a v3 position's fee
    /// recipient, callable only by the CURRENT recipient. Ported from the
    /// v3 factory so sweeping into the vault does not strip creators of
    /// their escape hatch (e.g. a compromised creator wallet) and leave
    /// them dependent on the admin. Once per tokenId, ever; further
    /// changes need the admin path.
    function migrateV3FeeRecipient(uint256 tokenId, address newRecipient) external {
        if (newRecipient == address(0)) revert ZeroAddress();
        if (!v3Held[tokenId]) revert UnknownPosition();
        address current = v3FeeRecipientOf(tokenId);
        if (current == address(0) || msg.sender != current) revert NotAuthorized();
        if (v3FeeRecipientMigrated[tokenId]) revert AlreadyMigrated();

        v3FeeRecipientMigrated[tokenId] = true;
        v3FeeRecipient[tokenId] = newRecipient;
        emit V3FeeRecipientUpdated(tokenId, current, newRecipient);
    }

    /* ══════════════════════════ Admin ════════════════════════════ */

    /// @notice Redirect a v3 position's fee recipient. Admin only; this is
    /// the community-takeover / fee-reassignment lever. Never affects
    /// principal.
    function adminSetV3FeeRecipient(uint256 tokenId, address newRecipient) external onlyAdmin {
        if (newRecipient == address(0)) revert ZeroAddress();
        if (!v3Held[tokenId]) revert UnknownPosition();
        address old = v3FeeRecipientOf(tokenId);
        v3FeeRecipient[tokenId] = newRecipient;
        emit V3FeeRecipientUpdated(tokenId, old, newRecipient);
    }

    /// @notice Step 1 of handing the admin role to a new controller (e.g.
    /// a multisig). Two-step because admin is the ONLY lever that can
    /// redirect a v3 fee recipient — a typo here would permanently orphan
    /// every swept position's fee routing on a non-upgradeable contract.
    function transferAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert ZeroAddress();
        pendingAdmin = newAdmin;
        emit AdminTransferStarted(admin, newAdmin);
    }

    /// @notice Step 2: the proposed admin claims the role, proving the
    /// address is controllable.
    function acceptAdmin() external {
        if (msg.sender != pendingAdmin) revert NotAuthorized();
        emit AdminTransferred(admin, pendingAdmin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    /// @notice Update the v3 treasury (non-creator fee destination).
    function setTreasury(address newTreasury) external onlyAdmin {
        if (newTreasury == address(0)) revert ZeroAddress();
        emit TreasuryUpdated(treasury, newTreasury);
        treasury = newTreasury;
    }

    /// @notice Update the v3 creator/treasury split.
    function setCreatorFeeBps(uint256 newBps) external onlyAdmin {
        if (newBps == 0 || newBps > BPS_DENOMINATOR) revert InvalidFee();
        emit CreatorFeeBpsUpdated(creatorFeeBps, newBps);
        creatorFeeBps = newBps;
    }

    /* ─────────────────────────── Views ──────────────────────────── */

    function isV4Locked(address token) external view returns (bool) {
        return v4Positions[token].locked;
    }
}
