// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IQuotronReflections} from "./interfaces/IQuotronReflections.sol";
import {QuotronMirror} from "./QuotronMirror.sol";

/// @title Quotron404 — the $QUOTRON token + terminal collection core
/// @notice Custom ERC-404: 4,444 tokens (18 decimals), 1.0 token = 1
/// terminal NFT. Holding whole tokens materializes DARK terminals drawn
/// randomly from the unclaimed id pool; selling below a whole token
/// dissolves the most recent dark terminal back into the pool (the
/// gacha reroll). Burning exactly 1.0 token HARDWIRES a terminal: it
/// leaves token-linked accounting forever and becomes a plain,
/// permanent ERC-721 (the only state that earns reflections).
///
/// ERC-721 marketplace surface lives on the paired QuotronMirror
/// (DN404-style split so ERC-20/ERC-721 selectors never collide).
///
/// The id -> (floor, tier, art) assignment is pre-committed:
/// `assignmentHash` = sha256 of assignment.csv (seed 44440707), pinned
/// in the repo + IPFS. Chain and art cannot disagree.
contract Quotron404 {
    // ── ERC-20 ──────────────────────────────────────────────────────
    string public constant name = "QUOTRONS";
    string public constant symbol = "QUOTRON";
    uint8 public constant decimals = 18;
    uint256 public constant UNIT = 1e18;
    uint256 public constant MAX_ID = 4444;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    // ── terminals ───────────────────────────────────────────────────
    /// @dev id -> owner (dark AND hardwired ids)
    mapping(uint256 => address) internal _ownerOf;
    /// @dev owner -> dark (token-backed) ids
    mapping(address => uint256[]) internal _darkOwned;
    mapping(uint256 => uint256) internal _darkIndex;
    /// @dev owner -> hardwired ids
    mapping(address => uint256[]) internal _hwOwned;
    mapping(uint256 => uint256) internal _hwIndex;

    mapping(uint256 => bool) public isHardwired;
    uint256 public totalHardwired;

    /// @dev exempt addresses (pools, PoolManager, deployer/LP ops) hold
    /// tokens without materializing NFTs.
    mapping(address => bool) public erc721TransferExempt;

    // virtual Fisher-Yates pool over [1..MAX_ID]
    uint256 public poolSize;
    mapping(uint256 => uint256) internal _poolSlot; // 0 => slot i holds id i+1
    uint256 internal _drawNonce;

    event Hardwired(uint256 indexed id, address indexed owner);
    event TerminalMaterialized(uint256 indexed id, address indexed owner);
    event TerminalDissolved(uint256 indexed id, address indexed owner);

    // ── wiring ──────────────────────────────────────────────────────
    address public owner;
    QuotronMirror public mirror;
    IQuotronReflections public reflections;
    string public darkBaseURI;
    string public litBaseURI;
    bool public metadataFrozen;
    address public royaltyReceiver;
    uint96 public constant ROYALTY_BPS = 500; // 5%
    bytes32 public immutable assignmentHash;

    /// @notice Staged launch: while locked, only the owner may move tokens
    /// (and only to/from allowlisted setup addresses). This lets the token,
    /// reflections, hook and all ten pools be deployed, wired, seeded and
    /// verified with zero possibility of early trading, rogue third-party
    /// pools, or OTC price discovery. Unlocking is one-way and IS the
    /// launch: it starts the 6-hour whitelist window.
    bool public transfersLocked = true;
    uint256 public launchedAt;
    mapping(address => bool) public setupAllowed;

    event Launched(uint256 timestamp);
    event SetupAllowed(address indexed who, bool allowed);

    error NotOwner();
    error NotMirror();
    error ZeroAddress();
    error NotTerminalOwner();
    error AlreadyHardwired();
    error MetadataIsFrozen();
    error InsufficientBalance();
    error TransfersAreLocked();
    error AlreadyLaunched();
    error UnauthorizedPoolSettlement();
    error BannedVenue();
    error NotHook();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier onlyMirror() {
        if (msg.sender != address(mirror)) revert NotMirror();
        _;
    }

    constructor(bytes32 assignmentHash_) {
        owner = msg.sender;
        assignmentHash = assignmentHash_;
        poolSize = MAX_ID;
        mirror = new QuotronMirror(address(this));

        // full supply to deployer for LP seeding; deployer is exempt so
        // no terminals materialize from the treasury balance.
        erc721TransferExempt[msg.sender] = true;
        totalSupply = MAX_ID * UNIT;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // ── admin (pre-launch wiring; metadata freezable) ───────────────
    function setReflections(address r) external onlyOwner {
        if (r == address(0)) revert ZeroAddress();
        reflections = IQuotronReflections(r);
    }

    function setExempt(address a, bool exempt) external onlyOwner {
        // exempting an address with dark terminals would strand them;
        // only allow on empty-or-fresh addresses.
        require(_darkOwned[a].length == 0, "has terminals");
        erc721TransferExempt[a] = exempt;
    }

    function setBaseURIs(string calldata dark_, string calldata lit_) external onlyOwner {
        if (metadataFrozen) revert MetadataIsFrozen();
        darkBaseURI = dark_;
        litBaseURI = lit_;
    }

    function freezeMetadata() external onlyOwner {
        metadataFrozen = true;
    }

    function setRoyaltyReceiver(address r) external onlyOwner {
        if (r == address(0)) revert ZeroAddress();
        royaltyReceiver = r;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        owner = newOwner;
    }

    /// @notice Allow an address to move tokens during the locked setup
    /// phase (pool managers, seeders, the hook).
    function setSetupAllowed(address who, bool allowed) external onlyOwner {
        setupAllowed[who] = allowed;
        emit SetupAllowed(who, allowed);
    }

    /// @notice THE LAUNCH. Unlocks transfers for everyone and stamps the
    /// timestamp the floor hook reads for its 6-hour whitelist window.
    /// One-way: there is no re-lock.
    function launch() external onlyOwner {
        if (!transfersLocked) revert AlreadyLaunched();
        transfersLocked = false;
        launchedAt = block.timestamp;
        emit Launched(block.timestamp);
    }

    /// @dev True once trading is open. The hook's fee tiers key off this.
    function isLaunched() external view returns (bool) {
        return !transfersLocked;
    }

    // ── protocol-owned liquidity routing ────────────────────────────
    /// All $QUOTRON trading is locked to the ten hooked floor pools by
    /// construction, so every trade is guaranteed to feed the three
    /// engines the fee carve funds: the STONKBROKER buyback-and-burn,
    /// the locked LP compound, and the reflections engine that pays
    /// hardwired terminals.
    ///
    /// v4 subtlety: every v4 pool (ours or a rogue one) settles through
    /// the same PoolManager singleton, so an address allowlist cannot
    /// tell them apart. Instead the PoolManager is locked by default
    /// and our floor hook grants a one-shot authorization per swap in
    /// beforeSwap. Rogue v4 pools settle without our hook, carry no
    /// authorization, and revert — they cannot even be seeded.
    /// Known non-v4 AMM venues are refused by runtime codehash, which
    /// can only ever target contract archetypes, never people (EOA
    /// hashes are unbannable by construction).
    address public poolManager;
    address public floorHook;
    uint256 private _pmAuthorizations;
    mapping(bytes32 => bool) public bannedVenueCodehash;

    event PoolRoutingConfigured(address poolManager, address floorHook);
    event VenueCodehashBanned(bytes32 indexed codehash, bool banned);

    function configurePoolRouting(address pm, address hook_) external onlyOwner {
        if (pm == address(0) || hook_ == address(0)) revert ZeroAddress();
        poolManager = pm;
        floorHook = hook_;
        emit PoolRoutingConfigured(pm, hook_);
    }

    /// @notice Refuse settlement with a venue archetype (an AMM pair or
    /// pool implementation), identified by runtime codehash.
    function banVenueCodehash(bytes32 ch, bool banned) external onlyOwner {
        // empty / EOA hashes can never be banned: this power cannot be
        // pointed at a person.
        require(ch != bytes32(0) && ch != keccak256(""), "eoa hash");
        bannedVenueCodehash[ch] = banned;
        emit VenueCodehashBanned(ch, banned);
    }

    /// @notice One-shot settlement authorization, granted by the floor
    /// hook at the top of every swap through a registered pool.
    function authorizePoolTransfer() external {
        if (msg.sender != floorHook) revert NotHook();
        unchecked {
            _pmAuthorizations += 1;
        }
    }

    function _checkTransferAllowed(address from, address to) internal {
        if (transfersLocked) {
            if (
                from == owner || to == owner || setupAllowed[from]
                    || setupAllowed[to]
            ) return;
            revert TransfersAreLocked();
        }
        // post-launch: protocol-owned liquidity routing
        address pm = poolManager;
        if (pm != address(0) && (from == pm || to == pm)) {
            // seeding and LP-compound ops contracts bypass with an
            // explicit owner grant; everything else needs the hook's
            // per-swap authorization.
            if (setupAllowed[from] || setupAllowed[to]) return;
            if (_pmAuthorizations == 0) revert UnauthorizedPoolSettlement();
            unchecked {
                _pmAuthorizations -= 1;
            }
            return;
        }
        if (bannedVenueCodehash[from.codehash] || bannedVenueCodehash[to.codehash]) {
            revert BannedVenue();
        }
    }

    // ── ERC-20 surface ──────────────────────────────────────────────
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        if (allowed != type(uint256).max) {
            allowance[from][msg.sender] = allowed - amount;
        }
        _transfer(from, to, amount);
        return true;
    }

    // ── views the app + mirror use ──────────────────────────────────
    function ownedIds(address a) external view returns (uint256[] memory ids) {
        uint256[] storage dark = _darkOwned[a];
        uint256[] storage hw = _hwOwned[a];
        ids = new uint256[](dark.length + hw.length);
        for (uint256 i; i < dark.length; ++i) ids[i] = dark[i];
        for (uint256 i; i < hw.length; ++i) ids[dark.length + i] = hw[i];
    }

    function ownerOfId(uint256 id) public view returns (address) {
        return _ownerOf[id];
    }

    function nftBalanceOf(address a) external view returns (uint256) {
        return _darkOwned[a].length + _hwOwned[a].length;
    }

    function tokenURI(uint256 id) external view returns (string memory) {
        require(_ownerOf[id] != address(0), "unminted");
        string memory base = isHardwired[id] ? litBaseURI : darkBaseURI;
        return string(abi.encodePacked(base, _toString(id), ".json"));
    }

    function royaltyInfo(uint256, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = royaltyReceiver;
        royaltyAmount = (salePrice * ROYALTY_BPS) / 10_000;
    }

    // ── the one-way door ────────────────────────────────────────────
    /// @notice Burn the 1.0 $QUOTRON backing a dark terminal you own.
    /// The terminal leaves token-linked accounting forever and becomes a
    /// permanent, plain ERC-721 — the only state that earns reflections.
    function hardwire(uint256 id) external {
        if (_ownerOf[id] != msg.sender) revert NotTerminalOwner();
        if (isHardwired[id]) revert AlreadyHardwired();
        if (balanceOf[msg.sender] < UNIT) revert InsufficientBalance();

        // burn the backing token
        balanceOf[msg.sender] -= UNIT;
        totalSupply -= UNIT;
        emit Transfer(msg.sender, address(0), UNIT);

        // move id: dark accounting -> hardwired accounting (floor(bal)
        // dropped by exactly 1, so dark count stays consistent without
        // dissolving anything)
        _removeDark(msg.sender, id);
        isHardwired[id] = true;
        totalHardwired += 1;
        _hwIndex[id] = _hwOwned[msg.sender].length;
        _hwOwned[msg.sender].push(id);

        emit Hardwired(id, msg.sender);
        if (address(reflections) != address(0)) {
            reflections.onHardwire(id, msg.sender);
        }
    }

    // ── mirror-driven ERC-721 transfers ─────────────────────────────
    /// @dev Dark id: moves 1.0 token with the specific id (no reroll).
    /// Hardwired id: pure ownership move + reflections checkpoint.
    function mirrorTransfer(address from, address to, uint256 id) external onlyMirror {
        require(_ownerOf[id] == from, "wrong from");
        if (to == address(0)) revert ZeroAddress();
        _checkTransferAllowed(from, to);

        if (isHardwired[id]) {
            _removeHW(from, id);
            _hwIndex[id] = _hwOwned[to].length;
            _hwOwned[to].push(id);
            _ownerOf[id] = to;
            if (address(reflections) != address(0)) {
                reflections.onHardwiredTransfer(id, from, to);
            }
            return;
        }

        // dark: the token moves with the terminal
        if (balanceOf[from] < UNIT) revert InsufficientBalance();
        balanceOf[from] -= UNIT;
        balanceOf[to] += UNIT;
        emit Transfer(from, to, UNIT);

        _removeDark(from, id);
        if (erc721TransferExempt[to]) {
            // terminals dissolve into exempt holders (pools etc.)
            _ownerOf[id] = address(0);
            _returnToPool(id);
            emit TerminalDissolved(id, from);
            mirror.emitTransfer(from, address(0), id);
        } else {
            _darkIndex[id] = _darkOwned[to].length;
            _darkOwned[to].push(id);
            _ownerOf[id] = to;
            // receiver may now be OVER-collateralized only if they had
            // fractional balance crossing a whole unit; sync handles it.
            _syncUp(to);
        }
    }

    // ── internals ───────────────────────────────────────────────────
    function _transfer(address from, address to, uint256 amount) internal {
        if (to == address(0)) revert ZeroAddress();
        _checkTransferAllowed(from, to);
        uint256 fromBal = balanceOf[from];
        if (fromBal < amount) revert InsufficientBalance();
        unchecked {
            balanceOf[from] = fromBal - amount;
        }
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);

        if (!erc721TransferExempt[from]) _syncDown(from);
        if (!erc721TransferExempt[to]) _syncUp(to);
    }

    /// @dev Dissolve most-recent dark terminals until count == floor(bal).
    function _syncDown(address a) internal {
        uint256 target = balanceOf[a] / UNIT;
        uint256[] storage dark = _darkOwned[a];
        uint256 hwCount = _hwOwned[a].length;
        // dark terminals are backed by tokens BEYOND those burned for
        // hardwired ones (hardwired burn already reduced balance), so
        // target applies to dark count directly.
        hwCount; // (hardwired ids are independent of balance by design)
        while (dark.length > target) {
            uint256 id = dark[dark.length - 1];
            _removeDark(a, id);
            _ownerOf[id] = address(0);
            _returnToPool(id);
            emit TerminalDissolved(id, a);
            mirror.emitTransfer(a, address(0), id);
        }
    }

    /// @dev Materialize terminals until count == floor(bal).
    function _syncUp(address a) internal {
        uint256 target = balanceOf[a] / UNIT;
        uint256[] storage dark = _darkOwned[a];
        while (dark.length < target && poolSize > 0) {
            uint256 id = _draw(a);
            _darkIndex[id] = dark.length;
            dark.push(id);
            _ownerOf[id] = a;
            emit TerminalMaterialized(id, a);
            mirror.emitTransfer(address(0), a, id);
        }
    }

    function _draw(address forWhom) internal returns (uint256 id) {
        uint256 i = uint256(
            keccak256(
                abi.encodePacked(block.prevrandao, block.timestamp, forWhom, ++_drawNonce)
            )
        ) % poolSize;
        id = _slotValue(i);
        uint256 last = _slotValue(poolSize - 1);
        _poolSlot[i] = last;
        delete _poolSlot[poolSize - 1];
        poolSize -= 1;
    }

    function _returnToPool(uint256 id) internal {
        _poolSlot[poolSize] = id;
        poolSize += 1;
    }

    function _slotValue(uint256 i) internal view returns (uint256) {
        uint256 v = _poolSlot[i];
        return v == 0 ? i + 1 : v;
    }

    function _removeDark(address a, uint256 id) internal {
        uint256[] storage arr = _darkOwned[a];
        uint256 idx = _darkIndex[id];
        uint256 lastId = arr[arr.length - 1];
        arr[idx] = lastId;
        _darkIndex[lastId] = idx;
        arr.pop();
        delete _darkIndex[id];
    }

    function _removeHW(address a, uint256 id) internal {
        uint256[] storage arr = _hwOwned[a];
        uint256 idx = _hwIndex[id];
        uint256 lastId = arr[arr.length - 1];
        arr[idx] = lastId;
        _hwIndex[lastId] = idx;
        arr.pop();
        delete _hwIndex[id];
    }

    function _toString(uint256 v) internal pure returns (string memory str) {
        if (v == 0) return "0";
        uint256 j = v;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory b = new bytes(len);
        while (v != 0) {
            len -= 1;
            b[len] = bytes1(uint8(48 + (v % 10)));
            v /= 10;
        }
        str = string(b);
    }
}
