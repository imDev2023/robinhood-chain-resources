//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ITokenSelectFactory {
    struct TokenCreationParams {
        string name;
        string symbol;
        uint256 targetETHRaise;
        uint256 maxContributionPerWallet;
        uint256 teamAllocation;    
        uint256 marketingAllocation;    
        uint256 communityRewardsAllocation;  
        uint256 saleStartTime;
        uint256 saleEndTime;
        uint40 teamStartDelay;
        uint40 teamDuration;
        uint40 marketingStartDelay;
        uint40 marketingDuration;
        uint40 communityStartDelay;
        uint40 communityDuration;

        // Recipients of the team / marketing / community vesting streams (ie. a multisig).
        // address(0) on any of them = default that stream to the creator.
        address teamRecipient;
        address marketingRecipient;
        address communityRecipient;
    }

    struct BatchClaimResult {
        uint256 totalAttempted;
        uint256 successfulClaims;
        uint256 lastProcessedIndex;
        bool completed;
    }

    error InvalidMigrationFee();
    error InvalidMigrationFeePercentage();
    error InvalidFeeConfig();
    error InvalidDeploymentFee();
    error InvalidTreasury();
    error InvalidStreamManager();
    error InvalidReferrer();
    error InvalidAdmin();
    error InvalidDeployer();
    error NotTokenSelectToken();
    error IndexOutOfBounds();
    error InvalidRange();
    error IncorrectDeploymentFee();
    error ETHTransferFailed();
    error TokenTransferFailed();
    error TreasuryTransferFailed();
    error OnlyReferrerAdmin();
    error OnlyMigrationAdmin();
    error UnauthorizedPosition();
    error NotMigrated();
    error SelectTokenNotSet();
    error InvalidSelectToken();
    error InvalidEthPoolRatio();
    error NoSelectPoolPosition();
    error LpVaultNotSet();
    error LpVaultAlreadySet();

    event MigrationFeeUpdated(uint256 oldFee, uint256 newFee);
    event MigrationFeePercentageUpdated(uint256 oldPercentage, uint256 newPercentage);
    event DeploymentFeeUpdated(uint256 oldFee, uint256 newFee);
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event StreamManagerUpdated(address indexed oldStreamManager, address indexed newStreamManager);
    event ReferrerAdminUpdated(address indexed oldReferrerAdmin, address indexed newReferrerAdmin);
    event MigrationAdminUpdated(address indexed oldMigrationAdmin, address indexed newMigrationAdmin);
    event TokenDeployerUpdated(address indexed oldTokenDeployer, address indexed newTokenDeployer);
    event MinETHLiquidityUpdated(uint256 oldMinimum, uint256 newMinimum);
    event ReferrerAdded(address indexed referrer);
    event ReferrerRemoved(address indexed referrer);

    event RewardFeesUpdated(
        uint256 oldServiceRate, 
        uint256 oldCreatorWithReferrerRate, 
        uint256 oldCreatorNoReferrerRate, 
        uint256 oldReferrerRate,
        uint256 newServiceRate,
        uint256 newCreatorFeeWithReferrer,
        uint256 newCreatorFeeNoReferrer,
        uint256 newReferrerFee
        );


    event NewTokenSelectToken(
        address indexed tokenAddress,
        address indexed creator,
        string name,
        string symbol,
        uint256 targetETHRaise,
        uint256 migrationFee,
        uint256 deploymentFee
    );

    event FeesCollected(
        uint256 indexed positionId, 
        uint256 ethFees, 
        uint256 tokenFees,
        uint256 ethServiceCharge,
        uint256 tokenServiceCharge
    );

    event BatchClaimCompleted(
        address indexed user,
        uint256 totalAttempted,
        uint256 successfulClaims,
        bool completed
    );

    event SelectTokenUpdated(address indexed oldToken, address indexed newToken);
    event EthPoolRatioUpdated(uint256 oldRatio, uint256 newRatio);
    event SelectPoolFeesCollected(address indexed tokenAddress, uint256 amount0, uint256 amount1);
    event LpVaultDeployed(address indexed vault);
    event SelectPoolSeeded(address indexed tokenAddress, uint256 ethPositionId, uint256 selectPositionId);
    event RefundsEnabled(address indexed tokenAddress);

    function streamManager() external view returns (address);

    function collectAndTransferFees(uint256 lpPositionId, uint256 tokenServiceChargeRate) external returns (
        uint256 originalETH,
        uint256 originalTokens,
        uint256 netETHSent,
        uint256 netTokensSent
    );

    function selectToken() external view returns (address);
    function ethPoolRatioBps() external view returns (uint256);
    function collectSelectPoolFees(address token) external returns (uint256 amount0, uint256 amount1);
}