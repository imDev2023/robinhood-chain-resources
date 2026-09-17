// SPDX-License-Identifier: BUSL-1.1
// Copyright (c) 2026 long.xyz. All rights reserved.
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {Currency} from "v4-core/src/types/Currency.sol";

import {IDopplerHookInitializer} from "../interfaces/IDopplerHookInitializer.sol";

/// @dev Launched DERC20s expose ERC20Burnable-style burn (burns the caller's balance).
interface IBurnableToken {
    function burn(uint256 value) external;
}

/// @title LongFeeSplitter
/// @author @natan_benish
/// @notice Holds a pool's creator fee-beneficiary slot on the DopplerHookInitializer and,
/// on a permissionless {distribute}, routes claimed LP fees between the original receiver,
/// the community treasury (a TimelockController), and an asset-side burn.
/// @dev Distribution is balance-based: every call splits the contract's ENTIRE holdings of
/// both pool currencies, so donations, dust, and migration residuals always sweep.
/// CREATOR GUARANTEE: the numeraire-side split is IMMUTABLE (20% original receiver / 80%
/// treasury / 0 burn) — governance cannot touch it, {setSplit} only governs the asset
/// side, and {migrateBeneficiary} (which would strip the creator by moving the whole
/// slot) requires the original receiver's standing approval of the exact destination.
/// The asset-side split remains fully governance-tunable, including to creatorBps = 0.
contract LongFeeSplitter is ReentrancyGuard {
    using SafeERC20 for IERC20;
    using PoolIdLibrary for PoolKey;

    struct Split {
        uint16 creatorBps;
        uint16 treasuryBps;
        uint16 burnBps;
    }

    uint256 public constant BPS_DENOMINATOR = 10_000;
    uint256 internal constant WAD = 1e18;

    /// @dev The numeraire-side split is a hard, immutable guarantee to the original
    /// receiver: no setter exists for it. Burning the numeraire is always meaningless
    /// (stock/stable/native token), so its burn share is structurally zero.
    uint16 public constant NUMERAIRE_CREATOR_BPS = 2000;
    uint16 public constant NUMERAIRE_TREASURY_BPS = 8000;
    uint16 public constant NUMERAIRE_BURN_BPS = 0;

    IDopplerHookInitializer public immutable INITIALIZER;
    bytes32 public immutable POOL_ID;
    address public immutable ASSET;
    /// @dev address(0) when the pool's numeraire is native ETH (native sorts as currency0).
    address public immutable NUMERAIRE;
    address public immutable ORIGINAL_RECEIVER;
    address public immutable TIMELOCK;

    Split public assetSplit;

    /// @notice Migration destination pre-approved by the original receiver;
    /// address(0) = none approved.
    address public approvedMigrationDestination;

    error ZeroAddress();
    error NotTimelock(address caller);
    error NotOriginalReceiver(address caller);
    error AssetNotInPool(address asset);
    error InvalidSplit();
    error MigrationNotApproved(address newBeneficiary);
    error BeneficiaryAlreadyHasShares(address newBeneficiary);
    error CannotSweepPoolCurrency(address token);
    error NativeTransferFailed(address to);

    event Distributed(
        address indexed caller,
        uint256 assetToCreator,
        uint256 assetToTreasury,
        uint256 assetBurned,
        uint256 numeraireToCreator,
        uint256 numeraireToTreasury
    );
    event SplitUpdated(Split assetSplit);
    event MigrationApproved(address indexed destination);
    event BeneficiaryMigrated(address indexed newBeneficiary);
    event Swept(address indexed token, address indexed to, uint256 amount);

    modifier onlyTimelock() {
        if (msg.sender != TIMELOCK) revert NotTimelock(msg.sender);
        _;
    }

    constructor(address initializer_, address asset_, address originalReceiver_, address timelock_) {
        if (initializer_ == address(0) || asset_ == address(0) || originalReceiver_ == address(0)
                || timelock_ == address(0)) {
            revert ZeroAddress();
        }

        INITIALIZER = IDopplerHookInitializer(initializer_);
        ASSET = asset_;
        ORIGINAL_RECEIVER = originalReceiver_;
        TIMELOCK = timelock_;

        (address numeraire,,,,, PoolKey memory key,) = IDopplerHookInitializer(initializer_).getState(asset_);
        // The asset may be currency0 OR currency1 depending on address sort order.
        if (Currency.unwrap(key.currency0) != asset_ && Currency.unwrap(key.currency1) != asset_) {
            revert AssetNotInPool(asset_);
        }
        POOL_ID = PoolId.unwrap(key.toId());
        NUMERAIRE = numeraire;

        _setAssetSplit(Split({creatorBps: 2000, treasuryBps: 4000, burnBps: 4000}));
    }

    /// @notice The initializer pays native ETH via a raw call on some pools; without this,
    /// activating community mode on such a pool would brick its fee claims for good.
    receive() external payable {}

    /// @notice Claims this contract's beneficiary share and splits everything it holds.
    /// Callable by anyone. Safe pre-activation (collectFees releases nothing to a
    /// non-beneficiary) and safe when nothing is pending (zero transfers are skipped).
    function distribute() external nonReentrant {
        _distribute();
    }

    /// @notice Retunes the ASSET-side split only. Treasury-governed. The numeraire side
    /// is an immutable creator guarantee (see the contract natspec) and has no setter.
    /// @dev Must sum to exactly 10_000 BPS.
    function setSplit(Split calldata newAssetSplit) external onlyTimelock {
        _setAssetSplit(newAssetSplit);
    }

    /// @notice The original receiver pre-approves (or revokes with address(0)) the exact
    /// destination a governance migration may target. Without a standing approval the
    /// DAO cannot move the beneficiary slot — which would otherwise be a one-proposal
    /// bypass of the immutable numeraire guarantee.
    function approveMigration(address destination) external {
        if (msg.sender != ORIGINAL_RECEIVER) revert NotOriginalReceiver(msg.sender);
        approvedMigrationDestination = destination;
        emit MigrationApproved(destination);
    }

    /// @notice Escape hatch: moves the beneficiary slot to `newBeneficiary` (e.g. a v2
    /// splitter). Requires BOTH the treasury (governance) and the original receiver's
    /// standing approval of this exact destination. Pending fees are paid into this
    /// contract first and immediately flushed under the current split.
    function migrateBeneficiary(address newBeneficiary) external onlyTimelock nonReentrant {
        if (newBeneficiary == address(0)) revert ZeroAddress();
        if (newBeneficiary != approvedMigrationDestination) revert MigrationNotApproved(newBeneficiary);
        // Moving onto an existing beneficiary merges the slots irreversibly.
        if (INITIALIZER.getShares(POOL_ID, newBeneficiary) != 0) {
            revert BeneficiaryAlreadyHasShares(newBeneficiary);
        }

        INITIALIZER.updateBeneficiary(POOL_ID, newBeneficiary);
        _distribute();
        emit BeneficiaryMigrated(newBeneficiary);
    }

    /// @notice Rescues tokens that are not pool currencies (those only ever flow through
    /// {distribute}). `token == address(0)` sweeps stray native — automatically blocked
    /// when the pool's numeraire IS native. Treasury-governed.
    function sweep(address token, address to) external onlyTimelock nonReentrant {
        if (to == address(0)) revert ZeroAddress();
        if (token == ASSET || token == NUMERAIRE) revert CannotSweepPoolCurrency(token);

        uint256 amount = token == address(0) ? address(this).balance : IERC20(token).balanceOf(address(this));
        _pay(token, to, amount);
        emit Swept(token, to, amount);
    }

    // ------------------------------------------------------------ views

    /// @notice This contract's claimable share of already-collected pool fees.
    /// @dev Lower bound: excludes fees still accruing inside the locked v4 positions,
    /// which are only pulled in when collectFees runs.
    function pendingFees() external view returns (uint256 pending0, uint256 pending1) {
        uint256 shares = INITIALIZER.getShares(POOL_ID, address(this));
        pending0 = (INITIALIZER.getCumulatedFees0(POOL_ID) - INITIALIZER.getLastCumulatedFees0(POOL_ID, address(this)))
            * shares / WAD;
        pending1 = (INITIALIZER.getCumulatedFees1(POOL_ID) - INITIALIZER.getLastCumulatedFees1(POOL_ID, address(this)))
            * shares / WAD;
    }

    /// @notice True once the creator has flipped their beneficiary slot to this contract.
    function isActive() external view returns (bool) {
        return INITIALIZER.getShares(POOL_ID, address(this)) != 0;
    }

    /// @notice The immutable numeraire-side split, in the same shape as {assetSplit}.
    function numeraireSplit() public pure returns (Split memory) {
        return Split({
            creatorBps: NUMERAIRE_CREATOR_BPS,
            treasuryBps: NUMERAIRE_TREASURY_BPS,
            burnBps: NUMERAIRE_BURN_BPS
        });
    }

    // ------------------------------------------------------------ internals

    function _setAssetSplit(Split memory newAssetSplit) internal {
        if (uint256(newAssetSplit.creatorBps) + newAssetSplit.treasuryBps + newAssetSplit.burnBps != BPS_DENOMINATOR) {
            revert InvalidSplit();
        }

        assetSplit = newAssetSplit;
        emit SplitUpdated(newAssetSplit);
    }

    function _distribute() internal {
        INITIALIZER.collectFees(POOL_ID);

        (uint256 assetToCreator, uint256 assetToTreasury, uint256 assetBurned) = _splitAndPay(ASSET, assetSplit);
        (uint256 numeraireToCreator, uint256 numeraireToTreasury,) = _splitAndPay(NUMERAIRE, numeraireSplit());

        emit Distributed(
            msg.sender, assetToCreator, assetToTreasury, assetBurned, numeraireToCreator, numeraireToTreasury
        );
    }

    /// @dev Treasury takes the rounding residual so payouts always sum to the full balance.
    function _splitAndPay(address currency, Split memory split)
        internal
        returns (uint256 toCreator, uint256 toTreasury, uint256 burned)
    {
        uint256 balance = currency == address(0) ? address(this).balance : IERC20(currency).balanceOf(address(this));
        if (balance == 0) return (0, 0, 0);

        toCreator = balance * split.creatorBps / BPS_DENOMINATOR;
        burned = balance * split.burnBps / BPS_DENOMINATOR;
        toTreasury = balance - toCreator - burned;

        if (toCreator != 0) _pay(currency, ORIGINAL_RECEIVER, toCreator);
        if (toTreasury != 0) _pay(currency, TIMELOCK, toTreasury);
        // Only the asset side can carry a burn share (never native; enforced in _setSplit).
        if (burned != 0) IBurnableToken(currency).burn(burned);
    }

    function _pay(address currency, address to, uint256 amount) internal {
        if (currency == address(0)) {
            (bool success,) = to.call{value: amount}("");
            if (!success) revert NativeTransferFailed(to);
        } else {
            IERC20(currency).safeTransfer(to, amount);
        }
    }
}
