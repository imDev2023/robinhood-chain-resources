// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "openzeppelin-contracts/contracts/utils/Pausable.sol";
import {AccessControl} from "openzeppelin-contracts/contracts/access/AccessControl.sol";
import {
    ZeroAddress,
    Unauthorized,
    InvalidConfig,
    BucketCapExceeded,
    ReturnExceedsReleased,
    InvariantViolation
} from "../libs/Errors.sol";
import {Events} from "../libs/Events.sol";

contract TokenEscrowReserve is ReentrancyGuard, Pausable, AccessControl {
    using SafeERC20 for IERC20;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    enum BucketType {
        AMM,
        LOAN,
        REWARD
    }

    struct Bucket {
        uint256 cap;
        uint256 used;
    }

    IERC20 public immutable token;
    uint256 public immutable totalSupply;

    mapping(address => bool) public authorizedVaults;
    mapping(BucketType => Bucket) private buckets;
    bool public vaultsInitialized;

    uint256 public totalReleased;

    modifier onlyAuthorizedVault() {
        _checkAuthorizedVault();
        _;
    }

    function _checkAuthorizedVault() internal view {
        if (!authorizedVaults[msg.sender]) revert Unauthorized();
    }

    constructor(
        address token_,
        uint256 ammCap_,
        uint256 loanCap_,
        uint256 rewardCap_,
        address admin_
    ) {
        if (token_ == address(0) || admin_ == address(0)) revert ZeroAddress();

        uint256 sumCaps = ammCap_ + loanCap_ + rewardCap_;
        uint256 tokenSupply = IERC20(token_).totalSupply();
        if (sumCaps > tokenSupply) revert InvalidConfig();

        token = IERC20(token_);
        totalSupply = tokenSupply;

        buckets[BucketType.AMM] = Bucket({cap: ammCap_, used: 0});
        buckets[BucketType.LOAN] = Bucket({cap: loanCap_, used: 0});
        buckets[BucketType.REWARD] = Bucket({cap: rewardCap_, used: 0});

        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        _grantRole(PAUSER_ROLE, admin_);
    }

    function initializeVaults(address ammVault_, address loanVault_, address rewardVault_)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        if (vaultsInitialized) revert InvalidConfig();
        if (ammVault_ == address(0) || loanVault_ == address(0) || rewardVault_ == address(0)) revert ZeroAddress();

        authorizedVaults[ammVault_] = true;
        authorizedVaults[loanVault_] = true;
        authorizedVaults[rewardVault_] = true;
        vaultsInitialized = true;
    }

    /// @notice Initializes all authorized vaults in one immutable deployment-time step.
    /// @dev Once initialized, the set is fixed for the market lifetime.
    function initializeVaultsBatch(address[] calldata vaults_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (vaultsInitialized) revert InvalidConfig();
        if (vaults_.length == 0) revert InvalidConfig();
        for (uint256 i; i < vaults_.length; ++i) {
            address vault = vaults_[i];
            if (vault == address(0)) revert ZeroAddress();
            authorizedVaults[vault] = true;
        }
        vaultsInitialized = true;
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function release(address to, uint256 amount, BucketType bucketType)
        external
        onlyAuthorizedVault
        nonReentrant
        whenNotPaused
    {
        if (to == address(0)) revert ZeroAddress();

        Bucket storage bucket = buckets[bucketType];
        uint256 newUsed = bucket.used + amount;
        if (newUsed > bucket.cap) revert BucketCapExceeded();

        bucket.used = newUsed;
        totalReleased += amount;

        token.safeTransfer(to, amount);
        emit Events.EscrowReleased(to, amount, uint8(bucketType));

        if (!checkInvariant()) revert InvariantViolation();
    }

    function returnTokens(uint256 amount, BucketType bucketType)
        external
        onlyAuthorizedVault
        nonReentrant
        whenNotPaused
    {
        Bucket storage bucket = buckets[bucketType];
        if (amount > bucket.used || amount > totalReleased) revert ReturnExceedsReleased();

        bucket.used -= amount;
        totalReleased -= amount;
        token.safeTransferFrom(msg.sender, address(this), amount);

        emit Events.EscrowReturned(msg.sender, amount, uint8(bucketType));

        if (!checkInvariant()) revert InvariantViolation();
    }

    /// @notice Move bucket accounting from one bucket to another without
    ///         moving tokens. Used during liquidation to transfer the LOAN
    ///         bucket's principal accounting to the AMM bucket so the
    ///         ingested NFT can be bought without reverting.
    function rebalanceBuckets(uint256 amount, BucketType fromBucket, BucketType toBucket)
        external
        onlyAuthorizedVault
        nonReentrant
        whenNotPaused
    {
        Bucket storage from = buckets[fromBucket];
        Bucket storage to = buckets[toBucket];

        if (amount > from.used) revert ReturnExceedsReleased();
        uint256 newToUsed = to.used + amount;
        if (newToUsed > to.cap) revert BucketCapExceeded();

        from.used -= amount;
        to.used = newToUsed;

        emit Events.BucketRebalanced(uint8(fromBucket), uint8(toBucket), amount);
    }

    function bucketBalance(BucketType bucketType) external view returns (uint256 used, uint256 cap, uint256 available) {
        Bucket storage bucket = buckets[bucketType];
        used = bucket.used;
        cap = bucket.cap;
        available = cap - used;
    }

    function checkInvariant() public view returns (bool) {
        uint256 totalObligations = (buckets[BucketType.AMM].cap - buckets[BucketType.AMM].used)
            + (buckets[BucketType.LOAN].cap - buckets[BucketType.LOAN].used)
            + (buckets[BucketType.REWARD].cap - buckets[BucketType.REWARD].used);
        return token.balanceOf(address(this)) >= totalObligations;
    }
}
