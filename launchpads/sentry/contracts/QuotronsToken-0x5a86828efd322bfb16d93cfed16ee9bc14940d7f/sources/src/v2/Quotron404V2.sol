// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IQuotronReflections} from "../interfaces/IQuotronReflections.sol";
import {QuotronMirrorV2} from "./QuotronMirrorV2.sol";

interface IQuotronLaunchTransferGuard {
    function isTransferRestricted(address account) external view returns (bool);
}

/// @title Quotron404V2
/// @notice Capped ERC-404 core with exact-id migration, explicit emergency
/// pause, immutable post-launch routing, and approval-safe NFT transitions.
/// @dev A disclosed blacklist guardian may freeze addresses. A threshold-2+
/// recovery Safe may forcibly move this contract's QUOTRON or mirror terminals.
contract Quotron404V2 {
    string public constant name = "QUOTRONS";
    string public constant symbol = "QUOTRON";
    uint8 public constant decimals = 18;
    uint256 public constant UNIT = 1e18;
    uint256 public constant MAX_ID = 4444;
    uint256 private constant REMOVED = type(uint256).max;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    mapping(uint256 => address) internal _ownerOf;
    mapping(address => uint256[]) internal _darkOwned;
    mapping(uint256 => uint256) internal _darkIndex;
    mapping(address => uint256[]) internal _hwOwned;
    mapping(uint256 => uint256) internal _hwIndex;

    mapping(uint256 => bool) public isHardwired;
    uint256 public totalHardwired;
    mapping(address => bool) public erc721TransferExempt;

    /// @dev Lazy Fisher-Yates pool. Slot value 0 means id=(slot+1).
    uint256 public poolSize;
    mapping(uint256 => uint256) internal _poolSlot;
    /// @dev 0 means the id remains in its original slot, position+1 otherwise,
    /// REMOVED once assigned. This inverse index permits exact-id migration.
    mapping(uint256 => uint256) internal _poolPosition;
    uint256 internal _drawNonce;

    event Hardwired(uint256 indexed id, address indexed owner);
    event TerminalMaterialized(uint256 indexed id, address indexed owner);
    event TerminalDissolved(uint256 indexed id, address indexed owner);
    event MigratedDark(uint256 indexed id, address indexed owner);
    event MigratedHardwired(uint256 indexed id, address indexed owner);
    event MigratedFractional(address indexed owner, uint256 amount);

    address public owner;
    QuotronMirrorV2 public immutable mirror;
    IQuotronReflections public reflections;
    string public darkBaseURI;
    string public litBaseURI;
    bool public metadataFrozen;
    address public royaltyReceiver;
    uint96 public constant ROYALTY_BPS = 500;
    bytes32 public immutable assignmentHash;

    bool public transfersLocked = true;
    bool public paused;
    uint256 public launchedAt;
    mapping(address => bool) public setupAllowed;
    uint256 public setupAllowedCount;

    address public migrationOperator;
    address public migrationReserve;
    bool public migrationConfigured;
    address public blacklistGuardian;
    address public recoveryAdmin;
    bool public emergencyControlsConfigured;
    mapping(address => bool) public blacklisted;

    address public poolManager;
    address public floorHook;
    address public canonicalRouter;
    /// @dev Hook authorizations are direction- and amount-bound and may only
    /// be consumed in the transaction that created them. This prevents
    /// ERC-6909 claim settlement from banking permissions for a rogue pool.
    bytes32 private constant PM_SEND_AUTHORIZATION_SLOT = keccak256("quotrons.v2.pool-manager.send.authorization");
    bytes32 private constant PM_RECEIVE_AUTHORIZATION_SLOT =
        keccak256("quotrons.v2.pool-manager.receive.authorization");
    mapping(bytes32 => bool) public bannedVenueCodehash;

    event Launched(uint256 timestamp);
    event Paused(bool paused);
    event SetupAllowed(address indexed account, bool allowed);
    event MigrationConfigured(address indexed operator, address indexed reserve);
    event EmergencyControlsConfigured(address indexed blacklistGuardian, address indexed recoveryAdmin);
    event BlacklistUpdated(address indexed account, bool blacklisted, address indexed caller);
    event QuotronRecovered(address indexed from, address indexed to, uint256 amount);
    event TerminalRecovered(address indexed from, address indexed to, uint256 indexed id, bool hardwired);
    event PoolRoutingConfigured(address indexed poolManager, address indexed hook, address indexed router);
    event VenueCodehashBanned(bytes32 indexed codehash, bool banned);

    error NotOwner();
    error NotMirror();
    error NotMigrationOperator();
    error NotBlacklistAuthority();
    error NotRecoveryAdmin();
    error UnsafeRecoveryAdmin();
    error ZeroAddress();
    error NotTerminalOwner();
    error AlreadyHardwired();
    error MetadataIsFrozen();
    error InsufficientBalance();
    error TransfersAreLocked();
    error ContractPaused();
    error AlreadyLaunched();
    error UnauthorizedPoolSettlement();
    error BannedVenue();
    error NotHook();
    error NotRouter();
    error UnconsumedPoolAuthorization();
    error AlreadyConfigured();
    error InvalidId();
    error IdUnavailable();
    error ExemptRecipient();
    error MigrationInvariant();
    error FractionalAmount();
    error BlacklistedAccount();
    error ProtectedAccount();
    error InvalidRecovery();
    error LaunchTransferRestricted();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier onlyMirror() {
        if (msg.sender != address(mirror)) revert NotMirror();
        _;
    }

    modifier onlyMigrationOperator() {
        if (msg.sender != migrationOperator) revert NotMigrationOperator();
        _;
    }

    constructor(bytes32 assignmentHash_) {
        owner = msg.sender;
        assignmentHash = assignmentHash_;
        poolSize = MAX_ID;
        mirror = new QuotronMirrorV2(address(this));

        erc721TransferExempt[msg.sender] = true;
        totalSupply = MAX_ID * UNIT;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // ── pre-launch wiring / admin ───────────────────────────────────

    function setReflections(address reflections_) external onlyOwner {
        if (!transfersLocked || address(reflections) != address(0)) {
            revert AlreadyConfigured();
        }
        if (reflections_ == address(0)) revert ZeroAddress();
        reflections = IQuotronReflections(reflections_);
    }

    function configureMigration(address operator, address reserve) external onlyOwner {
        if (!transfersLocked || migrationConfigured) revert AlreadyConfigured();
        if (operator == address(0) || reserve == address(0)) revert ZeroAddress();
        if (_darkOwned[reserve].length != 0) revert MigrationInvariant();

        migrationOperator = operator;
        migrationReserve = reserve;
        migrationConfigured = true;
        erc721TransferExempt[reserve] = true;
        emit MigrationConfigured(operator, reserve);
    }

    function configureEmergencyControls(address guardian, address recoveryAdmin_) external onlyOwner {
        if (!transfersLocked || emergencyControlsConfigured) revert AlreadyConfigured();
        if (guardian == address(0) || recoveryAdmin_ == address(0)) revert ZeroAddress();
        if (recoveryAdmin_.code.length == 0) revert UnsafeRecoveryAdmin();
        blacklistGuardian = guardian;
        recoveryAdmin = recoveryAdmin_;
        emergencyControlsConfigured = true;
        emit EmergencyControlsConfigured(guardian, recoveryAdmin_);
    }

    function setBlacklisted(address account, bool blocked) external {
        if (!emergencyControlsConfigured) revert AlreadyConfigured();
        if (_isBlacklistProtected(account)) revert ProtectedAccount();
        if (msg.sender == blacklistGuardian) {
            if (!blocked) revert NotBlacklistAuthority();
        } else {
            _requireRecoveryAdmin();
        }
        blacklisted[account] = blocked;
        emit BlacklistUpdated(account, blocked, msg.sender);
    }

    function setExempt(address account, bool exempt) external onlyOwner {
        if (!transfersLocked) revert AlreadyLaunched();
        if (account == address(0)) revert ZeroAddress();
        if (_darkOwned[account].length != 0) revert MigrationInvariant();
        erc721TransferExempt[account] = exempt;
    }

    function setSetupAllowed(address account, bool allowed) external onlyOwner {
        if (!transfersLocked) revert AlreadyLaunched();
        if (account == address(0)) revert ZeroAddress();
        bool current = setupAllowed[account];
        if (current == allowed) return;
        setupAllowed[account] = allowed;
        if (allowed) {
            ++setupAllowedCount;
        } else {
            --setupAllowedCount;
        }
        emit SetupAllowed(account, allowed);
    }

    function setBaseURIs(string calldata dark_, string calldata lit_) external onlyOwner {
        if (metadataFrozen) revert MetadataIsFrozen();
        darkBaseURI = dark_;
        litBaseURI = lit_;
    }

    function freezeMetadata() external onlyOwner {
        metadataFrozen = true;
    }

    function setRoyaltyReceiver(address receiver) external onlyOwner {
        if (!transfersLocked) revert AlreadyLaunched();
        if (receiver == address(0)) revert ZeroAddress();
        royaltyReceiver = receiver;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        owner = newOwner;
    }

    function configurePoolRouting(address manager, address hook_, address router_) external onlyOwner {
        if (!transfersLocked || poolManager != address(0)) revert AlreadyConfigured();
        if (manager == address(0) || hook_ == address(0) || router_ == address(0)) revert ZeroAddress();
        poolManager = manager;
        floorHook = hook_;
        canonicalRouter = router_;
        emit PoolRoutingConfigured(manager, hook_, router_);
    }

    function launch() external onlyOwner {
        if (!transfersLocked) revert AlreadyLaunched();
        if (
            !migrationConfigured || !emergencyControlsConfigured || address(reflections) == address(0)
                || poolManager == address(0) || floorHook == address(0) || canonicalRouter == address(0)
                || royaltyReceiver == address(0) || mirror.getTransferValidator() == address(0)
                || setupAllowedCount != 0 || !_safeThresholdAtLeastTwo(recoveryAdmin)
        ) {
            revert MigrationInvariant();
        }
        transfersLocked = false;
        launchedAt = block.timestamp;
        emit Launched(block.timestamp);
    }

    function setPaused(bool paused_) external onlyOwner {
        paused = paused_;
        emit Paused(paused_);
    }

    function isLaunched() external view returns (bool) {
        return !transfersLocked;
    }

    function banVenueCodehash(bytes32 codehash, bool banned) external onlyOwner {
        require(codehash != bytes32(0) && codehash != keccak256(""), "eoa hash");
        bannedVenueCodehash[codehash] = banned;
        emit VenueCodehashBanned(codehash, banned);
    }

    // ── exact-id migration ─────────────────────────────────────────

    function migrateDark(address to, uint256 id) external onlyMigrationOperator {
        if (to == address(0)) revert ZeroAddress();
        _requireNotBlacklisted(to);
        if (erc721TransferExempt[to]) revert ExemptRecipient();
        _requirePortfolioInvariant(to);

        _spendReserve(UNIT, to);
        if (balanceOf[to] / UNIT != _darkOwned[to].length + 1) {
            revert MigrationInvariant();
        }

        _takeSpecificId(id);
        _darkIndex[id] = _darkOwned[to].length;
        _darkOwned[to].push(id);
        _ownerOf[id] = to;
        emit TerminalMaterialized(id, to);
        emit MigratedDark(id, to);
        mirror.emitTransfer(address(0), to, id);
    }

    function migrateHardwired(address to, uint256 id) external onlyMigrationOperator {
        if (to == address(0)) revert ZeroAddress();
        _requireNotBlacklisted(to);
        _takeSpecificId(id);

        address reserve = migrationReserve;
        uint256 reserveBalance = balanceOf[reserve];
        if (reserveBalance < UNIT) revert InsufficientBalance();
        unchecked {
            balanceOf[reserve] = reserveBalance - UNIT;
            totalSupply -= UNIT;
        }
        emit Transfer(reserve, address(0), UNIT);

        isHardwired[id] = true;
        totalHardwired += 1;
        _ownerOf[id] = to;
        _hwIndex[id] = _hwOwned[to].length;
        _hwOwned[to].push(id);
        emit Hardwired(id, to);
        emit MigratedHardwired(id, to);
        mirror.emitTransfer(address(0), to, id);

        reflections.onHardwire(id, to);
    }

    function migrateFractional(address to, uint256 amount) external onlyMigrationOperator {
        if (to == address(0)) revert ZeroAddress();
        _requireNotBlacklisted(to);
        if (erc721TransferExempt[to]) revert ExemptRecipient();
        if (amount == 0 || amount >= UNIT) revert FractionalAmount();
        _requirePortfolioInvariant(to);

        uint256 beforeWhole = balanceOf[to] / UNIT;
        _spendReserve(amount, to);
        if (balanceOf[to] / UNIT != beforeWhole) revert MigrationInvariant();
        emit MigratedFractional(to, amount);
    }

    function _spendReserve(uint256 amount, address to) internal {
        address reserve = migrationReserve;
        uint256 reserveBalance = balanceOf[reserve];
        if (reserveBalance < amount) revert InsufficientBalance();
        unchecked {
            balanceOf[reserve] = reserveBalance - amount;
        }
        balanceOf[to] += amount;
        emit Transfer(reserve, to, amount);
    }

    // ── protocol-owned pool routing ─────────────────────────────────

    function authorizePoolTransfer(int128 quotronDelta) external {
        if (msg.sender != floorHook) revert NotHook();
        if (quotronDelta > 0) {
            uint256 authorized = _transientLoad(PM_SEND_AUTHORIZATION_SLOT);
            _transientStore(PM_SEND_AUTHORIZATION_SLOT, authorized + uint256(uint128(quotronDelta)));
        } else if (quotronDelta < 0) {
            uint256 authorized = _transientLoad(PM_RECEIVE_AUTHORIZATION_SLOT);
            _transientStore(PM_RECEIVE_AUTHORIZATION_SLOT, authorized + uint256(uint128(-quotronDelta)));
        }
    }

    /// @notice Canonical-router end-of-callback assertion. Any nonzero value
    /// means a swap attempted claim settlement or otherwise failed to perform
    /// the exact ERC-20 settlement authorized by the registered hook.
    function assertPoolTransferAuthorizationConsumed() external view {
        if (msg.sender != canonicalRouter) revert NotRouter();
        if (_transientLoad(PM_SEND_AUTHORIZATION_SLOT) != 0 || _transientLoad(PM_RECEIVE_AUTHORIZATION_SLOT) != 0) {
            revert UnconsumedPoolAuthorization();
        }
    }

    function adminTransferQuotron(address from, address to, uint256 amount) external {
        _requireRecoveryAdmin();
        if (amount == 0) revert InvalidRecovery();
        _requireRecoveryAccounts(from, to);

        uint256 fromBalance = balanceOf[from];
        if (fromBalance < amount) revert InsufficientBalance();
        unchecked {
            balanceOf[from] = fromBalance - amount;
        }
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);

        if (!erc721TransferExempt[from]) _syncDown(from);
        _syncUp(to);
        emit QuotronRecovered(from, to, amount);
    }

    function adminTransferTerminal(address from, address to, uint256 id) external {
        _requireRecoveryAdmin();
        _requireRecoveryAccounts(from, to);
        if (_ownerOf[id] != from) revert NotTerminalOwner();

        bool hardwired = isHardwired[id];
        if (hardwired) {
            _removeHW(from, id);
            _hwIndex[id] = _hwOwned[to].length;
            _hwOwned[to].push(id);
            _ownerOf[id] = to;
            reflections.onHardwiredTransfer(id, from, to);
        } else {
            if (balanceOf[from] < UNIT) revert InsufficientBalance();
            _requirePortfolioInvariant(from);
            _requirePortfolioInvariant(to);
            balanceOf[from] -= UNIT;
            balanceOf[to] += UNIT;
            emit Transfer(from, to, UNIT);

            _removeDark(from, id);
            _darkIndex[id] = _darkOwned[to].length;
            _darkOwned[to].push(id);
            _ownerOf[id] = to;
        }

        mirror.emitTransfer(from, to, id);
        emit TerminalRecovered(from, to, id, hardwired);
    }

    function _checkTransferAllowed(address from, address to, uint256 amount) internal {
        _requireNotBlacklisted(from);
        _requireNotBlacklisted(to);
        _requireNotBlacklisted(msg.sender);

        if (transfersLocked) {
            if (
                from == owner || to == owner || setupAllowed[from] || setupAllowed[to]
                    || msg.sender == migrationOperator
            ) {
                return;
            }
            revert TransfersAreLocked();
        }

        if (paused && !setupAllowed[from] && !setupAllowed[to]) {
            revert ContractPaused();
        }

        if (
            bannedVenueCodehash[from.codehash] || bannedVenueCodehash[to.codehash]
                || bannedVenueCodehash[msg.sender.codehash]
        ) {
            revert BannedVenue();
        }

        address manager = poolManager;
        if (from != manager && to != manager && IQuotronLaunchTransferGuard(floorHook).isTransferRestricted(from)) {
            revert LaunchTransferRestricted();
        }
        if (from == manager) {
            if (setupAllowed[from] || setupAllowed[to]) return;
            uint256 authorized = _transientLoad(PM_SEND_AUTHORIZATION_SLOT);
            if (amount > authorized) revert UnauthorizedPoolSettlement();
            _transientStore(PM_SEND_AUTHORIZATION_SLOT, authorized - amount);
        } else if (to == manager) {
            if (setupAllowed[from] || setupAllowed[to]) return;
            if (msg.sender != canonicalRouter) revert NotRouter();
            uint256 authorized = _transientLoad(PM_RECEIVE_AUTHORIZATION_SLOT);
            if (amount > authorized) revert UnauthorizedPoolSettlement();
            _transientStore(PM_RECEIVE_AUTHORIZATION_SLOT, authorized - amount);
        }
    }

    function _transientLoad(bytes32 slot) internal view returns (uint256 value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    function _transientStore(bytes32 slot, uint256 value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    // ── ERC-20 surface ──────────────────────────────────────────────

    function approve(address spender, uint256 amount) external returns (bool) {
        _requireNotBlacklisted(msg.sender);
        _requireNotBlacklisted(spender);
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
            emit Approval(from, msg.sender, allowance[from][msg.sender]);
        }
        _transfer(from, to, amount);
        return true;
    }

    // ── terminal views ──────────────────────────────────────────────

    function ownedIds(address account) external view returns (uint256[] memory ids) {
        uint256[] storage dark = _darkOwned[account];
        uint256[] storage hardwired = _hwOwned[account];
        ids = new uint256[](dark.length + hardwired.length);
        for (uint256 i; i < dark.length; ++i) {
            ids[i] = dark[i];
        }
        for (uint256 i; i < hardwired.length; ++i) {
            ids[dark.length + i] = hardwired[i];
        }
    }

    function darkOwned(address account) external view returns (uint256[] memory) {
        return _darkOwned[account];
    }

    function hardwiredOwned(address account) external view returns (uint256[] memory) {
        return _hwOwned[account];
    }

    function ownerOfId(uint256 id) public view returns (address) {
        return _ownerOf[id];
    }

    function nftBalanceOf(address account) external view returns (uint256) {
        return _darkOwned[account].length + _hwOwned[account].length;
    }

    function isIdAvailable(uint256 id) public view returns (bool) {
        if (id == 0 || id > MAX_ID || _poolPosition[id] == REMOVED) return false;
        uint256 position = _positionOf(id);
        return position < poolSize && _slotValue(position) == id;
    }

    function economicUnits() external view returns (uint256) {
        return totalSupply + totalHardwired * UNIT;
    }

    function tokenURI(uint256 id) external view returns (string memory) {
        require(_ownerOf[id] != address(0), "unminted");
        string memory base = isHardwired[id] ? litBaseURI : darkBaseURI;
        return string(abi.encodePacked(base, _toString(id), ".json"));
    }

    function royaltyInfo(uint256, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount) {
        receiver = royaltyReceiver;
        royaltyAmount = (salePrice * ROYALTY_BPS) / 10_000;
    }

    // ── hardwire + mirror transfers ─────────────────────────────────

    function hardwire(uint256 id) external {
        if (transfersLocked) revert TransfersAreLocked();
        if (paused) revert ContractPaused();
        _requireNotBlacklisted(msg.sender);
        if (IQuotronLaunchTransferGuard(floorHook).isTransferRestricted(msg.sender)) {
            revert LaunchTransferRestricted();
        }
        if (_ownerOf[id] != msg.sender) revert NotTerminalOwner();
        if (isHardwired[id]) revert AlreadyHardwired();
        if (balanceOf[msg.sender] < UNIT) revert InsufficientBalance();

        balanceOf[msg.sender] -= UNIT;
        totalSupply -= UNIT;
        emit Transfer(msg.sender, address(0), UNIT);

        _removeDark(msg.sender, id);
        isHardwired[id] = true;
        totalHardwired += 1;
        _hwIndex[id] = _hwOwned[msg.sender].length;
        _hwOwned[msg.sender].push(id);

        mirror.clearApproval(msg.sender, id);
        emit Hardwired(id, msg.sender);
        reflections.onHardwire(id, msg.sender);
    }

    function mirrorTransfer(address from, address to, uint256 id) external onlyMirror {
        if (_ownerOf[id] != from) revert NotTerminalOwner();
        if (to == address(0)) revert ZeroAddress();
        _checkTransferAllowed(from, to, 0);

        if (isHardwired[id]) {
            _removeHW(from, id);
            _hwIndex[id] = _hwOwned[to].length;
            _hwOwned[to].push(id);
            _ownerOf[id] = to;
            reflections.onHardwiredTransfer(id, from, to);
            return;
        }

        if (erc721TransferExempt[to]) revert ExemptRecipient();
        if (balanceOf[from] < UNIT) revert InsufficientBalance();
        _requirePortfolioInvariant(from);
        _requirePortfolioInvariant(to);

        balanceOf[from] -= UNIT;
        balanceOf[to] += UNIT;
        emit Transfer(from, to, UNIT);

        _removeDark(from, id);
        _darkIndex[id] = _darkOwned[to].length;
        _darkOwned[to].push(id);
        _ownerOf[id] = to;
    }

    // ── ERC-404 synchronization ─────────────────────────────────────

    function _transfer(address from, address to, uint256 amount) internal {
        if (to == address(0)) revert ZeroAddress();
        _checkTransferAllowed(from, to, amount);
        uint256 fromBalance = balanceOf[from];
        if (fromBalance < amount) revert InsufficientBalance();
        unchecked {
            balanceOf[from] = fromBalance - amount;
        }
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);

        if (!erc721TransferExempt[from]) _syncDown(from);
        if (!erc721TransferExempt[to]) _syncUp(to);
    }

    function _syncDown(address account) internal {
        uint256 target = balanceOf[account] / UNIT;
        uint256[] storage dark = _darkOwned[account];
        while (dark.length > target) {
            uint256 id = dark[dark.length - 1];
            _removeDark(account, id);
            _ownerOf[id] = address(0);
            _returnToPool(id);
            emit TerminalDissolved(id, account);
            mirror.emitTransfer(account, address(0), id);
        }
    }

    function _syncUp(address account) internal {
        uint256 target = balanceOf[account] / UNIT;
        uint256[] storage dark = _darkOwned[account];
        while (dark.length < target && poolSize > 0) {
            uint256 id = _draw(account);
            _darkIndex[id] = dark.length;
            dark.push(id);
            _ownerOf[id] = account;
            emit TerminalMaterialized(id, account);
            mirror.emitTransfer(address(0), account, id);
        }
    }

    // ── exact-removable id pool ─────────────────────────────────────

    function _draw(address account) internal returns (uint256 id) {
        uint256 position = uint256(
            keccak256(abi.encodePacked(block.prevrandao, block.timestamp, block.number, account, ++_drawNonce))
        ) % poolSize;
        id = _slotValue(position);
        _removePoolPosition(position, id);
    }

    function _takeSpecificId(uint256 id) internal {
        if (id == 0 || id > MAX_ID) revert InvalidId();
        if (!isIdAvailable(id)) revert IdUnavailable();
        _removePoolPosition(_positionOf(id), id);
    }

    function _removePoolPosition(uint256 position, uint256 id) internal {
        uint256 lastPosition = poolSize - 1;
        uint256 lastId = _slotValue(lastPosition);

        if (position != lastPosition) {
            if (lastId == position + 1) {
                delete _poolSlot[position];
            } else {
                _poolSlot[position] = lastId;
            }
            _poolPosition[lastId] = position + 1;
        }

        delete _poolSlot[lastPosition];
        _poolPosition[id] = REMOVED;
        poolSize = lastPosition;
    }

    function _returnToPool(uint256 id) internal {
        if (_poolPosition[id] != REMOVED) revert MigrationInvariant();
        uint256 position = poolSize;
        _poolSlot[position] = id;
        _poolPosition[id] = position + 1;
        poolSize = position + 1;
    }

    function _positionOf(uint256 id) internal view returns (uint256) {
        uint256 encoded = _poolPosition[id];
        if (encoded == REMOVED) revert IdUnavailable();
        return encoded == 0 ? id - 1 : encoded - 1;
    }

    function _slotValue(uint256 position) internal view returns (uint256) {
        uint256 value = _poolSlot[position];
        return value == 0 ? position + 1 : value;
    }

    // ── array helpers ───────────────────────────────────────────────

    function _requirePortfolioInvariant(address account) internal view {
        if (erc721TransferExempt[account]) revert ExemptRecipient();
        if (_darkOwned[account].length != balanceOf[account] / UNIT) {
            revert MigrationInvariant();
        }
    }

    function isProtectedAccount(address account) external view returns (bool) {
        return _isBlacklistProtected(account);
    }

    function _requireRecoveryAdmin() internal view {
        if (msg.sender != recoveryAdmin) revert NotRecoveryAdmin();
        if (!_safeThresholdAtLeastTwo(msg.sender)) revert UnsafeRecoveryAdmin();
    }

    function _safeThresholdAtLeastTwo(address account) internal view returns (bool) {
        if (account.code.length == 0) return false;
        (bool ok, bytes memory result) = account.staticcall(abi.encodeWithSignature("getThreshold()"));
        return ok && result.length >= 32 && abi.decode(result, (uint256)) >= 2;
    }

    function _requireNotBlacklisted(address account) internal view {
        if (account != address(0) && blacklisted[account]) revert BlacklistedAccount();
    }

    function _requireRecoveryAccounts(address from, address to) internal view {
        if (from == address(0) || to == address(0)) revert ZeroAddress();
        if (from == to || _isProtocolAccount(from) || _isProtocolAccount(to)) revert InvalidRecovery();
        if (erc721TransferExempt[to]) revert ExemptRecipient();
    }

    function _isBlacklistProtected(address account) internal view returns (bool) {
        return account == address(0) || account == owner || account == blacklistGuardian || account == recoveryAdmin
            || _isProtocolAccount(account);
    }

    function _isProtocolAccount(address account) internal view returns (bool) {
        return account == address(this) || account == address(mirror) || account == address(reflections)
            || account == migrationOperator || account == migrationReserve || account == poolManager
            || account == floorHook || account == canonicalRouter || account == royaltyReceiver;
    }

    function _removeDark(address account, uint256 id) internal {
        uint256[] storage ids = _darkOwned[account];
        uint256 index = _darkIndex[id];
        uint256 lastId = ids[ids.length - 1];
        ids[index] = lastId;
        _darkIndex[lastId] = index;
        ids.pop();
        delete _darkIndex[id];
    }

    function _removeHW(address account, uint256 id) internal {
        uint256[] storage ids = _hwOwned[account];
        uint256 index = _hwIndex[id];
        uint256 lastId = ids[ids.length - 1];
        ids[index] = lastId;
        _hwIndex[lastId] = index;
        ids.pop();
        delete _hwIndex[id];
    }

    function _toString(uint256 value) internal pure returns (string memory result) {
        if (value == 0) return "0";
        uint256 cursor = value;
        uint256 length;
        while (cursor != 0) {
            ++length;
            cursor /= 10;
        }
        bytes memory buffer = new bytes(length);
        while (value != 0) {
            --length;
            buffer[length] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }
        result = string(buffer);
    }
}
