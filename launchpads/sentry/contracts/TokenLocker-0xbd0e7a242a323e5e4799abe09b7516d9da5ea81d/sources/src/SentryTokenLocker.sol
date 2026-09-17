// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SentryTokenLocker
 * @dev Trustless ERC-20 time-locks. Anyone can lock any token for any
 * beneficiary until a chosen unlock time. No owner, no admin functions,
 * no fees, no early-withdrawal path of any kind: once locked, tokens can
 * only ever move to the lock's beneficiary after its unlock time.
 *
 * Fee-on-transfer tokens are supported: the locked amount is the balance
 * actually received, not the amount requested.
 *
 * A lock's beneficiary can extend its unlock time (never shorten it) and
 * can hand the lock to a new beneficiary.
 */
contract SentryTokenLocker {
    struct Lock {
        address token;
        address beneficiary;
        uint256 amount;
        uint64 unlockTime;
        bool withdrawn;
    }

    Lock[] private _locks;

    // Lock ids ever associated with a beneficiary. Entries are not removed
    // when a lock is handed over or withdrawn; read the Lock for live state.
    mapping(address => uint256[]) private _beneficiaryLockIds;
    mapping(address => uint256[]) private _tokenLockIds;

    /// @notice Currently locked (not yet withdrawn) amount per token.
    mapping(address => uint256) public totalLocked;

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status = _NOT_ENTERED;

    event TokensLocked(
        uint256 indexed lockId,
        address indexed token,
        address indexed beneficiary,
        uint256 amount,
        uint64 unlockTime
    );
    event TokensWithdrawn(uint256 indexed lockId, address indexed token, address indexed beneficiary, uint256 amount);
    event LockExtended(uint256 indexed lockId, uint64 oldUnlockTime, uint64 newUnlockTime);
    event LockBeneficiaryTransferred(uint256 indexed lockId, address indexed oldBeneficiary, address indexed newBeneficiary);

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    /**
     * @notice Lock `amount` of `token` for `beneficiary` until `unlockTime`.
     * @dev Caller must approve this contract first. The recorded amount is
     *      the balance actually received (fee-on-transfer safe).
     */
    function lock(
        address token,
        uint256 amount,
        uint64 unlockTime,
        address beneficiary
    ) external nonReentrant returns (uint256 lockId) {
        require(token != address(0), "Invalid token");
        require(beneficiary != address(0), "Invalid beneficiary");
        require(amount > 0, "Amount is zero");
        require(unlockTime > block.timestamp, "Unlock time in the past");

        uint256 balanceBefore = _balanceOf(token, address(this));
        _safeTransferFrom(token, msg.sender, address(this), amount);
        uint256 received = _balanceOf(token, address(this)) - balanceBefore;
        require(received > 0, "Nothing received");

        lockId = _locks.length;
        _locks.push(Lock({
            token: token,
            beneficiary: beneficiary,
            amount: received,
            unlockTime: unlockTime,
            withdrawn: false
        }));
        _beneficiaryLockIds[beneficiary].push(lockId);
        _tokenLockIds[token].push(lockId);
        totalLocked[token] += received;

        emit TokensLocked(lockId, token, beneficiary, received, unlockTime);
    }

    /// @notice Withdraw a matured lock. Only the beneficiary, only after unlock.
    function withdraw(uint256 lockId) external nonReentrant {
        Lock storage l = _lockAt(lockId);
        require(msg.sender == l.beneficiary, "Not beneficiary");
        require(!l.withdrawn, "Already withdrawn");
        require(block.timestamp >= l.unlockTime, "Still locked");

        l.withdrawn = true;
        totalLocked[l.token] -= l.amount;
        _safeTransfer(l.token, l.beneficiary, l.amount);

        emit TokensWithdrawn(lockId, l.token, l.beneficiary, l.amount);
    }

    /// @notice Push a lock's unlock time further out. Never shortens.
    function extendLock(uint256 lockId, uint64 newUnlockTime) external {
        Lock storage l = _lockAt(lockId);
        require(msg.sender == l.beneficiary, "Not beneficiary");
        require(!l.withdrawn, "Already withdrawn");
        require(newUnlockTime > l.unlockTime, "Can only extend");

        uint64 old = l.unlockTime;
        l.unlockTime = newUnlockTime;
        emit LockExtended(lockId, old, newUnlockTime);
    }

    /// @notice Hand a lock to a new beneficiary.
    function transferBeneficiary(uint256 lockId, address newBeneficiary) external {
        require(newBeneficiary != address(0), "Invalid beneficiary");
        Lock storage l = _lockAt(lockId);
        require(msg.sender == l.beneficiary, "Not beneficiary");
        require(!l.withdrawn, "Already withdrawn");

        address old = l.beneficiary;
        l.beneficiary = newBeneficiary;
        _beneficiaryLockIds[newBeneficiary].push(lockId);
        emit LockBeneficiaryTransferred(lockId, old, newBeneficiary);
    }

    /* ────────────────────────────── Views ─────────────────────────────── */

    function lockCount() external view returns (uint256) {
        return _locks.length;
    }

    function getLock(uint256 lockId) external view returns (Lock memory) {
        return _lockAt(lockId);
    }

    /// @dev Ids ever associated with the beneficiary; check each lock's
    ///      current beneficiary/withdrawn state.
    function getBeneficiaryLockIds(address beneficiary) external view returns (uint256[] memory) {
        return _beneficiaryLockIds[beneficiary];
    }

    function getTokenLockIds(address token) external view returns (uint256[] memory) {
        return _tokenLockIds[token];
    }

    /* ──────────────────────────── Internals ───────────────────────────── */

    function _lockAt(uint256 lockId) private view returns (Lock storage) {
        require(lockId < _locks.length, "Unknown lock");
        return _locks[lockId];
    }

    function _balanceOf(address token, address account) private view returns (uint256) {
        (bool ok, bytes memory data) = token.staticcall(
            abi.encodeWithSelector(0x70a08231, account)
        );
        require(ok && data.length >= 32, "balanceOf failed");
        return abi.decode(data, (uint256));
    }

    /// @dev Transfer helpers that accept both standard and no-return
    ///      (USDT-style) ERC-20s but revert on explicit false.
    function _safeTransfer(address token, address to, uint256 amount) private {
        (bool ok, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, amount)
        );
        require(ok && (data.length == 0 || abi.decode(data, (bool))), "Transfer failed");
    }

    function _safeTransferFrom(address token, address from, address to, uint256 amount) private {
        (bool ok, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, amount)
        );
        require(ok && (data.length == 0 || abi.decode(data, (bool))), "TransferFrom failed");
    }
}
