// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

/// @title ILighterBridge — the subset of Lighter's zk-rollup bridge used by LongX.
/// @notice Robinhood Chain (4663) proxy: 0x94bAB9693Ba2f6358507eFfcbd372b0660AFfF9d.
///         Signatures were extracted from the Blockscout-verified Ethereum ZkLighter
///         implementation (0x8D692294a4824d868e35B3CEcd734aCf41B2342e), which is
///         selector-matched to the (unverified) 4663 implementation.
///
///         Authorization is purely msg.sender-based: the address that deposits owns
///         the resulting L2 account, which is what lets a contract be an account owner.
///
/// @dev Runtime unknowns (parameterized in LongXVault — see
///      POC_RUNBOOK.md): assetIndex for USDG, routeType semantics, the orderType
///      enum value for reduce-only forced orders, the pubkey byte format accepted
///      by changePubKey, and deposit/withdraw amount scaling vs event baseAmount.
/// @notice zkLighter's per-batch commitment record (Storage.sol). The bridge
///         stores `keccak256(abi.encode(info))` in `storedBatchHashes` at
///         COMMIT time, so supplying the preimage proves a batch's stateRoot
///         is a committed one — the anchor for committed-basis proofs.
struct StoredBatchInfo {
    uint64 batchNumber;
    uint64 endBlockNumber;
    uint32 batchSize;
    uint64 startTimestamp;
    uint64 endTimestamp;
    uint32 priorityRequestCount;
    bytes32 prefixPriorityRequestHash;
    bytes32 onChainOperationsHash;
    bytes32 stateRoot;
    bytes32 validiumRoot;
    bytes32 commitment;
}

interface ILighterBridge {
    // ------------------------------------------------------------ mutations
    /// @notice Deposits `_amount` of asset `_assetIndex` to `_to`'s L2 account.
    ///         The first deposit for an address atomically creates the account
    ///         and registers the address as its owner.
    function deposit(address _to, uint16 _assetIndex, uint8 _routeType, uint256 _amount) external;

    /// @notice Installs or rotates the L2 signing key at `_apiKeyIndex` on the account.
    ///         Rejects zero / non-canonical pubkeys. Travels the priority queue.
    function changePubKey(uint48 _accountIndex, uint8 _apiKeyIndex, bytes calldata _pubKey) external;

    /// @notice Forced order via the priority queue (reduce-only semantics expected
    ///         to be expressed through `_orderType` — exact enum value unconfirmed).
    function createOrder(
        uint48 _accountIndex,
        uint16 _marketIndex,
        uint48 _baseAmount,
        uint32 _price,
        uint8 _isAsk,
        uint8 _orderType
    ) external;

    /// @notice Forced cancellation of all the account's resting orders.
    function cancelAllOrders(uint48 _accountIndex) external;

    /// @notice Forced withdrawal via the priority queue. Funds become claimable
    ///         via withdrawPendingBalance after batch execution (~15-40 min).
    function withdraw(uint48 _accountIndex, uint16 _assetIndex, uint8 _routeType, uint64 _baseAmount) external;

    /// @notice Claims finalized withdrawals back to `owner` on Robinhood Chain.
    function withdrawPendingBalance(address owner, uint16 assetIndex, uint128 amount) external;

    // ------------------------------------------------------------ views
    function addressToAccountIndex(address) external view returns (uint48);
    /// @notice Withdrawn-but-unclaimed balance credited to `owner` once the
    ///         batch carrying the withdrawal EXECUTES on L1 (verify+execute
    ///         lag, ~20-60 min after commit).
    function getPendingBalance(address owner, uint16 assetIndex) external view returns (uint128);
    /// @notice keccak256(abi.encode(StoredBatchInfo)) per committed batch.
    ///         Written at commit; deleted ONLY by revertBatches — entries
    ///         survive verification and execution.
    function storedBatchHashes(uint64 batchNumber) external view returns (bytes32);
    function stateRoot() external view returns (bytes32);
    function lastVerifiedStateRoot() external view returns (bytes32);
    function verifiedBatchesCount() external view returns (uint64);
    function committedBatchesCount() external view returns (uint64);
    function executedBatchesCount() external view returns (uint64);
    function openPriorityRequestCount() external view returns (uint64);
    function committedPriorityRequestCount() external view returns (uint64);
    function verifiedPriorityRequestCount() external view returns (uint64);
    function executedPriorityRequestCount() external view returns (uint64);
    function PRIORITY_EXPIRATION() external view returns (uint256);

    // ------------------------------------------------------------ events
    event Deposit(uint48 toAccountIndex, address toAddress, uint16 assetIndex, uint8 routeType, uint128 baseAmount);
    event NewPriorityRequest(
        address sender, uint64 serialId, uint8 pubdataType, bytes pubData, uint64 expirationTimestamp
    );
    event WithdrawPending(address owner, uint16 assetIndex, uint128 baseAmount);
}
