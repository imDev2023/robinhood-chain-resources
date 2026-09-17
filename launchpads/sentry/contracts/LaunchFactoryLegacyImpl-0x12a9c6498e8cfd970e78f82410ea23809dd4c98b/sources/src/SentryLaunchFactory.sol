// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SentryLaunchFactory
 * @dev Token launch factory for the Sentry launchpad on Uniswap V3. Deploys
 * tokens, creates 1% fee-tier pools, mints single-sided LP positions,
 * permanently self-custodies the LP NFTs, and routes collected trading fees
 * between creators and treasury.
 *
 * - Multi-base token support (WETH, etc.), each with its own pool manager
 * - Upgradeable via TransparentUpgradeableProxy + ProxyAdmin; initialize()
 *   replaces the constructor
 */

import "./interfaces/ISentryInterfaces.sol";
import "./SentryTokenStandard.sol";

/* ─────────────────────────── Structs ─────────────────────────── */

struct MintingDetails {
    uint160 sqrtPriceX96;
    int24 tickLower;
    int24 tickUpper;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
}

/* ─────────────────────────── SentryLaunchFactory ─────────────────────────── */

contract SentryLaunchFactory {
    /* ─────────────────────────── State Variables ─────────────────────────── */

    // Initializer guard (proxy pattern)
    bool private _initialized;

    /// @dev Locks initialize() on the implementation; only the proxy can init.
    constructor() {
        _initialized = true;
    }

    // Core DEX addresses
    address public npm;         // Uniswap V3 NonfungiblePositionManager

    // Multi-Base Token Support
    mapping(address => address) public baseTokenToPoolManager;
    address[] public baseTokens;

    // Constants
    uint24 public constant FEE_TIER = 10000; // 1% fee tier for launches
    uint256 private constant DEFAULT_CREATOR_FEE_BPS = 6500; // 65% of collected LP fees → creator
    uint256 private constant BPS_DENOMINATOR = 10_000;

    // Treasury — receives ALL collected fees
    address public treasury;

    // Creator tracking
    mapping(uint256 => address) public nftCreators;
    mapping(address => uint256[]) public creatorNFTs;
    mapping(uint256 => address) public tokenIdToToken;

    // Token deployment counter
    uint256 public totalTokensDeployed;

    // Temporary storage for stack optimization
    address private _tempCreator;
    address private _tempToken0;
    address private _tempToken1;
    address private _tempPool;

    // Owner
    address public owner;

    // Reentrancy guard
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    // Creator's share of collected LP fees, in bps
    uint256 private _creatorFeeBps;

    // Fee recipient overrides. Zero address means fees route to the
    // token's creator (nftCreators). Self-service migration is allowed
    // ONCE per token, ever; the owner path has no limit. Appended for
    // proxy storage-layout safety — never reorder the fields above.
    mapping(uint256 => address) public feeRecipients;
    mapping(uint256 => bool) public feeRecipientMigrated;

    /* ──────────────────────────────── Events ──────────────────────────────── */

    event Initialized(address indexed npm, address indexed treasury);
    event TokenDeployed(
        address indexed token,
        string name,
        string symbol,
        address indexed creator,
        uint256 tokenId
    );
    event PoolInitialized(address indexed pool, address indexed token);
    event LiquidityMinted(uint256 indexed tokenId, address indexed pool, address indexed token);
    event LPLocked(uint256 indexed tokenId, address indexed pool, address indexed token);
    event FeesCollected(uint256 indexed tokenId, uint256 amount0, uint256 amount1);
    event CreatorFeePaid(uint256 indexed tokenId, address indexed creator, address token, uint256 amount);
    event BaseTokenAdded(address indexed baseToken, address indexed manager);
    event BaseTokenRemoved(address indexed baseToken);
    event PoolManagerUpdated(address indexed baseToken, address oldManager, address newManager);
    event TreasuryUpdated(address oldTreasury, address newTreasury);
    event NPMUpdated(address oldNPM, address newNPM);
    event CreatorFeeBpsUpdated(uint256 oldCreatorFeeBps, uint256 newCreatorFeeBps);
    event FeeRecipientUpdated(
        uint256 indexed tokenId,
        address indexed oldRecipient,
        address indexed newRecipient,
        address setBy
    );

    /* ─────────────────────────────── Modifiers ─────────────────────────────── */

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier initializer() {
        require(!_initialized, "Already initialized");
        _initialized = true;
        _;
    }

    /* ──────────────────────────── Initializer ──────────────────────────────── */

    /**
     * @notice Replaces the constructor for proxy compatibility.
     *         Called once by the TransparentUpgradeableProxy on deployment.
     * @param _npm                Uniswap V3 NonfungiblePositionManager address
     * @param _initialBaseToken   First supported base token (e.g. WETH)
     * @param _initialPoolManager Pool manager contract for the initial base token
     * @param _treasury           Address that receives treasury LP fees
     */
    function initialize(
        address _npm,
        address _initialBaseToken,
        address _initialPoolManager,
        address _treasury
    ) external initializer {
        require(_npm != address(0), "Invalid NPM");
        require(_initialBaseToken != address(0), "Invalid base token");
        require(_initialPoolManager != address(0), "Invalid pool manager");
        require(_treasury != address(0), "Invalid treasury");

        npm = _npm;
        treasury = _treasury;
        owner = msg.sender;       // proxy deployer becomes owner
        _status = _NOT_ENTERED;
        _creatorFeeBps = DEFAULT_CREATOR_FEE_BPS;

        baseTokenToPoolManager[_initialBaseToken] = _initialPoolManager;
        baseTokens.push(_initialBaseToken);

        emit BaseTokenAdded(_initialBaseToken, _initialPoolManager);
        emit Initialized(_npm, _treasury);
    }

    /* ────────────────────── Base Token Management ───────────────────────── */

    function addBaseToken(address baseToken, address manager) external onlyOwner {
        require(baseToken != address(0) && manager != address(0), "Invalid addresses");
        require(baseTokenToPoolManager[baseToken] == address(0), "Base token already exists");
        baseTokenToPoolManager[baseToken] = manager;
        baseTokens.push(baseToken);
        emit BaseTokenAdded(baseToken, manager);
    }

    function updatePoolManager(address baseToken, address newManager) external onlyOwner {
        require(baseTokenToPoolManager[baseToken] != address(0), "Base token does not exist");
        require(newManager != address(0), "Invalid manager");
        address oldManager = baseTokenToPoolManager[baseToken];
        baseTokenToPoolManager[baseToken] = newManager;
        emit PoolManagerUpdated(baseToken, oldManager, newManager);
    }

    function removeBaseToken(address baseToken) external onlyOwner {
        require(baseTokenToPoolManager[baseToken] != address(0), "Base token does not exist");
        delete baseTokenToPoolManager[baseToken];
        for (uint256 i = 0; i < baseTokens.length; i++) {
            if (baseTokens[i] == baseToken) {
                baseTokens[i] = baseTokens[baseTokens.length - 1];
                baseTokens.pop();
                break;
            }
        }
        emit BaseTokenRemoved(baseToken);
    }

    /* ────────────────────── Token Launch ───────────────────── */

    /**
     * @notice Launch a new token, create a V3 pool, and lock single-sided LP.
     * @param _name     Token name
     * @param _symbol   Token symbol
     * @param baseToken The base pair token (e.g. WETH)
     * @return tokenAddress The deployed token contract address
     * @return tokenId      LP NFT token ID (held permanently by this factory)
     */
    function launch(
        string memory _name,
        string memory _symbol,
        address baseToken
    ) external nonReentrant returns (address tokenAddress, uint256 tokenId) {
        return _launch(_name, _symbol, baseToken);
    }

    /// @notice Launch with LP fees directed to `feeRecipient` instead of the
    ///         launcher. Zero address (or the launcher's own address) behaves
    ///         exactly like launch(). The launcher remains the recorded
    ///         creator; only the fee destination differs.
    function launchWithFeeRecipient(
        string memory _name,
        string memory _symbol,
        address baseToken,
        address feeRecipient
    ) external nonReentrant returns (address tokenAddress, uint256 tokenId) {
        (tokenAddress, tokenId) = _launch(_name, _symbol, baseToken);
        if (feeRecipient != address(0) && feeRecipient != msg.sender) {
            feeRecipients[tokenId] = feeRecipient;
            emit FeeRecipientUpdated(tokenId, msg.sender, feeRecipient, msg.sender);
        }
    }

    function _launch(
        string memory _name,
        string memory _symbol,
        address baseToken
    ) internal returns (address tokenAddress, uint256 tokenId) {
        require(baseTokenToPoolManager[baseToken] != address(0), "Base token not supported");

        SentryTokenStandard token = new SentryTokenStandard(_name, _symbol, address(this));
        tokenAddress = address(token);
        totalTokensDeployed++;

        require(token.approve(npm, type(uint256).max), "Approval failed");

        // V3 requires token0 < token1 (sorted by address)
        address token0 = tokenAddress < baseToken ? tokenAddress : baseToken;
        address token1 = tokenAddress < baseToken ? baseToken : tokenAddress;

        require(
            _tryPoolAndMint(tokenAddress, token0, token1, baseToken, msg.sender),
            "Pool creation and mint failed"
        );

        uint256[] storage creatorNFTList = creatorNFTs[msg.sender];
        tokenId = creatorNFTList[creatorNFTList.length - 1];

        emit TokenDeployed(tokenAddress, _name, _symbol, msg.sender, tokenId);
    }

    /* ──────────────────────── Internal Pool & Mint Logic ───────────────────── */

    function _tryPoolAndMint(
        address tokenAddress,
        address token0,
        address token1,
        address baseToken,
        address creator
    ) internal returns (bool) {
        _tempCreator = creator;
        _tempToken0 = token0;
        _tempToken1 = token1;

        MintingDetails memory details;
        (
            details.sqrtPriceX96,
            details.tickLower,
            details.tickUpper,
            details.amount0Desired,
            details.amount1Desired,
            details.amount0Min,
            details.amount1Min
        ) = ITsunamiPoolManager(baseTokenToPoolManager[baseToken]).getMintingParameters(tokenAddress, token0, token1);

        if (!_createAndInitializePool(details.sqrtPriceX96)) return false;
        return _mintPosition(details, tokenAddress);
    }

    function _createAndInitializePool(uint160 sqrtPriceX96) internal returns (bool) {
        try INonfungiblePositionManager(npm).createAndInitializePoolIfNecessary(
            _tempToken0, _tempToken1, FEE_TIER, sqrtPriceX96
        ) returns (address pool) {
            _tempPool = pool;
            return true;
        } catch {
            return false;
        }
    }

    function _mintPosition(
        MintingDetails memory details,
        address tokenAddress
    ) internal returns (bool) {
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: _tempToken0,
            token1: _tempToken1,
            fee: FEE_TIER,
            tickLower: details.tickLower,
            tickUpper: details.tickUpper,
            amount0Desired: details.amount0Desired,
            amount1Desired: details.amount1Desired,
            amount0Min: details.amount0Min,
            amount1Min: details.amount1Min,
            recipient: address(this),
            deadline: block.timestamp + 600
        });

        try INonfungiblePositionManager(npm).mint(params) returns (uint256 tokenId, uint128, uint256, uint256) {
            return _handleSuccessfulMint(tokenId, INonfungiblePositionManager(npm), tokenAddress);
        } catch {
            return false;
        }
    }

    function _handleSuccessfulMint(
        uint256 tokenId,
        INonfungiblePositionManager npmContract,
        address tokenAddress
    ) internal returns (bool) {
        nftCreators[tokenId] = _tempCreator;
        creatorNFTs[_tempCreator].push(tokenId);
        tokenIdToToken[tokenId] = tokenAddress;

        require(npmContract.ownerOf(tokenId) == address(this), "Factory does not own LP NFT");

        emit PoolInitialized(_tempPool, tokenAddress);
        emit LiquidityMinted(tokenId, _tempPool, tokenAddress);
        // Factory permanently self-custodies the LP NFT.
        emit LPLocked(tokenId, _tempPool, tokenAddress);

        return true;
    }

    /* ──────────────────────────── Fee Collection ───────────────────────────── */

    /// @notice Collect accrued trading fees from one LP position and route them.
    /// @dev Callable by the factory owner, the token's creator, or the current
    ///      fee recipient. Routing is identical regardless of caller: the split
    ///      always pays the current fee recipient + treasury, so no caller can
    ///      redirect a payout by collecting.
    function collectFees(uint256 tokenId) external nonReentrant {
        require(
            msg.sender == owner
                || msg.sender == nftCreators[tokenId]
                || msg.sender == feeRecipients[tokenId],
            "Not owner or token creator"
        );
        (, , address token0, address token1, , , , , , , , ) = INonfungiblePositionManager(npm).positions(tokenId);
        (uint256 amount0, uint256 amount1) = INonfungiblePositionManager(npm).collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );
        emit FeesCollected(tokenId, amount0, amount1);
        _routeFees(token0, token1, amount0, amount1, tokenId);
    }

    /// @notice Batch collect fees from multiple LP positions (owner only).
    function collectMultipleFees(uint256[] calldata tokenIds) external onlyOwner nonReentrant {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            (, , address token0, address token1, , , , , , , , ) = INonfungiblePositionManager(npm).positions(tokenIds[i]);
            (uint256 amount0, uint256 amount1) = INonfungiblePositionManager(npm).collect(
                INonfungiblePositionManager.CollectParams({
                    tokenId: tokenIds[i],
                    recipient: address(this),
                    amount0Max: type(uint128).max,
                    amount1Max: type(uint128).max
                })
            );
            emit FeesCollected(tokenIds[i], amount0, amount1);
            _routeFees(token0, token1, amount0, amount1, tokenIds[i]);
        }
    }

    /// @dev Splits both sides of the collected fees the same way:
    ///      creatorFeeBps() (default 65%) to the position's current fee
    ///      recipient (the creator unless overridden), the remainder
    ///      (default 35%) to treasury. If the recipient resolves to zero,
    ///      the full amount goes to treasury rather than burning it or
    ///      reverting.
    function _routeFees(
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1,
        uint256 tokenId
    ) internal {
        address recipient = feeRecipientOf(tokenId);
        _routeSide(token0, amount0, recipient, tokenId);
        _routeSide(token1, amount1, recipient, tokenId);
    }

    function _routeSide(address token, uint256 amount, address recipient, uint256 tokenId) internal {
        if (amount == 0) return;

        uint256 creatorCut = recipient == address(0)
            ? 0
            : (amount * creatorFeeBps()) / BPS_DENOMINATOR;
        uint256 treasuryCut = amount - creatorCut;

        if (creatorCut > 0) {
            require(IERC20(token).transfer(recipient, creatorCut), "creator transfer failed");
            emit CreatorFeePaid(tokenId, recipient, token, creatorCut);
        }
        if (treasuryCut > 0) {
            require(IERC20(token).transfer(treasury, treasuryCut), "treasury transfer failed");
        }
    }

    /* ─────────────────────── Fee Recipient Management ──────────────────────── */

    /// @notice Where a position's creator-side fees currently go: the
    ///         override when set, otherwise the token's creator.
    function feeRecipientOf(uint256 tokenId) public view returns (address) {
        address override_ = feeRecipients[tokenId];
        return override_ == address(0) ? nftCreators[tokenId] : override_;
    }

    /// @notice One-time self-service migration of a position's fee
    ///         recipient. Callable only by the CURRENT recipient, exactly
    ///         once per token, ever. Further changes require the owner path
    ///         (community-takeover reviews and the like).
    function migrateFeeRecipient(uint256 tokenId, address newRecipient) external {
        require(newRecipient != address(0), "Invalid recipient");
        address current = feeRecipientOf(tokenId);
        require(current != address(0), "Unknown tokenId");
        require(msg.sender == current, "Not fee recipient");
        require(!feeRecipientMigrated[tokenId], "Already migrated");

        feeRecipientMigrated[tokenId] = true;
        feeRecipients[tokenId] = newRecipient;
        emit FeeRecipientUpdated(tokenId, current, newRecipient, msg.sender);
    }

    /// @notice Owner override of a position's fee recipient, unrestricted
    ///         and repeatable. Does not consume (or reset) the self-service
    ///         migration flag.
    function adminSetFeeRecipient(uint256 tokenId, address newRecipient) external onlyOwner {
        require(newRecipient != address(0), "Invalid recipient");
        require(nftCreators[tokenId] != address(0), "Unknown tokenId");
        address old = feeRecipientOf(tokenId);
        feeRecipients[tokenId] = newRecipient;
        emit FeeRecipientUpdated(tokenId, old, newRecipient, msg.sender);
    }

    /* ───────────────────────── Admin Functions ────────────────────────────── */

    event LPSweptToVault(uint256 indexed tokenId, address indexed vault, address creator, address feeRecipient);

    /// @notice One-time escape hatch: move self-custodied v3 LP NFTs out
    /// of this (upgradeable) factory and into the immutable LP vault. The
    /// current fee routing for each position (its recorded creator and any
    /// fee-recipient override) is encoded into the transfer `data` so the
    /// vault can attribute fees identically. Owner only. Naturally
    /// idempotent: once an NFT is transferred the factory no longer owns
    /// it, so a repeat sweep of the same id reverts in the NPM.
    /// @param tokenIds The LP NFT ids to sweep (must be held by this factory).
    /// @param vault    The SentryLPVault to receive them.
    function sweepToVault(uint256[] calldata tokenIds, address vault) external onlyOwner nonReentrant {
        require(vault != address(0), "Invalid vault");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            address creator = nftCreators[tokenId];
            require(creator != address(0), "Unknown tokenId");
            address feeRecipientOverride = feeRecipients[tokenId];
            INonfungiblePositionManager(npm).safeTransferFrom(
                address(this), vault, tokenId, abi.encode(creator, feeRecipientOverride)
            );
            emit LPSweptToVault(tokenId, vault, creator, feeRecipientOverride);
        }
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid owner");
        owner = newOwner;
    }

    function updateTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0), "Invalid treasury");
        address oldTreasury = treasury;
        treasury = newTreasury;
        emit TreasuryUpdated(oldTreasury, newTreasury);
    }

    function updateNPM(address newNPM) external onlyOwner {
        require(newNPM != address(0), "Invalid NPM");
        address oldNPM = npm;
        npm = newNPM;
        emit NPMUpdated(oldNPM, newNPM);
    }

    /// @notice Backwards-compatible getter for integrations that read the old public constant.
    function CREATOR_FEE_BPS() external view returns (uint256) {
        return creatorFeeBps();
    }

    function creatorFeeBps() public view returns (uint256) {
        uint256 configured = _creatorFeeBps;
        return configured == 0 ? DEFAULT_CREATOR_FEE_BPS : configured;
    }

    function setCreatorFeeBps(uint256 newCreatorFeeBps) external onlyOwner {
        require(newCreatorFeeBps > 0 && newCreatorFeeBps <= BPS_DENOMINATOR, "Invalid creator fee");
        uint256 old = creatorFeeBps();
        _creatorFeeBps = newCreatorFeeBps;
        emit CreatorFeeBpsUpdated(old, newCreatorFeeBps);
    }

    /* ──────────────────────────── View Functions ───────────────────────────── */

    function getPoolManager(address baseToken) external view returns (address) {
        return baseTokenToPoolManager[baseToken];
    }

    function getSupportedBaseTokens() external view returns (address[] memory) {
        return baseTokens;
    }

    function getCreator(uint256 tokenId) external view returns (address) {
        return nftCreators[tokenId];
    }

    function getCreatorNFTs(address creator) external view returns (uint256[] memory) {
        return creatorNFTs[creator];
    }

    function getCreatorNFTCount(address creator) external view returns (uint256) {
        return creatorNFTs[creator].length;
    }

    function getTokenByNFT(uint256 tokenId) external view returns (address) {
        return tokenIdToToken[tokenId];
    }

    function getTotalTokensDeployed() external view returns (uint256) {
        return totalTokensDeployed;
    }

    /* ──────────────── ERC-721 Receiver (defensive) ──────────────────────── */

    /// @dev Accept LP NFTs via safeTransferFrom (defensive — NPM uses _mint, but future-proofs).
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /* ─────────────────── Upgrade Storage Gap ─────────────────────────────── */

    // Shrunk 41 -> 39 in the fee-recipient upgrade: feeRecipients and
    // feeRecipientMigrated consumed the gap's first two slots, keeping
    // the total storage footprint identical to the deployed layout.
    uint256[39] private __gap;
}
