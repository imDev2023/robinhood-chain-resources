// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IActivationManager {
    function activeWeight(uint256 tokenId) external view returns (uint256);
    function totalActiveWeight() external view returns (uint256);
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

/// @title SafetyDepositClockInV2
/// @notice Receiver for Safety Deposit Box (v3 + v4 locker) protocol fees.
///
///         v2 replaces v1's push airdrop with a **pull-based clock-in**:
///         - ETH and WETH are flushed, permissionlessly, to the StockBooster
///           (unchanged from v1).
///         - Every other token accrues into weekly rounds. `startRound(token)`
///           snapshots the balance + activation weight; each broker then claims
///           their own weight-proportional share via `clockIn` — paying their
///           own (tiny) gas only for the tokens they actually want. Claims are
///           open until the next round starts; unclaimed shares roll into the
///           next round's pot, so skipped dust recycles to the brokers who do
///           clock in.
///
///         Why pull instead of push: a push airdrop costs gas proportional to
///         the broker count regardless of pot value, forces the caller to
///         subsidize everyone, and force-feeds dust into every wallet. Pull
///         claims cost ~60k gas per token, are paid by the beneficiary, and
///         make token selectivity free — you simply don't claim what you don't
///         want.
///
///         Claims are permissionless *triggers* but pinned *destinations*:
///         anyone may clock in on behalf of any broker tokenId, and the funds
///         always land in that broker's ERC-6551 token-bound wallet — never
///         the caller. The contract is ownerless: there is no configuration
///         and no privileged withdrawal path.
contract SafetyDepositClockInV2 {
    error NothingToDistribute();
    error RoundTooYoung();
    error WethNotAirdroppable();
    error EthFlushFailed();
    error ClaimTransferFailed();
    error EmptyClaim();
    error Reentrancy();

    event EthFlushed(uint256 amount);
    event RoundStarted(address indexed token, uint64 indexed round, uint256 pot, uint256 totalWeight);
    event ClockedIn(
        address indexed token, uint64 indexed round, uint256 indexed tokenId, address wallet, uint256 amount
    );

    /// @notice Minimum age of a round before it can be superseded. Bounds the
    ///         claim window brokers can rely on and stops rapid-restart griefing
    ///         (restarting recomputes everyone's shares against a fresh pot).
    uint64 public constant ROUND_COOLDOWN = 7 days;

    address public immutable stockBooster;
    IActivationManager public immutable activation;
    IBrokerNft public immutable brokerNft;
    IWeth public immutable weth;

    struct Round {
        uint64 round; // 1-based counter per token; 0 = no round yet
        uint64 startedAt;
        uint256 pot; // snapshot of distributable balance at start
        uint256 remaining; // unclaimed portion of pot
        uint256 totalWeight; // activation weight snapshot at start
    }

    mapping(address => Round) public rounds;
    /// @dev claimed[token][round][tokenId] — one claim per broker per round.
    mapping(address => mapping(uint64 => mapping(uint256 => bool))) public claimed;

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

    /// @notice Push the full ETH balance to the StockBooster. Permissionless: the
    ///         destination is hardwired, so there is nothing a caller can abuse.
    function flushEth() external nonReentrant {
        uint256 bal = address(this).balance;
        if (bal == 0) revert NothingToDistribute();
        (bool ok,) = stockBooster.call{value: bal}("");
        if (!ok) revert EthFlushFailed();
        emit EthFlushed(bal);
    }

    /// @notice Unwrap the full WETH balance and push it to the StockBooster. The
    ///         v3 locker pays its native-side protocol fees in WETH, which is ETH
    ///         in disguise and must follow the ETH flow, not the claim flow.
    function flushWeth() external nonReentrant {
        uint256 bal = weth.balanceOf(address(this));
        if (bal == 0) revert NothingToDistribute();
        weth.withdraw(bal);
        (bool ok,) = stockBooster.call{value: address(this).balance}("");
        if (!ok) revert EthFlushFailed();
        emit EthFlushed(bal);
    }

    /// @notice Open a new claim round for `token`, snapshotting the full current
    ///         balance (unclaimed remainder from the previous round rolls in
    ///         automatically) and the current total activation weight.
    ///         Permissionless, but a live round can only be superseded after
    ///         ROUND_COOLDOWN — or immediately once it is fully claimed.
    function startRound(address token) external nonReentrant {
        if (token == address(weth)) revert WethNotAirdroppable();
        Round storage r = rounds[token];
        if (r.round > 0 && r.remaining > 0 && block.timestamp < r.startedAt + ROUND_COOLDOWN) {
            revert RoundTooYoung();
        }

        uint256 pot = IERC20Minimal(token).balanceOf(address(this));
        uint256 totalWeight = activation.totalActiveWeight();
        if (pot == 0 || totalWeight == 0) revert NothingToDistribute();

        r.round += 1;
        r.startedAt = uint64(block.timestamp);
        r.pot = pot;
        r.remaining = pot;
        r.totalWeight = totalWeight;

        emit RoundStarted(token, r.round, pot, totalWeight);
    }

    /// @notice Clock in: claim the current-round shares of `tokens` for each
    ///         broker in `tokenIds`. Callable by anyone; every share is paid to
    ///         the broker's token-bound wallet, never the caller. Already-claimed
    ///         or zero-share entries are skipped silently so batches are easy.
    function clockIn(address[] calldata tokens, uint256[] calldata tokenIds) external nonReentrant {
        uint256 nTokens = tokens.length;
        uint256 nIds = tokenIds.length;
        if (nTokens == 0 || nIds == 0) revert EmptyClaim();

        for (uint256 t = 0; t < nTokens; t++) {
            address token = tokens[t];
            Round storage r = rounds[token];
            uint64 round = r.round;
            if (round == 0 || r.remaining == 0) continue;

            for (uint256 i = 0; i < nIds; i++) {
                uint256 tokenId = tokenIds[i];
                if (claimed[token][round][tokenId]) continue;
                claimed[token][round][tokenId] = true;

                uint256 weight = activation.activeWeight(tokenId);
                if (weight == 0) continue;

                address wallet = brokerNft.tokenWallet(tokenId);
                if (wallet == address(0)) continue;

                uint256 share = (r.pot * weight) / r.totalWeight;
                if (share > r.remaining) share = r.remaining;
                if (share == 0) continue;

                // The caller chose this token list, so a failed transfer reverts
                // the whole claim instead of silently burning the claim flag.
                if (!_tryTransfer(token, wallet, share)) revert ClaimTransferFailed();
                r.remaining -= share;
                emit ClockedIn(token, round, tokenId, wallet, share);
            }
        }
    }

    /// @notice View helper: the share `tokenId` could claim right now for `token`
    ///         (0 if no round, already claimed, inactive broker, or empty pot).
    function claimable(address token, uint256 tokenId) external view returns (uint256) {
        Round storage r = rounds[token];
        uint64 round = r.round;
        if (round == 0 || r.remaining == 0) return 0;
        if (claimed[token][round][tokenId]) return 0;
        uint256 weight = activation.activeWeight(tokenId);
        if (weight == 0) return 0;
        if (brokerNft.tokenWallet(tokenId) == address(0)) return 0;
        uint256 share = (r.pot * weight) / r.totalWeight;
        return share > r.remaining ? r.remaining : share;
    }

    /// @dev Non-reverting ERC-20 transfer: tolerates missing return data, treats a
    ///      false return or revert as failure.
    function _tryTransfer(address token, address to, uint256 amount) internal returns (bool) {
        (bool ok, bytes memory ret) = token.call(abi.encodeCall(IERC20Minimal.transfer, (to, amount)));
        return ok && (ret.length == 0 || abi.decode(ret, (bool)));
    }
}
