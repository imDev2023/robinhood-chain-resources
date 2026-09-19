// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IPositionManager} from "@uniswap/v4-periphery/src/interfaces/IPositionManager.sol";
import {Actions} from "@uniswap/v4-periphery/src/libraries/Actions.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";

/// @notice Non-upgradeable custody for Coinbarrel Advanced v4 positions.
/// @dev The only PositionManager action available is a zero-liquidity
/// decrease used to realize fees. There is no owner, transfer, approval,
/// arbitrary call, nonzero decrease, or upgrade path.
contract PermanentV4PositionCustody is IERC721Receiver {
    IPositionManager public immutable positionManager;
    address public immutable weth;
    address public immutable feeHandler;

    mapping(uint256 positionId => address token) public positionTokens;

    event PositionSecured(address indexed token, uint256 indexed positionId);
    event FeesHarvested(address indexed token, uint256 indexed positionId, uint256 wethAmount, uint256 tokensBurned);

    error ZeroAddress();
    error NotFeeHandler();
    error NotPositionManager();
    error InvalidPositionId();
    error PositionNotCustodied();
    error PositionAlreadyRegistered();
    error PositionNotRegistered();

    constructor(address positionManager_, address weth_, address feeHandler_) {
        if (positionManager_ == address(0) || weth_ == address(0) || feeHandler_ == address(0)) revert ZeroAddress();
        positionManager = IPositionManager(positionManager_);
        weth = weth_;
        feeHandler = feeHandler_;
    }

    modifier onlyFeeHandler() {
        if (msg.sender != feeHandler) revert NotFeeHandler();
        _;
    }

    function onERC721Received(address, address, uint256, bytes calldata) external view returns (bytes4) {
        if (msg.sender != address(positionManager)) revert NotPositionManager();
        return IERC721Receiver.onERC721Received.selector;
    }

    function register(address token, uint256 positionId) external onlyFeeHandler {
        if (token == address(0)) revert ZeroAddress();
        if (positionId == 0) revert InvalidPositionId();
        if (positionTokens[positionId] != address(0)) revert PositionAlreadyRegistered();
        if (IERC721(address(positionManager)).ownerOf(positionId) != address(this)) revert PositionNotCustodied();
        positionTokens[positionId] = token;
        emit PositionSecured(token, positionId);
    }

    function collect(address token, uint256 positionId)
        external
        onlyFeeHandler
        returns (uint256 wethAmount, uint256 tokensBurned)
    {
        if (positionTokens[positionId] != token) revert PositionNotRegistered();

        uint256 nativeBefore = feeHandler.balance;
        uint256 tokenBefore = IERC20(token).balanceOf(feeHandler);

        bytes memory actions = abi.encodePacked(uint8(Actions.DECREASE_LIQUIDITY), uint8(Actions.TAKE_PAIR));
        bytes[] memory params = new bytes[](2);
        params[0] = abi.encode(positionId, uint256(0), uint128(0), uint128(0), bytes(""));
        // Assets land at the stable vault proxy so LaunchTokenAdvanced's
        // launch-window exemption and all existing accounting stay intact.
        params[1] = abi.encode(Currency.wrap(address(0)), Currency.wrap(token), feeHandler);
        positionManager.modifyLiquidities(abi.encode(actions, params), block.timestamp);

        wethAmount = feeHandler.balance - nativeBefore;
        tokensBurned = IERC20(token).balanceOf(feeHandler) - tokenBefore;
        emit FeesHarvested(token, positionId, wethAmount, tokensBurned);
    }
}
