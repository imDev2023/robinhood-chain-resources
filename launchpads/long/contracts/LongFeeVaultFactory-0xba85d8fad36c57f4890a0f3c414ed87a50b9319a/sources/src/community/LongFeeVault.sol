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

/// @title LongFeeVault
/// @author @natan_benish
/// @notice Holds a pool's creator fee-beneficiary slot on the DopplerHookInitializer and
/// IS the community treasury: a permissionless {distribute} claims accrued LP fees, pays
/// the creator's share, burns the asset's burn share, and RETAINS everything else in the
/// vault. The LONG ops {ADMIN} routes retained funds into community programs (index
/// buys, airdrop distributors, …) through an explicit module registry, and can migrate
/// the whole position to a successor vault.
/// @dev CLAIM-DELTA accounting: each {distribute} splits ONLY what {collectFees} just
/// released (balance deltas measured around the claim). Retained holdings and direct
/// donations are never re-split — donations accumulate 100% untouched.
/// TRUST MODEL (read this): unlike the original LongFeeSplitter generation, this vault
/// carries NO creator guarantees and NO governance. The hardcoded LONG {ADMIN} EOA has
/// total operational power: it can retune BOTH split tables (including creatorBps = 0 on
/// both sides), push ANY held token — retained treasury and pool currencies included —
/// to any pre-registered module, and unilaterally migrate the fee slot plus the entire
/// balance to a new destination. There is no timelock and no second key.
/// Still true from the fee manager's side: activation is a separate creator transaction
/// (`updateBeneficiary` moves the CALLER's slot; no access control; a wrong-wallet call
/// is a silent no-op that still emits the event; merging onto an existing beneficiary is
/// irreversible; payouts may include native ETH via raw call — hence {receive}).
contract LongFeeVault is ReentrancyGuard {
    using SafeERC20 for IERC20;
    using PoolIdLibrary for PoolKey;

    struct Split {
        uint16 creatorBps;
        uint16 vaultBps;
        uint16 burnBps;
    }

    uint256 public constant BPS_DENOMINATOR = 10_000;
    uint256 internal constant WAD = 1e18;

    /// @dev LONG ops key. A constant (not a constructor arg) so the factory surface
    /// stays minimal and the factory's CREATE2 address is a pure function of source.
    address public constant ADMIN = 0x8aa7A1dFA6635AF2979dA4D2bDd51780842e3F99;

    IDopplerHookInitializer public immutable INITIALIZER;
    bytes32 public immutable POOL_ID;
    address public immutable ASSET;
    /// @dev address(0) when the pool's numeraire is native ETH (native sorts as currency0).
    address public immutable NUMERAIRE;
    address public immutable ORIGINAL_RECEIVER;

    /// @notice Asset-side split of each fresh claim; vault share stays in the contract.
    Split public assetSplit;
    /// @notice Numeraire-side split of each fresh claim. burnBps is structurally zero
    /// (stock/stable/native tokens cannot be burned) — enforced at every write.
    Split public numeraireSplit;
    /// @notice Registered destinations {pushToModule} may pay. Admin-curated.
    mapping(address module => bool registered) public isModule;

    error ZeroAddress();
    error NotAdmin(address caller);
    error AssetNotInPool(address asset);
    error InvalidSplit();
    error AlreadyModule(address module);
    error NotModule(address module);
    error ZeroAmount();
    error BeneficiaryAlreadyHasShares(address newBeneficiary);
    error NativeTransferFailed(address to);

    event Distributed(
        address indexed caller,
        uint256 assetToCreator,
        uint256 assetRetained,
        uint256 assetBurned,
        uint256 numeraireToCreator,
        uint256 numeraireRetained
    );
    event SplitsUpdated(Split assetSplit, Split numeraireSplit);
    event ModuleAdded(address indexed module);
    event ModuleRemoved(address indexed module);
    event ModulePushed(address indexed module, address indexed token, uint256 amount);
    event AdminMigrated(address indexed newBeneficiary, uint256 assetHandedOver, uint256 numeraireHandedOver);

    modifier onlyAdmin() {
        if (msg.sender != ADMIN) revert NotAdmin(msg.sender);
        _;
    }

    /// @dev Initial split tables are caller-provided and validated like any retune; the
    /// factory restricts them to its two supported modes (see LongFeeVaultFactory).
    constructor(
        address initializer_,
        address asset_,
        address originalReceiver_,
        Split memory assetSplit_,
        Split memory numeraireSplit_
    ) {
        if (initializer_ == address(0) || asset_ == address(0) || originalReceiver_ == address(0)) {
            revert ZeroAddress();
        }

        INITIALIZER = IDopplerHookInitializer(initializer_);
        ASSET = asset_;
        ORIGINAL_RECEIVER = originalReceiver_;

        (address numeraire,,,,, PoolKey memory key,) = IDopplerHookInitializer(initializer_).getState(asset_);
        // The asset may be currency0 OR currency1 depending on address sort order.
        if (Currency.unwrap(key.currency0) != asset_ && Currency.unwrap(key.currency1) != asset_) {
            revert AssetNotInPool(asset_);
        }
        POOL_ID = PoolId.unwrap(key.toId());
        NUMERAIRE = numeraire;

        _setSplits(assetSplit_, numeraireSplit_);
    }

    /// @notice The initializer pays native ETH via a raw call on some pools; without this,
    /// activating a native-numeraire pool would brick its fee claims for good. Also
    /// accepts direct native donations, which accumulate untouched.
    receive() external payable {}

    /// @notice Claims this vault's beneficiary share and splits ONLY the fresh claim:
    /// creator and burn take their bps floors, the residual is retained in the vault.
    /// Callable by anyone. Safe pre-activation (collectFees releases nothing to a
    /// non-beneficiary) and when nothing is pending (all-zero event, no revert).
    function distribute() external nonReentrant {
        _distribute();
    }

    /// @notice Atomically retunes BOTH split tables. Each must sum to exactly 10_000
    /// bps; the numeraire side's burnBps must be zero. Admin-only — including the
    /// creator share on both sides (no guarantee survives a retune).
    function setSplits(Split calldata newAssetSplit, Split calldata newNumeraireSplit) external onlyAdmin {
        _setSplits(newAssetSplit, newNumeraireSplit);
    }

    /// @notice Registers a destination {pushToModule} may pay (index-buy contract,
    /// airdrop distributor, …). Funds can only ever leave through registered modules
    /// or {adminMigrate}.
    function addModule(address module) external onlyAdmin {
        if (module == address(0)) revert ZeroAddress();
        if (isModule[module]) revert AlreadyModule(module);
        isModule[module] = true;
        emit ModuleAdded(module);
    }

    function removeModule(address module) external onlyAdmin {
        if (!isModule[module]) revert NotModule(module);
        isModule[module] = false;
        emit ModuleRemoved(module);
    }

    /// @notice Pushes `amount` of `token` (address(0) = native) to a REGISTERED module.
    /// `amount == type(uint256).max` pushes the entire current balance. Every push is an
    /// explicit admin transaction — nothing streams automatically. Any held token may be
    /// pushed, pool currencies included (this is also the stray-token rescue path).
    function pushToModule(address module, address token, uint256 amount) external onlyAdmin nonReentrant {
        if (!isModule[module]) revert NotModule(module);
        if (amount == type(uint256).max) amount = _balanceOf(token);
        if (amount == 0) revert ZeroAmount();

        _pay(token, module, amount);
        emit ModulePushed(module, token, amount);
    }

    /// @notice Migrates to a successor: claims what's pending, moves the beneficiary
    /// slot to `newBeneficiary`, and hands over the vault's ENTIRE asset + numeraire
    /// holdings (retained treasury, donations, and the just-claimed pending — nothing
    /// is split on the way out; the successor honors the creator going forward).
    /// @dev Refuses destinations that already hold shares (merges are irreversible on
    /// the fee manager). On native-numeraire pools the destination must accept raw-call
    /// native — it must anyway, or its own future claims would brick. Called on an
    /// inactive vault this degenerates to a balance evacuation.
    function adminMigrate(address newBeneficiary) external onlyAdmin nonReentrant {
        if (newBeneficiary == address(0)) revert ZeroAddress();
        if (INITIALIZER.getShares(POOL_ID, newBeneficiary) != 0) {
            revert BeneficiaryAlreadyHasShares(newBeneficiary);
        }

        INITIALIZER.collectFees(POOL_ID);
        INITIALIZER.updateBeneficiary(POOL_ID, newBeneficiary);

        uint256 assetBalance = _balanceOf(ASSET);
        uint256 numeraireBalance = _balanceOf(NUMERAIRE);
        if (assetBalance != 0) _pay(ASSET, newBeneficiary, assetBalance);
        if (numeraireBalance != 0) _pay(NUMERAIRE, newBeneficiary, numeraireBalance);

        emit AdminMigrated(newBeneficiary, assetBalance, numeraireBalance);
    }

    // ------------------------------------------------------------ views

    /// @notice This vault's claimable share of already-collected pool fees.
    /// @dev Lower bound: excludes fees still accruing inside the locked v4 positions,
    /// which are only pulled in when collectFees runs.
    function pendingFees() external view returns (uint256 pending0, uint256 pending1) {
        uint256 shares = INITIALIZER.getShares(POOL_ID, address(this));
        pending0 = (INITIALIZER.getCumulatedFees0(POOL_ID) - INITIALIZER.getLastCumulatedFees0(POOL_ID, address(this)))
            * shares / WAD;
        pending1 = (INITIALIZER.getCumulatedFees1(POOL_ID) - INITIALIZER.getLastCumulatedFees1(POOL_ID, address(this)))
            * shares / WAD;
    }

    /// @notice True once the creator has flipped their beneficiary slot to this vault.
    function isActive() external view returns (bool) {
        return INITIALIZER.getShares(POOL_ID, address(this)) != 0;
    }

    // ------------------------------------------------------------ internals

    function _setSplits(Split memory newAssetSplit, Split memory newNumeraireSplit) internal {
        if (uint256(newAssetSplit.creatorBps) + newAssetSplit.vaultBps + newAssetSplit.burnBps != BPS_DENOMINATOR) {
            revert InvalidSplit();
        }
        if (
            uint256(newNumeraireSplit.creatorBps) + newNumeraireSplit.vaultBps + newNumeraireSplit.burnBps
                != BPS_DENOMINATOR || newNumeraireSplit.burnBps != 0
        ) {
            revert InvalidSplit();
        }

        assetSplit = newAssetSplit;
        numeraireSplit = newNumeraireSplit;
        emit SplitsUpdated(newAssetSplit, newNumeraireSplit);
    }

    /// @dev Claim-delta core. Order is load-bearing: snapshot both balances, claim,
    /// lock the deltas into locals, and only THEN move anything out — so the native
    /// creator payout can never corrupt the numeraire delta, retained holdings and
    /// donations (which sit inside the snapshots) are never re-split, and the caller
    /// cannot inflate a delta (non-payable function, empty receive can't reenter).
    function _distribute() internal {
        uint256 assetBefore = _balanceOf(ASSET);
        uint256 numeraireBefore = _balanceOf(NUMERAIRE);

        INITIALIZER.collectFees(POOL_ID);

        uint256 assetClaimed = _balanceOf(ASSET) - assetBefore;
        uint256 numeraireClaimed = _balanceOf(NUMERAIRE) - numeraireBefore;

        Split memory assetTable = assetSplit;
        uint256 assetToCreator = assetClaimed * assetTable.creatorBps / BPS_DENOMINATOR;
        uint256 assetBurned = assetClaimed * assetTable.burnBps / BPS_DENOMINATOR;
        uint256 assetRetained = assetClaimed - assetToCreator - assetBurned;

        Split memory numeraireTable = numeraireSplit;
        uint256 numeraireToCreator = numeraireClaimed * numeraireTable.creatorBps / BPS_DENOMINATOR;
        uint256 numeraireRetained = numeraireClaimed - numeraireToCreator;

        if (assetToCreator != 0) _pay(ASSET, ORIGINAL_RECEIVER, assetToCreator);
        if (assetBurned != 0) IBurnableToken(ASSET).burn(assetBurned);
        if (numeraireToCreator != 0) _pay(NUMERAIRE, ORIGINAL_RECEIVER, numeraireToCreator);

        emit Distributed(
            msg.sender, assetToCreator, assetRetained, assetBurned, numeraireToCreator, numeraireRetained
        );
    }

    function _balanceOf(address currency) internal view returns (uint256) {
        return currency == address(0) ? address(this).balance : IERC20(currency).balanceOf(address(this));
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
