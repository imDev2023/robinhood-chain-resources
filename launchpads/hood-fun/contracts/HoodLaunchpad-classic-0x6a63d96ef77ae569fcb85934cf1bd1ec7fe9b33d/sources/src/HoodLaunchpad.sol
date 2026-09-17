// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {HoodToken} from "./HoodToken.sol";
import {IUniswapV2Factory, IUniswapV2Pair, IWETH} from "./interfaces/IUniswapV2.sol";
import {IHoodMigrator} from "./interfaces/IV3Migration.sol";

/// @title HoodLaunchpad
/// @notice hood.fun core: token factory, constant-product bonding curve with
///         virtual reserves, and permissionless graduation to Uniswap v2.
///
/// Curve model (pump.fun-style x*y=k with virtual reserves, quoted in ETH):
///   - Each token mints CURVE_SUPPLY + LP_SUPPLY to this contract.
///   - Buys pull from CURVE_SUPPLY against growing virtual ETH reserves.
///   - When the last curve token is sold the curve graduates; anyone may then
///     call `migrate`, which pairs LP_SUPPLY with the raised ETH on Uniswap v2
///     and burns the LP tokens, making the migrated liquidity unruggable.
///
/// Security posture:
///   - Tokens are transfer-locked (except to/from this contract) until
///     graduation, closing pre-created-pair / pre-seeded-liquidity exploits.
///   - Migration mints directly against the pair and tolerates a pre-existing
///     pair; stray donations are absorbed into burned LP.
///   - Checks-effects-interactions plus reentrancy guards on all mutators.
///   - Slippage bounds (minOut) on every trade; optional launch snipe guard
///     capping per-wallet buys during the first blocks after creation.
///   - No privileged withdrawals other than accrued protocol fees.
contract HoodLaunchpad is Ownable2Step, ReentrancyGuard {
    // ---------------------------------------------------------------- types

    struct Curve {
        uint128 virtualEth; // current virtual ETH reserve
        uint128 virtualTokens; // current virtual token reserve
        uint128 realEth; // ETH held for this curve (excludes protocol fees)
        uint128 realTokens; // tokens still purchasable on the curve
        address creator;
        uint48 createdAtBlock;
        bool graduated;
        bool migrated;
        uint16 tradeFeeBps; // creator-chosen fee on buys/sells for THIS token
    }

    struct Config {
        uint128 virtualEthSeed; // initial virtual ETH reserve for new curves
        uint64 creationFee; // flat fee to create a token
        uint16 defaultTradeFeeBps; // suggested default fee if creator picks none
        uint64 migrationFee; // flat fee taken from raised ETH at migration
        uint16 migrationFeeBps; // percentage fee on raised ETH at migration
        uint16 guardBlocks; // snipe-guard window after creation
        uint16 guardMaxWalletBps; // max curve-supply share one wallet may buy in window
        uint16 creatorFeeShareBps; // creator's share of every fee (trades + migration)
        bool vanityEnforced; // require token addresses to end in 0x600d
    }

    // ------------------------------------------------------------ constants

    uint256 public constant TOTAL_SUPPLY = 1_000_000_000e18;
    uint256 public constant CURVE_SUPPLY = 800_000_000e18;
    uint256 public constant LP_SUPPLY = TOTAL_SUPPLY - CURVE_SUPPLY;
    // Tuned so a launch starts ~$4k and graduates ~$44k market cap
    // (2.81 ETH seed → ~26.9 ETH graduation MC; ratio ~11x).
    uint256 public constant VIRTUAL_TOKEN_SEED = 1_145_000_000e18;
    uint256 internal constant BPS = 10_000;
    uint256 public constant MIN_TRADE_FEE_BPS = 100; // floor, 1%
    uint256 public constant MAX_TRADE_FEE_BPS = 500; // hard cap, 5%
    uint256 public constant MAX_MIGRATION_FEE_BPS = 1000; // hard cap, 10% of raise
    address internal constant LP_BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    /// @dev Brand suffix: every hood.fun token address ends in 0x600d.
    uint256 internal constant VANITY_SUFFIX = 0x600d;

    // -------------------------------------------------------------- storage

    IUniswapV2Factory public immutable uniswapFactory;
    IWETH public immutable weth;

    Config public config;
    uint256 public protocolFeesAccrued;

    /// @dev Pluggable graduation target. When set, migrate() hands the LP supply
    ///      and raised ETH to this contract (Uniswap v3 + eternal lock) instead
    ///      of doing the built-in v2 pair + LP burn. Owner-settable so migration
    ///      logic can evolve (v3 today, v4 later) without redeploying this
    ///      launchpad. address(0) == use the legacy v2-burn path.
    address public migrator;

    mapping(address token => Curve) public curves;
    mapping(address token => mapping(address wallet => uint256)) public guardBought;
    mapping(address token => uint256) public creatorFees;
    address[] public allTokens;

    /// @dev Partner launchpads (e.g. bundler platforms) approved to launch on
    ///      this curve via createTokenFor. feeShareBps is the platform's share
    ///      of the PROTOCOL's fee cut on its tokens — the creator's share is
    ///      never touched. Revocable: an unapproved platform stops accruing
    ///      but keeps whatever it already earned.
    struct Platform {
        bool approved;
        uint16 feeShareBps;
    }

    mapping(address platform => Platform) public platforms;
    mapping(address token => address) public tokenPlatform;
    mapping(address platform => uint256) public platformFees;

    // --------------------------------------------------------------- events

    event TokenCreated(
        address indexed token,
        address indexed creator,
        string name,
        string symbol,
        string metadataURI,
        uint256 virtualEth,
        uint256 virtualTokens,
        uint256 curveSupply
    );

    /// @dev Post-trade virtual reserves are emitted so indexers can derive
    ///      price/OHLCV without extra RPC reads (Uniswap Sync-style).
    event Trade(
        address indexed token,
        address indexed trader,
        bool isBuy,
        uint256 ethAmount,
        uint256 tokenAmount,
        uint256 fee,
        uint256 virtualEthAfter,
        uint256 virtualTokensAfter
    );

    event Graduated(address indexed token, uint256 raisedEth);
    event Migrated(
        address indexed token, address indexed pair, uint256 ethLiquidity, uint256 tokenLiquidity, uint256 lpBurned
    );
    event ConfigUpdated(Config config);
    event MigratorSet(address indexed migrator);
    event FeesWithdrawn(address indexed to, uint256 amount);
    event CreatorFeesClaimed(address indexed token, address indexed creator, uint256 amount);
    event PlatformSet(address indexed platform, bool approved, uint16 feeShareBps);
    event PlatformLaunch(address indexed token, address indexed platform, address indexed creator);
    event PlatformFeesClaimed(address indexed platform, uint256 amount);

    // --------------------------------------------------------------- errors

    error UnknownToken();
    error AlreadyGraduated();
    error NotGraduated();
    error AlreadyMigrated();
    error ZeroAmount();
    error SlippageExceeded();
    error InsufficientPayment();
    error SnipeGuardExceeded();
    error FeeTooHigh();
    error EthTransferFailed();
    error NothingToWithdraw();
    error BadVanitySalt();
    error NotCreator();
    error NotPlatform();
    error ZeroAddress();

    // ---------------------------------------------------------- constructor

    constructor(address uniswapFactory_, address weth_, address owner_) Ownable(owner_) {
        uniswapFactory = IUniswapV2Factory(uniswapFactory_);
        weth = IWETH(weth_);
        config = Config({
            virtualEthSeed: 2.81 ether,
            creationFee: 0,
            defaultTradeFeeBps: 100, // 1% default; creators may pick 0..MAX
            migrationFee: 0.05 ether,
            migrationFeeBps: 300, // 3% of the raise at migration
            guardBlocks: 100,
            guardMaxWalletBps: 1000, // 10% of curve supply per wallet in the window
            creatorFeeShareBps: 5000, // creator earns 50% of every fee
            vanityEnforced: true
        });
    }

    // ---------------------------------------------------------------- admin

    function setConfig(Config calldata newConfig) external onlyOwner {
        if (newConfig.defaultTradeFeeBps > MAX_TRADE_FEE_BPS) revert FeeTooHigh();
        if (newConfig.migrationFeeBps > MAX_MIGRATION_FEE_BPS) revert FeeTooHigh();
        if (newConfig.creatorFeeShareBps > BPS) revert FeeTooHigh();
        if (newConfig.virtualEthSeed == 0) revert ZeroAmount();
        config = newConfig;
        emit ConfigUpdated(newConfig);
    }

    /// @notice Set (or clear) the pluggable graduation migrator. When set,
    ///         migrate() routes liquidity to it (Uniswap v3 + eternal lock);
    ///         when address(0), migrate() uses the legacy v2 pair + LP burn.
    ///         Only affects coins that graduate after the change.
    function setMigrator(address migrator_) external onlyOwner {
        migrator = migrator_;
        emit MigratorSet(migrator_);
    }

    /// @notice Approve (or revoke) a partner launchpad and set its share of
    ///         the protocol fee cut on tokens it launches. Share applies at
    ///         trade time, so adjustments affect future trades only.
    function setPlatform(address platform, bool approved, uint16 feeShareBps) external onlyOwner {
        if (platform == address(0)) revert ZeroAddress();
        if (feeShareBps > BPS) revert FeeTooHigh();
        platforms[platform] = Platform({approved: approved, feeShareBps: feeShareBps});
        emit PlatformSet(platform, approved, feeShareBps);
    }

    function withdrawFees(address to) external onlyOwner nonReentrant {
        uint256 amount = protocolFeesAccrued;
        if (amount == 0) revert NothingToWithdraw();
        protocolFeesAccrued = 0;
        (bool ok,) = to.call{value: amount}("");
        if (!ok) revert EthTransferFailed();
        emit FeesWithdrawn(to, amount);
    }

    /// @notice Claim the creator's accrued share of trade fees for a token.
    function claimCreatorFees(address token) external nonReentrant {
        if (curves[token].creator != msg.sender) revert NotCreator();
        uint256 amount = creatorFees[token];
        if (amount == 0) revert NothingToWithdraw();
        creatorFees[token] = 0;
        (bool ok,) = msg.sender.call{value: amount}("");
        if (!ok) revert EthTransferFailed();
        emit CreatorFeesClaimed(token, msg.sender, amount);
    }

    /// @notice Claim the calling platform's accrued fee share.
    function claimPlatformFees() external nonReentrant {
        uint256 amount = platformFees[msg.sender];
        if (amount == 0) revert NothingToWithdraw();
        platformFees[msg.sender] = 0;
        (bool ok,) = msg.sender.call{value: amount}("");
        if (!ok) revert EthTransferFailed();
        emit PlatformFeesClaimed(msg.sender, amount);
    }

    function _accrueFee(address token, uint256 fee) internal {
        uint256 creatorCut = (fee * config.creatorFeeShareBps) / BPS;
        if (creatorCut != 0) creatorFees[token] += creatorCut;
        uint256 protocolCut = fee - creatorCut;
        address platform = tokenPlatform[token];
        if (platform != address(0)) {
            Platform memory p = platforms[platform];
            if (p.approved && p.feeShareBps != 0) {
                uint256 platformCut = (protocolCut * p.feeShareBps) / BPS;
                if (platformCut != 0) {
                    platformFees[platform] += platformCut;
                    protocolCut -= platformCut;
                }
            }
        }
        protocolFeesAccrued += protocolCut;
    }

    // --------------------------------------------------------------- create

    /// @notice Deploy a new token and its bonding curve. Any ETH sent beyond
    ///         the creation fee is used as the creator's initial buy, which
    ///         executes atomically inside this transaction — a guaranteed
    ///         dev-first-buy that cannot be front-run.
    /// @param salt CREATE2 salt (mixed with msg.sender so it cannot be stolen
    ///        from the mempool). When vanity enforcement is on, grind salts
    ///        client-side until the predicted address ends in 0x600d.
    /// @param tradeFeeBps creator-chosen buy/sell fee for this token, capped at
    ///        MAX_TRADE_FEE_BPS. Lower fee = cheaper to trade (attracts traders);
    ///        the creator still earns their share of whatever they set.
    function createToken(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        uint256 minTokensOut,
        bytes32 salt,
        uint16 tradeFeeBps
    ) external payable nonReentrant returns (address token) {
        return _create(msg.sender, name, symbol, metadataURI, minTokensOut, salt, tradeFeeBps);
    }

    /// @notice Partner-launchpad entrypoint: an approved platform launches a
    ///         token on this curve on behalf of `creator`, using its own stack
    ///         (bundlers, relayers, custom UX). The curve, graduation, LP burn
    ///         and creator fee share are identical to a native launch; the
    ///         platform additionally earns its registered share of the
    ///         protocol fee cut on every trade of this token, forever.
    ///         Salt is bound to the CALLING PLATFORM (grind against your own
    ///         address via predictTokenAddress(platformAddr, …)). The bundled
    ///         dev-buy credits `creator`, not the platform.
    function createTokenFor(
        address creator,
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        uint256 minTokensOut,
        bytes32 salt,
        uint16 tradeFeeBps
    ) external payable nonReentrant returns (address token) {
        if (!platforms[msg.sender].approved) revert NotPlatform();
        if (creator == address(0)) revert ZeroAddress();
        token = _create(creator, name, symbol, metadataURI, minTokensOut, salt, tradeFeeBps);
        tokenPlatform[token] = msg.sender;
        emit PlatformLaunch(token, msg.sender, creator);
    }

    function _create(
        address creator,
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        uint256 minTokensOut,
        bytes32 salt,
        uint16 tradeFeeBps
    ) internal returns (address token) {
        Config memory cfg = config;
        if (msg.value < cfg.creationFee) revert InsufficientPayment();
        if (tradeFeeBps < MIN_TRADE_FEE_BPS || tradeFeeBps > MAX_TRADE_FEE_BPS) revert FeeTooHigh();
        protocolFeesAccrued += cfg.creationFee;

        token = address(
            new HoodToken{salt: keccak256(abi.encodePacked(msg.sender, salt))}(name, symbol, TOTAL_SUPPLY)
        );
        if (cfg.vanityEnforced && uint160(token) & 0xffff != VANITY_SUFFIX) revert BadVanitySalt();
        curves[token] = Curve({
            virtualEth: cfg.virtualEthSeed,
            virtualTokens: uint128(VIRTUAL_TOKEN_SEED),
            realEth: 0,
            realTokens: uint128(CURVE_SUPPLY),
            creator: creator,
            createdAtBlock: uint48(block.number),
            graduated: false,
            migrated: false,
            tradeFeeBps: tradeFeeBps
        });
        allTokens.push(token);

        emit TokenCreated(
            token, creator, name, symbol, metadataURI, cfg.virtualEthSeed, VIRTUAL_TOKEN_SEED, CURVE_SUPPLY
        );

        uint256 buyEth = msg.value - cfg.creationFee;
        if (buyEth > 0) {
            // Creator's bundled dev-buy is exempt from the snipe guard: the
            // token did not exist before this tx, so there is nothing to snipe.
            _buy(token, creator, buyEth, minTokensOut, cfg, true);
        } else if (minTokensOut != 0) {
            revert SlippageExceeded();
        }
    }

    // ---------------------------------------------------------------- trade

    function buy(address token, uint256 minTokensOut) external payable nonReentrant {
        if (msg.value == 0) revert ZeroAmount();
        _requireLiveCurve(token);
        _buy(token, msg.sender, msg.value, minTokensOut, config, false);
    }

    /// @notice Buy on the curve and credit `recipient` instead of the payer.
    ///         The payer (msg.sender) provides the ETH and receives any refund;
    ///         the tokens and the per-wallet snipe-guard accounting land on
    ///         `recipient`. This is the primitive the HoodBundler uses to do a
    ///         create + many buys atomically in one transaction — the guard
    ///         still binds each recipient, so it is not a bypass.
    function buyFor(address token, address recipient, uint256 minTokensOut) external payable nonReentrant {
        if (msg.value == 0) revert ZeroAmount();
        if (recipient == address(0)) revert ZeroAddress();
        _requireLiveCurve(token);
        _buy(token, recipient, msg.value, minTokensOut, config, false);
    }

    function sell(address token, uint256 tokenAmount, uint256 minEthOut) external nonReentrant {
        if (tokenAmount == 0) revert ZeroAmount();
        Curve storage c = _requireLiveCurve(token);

        uint256 vEth = c.virtualEth;
        uint256 vTok = c.virtualTokens;
        uint256 ethOut = vEth - Math.ceilDiv(vEth * vTok, vTok + tokenAmount);
        uint256 fee = (ethOut * c.tradeFeeBps) / BPS;
        uint256 ethToSeller = ethOut - fee;
        if (ethToSeller < minEthOut || ethToSeller == 0) revert SlippageExceeded();

        c.virtualEth = uint128(vEth - ethOut);
        c.virtualTokens = uint128(vTok + tokenAmount);
        c.realEth = uint128(c.realEth - ethOut);
        c.realTokens = uint128(c.realTokens + tokenAmount);
        _accrueFee(token, fee);

        emit Trade(token, msg.sender, false, ethToSeller, tokenAmount, fee, c.virtualEth, c.virtualTokens);

        require(HoodToken(token).transferFrom(msg.sender, address(this), tokenAmount), "TRANSFER_FAILED");
        (bool ok,) = msg.sender.call{value: ethToSeller}("");
        if (!ok) revert EthTransferFailed();
    }

    function _buy(
        address token,
        address recipient,
        uint256 ethIn,
        uint256 minTokensOut,
        Config memory cfg,
        bool exemptGuard
    ) internal {
        Curve storage c = curves[token];
        uint256 feeBps = c.tradeFeeBps;

        uint256 vEth = c.virtualEth;
        uint256 vTok = c.virtualTokens;
        uint256 realTokens = c.realTokens;

        uint256 fee = (ethIn * feeBps) / BPS;
        uint256 ethForCurve = ethIn - fee;
        uint256 tokensOut = vTok - (vEth * vTok) / (vEth + ethForCurve);
        uint256 refund = 0;

        if (tokensOut >= realTokens) {
            // Final buy: clamp to remaining supply, charge exactly what it
            // costs (fee grossed up), refund the rest.
            tokensOut = realTokens;
            uint256 newVTok = vTok - realTokens;
            uint256 exactEth = Math.ceilDiv(vEth * vTok, newVTok) - vEth;
            // Ceil rounding can land 1 wei above what was sent; never charge
            // more than msg.value.
            if (exactEth > ethForCurve) exactEth = ethForCurve;
            uint256 grossEth = feeBps == 0 ? exactEth : Math.ceilDiv(exactEth * BPS, BPS - feeBps);
            if (grossEth > ethIn) grossEth = ethIn;
            refund = ethIn - grossEth;
            fee = grossEth - exactEth;
            ethForCurve = exactEth;
        }

        if (tokensOut < minTokensOut || tokensOut == 0) revert SlippageExceeded();

        if (!exemptGuard && block.number < c.createdAtBlock + cfg.guardBlocks && cfg.guardMaxWalletBps != 0) {
            uint256 bought = guardBought[token][recipient] + tokensOut;
            if (bought > (CURVE_SUPPLY * cfg.guardMaxWalletBps) / BPS) revert SnipeGuardExceeded();
            guardBought[token][recipient] = bought;
        }

        c.virtualEth = uint128(vEth + ethForCurve);
        c.virtualTokens = uint128(vTok - tokensOut);
        c.realEth = uint128(c.realEth + ethForCurve);
        c.realTokens = uint128(realTokens - tokensOut);
        _accrueFee(token, fee);

        emit Trade(token, recipient, true, ethForCurve + fee, tokensOut, fee, c.virtualEth, c.virtualTokens);

        if (c.realTokens == 0) {
            c.graduated = true;
            emit Graduated(token, c.realEth);
        }

        require(HoodToken(token).transfer(recipient, tokensOut), "TRANSFER_FAILED");
        if (refund > 0) {
            // Unused ETH returns to whoever funded the buy (the platform on
            // a createTokenFor dev-buy), not the token recipient.
            (bool ok,) = msg.sender.call{value: refund}("");
            if (!ok) revert EthTransferFailed();
        }
    }

    // -------------------------------------------------------------- migrate

    /// @notice Move a graduated curve's liquidity to its DEX pool.
    ///         Permissionless: anyone may call.
    ///
    ///         If a `migrator` is set, liquidity is routed to it — Uniswap v3 at
    ///         the 1% fee tier with the position locked eternally in the
    ///         hood.fun Liquidity Locker, so the 1% pool fee keeps accruing and
    ///         is split 50/50 creator/protocol forever.
    ///         If no migrator is set, the legacy path creates a Uniswap v2 pair
    ///         and burns the LP tokens to 0xdead.
    function migrate(address token) external nonReentrant returns (address pool) {
        Curve storage c = curves[token];
        if (c.creator == address(0)) revert UnknownToken();
        if (!c.graduated) revert NotGraduated();
        if (c.migrated) revert AlreadyMigrated();
        c.migrated = true;

        uint256 ethLiq = c.realEth;
        uint256 migrationFee = config.migrationFee + (ethLiq * config.migrationFeeBps) / BPS;
        if (migrationFee < ethLiq) {
            ethLiq -= migrationFee;
            // creator gets their share of the migration fee, same as trade fees
            _accrueFee(token, migrationFee);
        }
        c.realEth = 0;

        HoodToken(token).unlock();

        address _migrator = migrator;
        if (_migrator != address(0)) {
            // Pluggable path: hand the LP supply + raised ETH to the migrator,
            // which builds the v3 pool and eternal-locks the position. Fees are
            // earned by the locked position forever, not trapped in burned LP.
            require(HoodToken(token).transfer(_migrator, LP_SUPPLY), "TRANSFER_FAILED");
            pool = IHoodMigrator(_migrator).migrate{value: ethLiq}(token, c.creator);
            emit Migrated(token, pool, ethLiq, LP_SUPPLY, 0);
        } else {
            // Legacy path: Uniswap v2 pair + LP burn.
            pool = uniswapFactory.getPair(token, address(weth));
            if (pool == address(0)) {
                pool = uniswapFactory.createPair(token, address(weth));
            }

            weth.deposit{value: ethLiq}();
            require(weth.transfer(pool, ethLiq), "TRANSFER_FAILED");
            require(HoodToken(token).transfer(pool, LP_SUPPLY), "TRANSFER_FAILED");
            uint256 liquidity = IUniswapV2Pair(pool).mint(address(this));
            require(IUniswapV2Pair(pool).transfer(LP_BURN_ADDRESS, liquidity), "TRANSFER_FAILED");

            emit Migrated(token, pool, ethLiq, LP_SUPPLY, liquidity);
        }
    }

    // ---------------------------------------------------------------- views

    function quoteBuy(address token, uint256 ethIn)
        external
        view
        returns (uint256 tokensOut, uint256 fee, uint256 ethUsed)
    {
        Curve memory c = curves[token];
        if (c.creator == address(0)) revert UnknownToken();
        if (c.graduated || ethIn == 0) return (0, 0, 0);
        uint256 feeBps = c.tradeFeeBps;

        fee = (ethIn * feeBps) / BPS;
        uint256 ethForCurve = ethIn - fee;
        tokensOut = c.virtualTokens - (uint256(c.virtualEth) * c.virtualTokens) / (c.virtualEth + ethForCurve);
        ethUsed = ethIn;

        if (tokensOut >= c.realTokens) {
            tokensOut = c.realTokens;
            uint256 newVTok = c.virtualTokens - c.realTokens;
            uint256 exactEth = Math.ceilDiv(uint256(c.virtualEth) * c.virtualTokens, newVTok) - c.virtualEth;
            if (exactEth > ethForCurve) exactEth = ethForCurve;
            ethUsed = feeBps == 0 ? exactEth : Math.ceilDiv(exactEth * BPS, BPS - feeBps);
            if (ethUsed > ethIn) ethUsed = ethIn;
            fee = ethUsed - exactEth;
        }
    }

    function quoteSell(address token, uint256 tokenAmount) external view returns (uint256 ethOut, uint256 fee) {
        Curve memory c = curves[token];
        if (c.creator == address(0)) revert UnknownToken();
        if (c.graduated || tokenAmount == 0) return (0, 0);
        uint256 gross =
            c.virtualEth - Math.ceilDiv(uint256(c.virtualEth) * c.virtualTokens, c.virtualTokens + tokenAmount);
        fee = (gross * c.tradeFeeBps) / BPS;
        ethOut = gross - fee;
    }

    /// @notice Spot price in ETH wei per whole token (1e18 base units).
    function currentPrice(address token) external view returns (uint256) {
        Curve memory c = curves[token];
        if (c.creator == address(0)) revert UnknownToken();
        return (uint256(c.virtualEth) * 1e18) / c.virtualTokens;
    }

    /// @notice Curve progress toward graduation in basis points.
    function progressBps(address token) external view returns (uint256) {
        Curve memory c = curves[token];
        if (c.creator == address(0)) revert UnknownToken();
        return ((CURVE_SUPPLY - c.realTokens) * BPS) / CURVE_SUPPLY;
    }

    function tokenCount() external view returns (uint256) {
        return allTokens.length;
    }

    function getCurve(address token) external view returns (Curve memory) {
        return curves[token];
    }

    /// @notice Provenance check for integrators and indexers: true iff the
    ///         token was deployed by this launchpad.
    function isHoodToken(address token) external view returns (bool) {
        return curves[token].creator != address(0);
    }

    /// @notice Predicted CREATE2 address for a launch. Grind `salt` until the
    ///         result ends in 0x600d (when vanity enforcement is on).
    function predictTokenAddress(address creator, bytes32 salt, string calldata name, string calldata symbol)
        external
        view
        returns (address)
    {
        bytes32 initCodeHash =
            keccak256(abi.encodePacked(type(HoodToken).creationCode, abi.encode(name, symbol, TOTAL_SUPPLY)));
        bytes32 h = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), keccak256(abi.encodePacked(creator, salt)), initCodeHash)
        );
        return address(uint160(uint256(h)));
    }

    /// @notice Init code hash for client-side salt grinding (one RPC call,
    ///         then grind locally with keccak(0xff ++ launchpad ++ mixedSalt ++ hash)).
    function tokenInitCodeHash(string calldata name, string calldata symbol) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(type(HoodToken).creationCode, abi.encode(name, symbol, TOTAL_SUPPLY)));
    }

    /// @notice Paginated token listing for indexers (newest tokens last).
    function tokens(uint256 offset, uint256 limit) external view returns (address[] memory page) {
        uint256 n = allTokens.length;
        if (offset >= n) return new address[](0);
        uint256 end = offset + limit;
        if (end > n) end = n;
        page = new address[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            page[i - offset] = allTokens[i];
        }
    }

    // -------------------------------------------------------------- helpers

    function _requireLiveCurve(address token) internal view returns (Curve storage c) {
        c = curves[token];
        if (c.creator == address(0)) revert UnknownToken();
        if (c.graduated) revert AlreadyGraduated();
    }
}

library Math {
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a == 0 ? 0 : (a - 1) / b + 1;
    }
}
