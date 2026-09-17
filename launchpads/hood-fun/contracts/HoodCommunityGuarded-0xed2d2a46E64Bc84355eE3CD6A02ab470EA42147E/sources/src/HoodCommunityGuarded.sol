// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {HoodCommunityRewards} from "./HoodCommunity.sol";

/// @dev Guarded launchpad surface. Same launchpad the whole platform uses
///      (`0x8c52…66f6`) — this factory is just a whitelisted CALLER of the
///      already-deployed `createTokenForGuarded` + `buyFor`. NO launchpad
///      redeploy: the coin is minted by the same launchpad, emits the same
///      `TokenCreated`, and shows on Axiom/GMGN/Codex like any hood launch.
interface IGuardedLaunchpad {
    function createTokenForGuarded(
        address creator,
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        uint256 minTokensOut,
        bytes32 salt,
        uint16 tradeFeeBps,
        uint256 totalSupply_,
        bool antiSnipe,
        bool maxWallet
    ) external payable returns (address token);

    function buyFor(address token, address recipient, uint256 minTokensOut) external payable;

    /// This factory's accrued platform-fee share (pull-based, keyed by msg.sender).
    function claimPlatformFees() external;

    // curve tuple: (virtualEth, virtualTokens, realEth, realTokens, creator,
    // createdAtBlock, graduated, migrated, tradeFeeBps)
    function curves(address token)
        external
        view
        returns (uint128, uint128, uint128, uint128, address, uint48, bool, bool, uint16);

    function predictTokenAddress(
        address caller,
        bytes32 salt,
        string calldata name,
        string calldata symbol,
        uint256 totalSupply_
    ) external view returns (address);

    // config tuple: (virtualEthSeed, creationFee, defaultTradeFeeBps, migrationFee,
    // migrationFeeBps, guardBlocks, guardMaxWalletBps, creatorFeeShareBps, vanityEnforced)
    function config()
        external
        view
        returns (uint128, uint64, uint16, uint64, uint16, uint16, uint16, uint16, bool);
}

/// @title HoodCommunityGuarded
/// @notice A SECOND, additive community factory. Identical to HoodCommunityFactory
///         — same `HoodCommunityRewards` vault, same keeper `publisher`, same
///         `CommunityLaunched` event, so the existing indexer + keeper handle its
///         coins with only the factory list widened — EXCEPT it exposes the two
///         per-coin anti-whale toggles AND does the whole launch + full-curve
///         bundle in ONE transaction (atomic, block-0, no front-run window).
///
///         This exists so partners/bundlers (Proxima) can launch a REAL hood
///         community coin (fees→holders via our vault + our keeper) that is
///         UNCAPPED, and bundle the entire curve across their own wallets in the
///         same tx. It does NOT touch the launchpad, the old factory, the Safe,
///         or any live coin — it's a new whitelisted platform and nothing more.
contract HoodCommunityGuarded is Ownable, ReentrancyGuard {
    IGuardedLaunchpad public immutable launchpad;
    address public immutable weth;
    address public immutable implementation;

    /// @notice Keeper allowed to publish reward roots on every clone (the SAME
    ///         keeper as the original factory — set it here too so our existing
    ///         distribution keeper is authorized on these coins with no changes).
    address public publisher;

    /// @notice Who may call `launchCommunityGuarded`. This factory can mint UNCAPPED
    ///         coins (maxWallet=false → one wallet can hold the whole curve), which is
    ///         the exact thing the default cap prevents — so it is NOT public. Only
    ///         owner-approved launchers (Proxima, and anyone the Safe explicitly adds)
    ///         can use it. The owner is the Safe.
    mapping(address launcher => bool) public approvedLauncher;

    mapping(address token => address) public rewardsOf; // token → its rewards clone
    address[] public allCommunityTokens;

    event CommunityLaunched(address indexed token, address indexed rewards, address indexed launcher);
    event PublisherSet(address publisher);
    event LauncherSet(address indexed launcher, bool approved);

    error ZeroAddress();
    error LengthMismatch();
    error InsufficientValue();
    error RefundFailed();
    error NotApprovedLauncher();

    constructor(address launchpad_, address weth_, address owner_, address publisher_) Ownable(owner_) {
        if (launchpad_ == address(0) || weth_ == address(0) || publisher_ == address(0)) revert ZeroAddress();
        launchpad = IGuardedLaunchpad(launchpad_);
        weth = weth_;
        publisher = publisher_;
        implementation = address(new HoodCommunityRewards());
    }

    function setPublisher(address publisher_) external onlyOwner {
        if (publisher_ == address(0)) revert ZeroAddress();
        publisher = publisher_;
        emit PublisherSet(publisher_);
    }

    /// @notice Owner (Safe) grants/revokes who may launch through this factory.
    function setLauncher(address launcher, bool approved) external onlyOwner {
        approvedLauncher[launcher] = approved;
        emit LauncherSet(launcher, approved);
    }

    /// @notice Owner rescue. If this factory is whitelisted with a platform-fee
    ///         share, that share accrues to it on the launchpad (pull-based) — this
    ///         pulls it, then sweeps ALL ETH here to `to`. Also recovers any ETH
    ///         ever stuck on the factory. The factory holds no user funds between
    ///         launches (each launch sweeps its own leftover back to the launcher),
    ///         so this can only move protocol-side platform fees + stray ETH.
    function sweep(address to) external onlyOwner nonReentrant {
        if (to == address(0)) revert ZeroAddress();
        try launchpad.claimPlatformFees() {} catch {} // no-op if nothing accrued
        uint256 bal = address(this).balance;
        if (bal > 0) {
            (bool ok,) = to.call{value: bal}("");
            if (!ok) revert RefundFailed();
        }
    }

    /// @notice Accept transient ETH refunds. When a bundle buy overshoots the
    ///         graduation point, the launchpad refunds the excess to the CALLER
    ///         of buyFor — which is this factory. We take it in here and sweep it
    ///         back to the launcher at the end of the launch. The factory holds no
    ///         persistent balance (platform fees accrue pull-side on the launchpad).
    receive() external payable {}

    /// @notice ONE-CALL atomic launch: clone the community vault, mint the coin
    ///         with the two anti-whale toggles you choose, then bundle-buy the
    ///         curve across your wallets — all in this single transaction, so
    ///         there is no block between mint and bundle for anyone to front-run.
    ///
    /// @param salt        grind so `predictToken(salt, name, symbol, totalSupply_)`
    ///                    ends in 0x600d (this factory is the launchpad caller).
    /// @param antiSnipe   first-120s 0.5%/wallet guard. false = off.
    /// @param maxWallet   4%-of-total per-wallet cap. **false = uncapped** — set
    ///                    this false to bundle the whole curve into few wallets.
    /// @param wallets     bundle recipients (your wallets).
    /// @param ethIn       ETH to spend per wallet (curve buy). Sum + creationFee
    ///                    must equal msg.value (any excess is refunded).
    /// @param minOut      per-wallet slippage floor (tokens). 0 = no floor.
    ///
    /// @return token   the launched coin (created BY the launchpad — a normal hood coin)
    /// @return rewards the coin's community rewards vault (its `creator`)
    function launchCommunityGuarded(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        bytes32 salt,
        uint16 tradeFeeBps,
        uint256 totalSupply_,
        bool antiSnipe,
        bool maxWallet,
        address[] calldata wallets,
        uint256[] calldata ethIn,
        uint256[] calldata minOut
    ) external payable nonReentrant returns (address token, address rewards) {
        if (!approvedLauncher[msg.sender]) revert NotApprovedLauncher();
        if (wallets.length != ethIn.length || wallets.length != minOut.length) revert LengthMismatch();

        // clone the per-coin rewards vault (deterministic, unique per caller+salt)
        rewards = Clones.cloneDeterministic(implementation, keccak256(abi.encode(msg.sender, salt)));

        (, uint64 creationFee,,,,,,,) = launchpad.config();
        uint256 fee = uint256(creationFee);

        uint256 bundleTotal;
        for (uint256 i; i < ethIn.length; ++i) bundleTotal += ethIn[i];
        if (msg.value < fee + bundleTotal) revert InsufficientValue();

        // Factory's balance BEFORE this call's value — normally 0. We sweep only
        // what THIS launch leaves over, never any pre-existing balance.
        uint256 baseline = address(this).balance - msg.value;

        // Mint the coin: creator = the rewards vault (→ fees to holders), and the
        // caller's chosen anti-whale toggles. EXACTLY the creation fee is passed so
        // the launchpad never treats leftover value as a dev-buy to the vault.
        token = launchpad.createTokenForGuarded{value: fee}(
            rewards, name, symbol, metadataURI, 0, salt, tradeFeeBps, totalSupply_, antiSnipe, maxWallet
        );

        HoodCommunityRewards(payable(rewards)).initialize(address(launchpad), address(this), token, weth);

        // ATOMIC full-curve bundle — same tx. This factory is the coin's platform,
        // so every buyFor is snipe-guard exempt; with maxWallet=false there is no
        // per-wallet cap, so the whole curve can land across a few wallets and the
        // buy that fills it auto-migrates in this same transaction.
        for (uint256 i; i < wallets.length; ++i) {
            if (ethIn[i] == 0) continue;
            // Stop cleanly once the curve is full: a bundle sized to overshoot
            // graduates mid-loop, after which any further buy reverts
            // AlreadyGraduated. We break and the remaining ETH is swept back to
            // the launcher below — so oversizing the bundle is safe, never a revert.
            (,,,,,, bool graduated,,) = launchpad.curves(token);
            if (graduated) break;
            launchpad.buyFor{value: ethIn[i]}(token, wallets[i], minOut[i]);
        }

        // effects before the final interaction (checks-effects-interactions)
        rewardsOf[token] = rewards;
        allCommunityTokens.push(token);
        emit CommunityLaunched(token, rewards, msg.sender);

        // Sweep everything this launch left over — overpayment PLUS any excess the
        // launchpad refunded here when a bundle buy overshot graduation — back to
        // the launcher. (Leaves any pre-existing balance untouched via `baseline`.)
        uint256 leftover = address(this).balance - baseline;
        if (leftover > 0) {
            (bool ok,) = msg.sender.call{value: leftover}("");
            if (!ok) revert RefundFailed();
        }
    }

    function isCommunity(address token) external view returns (bool) {
        return rewardsOf[token] != address(0);
    }

    function communityCount() external view returns (uint256) {
        return allCommunityTokens.length;
    }

    /// @notice Predict the launched TOKEN address for a salt — grind `salt` until
    ///         this ends in 0x600d, then pass the same salt to launchCommunityGuarded.
    function predictToken(bytes32 salt, string calldata name, string calldata symbol, uint256 totalSupply_)
        external
        view
        returns (address)
    {
        return launchpad.predictTokenAddress(address(this), salt, name, symbol, totalSupply_);
    }

    /// @notice Predict a launch's rewards-clone address for a given caller + salt.
    function predictRewards(address caller, bytes32 salt) external view returns (address) {
        return Clones.predictDeterministicAddress(implementation, keccak256(abi.encode(caller, salt)), address(this));
    }
}
