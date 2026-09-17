// SPDX-License-Identifier: EUPL V1.2
//
// Vendored verbatim from EBSI's core-services monorepo (@ebsiint-sc/beacon-proxy) so
// `forge verify-contract` can compile the exact contract our TCR actually deploys via
// `new VersionedBeaconProxy(beacon, initData, msg.sender)` — not plain OZ BeaconProxy.
// Source: https://code.europa.eu/ebsi/public/core-services/-/blob/main/contracts/beacon-proxy/contracts/VersionedBeaconProxy.sol

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "./interfaces/IVersionedUpgradeableBeacon.sol";

/**
 * @title VersionedBeaconProxy
 * @dev A standard OpenZeppelin BeaconProxy that registers itself with an {IVersionedUpgradeableBeacon} at
 *      construction, recording `owner_` as the proxy owner (the account allowed to opt into new
 *      versions). The owner is passed explicitly rather than inferred from msg.sender, because the
 *      proxy is typically deployed by a factory. It deliberately declares NO external/public
 *      functions: all version and
 *      ownership state lives on the beacon, so nothing on the proxy can shadow the implementation's
 *      ABI (a non-transparent proxy). The implementation is resolved per-proxy by the beacon via the
 *      inherited `_implementation()` -> `IBeacon(beacon).implementation()` call, where `msg.sender`
 *      is this proxy. Per-proxy upgrades are performed by the proxy's owner on the beacon through
 *      `upgradeProxyToVersion`.
 */
contract VersionedBeaconProxy is BeaconProxy {
    constructor(
        address beacon_,
        bytes memory data_,
        address owner_
    ) BeaconProxy(beacon_, data_) {
        IVersionedUpgradeableBeacon(beacon_).registerProxy(owner_);
    }
}
