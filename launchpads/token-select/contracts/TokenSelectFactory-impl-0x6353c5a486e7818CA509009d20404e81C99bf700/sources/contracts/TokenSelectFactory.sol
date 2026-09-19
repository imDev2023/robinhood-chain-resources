// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {ITokenSelectDeployer} from "./interfaces/ITokenSelectDeployer.sol";
import {ITokenSelectToken} from "./interfaces/ITokenSelectToken.sol";
import {ITokenSelectFactory} from "./interfaces/ITokenSelectFactory.sol";
import {AllocationValidator} from "./libraries/PresaleLibraries.sol";
import {INonfungiblePositionManager} from "./interfaces/INonfungiblePositionManager.sol";
import {IWETH} from "./interfaces/IWETH.sol";
import {ILPVault} from "./interfaces/ILPVault.sol";
import {LPVault} from "./LPVault.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract TokenSelectFactory is ITokenSelectFactory, OwnableUpgradeable, ReentrancyGuardUpgradeable, UUPSUpgradeable {
    using SafeERC20 for IERC20;

    // Constants
    uint256 private constant INITIAL_MIGRATION_FEE = 0.1 ether; 
    uint256 private constant MAX_MIGRATION_FEE = 0.5 ether; 
    uint256 private constant INITIAL_MIGRATION_FEE_PERCENTAGE = 100;
    uint256 private constant MAX_MIGRATION_FEE_PERCENTAGE = 500;
    uint256 private constant INITIAL_SERVICE_CHARGE_RATE = 2000;
    uint256 private constant INITIAL_DEPLOYMENT_FEE = 0.003 ether; 
    uint256 private constant MAX_DEPLOYMENT_FEE = 0.05 ether;
    uint256 private constant MIN_ETH_LIQUIDITY = 1 ether;
    uint256 private constant INITIAL_ETH_POOL_RATIO_BPS = 9000;
    uint256 private constant MIN_ETH_POOL_RATIO_BPS = 5000;

    // Uniswap V3 NonfungiblePositionManager on RH (4663).
    // Must stay identical to MigrationManager.POSITION_MANAGER
    address private constant POSITION_MANAGER = 0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3;

    // State variables
    uint256 public migrationFee;
    uint256 public migrationFeePercentage;
    uint256 public deploymentFee;
    uint256 public serviceChargeRate;
    uint256 public minETHLiquidity;

    uint256 public creatorFeeNoReferrer;
    uint256 public creatorFeeWithReferrer;
    uint256 public referrerFee;
    
    address public treasury;
    address public streamManager;
    address public referrerAdmin;
    address public migrationAdmin;
    address public weth;

    mapping(address => bool) public tokenSelectTokens;
    mapping(address => uint256) public tokenLPPositions;
    mapping(address => bool) public authorizedReferrers;

    INonfungiblePositionManager public positionManager;
    ITokenSelectDeployer public tokenDeployer;
    
    // Token tracking for enumeration
    address[] public deployedTokens;                

    mapping(address => uint256) public tokenIndex;
    mapping(address => address) public tokenCreators;

    // === SELECT Pool State (V2) ===
    address public selectToken;
    uint256 public ethPoolRatioBps;
    mapping(address => uint256) public selectPoolPositionIds;

    // === Freeze-migration State (V3) ===
    // The ETH pool holds TWO NFTs: the WETH "bid" (tokenLPPositions) and the TOKEN "ask" seeded at
    // deploy. Fees are collected from both. Appended last for UUPS storage-layout safety.
    mapping(address => uint256) public tokenAskLPPositions;

    // === LP custody (V4) ===
    // Ownerless, non-upgradeable custodian of every LP position NFT. Created once by this factory
    // via deployLpVault() so no address is ever supplied and none can be substituted. Proxy
    // STORAGE, not an implementation immutable: upgrades replace code, never data, so a later
    // implementation cannot forget or change it. Appended last for UUPS layout safety.
    // Read only when injecting into a new token. The fee path resolves the vault per-token.
    address public lpVault;

    modifier onlyReferrerAdmin() {
        if (msg.sender != referrerAdmin) revert OnlyReferrerAdmin();
        _;
    }

    modifier onlyMigrationAdmin() {
        if (msg.sender != migrationAdmin) revert OnlyMigrationAdmin();
        _;
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(address _treasury, address _streamManager, address _tokenDeployer) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        
        if (_treasury == address(0)) revert InvalidTreasury();
        if (_streamManager == address(0)) revert InvalidStreamManager();
        if (_tokenDeployer == address(0)) revert InvalidDeployer();
        
        minETHLiquidity = MIN_ETH_LIQUIDITY;
        migrationFee = INITIAL_MIGRATION_FEE;
        migrationFeePercentage = INITIAL_MIGRATION_FEE_PERCENTAGE;
        serviceChargeRate = INITIAL_SERVICE_CHARGE_RATE;
        deploymentFee = INITIAL_DEPLOYMENT_FEE;

        creatorFeeNoReferrer = 1000;    
        creatorFeeWithReferrer = 1500;
        referrerFee = 1000;

        treasury = _treasury;
        streamManager = _streamManager;
        referrerAdmin = msg.sender;
        migrationAdmin = msg.sender;
        ethPoolRatioBps = INITIAL_ETH_POOL_RATIO_BPS;

        tokenDeployer = ITokenSelectDeployer(_tokenDeployer);
        
        // Initialize position manager and WETH
        positionManager = INonfungiblePositionManager(POSITION_MANAGER);
        weth = positionManager.WETH9();
        
        emit MigrationFeeUpdated(0, INITIAL_MIGRATION_FEE);
        emit MigrationFeePercentageUpdated(0, INITIAL_MIGRATION_FEE_PERCENTAGE);
        emit DeploymentFeeUpdated(0, INITIAL_DEPLOYMENT_FEE);
        emit TreasuryUpdated(address(0), _treasury);
        emit StreamManagerUpdated (address(0), _streamManager);
    }

    function createTokenSelectToken(TokenCreationParams memory params, address referrer) 
        external 
        payable
        nonReentrant 
        returns (address payable tokenAddress)
    {        
        if (msg.value != deploymentFee) revert IncorrectDeploymentFee();

        // Before any ETH moves. Without a vault the token's own constructor would revert anyway
        if (lpVault == address(0)) revert LpVaultNotSet();

        // Transfer deployment fee
        if (deploymentFee > 0) {
            (bool success, ) = treasury.call{value: deploymentFee}("");
            if (!success) revert TreasuryTransferFailed();
        }
        
        // Validate referrer: only use if authorized, otherwise set to zero address
        address validReferrer = authorizedReferrers[referrer] ? referrer : address(0);
        
        // Validate allocation amounts
        AllocationValidator.validateAllocations(
            params.teamAllocation,
            params.marketingAllocation,
            params.communityRewardsAllocation
        );

        // Validate allocation timestamps
        AllocationValidator.validateVestingSchedules(
            params.teamAllocation,
            params.teamStartDelay,
            params.teamDuration,
            params.marketingAllocation,
            params.marketingStartDelay,
            params.marketingDuration,
            params.communityRewardsAllocation,
            params.communityStartDelay,
            params.communityDuration
        );
        
        // Create constructor parameters
        ITokenSelectToken.ConstructorParams memory constructorParams = ITokenSelectToken.ConstructorParams({
            name: params.name,
            symbol: params.symbol,
            creator: msg.sender,
            factory: address(this),
            streamManager: streamManager,
            serviceChargeRate: serviceChargeRate,
            creatorFeeNoReferrer: creatorFeeNoReferrer,
            creatorFeeWithReferrer: creatorFeeWithReferrer,
            referrerFee: referrerFee,
            referrer: validReferrer,
            minETHLiquidity: minETHLiquidity,
            targetETHRaise: params.targetETHRaise,
            maxContributionPerWallet: params.maxContributionPerWallet,
            teamAllocation: params.teamAllocation,
            marketingAllocation: params.marketingAllocation,
            communityRewardsAllocation: params.communityRewardsAllocation,
            saleStartTime: params.saleStartTime,
            saleEndTime: params.saleEndTime,
            migrationFee: migrationFee,
            migrationFeePercentage: migrationFeePercentage,
            selectToken: selectToken,
            ethPoolRatioBps: ethPoolRatioBps,
            teamStartDelay: params.teamStartDelay,
            teamDuration: params.teamDuration,
            marketingStartDelay: params.marketingStartDelay,
            marketingDuration: params.marketingDuration,
            communityStartDelay: params.communityStartDelay,
            communityDuration: params.communityDuration,
            teamRecipient: params.teamRecipient,
            marketingRecipient: params.marketingRecipient,
            communityRecipient: params.communityRecipient,
            lpVault: lpVault
        });
        
        tokenAddress = payable(tokenDeployer.deployToken(constructorParams));

        // Seed the frozen one-sided TOKEN legs atomically in this same tx, the token has
        // runtime code (a mint can't run inside the token's own constructor).
        ITokenSelectToken(tokenAddress).seedInitialLiquidity();

        tokenSelectTokens[tokenAddress] = true;
        deployedTokens.push(tokenAddress);
        tokenIndex[tokenAddress] = deployedTokens.length - 1;
        tokenCreators[tokenAddress] = msg.sender;
        
        emit NewTokenSelectToken(
            tokenAddress,
            msg.sender,
            params.name,
            params.symbol,
            params.targetETHRaise,
            migrationFee,
            deploymentFee
        );
    }

    /**
    * @dev Migrate a token
    * @param tokenAddress Address of the token to migrate
    */
    function migrate(address tokenAddress, int24 fairTick) external nonReentrant onlyMigrationAdmin {
        // Validate legitimate token
        if (!tokenSelectTokens[tokenAddress]) revert NotTokenSelectToken();
        
        // Call the token's migrate function. The ETH pool is seeded as two one-sided legs:
        // a WETH "bid" added now and the TOKEN "ask" seeded at deploy. Store both ids.
        (, , , uint256 ethBidPositionId, uint256 ethAskPositionId, uint256 selectPositionId) =
            ITokenSelectToken(tokenAddress).migrate(treasury, fairTick);

        tokenLPPositions[tokenAddress] = ethBidPositionId;
        tokenAskLPPositions[tokenAddress] = ethAskPositionId;

        if (selectPositionId != 0) {
            selectPoolPositionIds[tokenAddress] = selectPositionId;
        }
    }

    /**
    * @dev Re-attempt SELECT pool seeding for a migrated token whose atomic seed failed.
    * @param tokenAddress Address of the migrated token
    * @param fairTick Fair tick for the one-sided SELECT position
    */
    function retrySelectPool(address tokenAddress, int24 fairTick) external nonReentrant onlyMigrationAdmin {
        if (!tokenSelectTokens[tokenAddress]) revert NotTokenSelectToken();

        uint256 selectPositionId = ITokenSelectToken(tokenAddress).retrySelectPoolSeeding(fairTick);
        if (selectPositionId != 0) {
            selectPoolPositionIds[tokenAddress] = selectPositionId;
        }

        emit SelectPoolSeeded(tokenAddress, tokenLPPositions[tokenAddress], selectPositionId);
    }

    /**
    * @dev Escape hatch: open contributor refunds for a token whose migration is broken.
    *      Owner-only. This is one-way: the token can never migrate afterwards and it only lets
    *      each contributor withdraw their OWN ETH via token.refund()
    * @param tokenAddress Address of the token to open refunds for
    */
    function enableRefunds(address tokenAddress) external onlyOwner {
        if (!tokenSelectTokens[tokenAddress]) revert NotTokenSelectToken();

        ITokenSelectToken(tokenAddress).enableRefunds();

        emit RefundsEnabled(tokenAddress);
    }

    /**
    * @dev Add a referrer to authorized list
    * @param referrer Address to authorize as referrer
    */
    function addReferrer(address referrer) external onlyReferrerAdmin {
        if (referrer == address(0)) revert InvalidReferrer();

        authorizedReferrers[referrer] = true;

        emit ReferrerAdded(referrer);
    }

    /**
    * @dev Remove a referrer from authorized list
    * @param referrer Address to remove from referrers
    */
    function removeReferrer(address referrer) external onlyReferrerAdmin {
       
        authorizedReferrers[referrer] = false;
     
        emit ReferrerRemoved(referrer);
    }

    /**
    * @dev Collect fees from LP position and transfer to token contract
    * @param lpPositionId The NFT position ID
    * @param tokenServiceChargeRate Service charge rate for this specific token
    * @return originalETH Total ETH collected from LP
    * @return originalTokens Total tokens collected from LP
    * @return netETHSent Total ETH sent to token contract (after service charge)
    * @return netTokensSent Total tokens sent to token contract (after service charge)
    */
    function collectAndTransferFees(uint256 lpPositionId, uint256 tokenServiceChargeRate) 
        external  
        returns (
            uint256 originalETH,
            uint256 originalTokens,
            uint256 netETHSent,
            uint256 netTokensSent
        ) 
    {
        // Only allow legitimate tokens to call this
        if (!tokenSelectTokens[msg.sender]) revert NotTokenSelectToken();
        if (lpPositionId != tokenLPPositions[msg.sender]) revert UnauthorizedPosition();
        if (tokenLPPositions[msg.sender] == 0) revert NotMigrated();

        // Collect fees from BOTH ETH-pool legs: the WETH bid and the TOKEN ask
        // seeded at deploy. Fee accounting downstream is linear.
        (originalETH, originalTokens) = _collectFeesFromLP(lpPositionId);

        uint256 askPositionId = tokenAskLPPositions[msg.sender];
        if (askPositionId != 0) {
            (uint256 askETH, uint256 askTokens) = _collectFeesFromLP(askPositionId);
            originalETH += askETH;
            originalTokens += askTokens;
        }
        
        // Handle service charges
        (netETHSent, netTokensSent) = _transferServiceCharges(
            originalETH, 
            originalTokens, 
            msg.sender,
            tokenServiceChargeRate
        );
        
        // Transfer amounts to token contract
        if (netETHSent > 0) {
            (bool success, ) = msg.sender.call{value: netETHSent}("");
            if (!success) revert ETHTransferFailed();
        }
        
        if (netTokensSent > 0) {
            IERC20(msg.sender).safeTransfer(msg.sender, netTokensSent);
        }
        
        emit FeesCollected(lpPositionId, netETHSent, netTokensSent, 
                        originalETH - netETHSent, originalTokens - netTokensSent);
    }

    function batchClaimRewards(address[] calldata tokens) 
        external 
        nonReentrant 
        returns (BatchClaimResult memory result) 
    {
        result.totalAttempted = tokens.length;
        bool brokeForGas = false;
        
        for (uint256 i = 0; i < tokens.length; i++) {
            // Validate legitimate token
            if (!tokenSelectTokens[tokens[i]]) {
                result.lastProcessedIndex = i;
                continue;
            }
            
            // Check remaining gas before operation
            if (gasleft() < 300000) { // Reserve gas for return operations
                result.completed = false;
                brokeForGas = true;
                result.lastProcessedIndex = i > 0 ? i - 1 : 0;
                break;
            }
            
            // Attempt to claim for user
            try ITokenSelectToken(tokens[i]).claimRewardsFor(msg.sender) {
                result.successfulClaims++;
            } catch {}
            
            result.lastProcessedIndex = i;
        }
        
        // Only mark as completed if:
        // 1. Didn't break due to gas issues, AND
        // 2. Either processed all tokens OR had an empty array
        if (!brokeForGas && (tokens.length == 0 || result.lastProcessedIndex == tokens.length - 1)) {
            result.completed = true;
        }
        
        emit BatchClaimCompleted(
            msg.sender,
            result.totalAttempted,
            result.successfulClaims,
            result.completed
        );
    }

    /**
    * @dev Collect fees from LP position and return original amounts
    * @param lpPositionId The NFT position ID
    * @return originalETH Original ETH amount collected
    * @return originalTokens Original token amount collected
    */
    function _collectFeesFromLP(uint256 lpPositionId) internal returns (uint256 originalETH, uint256 originalTokens) {
       
        // Get token0 address and determine amounts
        (, , address token0, address token1, , , , , , , , ) = positionManager.positions(lpPositionId);

        bool isValidPair = (token0 == msg.sender && token1 == weth) || (token0 == weth && token1 == msg.sender);
        if (!isValidPair) revert UnauthorizedPosition();

        // Ask TOKEN which vault holds its positions.
        // The token's lpVault is immutable and was the mint recipient, so this is always the vault
        // that actually owns lpPositionId. A later implementation carrying a different address can
        // therefore only affect new launches.
        (uint256 amount0, uint256 amount1) =
            ILPVault(ITokenSelectToken(msg.sender).lpVault()).collect(lpPositionId);

        originalETH = (token0 == weth) ? amount0 : amount1;
        originalTokens = (token0 == weth) ? amount1 : amount0;
    }

    /**
    * @dev Handle service charge transfers to treasury and return net amounts
    * @param originalETH Original ETH amount
    * @param originalTokens Original token amount
    * @param tokenContract Token contract address
    * @return netETH ETH amount after service charge
    * @return netTokens Token amount after service charge
    */
    function _transferServiceCharges(
        uint256 originalETH,
        uint256 originalTokens,
        address tokenContract,
        uint256 tokenServiceChargeRate
    ) internal returns (uint256 netETH, uint256 netTokens) {
        uint256 ethServiceCharge = (originalETH * tokenServiceChargeRate) / 10000;
        uint256 tokenServiceCharge = (originalTokens * tokenServiceChargeRate) / 10000;
        
        // Calculate net amounts
        netETH = originalETH - ethServiceCharge;
        netTokens = originalTokens - tokenServiceCharge;
        
        // Unwrap WETH
        if (originalETH > 0) {
            IWETH(weth).withdraw(originalETH);
        }
        
        // Transfer service charge to treasury
        if (ethServiceCharge > 0) {
            (bool success, ) = treasury.call{value: ethServiceCharge}("");
            if (!success) revert TreasuryTransferFailed();
        }
        
        if (tokenServiceCharge > 0) {
            IERC20(tokenContract).safeTransfer(treasury, tokenServiceCharge);
        }
    }
    
    /**
    * @dev Update deployment fee
    * @param newFee New deployment fee in wei
    */
    function setDeploymentFee(uint256 newFee) external onlyOwner {
        if (newFee > MAX_DEPLOYMENT_FEE) revert InvalidDeploymentFee();
        
        uint256 oldFee = deploymentFee;
        deploymentFee = newFee;
        
        emit DeploymentFeeUpdated(oldFee, newFee);
    }

    /**
     * @dev Update migration fee
     * @param newFee New migration fee in wei
     */
    function setMigrationFee(uint256 newFee) external onlyOwner {
        if (newFee > MAX_MIGRATION_FEE) revert InvalidMigrationFee();
        
        uint256 oldFee = migrationFee;
        migrationFee = newFee;
        
        emit MigrationFeeUpdated(oldFee, newFee);
    }

    /**
    * @dev Update migration fee percentage
    * @param newPercentage New migration fee percentage in basis points
    */
    function setMigrationFeePercentage(uint256 newPercentage) external onlyOwner {
        if (newPercentage > MAX_MIGRATION_FEE_PERCENTAGE) revert InvalidMigrationFeePercentage();
        
        uint256 oldPercentage = migrationFeePercentage;
        migrationFeePercentage = newPercentage;
        
        emit MigrationFeePercentageUpdated(oldPercentage, newPercentage);
    }

     /**
     * @dev Update fee rates for trading fee rewards
     * @param _newServiceRate New service charge rate in basis points
     * @param _newCreatorFeeWithReferrer New creator-with-referrer rate in basis points
     * @param _newCreatorFeeNoReferrer New creator-without-referrer rate in basis points
     * @param _newReferrerFee New referrer rate in basis points
     */
    function setRewardFees(
        uint256 _newServiceRate, 
        uint256 _newCreatorFeeWithReferrer, 
        uint256 _newCreatorFeeNoReferrer, 
        uint256 _newReferrerFee
        ) external onlyOwner {
        
        if(
            _newServiceRate +
             _newCreatorFeeWithReferrer + 
             _newReferrerFee > 6000 || 
             _newServiceRate + 
             _newCreatorFeeNoReferrer > 6000) 
             revert InvalidFeeConfig();

        uint256 oldServiceRate = serviceChargeRate;
        uint256 oldCreatorWithReferrerRate = creatorFeeWithReferrer;
        uint256 oldCreatorNoReferrerRate = creatorFeeNoReferrer;
        uint256 oldReferrerRate = referrerFee;

        serviceChargeRate = _newServiceRate;
        creatorFeeWithReferrer = _newCreatorFeeWithReferrer;
        creatorFeeNoReferrer = _newCreatorFeeNoReferrer;
        referrerFee = _newReferrerFee;

        emit RewardFeesUpdated(
            oldServiceRate,
            oldCreatorWithReferrerRate,
            oldCreatorNoReferrerRate,
            oldReferrerRate,
            _newServiceRate,
            _newCreatorFeeWithReferrer,
            _newCreatorFeeNoReferrer,
            _newReferrerFee
            );
        }

    function setMinETHLiquidity(uint256 newMinimum) external onlyOwner {
        uint256 oldMinimum = minETHLiquidity;
        minETHLiquidity = newMinimum;
        emit MinETHLiquidityUpdated(oldMinimum, newMinimum);
    }

    /**
    * @dev Update internal stream manager address
    * @param newStreamManager New streamManager address
    */
    function setStreamManager(address newStreamManager) external onlyOwner {
        if (newStreamManager == address(0)) revert InvalidStreamManager();
        
        address oldStreamManager = streamManager;
        streamManager = newStreamManager;
        
        emit StreamManagerUpdated(oldStreamManager, newStreamManager);
    }

    /** 
    * @dev Update referrerAdmin authority
    * @param _newAdmin Address of new referrerAdmin authority
    */
    function setReferrerAdmin(address _newAdmin) external onlyOwner {
        if (_newAdmin == address(0)) revert InvalidAdmin();

        address oldAdmin = referrerAdmin;
        referrerAdmin = _newAdmin;

        emit ReferrerAdminUpdated(oldAdmin, _newAdmin);
    }

    /**
    * @dev Update migrationAdmin authority
    * @param _newAdmin Address of new migrationAdmin authority
    */
    function setMigrationAdmin(address _newAdmin) external onlyOwner {
        if (_newAdmin == address(0)) revert InvalidAdmin();

        address oldAdmin = migrationAdmin;
        migrationAdmin = _newAdmin;

        emit MigrationAdminUpdated(oldAdmin, _newAdmin);
    }

    /**
     * @dev Update the token deployer contract
     */
    function setTokenSelectDeployer(address newDeployer) external onlyOwner {
        if (newDeployer == address(0)) revert InvalidDeployer();

        address oldTokenDeployer = address(tokenDeployer);
        tokenDeployer = ITokenSelectDeployer(newDeployer);

        emit TokenDeployerUpdated(oldTokenDeployer, newDeployer);
    }

    /**
    * @dev Update treasury address
    * @param newTreasury New treasury address
    */
    function setTreasury(address newTreasury) external onlyOwner {
        if (newTreasury == address(0)) revert InvalidTreasury();
        
        address oldTreasury = treasury;
        treasury = newTreasury;
        
        emit TreasuryUpdated(oldTreasury, newTreasury);
    }

    // === SELECT Pool Functions ===

    /**
     * @dev Set the SELECT token address
     */
    /**
     * @dev Create this factory's LP vault. One-shot, the vault reads its
     *      FACTORY from msg.sender, so nothing can be substituted and nothing has to be
     *      precomputed. Must be called before any token can be created.
     *
     *      The address lives in proxy storage, so an implementation upgrade keeps it; calling this
     *      again reverts. Existing tokens are unaffected either way.
     */
    function deployLpVault() external onlyOwner returns (address vault) {
        if (lpVault != address(0)) revert LpVaultAlreadySet();

        vault = address(new LPVault(POSITION_MANAGER));
        lpVault = vault;

        emit LpVaultDeployed(vault);
    }

    function setSelectToken(address _selectToken) external onlyOwner {
        address oldToken = selectToken;
        selectToken = _selectToken;
        emit SelectTokenUpdated(oldToken, _selectToken);
    }

    /**
     * @dev Set the ETH pool ratio in basis points (ie 9000 = 90%)
     */
    function setEthPoolRatioBps(uint256 _ratioBps) external onlyOwner {
        if (_ratioBps < MIN_ETH_POOL_RATIO_BPS || _ratioBps > 10000) revert InvalidEthPoolRatio();
        uint256 oldRatio = ethPoolRatioBps;
        ethPoolRatioBps = _ratioBps;
        emit EthPoolRatioUpdated(oldRatio, _ratioBps);
    }

    /**
     * @dev Collect fees from SELECT pool position (all fees go to treasury).
     */
    function collectSelectPoolFees(address tokenAddress) external onlyMigrationAdmin returns (uint256 amount0, uint256 amount1) {
        // This now makes an external call to tokenAddress, so verify it is ours first.
        if (!tokenSelectTokens[tokenAddress]) revert NotTokenSelectToken();

        uint256 posId = selectPoolPositionIds[tokenAddress];
        if (posId == 0) revert NoSelectPoolPosition();

        // Read the pair from the position rather than from `selectToken`, which is owner-mutable.
        (, , address token0, address token1, , , , , , , , ) = positionManager.positions(posId);

        (amount0, amount1) = ILPVault(ITokenSelectToken(tokenAddress).lpVault()).collect(posId);

        if (amount0 > 0) IERC20(token0).safeTransfer(treasury, amount0);
        if (amount1 > 0) IERC20(token1).safeTransfer(treasury, amount1);

        emit SelectPoolFeesCollected(tokenAddress, amount0, amount1);
    }

    /**
     * @dev Get all deployed tokens
     * @return address[] Array of all deployed token addresses
     */
    function getAllDeployedTokens() external view returns (address[] memory) {
        return deployedTokens;
    }

    /**
     * @dev Get deployed tokens in range (for pagination)
     * @param start Starting index (inclusive)
     * @param end Ending index (exclusive)
     * @return tokens Array of token addresses in the specified range
     */
    function getDeployedTokensRange(uint256 start, uint256 end) 
        external 
        view 
        returns (address[] memory tokens) 
    {
        if (start >= end || end > deployedTokens.length) revert InvalidRange();
        
        tokens = new address[](end - start);
        for (uint256 i = start; i < end; i++) {
            tokens[i - start] = deployedTokens[i];
        }
    }

    /**
     * @dev Get total number of deployed tokens
     * @return uint256 Total count of deployed tokens
     */
    function getDeployedTokensCount() external view returns (uint256) {
        return deployedTokens.length;
    }

    /**
     * @dev Get allocation limits for reference
     */
    function getAllocationLimits() external pure returns (
        uint256 maxMarketing,
        uint256 maxTeam,
        uint256 maxCommunity,
        uint256 maxCombined
    ) {
        return AllocationValidator.getAllocationLimits();
    }

    /**
     * @dev Validate token creation parameters
     * @param params Token creation parameters to validate
     * @return bool True if parameters are valid
     */
    function validateTokenParams(TokenCreationParams memory params) 
        external 
        pure 
        returns (bool) 
    {
        return AllocationValidator.areAllocationsValid(
            params.teamAllocation,
            params.marketingAllocation,
            params.communityRewardsAllocation
        ) && 
        AllocationValidator.areVestingSchedulesValid(
            params.teamAllocation,
            params.teamStartDelay,
            params.teamDuration,
            params.marketingAllocation,
            params.marketingStartDelay,
            params.marketingDuration,
            params.communityRewardsAllocation,
            params.communityStartDelay,
            params.communityDuration
        );
    }

    /**
     * @dev Authorize upgrades
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev Allow factory to receive ETH
     */
    receive() external payable {}
}