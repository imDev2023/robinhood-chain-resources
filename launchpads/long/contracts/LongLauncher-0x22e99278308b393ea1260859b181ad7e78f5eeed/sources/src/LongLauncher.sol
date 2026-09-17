// SPDX-License-Identifier: BUSL-1.1
// Copyright (c) 2026 long.xyz. All rights reserved.

/*=====================================================================================================
 *
 *   _       ___    _   _    ____      _          _      _   _   _   _    ____   _   _   _____   ____
 *  | |     / _ \  | \ | |  / ___|    | |        / \    | | | | | \ | |  / ___| | | | | | ____| |  _ \
 *  | |    | | | | |  \| | | |  _     | |       / _ \   | | | | |  \| | | |     | |_| | |  _|   | |_) |
 *  | |___ | |_| | | |\  | | |_| |    | |___   / ___ \  | |_| | | |\  | | |___  |  _  | | |___  |  _ <
 *  |_____| \___/  |_| \_|  \____|    |_____| /_/   \_\  \___/  |_| \_|  \____| |_| |_| |_____| |_| \_\
 *
 *                    T O K E N I Z E D   S T O C K S   / /   O N C H A I N
 *
 *          [ AIRLOCK ROUTER ]------[ 24H TICKER LOCK ]------[ ROBINHOOD CHAIN ]
 *
 *      PRICE
 *        ^         |             |                        /\
 *        |    |   -+-       |   -+-        /\      /\    /  \          /\
 *        |   -+-   |       -+-   |    ____/  \____/  \__/    \________/  \____>
 *        |    |             |
 *        +---------------------------------------------------------------------------------> TIME
 *
 *                                           P L A Y
 *
 *        L            .--------.    .--------.        N   N      GGG
 *        L           /          \__/          \       NN  N     G
 *        L           \          /  \          /       N N N     G  GG
 *        LLLLL        '--------'    '--------'        N  NN      GGG
 *
 *                                  T E R M   G A M E S .
 *
 *====================================================================================================*/

pragma solidity ^0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {IAirlock} from "./interfaces/IAirlock.sol";

/// @title LongLauncher
/// @author @natan_benish
/// @notice Airlock-compatible launch router that reserves normalized token tickers for 24 hours.
contract LongLauncher is Ownable2Step, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @dev Timestamp-based wall-clock duration; independent of Robinhood's ~100 ms block cadence.
    uint48 public constant RESERVATION_DURATION = 24 hours;
    uint256 internal constant DOPPLER_ERC20_V1_TOKEN_DATA_HEAD_SIZE = 11 * 32;
    uint256 internal constant MAX_TICKER_LENGTH = 15;

    IAirlock public immutable AIRLOCK;
    address public immutable TRUSTED_TOKEN_FACTORY;

    struct TickerRecord {
        address token;
        uint48 deployedAt;
        uint48 reservedUntil;
    }

    mapping(bytes32 tickerKey => TickerRecord record) private _records;

    error ZeroAddress();
    error UnsupportedTokenFactory(address supplied, address expected);
    error MalformedTokenData();
    error InvalidTickerLength(uint256 length);
    error InvalidTickerCharacter(uint256 index, bytes1 character);
    error TickerReserved(bytes32 tickerKey, address token, uint48 reservedUntil);
    error DeployedSymbolMismatch(bytes32 submittedKey, bytes32 deployedKey);
    error TimestampOverflow();
    error NativeTransferFailed();
    error OwnershipRenunciationDisabled();

    event LaunchCreated(
        address indexed poolOrHook,
        address indexed asset,
        address indexed numeraire,
        address poolInitializer,
        address launcher,
        bytes32 tickerKey,
        uint48 deployedAt,
        uint48 reservedUntil,
        string normalizedTicker
    );
    event NativeSwept(address indexed recipient, uint256 amount);
    event ERC20Swept(address indexed token, address indexed recipient, uint256 amount);

    constructor(address airlock_, address trustedTokenFactory_, address initialOwner) Ownable(initialOwner) {
        if (airlock_ == address(0) || trustedTokenFactory_ == address(0)) revert ZeroAddress();
        AIRLOCK = IAirlock(airlock_);
        TRUSTED_TOKEN_FACTORY = trustedTokenFactory_;
    }

    receive() external payable {}

    /// @notice Forwards an unchanged Airlock create request after enforcing ticker availability.
    function create(IAirlock.CreateParams calldata data)
        external
        whenNotPaused
        nonReentrant
        returns (address asset, address pool, address governance, address timelock, address migrationPool)
    {
        if (data.tokenFactory != TRUSTED_TOKEN_FACTORY) {
            revert UnsupportedTokenFactory(data.tokenFactory, TRUSTED_TOKEN_FACTORY);
        }

        (bytes32 key, string memory normalizedTicker) = _tickerFromTokenFactoryData(data.tokenFactoryData);
        TickerRecord memory current = _records[key];
        if (block.timestamp < current.reservedUntil) {
            revert TickerReserved(key, current.token, current.reservedUntil);
        }

        (asset, pool, governance, timelock, migrationPool) = AIRLOCK.create(data);

        _registerSuccessfulLaunch(data, asset, pool, key, normalizedTicker, msg.sender);
    }

    function tickerKey(string calldata ticker) external pure returns (bytes32 key) {
        (key,) = _normalizeTicker(bytes(ticker));
    }

    function getTickerRecord(string calldata ticker) external view returns (TickerRecord memory) {
        (bytes32 key,) = _normalizeTicker(bytes(ticker));
        return _records[key];
    }

    function isTickerAvailable(string calldata ticker) external view returns (bool) {
        (bytes32 key,) = _normalizeTicker(bytes(ticker));
        return block.timestamp >= _records[key].reservedUntil;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function sweepNative(address payable recipient, uint256 amount) external onlyOwner nonReentrant {
        if (recipient == address(0)) revert ZeroAddress();
        (bool success,) = recipient.call{value: amount}("");
        if (!success) revert NativeTransferFailed();
        emit NativeSwept(recipient, amount);
    }

    function sweepERC20(address token, address recipient, uint256 amount) external onlyOwner nonReentrant {
        if (token == address(0) || recipient == address(0)) revert ZeroAddress();
        IERC20(token).safeTransfer(recipient, amount);
        emit ERC20Swept(token, recipient, amount);
    }

    function renounceOwnership() public pure override {
        revert OwnershipRenunciationDisabled();
    }

    function _registerSuccessfulLaunch(
        IAirlock.CreateParams calldata data,
        address asset,
        address pool,
        bytes32 key,
        string memory normalizedTicker,
        address launcher
    ) internal {
        (bytes32 deployedKey,) = _normalizeTicker(bytes(IERC20Metadata(asset).symbol()));
        if (deployedKey != key) revert DeployedSymbolMismatch(key, deployedKey);

        uint256 reservedUntil256 = block.timestamp + RESERVATION_DURATION;
        if (reservedUntil256 > type(uint48).max) revert TimestampOverflow();

        uint48 deployedAt = uint48(block.timestamp);
        uint48 reservedUntil = uint48(reservedUntil256);
        _records[key] = TickerRecord({token: asset, deployedAt: deployedAt, reservedUntil: reservedUntil});

        emit LaunchCreated(
            pool,
            asset,
            data.numeraire,
            data.poolInitializer,
            launcher,
            key,
            deployedAt,
            reservedUntil,
            normalizedTicker
        );
    }

    /// @dev The V1 payload is abi.encode(name, symbol, schedules, beneficiaries, scheduleIds,
    /// amounts, tokenURI, maxBalanceLimit, balanceLimitEnd, controller, exclusions).
    function _tickerFromTokenFactoryData(bytes calldata tokenData)
        internal
        pure
        returns (bytes32 key, string memory normalizedTicker)
    {
        if (tokenData.length < DOPPLER_ERC20_V1_TOKEN_DATA_HEAD_SIZE) revert MalformedTokenData();

        uint256 symbolOffset;
        assembly ("memory-safe") {
            symbolOffset := calldataload(add(tokenData.offset, 0x20))
        }

        if (
            symbolOffset < DOPPLER_ERC20_V1_TOKEN_DATA_HEAD_SIZE || symbolOffset & 31 != 0
                || symbolOffset > tokenData.length - 32
        ) {
            revert MalformedTokenData();
        }

        uint256 length;
        assembly ("memory-safe") {
            length := calldataload(add(tokenData.offset, symbolOffset))
        }

        uint256 contentOffset = symbolOffset + 32;
        if (contentOffset > tokenData.length || length > tokenData.length - contentOffset) {
            revert MalformedTokenData();
        }
        if (length == 0 || length > MAX_TICKER_LENGTH) revert InvalidTickerLength(length);

        bytes memory ticker = new bytes(length);
        assembly ("memory-safe") {
            calldatacopy(add(ticker, 0x20), add(tokenData.offset, contentOffset), length)
        }
        return _normalizeTicker(ticker);
    }

    function _normalizeTicker(bytes memory ticker)
        internal
        pure
        returns (bytes32 key, string memory normalizedTicker)
    {
        uint256 length = ticker.length;
        if (length == 0 || length > MAX_TICKER_LENGTH) revert InvalidTickerLength(length);

        for (uint256 i; i < length; ++i) {
            uint8 character = uint8(ticker[i]);
            if (character >= 97 && character <= 122) {
                ticker[i] = bytes1(character - 32);
            } else if (character < 65 || character > 90) {
                revert InvalidTickerCharacter(i, ticker[i]);
            }
        }

        key = keccak256(ticker);
        normalizedTicker = string(ticker);
    }
}
