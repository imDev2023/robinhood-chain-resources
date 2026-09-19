//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ITokenSelectToken {
    struct ConstructorParams {
        string name;
        string symbol;
        address creator;
        address factory;
        address streamManager;
        address referrer;

        uint256 minETHLiquidity;
        uint256 targetETHRaise;
        uint256 maxContributionPerWallet;
        uint256 teamAllocation;      
        uint256 marketingAllocation;     
        uint256 communityRewardsAllocation;           
        uint256 saleStartTime;
        uint256 saleEndTime;
        uint256 migrationFee;
        uint256 migrationFeePercentage;

        uint256 serviceChargeRate;
        uint256 creatorFeeNoReferrer;
        uint256 creatorFeeWithReferrer;
        uint256 referrerFee;

        address selectToken;       // address(0) = skip SELECT pool
        uint256 ethPoolRatioBps;   // 9000 = 90% to ETH pool, 10000 = 100% (backward compat)

        uint40 teamStartDelay;
        uint40 teamDuration;
        uint40 marketingStartDelay;
        uint40 marketingDuration;
        uint40 communityStartDelay;
        uint40 communityDuration;

        // Recipients of the team / marketing / community vesting streams. address(0) on any of
        // them = default that stream to the creator; PresaleCore resolves this at construction so
        // the stored values are never zero.
        address teamRecipient;
        address marketingRecipient;
        address communityRecipient;

        // Custodian for every LP position this token mints. Injected by the factory and stored
        // immutably, so the fee-collection path can ask the token which vault holds its NFTs
        // rather than relying on a factory-wide value that a later implementation could change.
        address lpVault;
    }

    error OnlyFactory();
    error OnlyStreamManager();
    error OnlyCreator();
    error InvalidAllocation();
    error InsufficientRaiseTarget();
    error InvalidFairTick();
    error SaleNotStarted();
    error NotReadyForMigration();
    error SaleEnded();
    error SaleCancelled();
    error TargetAlreadyReached();
    error NotMigrated();
    error MigrationAlreadyCompleted();
    error AllocationsAlreadyTransferred();
    error TransfersDisabled();
    error MaxContributionExceeded();
    error InvalidContribution();
    error NoContribution();
    error RefundFailed();
    error NoRewardsAvailable();
    error AlreadyClaimed();
    error NotEligibleForRewards();
    error InsufficientRewards(string rewardType);
    error ETHAmountMismatch();
    error TokenAmountMismatch();
    error DirectETHNotAllowed();
    error SelectPoolAlreadySeeded();
    error RefundsAlreadyEnabled();
    error MigrationAborted();
    error PoolAlreadyExists();
    error InvalidLpVault();
    error EthPoolNotFrozen();
    error AlreadySeeded();
    error UnauthorizedCallback();

    event Contribution(address indexed contributor, uint256 amount, uint256 totalRaised);
    event Refund(address indexed contributor, uint256 amount);
    event TargetReached(uint256 totalRaised);
    event Migration(uint256 actualETHUsed, uint256 actualTokensUsed, uint256 ethPositionTokenId, uint256 migrationFeeTransferred);
    event TokensBurned(uint256 amount);  
    event PresaleTokensClaimed(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 ethAmount, uint256 tokenAmount);
    event FeesCollected(uint256 ethAmount, uint256 tokenAmount);
    event CancelSale();
    event SelectPoolLiquidityAdded(uint256 nftId, int24 fairTick, uint256 amount);
    event EthPoolSeeded(uint256 ethAskPositionId, uint256 ethBidPositionId, int24 initializedTick);
    event SelectPoolSeedFailed(int24 fairTick);
    event SelectPoolSeededLate(uint256 nftId, int24 fairTick);
    event RefundsEnabled();

    function seedInitialLiquidity() external;
    function creator() external view returns (address);
    function lpVault() external view returns (address);
    function teamRecipient() external view returns (address);
    function marketingRecipient() external view returns (address);
    function communityRecipient() external view returns (address);
    function getStreamRecipients() external view returns (address, address, address);
    function teamAllocation() external view returns (uint256);
    function marketingAllocation() external view returns (uint256);
    function communityRewardsAllocation() external view returns (uint256);
    function transferAllocations() external;
    function areAllocationsReleased() external view returns (bool);
    function claimRewardsFor(address user) external;
    function isReadyForMigration() external view returns (bool);

    function getVestingSchedules() external view returns (
        uint40 teamStartDelay,
        uint40 teamDuration,
        uint40 marketingStartDelay,
        uint40 marketingDuration,
        uint40 communityStartDelay,
        uint40 communityDuration
    );

    function migrate(address _treasury, int24 fairTick) external returns (
        uint256 actualETHUsed,
        uint256 actualTokensUsed,
        uint256 migrationFeeAmount,
        uint256 ethBidPositionId,
        uint256 ethAskPositionId,
        uint256 selectPositionId
    );

    function selectPoolReserve() external view returns (uint256);
    function selectTokenPool() external view returns (address);
    function selectPoolSeeded() external view returns (bool);
    function ethAskPositionId() external view returns (uint256);
    function retrySelectPoolSeeding(int24 fairTick) external returns (uint256 nftId);
    function refundsEnabled() external view returns (bool);
    function enableRefunds() external;
}