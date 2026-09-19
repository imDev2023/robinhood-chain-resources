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

/// @title SafetyDepositClockInV3
/// @notice Receiver for Safety Deposit Box (v3 + v4 locker) protocol fees.
///
///         v3 = v2's pull-based clock-in plus a fixed **90/10 split**: 90% of
///         every inflow goes to the process (ETH/WETH → StockBooster, other
///         tokens → broker claim rounds) and 10% goes to the protocol wallet.
///
///         - ETH and WETH are flushed permissionlessly; each flush pays 10%
///           to the protocol wallet and 90% to the StockBooster.
///         - Every other token accrues into weekly rounds. `startRound(token)`
///           skims 10% of the *new* funds since the previous round (rollover
///           from unclaimed shares was already skimmed once and is never
///           taxed again), then snapshots the remaining pot + activation
///           weight; each broker claims their weight-proportional share via
///           `clockIn` into their ERC-6551 token-bound wallet.
///
///         Claims are permissionless *triggers* but pinned *destinations*:
///         anyone may clock in on behalf of any broker tokenId, and the funds
///         always land in that broker's token-bound wallet — never the caller.
///         The contract is ownerless: the protocol wallet is immutable and
///         only ever receives its fixed 10%; there is no configuration and no
///         privileged withdrawal path.
contract SafetyDepositClockInV3 {
    error NothingToDistribute();
    error RoundTooYoung();
    error WethNotAirdroppable();
    error EthFlushFailed();
    error ClaimTransferFailed();
    error ProtocolTransferFailed();
    error EmptyClaim();
    error Reentrancy();

    event EthFlushed(uint256 boosterAmount, uint256 protocolAmount);
    event ProtocolCutPaid(address indexed token, uint256 amount);
    event RoundStarted(address indexed token, uint64 indexed round, uint256 pot, uint256 totalWeight);
    event ClockedIn(
        address indexed token, uint64 indexed round, uint256 indexed tokenId, address wallet, uint256 amount
    );

    /// @notice Minimum age of a round before it can be superseded. Bounds the
    ///         claim window brokers can rely on and stops rapid-restart griefing
    ///         (restarting recomputes everyone's shares against a fresh pot).
    uint64 public constant ROUND_COOLDOWN = 7 days;

    /// @notice Protocol's fixed cut of every inflow, in basis points (10%).
    uint256 public constant PROTOCOL_BPS = 1000;
    uint256 public constant BPS = 10_000;

    address public immutable stockBooster;
    address public immutable protocolWallet;
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

    constructor(
        address stockBooster_,
        address protocolWallet_,
        address activation_,
        address brokerNft_,
        address weth_
    ) {
        require(
            stockBooster_ != address(0) && protocolWallet_ != address(0) && activation_ != address(0)
                && brokerNft_ != address(0) && weth_ != address(0),
            "zero addr"
        );
        stockBooster = stockBooster_;
        protocolWallet = protocolWallet_;
        activation = IActivationManager(activation_);
        brokerNft = IBrokerNft(brokerNft_);
        weth = IWeth(weth_);
    }

    /// @notice Accept ETH from the locker's protocol fee payouts (and anyone else).
    receive() external payable {}

    /// @notice Split the full ETH balance: 10% to the protocol wallet, 90% to the
    ///         StockBooster. Permissionless: both destinations are hardwired, so
    ///         there is nothing a caller can abuse.
    function flushEth() external nonReentrant {
        uint256 bal = address(this).balance;
        if (bal == 0) revert NothingToDistribute();
        _flushSplit(bal);
    }

    /// @notice Unwrap the full WETH balance and split it like ETH. The v3 locker
    ///         pays its native-side protocol fees in WETH, which is ETH in
    ///         disguise and must follow the ETH flow, not the claim flow.
    function flushWeth() external nonReentrant {
        uint256 bal = weth.balanceOf(address(this));
        if (bal == 0) revert NothingToDistribute();
        weth.withdraw(bal);
        // Split the full ETH balance (covers any stray ETH too, same as flushEth).
        _flushSplit(address(this).balance);
    }

    function _flushSplit(uint256 bal) internal {
        uint256 protocolCut = (bal * PROTOCOL_BPS) / BPS;
        uint256 boosterAmount = bal - protocolCut;
        if (protocolCut > 0) {
            (bool okP,) = protocolWallet.call{value: protocolCut}("");
            if (!okP) revert EthFlushFailed();
        }
        (bool ok,) = stockBooster.call{value: boosterAmount}("");
        if (!ok) revert EthFlushFailed();
        emit EthFlushed(boosterAmount, protocolCut);
    }

    /// @notice Open a new claim round for `token`. First pays the protocol its
    ///         10% of the funds that arrived since the previous round (the
    ///         unclaimed remainder rolling over was already skimmed when it
    ///         first arrived, so it is never taxed twice), then snapshots the
    ///         rest as the pot together with the current total activation
    ///         weight. Permissionless, but a live round can only be superseded
    ///         after ROUND_COOLDOWN — or immediately once it is fully claimed.
    function startRound(address token) external nonReentrant {
        if (token == address(weth)) revert WethNotAirdroppable();
        Round storage r = rounds[token];
        if (r.round > 0 && r.remaining > 0 && block.timestamp < r.startedAt + ROUND_COOLDOWN) {
            revert RoundTooYoung();
        }

        uint256 bal = IERC20Minimal(token).balanceOf(address(this));
        // Rollover (r.remaining) was skimmed in the round it arrived; only the
        // delta on top of it is new, untaxed inflow.
        uint256 newFunds = bal > r.remaining ? bal - r.remaining : 0;
        uint256 protocolCut = (newFunds * PROTOCOL_BPS) / BPS;
        if (protocolCut > 0) {
            if (!_tryTransfer(token, protocolWallet, protocolCut)) revert ProtocolTransferFailed();
            emit ProtocolCutPaid(token, protocolCut);
            bal -= protocolCut;
        }

        uint256 totalWeight = activation.totalActiveWeight();
        if (bal == 0 || totalWeight == 0) revert NothingToDistribute();

        r.round += 1;
        r.startedAt = uint64(block.timestamp);
        r.pot = bal;
        r.remaining = bal;
        r.totalWeight = totalWeight;

        emit RoundStarted(token, r.round, bal, totalWeight);
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
