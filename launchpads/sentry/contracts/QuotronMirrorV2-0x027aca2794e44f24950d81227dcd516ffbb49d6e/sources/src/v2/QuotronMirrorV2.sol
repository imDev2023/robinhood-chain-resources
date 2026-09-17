// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IQuotron404V2Base {
    function owner() external view returns (address);
    function isLaunched() external view returns (bool);
    function ownerOfId(uint256 id) external view returns (address);
    function nftBalanceOf(address account) external view returns (uint256);
    function tokenURI(uint256 id) external view returns (string memory);
    function royaltyInfo(uint256 id, uint256 salePrice) external view returns (address, uint256);
    function mirrorTransfer(address from, address to, uint256 id) external;
    function blacklisted(address account) external view returns (bool);
}

interface ICreatorTokenV2 {
    event TransferValidatorUpdated(address oldValidator, address newValidator);

    function getTransferValidator() external view returns (address validator);
    function getTransferValidationFunction() external view returns (bytes4 functionSignature, bool isViewFunction);
    function setTransferValidator(address validator) external;
}

interface ICreatorTransferValidatorV2 {
    function validateTransfer(address caller, address from, address to, uint256 tokenId) external view;
}

/// @title QuotronMirrorV2
/// @notice ERC-721/2981 creator-token face for Quotron404V2.
/// @dev Every base-driven ownership transition clears token approval. This is
/// the V1 incident's missing invariant: an approval can never survive a burn,
/// rematerialization, hardwire, or ownership change.
contract QuotronMirrorV2 is ICreatorTokenV2 {
    string public constant name = "QUOTRONS";
    string public constant symbol = "QUOTRON";

    IQuotron404V2Base public immutable base;
    address private _transferValidator;

    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Approval(address indexed owner, address indexed approved, uint256 indexed id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    error NotBase();
    error NotAuthorized();
    error UnsafeReceiver();
    error InvalidOperator();
    error ZeroAddress();
    error BlacklistedAccount();
    error NotOwner();
    error InvalidTransferValidator();
    error TransferValidatorFrozen();

    constructor(address base_) {
        if (base_ == address(0)) revert ZeroAddress();
        base = IQuotron404V2Base(base_);
    }

    function ownerOf(uint256 id) public view returns (address owner_) {
        owner_ = base.ownerOfId(id);
        require(owner_ != address(0), "unminted");
    }

    function balanceOf(address account) external view returns (uint256) {
        if (account == address(0)) revert ZeroAddress();
        return base.nftBalanceOf(account);
    }

    function tokenURI(uint256 id) external view returns (string memory) {
        return base.tokenURI(id);
    }

    function royaltyInfo(uint256 id, uint256 salePrice) external view returns (address, uint256) {
        return base.royaltyInfo(id, salePrice);
    }

    function owner() external view returns (address) {
        return base.owner();
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == 0x01ffc9a7 // ERC-165
            || interfaceId == 0x80ac58cd // ERC-721
            || interfaceId == 0x5b5e139f // ERC-721 Metadata
            || interfaceId == 0x2a55205a // ERC-2981
            || interfaceId == type(ICreatorTokenV2).interfaceId;
    }

    function getTransferValidator() external view returns (address validator) {
        return _transferValidator;
    }

    function getTransferValidationFunction() external pure returns (bytes4 functionSignature, bool isViewFunction) {
        return (ICreatorTransferValidatorV2.validateTransfer.selector, true);
    }

    function setTransferValidator(address validator) external {
        if (msg.sender != base.owner()) revert NotOwner();
        if (base.isLaunched()) revert TransferValidatorFrozen();
        if (validator != address(0) && validator.code.length == 0) revert InvalidTransferValidator();
        address oldValidator = _transferValidator;
        _transferValidator = validator;
        emit TransferValidatorUpdated(oldValidator, validator);
    }

    function approve(address spender, uint256 id) external {
        address owner_ = ownerOf(id);
        _requireNotBlacklisted(owner_);
        _requireNotBlacklisted(msg.sender);
        _requireNotBlacklisted(spender);
        if (spender == owner_) revert InvalidOperator();
        if (msg.sender != owner_ && !isApprovedForAll[owner_][msg.sender]) {
            revert NotAuthorized();
        }
        getApproved[id] = spender;
        emit Approval(owner_, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) external {
        _requireNotBlacklisted(msg.sender);
        _requireNotBlacklisted(operator);
        if (operator == msg.sender) revert InvalidOperator();
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(address from, address to, uint256 id) public {
        if (to == address(0)) revert ZeroAddress();
        _requireNotBlacklisted(from);
        _requireNotBlacklisted(to);
        _requireNotBlacklisted(msg.sender);
        address owner_ = ownerOf(id);
        require(owner_ == from, "wrong from");
        if (msg.sender != owner_ && msg.sender != getApproved[id] && !isApprovedForAll[owner_][msg.sender]) {
            revert NotAuthorized();
        }

        address validator = _transferValidator;
        if (validator != address(0)) {
            ICreatorTransferValidatorV2(validator).validateTransfer(msg.sender, from, to, id);
        }
        _clearApproval(owner_, id);
        base.mirrorTransfer(from, to, id);
        emit Transfer(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint256 id) external {
        safeTransferFrom(from, to, id, "");
    }

    function safeTransferFrom(address from, address to, uint256 id, bytes memory data) public {
        transferFrom(from, to, id);
        if (to.code.length != 0) {
            (bool ok, bytes memory result) = to.call(abi.encodeWithSelector(0x150b7a02, msg.sender, from, id, data));
            if (!ok || result.length < 32 || bytes4(abi.decode(result, (bytes32))) != bytes4(0x150b7a02)) {
                revert UnsafeReceiver();
            }
        }
    }

    /// @dev Called for every base-driven mint/burn/rematerialization.
    function emitTransfer(address from, address to, uint256 id) external {
        if (msg.sender != address(base)) revert NotBase();
        _clearApproval(from, id);
        emit Transfer(from, to, id);
    }

    /// @dev Hardwiring changes the token's approval domain even though the
    /// owner and ERC-721 id remain the same.
    function clearApproval(address owner_, uint256 id) external {
        if (msg.sender != address(base)) revert NotBase();
        _clearApproval(owner_, id);
    }

    function _clearApproval(address owner_, uint256 id) internal {
        if (getApproved[id] != address(0)) {
            delete getApproved[id];
            if (owner_ != address(0)) emit Approval(owner_, address(0), id);
        }
    }

    function _requireNotBlacklisted(address account) internal view {
        if (base.blacklisted(account)) revert BlacklistedAccount();
    }
}
