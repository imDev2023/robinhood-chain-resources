// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICommunityLaunchpad {
    function createTokenFor(
        address creator,
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        uint256 minTokensOut,
        bytes32 salt,
        uint16 tradeFeeBps,
        uint256 totalSupply_
    ) external payable returns (address token);

    function buyFor(address token, address recipient, uint256 minTokensOut) external payable;

    function claimCreatorFees(address token) external;

    function creatorFees(address token) external view returns (uint256);

    // config tuple: (virtualEthSeed, creationFee, defaultTradeFeeBps, migrationFee,
    // migrationFeeBps, guardBlocks, guardMaxWalletBps, creatorFeeShareBps, vanityEnforced)
    function config()
        external
        view
        returns (uint128, uint64, uint16, uint64, uint16, uint16, uint16, uint16, bool);
}

interface IWETH9 {
    function withdraw(uint256) external;
    function balanceOf(address) external view returns (uint256);
}

interface ICommunityFactory {
    function publisher() external view returns (address);
}

/// @title HoodCommunityRewards
/// @notice One instance is cloned per COMMUNITY coin and set as that coin's
///         `creator` on the launchpad. Every creator fee the coin earns — the
///         ETH curve fees and the WETH creator-share of the locked Uniswap pool —
///         lands here and is **AUTO-DISTRIBUTED** to the coin's HOLDERS pro-rata.
///         There is NO claiming: the hood.fun keeper harvests the fees, snapshots
///         holders off-chain, and calls `distribute()`, which pays every holder
///         directly and reimburses its own gas out of the pot — so it runs forever
///         with no funding and nobody ever has to claim.
///
///         The token-side burn is UNCHANGED — it still happens in the locker.
///         Only the ETH/WETH creator-fee side is redirected to holders here.
contract HoodCommunityRewards is ReentrancyGuard {
    ICommunityLaunchpad public launchpad;
    address public factory; // its publisher() is the authorized keeper
    address public token;
    IWETH9 public weth;

    uint256 public totalReceived; // all ETH ever harvested
    uint256 public totalDistributed; // all ETH ever paid out to holders
    uint256 public round; // distribution counter

    bool private _init;

    /// @dev Gas cap per holder transfer — enough for an EOA/simple receiver, too
    ///      little for a griefing contract to burn or re-enter. A recipient that
    ///      needs more just gets skipped and rolls to the next round.
    uint256 public constant SEND_GAS = 30_000;
    /// @dev The keeper's gas reimbursement is capped at this share of a batch, so
    ///      a compromised keeper can never siphon the pot disguised as "gas".
    uint256 public constant MAX_GAS_BPS = 1000; // 10%

    event Harvested(uint256 amount, uint256 totalReceived);
    event Distributed(uint256 indexed round, uint256 toHolders, uint256 recipients, uint256 gasReimbursed);
    event Paid(address indexed holder, uint256 amount);
    event Skipped(address indexed holder, uint256 amount); // recipient rejected the ETH

    error AlreadyInitialized();
    error NotPublisher();
    error LengthMismatch();
    error InsufficientBalance();

    /// @dev Called once by the factory right after cloning.
    function initialize(address launchpad_, address factory_, address token_, address weth_) external {
        if (_init) revert AlreadyInitialized();
        _init = true;
        launchpad = ICommunityLaunchpad(launchpad_);
        factory = factory_;
        token = token_;
        weth = IWETH9(weth_);
    }

    /// @notice Accept ETH (creator fees pulled from the launchpad, or unwrapped WETH).
    receive() external payable {}

    /// @notice Pull everything owed to this coin into the pot. Permissionless — the
    ///         keeper (or anyone) can top up. Harvests curve creator fees and
    ///         unwraps any WETH the locker has paid in.
    function harvest() public nonReentrant returns (uint256 gained) {
        return _harvest();
    }

    function _harvest() internal returns (uint256 gained) {
        uint256 before = address(this).balance;
        if (launchpad.creatorFees(token) > 0) {
            launchpad.claimCreatorFees(token); // sends ETH here
        }
        uint256 w = weth.balanceOf(address(this));
        if (w > 0) weth.withdraw(w); // WETH → ETH
        gained = address(this).balance - before;
        if (gained > 0) {
            totalReceived += gained;
            emit Harvested(gained, totalReceived);
        }
    }

    /// @notice Keeper-only: auto-send `amounts[i]` to `holders[i]` — the pro-rata
    ///         shares the keeper computed off-chain from a live holder snapshot.
    ///         Harvests first, so it always pays out fresh fees. A recipient whose
    ///         transfer reverts (a contract that rejects ETH) is skipped and its
    ///         share simply stays in the pot for next round. The keeper's gas is
    ///         reimbursed from the pot (capped at MAX_GAS_BPS of the batch), so the
    ///         distribution funds its own gas and never needs topping up.
    function distribute(address[] calldata holders, uint256[] calldata amounts) external nonReentrant {
        if (msg.sender != ICommunityFactory(factory).publisher()) revert NotPublisher();
        if (holders.length != amounts.length) revert LengthMismatch();
        uint256 gasStart = gasleft();

        _harvest(); // pull any pending fees into the pot first

        uint256 total;
        for (uint256 i; i < amounts.length; ++i) total += amounts[i];
        if (total > address(this).balance) revert InsufficientBalance();

        uint256 paid;
        uint256 recipients;
        for (uint256 i; i < holders.length; ++i) {
            uint256 amt = amounts[i];
            if (amt == 0) continue;
            (bool ok,) = holders[i].call{value: amt, gas: SEND_GAS}("");
            if (ok) {
                paid += amt;
                unchecked {
                    ++recipients;
                }
                emit Paid(holders[i], amt);
            } else {
                emit Skipped(holders[i], amt); // rolls to next round
            }
        }
        totalDistributed += paid;
        unchecked {
            ++round;
        }

        // Reimburse the keeper's gas out of the pot, capped so it can never be an
        // extraction path. +40k covers the reimburse call + trailing opcodes.
        uint256 gasCost = (gasStart - gasleft() + 40_000) * tx.gasprice;
        uint256 cap = (paid * MAX_GAS_BPS) / 10_000;
        if (gasCost > cap) gasCost = cap;
        if (gasCost > address(this).balance) gasCost = address(this).balance;
        if (gasCost > 0) {
            (bool r,) = msg.sender.call{value: gasCost}("");
            r; // best-effort; on failure the ETH just stays in the pot
        }
        emit Distributed(round, paid, recipients, gasCost);
    }

    /// @notice ETH sitting in the pot right now (already-harvested, awaiting the
    ///         next distribution) plus everything still pending on the launchpad —
    ///         i.e. what the next distribution will pay out. Lets the keeper decide
    ///         when the pot is worth a distribution.
    function distributable() external view returns (uint256) {
        return address(this).balance + launchpad.creatorFees(token) + weth.balanceOf(address(this));
    }
}

/// @title HoodCommunityFactory
/// @notice Whitelisted platform that launches COMMUNITY coins on the hood.fun
///         launchpad. For each launch it clones a HoodCommunityRewards, makes the
///         clone the coin's `creator` (so fees flow to holders), and — if the
///         creator wants a first buy — routes the dev-buy to the real launcher
///         (not the clone) via the guard-exempt platform buyFor.
///
///         The owner (Safe) sets the keeper `publisher` that signs reward roots.
contract HoodCommunityFactory is Ownable, ReentrancyGuard {
    ICommunityLaunchpad public immutable launchpad;
    address public immutable weth;
    address public immutable implementation;

    /// @notice Keeper allowed to publish reward roots on every clone.
    address public publisher;

    mapping(address token => address) public rewardsOf; // token → its rewards clone
    address[] public allCommunityTokens;

    event CommunityLaunched(address indexed token, address indexed rewards, address indexed launcher);
    event PublisherSet(address publisher);

    error ZeroAddress();

    constructor(address launchpad_, address weth_, address owner_, address publisher_) Ownable(owner_) {
        if (launchpad_ == address(0) || weth_ == address(0) || publisher_ == address(0)) revert ZeroAddress();
        launchpad = ICommunityLaunchpad(launchpad_);
        weth = weth_;
        publisher = publisher_;
        implementation = address(new HoodCommunityRewards());
    }

    function setPublisher(address publisher_) external onlyOwner {
        if (publisher_ == address(0)) revert ZeroAddress();
        publisher = publisher_;
        emit PublisherSet(publisher_);
    }

    /// @notice Launch a community coin. `salt` must be ground so the token address
    ///         ends in 0x600d (grind against THIS factory's address, since it is
    ///         the launchpad caller). msg.value = creationFee + devBuyEth.
    function launchCommunity(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        bytes32 salt,
        uint16 tradeFeeBps,
        uint256 totalSupply_,
        uint256 devBuyEth,
        uint256 minDevTokensOut
    ) external payable nonReentrant returns (address token, address rewards) {
        // clone the per-coin rewards vault (deterministic, unique per caller+salt)
        rewards = Clones.cloneDeterministic(implementation, keccak256(abi.encode(msg.sender, salt)));

        // Pass EXACTLY the creation fee to the launchpad so it never dev-buys to
        // the clone. (createTokenFor treats any value above the fee as a dev-buy
        // credited to the `creator` — here the clone — which we must avoid.)
        (, uint64 creationFee,,,,,,,) = launchpad.config();
        uint256 fee = uint256(creationFee);
        require(msg.value >= fee + devBuyEth, "insufficient value");

        token = launchpad.createTokenFor{value: fee}(
            rewards, name, symbol, metadataURI, 0, salt, tradeFeeBps, totalSupply_
        );

        HoodCommunityRewards(payable(rewards)).initialize(address(launchpad), address(this), token, weth);

        // optional creator dev-buy — credited to the LAUNCHER, guard-exempt
        if (devBuyEth > 0) {
            launchpad.buyFor{value: devBuyEth}(token, msg.sender, minDevTokensOut);
        }

        // refund any dust the caller overpaid
        uint256 refund = msg.value - fee - devBuyEth;
        if (refund > 0) {
            (bool ok,) = msg.sender.call{value: refund}("");
            require(ok, "refund failed");
        }

        rewardsOf[token] = rewards;
        allCommunityTokens.push(token);
        emit CommunityLaunched(token, rewards, msg.sender);
    }

    function isCommunity(address token) external view returns (bool) {
        return rewardsOf[token] != address(0);
    }

    function communityCount() external view returns (uint256) {
        return allCommunityTokens.length;
    }

    /// @notice Predict a launch's rewards-clone address for a given caller + salt.
    function predictRewards(address caller, bytes32 salt) external view returns (address) {
        return Clones.predictDeterministicAddress(implementation, keccak256(abi.encode(caller, salt)), address(this));
    }
}
