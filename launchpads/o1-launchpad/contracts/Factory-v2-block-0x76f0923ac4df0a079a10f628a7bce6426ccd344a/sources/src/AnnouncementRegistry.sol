// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title AnnouncementRegistry
/// @notice Optional, zero-live-roles creator announcements feed. The factory records each token's creator at
///         launch; that creator can post announcements here without the token holding any B20 role, so a
///         fully-renounced (admin-less) token can still have a verifiable on-chain feed. It is used instead of
///         B20-native announce, which would require granting the creator OPERATOR_ROLE.
contract AnnouncementRegistry {
    address public immutable factory;

    mapping(address => address) public creatorOf; // token => creator
    mapping(address => mapping(bytes32 => bool)) public usedId; // token => announcement id => used

    error NotFactory();
    error NotCreator();
    error AlreadyRegistered();
    error IdAlreadyUsed();
    error ZeroAddress();

    event CreatorRegistered(address indexed token, address indexed creator);
    event Announcement(
        address indexed token, address indexed creator, bytes32 indexed id, string description, string uri
    );

    constructor(address _factory) {
        if (_factory == address(0)) revert ZeroAddress();
        factory = _factory;
    }

    function registerCreator(address token, address creator) external {
        if (msg.sender != factory) revert NotFactory();
        if (creatorOf[token] != address(0)) revert AlreadyRegistered();
        creatorOf[token] = creator;
        emit CreatorRegistered(token, creator);
    }

    function post(address token, bytes32 id, string calldata description, string calldata uri) external {
        if (msg.sender != creatorOf[token]) revert NotCreator();
        if (usedId[token][id]) revert IdAlreadyUsed();
        usedId[token][id] = true;
        emit Announcement(token, msg.sender, id, description, uri);
    }
}
