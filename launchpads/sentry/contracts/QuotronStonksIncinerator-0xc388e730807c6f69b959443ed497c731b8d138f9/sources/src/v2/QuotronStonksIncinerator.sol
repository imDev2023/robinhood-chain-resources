// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "v4-core/interfaces/callback/IUnlockCallback.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {SwapParams} from "v4-core/types/PoolOperation.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "v4-core/types/BalanceDelta.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";

interface IQuotronConverterRoutes {
    function poolManager() external view returns (address);
    function v3Router() external view returns (address);
    function weth() external view returns (address);
    function usdg() external view returns (address);
    function wethUsdgFee() external view returns (uint24);
    function routesSealed() external view returns (bool);
    function hook() external view returns (address);
    function routes(uint256 floorIdx) external view returns (address stock, uint24 fee, int24 tickSpacing, address hooks);
}

interface IQuotronHookIncinerator {
    function canonicalRouter() external view returns (address);
    function quotron() external view returns (address);
}

interface IV3ExactInputIncinerator {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}

interface IERC20Incinerator {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IWethIncinerator {
    function withdraw(uint256 amount) external;
}

interface IQuotronRouterIncinerator {
    function quotron() external view returns (address);
    function buyExactEth(uint256 minQuotronOut, address recipient, uint256 deadline)
        external
        payable
        returns (uint256 quotronOut);
}

interface IQuotronTokenIncinerator {
    function canonicalRouter() external view returns (address);
}

interface IERC2612Incinerator {
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;
}

/// @title QuotronStonksIncinerator
/// @notice Sells tokenized stocks to USDG, on to native ETH, or all the way
/// back into $QUOTRON through the canonical router, in a single transaction.
/// The ten Quotron floor stocks trade through an immutable route table fixed
/// at deployment - each floor's stock is verified against the sealed
/// QuotronEpochConverter, while the venue (a hookless V4 pool or a V3 pool)
/// and fee tier are chosen for depth. Any other Robinhood Chain token with a
/// USDG pool on either venue trades through the caller-supplied generic
/// entry points, making this a public utility other projects can integrate.
/// The contract has no owner and holds no balances between transactions. A
/// fixed 2.5% service fee on the proceeds goes to the Quotron admin Safe,
/// denominated in the delivered asset (USDG, or WETH on the ETH path).
/// Anything stranded here (donations, mistaken transfers, forced ETH) can be
/// swept to that same Safe by anyone via the permissionless rescue functions.
contract QuotronStonksIncinerator is IUnlockCallback {
    using BalanceDeltaLibrary for BalanceDelta;

    /// @dev venue: VENUE_V4 = hookless V4 pool (fee + tickSpacing),
    /// VENUE_V3 = V3 pool via the canonical V3 router (fee only).
    struct FloorRoute {
        address stock;
        uint24 fee;
        int24 tickSpacing;
        address hooks;
        uint8 venue;
    }

    /// @notice One caller-supplied sale: a token, its USDG pool's venue and
    /// fee tier (plus tick spacing for V4), and the amount to sell.
    /// `type(uint256).max` sells the caller's full balance; zero skips.
    struct GenericSale {
        address token;
        uint24 fee;
        int24 tickSpacing;
        uint256 amount;
        uint8 venue;
    }

    /// @dev An EIP-2612 signature authorizing this contract to pull one
    /// token. `deadline == 0` means no permit for that slot.
    struct StockPermit {
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    /// @notice Quotron admin multisig (the threshold-2 recovery Safe).
    address public constant FEE_RECIPIENT = 0x15277aA1ecC13734d57C519a2DAA1cc4A748bA89;
    uint256 public constant FEE_BPS = 250;

    IPoolManager public immutable poolManager;
    IV3ExactInputIncinerator public immutable v3Router;
    address public immutable weth;
    address public immutable usdg;
    uint24 public immutable wethUsdgFee;

    FloorRoute[10] public routes;

    /// @notice The canonical QUOTRON/WETH router, verified against the token
    /// at construction. Used only by the QUOTRON output path.
    IQuotronRouterIncinerator public immutable quotronRouter;

    uint8 public constant VENUE_V4 = 0;
    uint8 public constant VENUE_V3 = 1;

    uint8 internal constant OUT_USDG = 0;
    uint8 internal constant OUT_ETH = 1;
    uint8 internal constant OUT_QUOTRON = 2;

    uint256 private _lock = 1;

    event StockIncinerated(address indexed account, address indexed stock, uint256 amountIn, uint256 usdgOut);
    event Incinerated(address indexed account, uint256 usdgOut, uint256 wethOut, uint256 feePaid, bool toEth);
    event IncineratedForQuotron(
        address indexed account, uint256 usdgOut, uint256 wethOut, uint256 feePaid, uint256 quotronOut
    );
    event Rescued(address indexed token, uint256 amount);

    error RoutesNotSealed();
    error HookedRoute();
    error RouteStockMismatch();
    error InvalidVenue();
    error InvalidRoute();
    error NotPoolManager();
    error NothingToIncinerate();
    error InvalidSaleToken();
    error PermitCountMismatch();
    error AmountOverflow();
    error DeadlineExpired();
    error SlippageExceeded();
    error PartialFill();
    error SettleMismatch();
    error Reentrancy();
    error TokenTransferFailed();
    error NativeTransferFailed();
    error UnexpectedEth();
    error RouterMismatch();

    modifier nonReentrant() {
        if (_lock != 1) revert Reentrancy();
        _lock = 2;
        _;
        _lock = 1;
    }

    constructor(address converter_, address router_, FloorRoute[10] memory routes_) {
        IQuotronConverterRoutes converter = IQuotronConverterRoutes(converter_);
        if (!converter.routesSealed()) revert RoutesNotSealed();

        poolManager = IPoolManager(converter.poolManager());
        v3Router = IV3ExactInputIncinerator(converter.v3Router());
        weth = converter.weth();
        usdg = converter.usdg();
        wethUsdgFee = converter.wethUsdgFee();

        for (uint256 i; i < 10; ++i) {
            FloorRoute memory route = routes_[i];
            // Floor order is protocol state: each slot must sell exactly the
            // stock the sealed converter assigns to that floor.
            (address stock,,,) = converter.routes(i);
            if (route.stock != stock) revert RouteStockMismatch();
            // The security model assumes no hook code runs inside our unlock.
            if (route.hooks != address(0)) revert HookedRoute();
            if (route.venue > VENUE_V3) revert InvalidVenue();
            if (route.fee == 0 || (route.venue == VENUE_V4 && route.tickSpacing == 0)) revert InvalidRoute();
            routes[i] = route;
        }

        // Router binding anchored on the pinned converter's fee hook: the
        // hook names the canonical router, the router names the hook's token,
        // and that token names the router back. An impostor router cannot
        // satisfy all three without controlling the sealed converter.
        address hook = converter.hook();
        address token = IQuotronRouterIncinerator(router_).quotron();
        if (
            IQuotronHookIncinerator(hook).canonicalRouter() != router_
                || IQuotronHookIncinerator(hook).quotron() != token
                || IQuotronTokenIncinerator(token).canonicalRouter() != router_
        ) revert RouterMismatch();
        quotronRouter = IQuotronRouterIncinerator(router_);
    }

    // ── the ten Quotron floor stocks ────────────────────────────────

    /// @notice Sells the caller's floor stocks to USDG in one transaction.
    /// @param amounts Per-floor stock amount to sell. `type(uint256).max`
    /// sells the caller's full balance of that floor's stock; zero skips it.
    /// @param toEth When true the USDG proceeds are swapped to WETH and
    /// unwrapped, and the caller receives native ETH instead of USDG.
    /// @param minUsdgOut USDG path: enforced on the net amount delivered
    /// after the service fee. ETH path: bounds the gross USDG leg.
    /// @param minWethOut ETH path only: enforced on the net WETH delivered
    /// after the service fee. Ignored when `toEth` is false.
    /// @return usdgOut Gross USDG received from the stock sales.
    /// @return wethOut Gross WETH received on the ETH path, zero otherwise.
    /// @return feePaid Service fee sent to the admin Safe, denominated in
    /// USDG on the USDG path and WETH on the ETH path.
    function incinerate(
        uint256[10] calldata amounts,
        bool toEth,
        uint256 minUsdgOut,
        uint256 minWethOut,
        uint256 deadline
    ) external nonReentrant returns (uint256 usdgOut, uint256 wethOut, uint256 feePaid) {
        if (block.timestamp > deadline) revert DeadlineExpired();
        (usdgOut, wethOut, feePaid,) =
            _execute(_pullRoutes(amounts), toEth ? OUT_ETH : OUT_USDG, minUsdgOut, minWethOut, 0, deadline);
    }

    /// @notice Same as `incinerate`, but first applies an EIP-2612 permit
    /// signature per stock - so a wallet without transaction batching needs
    /// zero approval transactions: ten gasless signatures, one transaction.
    /// @dev Permit calls are try/catch'd: a permit already consumed by a
    /// front-runner is harmless when the resulting allowance covers the pull;
    /// any genuinely missing allowance still reverts atomically at transfer.
    function incinerateWithPermits(
        uint256[10] calldata amounts,
        StockPermit[10] calldata permits,
        bool toEth,
        uint256 minUsdgOut,
        uint256 minWethOut,
        uint256 deadline
    ) external nonReentrant returns (uint256 usdgOut, uint256 wethOut, uint256 feePaid) {
        if (block.timestamp > deadline) revert DeadlineExpired();
        _applyRoutePermits(amounts, permits);
        (usdgOut, wethOut, feePaid,) =
            _execute(_pullRoutes(amounts), toEth ? OUT_ETH : OUT_USDG, minUsdgOut, minWethOut, 0, deadline);
    }

    /// @notice Sells the caller's floor stocks and reinvests the proceeds
    /// into $QUOTRON through the canonical router, delivered straight to the
    /// caller - every whole token draws a dark terminal. Permit slots are
    /// optional (zero deadline = none). The 2.5% service fee is taken in WETH
    /// before the buy; the canonical pool's own 3% trading fee applies to the
    /// buy leg, two-thirds of which pays hardwired holders.
    /// @param minWethOut Floor on net WETH after the service fee.
    /// @param minQuotronOut Floor on QUOTRON delivered by the router.
    function incinerateForQuotron(
        uint256[10] calldata amounts,
        StockPermit[10] calldata permits,
        uint256 minUsdgOut,
        uint256 minWethOut,
        uint256 minQuotronOut,
        uint256 deadline
    ) external nonReentrant returns (uint256 usdgOut, uint256 wethOut, uint256 feePaid, uint256 quotronOut) {
        if (block.timestamp > deadline) revert DeadlineExpired();
        _applyRoutePermits(amounts, permits);
        return _execute(_pullRoutes(amounts), OUT_QUOTRON, minUsdgOut, minWethOut, minQuotronOut, deadline);
    }

    // ── any tokenized stock (integration surface) ───────────────────

    /// @notice Sells any set of tokens with hookless V4 USDG pools to USDG or
    /// native ETH - the open integration surface for Robinhood Chain. The
    /// caller supplies each token's pool parameters; a wrong fee/tickSpacing
    /// simply reverts against the uninitialized pool. Output paths, min-out
    /// semantics, and the service fee match `incinerate` exactly.
    function incinerateAny(
        GenericSale[] calldata sales,
        bool toEth,
        uint256 minUsdgOut,
        uint256 minWethOut,
        uint256 deadline
    ) external nonReentrant returns (uint256 usdgOut, uint256 wethOut, uint256 feePaid) {
        if (block.timestamp > deadline) revert DeadlineExpired();
        (usdgOut, wethOut, feePaid,) =
            _execute(_pullGeneric(sales), toEth ? OUT_ETH : OUT_USDG, minUsdgOut, minWethOut, 0, deadline);
    }

    /// @notice `incinerateAny` with one EIP-2612 permit per sale entry
    /// (`permits.length` must equal `sales.length`; zero-deadline entries are
    /// skipped). Zero approval transactions for permit-capable tokens.
    function incinerateAnyWithPermits(
        GenericSale[] calldata sales,
        StockPermit[] calldata permits,
        bool toEth,
        uint256 minUsdgOut,
        uint256 minWethOut,
        uint256 deadline
    ) external nonReentrant returns (uint256 usdgOut, uint256 wethOut, uint256 feePaid) {
        if (block.timestamp > deadline) revert DeadlineExpired();
        if (permits.length != sales.length) revert PermitCountMismatch();
        _applyGenericPermits(sales, permits);
        (usdgOut, wethOut, feePaid,) =
            _execute(_pullGeneric(sales), toEth ? OUT_ETH : OUT_USDG, minUsdgOut, minWethOut, 0, deadline);
    }

    /// @notice `incinerateForQuotron` for any set of tokens with hookless V4
    /// USDG pools. `permits` may be empty, or one entry per sale.
    function incinerateAnyForQuotron(
        GenericSale[] calldata sales,
        StockPermit[] calldata permits,
        uint256 minUsdgOut,
        uint256 minWethOut,
        uint256 minQuotronOut,
        uint256 deadline
    ) external nonReentrant returns (uint256 usdgOut, uint256 wethOut, uint256 feePaid, uint256 quotronOut) {
        if (block.timestamp > deadline) revert DeadlineExpired();
        if (permits.length != 0) {
            if (permits.length != sales.length) revert PermitCountMismatch();
            _applyGenericPermits(sales, permits);
        }
        return _execute(_pullGeneric(sales), OUT_QUOTRON, minUsdgOut, minWethOut, minQuotronOut, deadline);
    }

    // -- permit helpers -------------------------------------------------

    function _applyRoutePermits(uint256[10] calldata amounts, StockPermit[10] calldata permits) internal {
        for (uint256 i; i < 10; ++i) {
            StockPermit calldata p = permits[i];
            if (p.deadline == 0 || amounts[i] == 0) continue;
            try IERC2612Incinerator(routes[i].stock).permit(
                msg.sender, address(this), p.value, p.deadline, p.v, p.r, p.s
            ) {} catch {}
        }
    }

    function _applyGenericPermits(GenericSale[] calldata sales, StockPermit[] calldata permits) internal {
        for (uint256 i; i < sales.length; ++i) {
            StockPermit calldata p = permits[i];
            if (p.deadline == 0 || sales[i].amount == 0) continue;
            try IERC2612Incinerator(sales[i].token).permit(
                msg.sender, address(this), p.value, p.deadline, p.v, p.r, p.s
            ) {} catch {}
        }
    }

    // ── shared pull / execute / settle machinery ────────────────────

    function _pullRoutes(uint256[10] calldata amounts) internal returns (GenericSale[] memory sales) {
        sales = new GenericSale[](10);
        uint256 count;
        for (uint256 i; i < 10; ++i) {
            if (amounts[i] == 0) continue;
            FloorRoute memory route = routes[i];
            uint256 received = _pullToken(route.stock, amounts[i]);
            if (received == 0) continue;
            sales[count++] = GenericSale(route.stock, route.fee, route.tickSpacing, received, route.venue);
        }
        assembly {
            mstore(sales, count)
        }
    }

    function _pullGeneric(GenericSale[] calldata requested) internal returns (GenericSale[] memory sales) {
        sales = new GenericSale[](requested.length);
        uint256 count;
        for (uint256 i; i < requested.length; ++i) {
            GenericSale calldata sale = requested[i];
            if (sale.amount == 0) continue;
            // USDG cannot be "sold to USDG"; a pulled balance would strand.
            if (sale.token == usdg || sale.token == address(0)) revert InvalidSaleToken();
            if (sale.venue > VENUE_V3) revert InvalidVenue();
            uint256 received = _pullToken(sale.token, sale.amount);
            if (received == 0) continue;
            sales[count++] = GenericSale(sale.token, sale.fee, sale.tickSpacing, received, sale.venue);
        }
        assembly {
            mstore(sales, count)
        }
    }

    function _pullToken(address token, uint256 amount) internal returns (uint256 received) {
        if (amount == type(uint256).max) {
            amount = IERC20Incinerator(token).balanceOf(msg.sender);
            if (amount == 0) return 0;
        }
        if (amount > uint256(type(int256).max)) revert AmountOverflow();

        uint256 before = IERC20Incinerator(token).balanceOf(address(this));
        _safeTransferFrom(token, msg.sender, address(this), amount);
        received = IERC20Incinerator(token).balanceOf(address(this)) - before;
        if (received > uint256(type(int256).max)) revert AmountOverflow();
    }

    function _execute(
        GenericSale[] memory sales,
        uint8 mode,
        uint256 minUsdgOut,
        uint256 minWethOut,
        uint256 minQuotronOut,
        uint256 deadline
    ) internal returns (uint256 usdgOut, uint256 wethOut, uint256 feePaid, uint256 quotronOut) {
        if (sales.length == 0) revert NothingToIncinerate();
        usdgOut = _sellAll(sales);

        if (mode == OUT_USDG) {
            feePaid = _deliverUsdg(usdgOut, minUsdgOut);
            emit Incinerated(msg.sender, usdgOut, 0, feePaid, false);
            return (usdgOut, 0, feePaid, 0);
        }

        if (usdgOut < minUsdgOut) revert SlippageExceeded();
        (wethOut, feePaid) = _convertToEth(usdgOut, minWethOut);
        uint256 netWeth = wethOut - feePaid;

        if (mode == OUT_QUOTRON) {
            quotronOut = _buyQuotron(netWeth, minQuotronOut, deadline);
            emit IncineratedForQuotron(msg.sender, usdgOut, wethOut, feePaid, quotronOut);
            return (usdgOut, wethOut, feePaid, quotronOut);
        }

        (bool ok,) = msg.sender.call{value: netWeth}("");
        if (!ok) revert NativeTransferFailed();
        emit Incinerated(msg.sender, usdgOut, wethOut, feePaid, true);
    }

    /// @dev V3-venue sales go straight through the canonical V3 router; the
    /// V4-venue sales share one pool-manager unlock.
    function _sellAll(GenericSale[] memory sales) internal returns (uint256 usdgOut) {
        GenericSale[] memory v4Sales = new GenericSale[](sales.length);
        uint256 v4Count;
        for (uint256 i; i < sales.length; ++i) {
            if (sales[i].venue == VENUE_V3) {
                usdgOut += _sellV3(sales[i]);
            } else {
                v4Sales[v4Count++] = sales[i];
            }
        }
        if (v4Count != 0) {
            assembly {
                mstore(v4Sales, v4Count)
            }
            bytes memory result = poolManager.unlock(abi.encode(msg.sender, v4Sales));
            usdgOut += abi.decode(result, (uint256));
        }
    }

    /// @dev USDG path: carve the fee, enforce the net floor, pay out.
    function _deliverUsdg(uint256 usdgOut, uint256 minUsdgOut) internal returns (uint256 feePaid) {
        feePaid = (usdgOut * FEE_BPS) / 10_000;
        uint256 netUsdg = usdgOut - feePaid;
        if (netUsdg < minUsdgOut) revert SlippageExceeded();
        if (feePaid != 0) _safeTransfer(usdg, FEE_RECIPIENT, feePaid);
        _safeTransfer(usdg, msg.sender, netUsdg);
    }

    /// @dev USDG -> WETH through the canonical V3 hop with full-consumption
    /// enforcement; the fee is carved in WETH and the net is unwrapped to
    /// ETH, held here for the caller's delivery leg.
    function _convertToEth(uint256 usdgOut, uint256 minWethOut)
        internal
        returns (uint256 wethOut, uint256 feePaid)
    {
        _forceApprove(usdg, address(v3Router), usdgOut);
        uint256 beforeUsdg = IERC20Incinerator(usdg).balanceOf(address(this));
        uint256 beforeWeth = IERC20Incinerator(weth).balanceOf(address(this));
        uint256 reported = v3Router.exactInputSingle(
            IV3ExactInputIncinerator.ExactInputSingleParams({
                tokenIn: usdg,
                tokenOut: weth,
                fee: wethUsdgFee,
                recipient: address(this),
                amountIn: usdgOut,
                amountOutMinimum: minWethOut,
                sqrtPriceLimitX96: 0
            })
        );
        _forceApprove(usdg, address(v3Router), 0);
        // Exact-input V3 swaps consume less than amountIn when the pool's
        // WETH side is exhausted; the remainder would strand here forever.
        if (beforeUsdg - IERC20Incinerator(usdg).balanceOf(address(this)) != usdgOut) {
            revert PartialFill();
        }
        wethOut = IERC20Incinerator(weth).balanceOf(address(this)) - beforeWeth;
        feePaid = (wethOut * FEE_BPS) / 10_000;
        uint256 netWeth = wethOut - feePaid;
        if (netWeth < minWethOut || reported < minWethOut) revert SlippageExceeded();
        if (feePaid != 0) _safeTransfer(weth, FEE_RECIPIENT, feePaid);
        IWethIncinerator(weth).withdraw(netWeth);
    }

    /// @dev Reinvest: the canonical router delivers QUOTRON straight to the
    /// caller (whole tokens materialize dark terminals there). Exact-input
    /// buys settle the full ETH amount, so no refund ever returns here; any
    /// ETH that reaches this contract by other means is the Safe's via
    /// `rescueNative`, never a later caller's.
    function _buyQuotron(uint256 netWeth, uint256 minQuotronOut, uint256 deadline)
        internal
        returns (uint256 quotronOut)
    {
        quotronOut = quotronRouter.buyExactEth{value: netWeth}(
            minQuotronOut == 0 ? 1 : minQuotronOut, msg.sender, deadline
        );
    }

    /// @dev One exact-input V3 sale: token -> USDG through the canonical V3
    /// router, with the same full-consumption policy as the V4 leg.
    function _sellV3(GenericSale memory sale) internal returns (uint256 saleUsdg) {
        _forceApprove(sale.token, address(v3Router), sale.amount);
        uint256 beforeToken = IERC20Incinerator(sale.token).balanceOf(address(this));
        uint256 beforeUsdg = IERC20Incinerator(usdg).balanceOf(address(this));
        v3Router.exactInputSingle(
            IV3ExactInputIncinerator.ExactInputSingleParams({
                tokenIn: sale.token,
                tokenOut: usdg,
                fee: sale.fee,
                recipient: address(this),
                amountIn: sale.amount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            })
        );
        _forceApprove(sale.token, address(v3Router), 0);
        if (beforeToken - IERC20Incinerator(sale.token).balanceOf(address(this)) != sale.amount) {
            revert PartialFill();
        }
        saleUsdg = IERC20Incinerator(usdg).balanceOf(address(this)) - beforeUsdg;
        emit StockIncinerated(msg.sender, sale.token, sale.amount, saleUsdg);
    }

    /// @dev Executes every V4-venue token -> USDG swap inside a single
    /// pool-manager unlock. Tokens are settled per swap; the aggregate USDG is taken once.
    /// All pools are hookless: the floor routes are constructor-asserted and
    /// the generic path builds keys with the zero hook address.
    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender != address(poolManager)) revert NotPoolManager();
        (address account, GenericSale[] memory sales) = abi.decode(data, (address, GenericSale[]));

        uint256 totalUsdg;
        for (uint256 i; i < sales.length; ++i) {
            GenericSale memory sale = sales[i];
            uint256 amountIn = sale.amount;

            PoolKey memory key = _key(usdg, sale.token, sale.fee, sale.tickSpacing, address(0));
            bool zeroForOne = Currency.unwrap(key.currency0) == sale.token;

            BalanceDelta delta = poolManager.swap(
                key,
                SwapParams({
                    zeroForOne: zeroForOne,
                    amountSpecified: -int256(amountIn),
                    sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
                }),
                ""
            );

            int128 amount0 = delta.amount0();
            int128 amount1 = delta.amount1();
            uint256 saleUsdg;
            uint256 consumed;
            if (amount0 < 0) {
                uint256 amount = uint256(uint128(-amount0));
                _settle(key.currency0, amount);
                if (Currency.unwrap(key.currency0) == sale.token) consumed = amount;
            }
            if (amount1 < 0) {
                uint256 amount = uint256(uint128(-amount1));
                _settle(key.currency1, amount);
                if (Currency.unwrap(key.currency1) == sale.token) consumed = amount;
            }
            if (amount0 > 0 && Currency.unwrap(key.currency0) == usdg) saleUsdg = uint256(uint128(amount0));
            if (amount1 > 0 && Currency.unwrap(key.currency1) == usdg) saleUsdg = uint256(uint128(amount1));

            // An exact-input swap that exhausts pool liquidity consumes less
            // than the full amount; the remainder would strand here forever.
            // Revert atomically instead, matching the canonical router's
            // exact-input policy.
            if (consumed != amountIn) revert PartialFill();

            totalUsdg += saleUsdg;
            emit StockIncinerated(account, sale.token, amountIn, saleUsdg);
        }

        if (totalUsdg != 0) {
            poolManager.take(Currency.wrap(usdg), address(this), totalUsdg);
        }
        return abi.encode(totalUsdg);
    }

    receive() external payable {
        // WETH unwraps are the only ETH this contract ever expects to be
        // handed; the router never refunds on exact-input buys.
        if (msg.sender != weth) revert UnexpectedEth();
    }

    /// @notice Permissionless sweep of any token stuck on this contract to
    /// the admin Safe. The contract holds balances only while an incinerate
    /// is executing, and the reentrancy lock keeps this function out of that
    /// window - so a rescue can only ever move stranded funds (donations,
    /// tokens sent here by mistake), never a user's in-flight proceeds.
    function rescue(address token) external nonReentrant {
        uint256 amount = IERC20Incinerator(token).balanceOf(address(this));
        if (amount == 0) return;
        _safeTransfer(token, FEE_RECIPIENT, amount);
        emit Rescued(token, amount);
    }

    /// @notice Permissionless sweep of force-sent ETH (e.g. selfdestruct) to
    /// the admin Safe. Same in-flight protection as `rescue`.
    function rescueNative() external nonReentrant {
        uint256 amount = address(this).balance;
        if (amount == 0) return;
        (bool ok,) = FEE_RECIPIENT.call{value: amount}("");
        if (!ok) revert NativeTransferFailed();
        emit Rescued(address(0), amount);
    }

    function _settle(Currency currency, uint256 amount) internal {
        poolManager.sync(currency);
        _safeTransfer(Currency.unwrap(currency), address(poolManager), amount);
        // Require the credit to land locally and exactly: a token that hijacks
        // the synced-currency slot mid-transfer would otherwise only be caught
        // by the pool manager's global delta check at unlock exit.
        if (poolManager.settle() != amount) revert SettleMismatch();
    }

    function _key(address tokenA, address tokenB, uint24 fee, int24 tickSpacing, address hooks)
        internal
        pure
        returns (PoolKey memory)
    {
        (address currency0, address currency1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        return PoolKey({
            currency0: Currency.wrap(currency0),
            currency1: Currency.wrap(currency1),
            fee: fee,
            tickSpacing: tickSpacing,
            hooks: IHooks(hooks)
        });
    }

    function _forceApprove(address token, address spender, uint256 amount) internal {
        _safeApprove(token, spender, 0);
        if (amount != 0) _safeApprove(token, spender, amount);
    }

    function _safeApprove(address token, address spender, uint256 amount) internal {
        (bool ok, bytes memory data) = token.call(abi.encodeCall(IERC20Incinerator.approve, (spender, amount)));
        if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) revert TokenTransferFailed();
    }

    function _safeTransfer(address token, address to, uint256 amount) internal {
        (bool ok, bytes memory data) = token.call(abi.encodeCall(IERC20Incinerator.transfer, (to, amount)));
        if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) revert TokenTransferFailed();
    }

    function _safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        (bool ok, bytes memory data) = token.call(abi.encodeCall(IERC20Incinerator.transferFrom, (from, to, amount)));
        if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) revert TokenTransferFailed();
    }
}
