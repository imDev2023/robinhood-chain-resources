//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {INonfungiblePositionManager} from "./interfaces/INonfungiblePositionManager.sol";

/**
 * @title LPVault
 * @dev Custodian for every Uniswap V3 LP position NFT the protocol mints: the ETH pool's TOKEN
 *      ask and WETH bid, the SELECT/TOKEN freeze plug, and the SELECT reserve.
 *
 *      The guarantee here is what this contract CANNOT do: collect() is the only position-manager
 *      call it makes, so the positions can never be moved or their liquidity reduced.
 *
 *      Do not add an ERC-1271 isValidSignature to this contract. The position manager's permit()
 *      grants an approval to any contract owner that returns the ERC-1271 magic value, which would
 *      hand a caller control of every position held here.
 */
contract LPVault {
    INonfungiblePositionManager public immutable POSITION_MANAGER;

    /// @dev The factory PROXY. Set from msg.sender, so only the contract that deployed this can drive it
    address public immutable FACTORY;

    error OnlyFactory();
    error ZeroAddress();

    constructor(address positionManager_) {
        if (positionManager_ == address(0)) revert ZeroAddress();
        POSITION_MANAGER = INonfungiblePositionManager(positionManager_);
        FACTORY = msg.sender;
    }

    /**
     * @dev Collect accrued trading fees from one position and pay them to the factory
     * @param tokenId The position to collect from.
     */
    function collect(uint256 tokenId) external returns (uint256 amount0, uint256 amount1) {
        if (msg.sender != FACTORY) revert OnlyFactory();

        return POSITION_MANAGER.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: FACTORY,
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );
    }

    /**
     * @dev Accept ERC721 transfers. Uniswap's position manager uses _mint rather than _safeMint,
     *      so this never fires on the mints that put positions here; it exists so a position can
     *      also be moved in with safeTransferFrom without being rejected.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return 0x150b7a02;
    }
}
