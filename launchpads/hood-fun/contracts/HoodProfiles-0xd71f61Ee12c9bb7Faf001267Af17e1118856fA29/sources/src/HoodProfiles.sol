// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title HoodProfiles
/// @notice On-chain usernames and avatars for hood.fun. Names are unique,
///         lowercase [a-z0-9_], up to 24 bytes; avatars are compact data URIs
///         stored on-chain (same pipeline as token images). No admin, no
///         custody — every wallet owns its own profile forever.
contract HoodProfiles {
    struct Profile {
        string name;
        string imageURI;
    }

    uint256 public constant MAX_NAME_BYTES = 24;
    uint256 public constant MAX_IMAGE_BYTES = 40_000;

    mapping(address => Profile) private profiles;
    mapping(bytes32 => address) public nameOwner;

    event ProfileUpdated(address indexed user, string name, string imageURI);

    error BadName();
    error NameTaken();
    error ImageTooLarge();

    /// @notice Set or update your profile. Pass empty strings to clear a field.
    function setProfile(string calldata name, string calldata imageURI) external {
        bytes calldata b = bytes(name);
        if (b.length > MAX_NAME_BYTES) revert BadName();
        if (bytes(imageURI).length > MAX_IMAGE_BYTES) revert ImageTooLarge();
        for (uint256 i; i < b.length; i++) {
            bytes1 c = b[i];
            bool ok = (c >= 0x30 && c <= 0x39) || (c >= 0x61 && c <= 0x7a) || c == 0x5f;
            if (!ok) revert BadName();
        }

        bytes memory old = bytes(profiles[msg.sender].name);
        if (b.length > 0) {
            bytes32 h = keccak256(b);
            address holder = nameOwner[h];
            if (holder != address(0) && holder != msg.sender) revert NameTaken();
            if (old.length > 0 && keccak256(old) != h) delete nameOwner[keccak256(old)];
            nameOwner[h] = msg.sender;
        } else if (old.length > 0) {
            delete nameOwner[keccak256(old)];
        }

        profiles[msg.sender] = Profile(name, imageURI);
        emit ProfileUpdated(msg.sender, name, imageURI);
    }

    function getProfile(address user) external view returns (string memory name, string memory imageURI) {
        Profile storage p = profiles[user];
        return (p.name, p.imageURI);
    }
}
