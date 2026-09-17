// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ILegacyQuotron {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function ownerOfId(uint256 id) external view returns (address);
    function isHardwired(uint256 id) external view returns (bool);
    function erc721TransferExempt(address account) external view returns (bool);
}

interface ILegacyMirror {
    function transferFrom(address from, address to, uint256 id) external;
    function getApproved(uint256 id) external view returns (address);
    function isApprovedForAll(address account, address operator) external view returns (bool);
}

interface ILegacyReflections {
    function claim(uint256[] calldata ids) external;
    function attributesOf(uint256 id) external view returns (uint8, uint8);
    function floorStocks(uint256 index) external view returns (address);
    function paxg() external view returns (address);
}

interface IQuotronV2MigrationTarget {
    function UNIT() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function migrationReserve() external view returns (address);
    function migrateDark(address to, uint256 id) external;
    function migrateHardwired(address to, uint256 id) external;
    function migrateFractional(address to, uint256 amount) external;
    function ownerOfId(uint256 id) external view returns (address);
    function isHardwired(uint256 id) external view returns (bool);
}

interface IQuotronReflectionsV2Legacy {
    function creditLegacy(uint256 id, address token, uint256 amount) external;
}

interface IERC20Migration {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

/// @notice Permanent receiver for fractional V1 tokens. It intentionally has
/// no call or withdrawal surface. V1 must mark it ERC-721-exempt before the
/// migration opens.
contract QuotronLegacyTokenSink {
    address public immutable legacyToken;

    constructor(address legacyToken_) {
        legacyToken = legacyToken_;
    }
}

/// @title QuotronMigrator
/// @notice Block-pinned, Merkle-authorized V1 -> V2 asset sink. Dark terminals
/// surrender the exact V1 NFT plus its backing token; hardwired terminals
/// surrender the NFT and carry any unclaimed V1 rewards into V2; fractional
/// balances move to a permanently locked exempt sink.
contract QuotronMigrator {
    uint8 public constant KIND_DARK = 1;
    uint8 public constant KIND_HARDWIRED = 2;
    uint8 public constant KIND_FRACTIONAL = 3;
    uint8 public constant KIND_RESTITUTION_DARK = 4;
    bytes32 public constant LEAF_DOMAIN = keccak256("QUOTRONS_V2_MIGRATION_V1_BLOCK_PINNED");
    address public constant INCIDENT_ATTACKER = 0xB53CcF301CF2E2283265810372a0915Defb7e53d;
    address public constant INCIDENT_OPERATOR = 0x2001a402E8803c1C92317c080326f1c80aA74532;
    address public constant INCIDENT_POISON_SEED = 0x122778523DF4ddf5189218B2bAbffCb3bc351bbC;

    address public owner;
    ILegacyQuotron public immutable legacy;
    ILegacyMirror public immutable legacyMirror;
    ILegacyReflections public immutable legacyReflections;
    IQuotronV2MigrationTarget public immutable v2;
    IQuotronReflectionsV2Legacy public immutable v2Reflections;
    QuotronLegacyTokenSink public immutable fractionalSink;
    uint256 public immutable snapshotBlock;
    bytes32 public immutable snapshotRoot;
    uint256 public immutable distributionCap;

    struct IdClaimAssignment {
        bytes32 leaf;
        address snapshotAccount;
        address beneficiary;
        uint256 v2Id;
        uint8 kind;
        bool followsToken;
    }

    struct DistributionClaim {
        uint8 kind;
        address account;
        uint256 v1Id;
        uint256 v2Id;
        uint256 amount;
        bytes32[] proof;
    }

    mapping(bytes32 => bool) public usedLeaf;
    mapping(uint256 => IdClaimAssignment) public idClaimAssignment;
    bool public paused;
    bool public distributionFinalized;
    uint256 public totalDistributed;
    uint256 private _lock = 1;

    event IdMigrated(uint8 indexed kind, address indexed account, uint256 indexed v1Id, uint256 v2Id);
    event FractionalMigrated(address indexed account, uint256 amount);
    event RestitutionClaimed(address indexed account, uint256 indexed originalId, uint256 indexed replacementId);
    event LegacyRewardMigrated(uint256 indexed id, address indexed token, uint256 amount);
    event LegacyRewardDeferred(uint256 indexed id);
    event IdClaimAssigned(
        uint256 indexed v1Id, address indexed snapshotAccount, address indexed beneficiary, bytes32 leaf
    );
    event IdClaimTransferred(uint256 indexed v1Id, address indexed previousBeneficiary, address indexed newBeneficiary);
    event IdClaimFollowsToken(uint256 indexed v1Id, address indexed snapshotAccount, address indexed currentOwner);
    event Paused(bool paused);
    event GenesisDistributed(
        uint8 indexed kind, address indexed account, uint256 indexed v1Id, uint256 v2Id, uint256 reserveSpent
    );
    event DistributionFinalized(uint256 totalDistributed);

    error NotOwner();
    error Paused_();
    error Reentrancy();
    error InvalidKind();
    error InvalidProof();
    error LeafAlreadyUsed();
    error WrongOwner();
    error WrongTerminalState();
    error WrongBeneficiary();
    error LegacyConfigurationUnsafe();
    error TransferFailed();
    error InvalidAmount();
    error ZeroAddress();
    error ClaimAlreadyAssigned();
    error ClaimNotAssigned();
    error ClaimAlreadyFollowsToken();
    error IncidentAddress();
    error UnsafeLegacyApproval();
    error DistributionClosed();
    error DistributionCapExceeded();
    error DistributionIncomplete();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier nonReentrant() {
        if (_lock != 1) revert Reentrancy();
        _lock = 2;
        _;
        _lock = 1;
    }

    modifier whenNotPaused() {
        if (paused) revert Paused_();
        _;
    }

    modifier whenDistributionOpen() {
        if (distributionFinalized) revert DistributionClosed();
        _;
    }

    constructor(
        address legacy_,
        address legacyMirror_,
        address legacyReflections_,
        address v2_,
        address v2Reflections_,
        uint256 snapshotBlock_,
        bytes32 snapshotRoot_,
        uint256 distributionCap_
    ) {
        if (
            legacy_ == address(0) || legacyMirror_ == address(0) || legacyReflections_ == address(0)
                || v2_ == address(0) || v2Reflections_ == address(0)
        ) {
            revert ZeroAddress();
        }
        if (snapshotBlock_ == 0 || snapshotRoot_ == bytes32(0) || distributionCap_ == 0) {
            revert InvalidProof();
        }

        owner = msg.sender;
        legacy = ILegacyQuotron(legacy_);
        legacyMirror = ILegacyMirror(legacyMirror_);
        legacyReflections = ILegacyReflections(legacyReflections_);
        v2 = IQuotronV2MigrationTarget(v2_);
        v2Reflections = IQuotronReflectionsV2Legacy(v2Reflections_);
        fractionalSink = new QuotronLegacyTokenSink(legacy_);
        snapshotBlock = snapshotBlock_;
        snapshotRoot = snapshotRoot_;
        distributionCap = distributionCap_;
    }

    // ── user migration ──────────────────────────────────────────────

    /// @notice Owner-operated, proof-checked zero-action distribution. Every
    /// destination and allocation is fixed by the immutable snapshot root.
    /// Batches are atomic: one invalid claim reverts the entire batch.
    function distributeBatch(DistributionClaim[] calldata claims)
        external
        onlyOwner
        nonReentrant
        whenNotPaused
        whenDistributionOpen
    {
        uint256 length = claims.length;
        if (length == 0) revert InvalidAmount();
        for (uint256 i; i < length; ++i) {
            _distribute(claims[i]);
        }
    }

    /// @notice Permanently closes every remaining migration claim after the
    /// committed reserve has been fully distributed.
    function finalizeDistribution() external onlyOwner whenDistributionOpen {
        if (totalDistributed != distributionCap) revert DistributionIncomplete();
        address reserve = v2.migrationReserve();
        if (reserve == address(0) || v2.balanceOf(reserve) != 0) revert DistributionIncomplete();
        distributionFinalized = true;
        emit DistributionFinalized(totalDistributed);
    }

    /// @notice Irrevocably assigns a snapshot terminal claim to its current
    /// V1 owner after a voluntary secondary transfer. The snapshot holder is
    /// the only account that can initialize the assignment.
    function assignIdClaim(uint8 kind, uint256 v1Id, uint256 v2Id, address beneficiary, bytes32[] calldata proof)
        external
        whenNotPaused
        whenDistributionOpen
    {
        if (kind != KIND_DARK && kind != KIND_HARDWIRED) revert InvalidKind();
        if (beneficiary == address(0)) revert ZeroAddress();
        if (_isIncidentAddress(beneficiary)) revert IncidentAddress();
        if (legacy.ownerOfId(v1Id) != beneficiary) revert WrongOwner();
        _requireSafeApprovals(v1Id, beneficiary);
        if ((kind == KIND_HARDWIRED) != legacy.isHardwired(v1Id)) {
            revert WrongTerminalState();
        }

        bytes32 leaf = leafFor(kind, msg.sender, v1Id, v2Id, _kindAmount(kind));
        if (usedLeaf[leaf]) revert LeafAlreadyUsed();
        if (!_verify(leaf, proof)) revert InvalidProof();
        if (idClaimAssignment[v1Id].leaf != bytes32(0)) {
            revert ClaimAlreadyAssigned();
        }

        idClaimAssignment[v1Id] = IdClaimAssignment({
            leaf: leaf,
            snapshotAccount: msg.sender,
            beneficiary: beneficiary,
            v2Id: v2Id,
            kind: kind,
            followsToken: false
        });
        emit IdClaimAssigned(v1Id, msg.sender, beneficiary, leaf);
    }

    /// @notice Opts a snapshot claim into bearer mode so the migration right
    /// follows the V1 terminal through future secondary-market sales. This is
    /// irreversible and should only be used when the holder deliberately wants
    /// the right to travel with the NFT.
    function assignIdClaimToToken(uint8 kind, uint256 v1Id, uint256 v2Id, bytes32[] calldata proof)
        external
        whenNotPaused
        whenDistributionOpen
    {
        if (kind != KIND_DARK && kind != KIND_HARDWIRED) revert InvalidKind();
        address currentOwner = legacy.ownerOfId(v1Id);
        if (currentOwner == address(0)) revert WrongOwner();
        if (_isIncidentAddress(currentOwner)) revert IncidentAddress();
        _requireSafeApprovals(v1Id, currentOwner);
        if ((kind == KIND_HARDWIRED) != legacy.isHardwired(v1Id)) {
            revert WrongTerminalState();
        }

        bytes32 leaf = leafFor(kind, msg.sender, v1Id, v2Id, _kindAmount(kind));
        if (usedLeaf[leaf]) revert LeafAlreadyUsed();
        if (!_verify(leaf, proof)) revert InvalidProof();
        if (idClaimAssignment[v1Id].leaf != bytes32(0)) {
            revert ClaimAlreadyAssigned();
        }

        idClaimAssignment[v1Id] = IdClaimAssignment({
            leaf: leaf,
            snapshotAccount: msg.sender,
            beneficiary: currentOwner,
            v2Id: v2Id,
            kind: kind,
            followsToken: true
        });
        emit IdClaimAssigned(v1Id, msg.sender, currentOwner, leaf);
        emit IdClaimFollowsToken(v1Id, msg.sender, currentOwner);
    }

    /// @notice Irreversibly converts a direct claim assignment into bearer
    /// mode. The assigned beneficiary must still own the V1 terminal.
    function makeIdClaimFollowToken(uint256 v1Id) external whenNotPaused whenDistributionOpen {
        IdClaimAssignment storage assignment = idClaimAssignment[v1Id];
        if (assignment.leaf == bytes32(0)) revert ClaimNotAssigned();
        if (assignment.followsToken) revert ClaimAlreadyFollowsToken();
        if (assignment.beneficiary != msg.sender) revert WrongBeneficiary();
        if (usedLeaf[assignment.leaf]) revert LeafAlreadyUsed();
        if (legacy.ownerOfId(v1Id) != msg.sender) revert WrongOwner();
        if (_isIncidentAddress(msg.sender)) revert IncidentAddress();
        _requireSafeApprovals(v1Id, msg.sender);
        if ((assignment.kind == KIND_HARDWIRED) != legacy.isHardwired(v1Id)) {
            revert WrongTerminalState();
        }

        assignment.followsToken = true;
        emit IdClaimFollowsToken(v1Id, assignment.snapshotAccount, msg.sender);
    }

    /// @notice Passes an already-assigned migration right to the terminal's
    /// new current owner. A thief cannot call this because only the existing
    /// claim beneficiary is authorized.
    function transferIdClaim(uint256 v1Id, address newBeneficiary) external whenNotPaused whenDistributionOpen {
        if (newBeneficiary == address(0)) revert ZeroAddress();
        if (_isIncidentAddress(newBeneficiary)) revert IncidentAddress();
        IdClaimAssignment storage assignment = idClaimAssignment[v1Id];
        if (assignment.leaf == bytes32(0)) revert ClaimNotAssigned();
        if (assignment.followsToken) revert ClaimAlreadyFollowsToken();
        if (assignment.beneficiary != msg.sender) revert WrongBeneficiary();
        if (usedLeaf[assignment.leaf]) revert LeafAlreadyUsed();
        if (legacy.ownerOfId(v1Id) != newBeneficiary) revert WrongOwner();
        _requireSafeApprovals(v1Id, newBeneficiary);
        if ((assignment.kind == KIND_HARDWIRED) != legacy.isHardwired(v1Id)) {
            revert WrongTerminalState();
        }

        address previous = assignment.beneficiary;
        assignment.beneficiary = newBeneficiary;
        emit IdClaimTransferred(v1Id, previous, newBeneficiary);
    }

    /// @notice Pull a snapshot-authorized dark or hardwired V1 terminal and
    /// assign the committed V2 id. By default only the snapshot wallet may
    /// migrate. A different current owner requires an explicit on-chain claim
    /// assignment from the snapshot holder.
    function migrateId(uint8 kind, address snapshotAccount, uint256 v1Id, uint256 v2Id, bytes32[] calldata proof)
        external
        nonReentrant
        whenNotPaused
        whenDistributionOpen
    {
        if (kind != KIND_DARK && kind != KIND_HARDWIRED) revert InvalidKind();
        address beneficiary = _idClaimBeneficiary(kind, snapshotAccount, v1Id, v2Id);
        if (msg.sender != beneficiary) revert WrongBeneficiary();
        _consumeLeaf(kind, snapshotAccount, v1Id, v2Id, _kindAmount(kind), proof);

        if (legacy.ownerOfId(v1Id) != beneficiary) revert WrongOwner();
        bool hardwired = legacy.isHardwired(v1Id);
        if ((kind == KIND_HARDWIRED) != hardwired) revert WrongTerminalState();

        legacyMirror.transferFrom(beneficiary, address(this), v1Id);
        _completeDepositedId(kind, beneficiary, v1Id, v2Id);
    }

    /// @notice Completes a terminal that was accidentally transferred to this
    /// contract without calling migrateId. The snapshot wallet must submit
    /// its proof; no arbitrary beneficiary is accepted.
    function completeDepositedId(
        uint8 kind,
        address snapshotAccount,
        uint256 v1Id,
        uint256 v2Id,
        bytes32[] calldata proof
    ) external nonReentrant whenNotPaused whenDistributionOpen {
        if (kind != KIND_DARK && kind != KIND_HARDWIRED) revert InvalidKind();
        address beneficiary = _idClaimBeneficiary(kind, snapshotAccount, v1Id, v2Id);
        if (msg.sender != beneficiary) revert WrongBeneficiary();
        _consumeLeaf(kind, snapshotAccount, v1Id, v2Id, _kindAmount(kind), proof);
        _completeDepositedId(kind, beneficiary, v1Id, v2Id);
    }

    function migrateFractional(uint256 amount, bytes32[] calldata proof)
        external
        nonReentrant
        whenNotPaused
        whenDistributionOpen
    {
        uint256 unit = v2.UNIT();
        if (amount == 0 || amount >= unit) revert InvalidAmount();
        _consumeLeaf(KIND_FRACTIONAL, msg.sender, 0, 0, amount, proof);
        _recordDistribution(amount);

        if (!legacy.erc721TransferExempt(address(fractionalSink))) {
            revert LegacyConfigurationUnsafe();
        }
        uint256 beforeBalance = legacy.balanceOf(address(fractionalSink));
        if (!legacy.transferFrom(msg.sender, address(fractionalSink), amount)) {
            revert TransferFailed();
        }
        if (legacy.balanceOf(address(fractionalSink)) - beforeBalance != amount) {
            revert TransferFailed();
        }

        v2.migrateFractional(msg.sender, amount);
        emit FractionalMigrated(msg.sender, amount);
    }

    /// @notice Claims a theft/restitution allocation. Conflict cases encode a
    /// replacementId in the published leaf; non-conflicts use originalId.
    function claimRestitutionDark(uint256 originalId, uint256 replacementId, bytes32[] calldata proof)
        external
        nonReentrant
        whenNotPaused
        whenDistributionOpen
    {
        _consumeLeaf(KIND_RESTITUTION_DARK, msg.sender, originalId, replacementId, v2.UNIT(), proof);
        _recordDistribution(v2.UNIT());
        v2.migrateDark(msg.sender, replacementId);
        emit RestitutionClaimed(msg.sender, originalId, replacementId);
    }

    // ── reward continuity ───────────────────────────────────────────

    /// @notice Permissionless retry if a legacy token transfer temporarily
    /// prevented rewards from moving during the hardwired migration.
    function retryLegacyRewards(uint256 id) external nonReentrant whenNotPaused {
        if (
            legacy.ownerOfId(id) != address(this) || !legacy.isHardwired(id) || !v2.isHardwired(id)
                || v2.ownerOfId(id) == address(0)
        ) {
            revert WrongTerminalState();
        }
        if (!_claimAndCreditLegacy(id)) emit LegacyRewardDeferred(id);
    }

    function _distribute(DistributionClaim calldata claim) internal {
        if (claim.account == address(0)) revert ZeroAddress();
        if (_isIncidentAddress(claim.account)) revert IncidentAddress();

        uint256 reserveSpent;
        if (claim.kind == KIND_DARK) {
            if (claim.amount != v2.UNIT()) revert InvalidAmount();
            reserveSpent = claim.amount;
        } else if (claim.kind == KIND_HARDWIRED) {
            if (claim.amount != 0 || claim.v1Id != claim.v2Id) revert InvalidAmount();
            reserveSpent = v2.UNIT();
        } else if (claim.kind == KIND_FRACTIONAL) {
            if (claim.v1Id != 0 || claim.v2Id != 0 || claim.amount == 0 || claim.amount >= v2.UNIT()) {
                revert InvalidAmount();
            }
            reserveSpent = claim.amount;
        } else if (claim.kind == KIND_RESTITUTION_DARK) {
            if (claim.amount != v2.UNIT()) revert InvalidAmount();
            reserveSpent = claim.amount;
        } else {
            revert InvalidKind();
        }

        _consumeLeaf(claim.kind, claim.account, claim.v1Id, claim.v2Id, claim.amount, claim.proof);
        _recordDistribution(reserveSpent);

        if (claim.kind == KIND_HARDWIRED) {
            v2.migrateHardwired(claim.account, claim.v2Id);
        } else if (claim.kind == KIND_FRACTIONAL) {
            v2.migrateFractional(claim.account, claim.amount);
        } else {
            v2.migrateDark(claim.account, claim.v2Id);
        }

        emit GenesisDistributed(claim.kind, claim.account, claim.v1Id, claim.v2Id, reserveSpent);
    }

    function _idClaimBeneficiary(uint8 kind, address snapshotAccount, uint256 v1Id, uint256 v2Id)
        internal
        view
        returns (address beneficiary)
    {
        IdClaimAssignment storage assignment = idClaimAssignment[v1Id];
        if (assignment.leaf == bytes32(0)) {
            beneficiary = snapshotAccount;
        } else {
            bytes32 leaf = leafFor(kind, snapshotAccount, v1Id, v2Id, _kindAmount(kind));
            if (
                assignment.leaf != leaf || assignment.snapshotAccount != snapshotAccount || assignment.v2Id != v2Id
                    || assignment.kind != kind
            ) {
                revert InvalidProof();
            }
            beneficiary = assignment.followsToken ? legacy.ownerOfId(v1Id) : assignment.beneficiary;
        }

        if (beneficiary == address(0)) revert WrongOwner();
        if (_isIncidentAddress(beneficiary)) {
            revert IncidentAddress();
        }
        _requireSafeApprovals(v1Id, beneficiary);
        return beneficiary;
    }

    function _completeDepositedId(uint8 kind, address account, uint256 v1Id, uint256 v2Id) internal {
        if (legacy.ownerOfId(v1Id) != address(this)) revert WrongOwner();
        bool hardwired = legacy.isHardwired(v1Id);
        if ((kind == KIND_HARDWIRED) != hardwired) revert WrongTerminalState();
        if (v1Id != v2Id) revert WrongTerminalState();
        _recordDistribution(v2.UNIT());

        if (kind == KIND_DARK) {
            if (legacy.erc721TransferExempt(address(this))) {
                revert LegacyConfigurationUnsafe();
            }
            v2.migrateDark(account, v2Id);
        } else {
            v2.migrateHardwired(account, v2Id);
            if (!_claimAndCreditLegacy(v1Id)) emit LegacyRewardDeferred(v1Id);
        }
        emit IdMigrated(kind, account, v1Id, v2Id);
    }

    function _recordDistribution(uint256 reserveSpent) internal {
        uint256 distributed = totalDistributed + reserveSpent;
        if (distributed > distributionCap) revert DistributionCapExceeded();
        totalDistributed = distributed;
    }

    function _claimAndCreditLegacy(uint256 id) internal returns (bool success) {
        uint8 floorCode;
        try legacyReflections.attributesOf(id) returns (uint8 floorCode_, uint8) {
            floorCode = floorCode_;
        } catch {
            return false;
        }
        address[10] memory tokens;
        uint256[10] memory balances;
        uint256 count;

        if (floorCode < 10) {
            try legacyReflections.floorStocks(floorCode) returns (address token) {
                tokens[0] = token;
            } catch {
                return false;
            }
            count = 1;
        } else if (floorCode == 10) {
            count = 10;
            for (uint256 i; i < 10; ++i) {
                try legacyReflections.floorStocks(i) returns (address token) {
                    tokens[i] = token;
                } catch {
                    return false;
                }
            }
        } else {
            try legacyReflections.paxg() returns (address token) {
                tokens[0] = token;
            } catch {
                return false;
            }
            count = 1;
        }
        for (uint256 i; i < count; ++i) {
            (bool readable, uint256 balance) = _tryBalanceOf(tokens[i]);
            if (!readable) return false;
            balances[i] = balance;
        }

        uint256[] memory ids = new uint256[](1);
        ids[0] = id;
        try legacyReflections.claim(ids) {
            for (uint256 i; i < count; ++i) {
                uint256 afterBalance = IERC20Migration(tokens[i]).balanceOf(address(this));
                uint256 delta = afterBalance - balances[i];
                if (delta != 0) _creditLegacy(id, tokens[i], delta);
            }
            return true;
        } catch {
            return false;
        }
    }

    function _creditLegacy(uint256 id, address token, uint256 amount) internal {
        IERC20Migration erc20 = IERC20Migration(token);
        uint256 current = erc20.allowance(address(this), address(v2Reflections));
        if (current != 0) _safeApprove(token, address(v2Reflections), 0);
        _safeApprove(token, address(v2Reflections), amount);
        v2Reflections.creditLegacy(id, token, amount);
        _safeApprove(token, address(v2Reflections), 0);
        emit LegacyRewardMigrated(id, token, amount);
    }

    function _tryBalanceOf(address token) internal view returns (bool success, uint256 balance) {
        if (token == address(0)) return (false, 0);
        (bool ok, bytes memory data) = token.staticcall(abi.encodeCall(IERC20Migration.balanceOf, (address(this))));
        if (!ok || data.length < 32) return (false, 0);
        return (true, abi.decode(data, (uint256)));
    }

    // ── Merkle commitment ───────────────────────────────────────────

    function leafFor(uint8 kind, address account, uint256 v1Id, uint256 v2Id, uint256 amount)
        public
        view
        returns (bytes32)
    {
        bytes32 inner = keccak256(
            abi.encode(LEAF_DOMAIN, block.chainid, address(legacy), snapshotBlock, kind, account, v1Id, v2Id, amount)
        );
        return keccak256(bytes.concat(inner));
    }

    function verifyLeaf(
        uint8 kind,
        address account,
        uint256 v1Id,
        uint256 v2Id,
        uint256 amount,
        bytes32[] calldata proof
    ) external view returns (bool) {
        return _verify(leafFor(kind, account, v1Id, v2Id, amount), proof);
    }

    function _consumeLeaf(
        uint8 kind,
        address account,
        uint256 v1Id,
        uint256 v2Id,
        uint256 amount,
        bytes32[] calldata proof
    ) internal {
        bytes32 leaf = leafFor(kind, account, v1Id, v2Id, amount);
        if (usedLeaf[leaf]) revert LeafAlreadyUsed();
        if (!_verify(leaf, proof)) revert InvalidProof();
        usedLeaf[leaf] = true;
    }

    function _verify(bytes32 leaf, bytes32[] calldata proof) internal view returns (bool) {
        bytes32 hash = leaf;
        for (uint256 i; i < proof.length; ++i) {
            bytes32 sibling = proof[i];
            hash = hash < sibling ? keccak256(bytes.concat(hash, sibling)) : keccak256(bytes.concat(sibling, hash));
        }
        return hash == snapshotRoot;
    }

    function _kindAmount(uint8 kind) internal view returns (uint256) {
        return kind == KIND_DARK ? v2.UNIT() : 0;
    }

    function _isIncidentAddress(address account) internal pure returns (bool) {
        return account == INCIDENT_ATTACKER || account == INCIDENT_OPERATOR || account == INCIDENT_POISON_SEED;
    }

    function _requireSafeApprovals(uint256 v1Id, address account) internal view {
        address approved = legacyMirror.getApproved(v1Id);
        if (approved != address(0) && approved != address(this)) {
            revert UnsafeLegacyApproval();
        }
        if (
            legacyMirror.isApprovedForAll(account, INCIDENT_ATTACKER)
                || legacyMirror.isApprovedForAll(account, INCIDENT_OPERATOR)
                || legacyMirror.isApprovedForAll(account, INCIDENT_POISON_SEED)
        ) {
            revert UnsafeLegacyApproval();
        }
    }

    // ── safety / operations ─────────────────────────────────────────

    function legacyConfigurationReady() external view returns (bool) {
        return !legacy.erc721TransferExempt(address(this)) && legacy.erc721TransferExempt(address(fractionalSink));
    }

    function setPaused(bool paused_) external onlyOwner {
        paused = paused_;
        emit Paused(paused_);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        owner = newOwner;
    }

    function _safeApprove(address token, address spender, uint256 amount) internal {
        (bool ok, bytes memory data) = token.call(abi.encodeCall(IERC20Migration.approve, (spender, amount)));
        if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert TransferFailed();
        }
    }
}
