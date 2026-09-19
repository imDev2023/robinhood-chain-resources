// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";

import {ERC20LaunchpadFactory} from "./ERC20LaunchpadFactory.sol";
import {IRWAQuoteRegistry} from "./interfaces/IRWAQuoteRegistry.sol";
import {LaunchHook} from "./LaunchHook.sol";
import {LaunchTokenDeployer} from "./LaunchTokenDeployer.sol";

/// @title RWAERC20LaunchpadFactory
/// @notice Managed ERC-20 launch factory serving standard and RWA product routes on non-Base chains.
contract RWAERC20LaunchpadFactory is ERC20LaunchpadFactory {
    uint256 public constant MAX_QUOTE_BATCH_SIZE = 64;
    uint8 public constant TOKEN_ADDRESS_SUFFIX = 0x01;

    address public priceUpdater;
    bool public launchCreationEnabled;
    mapping(address quoteToken => uint64 revision) public quoteRevision;

    event PriceUpdaterUpdated(address indexed previousPriceUpdater, address indexed newPriceUpdater);
    event LaunchCreationEnabledUpdated(bool creationEnabled);

    error UnauthorizedPriceUpdater();
    error StaleQuoteRevision(address quoteToken, uint64 expectedRevision, uint64 actualRevision);
    error QuoteBatchOutOfBounds();
    error QuoteBatchNotSorted();
    error MisalignedStartTick();
    error InvalidQuoteToken();
    error InvalidTokenAddressSuffix(address predictedToken);
    error LaunchCreationDisabled();

    modifier onlyOwnerOrPriceUpdater() {
        if (msg.sender != owner() && msg.sender != priceUpdater) revert UnauthorizedPriceUpdater();
        _;
    }

    constructor(
        IPoolManager poolManagerAddress,
        LaunchHook launchHook,
        LaunchTokenDeployer launchTokenDeployer,
        FactoryInitialization memory initialFactoryConfiguration
    ) ERC20LaunchpadFactory(poolManagerAddress, launchHook, launchTokenDeployer, initialFactoryConfiguration) {}

    function registerQuote(address quoteToken, int24 startTickToken0Frame) public onlyOwner nonReentrant {
        _registerQuote(quoteToken, startTickToken0Frame);
        _bumpConfigVersion();
    }

    function batchRegisterQuotes(IRWAQuoteRegistry.QuoteRegistration[] calldata quoteRegistrations)
        external
        onlyOwner
        nonReentrant
    {
        _validateBatchLength(quoteRegistrations.length);
        address previousQuoteToken;
        for (uint256 i = 0; i < quoteRegistrations.length; i++) {
            IRWAQuoteRegistry.QuoteRegistration calldata registration = quoteRegistrations[i];
            if (i != 0) _validateSortedAddress(previousQuoteToken, registration.quoteToken);
            _registerQuote(registration.quoteToken, registration.startTickToken0Frame);
            previousQuoteToken = registration.quoteToken;
        }
        _bumpConfigVersion();
    }

    function setQuoteStartTick(address quoteToken, int24 newStartTickToken0Frame, uint64 expectedRevision)
        external
        onlyOwnerOrPriceUpdater
        nonReentrant
    {
        _setQuoteStartTick(quoteToken, newStartTickToken0Frame, expectedRevision);
    }

    function batchSetQuoteStartTicks(IRWAQuoteRegistry.QuoteTickUpdate[] calldata quoteTickUpdates)
        external
        onlyOwnerOrPriceUpdater
        nonReentrant
    {
        _validateBatchLength(quoteTickUpdates.length);
        address previousQuoteToken;
        for (uint256 i = 0; i < quoteTickUpdates.length; i++) {
            IRWAQuoteRegistry.QuoteTickUpdate calldata update = quoteTickUpdates[i];
            if (i != 0) _validateSortedAddress(previousQuoteToken, update.quoteToken);
            _setQuoteStartTick(update.quoteToken, update.newStartTickToken0Frame, update.expectedRevision);
            previousQuoteToken = update.quoteToken;
        }
    }

    function unregisterQuote(address quoteToken) public onlyOwner nonReentrant {
        _unregisterQuote(quoteToken);
        _bumpConfigVersion();
    }

    function batchUnregisterQuotes(address[] calldata quoteTokens) external onlyOwner nonReentrant {
        _validateBatchLength(quoteTokens.length);
        address previousQuoteToken;
        for (uint256 i = 0; i < quoteTokens.length; i++) {
            address quoteToken = quoteTokens[i];
            if (i != 0) _validateSortedAddress(previousQuoteToken, quoteToken);
            _unregisterQuote(quoteToken);
            previousQuoteToken = quoteToken;
        }
        _bumpConfigVersion();
    }

    function setPriceUpdater(address newPriceUpdater) external onlyOwner nonReentrant {
        address previousPriceUpdater = priceUpdater;
        if (newPriceUpdater == previousPriceUpdater) return;
        priceUpdater = newPriceUpdater;
        _bumpConfigVersion();
        emit PriceUpdaterUpdated(previousPriceUpdater, newPriceUpdater);
    }

    function setLaunchCreationEnabled(bool creationEnabled) external onlyOwner nonReentrant {
        if (creationEnabled == launchCreationEnabled) return;
        if (creationEnabled) _requireLaunchCreationWiring();
        launchCreationEnabled = creationEnabled;
        _bumpConfigVersion();
        emit LaunchCreationEnabledUpdated(creationEnabled);
    }

    function renounceOwnership() public override onlyOwner {
        if (launchCreationEnabled || priceUpdater != address(0)) revert UnsafeOwnershipRenunciation();
        super.renounceOwnership();
    }

    function launchTokenBytecodeHash(LaunchParams calldata launchParams) external view returns (bytes32 bytecodeHash) {
        return tokenDeployer.tokenBytecodeHash(_tokenParams(launchParams, launchSupply));
    }

    function _beforeCreateLaunch(LaunchParams calldata launchParams) internal view override {
        super._beforeCreateLaunch(launchParams);
        if (!launchCreationEnabled) revert LaunchCreationDisabled();
        _validateQuoteStartTick(_quoteConfig[launchParams.quoteToken].startTickToken0Frame);
    }

    function _registerQuote(address quoteToken, int24 startTickToken0Frame) internal {
        if (quoteToken != address(0) && quoteToken.code.length == 0) revert InvalidQuoteToken();
        if (_quoteConfig[quoteToken].registered) revert QuoteAlreadyRegistered();
        _validateQuoteStartTick(startTickToken0Frame);

        uint8 quoteDecimals = quoteToken == address(0) ? 18 : IERC20Metadata(quoteToken).decimals();
        _quoteConfig[quoteToken] =
            QuoteConfig({registered: true, quoteDecimals: quoteDecimals, startTickToken0Frame: startTickToken0Frame});
        uint64 revision = _nextQuoteRevision(quoteToken);
        emit QuoteRegistered(quoteToken, quoteDecimals, startTickToken0Frame, revision);
    }

    function _setQuoteStartTick(address quoteToken, int24 newStartTickToken0Frame, uint64 expectedRevision) internal {
        QuoteConfig storage config = _quoteConfig[quoteToken];
        if (!config.registered) revert QuoteNotRegistered();

        uint64 actualRevision = quoteRevision[quoteToken];
        if (expectedRevision != actualRevision) {
            revert StaleQuoteRevision(quoteToken, expectedRevision, actualRevision);
        }
        _validateQuoteStartTick(newStartTickToken0Frame);
        int24 previousStartTickToken0Frame = config.startTickToken0Frame;
        if (newStartTickToken0Frame == previousStartTickToken0Frame) return;

        config.startTickToken0Frame = newStartTickToken0Frame;
        uint64 revision = _nextQuoteRevision(quoteToken);
        emit QuoteStartTickUpdated(quoteToken, previousStartTickToken0Frame, newStartTickToken0Frame, revision);
    }

    function _unregisterQuote(address quoteToken) internal {
        if (!_quoteConfig[quoteToken].registered) revert QuoteNotRegistered();
        delete _quoteConfig[quoteToken];
        uint64 revision = _nextQuoteRevision(quoteToken);
        emit QuoteUnregistered(quoteToken, revision);
    }

    function _nextQuoteRevision(address quoteToken) internal returns (uint64 revision) {
        revision = quoteRevision[quoteToken] + 1;
        quoteRevision[quoteToken] = revision;
    }

    function _validateQuoteStartTick(int24 startTickToken0Frame) internal view {
        _validateStartTickFrame(startTickToken0Frame);
        if (startTickToken0Frame % tickSpacing != 0) revert MisalignedStartTick();
    }

    function _validateBatchLength(uint256 length) internal pure {
        if (length == 0 || length > MAX_QUOTE_BATCH_SIZE) revert QuoteBatchOutOfBounds();
    }

    function _validateSortedAddress(address previousQuoteToken, address currentQuoteToken) internal pure {
        if (uint160(currentQuoteToken) <= uint160(previousQuoteToken)) revert QuoteBatchNotSorted();
    }

    function _validatePredictedToken(address predictedToken) internal pure override {
        if ((uint160(predictedToken) & 0xff) != TOKEN_ADDRESS_SUFFIX) {
            revert InvalidTokenAddressSuffix(predictedToken);
        }
    }

    function _requireLaunchCreationWiring() internal view override {
        super._requireLaunchCreationWiring();
        if (tokenDeployer.factory() != address(this)) revert InvalidConfig();
    }
}
