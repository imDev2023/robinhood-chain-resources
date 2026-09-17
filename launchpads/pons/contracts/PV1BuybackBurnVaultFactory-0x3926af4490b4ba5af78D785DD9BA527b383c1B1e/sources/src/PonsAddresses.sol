// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title PonsAddresses
/// @notice Shared Robinhood Chain (chainId 4663) addresses used by every PonsVault template.
library PonsAddresses {
    uint256 internal constant CHAIN_ID = 4663;

    address internal constant WETH = 0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73;
    address internal constant SWAP_ROUTER_02 = 0xCaf681a66D020601342297493863E78C959E5cb2;
    address internal constant V3_FACTORY = 0x1f7d7550B1b028f7571E69A784071F0205FD2EfA;

    address internal constant PONS_ACTIVE_LOCKER = 0x736D76699C26D0d966744cAe304C000d471f7F35;
    address internal constant PONS_LEGACY_LOCKER = 0x31ca5E101941A93A7DD6d0497928700625CF54B5;

    /// @dev pons launches pair against WETH in the 1% fee tier.
    uint24 internal constant POOL_FEE = 10_000;

    address internal constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    uint16 internal constant BPS_DENOMINATOR = 10_000;
}
