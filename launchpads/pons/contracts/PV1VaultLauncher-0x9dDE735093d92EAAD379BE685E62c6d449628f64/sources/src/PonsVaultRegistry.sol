// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Ownable2Step} from "@openzeppelin/access/Ownable2Step.sol";

import {IPonsVaultFactory} from "./interfaces/IPonsVaultFactory.sol";

/// @title PonsVaultRegistry
/// @notice The set of vault templates a launch may choose from.
///
/// @dev Exists so shipping a template is a transaction rather than a migration. Without it the
///      launcher would need a typed entry point per template, which means a new launcher address
///      every time — and since the launcher is the on-chain deployer of every token it creates,
///      moving it strands the tokens behind it. Keeping the template set out here lets the
///      launcher stay immutable and still gain templates.
///
///      The trust this adds is bounded and worth stating plainly: the owner chooses which factory a
///      template id resolves to, so a malicious registration would send *new* launches to a vault
///      the owner controls. It cannot touch a vault that already exists, because a launch resolves
///      the factory once and the resulting vault holds no reference back here. {lockRegistry}
///      gives up the ability to change the set at all, which is the endgame once the templates
///      have settled.
contract PonsVaultRegistry is Ownable2Step {
    error RegistryLocked();
    error UnknownTemplate(bytes32 templateId);
    error TemplateNotAvailable(bytes32 templateId);
    error ZeroAddress();

    event TemplateRegistered(bytes32 indexed templateId, address indexed factory);
    event TemplateRetired(bytes32 indexed templateId, address indexed factory);
    event RegistryLockedForever();

    struct Template {
        address factory;
        /// @dev Retired templates reject new launches but stay readable, so the vaults already
        ///      deployed under them remain resolvable through {findVault}.
        bool retired;
    }

    mapping(bytes32 templateId => Template template) public templates;

    /// @notice Every template id ever registered, in registration order.
    bytes32[] public templateIds;

    /// @notice Whether the template set has been frozen permanently.
    bool public locked;

    constructor() Ownable2Step() {}

    /// @notice Point a template id at the factory that builds it.
    /// @dev Re-registering an id replaces its factory, which is how a template is upgraded
    ///      wholesale rather than through the beacon. Existing vaults are unaffected.
    function register(bytes32 templateId, address factory) external onlyOwner {
        if (locked) revert RegistryLocked();
        if (factory == address(0)) revert ZeroAddress();

        if (templates[templateId].factory == address(0)) templateIds.push(templateId);
        templates[templateId] = Template({factory: factory, retired: false});

        emit TemplateRegistered(templateId, factory);
    }

    /// @notice Stop new launches from choosing `templateId`, without touching its existing vaults.
    function retire(bytes32 templateId) external onlyOwner {
        if (locked) revert RegistryLocked();

        address factory = templates[templateId].factory;
        if (factory == address(0)) revert UnknownTemplate(templateId);

        templates[templateId].retired = true;
        emit TemplateRetired(templateId, factory);
    }

    /// @notice Permanently give up the ability to add, replace, or retire templates. Irreversible.
    function lockRegistry() external onlyOwner {
        locked = true;
        emit RegistryLockedForever();
    }

    /// @notice The factory for `templateId`, reverting unless it is registered and live.
    /// @dev Used on the launch path, so both failures are distinct errors rather than a zero
    ///      address the caller has to interpret.
    function factoryFor(bytes32 templateId) external view returns (IPonsVaultFactory) {
        Template memory template = templates[templateId];
        if (template.factory == address(0)) revert UnknownTemplate(templateId);
        if (template.retired) revert TemplateNotAvailable(templateId);
        return IPonsVaultFactory(template.factory);
    }

    /// @notice Number of template ids ever registered, retired ones included.
    function templateCount() external view returns (uint256) {
        return templateIds.length;
    }

    /// @notice Every registered template id, for UIs and off-chain tooling.
    function allTemplateIds() external view returns (bytes32[] memory) {
        return templateIds;
    }

    /// @notice Search every registered factory for a vault attached to `token`.
    /// @dev A fallback for lookups the launcher cannot answer from its own records — vaults created
    ///      by calling a factory directly, and vaults from an earlier launcher whose factory is
    ///      still registered here. Linear in the number of templates and `view` only, so it is
    ///      meant for off-chain reads rather than the launch path.
    function findVault(address token) external view returns (address vault) {
        uint256 count = templateIds.length;
        for (uint256 i = 0; i < count; i++) {
            address factory = templates[templateIds[i]].factory;
            if (factory == address(0)) continue;

            // Tolerated rather than trusted: a factory registered before this interface settled
            // may not answer, and one bad entry should not break lookups for every other template.
            try IPonsVaultFactory(factory).vaultOf(token) returns (address found) {
                if (found != address(0)) return found;
            } catch {
                continue;
            }
        }
        return address(0);
    }
}
