// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title SentryTokenRelaunch
 * @dev The SENTRY relaunch token on Robinhood Chain. Three things in one
 * ERC20, all of them load-bearing for the launch:
 *
 *  1. PREMINE. 1B fixed supply mints at deploy: 10% to the treasury
 *     multisig, 3% to the founder, 87% to the deployer (which pairs into
 *     the launch pool and funds the airdrops). Both premine wallets hold
 *     through launch on purpose — they earn WETH reflections from the
 *     sniper window like any other holder.
 *
 *  2. WETH DIVIDENDS. Standard magnified-corrections accounting, same
 *     scheme as SentryTokenizedStocks, but the reward asset is WETH:
 *     SentrySentryFeeHook skims the reflection cut of every swap, sends it
 *     here, and calls notifyReward(). Holders claim(). No transfer tax —
 *     transfers always move the full amount, so pools and routers behave
 *     normally.
 *
 *  3. MIGRATION LOCK + EXTENSION VOTE. Wallets airdropped via
 *     airdropLocked() cannot transfer until unlockTime(); they can still
 *     receive (and they accrue WETH the whole time they are locked).
 *     Base unlock is AUG_3. Only migration wallets vote, once, YES/NO,
 *     weighted by their airdropped allocation (not live balance, so
 *     buying more does not buy more votes). At AUG_3 the vote resolves
 *     relatively: YES > NO extends the unlock to OCT_3, anything else
 *     (including a tie or zero turnout) unlocks on schedule.
 */

interface IERC20Minimal {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract SentryTokenRelaunch {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /* ─────────────────────── Premine recipients ─────────────────── */

    address public immutable treasury;
    address public immutable founder;

    uint256 public constant TREASURY_CUT = 100_000_000e18; // 10%
    uint256 public constant FOUNDER_CUT = 30_000_000e18; //  3%

    /* ────────────────────── Lock + vote state ───────────────────── */

    /// @notice 2026-08-03T00:00:00Z — base unlock, and the voting deadline.
    uint256 public constant AUG_3 = 1785715200;
    /// @notice 2026-10-03T00:00:00Z — unlock if the extension vote passes.
    uint256 public constant OCT_3 = 1790985600;

    uint256 public yesVotes;
    uint256 public noVotes;

    mapping(address => bool) public migrationLocked;
    mapping(address => uint256) public migrationAllocation;
    mapping(address => bool) public hasVoted;

    /// @notice Addresses a still-locked migration wallet is allowed to send
    /// to — the v4 PoolManager and any approved router. This is the early
    /// exit: a locked holder who wants out now can SELL (paying the hook's
    /// 80% early-exit fee), but cannot move tokens to a fresh wallet to
    /// escape the lock. While this mapping is empty the lock is absolute,
    /// so the escape hatch is opt-in.
    mapping(address => bool) public exitVenue;

    event MigrationLockSet(address indexed wallet, bool locked);
    event ExitVenueSet(address indexed venue, bool allowed);
    event VoteCast(address indexed voter, bool support, uint256 weight);
    event OwnershipRenounced(address indexed previousOwner);

    /* ───────────────────── WETH dividend state ──────────────────── */

    uint256 private constant MAG = 2 ** 128;
    /// @dev Don't distribute until at least one whole token is tracked;
    /// keeps magDPS * balance far inside int256 range.
    uint256 private constant MIN_TRACKED = 1e18;

    /// @notice The asset reflections are paid in (WETH).
    address public immutable rewardToken;

    /// @notice Supply held by dividend-earning (non-excluded) addresses.
    uint256 public trackedSupply;
    uint256 public magDividendPerShare;
    mapping(address => int256) private magCorrections;
    mapping(address => uint256) public withdrawnDividends;

    /// @notice Addresses that never accrue reflections (pool manager, hook,
    /// dead, this contract). Their accrual is frozen at exclusion.
    mapping(address => bool) public dividendExcluded;
    mapping(address => uint256) private frozenAccrued;

    /// @notice rewardToken already attributed; notifyReward() distributes
    /// any balance above this.
    uint256 public accountedRewards;
    /// @notice Rewards received while trackedSupply was below the floor.
    uint256 public pendingUndistributed;

    uint256 private _entered = 1;

    event RewardsDistributed(uint256 amount, uint256 magDividendPerShare);
    event DividendClaimed(address indexed holder, uint256 amount);
    event DividendExclusionSet(address indexed account, bool excluded);

    modifier nonReentrant() {
        require(_entered == 1, "reentrancy");
        _entered = 2;
        _;
        _entered = 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _deployer,
        address _treasury,
        address _founder,
        address _rewardToken,
        address[] memory _excluded
    ) {
        require(_treasury != address(0) && _founder != address(0), "Zero address");
        require(_rewardToken != address(0), "Invalid reward token");
        name = _name;
        symbol = _symbol;
        decimals = 18;
        totalSupply = 1_000_000_000 * (10 ** uint256(decimals));
        owner = _deployer;
        treasury = _treasury;
        founder = _founder;
        rewardToken = _rewardToken;

        dividendExcluded[address(0)] = true;
        dividendExcluded[address(this)] = true;
        dividendExcluded[0x000000000000000000000000000000000000dEaD] = true;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (!dividendExcluded[_excluded[i]]) {
                dividendExcluded[_excluded[i]] = true;
                emit DividendExclusionSet(_excluded[i], true);
            }
        }

        balanceOf[_treasury] = TREASURY_CUT;
        balanceOf[_founder] = FOUNDER_CUT;
        uint256 deployerCut = totalSupply - TREASURY_CUT - FOUNDER_CUT; // 87%
        balanceOf[_deployer] = deployerCut;

        // Seed trackedSupply from whichever premine wallets are earning.
        if (!dividendExcluded[_treasury]) trackedSupply += TREASURY_CUT;
        if (!dividendExcluded[_founder]) trackedSupply += FOUNDER_CUT;
        if (!dividendExcluded[_deployer]) trackedSupply += deployerCut;

        emit Transfer(address(0), _treasury, TREASURY_CUT);
        emit Transfer(address(0), _founder, FOUNDER_CUT);
        emit Transfer(address(0), _deployer, deployerCut);
    }

    /* ─────────────────────────── Lock state ─────────────────────── */

    /// @notice Whether the vote currently resolves to an extension. Final
    /// once block.timestamp >= AUG_3, because voting is closed by then.
    function extensionPassing() public view returns (bool) {
        return yesVotes > noVotes;
    }

    /// @notice Current unlock timestamp for migration-locked wallets.
    function unlockTime() public view returns (uint256) {
        return extensionPassing() ? OCT_3 : AUG_3;
    }

    /* ───────────────────────── Extension vote ───────────────────── */

    /// @notice Migration-locked wallets only, one vote each, weighted by
    /// the wallet's airdropped allocation. Treasury, founder, deployer and
    /// ordinary buyers hold no allocation, so they are excluded by
    /// construction.
    function vote(bool support) external {
        require(block.timestamp < AUG_3, "Voting closed");
        require(migrationLocked[msg.sender], "Only migration holders vote");
        require(!hasVoted[msg.sender], "Already voted");
        uint256 weight = migrationAllocation[msg.sender];
        require(weight > 0, "No allocation");

        hasVoted[msg.sender] = true;
        if (support) {
            yesVotes += weight;
        } else {
            noVotes += weight;
        }
        emit VoteCast(msg.sender, support, weight);
    }

    /* ───────────────────────────  Airdrops ──────────────────────── */

    /// @notice Batch-send migration entitlements, lock each recipient, and
    /// record their vote weight. Owner only.
    function airdropLocked(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Length mismatch");
        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
            migrationAllocation[recipients[i]] += amounts[i];
            if (!migrationLocked[recipients[i]]) {
                migrationLocked[recipients[i]] = true;
                emit MigrationLockSet(recipients[i], true);
            }
        }
    }

    /// @notice Batch-send unlocked balances (Ink-era buyers etc). Owner only.
    function airdrop(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Length mismatch");
        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
    }

    /* ────────────────────────── Administration ──────────────────── */

    /// @notice Remove a wallet's migration lock early (support corrections
    /// only). Locks are only ever created by airdropLocked().
    function unlock(address wallet) external onlyOwner {
        require(migrationLocked[wallet], "Not locked");
        migrationLocked[wallet] = false;
        emit MigrationLockSet(wallet, false);
    }

    /// @notice Allow (or revoke) a destination that locked migration wallets
    /// may transfer to. Allowlisting the PoolManager opens the early-exit
    /// sell path; leaving it empty keeps the lock absolute.
    function setExitVenue(address venue, bool allowed) external onlyOwner {
        require(venue != address(0), "Invalid venue");
        exitVenue[venue] = allowed;
        emit ExitVenueSet(venue, allowed);
    }

    /// @notice Exclude/include an address from reflections (pool manager,
    /// hook, vaults). Owner only, and therefore frozen after renounce.
    function setDividendExcluded(address account, bool excluded) external onlyOwner {
        require(account != address(0) && account != address(this), "Invalid account");
        if (dividendExcluded[account] == excluded) return;

        uint256 bal = balanceOf[account];
        if (excluded) {
            frozenAccrued[account] = uint256(int256(magDividendPerShare * bal) + magCorrections[account]) / MAG;
            trackedSupply -= bal;
        } else {
            magCorrections[account] = int256(frozenAccrued[account] * MAG) - int256(magDividendPerShare * bal);
            frozenAccrued[account] = 0;
            trackedSupply += bal;
        }
        dividendExcluded[account] = excluded;
        emit DividendExclusionSet(account, excluded);
    }

    /// @notice Give up owner powers once airdrops + LP are done. Irreversible.
    function renounceOwnership() external onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    /* ─────────────────── WETH dividend distribution ─────────────── */

    /// @notice Attribute newly received WETH to holders. Permissionless and
    /// exact: only the balance delta above what is already accounted for is
    /// distributed, so calling it without sending funds is a no-op. The fee
    /// hook calls this right after skimming each swap's reflection cut.
    function notifyReward() external {
        uint256 balance = IERC20Minimal(rewardToken).balanceOf(address(this));
        uint256 newRewards = balance - accountedRewards;
        if (newRewards == 0 && pendingUndistributed == 0) return;
        accountedRewards = balance;

        if (trackedSupply < MIN_TRACKED) {
            pendingUndistributed += newRewards;
            return;
        }
        uint256 amount = newRewards + pendingUndistributed;
        pendingUndistributed = 0;
        magDividendPerShare += (amount * MAG) / trackedSupply;
        emit RewardsDistributed(amount, magDividendPerShare);
    }

    /// @notice Withdraw the caller's accrued WETH reflections. Available to
    /// migration-locked wallets too — the lock stops token transfers, not
    /// dividend claims.
    function claim() external nonReentrant returns (uint256 amount) {
        amount = withdrawableDividendOf(msg.sender);
        if (amount == 0) return 0;
        withdrawnDividends[msg.sender] += amount;
        accountedRewards -= amount;
        require(IERC20Minimal(rewardToken).transfer(msg.sender, amount), "reward transfer failed");
        emit DividendClaimed(msg.sender, amount);
    }

    /* ──────────────────────── Dividend views ────────────────────── */

    function accumulativeDividendOf(address account) public view returns (uint256) {
        if (dividendExcluded[account]) return frozenAccrued[account];
        return uint256(int256(magDividendPerShare * balanceOf[account]) + magCorrections[account]) / MAG;
    }

    function withdrawableDividendOf(address account) public view returns (uint256) {
        return accumulativeDividendOf(account) - withdrawnDividends[account];
    }

    /* ──────────────────────────── ERC20 ─────────────────────────── */

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        allowance[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "Transfer from zero");
        require(to != address(0), "Transfer to zero");
        require(balanceOf[from] >= amount, "Insufficient balance");
        // Locked migration wallets can still reach an allowlisted exit venue
        // (the pool), where the hook charges the 80% early-exit fee. Every
        // other destination stays blocked until the unlock, so nobody can
        // sidestep the lock by moving to a fresh wallet.
        if (migrationLocked[from] && block.timestamp < unlockTime()) {
            require(exitVenue[to], "Migration tokens locked");
        }

        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        // Shift corrections so both parties' accrued dividends are unchanged
        // by the balance move (full amount moves — no transfer tax).
        int256 magShift = int256(magDividendPerShare * amount);
        magCorrections[from] += magShift;
        magCorrections[to] -= magShift;

        bool fromEx = dividendExcluded[from];
        bool toEx = dividendExcluded[to];
        if (fromEx && !toEx) trackedSupply += amount;
        else if (!fromEx && toEx) trackedSupply -= amount;

        emit Transfer(from, to, amount);
    }
}
