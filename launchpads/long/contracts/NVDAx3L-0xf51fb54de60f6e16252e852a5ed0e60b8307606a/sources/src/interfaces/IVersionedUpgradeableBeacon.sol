// SPDX-License-Identifier: EUPL V1.2
//
// Vendored from EBSI's core-services monorepo, required by VersionedBeaconProxy.sol.
// Source: https://code.europa.eu/ebsi/public/core-services/-/blob/main/contracts/beacon-proxy/contracts/interfaces/IVersionedUpgradeableBeacon.sol

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";

/**
 * @title IVersionedUpgradeableBeacon
 * @dev Beacon that stores multiple implementations by version and tracks, per proxy, the pinned
 *      version and the owner allowed to opt into a new version. Proxies hold no upgrade logic of
 *      their own: they resolve their implementation through the parameterless `implementation()`
 *      (keyed by the calling proxy) and all version/ownership state lives here.
 */
interface IVersionedUpgradeableBeacon is IBeacon {
    function latestVersion() external view returns (uint64);

    function implementation(uint64 version) external view returns (address);

    function isVersionAvailable(uint64 version) external view returns (bool);

    /// @dev Optional: returns all registered version numbers (may be expensive).
    function getVersions() external view returns (uint64[] memory);

    /// @dev Called by a proxy in its constructor (msg.sender == the proxy) to pin the latest
    ///      version and record its initial owner. One-time per proxy.
    function registerProxy(address initialOwner) external;

    /// @dev Opt-in upgrade: the proxy's owner switches the proxy to an available version.
    function upgradeProxyToVersion(address proxy, uint64 version) external;

    /// @dev Transfer the per-proxy owner (the account allowed to upgrade that proxy).
    function transferProxyOwnership(address proxy, address newOwner) external;

    /// @dev Effective version a proxy resolves to (latest if it was never pinned).
    function proxyVersionOf(address proxy) external view returns (uint64);

    function proxyOwnerOf(address proxy) external view returns (address);

    event VersionAdded(uint64 indexed version, address indexed implementation);
    event VersionDeprecated(uint64 indexed version);
    event ProxyRegistered(
        address indexed proxy,
        address indexed owner,
        uint64 version
    );
    event ProxyUpgraded(
        address indexed proxy,
        uint64 oldVersion,
        uint64 newVersion,
        address implementation
    );
    event ProxyOwnerChanged(
        address indexed proxy,
        address indexed oldOwner,
        address indexed newOwner
    );
}
