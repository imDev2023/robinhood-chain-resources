// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice ERC20 launched by the LaunchFactory. Enforces anti-snipe max-wallet /
/// max-tx limits until `restrictionsEndBlock`, after which it behaves as a plain ERC20.
contract LaunchToken is ERC20 {
    error NotFactory();
    error MaxWalletExceeded();
    error MaxTxExceeded();
    error InvalidSnapshotId();
    error TimestampNotFinalized();
    error SnapshotAlreadyCreatedThisTimestamp();
    error ZeroAddress();
    error InvalidFeeVaultDeposit();
    error FeeVaultAlreadyConfigured();

    event Snapshot(uint256 id);
    event VotingExcluded(address indexed account);
    event FeeVaultConfigured(address indexed vault, address indexed depositSource);

    address public immutable factory;
    uint256 public immutable restrictionsEndBlock;
    uint256 public immutable maxWalletAmount; // 0 = no limit
    uint256 public immutable maxTxAmount; // 0 = no limit

    /// @notice Addresses exempt from restrictions (pool, locker, position manager, router, factory).
    mapping(address => bool) public restrictionExempt;

    /// @notice Protocol inventory that must not receive CTO voting power.
    /// @dev This is deliberately separate from `restrictionExempt`: an address can need unrestricted
    /// transfers without being excluded from governance. Their balances contribute to the snapshotted
    /// aggregate nonvoting supply, while lazy per-account snapshots remain available for auditability and
    /// their unnecessary per-account final-boundary writes are skipped.
    mapping(address => bool) public votingExcluded;

    /// @notice First snapshot id at which an account is nonvoting (zero means never excluded).
    /// @dev This keeps historical round views stable even after a protocol recipient is excluded in a later round.
    mapping(address => uint256) public votingExcludedFromSnapshotId;

    /// @notice Fixed fee-distribution contracts allowed to pay accrued launched tokens without a recipient
    /// max-wallet failure. This is intentionally distinct from `restrictionExempt`: marking the V3 pool here
    /// would disable max-wallet protection for buys, so the factory marks only this token's CTO vault.
    mapping(address => bool) public feeSenderExempt;

    /// @notice The only address allowed to deposit this token into a configured CTO fee vault.
    /// @dev In production this is the canonical FeeRouter. Rejecting every other inbound transfer prevents
    /// holders from temporarily parking voting inventory in the excluded vault or using claims to bypass
    /// anti-snipe wallet limits.
    mapping(address vault => address source) public feeDepositSource;

    /// @notice Current balance held by every one-way voting-excluded account.
    /// @dev Maintaining the aggregate in `_update` lets elections exclude mutable protocol treasuries without
    /// iterating an ever-growing address list. A transfer into ordinary circulation decreases this value.
    uint256 public votingExcludedSupply;

    // ERC20Snapshot-style lazy balance history. A holder only writes once after each snapshot in which
    // its balance changes; taking a snapshot itself is O(1) and never loops over holders.
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;
    mapping(uint256 => uint256) private _snapshotTotalSupply;
    mapping(uint256 => uint256) private _snapshotVotingExcludedSupply;
    uint256 private _currentSnapshotId;

    /// @dev Round-scoped end-of-opening-timestamp values. Only accounts that move during the exact snapshot
    /// timestamp write this mapping; every other account's final boundary equals its exact snapshot balance.
    /// This avoids permanent per-transfer checkpoint growth during ordinary trading.
    struct FinalBoundaryBalance {
        uint256 balance;
        bool written;
    }

    mapping(uint256 snapshotId => uint48 timestamp) private _snapshotTime;
    mapping(uint256 snapshotId => mapping(address account => FinalBoundaryBalance)) private _finalBoundaryBalances;
    mapping(uint256 snapshotId => uint256 supply) private _finalBoundaryVotingExcludedSupply;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 supply_,
        uint16 maxWalletBps_,
        uint16 maxTxBps_,
        uint256 restrictionsEndBlock_
    ) ERC20(name_, symbol_) {
        factory = msg.sender;
        restrictionsEndBlock = restrictionsEndBlock_;
        maxWalletAmount = maxWalletBps_ >= 10_000 ? 0 : (supply_ * maxWalletBps_) / 10_000;
        maxTxAmount = maxTxBps_ >= 10_000 ? 0 : (supply_ * maxTxBps_) / 10_000;
        restrictionExempt[msg.sender] = true;
        votingExcluded[msg.sender] = true;
        votingExcludedFromSnapshotId[msg.sender] = 1;
        address dead = 0x000000000000000000000000000000000000dEaD;
        votingExcluded[dead] = true;
        votingExcludedFromSnapshotId[dead] = 1;
        _mint(msg.sender, supply_);
    }

    /// @notice Factory marks protocol addresses as exempt during launch (one-way).
    function setRestrictionExempt(address account) external {
        if (msg.sender != factory) revert NotFactory();
        restrictionExempt[account] = true;
    }

    /// @notice Factory permanently excludes protocol inventory from voting.
    /// @dev This must be called for the canonical pool and CTO fee vault before either first receives
    /// tokens. The setting is intentionally one-way so governance eligibility cannot be toggled around
    /// an election boundary.
    function setVotingExcluded(address account) external {
        if (msg.sender != factory) revert NotFactory();
        if (account == address(0)) revert ZeroAddress();
        if (!votingExcluded[account]) {
            votingExcluded[account] = true;
            votingExcludedFromSnapshotId[account] = _currentSnapshotId + 1;
            votingExcludedSupply += balanceOf(account);
            _updateFinalBoundaryExcludedSupply();
            emit VotingExcluded(account);
        }
    }

    /// @notice Factory permanently binds a CTO vault to its sole launched-token deposit source.
    /// @dev The vault may pay claims above max-wallet, but cannot accept arbitrary holder deposits.
    function configureFeeVault(address vault, address depositSource) external {
        if (msg.sender != factory) revert NotFactory();
        if (vault == address(0) || depositSource == address(0)) revert ZeroAddress();
        if (feeDepositSource[vault] != address(0)) revert FeeVaultAlreadyConfigured();
        feeSenderExempt[vault] = true;
        feeDepositSource[vault] = depositSource;
        emit FeeVaultConfigured(vault, depositSource);
    }

    /// @notice Create an exact holder-balance snapshot for a CTO election round.
    /// @dev Only the factory can open snapshots, allowing it to validate that this is one of its launches.
    function snapshot() external returns (uint256 id) {
        if (msg.sender != factory) revert NotFactory();
        if (_currentSnapshotId != 0 && _snapshotTime[_currentSnapshotId] == block.timestamp) {
            revert SnapshotAlreadyCreatedThisTimestamp();
        }
        id = ++_currentSnapshotId;
        _snapshotTotalSupply[id] = totalSupply();
        _snapshotVotingExcludedSupply[id] = votingExcludedSupply;
        _snapshotTime[id] = uint48(block.timestamp);
        _finalBoundaryVotingExcludedSupply[id] = votingExcludedSupply;
        emit Snapshot(id);
    }

    function currentSnapshotId() external view returns (uint256) {
        return _currentSnapshotId;
    }

    /// @notice `account`'s exact balance when `snapshotId` was created.
    function balanceOfAt(address account, uint256 snapshotId) public view returns (uint256) {
        _requireValidSnapshot(snapshotId);
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);
        return snapshotted ? value : balanceOf(account);
    }

    /// @notice Total token supply when `snapshotId` was created.
    function totalSupplyAt(uint256 snapshotId) public view returns (uint256) {
        _requireValidSnapshot(snapshotId);
        return _snapshotTotalSupply[snapshotId];
    }

    /// @notice Aggregate protocol/nonvoting inventory when `snapshotId` was created.
    function votingExcludedSupplyAt(uint256 snapshotId) public view returns (uint256) {
        _requireValidSnapshot(snapshotId);
        return _snapshotVotingExcludedSupply[snapshotId];
    }

    /// @notice `account`'s balance at the finalized end of a snapshot's opening timestamp.
    function finalizedBalanceAt(address account, uint256 snapshotId) external view returns (uint256) {
        _requireFinalizedSnapshot(snapshotId);
        if (_isVotingExcludedAt(account, snapshotId)) return 0;

        FinalBoundaryBalance storage finalBalance = _finalBoundaryBalances[snapshotId][account];
        return finalBalance.written ? finalBalance.balance : balanceOfAt(account, snapshotId);
    }

    /// @notice Aggregate voting-excluded supply at the finalized end of a snapshot's opening timestamp.
    function finalizedVotingExcludedSupplyAt(uint256 snapshotId) external view returns (uint256) {
        _requireFinalizedSnapshot(snapshotId);
        return _finalBoundaryVotingExcludedSupply[snapshotId];
    }

    function restrictionsActive() public view returns (bool) {
        return block.number < restrictionsEndBlock;
    }

    function _update(address from, address to, uint256 value) internal override {
        address requiredDepositSource = feeDepositSource[to];
        if (value != 0 && requiredDepositSource != address(0) && from != requiredDepositSource) {
            revert InvalidFeeVaultDeposit();
        }

        if (from != address(0) && to != address(0) && restrictionsActive()) {
            if (maxTxAmount != 0 && value > maxTxAmount && !restrictionExempt[from] && !restrictionExempt[to]) {
                revert MaxTxExceeded();
            }
            if (
                maxWalletAmount != 0 && !restrictionExempt[to] && !feeSenderExempt[from]
                    && balanceOf(to) + value > maxWalletAmount
            ) {
                revert MaxWalletExceeded();
            }
        }

        uint256 currentId = _currentSnapshotId;

        // Lazy snapshots capture the pre-mutation balance and remain enabled for excluded protocol accounts
        // for historical auditability; the election denominator uses the separately snapshotted aggregate.
        if (from == address(0)) {
            _updateAccountSnapshot(to, currentId);
        } else if (to == address(0)) {
            _updateAccountSnapshot(from, currentId);
        } else {
            _updateAccountSnapshot(from, currentId);
            _updateAccountSnapshot(to, currentId);
        }

        super._update(from, to, value);

        uint256 boundaryId;
        if (currentId != 0 && _snapshotTime[currentId] == block.timestamp) boundaryId = currentId;

        bool fromExcluded = from != address(0) && votingExcluded[from];
        bool toExcluded = to != address(0) && votingExcluded[to];
        if (fromExcluded != toExcluded) {
            if (fromExcluded) {
                votingExcludedSupply -= value;
            } else {
                votingExcludedSupply += value;
            }
            if (boundaryId != 0) _finalBoundaryVotingExcludedSupply[boundaryId] = votingExcludedSupply;
        }

        // Only the opening snapshot timestamp needs a second boundary. Repeated same-timestamp changes simply
        // overwrite the account's final value; ordinary trading outside that timestamp writes no history.
        if (boundaryId != 0) {
            if (from != address(0)) _updateFinalBoundaryBalance(from, boundaryId);
            if (to != address(0)) _updateFinalBoundaryBalance(to, boundaryId);
        }
    }

    function _updateFinalBoundaryBalance(address account, uint256 boundaryId) private {
        if (_isVotingExcludedAt(account, boundaryId)) return;
        FinalBoundaryBalance storage finalBalance = _finalBoundaryBalances[boundaryId][account];
        finalBalance.balance = balanceOf(account);
        finalBalance.written = true;
    }

    function _updateFinalBoundaryExcludedSupply() private {
        uint256 currentId = _currentSnapshotId;
        if (currentId != 0 && _snapshotTime[currentId] == block.timestamp) {
            _finalBoundaryVotingExcludedSupply[currentId] = votingExcludedSupply;
        }
    }

    function _updateAccountSnapshot(address account, uint256 currentId) private {
        Snapshots storage snapshots = _accountBalanceSnapshots[account];
        if (currentId != 0 && _lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(balanceOf(account));
        }
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private
        view
        returns (bool snapshotted, uint256 value)
    {
        uint256 low;
        uint256 high = snapshots.ids.length;

        // Find the first stored snapshot id greater than or equal to `snapshotId`.
        while (low < high) {
            uint256 mid = low + (high - low) / 2;
            if (snapshots.ids[mid] < snapshotId) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }

        if (low == snapshots.ids.length) return (false, 0);
        return (true, snapshots.values[low]);
    }

    function _requireValidSnapshot(uint256 snapshotId) private view {
        if (snapshotId == 0 || snapshotId > _currentSnapshotId) revert InvalidSnapshotId();
    }

    function _requireFinalizedSnapshot(uint256 snapshotId) private view {
        _requireValidSnapshot(snapshotId);
        if (_snapshotTime[snapshotId] >= block.timestamp) revert TimestampNotFinalized();
    }

    function _isVotingExcludedAt(address account, uint256 snapshotId) private view returns (bool) {
        uint256 excludedFrom = votingExcludedFromSnapshotId[account];
        return excludedFrom != 0 && snapshotId >= excludedFrom;
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        return ids.length == 0 ? 0 : ids[ids.length - 1];
    }
}
