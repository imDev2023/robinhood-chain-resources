// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20RoyaltySplitter {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

/// @title QuotronRoyaltySplitter
/// @notice Withdrawal-less 80/20 splitter for the collection's aggregate 5%
/// ERC-2981 royalty: 4% of a sale to the keeper and 1% to the creator.
contract QuotronRoyaltySplitter {
    uint256 private constant BPS = 10_000;
    uint256 private constant KEEPER_SHARE_BPS = 8_000;

    address public immutable keeper;
    address public immutable creator;
    uint256 private _lock = 1;

    event NativeRoyaltyReleased(uint256 total, uint256 keeperAmount, uint256 creatorAmount);
    event TokenRoyaltyReleased(address indexed token, uint256 total, uint256 keeperAmount, uint256 creatorAmount);

    error ZeroAddress();
    error Reentrancy();
    error NativeTransferFailed();
    error TokenTransferFailed();

    modifier nonReentrant() {
        if (_lock != 1) revert Reentrancy();
        _lock = 2;
        _;
        _lock = 1;
    }

    constructor(address keeper_, address creator_) {
        if (keeper_ == address(0) || creator_ == address(0)) revert ZeroAddress();
        keeper = keeper_;
        creator = creator_;
    }

    receive() external payable nonReentrant {
        _releaseNative(msg.value);
    }

    /// @notice Releases ETH forced into this contract without invoking receive.
    function releaseNative() external nonReentrant {
        _releaseNative(address(this).balance);
    }

    /// @notice Permissionlessly releases the entire balance of an ERC-20
    /// royalty payment in the immutable 80/20 proportion.
    function releaseToken(address token) external nonReentrant {
        if (token == address(0)) revert ZeroAddress();
        uint256 total = IERC20RoyaltySplitter(token).balanceOf(address(this));
        uint256 keeperAmount = (total * KEEPER_SHARE_BPS) / BPS;
        uint256 creatorAmount = total - keeperAmount;
        _safeTransfer(token, keeper, keeperAmount);
        _safeTransfer(token, creator, creatorAmount);
        emit TokenRoyaltyReleased(token, total, keeperAmount, creatorAmount);
    }

    function _releaseNative(uint256 total) internal {
        uint256 keeperAmount = (total * KEEPER_SHARE_BPS) / BPS;
        uint256 creatorAmount = total - keeperAmount;
        _sendNative(keeper, keeperAmount);
        _sendNative(creator, creatorAmount);
        emit NativeRoyaltyReleased(total, keeperAmount, creatorAmount);
    }

    function _sendNative(address to, uint256 amount) internal {
        if (amount == 0) return;
        (bool ok,) = to.call{value: amount}("");
        if (!ok) revert NativeTransferFailed();
    }

    function _safeTransfer(address token, address to, uint256 amount) internal {
        if (amount == 0) return;
        (bool ok, bytes memory result) = token.call(abi.encodeCall(IERC20RoyaltySplitter.transfer, (to, amount)));
        if (!ok || (result.length != 0 && !abi.decode(result, (bool)))) {
            revert TokenTransferFailed();
        }
    }
}
