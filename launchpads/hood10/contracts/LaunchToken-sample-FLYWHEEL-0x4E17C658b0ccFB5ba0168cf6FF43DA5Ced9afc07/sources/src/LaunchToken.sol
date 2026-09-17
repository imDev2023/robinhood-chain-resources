// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/// @notice The fee engine a token reads its live rate from.
interface IPoolFeeSource {
    function currentFeeRate(bytes32 poolId, address swapper) external view returns (uint256);
}

/// @title LaunchToken
/// @notice A plain, boring, fixed-supply ERC-20. No transfer tax, no owner, no
///         mint path after construction.
///
/// @dev    ERC-2612 permit is included because selling otherwise takes two
///         transactions -- approve Permit2, then swap -- while buying takes
///         one. "I bought in one click and now I cannot sell" is
///         indistinguishable from a honeypot to the person living it, and this
///         token's bytecode is fixed by the factory at deploy, so the choice
///         cannot be revisited later.
///
/// @dev    The tax this token advertises is charged pool-side by the hook, in
///         whatever the pool is quoted in -- it is NOT a fee-on-transfer.
///         That distinction is the whole reason the token is boring: a real
///         transfer tax breaks Uniswap v4's delta accounting, breaks aggregator
///         routing, and follows the token into every other pool it ever lands
///         in. A swap fee follows the pool, which is where it belongs.
///
///         The metadata and tax-scanner selectors below mirror what terminals
///         on this chain already probe (tokenURI / metaURI / contractURI, and
///         buyTaxRate / sellTaxRate), so a launch here indexes correctly on day
///         one instead of showing up as an unlabelled address.
contract LaunchToken is ERC20, ERC20Permit {
    error NotFactory();
    error AlreadyLaunched();
    error NotCreator();
    error MetadataTooLarge();

    event MetadataURIUpdated(string previousURI, string newURI);

    /// @dev The fee engine works in pips (1e6 = 100%), scanners ask in basis
    ///      points (1e4 = 100%).
    uint256 public constant PIPS_PER_BP = 100;

    address public immutable factory;
    address public immutable creator;
    address public immutable hook;
    /// @notice Total swap fee configured at launch, basis points. Advisory: the
    ///         live figure comes from the hook once the pool exists.
    uint24 public immutable taxBps;

    /// @notice v4 pools are ids inside the PoolManager, not standalone contracts.
    bytes32 public poolId;
    uint256 public launchBlock;

    string private _metadataURI;

    /// @dev Bounds what one launch can write. Not a DoS defence -- the creator
    ///      pays their own gas and no other pool is affected -- but a 64x64
    ///      icon inlined as a data URI is ~4KB, so anything past this is a
    ///      mistake rather than an intent.
    uint256 public constant MAX_METADATA_BYTES = 8_192;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory metadataURI_,
        address creator_,
        address hook_,
        uint24 taxBps_,
        uint256 supply_
    ) ERC20(name_, symbol_) ERC20Permit(name_) {
        factory = msg.sender;
        creator = creator_;
        hook = hook_;
        taxBps = taxBps_;
        if (bytes(metadataURI_).length > MAX_METADATA_BYTES) revert MetadataTooLarge();
        _metadataURI = metadataURI_;
        // The entire supply goes to the factory, which locks it into the pool
        // before this transaction ends. Nothing is held back by the protocol.
        _mint(msg.sender, supply_);
    }

    /// @dev Called by the factory in the launch transaction, once.
    function initializePool(bytes32 poolId_) external {
        if (msg.sender != factory) revert NotFactory();
        if (poolId != bytes32(0)) revert AlreadyLaunched();
        poolId = poolId_;
        launchBlock = block.number;
    }

    /// @notice Point the token's metadata somewhere else.
    ///
    /// @dev    Creator-only, and mutable on purpose. The URI is where a launch's
    ///         icon lives, and an icon that cannot be corrected is a permanent
    ///         mistake one bad upload away. The trade-off is real and worth
    ///         stating: anything caching `contractURI` can be shown one image
    ///         and later served another, so a consumer that cares should pin
    ///         what it fetched rather than trust the pointer. Everything that
    ///         governs the money -- supply, fee rate, the locked liquidity --
    ///         is immutable regardless; this changes a picture.
    function setMetadataURI(string calldata newURI) external {
        if (msg.sender != currentCreator()) revert NotCreator();
        if (bytes(newURI).length > MAX_METADATA_BYTES) revert MetadataTooLarge();
        emit MetadataURIUpdated(_metadataURI, newURI);
        _metadataURI = newURI;
    }

    /// @notice Whoever owns this pool's fee stream right now.
    ///
    /// @dev    The protocol supports handing a launch to a new owner
    ///         (`LaunchHook.transferCreator`), and before this the token's own
    ///         `creator` was immutable -- so after a legitimate sale the
    ///         original deployer kept permanent control of the icon the pad
    ///         renders on its board. Metadata follows the fee stream. Falls back
    ///         to the deployer only before the pool exists, when there is no
    ///         handover to follow.
    function currentCreator() public view returns (address) {
        if (poolId == bytes32(0)) return creator;
        try ILaunchHookCreator(hook).creatorOf(poolId) returns (address c) {
            return c == address(0) ? creator : c;
        } catch {
            return creator;
        }
    }

    /// @notice Real burn -- total supply drops, so explorers show supply
    ///         shrinking rather than a growing dead-address holder.
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    // ───────────────── metadata, under every selector in use ─────────────────

    function tokenURI() external view returns (string memory) {
        return _metadataURI;
    }

    function metaURI() external view returns (string memory) {
        return _metadataURI;
    }

    function contractURI() external view returns (string memory) {
        return _metadataURI;
    }

    // ─────────────────────── what tax scanners read ───────────────────────

    /// @dev Before the pool is wired up there is no engine to ask, so the
    ///      configured rate is the only defined answer. After, the engine is
    ///      the only answer -- a stale stored number is worse than none.
    function taxRatePips() public view returns (uint256) {
        if (poolId == bytes32(0)) return uint256(taxBps) * PIPS_PER_BP;
        return IPoolFeeSource(hook).currentFeeRate(poolId, address(0));
    }

    /// @dev Rounded up, so the answer is never less than what is charged.
    function buyTaxRate() external view returns (uint256) {
        return (taxRatePips() + PIPS_PER_BP - 1) / PIPS_PER_BP;
    }

    function sellTaxRate() external view returns (uint256) {
        return (taxRatePips() + PIPS_PER_BP - 1) / PIPS_PER_BP;
    }
}

/// @dev The one thing a launched token needs to ask its hook.
interface ILaunchHookCreator {
    function creatorOf(bytes32 poolId) external view returns (address);
}
