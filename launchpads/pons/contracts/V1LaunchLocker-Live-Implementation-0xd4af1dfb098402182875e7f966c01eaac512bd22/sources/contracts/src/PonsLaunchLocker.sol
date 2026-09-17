// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC721ReceiverLike, INonfungiblePositionManagerLike, IPonsLaunchFactory} from "./interfaces/ILaunchpad.sol";

/**
 * @title PonsLaunchLocker
 * @notice Holds launch position NFTs behind a UUPS proxy and distributes
 * accrued fees. The runtime code exposes no position withdrawal or
 * arbitrary-call function; custody guarantees therefore rest on the proxy
 * owner, who can authorize upgrades.
 */
contract PonsLaunchLocker is
    Initializable,
    Ownable2StepUpgradeable,
    ReentrancyGuard,
    UUPSUpgradeable,
    IERC721ReceiverLike
{
    using SafeERC20 for IERC20;

    uint256 public constant MAX_PROTOCOL_FEE_SHARE = 50;

    error NotFactory();
    error NotAuthorized();
    error TokenNotFound();
    error PositionNotHeld();
    error PositionAlreadyLocked();
    error NoFeesToCollect();
    error InvalidProtocolFee();
    error AlreadyInitialized();
    error ZeroAddress();

    event FactoryUpdated(address indexed factory);
    event PositionLocked(
        address indexed token,
        address indexed deployer,
        uint256 indexed dexId,
        address pairToken,
        uint256 positionId,
        address positionManager
    );
    event FeesClaimed(
        address indexed token,
        address indexed caller,
        address token0,
        address token1,
        uint256 recipientAmount0,
        uint256 recipientAmount1,
        uint256 protocolAmount0,
        uint256 protocolAmount1
    );
    event FeeRedirectUpdated(address indexed token, address indexed newFeeWallet);
    event FeeCollectorUpdated(address indexed collector, bool enabled);
    event ProtocolFeeRecipientUpdated(address recipient);
    event ProtocolFeeUpdated(uint256 share);

    // Proxy storage: extend by appending only, never reorder or remove.
    address public factory;
    address public protocolFeeRecipient;
    uint256 public protocolFeeShare;

    mapping(address collector => bool enabled) public feeCollectors;
    mapping(address token => address recipient) public feeRedirects;
    mapping(address token => uint256 share) public tokenProtocolFeeShares;
    mapping(address deployer => address[] tokens) public deployerTokens;
    mapping(address recipient => address[] tokens) public feeRecipientTokens;
    mapping(address token => uint256 indexPlusOne) private _feeRecipientTokenIndexes;
    mapping(address token => bool locked) private _lockedTokens;

    /**
     * @notice Locks the implementation so state can only live behind a proxy.
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the proxy with owner, fee recipient, and fee share.
     * @param initialOwner Administrative owner for fee policy, collectors, and upgrades.
     * @param initialProtocolFeeRecipient Recipient of the protocol fee share.
     * @param initialProtocolFeeShare Percentage from 0 through MAX_PROTOCOL_FEE_SHARE.
     */
    function initialize(address initialOwner, address initialProtocolFeeRecipient, uint256 initialProtocolFeeShare)
        external
        initializer
    {
        __Ownable_init(initialOwner);
        __Ownable2Step_init();

        if (initialProtocolFeeRecipient == address(0)) revert ZeroAddress();
        if (initialProtocolFeeShare > MAX_PROTOCOL_FEE_SHARE) revert InvalidProtocolFee();
        protocolFeeRecipient = initialProtocolFeeRecipient;
        protocolFeeShare = initialProtocolFeeShare;
    }

    modifier onlyFactory() {
        if (msg.sender != factory) revert NotFactory();
        _;
    }

    /**
     * @notice Binds the locker to one launch factory. Callable once.
     */
    function setFactory(address factory_) external onlyOwner {
        if (factory != address(0)) revert AlreadyInitialized();
        if (factory_ == address(0)) revert ZeroAddress();
        factory = factory_;
        emit FactoryUpdated(factory_);
    }

    /**
     * @notice Accepts only launch NFTs transferred by the configured factory.
     */
    function onERC721Received(address operator, address from, uint256, bytes calldata) external view returns (bytes4) {
        if (operator != factory || from != factory) revert NotFactory();
        return IERC721ReceiverLike.onERC721Received.selector;
    }

    /**
     * @notice Registers and verifies permanent custody of a launched position.
     */
    function lockPosition(address token) external onlyFactory {
        if (_lockedTokens[token]) revert PositionAlreadyLocked();

        IPonsLaunchFactory.LaunchedToken memory launched = IPonsLaunchFactory(factory).getLaunchedToken(token);
        if (!launched.exists || launched.token != token) revert TokenNotFound();

        address nftOwner = INonfungiblePositionManagerLike(launched.positionManager).ownerOf(launched.positionId);
        if (nftOwner != address(this)) revert PositionNotHeld();

        _lockedTokens[token] = true;
        tokenProtocolFeeShares[token] = protocolFeeShare;
        deployerTokens[launched.deployer].push(token);

        emit PositionLocked(
            token,
            launched.deployer,
            launched.dexId,
            launched.pairedToken,
            launched.positionId,
            launched.positionManager
        );
    }

    /**
     * @notice Collects V3 fees and splits both assets under the configured policy.
     */
    function collectFees(address token) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        IPonsLaunchFactory.LaunchedToken memory launched = getLaunchedToken(token);
        if (!launched.exists || !_lockedTokens[token]) revert TokenNotFound();

        address recipient = feeRedirects[token];
        if (recipient == address(0)) recipient = launched.deployer;
        if (
            msg.sender != owner() && msg.sender != launched.deployer && msg.sender != recipient
                && !feeCollectors[msg.sender]
        ) {
            revert NotAuthorized();
        }

        INonfungiblePositionManagerLike manager = INonfungiblePositionManagerLike(launched.positionManager);
        address token0;
        address token1;
        (,, token0, token1,,,,,,,,) = manager.positions(launched.positionId);

        (amount0, amount1) = manager.collect(
            INonfungiblePositionManagerLike.CollectParams({
                tokenId: launched.positionId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );
        if (amount0 == 0 && amount1 == 0) revert NoFeesToCollect();

        uint256 tokenProtocolFeeShare = tokenProtocolFeeShares[token];
        uint256 protocolAmount0 = (amount0 * tokenProtocolFeeShare) / 100;
        uint256 protocolAmount1 = (amount1 * tokenProtocolFeeShare) / 100;
        uint256 recipientAmount0 = amount0 - protocolAmount0;
        uint256 recipientAmount1 = amount1 - protocolAmount1;

        _transferIfPositive(token0, protocolFeeRecipient, protocolAmount0);
        _transferIfPositive(token1, protocolFeeRecipient, protocolAmount1);
        _transferIfPositive(token0, recipient, recipientAmount0);
        _transferIfPositive(token1, recipient, recipientAmount1);

        emit FeesClaimed(
            token, msg.sender, token0, token1, recipientAmount0, recipientAmount1, protocolAmount0, protocolAmount1
        );
    }

    /**
     * @notice Returns the factory record for a launch token.
     */
    function getLaunchedToken(address token) public view returns (IPonsLaunchFactory.LaunchedToken memory) {
        if (factory == address(0)) revert TokenNotFound();
        return IPonsLaunchFactory(factory).getLaunchedToken(token);
    }

    /**
     * @notice Returns the wallet currently entitled to the creator fee share.
     * Falls back to the launch deployer while no redirect is set.
     */
    function currentFeeRecipient(address token) public view returns (address) {
        IPonsLaunchFactory.LaunchedToken memory launched = getLaunchedToken(token);
        if (!launched.exists) revert TokenNotFound();
        address recipient = feeRedirects[token];
        return recipient == address(0) ? launched.deployer : recipient;
    }

    /**
     * @notice Redirects the creator share for one token. Once assigned away,
     * control follows the current recipient, so the original deployer cannot
     * reclaim fees they handed off.
     * @dev Callable by the current fee recipient, the owner (community
     * takeovers), or the factory during launch setup.
     */
    function setFeeRedirect(address token, address newFeeWallet) external {
        address recipient = currentFeeRecipient(token);
        if (msg.sender != recipient && msg.sender != owner() && msg.sender != factory) {
            revert NotAuthorized();
        }
        _setFeeRedirect(token, newFeeWallet);
    }

    /**
     * @notice Grants or revokes fee collection permission.
     */
    function setFeeCollector(address collector, bool enabled) external onlyOwner {
        if (collector == address(0)) revert ZeroAddress();
        feeCollectors[collector] = enabled;
        emit FeeCollectorUpdated(collector, enabled);
    }

    /**
     * @notice Changes the protocol fee recipient.
     */
    function setProtocolFeeRecipient(address recipient) external onlyOwner {
        if (recipient == address(0)) revert ZeroAddress();
        protocolFeeRecipient = recipient;
        emit ProtocolFeeRecipientUpdated(recipient);
    }

    /**
     * @notice Changes the fee share snapshotted by future token launches.
     */
    function setProtocolFeeShare(uint256 share) external onlyOwner {
        if (share > MAX_PROTOCOL_FEE_SHARE) revert InvalidProtocolFee();
        protocolFeeShare = share;
        emit ProtocolFeeUpdated(share);
    }

    /**
     * @notice Returns the number of tokens indexed for one deployer.
     */
    function deployerTokenCount(address deployer_) external view returns (uint256) {
        return deployerTokens[deployer_].length;
    }

    /**
     * @notice Returns the number of tokens indexed for one fee recipient.
     */
    function feeRecipientTokenCount(address recipient_) external view returns (uint256) {
        return feeRecipientTokens[recipient_].length;
    }

    /**
     * @notice Stores a creator-fee redirect and indexes the recipient for Profile reads.
     */
    function _setFeeRedirect(address token, address newFeeWallet) private {
        address previousFeeWallet = feeRedirects[token];
        if (previousFeeWallet == newFeeWallet) return;

        uint256 previousIndexPlusOne = _feeRecipientTokenIndexes[token];
        if (previousFeeWallet != address(0) && previousIndexPlusOne != 0) {
            address[] storage previousTokens = feeRecipientTokens[previousFeeWallet];
            uint256 previousIndex = previousIndexPlusOne - 1;
            uint256 lastIndex = previousTokens.length - 1;
            if (previousIndex != lastIndex) {
                address movedToken = previousTokens[lastIndex];
                previousTokens[previousIndex] = movedToken;
                _feeRecipientTokenIndexes[movedToken] = previousIndex + 1;
            }
            previousTokens.pop();
            delete _feeRecipientTokenIndexes[token];
        }

        feeRedirects[token] = newFeeWallet;
        if (newFeeWallet != address(0)) {
            feeRecipientTokens[newFeeWallet].push(token);
            _feeRecipientTokenIndexes[token] = feeRecipientTokens[newFeeWallet].length;
        }
        emit FeeRedirectUpdated(token, newFeeWallet);
    }

    function _transferIfPositive(address token, address recipient, uint256 amount) private {
        if (amount != 0) IERC20(token).safeTransfer(recipient, amount);
    }

    /**
     * @notice Restricts UUPS implementation upgrades to the owner.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
