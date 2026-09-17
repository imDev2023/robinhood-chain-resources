// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SentryTokenizedStocks
 * @dev ERC20 deployed by the Sentry Launch Factory for STOCK-PAIRED
 * launches. 1 billion fixed supply, auto-renounced ownership, and NO
 * transfer tax — transfers always move the full amount, so V3/V4 pools,
 * routers, and aggregators behave exactly as with SentryTokenStandard.
 *
 * What it adds is stock-dividend bookkeeping: every balance change
 * updates a magnified dividends-per-share accumulator so that reflection
 * fees — skimmed by the SentryStockFeeHook in the PAIRED STOCK (e.g.
 * AAPL) on every swap and transferred here — are attributable exactly
 * pro-rata to whoever held the token at that moment. Fully on-chain:
 * no keeper, no snapshots, no merkle roots.
 *
 *   - Hook (or anyone) sends `rewardToken` here, then calls
 *     notifyReward(): the balance delta since last accounting becomes
 *     dividends, split across the tracked (non-excluded) supply.
 *   - Holders call claim() to withdraw their accrued stock.
 *   - Excluded addresses (the V4 PoolManager, the factory, dead) never
 *     accrue; their balances are outside trackedSupply.
 *
 * Dividend math is the standard magnified-corrections scheme:
 *   accumulative(a) = (magDPS * balance(a) + corr[a]) / MAG
 * kept exact across transfers by shifting corr on every balance change.
 */

interface IFactoryOwner {
    function owner() external view returns (address);
}

interface IERC20Minimal {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract SentryTokenizedStocks {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /* ───────────────────── Stock dividend state ─────────────────── */

    uint256 private constant MAG = 2 ** 128;
    /// @dev Don't distribute until at least one whole token circulates;
    /// keeps magDPS * balance far inside int256 range.
    uint256 private constant MIN_TRACKED = 1e18;

    /// @notice The paired stock this token pays dividends in.
    address public immutable rewardToken;
    /// @notice The launch factory (admin functions gate on ITS owner).
    address public immutable factory;

    /// @notice Supply held by dividend-earning (non-excluded) addresses.
    uint256 public trackedSupply;
    uint256 public magDividendPerShare;
    mapping(address => int256) private magCorrections;
    mapping(address => uint256) public withdrawnDividends;

    /// @notice Addresses that never accrue dividends (pool manager,
    /// factory, lockers, dead). Their accrual is frozen at exclusion.
    mapping(address => bool) public dividendExcluded;
    mapping(address => uint256) private frozenAccrued;

    /// @notice rewardToken already attributed (distributed or pending);
    /// notifyReward() distributes any balance above this.
    uint256 public accountedRewards;
    /// @notice Rewards received while trackedSupply was below the floor;
    /// rolled into the next distribution.
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

    constructor(
        string memory _name,
        string memory _symbol,
        address _deployer,
        address _rewardToken,
        address[] memory _excluded
    ) {
        require(_rewardToken != address(0), "Invalid reward token");
        name = _name;
        symbol = _symbol;
        decimals = 18;
        totalSupply = 1_000_000_000 * (10 ** uint256(decimals));
        owner = address(0x000000000000000000000000000000000000dEaD);
        rewardToken = _rewardToken;
        factory = _deployer;

        dividendExcluded[address(0)] = true;
        dividendExcluded[address(this)] = true;
        dividendExcluded[0x000000000000000000000000000000000000dEaD] = true;
        for (uint256 i = 0; i < _excluded.length; i++) {
            dividendExcluded[_excluded[i]] = true;
            emit DividendExclusionSet(_excluded[i], true);
        }

        balanceOf[_deployer] = totalSupply;
        // The deployer is the factory, which is excluded — supply starts
        // fully outside trackedSupply and enters it as buyers receive it.
        if (!dividendExcluded[_deployer]) trackedSupply = totalSupply;
        emit Transfer(address(0), _deployer, totalSupply);
    }

    /* ─────────────────────────── ERC20 ──────────────────────────── */

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

        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        // Shift corrections so both parties' accumulated dividends are
        // unchanged by the balance move (full amount moves — no tax).
        int256 magShift = int256(magDividendPerShare * amount);
        magCorrections[from] += magShift;
        magCorrections[to] -= magShift;

        bool fromEx = dividendExcluded[from];
        bool toEx = dividendExcluded[to];
        if (fromEx && !toEx) trackedSupply += amount;
        else if (!fromEx && toEx) trackedSupply -= amount;

        emit Transfer(from, to, amount);
    }

    /* ───────────────────── Dividend distribution ────────────────── */

    /// @notice Attribute any newly received rewardToken to holders.
    /// Permissionless and exact: only the balance delta above what has
    /// already been accounted for is distributed, so calling it without
    /// sending funds is a no-op. The stock fee hook calls this right
    /// after skimming each swap's reflection fee here.
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

    /// @notice Withdraw the caller's accrued stock dividends.
    function claim() external nonReentrant returns (uint256 amount) {
        amount = withdrawableDividendOf(msg.sender);
        if (amount == 0) return 0;
        withdrawnDividends[msg.sender] += amount;
        accountedRewards -= amount;
        require(IERC20Minimal(rewardToken).transfer(msg.sender, amount), "reward transfer failed");
        emit DividendClaimed(msg.sender, amount);
    }

    /* ──────────────────────── Dividend views ────────────────────── */

    /// @notice Total stock dividends ever attributed to `account`.
    function accumulativeDividendOf(address account) public view returns (uint256) {
        if (dividendExcluded[account]) return frozenAccrued[account];
        return uint256(int256(magDividendPerShare * balanceOf[account]) + magCorrections[account]) / MAG;
    }

    /// @notice Stock dividends `account` can claim right now.
    function withdrawableDividendOf(address account) public view returns (uint256) {
        return accumulativeDividendOf(account) - withdrawnDividends[account];
    }

    /* ─────────────────────────── Admin ──────────────────────────── */

    /// @dev Gated on the FACTORY's owner (this token has no owner of its
    /// own by design). Used to exclude new infrastructure (a locker, a
    /// migration contract) from earning dividends.
    function setDividendExcluded(address account, bool excluded) external {
        require(msg.sender == IFactoryOwner(factory).owner(), "Not factory owner");
        require(account != address(0) && account != address(this), "Invalid account");
        if (dividendExcluded[account] == excluded) return;

        uint256 bal = balanceOf[account];
        if (excluded) {
            // Freeze accrual at its current value and pull the balance
            // out of the earning supply.
            frozenAccrued[account] =
                uint256(int256(magDividendPerShare * bal) + magCorrections[account]) / MAG;
            trackedSupply -= bal;
        } else {
            // Resume accrual from the frozen value.
            magCorrections[account] =
                int256(frozenAccrued[account] * MAG) - int256(magDividendPerShare * bal);
            frozenAccrued[account] = 0;
            trackedSupply += bal;
        }
        dividendExcluded[account] = excluded;
        emit DividendExclusionSet(account, excluded);
    }
}
