// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {Initializable} from "@openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin-contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ClonesUpgradeable} from "@openzeppelin-contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {IVaultFactory, IVaultFactoryDividendV23} from "./interfaces/IVaultFactory.sol";
import {VaultFactoryBaseV2} from "./interfaces/VaultFactoryBaseV2.sol";
import {IPortal, IPortalTypes, IPortalCommonTypes, MAGIC_DIVIDEND_COMPUTED} from "./interfaces/IPortal.sol";
import {IVaultPortalTypes} from "./interfaces/IVaultPortal.sol";
import {ISaltOwnerProvider} from "./interfaces/ISaltOwnerProvider.sol";
import {Strings} from "@openzeppelin/utils/Strings.sol";

/// @title VaultPortalBase
/// @notice Abstract base contract holding all inheritance, storage, and internal logic for VaultPortal
/// @dev Shared by VaultPortal (the upgradeable entry point) and VaultPortalLens (the view-function satellite).
///      Both contracts must be deployed with identical constructor arguments so their immutables match,
///      allowing VaultPortal to delegatecall into VaultPortalLens for read-only execution against the
///      proxy's own storage.
///      All non-immutable VaultPortal storage lives in this base contract. Append new storage here only,
///      and keep VaultPortal / satellite modules free of non-immutable storage variables.
abstract contract VaultPortalBase is Initializable, AccessControlUpgradeable, IVaultPortalTypes, ISaltOwnerProvider {
    using SafeERC20 for IERC20;

    /// @notice Role that can manage vault factories
    bytes32 public constant VAULT_ADMIN_ROLE = keccak256("VAULT_ADMIN_ROLE");

    /// @notice Role that can register adapters and submit audit reports
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");

    /// @notice Vanity suffix for tax tokens (0x7777)
    uint256 public immutable TAX_TOKEN_SUFFIX;

    /// @notice Vanity suffix for non-tax TokenV3 launches (0x8888)
    uint256 public constant NON_TAX_TOKEN_SUFFIX = 0x8888;

    /// @notice The Portal contract address (immutable)
    address public immutable PORTAL;

    /// @notice The tax token V1 implementation address (immutable)
    address public immutable TOKEN_IMPL_TAXED;

    /// @notice The tax token V2 implementation address (immutable)
    address public immutable TOKEN_IMPL_TAXED_V2;

    /// @notice The tax token V3 implementation address (immutable)
    address public immutable TOKEN_IMPL_TAXED_V3;

    /// @notice The non-tax Token V3 implementation address (immutable)
    address public immutable TOKEN_IMPL_V3;

    /// @notice Mapping from vault factory address to VaultFactoryInfo
    mapping(address => VaultFactoryInfo) internal _vaultFactories;

    /// @notice Mapping from tax token address to VaultedTaxTokenInfo
    mapping(address => VaultedTaxTokenInfo) internal taxVaults;

    /// @notice Mapping from tax token address to array of audit reports
    mapping(address => AuditReport[]) internal auditReports;

    /// @notice Mapping from vault factory address to array of audit reports
    mapping(address => AuditReport[]) internal factoryAuditReports;

    /// @notice Holds the real end-user address during an active Portal call.
    /// @dev Set to `msg.sender` immediately before calling Portal and cleared to address(0)
    ///      after Portal returns.  Portal reads this via the ISaltOwnerProvider callback to
    ///      resolve the true initiator when checking salt locks.
    address internal _pendingSaltOwner;

    /// @notice Mapping from vault factory address to policy-specific packed data
    /// @dev For TIME_DEPENDENT: top 64 bits = expirationTime, next 160 bits = developer address
    mapping(address => bytes32) internal _factoryPolicyData;

    /// @notice Whether VaultPortal has already cached a validation mode for a factory.
    /// @dev Appended at the end of storage to preserve upgrade-safe layout ordering.
    mapping(address => bool) internal _factoryValidationModeCached;

    /// @notice UI artifact bindings keyed by tax token address.
    /// @dev Appended at the end of storage to preserve upgrade-safe layout ordering.
    mapping(address => ArtifactRef) internal _tokenArtifacts;

    /// @notice UI artifact bindings keyed by vault address.
    /// @dev Appended at the end of storage to preserve upgrade-safe layout ordering.
    mapping(address => ArtifactRef) internal _vaultArtifacts;

    /// @notice UI artifact bindings keyed by vault factory address.
    /// @dev Appended at the end of storage to preserve upgrade-safe layout ordering.
    mapping(address => ArtifactRef) internal _factoryArtifacts;

    /// @notice Audit payment orders keyed by keccak256(orderId).
    /// @dev Appended at the end of storage to preserve upgrade-safe layout ordering.
    mapping(bytes32 => AuditPaymentOrder) internal _auditPaymentOrders;

    /// @notice All paid audit order keys for each payer in insertion order.
    /// @dev Appended at the end of storage to preserve upgrade-safe layout ordering.
    mapping(address => bytes32[]) internal _auditOrderKeysByPayer;

    /// @inheritdoc ISaltOwnerProvider
    function getSaltOwner() external view returns (address) {
        return _pendingSaltOwner;
    }

    /// @param params Shared immutable constructor parameters for VaultPortal and its satellite modules
    constructor(VaultPortalBaseParams memory params) {
        if (params.portal == address(0)) {
            revert ZeroPortalAddress();
        }
        //        if (params.tokenImplTaxed == address(0)) {
        //            revert ZeroTokenImplAddress();
        //        }
        //        if (params.tokenImplTaxedV2 == address(0)) {
        //            revert ZeroTokenImplAddress();
        //        }

        PORTAL = params.portal;
        TOKEN_IMPL_TAXED = params.tokenImplTaxed;
        TOKEN_IMPL_TAXED_V2 = params.tokenImplTaxedV2;
        TOKEN_IMPL_TAXED_V3 = params.tokenImplTaxedV3;
        TOKEN_IMPL_V3 = params.tokenImplV3;
        TAX_TOKEN_SUFFIX = params.taxTokenSuffix;
    }

    /// @dev Internal implementation for registerVaultFactory
    function _registerVaultFactory(
        address factory,
        bool enabled,
        bool official,
        RiskLevel riskLevel,
        VaultCategory category
    ) internal {
        FactoryValidationMode validationMode = _detectFactoryValidationMode(factory);
        _vaultFactories[factory] = VaultFactoryInfo({
            enabled: enabled,
            official: official,
            riskLevel: riskLevel,
            category: category,
            permissionPolicy: FactoryPermissionPolicy.OPEN,
            validationMode: validationMode,
            reserved: bytes26(0)
        });
        _factoryValidationModeCached[factory] = true;

        emit FlapTaxVaultFactoryRegistered(factory, enabled, official, riskLevel);
        emit FlapTaxVaultFactoryCategorySet(factory, category);
    }

    /// @notice Find vault address from Portal for a given tax token
    /// @param taxToken The tax token address
    /// @return vault The vault address, or address(0) if not found
    function _findVaultFromPortal(address taxToken) internal view returns (address vault) {
        // Get token from Portal
        (bool success, bytes memory result) =
            PORTAL.staticcall(abi.encodeWithSignature("getTokenV6(address)", taxToken));

        if (!success || result.length == 0) {
            return address(0);
        }

        IPortalTypes.TokenStateV6 memory state = abi.decode(result, (IPortalTypes.TokenStateV6));

        // For TOKEN_TAXED (v1): get tax splitter, then beneficiary
        if (state.tokenVersion == IPortalTypes.TokenVersion.TOKEN_TAXED) {
            // Get tax splitter address
            (bool splitterSuccess, bytes memory splitterResult) =
                taxToken.staticcall(abi.encodeWithSignature("taxSplitter()"));

            if (splitterSuccess && splitterResult.length > 0) {
                address taxSplitter = abi.decode(splitterResult, (address));

                // Get beneficiary from tax splitter
                (bool beneficiarySuccess, bytes memory beneficiaryResult) =
                    taxSplitter.staticcall(abi.encodeWithSignature("beneficiary()"));

                if (beneficiarySuccess && beneficiaryResult.length > 0) {
                    vault = abi.decode(beneficiaryResult, (address));
                }
            }
        }
        // For TOKEN_TAXED_V2 (v2), TOKEN_TAXED_V3 (v3), and TOKEN_V3_PERMIT: get tax processor,
        // check marketBps > 0, then get marketAddress
        else if (
            state.tokenVersion == IPortalTypes.TokenVersion.TOKEN_TAXED_V2
                || state.tokenVersion == IPortalTypes.TokenVersion.TOKEN_TAXED_V3
                || state.tokenVersion == IPortalTypes.TokenVersion.TOKEN_V3_PERMIT
        ) {
            // Get tax processor address
            (bool processorSuccess, bytes memory processorResult) =
                taxToken.staticcall(abi.encodeWithSignature("taxProcessor()"));

            if (processorSuccess && processorResult.length > 0) {
                address taxProcessor = abi.decode(processorResult, (address));

                // Get feeConfig from tax processor
                (bool configSuccess, bytes memory configResult) =
                    taxProcessor.staticcall(abi.encodeWithSignature("feeConfig()"));

                if (configSuccess && configResult.length > 0) {
                    // Decode PackedFeeConfig struct (marketBps, deflationBps, lpBps, dividendBps, feeRate, isWeth)
                    (uint16 marketBps,,,,,) = abi.decode(configResult, (uint16, uint16, uint16, uint16, uint16, bool));

                    if (marketBps > 0) {
                        // Get marketAddress from tax processor
                        (bool marketSuccess, bytes memory marketResult) =
                            taxProcessor.staticcall(abi.encodeWithSignature("marketAddress()"));

                        if (marketSuccess && marketResult.length > 0) {
                            vault = abi.decode(marketResult, (address));
                        }
                    }
                }
            }
        }

        return vault;
    }

    /// @notice Check if an address is a contract (excluding EIP-7702 delegated EOAs)
    /// @param account The address to check
    /// @return True if the address is a contract, false if it's an EOA or EIP-7702 delegated account
    function _isContract(address account) internal view returns (bool) {
        // Check if account has code
        if (account.code.length == 0) {
            return false;
        }

        // Check for EIP-7702 delegation indicator (0xef0100)
        // EIP-7702 delegated accounts start with this prefix
        if (account.code.length >= 3) {
            bytes memory code = account.code;
            if (code[0] == 0xef && code[1] == 0x01 && code[2] == 0x00) {
                return false;
            }
        }

        return true;
    }

    /// @dev Delegates the current call to `impl` using delegatecall.
    ///      Reverts if `impl` is address(0). Bubbles up the return data on both success and failure.
    function _delegateToImpl(address impl) internal {
        if (impl == address(0)) {
            revert FeatureDisabled();
        }
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /// @notice Convert a uint64 to its decimal string representation
    function _uint64ToString(uint64 v) internal pure returns (string memory) {
        return Strings.toString(uint256(v));
    }

    /// @notice Hash an audit order id into its storage key.
    function _auditOrderKey(string memory orderId) internal pure returns (bytes32) {
        return keccak256(bytes(orderId));
    }

    function _bindArtifact(BindingScope scope, address target, string calldata artifactId, bytes32 manifestHash)
        internal
    {
        _requireArtifactTarget(target);
        _requireArtifactPayload(artifactId, manifestHash);
        ArtifactRef storage record = _getArtifactRecord(scope, target);
        if (record.exists) {
            revert BindingAlreadyExists(scope, target);
        }

        record.exists = true;
        record.enabled = true;
        record.artifactId = artifactId;
        record.manifestHash = manifestHash;

        emit ArtifactBindingChanged(scope, target, BindingAction.Bind, true, artifactId, manifestHash, msg.sender);
    }

    function _updateArtifact(BindingScope scope, address target, string calldata artifactId, bytes32 manifestHash)
        internal
    {
        _requireArtifactTarget(target);
        _requireArtifactPayload(artifactId, manifestHash);
        ArtifactRef storage record = _getArtifactRecord(scope, target);
        if (!record.exists) {
            revert BindingNotFound(scope, target);
        }

        record.artifactId = artifactId;
        record.manifestHash = manifestHash;

        emit ArtifactBindingChanged(
            scope, target, BindingAction.Update, record.enabled, artifactId, manifestHash, msg.sender
        );
    }

    function _updateArtifactStatus(BindingScope scope, address target, bool enabled) internal {
        _requireArtifactTarget(target);
        ArtifactRef storage record = _getArtifactRecord(scope, target);
        if (!record.exists) {
            revert BindingNotFound(scope, target);
        }

        record.enabled = enabled;

        emit ArtifactBindingChanged(
            scope, target, BindingAction.SetEnabled, enabled, record.artifactId, record.manifestHash, msg.sender
        );
    }

    function _clearArtifact(BindingScope scope, address target) internal {
        _requireArtifactTarget(target);
        ArtifactRef storage record = _getArtifactRecord(scope, target);
        if (!record.exists) {
            revert BindingNotFound(scope, target);
        }
        if (scope == BindingScope.Token) {
            delete _tokenArtifacts[target];
        } else if (scope == BindingScope.Vault) {
            delete _vaultArtifacts[target];
        } else if (scope == BindingScope.Factory) {
            delete _factoryArtifacts[target];
        }

        emit ArtifactBindingChanged(scope, target, BindingAction.Clear, false, "", bytes32(0), msg.sender);
    }

    function _isArtifactEnabled(ArtifactRef storage record) internal view returns (bool) {
        return record.exists && record.enabled;
    }

    function _requireArtifactTarget(address target) internal pure {
        if (target == address(0)) {
            revert ZeroAddress();
        }
    }

    function _requireArtifactPayload(string calldata artifactId, bytes32 manifestHash) internal pure {
        if (bytes(artifactId).length == 0) {
            revert EmptyArtifactId();
        }
        if (manifestHash == bytes32(0)) {
            revert ZeroManifestHash();
        }
    }

    function _equalStrings(string memory left, string calldata right) internal pure returns (bool) {
        return keccak256(bytes(left)) == keccak256(bytes(right));
    }

    function _getArtifactRecord(BindingScope scope, address target) internal view returns (ArtifactRef storage) {
        if (scope == BindingScope.Token) return _tokenArtifacts[target];
        if (scope == BindingScope.Vault) return _vaultArtifacts[target];
        if (scope == BindingScope.Factory) return _factoryArtifacts[target];
        revert InvalidBindingScope(scope);
    }

    function _getCachedFactoryValidationMode(address factory)
        internal
        view
        returns (bool cached, FactoryValidationMode mode)
    {
        cached = _factoryValidationModeCached[factory];
        mode = _vaultFactories[factory].validationMode;
    }

    function _resolveFactoryValidationMode(address factory) internal returns (FactoryValidationMode mode) {
        (bool cached, FactoryValidationMode cachedMode) = _getCachedFactoryValidationMode(factory);
        if (cached) {
            return cachedMode;
        }

        mode = _detectFactoryValidationMode(factory);
        _vaultFactories[factory].validationMode = mode;
        _factoryValidationModeCached[factory] = true;
    }

    function _detectFactoryValidationMode(address factory) internal view returns (FactoryValidationMode mode) {
        string memory specVersion = _getFactorySpecVersion(factory);
        if (bytes(specVersion).length > 0) {
            if (_isSpecVersionV22OrHigher(specVersion)) {
                return FactoryValidationMode.V22;
            }
        }

        // A non-v2.2 spec string does not by itself prove that the factory has a legacy V6 hook.
        // We still probe the selector below. Only contracts that actually expose
        // `onBeforeNewTokenV6WithVault(...)` at runtime are classified as LEGACY_V6.
        (bool legacyOk, bytes memory legacyRet) = factory.staticcall(
            abi.encodeCall(VaultFactoryBaseV2.onBeforeNewTokenV6WithVault, (_buildValidationProbeParams(factory)))
        );
        if (legacyOk || legacyRet.length > 0) {
            return FactoryValidationMode.LEGACY_V6;
        }

        return FactoryValidationMode.NONE;
    }

    /// @notice Returns whether `factorySpecVersion()` belongs to the normalized pre-launch
    ///         validation generation introduced in v2.2.
    /// @dev    Expected format is `v<major>.<minor>`, for example `v2.1`, `v2.2`, `v2.3`, or `v3.0`.
    ///         Invalid or non-conforming strings are treated as legacy / unsupported for the
    ///         generic `onBeforeLaunch(bytes)` path and therefore return false.
    ///
    ///         Current interpretation:
    ///           - `v2.2+` in the same major line => true
    ///           - any higher major version       => true
    ///           - `v2.1` and below               => false
    function _isSpecVersionV22OrHigher(string memory specVersion) internal pure returns (bool) {
        bytes memory versionBytes = bytes(specVersion);
        if (versionBytes.length < 2 || versionBytes[0] != 0x76) {
            return false;
        }

        uint256 index = 1;
        uint256 major;
        bool hasMajor;

        while (index < versionBytes.length && versionBytes[index] >= 0x30 && versionBytes[index] <= 0x39) {
            hasMajor = true;
            major = major * 10 + (uint8(versionBytes[index]) - 48);
            index++;
        }

        if (!hasMajor) {
            return false;
        }
        if (major > 2) {
            return true;
        }
        if (major < 2) {
            return false;
        }
        if (index >= versionBytes.length || versionBytes[index] != 0x2e) {
            return false;
        }

        index++;
        uint256 minor;
        bool hasMinor;

        while (index < versionBytes.length && versionBytes[index] >= 0x30 && versionBytes[index] <= 0x39) {
            hasMinor = true;
            minor = minor * 10 + (uint8(versionBytes[index]) - 48);
            index++;
        }

        if (!hasMinor || index != versionBytes.length) {
            return false;
        }

        return minor >= 2;
    }

    function _isSpecVersionV23OrHigher(string memory specVersion) internal pure returns (bool) {
        bytes memory versionBytes = bytes(specVersion);
        if (versionBytes.length < 2 || versionBytes[0] != 0x76) {
            return false;
        }

        uint256 index = 1;
        uint256 major;
        bool hasMajor;

        while (index < versionBytes.length && versionBytes[index] >= 0x30 && versionBytes[index] <= 0x39) {
            hasMajor = true;
            major = major * 10 + (uint8(versionBytes[index]) - 48);
            index++;
        }

        if (!hasMajor) {
            return false;
        }
        if (major > 2) {
            return true;
        }
        if (major < 2) {
            return false;
        }
        if (index >= versionBytes.length || versionBytes[index] != 0x2e) {
            return false;
        }

        index++;
        uint256 minor;
        bool hasMinor;

        while (index < versionBytes.length && versionBytes[index] >= 0x30 && versionBytes[index] <= 0x39) {
            hasMinor = true;
            minor = minor * 10 + (uint8(versionBytes[index]) - 48);
            index++;
        }

        if (!hasMinor || index != versionBytes.length) {
            return false;
        }

        return minor >= 3;
    }

    function _getFactorySpecVersion(address factory) internal view returns (string memory specVersion) {
        (bool specOk, bytes memory specRet) =
            factory.staticcall(abi.encodeCall(VaultFactoryBaseV2.factorySpecVersion, ()));
        if (!specOk || specRet.length == 0) {
            return "";
        }

        specVersion = abi.decode(specRet, (string));
    }

    function _resolveComputedDividendToken(
        address factory,
        address requestedDividendToken,
        address predictedToken,
        uint8 launchVersion,
        bytes memory launchParams
    ) internal view returns (address resolvedDividendToken) {
        if (requestedDividendToken != MAGIC_DIVIDEND_COMPUTED) {
            return requestedDividendToken;
        }

        if (!_isSpecVersionV23OrHigher(_getFactorySpecVersion(factory))) {
            revert FactoryDoesNotSupportComputedDividend();
        }

        (bool ok, bytes memory ret) = factory.staticcall(
            abi.encodeCall(IVaultFactoryDividendV23.resolveDividendToken, (predictedToken, launchVersion, launchParams))
        );
        if (!ok) {
            if (ret.length > 0) {
                assembly ("memory-safe") {
                    revert(add(ret, 32), mload(ret))
                }
            }
            revert FactoryDoesNotSupportComputedDividend();
        }

        if (ret.length != 32) {
            revert FactoryDoesNotSupportComputedDividend();
        }

        resolvedDividendToken = abi.decode(ret, (address));
    }

    function _buildValidationProbeParams(address factory)
        internal
        pure
        returns (NewTokenV6WithVaultParams memory params)
    {
        params.tokenVersion = IPortalTypes.TokenVersion.TOKEN_TAXED_V3;
        params.vaultFactory = factory;
        return params;
    }
}

