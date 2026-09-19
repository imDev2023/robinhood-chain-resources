// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IActivationManager {
    function activeWeight(uint256 tokenId) external view returns (uint256);
    function totalActiveWeight() external view returns (uint256);
    function activeCount() external view returns (uint256);
    function activeTokenAt(uint256 index) external view returns (uint256);
}

interface IBrokerNft {
    function tokenWallet(uint256 tokenId) external view returns (address);
}

interface IERC20Minimal {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

interface IWeth is IERC20Minimal {
    function withdraw(uint256 amount) external;
}

/// @title SafetyDepositClockIn
/// @notice Receiver for Safety Deposit Box (StonkLiquidityLockerV4) protocol fees.
///         - Any ETH it holds can be flushed, permissionlessly, to the StockBooster
///           (the Clock In engine), where it joins the regular dividend flow.
///         - Any ERC-20 it holds ("collection tokens" skimmed from locked LPs) can be
///           airdropped, permissionlessly and in pages, to every activated StonkBroker,
///           weight-proportional, straight into each broker's ERC-6551 token-bound
///           wallet (never a bare EOA).
///
///         The paging pattern (snapshot pot -> cursor -> paidRound guard -> non-reverting
///         transfers capped by roundRemaining) is lifted from the audited StockBooster
///         Clock In engine so a poisoned recipient or shifting active set can never brick
///         or double-pay a round. Unpaid remainders roll into the next round's pot.
///
///         WETH is treated as ETH, not as a collection token: the v3 locker pays its
///         protocol fees in ERC-20s (WETH for the native side), so `flushWeth()` unwraps
///         and forwards to the StockBooster, and WETH can never be airdropped.
///
///         The contract is ownerless by design: there is nothing to configure and no
///         privileged withdrawal path. Everything that enters leaves only toward the
///         StockBooster or activated brokers.
contract SafetyDepositClockIn {
    error NoRoundInProgress();
    error RoundInProgress();
    error NothingToDistribute();
    error InvalidPageSize();
    error EthFlushFailed();
    error WethNotAirdroppable();
    error Reentrancy();

    event EthFlushed(uint256 amount);
    event AirdropStarted(address indexed token, uint256 indexed round, uint256 pot, uint256 totalWeight);
    event AirdropPaid(address indexed token, uint256 indexed round, uint256 indexed tokenId, address wallet, uint256 amount);
    event AirdropTransferSkipped(address indexed token, uint256 indexed round, uint256 indexed tokenId, uint256 amount);
    event AirdropFinished(address indexed token, uint256 indexed round, uint256 recipientsPaid);

    address public immutable stockBooster;
    IActivationManager public immutable activation;
    IBrokerNft public immutable brokerNft;
    IWeth public immutable weth;

    struct Round {
        uint64 round;          // 1-based counter per token
        bool active;
        uint256 pot;           // snapshot of distributable balance at start
        uint256 remaining;     // undistributed portion of pot
        uint256 totalWeight;   // activation weight snapshot at start
        uint256 cursor;        // next index into the active set
        uint256 paidCount;
    }

    mapping(address => Round) public rounds;
    /// @dev paid[token][round][tokenId] guards against double-pay when the active set shifts.
    mapping(address => mapping(uint64 => mapping(uint256 => bool))) public paid;

    uint256 private _entered = 1;

    modifier nonReentrant() {
        if (_entered != 1) revert Reentrancy();
        _entered = 2;
        _;
        _entered = 1;
    }

    constructor(address stockBooster_, address activation_, address brokerNft_, address weth_) {
        require(
            stockBooster_ != address(0) && activation_ != address(0) && brokerNft_ != address(0)
                && weth_ != address(0),
            "zero addr"
        );
        stockBooster = stockBooster_;
        activation = IActivationManager(activation_);
        brokerNft = IBrokerNft(brokerNft_);
        weth = IWeth(weth_);
    }

    /// @notice Accept ETH from the locker's protocol fee payouts (and anyone else).
    receive() external payable {}

    /// @notice Push the full ETH balance to the StockBooster. Permissionless: there is no
    ///         destination choice, so there is nothing a caller can abuse.
    function flushEth() external nonReentrant {
        uint256 bal = address(this).balance;
        if (bal == 0) revert NothingToDistribute();
        (bool ok,) = stockBooster.call{value: bal}("");
        if (!ok) revert EthFlushFailed();
        emit EthFlushed(bal);
    }

    /// @notice Unwrap the full WETH balance and push it to the StockBooster. The v3 locker
    ///         pays its native-side protocol fees in WETH, which is ETH in disguise and must
    ///         follow the ETH flow, not the airdrop flow.
    function flushWeth() external nonReentrant {
        uint256 bal = weth.balanceOf(address(this));
        if (bal == 0) revert NothingToDistribute();
        weth.withdraw(bal);
        (bool ok,) = stockBooster.call{value: address(this).balance}("");
        if (!ok) revert EthFlushFailed();
        emit EthFlushed(bal);
    }

    /// @notice Snapshot the current balance of `token` as a new airdrop round for all
    ///         activated brokers. Permissionless: the pot is just this contract's balance,
    ///         so starting a round early only splits the same funds across more rounds.
    function startAirdrop(address token) external nonReentrant {
        if (token == address(weth)) revert WethNotAirdroppable();
        Round storage r = rounds[token];
        if (r.active) revert RoundInProgress();

        uint256 pot = IERC20Minimal(token).balanceOf(address(this));
        uint256 totalWeight = activation.totalActiveWeight();
        if (pot == 0 || totalWeight == 0) revert NothingToDistribute();

        r.round += 1;
        r.active = true;
        r.pot = pot;
        r.remaining = pot;
        r.totalWeight = totalWeight;
        r.cursor = 0;
        r.paidCount = 0;

        emit AirdropStarted(token, r.round, pot, totalWeight);
    }

    /// @notice Pay up to `maxRecipients` activated brokers their weight-proportional share
    ///         of the round pot, into each broker's token-bound wallet. Call repeatedly
    ///         until the round closes.
    function continueAirdrop(address token, uint256 maxRecipients) external nonReentrant {
        Round storage r = rounds[token];
        if (!r.active) revert NoRoundInProgress();
        if (maxRecipients == 0) revert InvalidPageSize();

        uint64 round = r.round;
        uint256 pagePaid = 0;

        while (pagePaid < maxRecipients) {
            // Pot exhausted: every remaining share would clamp to zero, so stop
            // paging immediately and let the round close below. Without this, a
            // mid-round activation-weight increase (live weights vs. snapshot
            // totalWeight) could exhaust the pot early and force one tx to walk
            // the whole zero-share tail — potentially past the block gas limit,
            // leaving the round permanently open. (v1.2 audit fix)
            if (r.remaining == 0) break;

            uint256 count = activation.activeCount();
            if (r.cursor >= count) break;

            uint256 tokenId = activation.activeTokenAt(r.cursor);
            r.cursor += 1;
            // Every *examined* broker counts toward the page, paid or skipped,
            // so a page's gas is bounded by maxRecipients no matter how many
            // entries are skips. (v1.2 audit fix)
            pagePaid += 1;

            if (paid[token][round][tokenId]) continue;
            paid[token][round][tokenId] = true;

            uint256 weight = activation.activeWeight(tokenId);
            if (weight == 0) continue;

            address wallet = brokerNft.tokenWallet(tokenId);
            if (wallet == address(0)) continue;

            uint256 share = (r.pot * weight) / r.totalWeight;
            if (share > r.remaining) share = r.remaining;
            if (share == 0) continue;

            if (_tryTransfer(token, wallet, share)) {
                r.remaining -= share;
                r.paidCount += 1;
                emit AirdropPaid(token, round, tokenId, wallet, share);
            } else {
                emit AirdropTransferSkipped(token, round, tokenId, share);
            }
        }

        if (r.remaining == 0 || r.cursor >= activation.activeCount()) {
            r.active = false;
            emit AirdropFinished(token, round, r.paidCount);
        }
    }

    /// @dev Non-reverting ERC-20 transfer: tolerates missing return data, treats a false
    ///      return or revert as a skip so one poisoned recipient can't brick the round.
    function _tryTransfer(address token, address to, uint256 amount) internal returns (bool) {
        (bool ok, bytes memory ret) = token.call(abi.encodeCall(IERC20Minimal.transfer, (to, amount)));
        return ok && (ret.length == 0 || abi.decode(ret, (bool)));
    }
}
