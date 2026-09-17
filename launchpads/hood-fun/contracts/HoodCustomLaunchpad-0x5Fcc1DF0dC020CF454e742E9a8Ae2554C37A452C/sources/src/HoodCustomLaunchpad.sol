// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {HoodToken} from "./HoodToken.sol";
import {IUniswapV2Factory, IUniswapV2Pair, IWETH} from "./interfaces/IUniswapV2.sol";
import {IHoodMigrator} from "./interfaces/IV3Migration.sol";

/// @title HoodCustomLaunchpad
/// @notice hood.fun's public bonding-curve launchpad. A coin trades on an x*y=k
///         virtual-reserve curve, then graduates and MIGRATES into a locked
///         Uniswap v3 1% pool. Differs from the classic launchpad in:
///           1. Per-token custom TOTAL SUPPLY (1M … 1 quadrillion), chosen at
///              launch. Curve seeds scale with supply so the ETH economics stay
///              identical (same seed MC, same raise, same graduation MC) — only
///              the token count / price-per-token changes.
///           2. Fee split: 80% creator / 20% protocol-platform (vs 50/50).
///           3. No 0x600d vanity enforcement.
///         Anyone may createToken(); the createTokenFor() partner/bundle path
///         stays whitelisted (setPlatform) for Proxima + the hood.tools bundler.
///
/// @dev getCurve() returns the SAME 9-field tuple + same TokenCreated / Trade /
///      Graduated events as the classic launchpad, so the indexer/UI need only the
///      new address added. Per-token supply is kept in separate mappings so the
///      Curve tuple stays byte-identical.
contract HoodCustomLaunchpad is Ownable2Step, ReentrancyGuard {
    // ---------------------------------------------------------------- types

    struct Curve {
        uint128 virtualEth;
        uint128 virtualTokens;
        uint128 realEth;
        uint128 realTokens;
        address creator;
        uint48 createdAtBlock;
        bool graduated;
        bool migrated;
        uint16 tradeFeeBps;
    }

    struct Config {
        uint128 virtualEthSeed;
        uint64 creationFee;
        uint16 defaultTradeFeeBps;
        uint64 migrationFee;
        uint16 migrationFeeBps;
        uint16 guardBlocks;
        uint16 guardMaxWalletBps;
        uint16 creatorFeeShareBps;
        bool vanityEnforced;
    }

    // ------------------------------------------------------------ constants

    /// @dev The baseline the curve seeds are tuned for (same as the main
    ///      launchpad). Custom supplies scale the token-side seeds off these so
    ///      the ETH-denominated economics stay identical.
    uint256 public constant DEFAULT_TOTAL_SUPPLY = 1_000_000_000e18;
    uint256 public constant DEFAULT_VIRTUAL_TOKEN_SEED = 1_145_000_000e18;
    uint256 public constant CURVE_BPS = 8000; // 80% of supply sells on the curve, 20% → LP

    /// @dev Custom-supply bounds: 1 … 1 quadrillion whole tokens. The upper bound
    ///      keeps the scaled seeds inside uint128 and away from precision loss.
    uint256 public constant MIN_TOTAL_SUPPLY = 1e18; // 1 whole token
    uint256 public constant MAX_TOTAL_SUPPLY = 1_000_000_000_000_000e18;

    uint256 internal constant BPS = 10_000;
    uint256 public constant MIN_TRADE_FEE_BPS = 100;
    uint256 public constant MAX_TRADE_FEE_BPS = 500;
    uint256 public constant MAX_MIGRATION_FEE_BPS = 1000;
    address internal constant LP_BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint256 internal constant VANITY_SUFFIX = 0x600d;

    // -------------------------------------------------------------- storage

    IUniswapV2Factory public immutable uniswapFactory;
    IWETH public immutable weth;

    Config public config;
    uint256 public protocolFeesAccrued;
    address public migrator;

    mapping(address token => Curve) public curves;
    mapping(address token => mapping(address wallet => uint256)) public guardBought;
    mapping(address token => uint256) public creatorFees;
    address[] public allTokens;

    /// @dev Per-token supply split — stored OUTSIDE the Curve struct so getCurve
    ///      stays tuple-compatible with the main launchpad's indexer.
    mapping(address token => uint256) public tokenCurveSupply;
    mapping(address token => uint256) public tokenLpSupply;

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
    error BadSupply();

    // ---------------------------------------------------------- constructor

    constructor(address uniswapFactory_, address weth_, address owner_) Ownable(owner_) {
        uniswapFactory = IUniswapV2Factory(uniswapFactory_);
        weth = IWETH(weth_);
        config = Config({
            virtualEthSeed: 2.81 ether,
            creationFee: 0,
            defaultTradeFeeBps: 100,
            migrationFee: 0.05 ether,
            migrationFeeBps: 300,
            guardBlocks: 100,
            guardMaxWalletBps: 1000,
            creatorFeeShareBps: 8000, // 80% of every fee to the creator, 20% protocol/platform
            vanityEnforced: true // every launched token CA must end in 0x600d
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

    function setMigrator(address migrator_) external onlyOwner {
        migrator = migrator_;
        emit MigratorSet(migrator_);
    }

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

    function claimCreatorFees(address token) external nonReentrant {
        if (curves[token].creator != msg.sender) revert NotCreator();
        uint256 amount = creatorFees[token];
        if (amount == 0) revert NothingToWithdraw();
        creatorFees[token] = 0;
        (bool ok,) = msg.sender.call{value: amount}("");
        if (!ok) revert EthTransferFailed();
        emit CreatorFeesClaimed(token, msg.sender, amount);
    }

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

    /// @notice Deploy a custom-supply token + curve. `totalSupply_` sets the mint
    ///         (bounded MIN…MAX); the curve seeds scale so the ETH economics match
    ///         a standard launch. Any ETH beyond the creation fee is the creator's
    ///         atomic first buy. Caller must be an approved creator.
    function createToken(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        uint256 minTokensOut,
        bytes32 salt,
        uint16 tradeFeeBps,
        uint256 totalSupply_
    ) external payable nonReentrant returns (address token) {
        return _create(msg.sender, name, symbol, metadataURI, minTokensOut, salt, tradeFeeBps, totalSupply_);
    }

    /// @notice Partner-platform entrypoint (Proxima, hood.tools bundler, …). An
    ///         approved platform launches on behalf of `creator`. The salt binds
    ///         to the CALLING PLATFORM (grind against your own address). `creator`
    ///         must be an approved creator; the dev-buy credits `creator`.
    function createTokenFor(
        address creator,
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        uint256 minTokensOut,
        bytes32 salt,
        uint16 tradeFeeBps,
        uint256 totalSupply_
    ) external payable nonReentrant returns (address token) {
        if (!platforms[msg.sender].approved) revert NotPlatform();
        if (creator == address(0)) revert ZeroAddress();
        token = _create(creator, name, symbol, metadataURI, minTokensOut, salt, tradeFeeBps, totalSupply_);
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
        uint16 tradeFeeBps,
        uint256 totalSupply_
    ) internal returns (address token) {
        // Public launchpad — anyone may create with any supply in range. The
        // partner/bundle path (createTokenFor) stays whitelisted separately.
        if (totalSupply_ < MIN_TOTAL_SUPPLY || totalSupply_ > MAX_TOTAL_SUPPLY) revert BadSupply();

        Config memory cfg = config;
        if (msg.value < cfg.creationFee) revert InsufficientPayment();
        if (tradeFeeBps < MIN_TRADE_FEE_BPS || tradeFeeBps > MAX_TRADE_FEE_BPS) revert FeeTooHigh();
        protocolFeesAccrued += cfg.creationFee;

        // Scale the token-side seeds with supply → identical ETH economics.
        uint256 curveSupply_ = (totalSupply_ * CURVE_BPS) / BPS;
        uint256 lpSupply_ = totalSupply_ - curveSupply_;
        uint256 vTokSeed = (DEFAULT_VIRTUAL_TOKEN_SEED * totalSupply_) / DEFAULT_TOTAL_SUPPLY;

        token = address(new HoodToken{salt: keccak256(abi.encodePacked(msg.sender, salt))}(name, symbol, totalSupply_));
        if (cfg.vanityEnforced && uint160(token) & 0xffff != VANITY_SUFFIX) revert BadVanitySalt();

        curves[token] = Curve({
            virtualEth: cfg.virtualEthSeed,
            virtualTokens: uint128(vTokSeed),
            realEth: 0,
            realTokens: uint128(curveSupply_),
            creator: creator,
            createdAtBlock: uint48(block.number),
            graduated: false,
            migrated: false,
            tradeFeeBps: tradeFeeBps
        });
        tokenCurveSupply[token] = curveSupply_;
        tokenLpSupply[token] = lpSupply_;
        allTokens.push(token);

        emit TokenCreated(token, creator, name, symbol, metadataURI, cfg.virtualEthSeed, vTokSeed, curveSupply_);

        uint256 buyEth = msg.value - cfg.creationFee;
        if (buyEth > 0) {
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

    /// @notice Pay-and-credit-recipient buy. Whitelisted platforms (e.g. Proxima's
    ///         block-0 bundler) are snipe-guard EXEMPT here: a trusted, approved
    ///         platform can bundle across many wallets in the launch block/window
    ///         without the 10%-per-wallet cap. Everyone else's buyFor is guarded
    ///         exactly like a normal buy — the exemption is the whitelist privilege.
    function buyFor(address token, address recipient, uint256 minTokensOut) external payable nonReentrant {
        if (msg.value == 0) revert ZeroAmount();
        if (recipient == address(0)) revert ZeroAddress();
        _requireLiveCurve(token);
        bool exemptGuard = platforms[msg.sender].approved;
        _buy(token, recipient, msg.value, minTokensOut, config, exemptGuard);
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

    function _buy(address token, address recipient, uint256 ethIn, uint256 minTokensOut, Config memory cfg, bool exemptGuard)
        internal
    {
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
            tokensOut = realTokens;
            uint256 newVTok = vTok - realTokens;
            uint256 exactEth = Math.ceilDiv(vEth * vTok, newVTok) - vEth;
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
            if (bought > (tokenCurveSupply[token] * cfg.guardMaxWalletBps) / BPS) revert SnipeGuardExceeded();
            guardBought[token][recipient] = bought;
        }

        c.virtualEth = uint128(vEth + ethForCurve);
        c.virtualTokens = uint128(vTok - tokensOut);
        c.realEth = uint128(c.realEth + ethForCurve);
        c.realTokens = uint128(realTokens - tokensOut);
        _accrueFee(token, fee);

        emit Trade(token, recipient, true, ethForCurve + fee, tokensOut, fee, c.virtualEth, c.virtualTokens);

        bool graduating = (c.realTokens == 0);
        if (graduating) {
            c.graduated = true;
            emit Graduated(token, c.realEth);
        }

        require(HoodToken(token).transfer(recipient, tokensOut), "TRANSFER_FAILED");

        // ATOMIC AUTO-MIGRATION: the very tx that fills the curve also seeds and
        // permanently locks the Uniswap v3 pool. No keeper, no separate call, no
        // frozen window — every launch is on Uniswap v3 the instant it graduates.
        if (graduating) {
            _migrate(token, c);
        }

        if (refund > 0) {
            (bool ok,) = msg.sender.call{value: refund}("");
            if (!ok) revert EthTransferFailed();
        }
    }

    // -------------------------------------------------------------- migrate

    /// @notice Defensive, permissionless fallback. In normal operation migration
    ///         is ATOMIC — it runs inside the buy that fills the curve (see
    ///         `_buy`), so a coin is on Uniswap v3 in the same tx it graduates.
    ///         This entrypoint only fires in the (unexpected) case that a curve
    ///         is graduated but not yet migrated; otherwise it reverts
    ///         AlreadyMigrated.
    function migrate(address token) external nonReentrant returns (address pool) {
        Curve storage c = curves[token];
        if (c.creator == address(0)) revert UnknownToken();
        if (!c.graduated) revert NotGraduated();
        if (c.migrated) revert AlreadyMigrated();
        return _migrate(token, c);
    }

    /// @dev Seeds + locks the Uniswap v3 pool. Caller MUST have already verified
    ///      the curve is graduated and not migrated. Reused by the atomic path in
    ///      `_buy` and the public fallback above.
    function _migrate(address token, Curve storage c) internal returns (address pool) {
        c.migrated = true;

        uint256 lpSupply_ = tokenLpSupply[token];
        uint256 ethLiq = c.realEth;
        uint256 migrationFee = config.migrationFee + (ethLiq * config.migrationFeeBps) / BPS;
        if (migrationFee < ethLiq) {
            ethLiq -= migrationFee;
            _accrueFee(token, migrationFee);
        }
        c.realEth = 0;

        HoodToken(token).unlock();

        address _migrator = migrator;
        if (_migrator != address(0)) {
            require(HoodToken(token).transfer(_migrator, lpSupply_), "TRANSFER_FAILED");
            pool = IHoodMigrator(_migrator).migrate{value: ethLiq}(token, c.creator);
            emit Migrated(token, pool, ethLiq, lpSupply_, 0);
        } else {
            pool = uniswapFactory.getPair(token, address(weth));
            if (pool == address(0)) {
                pool = uniswapFactory.createPair(token, address(weth));
            }
            weth.deposit{value: ethLiq}();
            require(weth.transfer(pool, ethLiq), "TRANSFER_FAILED");
            require(HoodToken(token).transfer(pool, lpSupply_), "TRANSFER_FAILED");
            uint256 liquidity = IUniswapV2Pair(pool).mint(address(this));
            require(IUniswapV2Pair(pool).transfer(LP_BURN_ADDRESS, liquidity), "TRANSFER_FAILED");
            emit Migrated(token, pool, ethLiq, lpSupply_, liquidity);
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
        uint256 curveSupply_ = tokenCurveSupply[token];
        return ((curveSupply_ - c.realTokens) * BPS) / curveSupply_;
    }

    function tokenCount() external view returns (uint256) {
        return allTokens.length;
    }

    function getCurve(address token) external view returns (Curve memory) {
        return curves[token];
    }

    /// @notice The token's chosen total supply (curve + LP).
    function totalSupplyOf(address token) external view returns (uint256) {
        return tokenCurveSupply[token] + tokenLpSupply[token];
    }

    function isHoodToken(address token) external view returns (bool) {
        return curves[token].creator != address(0);
    }

    /// @notice Predicted CREATE2 address for a launch of a given supply. Grind
    ///         `salt` until the result ends in 0x600d (when vanity is enforced).
    function predictTokenAddress(
        address caller,
        bytes32 salt,
        string calldata name,
        string calldata symbol,
        uint256 totalSupply_
    ) external view returns (address) {
        bytes32 initCodeHash =
            keccak256(abi.encodePacked(type(HoodToken).creationCode, abi.encode(name, symbol, totalSupply_)));
        bytes32 h = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), keccak256(abi.encodePacked(caller, salt)), initCodeHash)
        );
        return address(uint160(uint256(h)));
    }

    function tokenInitCodeHash(string calldata name, string calldata symbol, uint256 totalSupply_)
        external
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(type(HoodToken).creationCode, abi.encode(name, symbol, totalSupply_)));
    }

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
