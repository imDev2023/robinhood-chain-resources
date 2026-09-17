// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*//////////////////////////////////////////////////////////////////////////
    hood.fun — STOCK REWARDS (fully separate feature; NO launchpad redeploy)

    "Enable stocks" on a hood coin: instead of paying ETH dividends to holders
    (the community-mode default), the coin's creator-fee stream funds a per-coin
    vault that CROWDSOURCES real tokenized-stock acquisition and hands the stock
    to holders. This is the only way it works on Robinhood Chain (stock tokens
    have no DEX liquidity and contracts can't KYC): the vault posts a STANDING
    BID at a premium over the on-chain Chainlink oracle, so a non-US Robinhood
    Wallet holder sells their stock token to the vault for an instant premium.

    Everything here is standalone — the factory is just a whitelisted CALLER of
    the already-deployed launchpad (like HoodCommunityGuarded). Nothing existing
    is modified or redeployed.

    ⚠️ Securities risk (operator-owned, by design): the assets are restricted
    tokenized securities the issuer can freeze and Chainalysis KYT screens on
    transfer. Treat the vault's stock balance as at-risk, not as treasury.
//////////////////////////////////////////////////////////////////////////*/

/// Launchpad surface (already deployed — we only CALL it).
interface IStockLaunchpad {
    function createTokenFor(
        address creator,
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        uint256 minTokensOut,
        bytes32 salt,
        uint16 tradeFeeBps,
        uint256 totalSupply_
    ) external payable returns (address token);
    function buyFor(address token, address recipient, uint256 minTokensOut) external payable;
    function claimCreatorFees(address token) external;
    function creatorFees(address token) external view returns (uint256);
    function config() external view returns (uint128, uint64, uint16, uint64, uint16, uint16, uint16, uint16, bool);
}

/// Minimal Chainlink feed surface (RH Chain publishes per-asset USD + ETH/USD).
interface IAggregatorV3 {
    function decimals() external view returns (uint8);
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

/// Config + keeper the per-coin vault reads from its factory.
interface IStockFactory {
    function publisher() external view returns (address); // the keeper (distributor)
    /// @dev `assetDecimals` is snapshotted at whitelist time so the vault never has
    ///      to assume 18 (audit L-1).
    function assetConfig(address token)
        external
        view
        returns (bool enabled, address usdFeed, uint32 maxStaleness, uint8 assetDecimals);
    function ethUsdConfig() external view returns (address feed, uint32 maxStaleness);
    function premiumBps() external view returns (uint16);
    function epochConfig() external view returns (uint32 length, uint16 releaseBps);
    /// Owner kill-switch for acquisitions (trading halts, feed anomalies) — audit H-1.
    function sellPaused() external view returns (bool);
    /// A liquid equity feed used purely as a MARKET-OPEN signal, plus how fresh it
    /// must be to count as open. See `_requireMarketOpen`.
    function marketHeartbeat() external view returns (address feed, uint32 maxAge);
    /// Max share of the held stock a single `distributeStock` round may move — audit M-1.
    function maxDistributeBps() external view returns (uint16);
}

/*//////////////////////////////////////////////////////////////////////////
                        PER-COIN VAULT (cloned)
//////////////////////////////////////////////////////////////////////////*/

/// @title HoodStockRewards
/// @notice One clone per stock coin, set as that coin's launchpad `creator`, so
///         its ETH creator-fees land here as an acquisition budget. Sellers flip
///         the coin's target stock token to the vault at a premium (`sellAsset`);
///         the keeper harvests fees, rolls the epoch budget, and distributes the
///         acquired stock to holders (`distributeStock`). All pricing is oracle-
///         driven with staleness + premium-cap guards; a per-epoch budget release
///         stops any seller from draining the treasury the instant fees land.
contract HoodStockRewards is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IStockLaunchpad public launchpad;
    address public factory; // IStockFactory — config + publisher()
    address public token; // the hood coin
    address public asset; // the target stock token this coin accumulates

    // per-coin epoch budget state
    uint64 public epochStart;
    uint256 public epochAllowance; // ETH spendable this epoch (snapshot at roll)
    uint256 public epochSpent;

    uint256 public totalEthSpent; // lifetime ETH paid to sellers
    uint256 public totalStockDistributed; // lifetime stock sent to holders
    uint256 public round;

    bool private _init;

    event Harvested(uint256 amount);
    event AssetBought(address indexed seller, uint256 stockAmount, uint256 ethPaid);
    event EpochRolled(uint64 start, uint256 allowance);
    event StockDistributed(uint256 indexed round, uint256 amount, uint256 recipients);
    event Paid(address indexed holder, uint256 amount);

    error AlreadyInitialized();
    error NotKeeper();
    error NotEnabled();
    error BadFeed();
    error StaleFeed();
    error EpochBudgetExhausted();
    error InsufficientBudget();
    error SlippageTooHigh();
    error LengthMismatch();
    error ZeroAmount();
    error SellPaused();
    error EpochNotElapsed();
    error DistributionTooLarge();
    error MarketClosed();

    uint16 internal constant MAX_PREMIUM_BPS = 2000; // mirrored guard: never pay >20% over oracle

    function initialize(address launchpad_, address factory_, address token_, address asset_) external {
        if (_init) revert AlreadyInitialized();
        _init = true;
        launchpad = IStockLaunchpad(launchpad_);
        factory = factory_;
        token = token_;
        asset = asset_;
        epochStart = uint64(block.timestamp);
    }

    /// @notice Accept ETH budget (creator fees pulled from the launchpad).
    receive() external payable {}

    // ------------------------------------------------------------- harvest

    /// @notice Pull this coin's pending creator fees from the launchpad into the
    ///         budget. Permissionless — anyone/the keeper can top up.
    function harvest() public nonReentrant returns (uint256 gained) {
        uint256 before = address(this).balance;
        if (launchpad.creatorFees(token) > 0) launchpad.claimCreatorFees(token);
        gained = address(this).balance - before;
        if (gained > 0) emit Harvested(gained);
    }

    // -------------------------------------------------------------- selling

    /// @notice Sell `stockAmount` of the coin's target stock token to the vault for
    ///         ETH at the factory `premiumBps` over the oracle. `minEthOut` guards
    ///         the seller against an oracle move mid-tx.
    function sellAsset(uint256 stockAmount, uint256 minEthOut) external nonReentrant returns (uint256 ethOut) {
        if (stockAmount == 0) revert ZeroAmount();
        if (IStockFactory(factory).sellPaused()) revert SellPaused();
        _requireMarketOpen(); // AUDIT H-1: the real guard — no bids while trading is shut
        (bool enabled, address usdFeed, uint32 maxStale, uint8 assetDec) = IStockFactory(factory).assetConfig(asset);
        if (!enabled) revert NotEnabled();

        _rollEpoch();

        (address ethFeed, uint32 ethStale) = IStockFactory(factory).ethUsdConfig();
        // AUDIT H-1: an equity feed only updates while its market is open, so a FRESH
        // feed is itself the market-open signal. The factory hard-caps `maxStaleness`
        // (MAX_STALENESS_CEILING), which means this call simply reverts once the feed
        // goes quiet at the close — closing the overnight/weekend window in which a
        // seller could dump stock that had gapped down against a frozen price.
        uint256 assetUsd = _price(usdFeed, maxStale); // 1e18 USD per whole stock token
        uint256 ethUsd = _price(ethFeed, ethStale); // 1e18 USD per ETH
        // AUDIT L-1: normalize by the STOCK TOKEN's own decimals (snapshotted at
        // whitelist time) instead of assuming 18.
        uint256 usdValue = (stockAmount * assetUsd) / (10 ** assetDec);
        ethOut = (usdValue * 1e18) / ethUsd;

        uint16 prem = IStockFactory(factory).premiumBps();
        if (prem > MAX_PREMIUM_BPS) prem = MAX_PREMIUM_BPS; // belt-and-suspenders
        ethOut = (ethOut * (10_000 + prem)) / 10_000;

        if (ethOut < minEthOut) revert SlippageTooHigh();
        if (epochSpent + ethOut > epochAllowance) revert EpochBudgetExhausted();
        if (ethOut > address(this).balance) revert InsufficientBudget();

        epochSpent += ethOut;
        totalEthSpent += ethOut;

        IERC20(asset).safeTransferFrom(msg.sender, address(this), stockAmount);
        (bool ok,) = msg.sender.call{value: ethOut}("");
        if (!ok) revert InsufficientBudget();

        emit AssetBought(msg.sender, stockAmount, ethOut);
    }

    /// @notice UI quote: ETH the vault would pay for `stockAmount` right now
    ///         (before epoch-budget limits). Powers the "sell at +X%" surface.
    function quote(uint256 stockAmount) external view returns (uint256 ethOut) {
        _requireMarketOpen(); // quote must fail wherever sellAsset would, so the UI can't advertise a bid that won't fill
        (bool enabled, address usdFeed, uint32 maxStale, uint8 assetDec) = IStockFactory(factory).assetConfig(asset);
        if (!enabled) revert NotEnabled();
        (address ethFeed, uint32 ethStale) = IStockFactory(factory).ethUsdConfig();
        uint256 assetUsd = _price(usdFeed, maxStale);
        uint256 ethUsd = _price(ethFeed, ethStale);
        uint256 usdValue = (stockAmount * assetUsd) / (10 ** assetDec); // AUDIT L-1
        ethOut = (usdValue * 1e18) / ethUsd;
        uint16 prem = IStockFactory(factory).premiumBps();
        if (prem > MAX_PREMIUM_BPS) prem = MAX_PREMIUM_BPS;
        ethOut = (ethOut * (10_000 + prem)) / 10_000;
    }

    // ---------------------------------------------------------- distribution

    /// @notice Keeper-only: hand out `amounts[i]` of the ACQUIRED stock token to
    ///         `holders[i]` — the pro-rata shares the keeper computed off-chain
    ///         from a live holder snapshot (min-balance + exclude-contracts applied
    ///         off-chain, same as the community keeper). Harvests fees first so the
    ///         budget stays fresh; a transfer that reverts (frozen/KYT-blocked
    ///         recipient) reverts the batch — the keeper re-runs without that holder.
    function distributeStock(address[] calldata holders, uint256[] calldata amounts) external nonReentrant {
        if (msg.sender != IStockFactory(factory).publisher()) revert NotKeeper();
        if (holders.length != amounts.length) revert LengthMismatch();

        uint256 total;
        for (uint256 i; i < amounts.length; ++i) total += amounts[i];
        uint256 held = IERC20(asset).balanceOf(address(this));
        if (total > held) revert InsufficientBudget();
        // AUDIT M-1: bound a single round. The keeper is a hot wallet, and the only
        // other check is "<= balance" — so a leaked key could move the entire stock
        // balance in one call. Cap each round at `maxDistributeBps` of what's held so
        // a compromise leaks a bounded slice per round instead of everything at once,
        // leaving time to rotate `publisher`. Honest residual: the keeper still
        // chooses the recipients.
        uint256 cap = (held * IStockFactory(factory).maxDistributeBps()) / 10_000;
        if (total > cap) revert DistributionTooLarge();

        uint256 recipients;
        for (uint256 i; i < holders.length; ++i) {
            if (amounts[i] == 0) continue;
            IERC20(asset).safeTransfer(holders[i], amounts[i]);
            emit Paid(holders[i], amounts[i]);
            unchecked {
                ++recipients;
            }
        }
        totalStockDistributed += total;
        unchecked {
            ++round;
        }
        emit StockDistributed(round, total, recipients);
    }

    // ------------------------------------------------------------------ epoch

    function _rollEpoch() internal {
        (uint32 len, uint16 releaseBps) = IStockFactory(factory).epochConfig();
        if (block.timestamp >= epochStart + len) {
            epochStart = uint64(block.timestamp);
            epochAllowance = (address(this).balance * releaseBps) / 10_000;
            epochSpent = 0;
            emit EpochRolled(epochStart, epochAllowance);
        } else if (epochAllowance == 0 && address(this).balance > 0) {
            epochAllowance = (address(this).balance * releaseBps) / 10_000; // seed first epoch
        }
    }

    /// @notice Keeper may roll the epoch once it has actually elapsed.
    /// @dev AUDIT M-1: this used to re-arm the budget unconditionally, so the keeper
    ///      could reset `epochSpent` at will and defeat the per-epoch drain cap — the
    ///      very throttle that bounds an oracle mispricing. It now enforces the same
    ///      elapsed-time rule as the automatic roll, so it can only ever do what
    ///      `_rollEpoch` would have done anyway.
    function rollEpoch() external {
        if (msg.sender != IStockFactory(factory).publisher()) revert NotKeeper();
        (uint32 len, uint16 releaseBps) = IStockFactory(factory).epochConfig();
        if (block.timestamp < epochStart + len) revert EpochNotElapsed();
        epochStart = uint64(block.timestamp);
        epochAllowance = (address(this).balance * releaseBps) / 10_000;
        epochSpent = 0;
        emit EpochRolled(epochStart, epochAllowance);
    }

    // ------------------------------------------------------------------ oracle

    /// @dev AUDIT H-1 (round 3) — prove the equity market is OPEN, independently of
    ///      the asset's own price age.
    ///
    ///      Measured on-chain: these feeds are DEVIATION-triggered, firing at ~0.5%
    ///      movement whatever the elapsed time (GME updated after 0.17h and after
    ///      9.15h — both on a ~0.5% move). So while the market is open, a stale price
    ///      is not a wrong price, it just means the asset hasn't moved. Age alone is
    ///      therefore a poor proxy for risk: it punishes quiet assets while still
    ///      admitting a price frozen by a CLOSED market, which is the actual danger —
    ///      the feed cannot reflect a gap that happens while trading is halted.
    ///
    ///      A liquid reference feed (e.g. NVDA, worst observed gap ~1.1h) settles it:
    ///      if IT ticked recently the market is demonstrably open, so the asset's own
    ///      staleness is benign. Paired with a per-asset ceiling kept below the
    ///      overnight gap (~17.5h), a price carried over from before the last close
    ///      still cannot be used.
    function _requireMarketOpen() internal view {
        (address feed, uint32 maxAge) = IStockFactory(factory).marketHeartbeat();
        (, int256 answer,, uint256 updatedAt, uint80 answeredInRound) =
            IAggregatorV3(feed).latestRoundData();
        if (answer <= 0 || updatedAt == 0 || answeredInRound == 0) revert BadFeed();
        if (block.timestamp - updatedAt > maxAge) revert MarketClosed();
    }

    function _price(address feed, uint32 maxStaleness) internal view returns (uint256) {
        (, int256 answer,, uint256 updatedAt, uint80 answeredInRound) = IAggregatorV3(feed).latestRoundData();
        if (answer <= 0 || updatedAt == 0 || answeredInRound == 0) revert BadFeed();
        if (block.timestamp - updatedAt > maxStaleness) revert StaleFeed();
        uint8 dec = IAggregatorV3(feed).decimals();
        return dec <= 18 ? uint256(answer) * (10 ** (18 - dec)) : uint256(answer) / (10 ** (dec - 18));
    }

    // ------------------------------------------------------------------- views

    /// @notice ETH budget available + spendable-this-epoch, and the stock currently
    ///         acquired and awaiting distribution.
    function status()
        external
        view
        returns (uint256 ethBudget, uint256 epochRemaining, uint256 stockHeld)
    {
        ethBudget = address(this).balance;
        epochRemaining = epochAllowance > epochSpent ? epochAllowance - epochSpent : 0;
        stockHeld = IERC20(asset).balanceOf(address(this));
    }
}

/*//////////////////////////////////////////////////////////////////////////
                        LAUNCH FACTORY (config + launch)
//////////////////////////////////////////////////////////////////////////*/

/// @title HoodStockFactory
/// @notice Whitelisted-platform factory that launches STOCK-REWARDS coins on the
///         existing hood launchpad. Holds the global oracle/premium/epoch config
///         all per-coin vaults read, and the keeper `publisher` that distributes.
///         Launching is permissionless (anyone can "enable stocks" on a new coin);
///         only the owner (Safe) controls which stock assets are whitelisted and
///         the pricing guardrails.
contract HoodStockFactory is Ownable, ReentrancyGuard {
    IStockLaunchpad public immutable launchpad;
    address public immutable implementation;

    address public publisher; // keeper (distributes + rolls epochs)

    struct Asset {
        bool enabled;
        address usdFeed; // Chainlink <ASSET>/USD
        uint32 maxStaleness;
        uint8 decimals; // AUDIT L-1: snapshotted so the vault never assumes 18
    }

    /// @notice AUDIT H-1 — hard ceiling on any configurable feed staleness.
    ///         Tokenized-equity feeds stop updating at the market close, so a wide
    ///         staleness window is exactly the window in which a seller can push
    ///         stock that has gapped down on-chain against a frozen oracle price.
    ///         Capping it means acquisitions simply stop working while the feed is
    ///         quiet (i.e. while the market is shut) — the correct behaviour for a
    ///         bid priced off that market — instead of quoting a stale price.
    ///
    ///         SIZED FROM REAL FEED CADENCE on Robinhood Chain (measured 2026-07-29,
    ///         mid-session, from consecutive `getRoundData` timestamps):
    ///           ETH/USD  median 0.68h, worst 3.00h   ← needed by EVERY sellAsset
    ///           NVDA     median 0.76h, worst 1.06h
    ///           TSLA     median 0.43h, worst 1.47h
    ///           GME      median 2.60h, worst 9.15h   ← sporadic
    ///         An earlier 2h ceiling was empirically unusable: ETH/USD alone breaches
    ///         it, so healthy stocks would revert StaleFeed at random. 6h clears every
    ///         liquid feed with margin while still slamming shut the windows H-1 is
    ///         actually about — the overnight gap (~17.5h) and the weekend (~65h).
    ///         ROUND 3: these feeds are DEVIATION-triggered (~0.5% move), not
    ///         heartbeat-driven, so a long gap means "hasn't moved", not "wrong".
    ///         Market-closed risk is now caught directly by the market-heartbeat
    ///         check in the vault, so this ceiling no longer has to double as a
    ///         market-hours proxy. It only has to stay under the OVERNIGHT gap
    ///         (~17.5h) so a price carried over from before the last close can never
    ///         be used. 12h does that while admitting sporadic-but-healthy feeds like
    ///         GME (worst observed gap 9.15h), which a 6h ceiling wrongly excluded.
    ///         Per-asset `maxStaleness` can still be set TIGHTER than this ceiling.
    uint32 public constant MAX_STALENESS_CEILING = 12 hours;

    /// @notice Ceiling on how old the market-open heartbeat may be. Kept tight: this
    ///         is the signal that trading is actually live, so it must track a liquid
    ///         feed closely (NVDA's worst observed gap is ~1.1h).
    uint32 public constant MAX_HEARTBEAT_AGE = 2 hours;

    mapping(address stockToken => Asset) public assets;
    address[] public assetList;

    address public ethUsdFeed;
    uint32 public ethUsdMaxStaleness;
    uint16 public premiumBps; // premium the vaults pay over oracle
    uint16 public constant MAX_PREMIUM_BPS = 2000; // 20% hard cap
    uint32 public epochLength;
    uint16 public epochReleaseBps;
    /// AUDIT H-1: owner kill-switch for acquisitions across every vault — used for a
    /// trading halt, a delisting, or a feed that starts misbehaving.
    bool public sellPaused;
    /// AUDIT M-1: max share of a vault's held stock one distribution round may move.
    uint16 public maxDistributeBps = 2500; // 25%
    /// AUDIT H-1 (round 3): liquid equity feed used as the MARKET-OPEN signal, and
    /// how fresh it must be to count as open.
    address public marketHeartbeatFeed;
    uint32 public marketHeartbeatMaxAge;

    mapping(address token => address) public stockVaultOf; // coin → its vault
    mapping(address token => address) public assetOf; // coin → its target stock
    address[] public allStockTokens;

    event StockCoinLaunched(address indexed token, address indexed vault, address indexed launcher, address asset);
    event PublisherSet(address publisher);
    event AssetSet(address indexed token, bool enabled, address usdFeed, uint32 maxStaleness);
    event ConfigSet(uint16 premiumBps, uint32 epochLength, uint16 epochReleaseBps);
    event EthUsdFeedSet(address feed, uint32 maxStaleness);
    event SellPausedSet(bool paused);
    event MaxDistributeBpsSet(uint16 bps);
    event MarketHeartbeatSet(address feed, uint32 maxAge);

    error ZeroAddress();
    error PremiumTooHigh();
    error BadParam();
    error AssetNotWhitelisted();
    error InsufficientValue();
    error RefundFailed();

    constructor(
        address launchpad_,
        address owner_,
        address publisher_,
        address ethUsdFeed_,
        uint32 ethUsdMaxStaleness_,
        uint16 premiumBps_,
        uint32 epochLength_,
        uint16 epochReleaseBps_,
        address marketHeartbeatFeed_,
        uint32 marketHeartbeatMaxAge_
    ) Ownable(owner_) {
        if (launchpad_ == address(0) || publisher_ == address(0) || ethUsdFeed_ == address(0)) revert ZeroAddress();
        // AUDIT H-1 (round 3): required at construction — a vault must never be able
        // to quote without a market-open signal.
        if (marketHeartbeatFeed_ == address(0)) revert ZeroAddress();
        if (marketHeartbeatMaxAge_ == 0 || marketHeartbeatMaxAge_ > MAX_HEARTBEAT_AGE) revert BadParam();
        marketHeartbeatFeed = marketHeartbeatFeed_;
        marketHeartbeatMaxAge = marketHeartbeatMaxAge_;
        if (premiumBps_ > MAX_PREMIUM_BPS) revert PremiumTooHigh();
        if (epochReleaseBps_ == 0 || epochReleaseBps_ > 10_000 || epochLength_ == 0) revert BadParam();
        if (ethUsdMaxStaleness_ == 0 || ethUsdMaxStaleness_ > MAX_STALENESS_CEILING) revert BadParam(); // AUDIT H-1
        launchpad = IStockLaunchpad(launchpad_);
        publisher = publisher_;
        ethUsdFeed = ethUsdFeed_;
        ethUsdMaxStaleness = ethUsdMaxStaleness_;
        premiumBps = premiumBps_;
        epochLength = epochLength_;
        epochReleaseBps = epochReleaseBps_;
        implementation = address(new HoodStockRewards());
    }

    // ------------------------------------------------------------------ launch

    /// @notice Launch a stock-rewards coin. `targetAsset` must be a whitelisted
    ///         stock token; the coin's creator fees will be used to acquire it and
    ///         distribute it to holders. `salt` must be ground so the token address
    ///         ends in 0x600d (grind against THIS factory). msg.value = creationFee
    ///         + optional devBuyEth (credited to the launcher).
    function launchStockCoin(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        bytes32 salt,
        uint16 tradeFeeBps,
        uint256 totalSupply_,
        address targetAsset,
        uint256 devBuyEth,
        uint256 minDevTokensOut
    ) external payable nonReentrant returns (address token, address vault) {
        if (!assets[targetAsset].enabled) revert AssetNotWhitelisted();

        vault = Clones.cloneDeterministic(implementation, keccak256(abi.encode(msg.sender, salt)));

        (, uint64 creationFee,,,,,,,) = launchpad.config();
        uint256 fee = uint256(creationFee);
        if (msg.value < fee + devBuyEth) revert InsufficientValue();

        token = launchpad.createTokenFor{value: fee}(vault, name, symbol, metadataURI, 0, salt, tradeFeeBps, totalSupply_);

        HoodStockRewards(payable(vault)).initialize(address(launchpad), address(this), token, targetAsset);

        // optional creator dev-buy — credited to the LAUNCHER (guard-exempt platform buy)
        if (devBuyEth > 0) launchpad.buyFor{value: devBuyEth}(token, msg.sender, minDevTokensOut);

        stockVaultOf[token] = vault;
        assetOf[token] = targetAsset;
        allStockTokens.push(token);
        emit StockCoinLaunched(token, vault, msg.sender, targetAsset);

        uint256 refund = msg.value - fee - devBuyEth;
        if (refund > 0) {
            (bool ok,) = msg.sender.call{value: refund}("");
            if (!ok) revert RefundFailed();
        }
    }

    // ------------------------------------------------------------- IStockFactory
    function assetConfig(address token) external view returns (bool, address, uint32, uint8) {
        Asset memory a = assets[token];
        return (a.enabled, a.usdFeed, a.maxStaleness, a.decimals);
    }

    function ethUsdConfig() external view returns (address, uint32) {
        return (ethUsdFeed, ethUsdMaxStaleness);
    }

    function epochConfig() external view returns (uint32, uint16) {
        return (epochLength, epochReleaseBps);
    }

    // ------------------------------------------------------------------- admin
    function setAsset(address token, bool enabled, address usdFeed, uint32 maxStaleness) external onlyOwner {
        if (token == address(0)) revert ZeroAddress();
        if (enabled && usdFeed == address(0)) revert ZeroAddress();
        // AUDIT H-1: staleness can never be widened past the ceiling.
        if (enabled && (maxStaleness == 0 || maxStaleness > MAX_STALENESS_CEILING)) revert BadParam();
        if (assets[token].usdFeed == address(0) && enabled) assetList.push(token);
        // AUDIT L-1: read and pin the token's decimals so pricing never assumes 18.
        uint8 dec = enabled ? IERC20Metadata(token).decimals() : assets[token].decimals;
        assets[token] = Asset({enabled: enabled, usdFeed: usdFeed, maxStaleness: maxStaleness, decimals: dec});
        emit AssetSet(token, enabled, usdFeed, maxStaleness);
    }

    /// @notice AUDIT H-1 — halt/resume stock acquisition across all vaults.
    function setSellPaused(bool paused) external onlyOwner {
        sellPaused = paused;
        emit SellPausedSet(paused);
    }

    /// @notice AUDIT H-1 (round 3) — set the market-open heartbeat feed.
    ///         Use a LIQUID equity feed (e.g. NVDA/SPY) whose own gaps stay well
    ///         inside `maxAge`; a quiet asset here would falsely read as "closed".
    function setMarketHeartbeat(address feed, uint32 maxAge) external onlyOwner {
        if (feed == address(0)) revert ZeroAddress();
        if (maxAge == 0 || maxAge > MAX_HEARTBEAT_AGE) revert BadParam();
        marketHeartbeatFeed = feed;
        marketHeartbeatMaxAge = maxAge;
        emit MarketHeartbeatSet(feed, maxAge);
    }

    function marketHeartbeat() external view returns (address, uint32) {
        return (marketHeartbeatFeed, marketHeartbeatMaxAge);
    }

    /// @notice AUDIT M-1 — bound how much stock one distribution round may move.
    function setMaxDistributeBps(uint16 bps) external onlyOwner {
        if (bps == 0 || bps > 10_000) revert BadParam();
        maxDistributeBps = bps;
        emit MaxDistributeBpsSet(bps);
    }

    function setConfig(uint16 premiumBps_, uint32 epochLength_, uint16 epochReleaseBps_) external onlyOwner {
        if (premiumBps_ > MAX_PREMIUM_BPS) revert PremiumTooHigh();
        if (epochReleaseBps_ == 0 || epochReleaseBps_ > 10_000 || epochLength_ == 0) revert BadParam();
        premiumBps = premiumBps_;
        epochLength = epochLength_;
        epochReleaseBps = epochReleaseBps_;
        emit ConfigSet(premiumBps_, epochLength_, epochReleaseBps_);
    }

    function setEthUsdFeed(address feed, uint32 maxStaleness) external onlyOwner {
        if (feed == address(0)) revert ZeroAddress();
        if (maxStaleness == 0 || maxStaleness > MAX_STALENESS_CEILING) revert BadParam(); // AUDIT H-1
        ethUsdFeed = feed;
        ethUsdMaxStaleness = maxStaleness;
        emit EthUsdFeedSet(feed, maxStaleness);
    }

    function setPublisher(address publisher_) external onlyOwner {
        if (publisher_ == address(0)) revert ZeroAddress();
        publisher = publisher_;
        emit PublisherSet(publisher_);
    }

    function isStockCoin(address token) external view returns (bool) {
        return stockVaultOf[token] != address(0);
    }

    function stockCoinCount() external view returns (uint256) {
        return allStockTokens.length;
    }

    function assetCount() external view returns (uint256) {
        return assetList.length;
    }

    function predictVault(address caller, bytes32 salt) external view returns (address) {
        return Clones.predictDeterministicAddress(implementation, keccak256(abi.encode(caller, salt)), address(this));
    }
}
