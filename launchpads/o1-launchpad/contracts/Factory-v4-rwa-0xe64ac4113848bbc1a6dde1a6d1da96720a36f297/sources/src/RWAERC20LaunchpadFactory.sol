// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";

import {ERC20LaunchpadFactory} from "./ERC20LaunchpadFactory.sol";
import {IRWAQuoteRegistry} from "./interfaces/IRWAQuoteRegistry.sol";
import {LaunchHook} from "./LaunchHook.sol";
import {LaunchTokenDeployer} from "./LaunchTokenDeployer.sol";

/// @title RWAERC20LaunchpadFactory
/// @notice ERC20 launch factory for RWA quotes with a restricted tick updater and native launch fee.
contract RWAERC20LaunchpadFactory is ERC20LaunchpadFactory, IRWAQuoteRegistry {
    uint256 public constant override MAX_QUOTE_BATCH_SIZE = 64;
    uint8 public constant TOKEN_ADDRESS_SUFFIX = 0x01;

    uint256 public override nativeLaunchFee;
    address public override priceUpdater;
    bool public override launchCreationEnabled;
    mapping(address => uint64) public override quoteRevision;

    event NativeLaunchFeeUpdated(uint256 oldFeeWei, uint256 newFeeWei);
    event PriceUpdaterUpdated(address indexed oldUpdater, address indexed newUpdater);
    event LaunchCreationEnabledUpdated(bool enabled);
    event QuoteRevisionUpdated(address indexed quote, uint64 revision);

    error QuoteCreationFeeUnsupported();
    error UnauthorizedPriceUpdater();
    error StaleQuoteRevision(address quote, uint64 expectedRevision, uint64 actualRevision);
    error QuoteBatchOutOfBounds();
    error QuoteBatchNotSorted();
    error MisalignedStartTick();
    error InvalidQuoteToken();
    error InvalidTokenAddressSuffix(address predicted);
    error LaunchCreationDisabled();
    error UnsafeOwnershipRenunciation();

    modifier onlyOwnerOrPriceUpdater() {
        if (msg.sender != owner() && msg.sender != priceUpdater) revert UnauthorizedPriceUpdater();
        _;
    }

    constructor(IPoolManager _poolManager, LaunchHook _hook, LaunchTokenDeployer _tokenDeployer, InitConfig memory cfg)
        ERC20LaunchpadFactory(_poolManager, _hook, _tokenDeployer, cfg)
    {}

    function registerQuote(address quote, int24 startTickToken0Frame) public override onlyOwner nonReentrant {
        _registerQuote(quote, startTickToken0Frame);
        _bumpConfigVersion();
    }

    function batchRegisterQuotes(IRWAQuoteRegistry.QuoteRegistration[] calldata registrations)
        external
        override
        onlyOwner
        nonReentrant
    {
        _validateBatchLength(registrations.length);
        address previous;
        for (uint256 i = 0; i < registrations.length; i++) {
            IRWAQuoteRegistry.QuoteRegistration calldata registration = registrations[i];
            if (i != 0) _validateSortedAddress(previous, registration.quote);
            _registerQuote(registration.quote, registration.startTickToken0Frame);
            previous = registration.quote;
        }
        _bumpConfigVersion();
    }

    function setQuoteStartTick(address quote, int24 startTickToken0Frame) public override onlyOwner nonReentrant {
        _setQuoteStartTick(quote, startTickToken0Frame, quoteRevision[quote]);
    }

    function setQuoteStartTick(address quote, int24 startTickToken0Frame, uint64 expectedRevision)
        external
        override
        onlyOwnerOrPriceUpdater
        nonReentrant
    {
        _setQuoteStartTick(quote, startTickToken0Frame, expectedRevision);
    }

    function batchSetQuoteStartTicks(IRWAQuoteRegistry.QuoteTickUpdate[] calldata updates)
        external
        override
        onlyOwnerOrPriceUpdater
        nonReentrant
    {
        _validateBatchLength(updates.length);
        address previous;
        for (uint256 i = 0; i < updates.length; i++) {
            IRWAQuoteRegistry.QuoteTickUpdate calldata update = updates[i];
            if (i != 0) _validateSortedAddress(previous, update.quote);
            _setQuoteStartTick(update.quote, update.startTickToken0Frame, update.expectedRevision);
            previous = update.quote;
        }
    }

    function unregisterQuote(address quote) public override onlyOwner nonReentrant {
        _unregisterQuote(quote);
        _bumpConfigVersion();
    }

    function batchUnregisterQuotes(address[] calldata quoteAddresses) external override onlyOwner nonReentrant {
        _validateBatchLength(quoteAddresses.length);
        address previous;
        for (uint256 i = 0; i < quoteAddresses.length; i++) {
            address quote = quoteAddresses[i];
            if (i != 0) _validateSortedAddress(previous, quote);
            _unregisterQuote(quote);
            previous = quote;
        }
        _bumpConfigVersion();
    }

    function setPriceUpdater(address updater) external override onlyOwner nonReentrant {
        address oldUpdater = priceUpdater;
        if (updater == oldUpdater) return;
        priceUpdater = updater;
        _bumpConfigVersion();
        emit PriceUpdaterUpdated(oldUpdater, updater);
    }

    function setNativeLaunchFee(uint256 newFeeWei) external override onlyOwner nonReentrant {
        uint256 oldFeeWei = nativeLaunchFee;
        if (newFeeWei == oldFeeWei) return;
        nativeLaunchFee = newFeeWei;
        _bumpConfigVersion();
        emit NativeLaunchFeeUpdated(oldFeeWei, newFeeWei);
    }

    function setQuoteCreationFee(address, uint256) public view override onlyOwner {
        revert QuoteCreationFeeUnsupported();
    }

    function setLaunchCreationEnabled(bool enabled) external override onlyOwner nonReentrant {
        if (enabled == launchCreationEnabled) return;
        launchCreationEnabled = enabled;
        _bumpConfigVersion();
        emit LaunchCreationEnabledUpdated(enabled);
    }

    function renounceOwnership() public override onlyOwner {
        if (launchCreationEnabled || priceUpdater != address(0)) revert UnsafeOwnershipRenunciation();
        super.renounceOwnership();
    }

    function launchTokenBytecodeHash(LaunchParams calldata p, address creator) external view returns (bytes32) {
        if (creator == address(0)) revert InvalidConfig();
        uint256 supply = launchSupply;
        (uint256 immediateTotal, uint256 vestedTotal) = _validateAndSumAllocations(p, supply);
        if (immediateTotal + vestedTotal >= supply) revert InvalidConfig();
        uint256 poolSupply = supply - immediateTotal - vestedTotal;
        (address[] memory recipients, uint256[] memory amounts) = _genesisMints(p, poolSupply, vestedTotal);
        return tokenDeployer.tokenBytecodeHash(_tokenParams(p, creator, recipients, amounts));
    }

    function _beforeCreateLaunch(LaunchParams calldata p) internal view override {
        super._beforeCreateLaunch(p);
        if (!launchCreationEnabled) revert LaunchCreationDisabled();
        _validateRWAStartTick(quotes[p.quote].startTickToken0Frame);
    }

    function _registerQuote(address quote, int24 startTickToken0Frame) internal {
        if (quote != address(0) && quote.code.length == 0) revert InvalidQuoteToken();
        if (quotes[quote].registered) revert QuoteAlreadyRegistered();
        _validateRWAStartTick(startTickToken0Frame);

        uint8 decimals = quote == address(0) ? 18 : IERC20Metadata(quote).decimals();
        quotes[quote] =
            Quote({registered: true, decimals: decimals, startTickToken0Frame: startTickToken0Frame, creationFee: 0});

        uint64 revision = quoteRevision[quote] + 1;
        quoteRevision[quote] = revision;
        emit QuoteRegistered(quote, decimals, startTickToken0Frame);
        emit QuoteRevisionUpdated(quote, revision);
    }

    function _setQuoteStartTick(address quote, int24 startTickToken0Frame, uint64 expectedRevision) internal {
        Quote storage quoteConfig = quotes[quote];
        if (!quoteConfig.registered) revert QuoteNotRegistered();

        uint64 revision = quoteRevision[quote];
        if (expectedRevision != revision) revert StaleQuoteRevision(quote, expectedRevision, revision);
        _validateRWAStartTick(startTickToken0Frame);
        if (startTickToken0Frame == quoteConfig.startTickToken0Frame) return;

        revision++;
        quoteConfig.startTickToken0Frame = startTickToken0Frame;
        quoteRevision[quote] = revision;
        emit QuoteRegistered(quote, quoteConfig.decimals, startTickToken0Frame);
        emit QuoteRevisionUpdated(quote, revision);
    }

    function _unregisterQuote(address quote) internal {
        if (!quotes[quote].registered) revert QuoteNotRegistered();
        delete quotes[quote];

        uint64 revision = quoteRevision[quote] + 1;
        quoteRevision[quote] = revision;
        emit QuoteUnregistered(quote);
        emit QuoteRevisionUpdated(quote, revision);
    }

    function _validateRWAStartTick(int24 startTickToken0Frame) internal view {
        _validateStartTickFrame(startTickToken0Frame);
        if (startTickToken0Frame % tickSpacing != 0) revert MisalignedStartTick();
    }

    function _validateBatchLength(uint256 length) internal pure {
        if (length == 0 || length > MAX_QUOTE_BATCH_SIZE) revert QuoteBatchOutOfBounds();
    }

    function _validateSortedAddress(address previous, address current) internal pure {
        if (uint160(current) <= uint160(previous)) revert QuoteBatchNotSorted();
    }

    function _collectCreationFee(address, uint256) internal override {
        super._collectCreationFee(address(0), nativeLaunchFee);
    }

    function _validatePredictedToken(address predicted) internal pure override {
        if ((uint160(predicted) & 0xff) != TOKEN_ADDRESS_SUFFIX) revert InvalidTokenAddressSuffix(predicted);
    }
}
