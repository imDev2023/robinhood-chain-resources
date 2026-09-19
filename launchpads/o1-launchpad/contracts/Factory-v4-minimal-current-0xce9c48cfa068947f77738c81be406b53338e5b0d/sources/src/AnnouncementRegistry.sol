// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title AnnouncementRegistry
interface ICreatorAuthority {
    function currentCreatorOf(address token) external view returns (address currentCreator);
}

/// @notice Optional, zero-live-roles creator announcements feed. The factory registers canonical launch tokens,
///         while creator authorization is resolved dynamically so rights transfers require no registry update.
contract AnnouncementRegistry {
    address public immutable factory;

    mapping(address token => bool registered) public isTokenRegistered;
    mapping(address token => mapping(bytes32 announcementId => bool used)) public isAnnouncementIdUsed;

    error NotFactory();
    error NotCreator();
    error AlreadyRegistered();
    error IdAlreadyUsed();
    error ZeroAddress();

    event TokenRegistered(address indexed token);
    event AnnouncementPosted(
        address indexed token,
        address indexed creator,
        bytes32 indexed announcementId,
        string description,
        string announcementURI
    );

    constructor(address factoryAddress) {
        if (factoryAddress == address(0) || factoryAddress.code.length == 0) revert ZeroAddress();
        factory = factoryAddress;
    }

    function registerToken(address token) external {
        if (msg.sender != factory) revert NotFactory();
        if (token == address(0)) revert ZeroAddress();
        if (isTokenRegistered[token]) revert AlreadyRegistered();
        isTokenRegistered[token] = true;
        emit TokenRegistered(token);
    }

    function postAnnouncement(
        address token,
        bytes32 announcementId,
        string calldata description,
        string calldata announcementURI
    ) external {
        if (!isTokenRegistered[token] || msg.sender != ICreatorAuthority(factory).currentCreatorOf(token)) {
            revert NotCreator();
        }
        if (isAnnouncementIdUsed[token][announcementId]) revert IdAlreadyUsed();
        isAnnouncementIdUsed[token][announcementId] = true;
        emit AnnouncementPosted(token, msg.sender, announcementId, description, announcementURI);
    }
}
