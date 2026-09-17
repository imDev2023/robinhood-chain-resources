// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IQuotron404Base {
    function ownerOfId(uint256 id) external view returns (address);
    function nftBalanceOf(address a) external view returns (uint256);
    function tokenURI(uint256 id) external view returns (string memory);
    function royaltyInfo(uint256 id, uint256 salePrice)
        external
        view
        returns (address, uint256);
    function mirrorTransfer(address from, address to, uint256 id) external;
}

/// @title QuotronMirror — the ERC-721 face of the QUOTRONS collection
/// @notice Marketplace-standard ERC-721 + ERC-2981 surface. Ownership
/// truth lives in Quotron404 (the ERC-20/404 core); this contract holds
/// approvals, emits the standard events, and proxies transfers so the
/// two token standards never share a selector (DN404-style split).
contract QuotronMirror {
    string public constant name = "QUOTRONS";
    string public constant symbol = "QUOTRON";

    IQuotron404Base public immutable base;

    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Approval(address indexed owner, address indexed approved, uint256 indexed id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    error NotBase();
    error NotAuthorized();
    error UnsafeReceiver();

    constructor(address base_) {
        base = IQuotron404Base(base_);
    }

    // ── views ───────────────────────────────────────────────────────
    function ownerOf(uint256 id) public view returns (address o) {
        o = base.ownerOfId(id);
        require(o != address(0), "unminted");
    }

    function balanceOf(address a) external view returns (uint256) {
        return base.nftBalanceOf(a);
    }

    function tokenURI(uint256 id) external view returns (string memory) {
        return base.tokenURI(id);
    }

    function royaltyInfo(uint256 id, uint256 salePrice)
        external
        view
        returns (address, uint256)
    {
        return base.royaltyInfo(id, salePrice);
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == 0x01ffc9a7 // ERC-165
            || interfaceId == 0x80ac58cd // ERC-721
            || interfaceId == 0x5b5e139f // ERC-721 Metadata
            || interfaceId == 0x2a55205a; // ERC-2981
    }

    // ── approvals ───────────────────────────────────────────────────
    function approve(address spender, uint256 id) external {
        address o = ownerOf(id);
        if (msg.sender != o && !isApprovedForAll[o][msg.sender]) revert NotAuthorized();
        getApproved[id] = spender;
        emit Approval(o, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // ── transfers ───────────────────────────────────────────────────
    function transferFrom(address from, address to, uint256 id) public {
        address o = ownerOf(id);
        require(o == from, "wrong from");
        if (
            msg.sender != o && msg.sender != getApproved[id]
                && !isApprovedForAll[o][msg.sender]
        ) revert NotAuthorized();
        delete getApproved[id];
        base.mirrorTransfer(from, to, id);
        emit Transfer(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint256 id) external {
        safeTransferFrom(from, to, id, "");
    }

    function safeTransferFrom(address from, address to, uint256 id, bytes memory data)
        public
    {
        transferFrom(from, to, id);
        if (to.code.length != 0) {
            (bool ok, bytes memory ret) = to.call(
                abi.encodeWithSelector(0x150b7a02, msg.sender, from, id, data)
            );
            if (!ok || ret.length < 32 || bytes4(ret) != bytes4(0x150b7a02)) {
                revert UnsafeReceiver();
            }
        }
    }

    /// @dev Base-driven event emission for materialize/dissolve syncs.
    function emitTransfer(address from, address to, uint256 id) external {
        if (msg.sender != address(base)) revert NotBase();
        emit Transfer(from, to, id);
    }
}
