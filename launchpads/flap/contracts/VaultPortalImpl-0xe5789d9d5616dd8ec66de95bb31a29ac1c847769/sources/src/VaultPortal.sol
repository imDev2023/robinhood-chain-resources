// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {IPortalTypes} from "./interfaces/IPortal.sol";
import {IVaultPortal} from "./interfaces/IVaultPortal.sol";
import {VaultPortalBase} from "./VaultPortalBase.sol";

/// @title VaultPortal
/// @notice Manages different vault types through a factory pattern for tax tokens
/// @dev Upgradeable contract using Transparent Proxy pattern.
///      View-only logic lives in VaultPortalLens; VaultPortal forwards `view` calls there
///      via `delegatecall` so the lens executes against this contract's own storage.
contract VaultPortal is VaultPortalBase, IVaultPortal {
    /// @notice The exact native-token amount required to pay for an audit order.
    uint256 public immutable AUDIT_PRICE;

    /// @notice The externally deployed VaultPortalLens module used for delegated view logic
    address public immutable LENS;

    /// @notice The externally deployed VaultPortalLaunch module used for launch flows
    address public immutable VAULT_PORTAL_LAUNCH;

    /// @notice The externally deployed VaultPortalTweak module used for admin/tweak flows
    address public immutable VAULT_PORTAL_TWEAK;

    /// @notice The externally deployed VaultPortalUIRegistry module used for UI artifact registry writes
    address public immutable VAULT_PORTAL_UI_REGISTRY;

    /// @notice The externally deployed VaultPortalAudit module used for audit payment and query flows
    address public immutable VAULT_PORTAL_AUDIT;

    /// @notice Constructor to set immutable variables and bind externally deployed satellite modules
    /// @param params Struct containing shared immutable config plus the deployed module addresses
    constructor(VaultPortalConstructorParams memory params) VaultPortalBase(params.baseParams) {
        if (
            params.lens == address(0) || params.vaultPortalLaunch == address(0) || params.vaultPortalTweak == address(0)
                || params.vaultPortalUIRegistry == address(0) || params.vaultPortalAudit == address(0)
        ) {
            revert ZeroModuleAddress();
        }
        if (!_isContract(params.lens)) {
            revert InvalidModuleAddress(params.lens);
        }
        if (!_isContract(params.vaultPortalLaunch)) {
            revert InvalidModuleAddress(params.vaultPortalLaunch);
        }
        if (!_isContract(params.vaultPortalTweak)) {
            revert InvalidModuleAddress(params.vaultPortalTweak);
        }
        if (!_isContract(params.vaultPortalUIRegistry)) {
            revert InvalidModuleAddress(params.vaultPortalUIRegistry);
        }
        if (!_isContract(params.vaultPortalAudit)) {
            revert InvalidModuleAddress(params.vaultPortalAudit);
        }

        LENS = params.lens;
        VAULT_PORTAL_LAUNCH = params.vaultPortalLaunch;
        VAULT_PORTAL_TWEAK = params.vaultPortalTweak;
        VAULT_PORTAL_UI_REGISTRY = params.vaultPortalUIRegistry;
        VAULT_PORTAL_AUDIT = params.vaultPortalAudit;
        AUDIT_PRICE = params.vaultPortalAuditPrice;

        _disableInitializers();
    }

    /// @notice Initialize the contract
    /// @dev Grants DEFAULT_ADMIN_ROLE and VAULT_ADMIN_ROLE to deployer
    function initialize() external initializer {
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(VAULT_ADMIN_ROLE, msg.sender);
    }

    /// @notice Get the version of this contract
    /// @return The version string
    function version() external pure returns (string memory) {
        // v1.12.0:
        // - Moved audit payment and audit-order query logic into a dedicated VaultPortalAudit delegatecall module.
        // - Replaced getMyLatestAuditOrder with paginated getMyAuditOrders(offset, limit), ordered newest first.
        // - Added vaultPortalAudit module wiring in constructor params.
        // - Audit payments are forwarded immediately to the configured audit-fee receiver.
        //
        // v1.10.0:
        // - Added VaultPortalUIRegistry as a dedicated delegatecall module.
        // - Added token/vault/factory UI artifact bindings with Token > Vault > Factory resolution.
        //
        // v1.9.0:
        // - Added MAGIC_DIVIDEND_COMPUTED sentinel support in newTokenV6WithVault and newTokenV7WithVault.
        // - VaultPortal now resolves computed dividend tokens by calling IVaultFactoryDividendV23.resolveDividendToken
        //   on the selected vault factory when the sentinel is supplied.
        // - Requires a v2.3+ vault factory; reverts with FactoryDoesNotSupportComputedDividend otherwise.
        // - Added _isSpecVersionV23OrHigher and _getFactorySpecVersion helpers to VaultPortalBase.
        // - Added DIVIDEND_TOKEN_LAUNCH_VERSION_V6 / V7 version markers for factory resolver decoding.
        // v1.8.1:
        // - Fixed newTokenV7WithVault to match upstream Portal.newTokenV7 directly.
        // - Supports both TOKEN_V3_PERMIT (0x8888 vanity) and TOKEN_TAXED_V3 (0x7777 vanity).
        // - Calls Portal.newTokenV7 directly instead of translating through newTokenV6 / V6 hooks.
        //
        // v1.7.0:
        // - Added FactoryPermissionPolicy (OPEN, TIME_DEPENDENT, DISABLED) to VaultFactoryInfo.
        // - New mapping _factoryPolicyData stores per-factory policy data (packed bytes32).
        // - getFactoryPolicy() view returns policy enum, raw data, and human-readable description.
        // - newTokenV6WithVault enforces the factory's permission policy before proceeding.
        // - VaultPortalTweak: disableFactory() and setTimeDependentPolicy() restricted to AUDITOR_ROLE.
        //
        // v1.6.0:
        // - Deprecated newTaxTokenWithVault (V1/V2 tax token path via newTokenV5).
        //   The function now reverts with a human-readable message directing callers
        //   to use newTokenV6WithVault instead.
        //
        // v1.5.0:
        // - Added refreshTokenVault(address token): syncs the stored vault address for a token
        //   with the current on-chain market wallet (reads from TaxSplitter.beneficiary for V1 or
        //   TaxProcessor.marketAddress for V2/V3). Restricted to AUDITOR_ROLE.
        //
        // v1.4.0:
        // - Implemented ISaltOwnerProvider: VaultPortal now exposes getSaltOwner() so Portal
        //   can resolve the true end-user when checking salt locks.
        // - _pendingSaltOwner is set to msg.sender immediately before each Portal call
        //   (newTokenV5, newTokenV6) and cleared to address(0) afterwards.
        //
        // v1.3.1:
        // - Added onBeforeNewTokenV6WithVault hook validation in newTokenV6WithVault.
        // - Factories can now reject token creation with custom validation logic.
        // - Fixed tryGetVault to return false when description call fails or returns empty string.
        //
        // v1.3.0:
        // - Added TOKEN_IMPL_TAXED_V3 immutable for V3 tax token address prediction.
        // - Added newTokenV6WithVault as a wrapper for Portal's newTokenV6.
        // - Only TOKEN_TAXED_V3 is supported; other versions revert with FeatureDisabled.
        return "1.12.1";
    }

    /// @notice Pay the configured audit price for an off-chain order.
    /// @param orderId The external audit order id.
    function payAudit(string calldata orderId) external payable {
        orderId;
        _delegateToImpl(VAULT_PORTAL_AUDIT);
    }

    /// @notice Returns the configured treasury address that receives audit payments.
    function AUDIT_FEE_RECEIVER() external view returns (address) {
        bytes memory result = _delegateToAuditView(abi.encodeWithSignature("AUDIT_FEE_RECEIVER()"));
        return abi.decode(result, (address));
    }

    /// @notice Get an audit payment order by order id.
    /// @param orderId The external audit order id.
    /// @return found Whether the order exists.
    /// @return order The stored audit payment order.
    function getAuditOrder(string calldata orderId) external view returns (bool found, AuditPaymentOrder memory order) {
        bytes memory result = _delegateToAuditView(abi.encodeWithSignature("getAuditOrder(string)", orderId));
        return abi.decode(result, (bool, AuditPaymentOrder));
    }

    /// @notice Get the caller's audit payment orders in reverse chronological order with pagination.
    /// @param offset The number of most-recent orders to skip.
    /// @param limit The maximum number of orders to return.
    /// @return orders The caller's audit payment orders, newest first.
    /// @return total The total number of audit payment orders for the caller.
    function getMyAuditOrders(uint256 offset, uint256 limit)
        external
        view
        returns (AuditPaymentOrder[] memory orders, uint256 total)
    {
        bytes memory result =
            _delegateToAuditView(abi.encodeWithSignature("getMyAuditOrders(address,uint256,uint256)", msg.sender, offset, limit));
        return abi.decode(result, (AuditPaymentOrder[], uint256));
    }

    // -------------------------------------------------------------------------
    // View functions — forwarded to VaultPortalLens via delegatecall
    // -------------------------------------------------------------------------

    /// @dev Forwards the current call to LENS by routing through `inspect`, which performs
    ///      a delegatecall. Using `address(this).staticcall` allows the outer function to
    ///      remain `view` while still executing delegatecall logic inside `inspect`.
    function _delegateToLens() internal view {
        (bool success, bytes memory result) =
            address(this).staticcall(abi.encodeWithSelector(this.inspect.selector, msg.data));
        if (!success) {
            assembly ("memory-safe") {
                revert(add(result, 0x20), mload(result))
            }
        }
        assembly ("memory-safe") {
            // `result` holds the ABI-encoded return of `inspect` (a `bytes`):
            //   [length-of-encoding][uint256(0x20)][inner-length][inner-data]
            // We skip the outer 3 words (0x60 bytes) and return only the inner bytes,
            // which is the raw return value from the delegatecall to LENS.
            return(add(result, 0x60), mload(add(result, 0x40)))
        }
    }

    /// @dev Forwards audit-related view calls through `inspectAudit`, which performs a delegatecall
    ///      into the dedicated audit module while preserving this contract's storage context.
    function _delegateToAuditView(bytes memory data) internal view returns (bytes memory result) {
        (bool success, bytes memory response) = address(this).staticcall(abi.encodeWithSelector(this.inspectAudit.selector, data));
        if (!success) {
            assembly ("memory-safe") {
                revert(add(response, 0x20), mload(response))
            }
        }

        result = abi.decode(response, (bytes));
    }

    /// @notice Executes a delegatecall to LENS against this contract's storage.
    /// @dev Not meant to be called directly. Called via staticcall from `_delegateToLens`
    ///      so that view functions can forward calls to LENS without violating the view restriction.
    /// @param data The calldata to forward (typically `msg.data` from the calling view function)
    /// @return result The raw return bytes from the delegatecall to LENS
    function inspect(bytes memory data) external returns (bytes memory result) {
        (bool success, bytes memory response) = LENS.delegatecall(data);
        if (!success) {
            assembly ("memory-safe") {
                revert(add(response, 0x20), mload(response))
            }
        }
        return response;
    }

    /// @notice Executes a delegatecall to the dedicated audit module against this contract's storage.
    /// @dev Not meant to be called directly. Called via staticcall from `_delegateToAuditView`.
    /// @param data The calldata to forward to the audit module.
    /// @return result The raw return bytes from the delegatecall to the audit module.
    function inspectAudit(bytes memory data) external returns (bytes memory result) {
        (bool success, bytes memory response) = VAULT_PORTAL_AUDIT.delegatecall(data);
        if (!success) {
            assembly ("memory-safe") {
                revert(add(response, 0x20), mload(response))
            }
        }
        return response;
    }

    /// @notice Get information about a registered vault factory
    /// @param factory The address of the vault factory
    /// @return enabled Whether this factory can be used to create new vaults
    /// @return official Whether vaults created by this factory are marked as official/endorsed
    /// @return riskLevel The risk level classification for vaults from this factory
    /// @return reserved Reserved space (the first byte encodes VaultCategory; remaining 28 bytes are padding)
    function vaultFactories(address factory)
        external
        view
        returns (bool enabled, bool official, RiskLevel riskLevel, bytes29 reserved)
    {
        _delegateToLens();
    }

    /// @notice Deprecated. Use newTokenV6WithVault instead.
    /// @dev This function previously created a V1/V2 tax token via Portal's newTokenV5.
    ///      It is no longer supported. Calling it will always revert.
    /// @param params Unused — kept for ABI compatibility only.
    function newTaxTokenWithVault(NewTaxTokenWithVaultParams calldata params) external payable returns (address token) {
        params;
        revert("newTaxTokenWithVault is deprecated and no longer supported. " "Please use newTokenV6WithVault instead.");
    }

    /// @notice Create a new tax token via Portal's newTokenV6 with vault
    /// @dev Only TOKEN_TAXED_V3 is currently supported; other versions revert with FeatureDisabled.
    /// @param params The parameters for creating the tax token with vault
    /// @return token The address of the newly created tax token
    function newTokenV6WithVault(NewTokenV6WithVaultParams calldata params) external payable returns (address token) {
        params;
        _delegateToImpl(VAULT_PORTAL_LAUNCH);
    }

    /// @notice Create a new token via Portal's newTokenV7 with vault
    /// @dev Supports TOKEN_V3_PERMIT (non-tax) and TOKEN_TAXED_V3 (tax).
    ///      MARKETING_OR_VAULT fee recipients are rewritten to the created vault before forwarding.
    /// @param params The parameters for creating the token with vault
    /// @return token The address of the newly created token
    function newTokenV7WithVault(NewTokenV7WithVaultParams calldata params) external payable returns (address token) {
        params;
        _delegateToImpl(VAULT_PORTAL_LAUNCH);
    }

    /// @notice Predict the tax token V1 address
    /// @param salt The salt for deterministic deployment
    /// @return predictedAddress The predicted tax token address
    function predictTaxTokenV1Address(bytes32 salt) external view returns (address predictedAddress) {
        _delegateToLens();
    }

    /// @notice Get vault info for a tax token
    /// @param taxToken The tax token address
    /// @return info The vault info
    function getVault(address taxToken) external view returns (VaultInfo memory info) {
        _delegateToLens();
    }

    /// @notice Try to get vault info for a tax token
    /// @param taxToken The tax token address
    /// @dev mainly for unified access from UI side
    /// @return found Whether the vault was found
    /// @return info The vault info
    function tryGetVault(address taxToken) external view returns (bool found, VaultInfo memory info) {
        _delegateToLens();
    }

    /// @notice Register or update a vault factory (backward-compatible, defaults category to NONE)
    /// @param factory The vault factory address
    /// @param enabled Whether the factory is enabled
    /// @param official Whether vaults from this factory are official
    /// @param riskLevel The risk level classification for vaults from this factory
    function registerVaultFactory(address factory, bool enabled, bool official, RiskLevel riskLevel)
        external
        onlyRole(VAULT_ADMIN_ROLE)
    {
        _registerVaultFactory(factory, enabled, official, riskLevel, VaultCategory.NONE);
    }

    /// @notice Register or update a vault factory with a specific category
    /// @param factory The vault factory address
    /// @param enabled Whether the factory is enabled
    /// @param official Whether vaults from this factory are official
    /// @param riskLevel The risk level classification for vaults from this factory
    /// @param category The category classification for vaults from this factory
    function registerVaultFactory(
        address factory,
        bool enabled,
        bool official,
        RiskLevel riskLevel,
        VaultCategory category
    ) external onlyRole(VAULT_ADMIN_ROLE) {
        _registerVaultFactory(factory, enabled, official, riskLevel, category);
    }

    /// @notice Register an adapter for a legacy tax token vault
    /// @param taxToken The tax token address
    /// @param adapter The adapter contract address
    function registerAdapter(address taxToken, address adapter) external onlyRole(AUDITOR_ROLE) {
        VaultedTaxTokenInfo storage vaultInfo = taxVaults[taxToken];

        // If vault doesn't exist, try to find it from Portal
        if (vaultInfo.vault == address(0)) {
            address potentialVault = _findVaultFromPortal(taxToken);
            if (potentialVault == address(0) || !_isContract(potentialVault)) {
                revert TokenNotFound(taxToken);
            }
            // Initialize vault info with default values
            vaultInfo.vault = potentialVault;
        }

        // Set the adapter
        vaultInfo.adapter = adapter;

        emit AdapterRegistered(taxToken, adapter);
    }

    /// @notice Submit a new audit report for a tax token
    /// @param taxToken The tax token address
    /// @param riskLevel The risk level classification from this audit
    /// @param ipfsCid The IPFS CID of the audit report
    function submitAuditReport(address taxToken, RiskLevel riskLevel, string calldata ipfsCid)
        external
        onlyRole(AUDITOR_ROLE)
    {
        VaultedTaxTokenInfo storage vaultInfo = taxVaults[taxToken];

        // If vault doesn't exist, try to find it from Portal
        if (vaultInfo.vault == address(0)) {
            address potentialVault = _findVaultFromPortal(taxToken);
            if (potentialVault == address(0) || !_isContract(potentialVault)) {
                revert TokenNotFound(taxToken);
            }
            // Initialize vault info with default values
            vaultInfo.vault = potentialVault;
        }

        // Update the risk level
        vaultInfo.riskLevel = riskLevel;

        // Create and store the audit report
        auditReports[taxToken].push(AuditReport({auditor: msg.sender, riskLevel: riskLevel, ipfsCid: ipfsCid}));

        emit AuditReportSubmitted(taxToken, msg.sender, riskLevel, ipfsCid);
    }

    /// @notice Submit a new audit report for a vault factory
    /// @param factory The vault factory address
    /// @param riskLevel The risk level classification from this audit
    /// @param ipfsCid The IPFS CID of the audit report
    function submitFactoryAuditReport(address factory, RiskLevel riskLevel, string calldata ipfsCid)
        external
        onlyRole(VAULT_ADMIN_ROLE)
    {
        // Ensure the factory is registered and enabled
        if (!_vaultFactories[factory].enabled) {
            revert VaultFactoryNotRegistered(factory);
        }

        // Create and store the audit report for the factory
        factoryAuditReports[factory].push(AuditReport({auditor: msg.sender, riskLevel: riskLevel, ipfsCid: ipfsCid}));

        emit FactoryAuditReportSubmitted(factory, msg.sender, riskLevel, ipfsCid);
    }

    /// @notice Get recent audit reports for a tax token with pagination
    function getAuditReports(address taxToken, uint256 offset, uint256 limit)
        external
        view
        returns (AuditReport[] memory reports, uint256 total)
    {
        _delegateToLens();
    }

    /// @notice Get the category of a vault
    /// @param taxToken The tax token address
    /// @return The category of the vault
    function getVaultCategory(address taxToken) external view returns (VaultCategory) {
        _delegateToLens();
    }

    /// @notice Get the category of a vault factory
    /// @param factory The vault factory address
    /// @return The category of the factory
    function getFactoryCategory(address factory) external view returns (VaultCategory) {
        _delegateToLens();
    }

    /// @notice Get the permission policy for a vault factory
    /// @param factory The vault factory address
    /// @return policy     The active FactoryPermissionPolicy
    /// @return policyData Raw 32-byte policy-specific data slot
    /// @return description Human-readable explanation of the current policy
    function getFactoryPolicy(address factory)
        external
        view
        returns (FactoryPermissionPolicy policy, bytes32 policyData, string memory description)
    {
        _delegateToLens();
    }

    /// @notice Get the cached validation mode for a vault factory.
    function getFactoryValidationMode(address factory) external view returns (FactoryValidationMode mode, bool cached) {
        factory;
        _delegateToLens();
    }

    // ---------------------------------------------------------------------
    // UI Artifact Registry — unified by BindingScope
    // ---------------------------------------------------------------------

    /// @notice Get the UI artifact bound to a target in the given scope.
    function getArtifact(BindingScope, address) external view returns (ArtifactRef memory) {
        _delegateToLens();
    }

    /// @notice Resolve the enabled artifact using Token > Vault > Factory priority.
    function resolveArtifact(address, address, address)
        external
        view
        returns (ArtifactRef memory, BindingScope, address)
    {
        _delegateToLens();
    }

    /// @notice Resolve the active artifact and compare it with an expected artifact id and manifest hash.
    function resolveArtifactBinding(address, address, address, string calldata, bytes32)
        external
        view
        returns (bool, ArtifactRef memory, BindingScope, address)
    {
        _delegateToLens();
    }

    /// @notice Bind a UI artifact to a target in the given scope.
    function bindArtifact(BindingScope, address, string calldata, bytes32) external {
        _delegateToImpl(VAULT_PORTAL_UI_REGISTRY);
    }

    /// @notice Update the artifactId / manifestHash of an existing binding.
    function updateArtifact(BindingScope, address, string calldata, bytes32) external {
        _delegateToImpl(VAULT_PORTAL_UI_REGISTRY);
    }

    /// @notice Enable or disable an existing binding.
    function updateArtifactStatus(BindingScope, address, bool) external {
        _delegateToImpl(VAULT_PORTAL_UI_REGISTRY);
    }

    /// @notice Clear (remove) an existing binding.
    function clearArtifact(BindingScope, address) external {
        _delegateToImpl(VAULT_PORTAL_UI_REGISTRY);
    }

    /// @notice Set the category of a vault
    /// @param taxToken The tax token address
    /// @param category The new category
    function setVaultCategory(address taxToken, VaultCategory category) external onlyRole(VAULT_ADMIN_ROLE) {
        VaultedTaxTokenInfo storage vaultInfo = taxVaults[taxToken];
        if (vaultInfo.vault == address(0)) {
            revert VaultNotFound(taxToken);
        }
        vaultInfo.category = category;
        emit VaultCategoryUpdated(taxToken, category);
    }

    /// @notice Set the category of a vault factory
    /// @dev Works for both registered and unregistered factories.
    ///      Setting a category on an unregistered factory has no effect on vault creation
    ///      since unregistered factories always result in NONE category for new vaults.
    /// @param factory The vault factory address
    /// @param category The new category
    function setFactoryCategory(address factory, VaultCategory category) external onlyRole(VAULT_ADMIN_ROLE) {
        VaultFactoryInfo storage factoryInfo = _vaultFactories[factory];
        factoryInfo.category = category;
        emit FactoryCategoryUpdated(factory, category);
    }

    /// @inheritdoc IVaultPortal
    function refreshTokenVault(
        address /*token*/
    )
        external
    {
        _delegateToImpl(VAULT_PORTAL_TWEAK);
    }

    /// @notice Permanently disable a factory so no one can launch tokens using it.
    /// @dev Only callable by AUDITOR_ROLE.
    function disableFactory(
        address /*factory*/
    )
        external
    {
        _delegateToImpl(VAULT_PORTAL_TWEAK);
    }

    /// @notice Set a time-dependent launch policy for a factory.
    /// @dev Only callable by AUDITOR_ROLE.
    function setTimeDependentPolicy(
        address,
        /*factory*/
        address,
        /*developer*/
        uint64 /*expirationDuration*/
    )
        external
    {
        _delegateToImpl(VAULT_PORTAL_TWEAK);
    }

    /// @notice Reset a factory's permission policy back to OPEN (unrestricted access).
    /// @dev Only callable by AUDITOR_ROLE.
    function resetFactoryPolicy(
        address /*factory*/
    )
        external
    {
        _delegateToImpl(VAULT_PORTAL_TWEAK);
    }

    /// @notice Allow the contract to receive ETH refunds from Portal
    receive() external payable {}
}

