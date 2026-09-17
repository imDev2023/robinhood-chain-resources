// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./BaseACPHook.sol";
import "../interfaces/IACPHookMetadata.sol";
import "../AgenticCommerceV3.sol";

/// @title FundTransferHook
/// @notice ACP hook that handles token transfers and escrow via intents.
///         Provider proposes a fund request intent via setBudget optParams.
///         Client confirms and auto-signs via fund optParams.
///         Provider can escrow tokens at submit time; escrow releases on
///         complete or refunds on reject/expiry.
/// @dev    This hook NEVER calls core functions — it only reacts to core
///         lifecycle events via before/after hooks.
///
///         OptParams encoding per hook:
///           setBudget: abi.encode(address token, uint256 amount, address destination)
///           fund:      abi.encode(address token, uint256 amount, address recipient)
///           submit:    abi.encode(address token, uint256 amount)
///           complete:  ignored
///           reject:    ignored
contract FundTransferHook is BaseACPHook, ReentrancyGuard, IACPHookMetadata {
    using SafeERC20 for IERC20;

    // ──────────────────── Types ────────────────────

    /// @notice Represents a pending or completed fund transfer between two parties.
    /// @param jobId     The ACP job this intent belongs to
    /// @param amount    Token amount to transfer (0 = message-only intent)
    /// @param actor     Address that created the intent (provider or client)
    /// @param isEscrow  True if tokens are held by this contract until signed
    /// @param isSigned  True after the intent has been signed (executed or rejected)
    /// @param from      Payer / depositor address
    /// @param token     ERC-20 token address
    /// @param recipient Destination address for the transfer
    struct Intent {
        uint256 jobId;       // 32 ─── slot 0
        uint256 amount;      // 32 ─── slot 1
        address actor;       // 20 ──┐ slot 2
        bool isEscrow;       // 1  ──┤
        bool isSigned;       // 1  ──┘
        address from;        // 20 ─── slot 3 (payer/depositor)
        address token;       // 20 ─── slot 4
        address recipient;   // 20 ─── slot 5
    }

    // ──────────────────── Storage ────────────────────

    uint256 public intentCounter;

    mapping(uint256 => Intent) public intents;
    mapping(uint256 jobId => uint256 intentId) public fundRequestIntentId;

    mapping(uint256 jobId => uint256 intentId) public providerEscrowIntentId;

    // ──────────────────── Events ────────────────────

    /// @notice Emitted when a new intent is created for a job
    event NewIntent(uint256 indexed jobId, address indexed actor, uint256 intentId);

    /// @notice Emitted when an intent is signed (approved or rejected)
    event IntentSigned(
        uint256 indexed intentId,
        address indexed signer,
        bool isApproved
    );

    /// @notice Emitted when a token transfer is executed (direct or from escrow)
    event PayableTransferExecuted(
        uint256 indexed jobId,
        uint256 indexed intentId,
        address from,
        address to,
        address token,
        uint256 amount
    );

    /// @notice Emitted when escrowed tokens are refunded to the depositor
    event PayableFundsRefunded(
        uint256 indexed jobId,
        uint256 indexed intentId,
        address sender,
        address token,
        uint256 amount
    );
    // ──────────────────── Errors ────────────────────

    /// @notice Thrown when the job is not in the expected status
    error WrongStatus();
    /// @notice Thrown when attempting to sign an already-signed intent
    error AlreadySigned();
    /// @notice Thrown when client's fund optParams do not match the stored intent
    error IntentMismatch();
    /// @notice Thrown when a no-evaluator job is submitted without escrow
    error EscrowRequiredWithoutEvaluator();

    // ──────────────────── Constructor ────────────────────

    constructor(address coreAddress) BaseACPHook(coreAddress) {}

    /// @dev Typed accessor for the core contract
    function _core() internal view returns (AgenticCommerceV3) {
        return AgenticCommerceV3(acpContract);
    }

    // ──────────────────── After hooks (bookkeeping + funds transfers) ──

    /// @dev Validates client's optParams against stored intent and auto-signs.
    function _postFund(
        uint256 jobId,
        address caller,
        bytes memory optParams
    ) internal override {
        uint256 intentId = fundRequestIntentId[jobId];
        if (intentId != 0) {
            if (optParams.length > 0) {
                (address expectedToken, uint256 expectedAmount, address expectedRecipient) =
                    abi.decode(optParams, (address, uint256, address));
                Intent storage intent = intents[intentId];
                if (intent.token != expectedToken) revert IntentMismatch();
                if (intent.amount != expectedAmount) revert IntentMismatch();
                if (intent.recipient != expectedRecipient) revert IntentMismatch();
            } else {
                revert IntentMismatch(); // client must acknowledge intent params
            }
            _autoSignIntent(intentId, caller, true);
        }
    }

    /// @dev If optParams provided, create escrow intent for fund request.
    ///      Otherwise, create message intent for budget approval.
    function _postSetBudget(
        uint256 jobId,
        address caller,
        uint256,
        bytes memory optParams
    ) internal override {
        if (optParams.length > 0) {
            (address token, uint256 amount, address destination) = abi.decode(
                optParams,
                (address, uint256, address)
            );

            // Clean up any existing intent before creating or clearing
            uint256 oldIntentId = fundRequestIntentId[jobId];
            if (oldIntentId != 0) {
                delete intents[oldIntentId];
                delete fundRequestIntentId[jobId];
            }

            if (token != address(0)) {
                AgenticCommerceV3.Job memory job = _core().getJob(jobId);
                uint256 intentId = _storeIntent(
                    jobId,
                    caller,
                    false,
                    job.client,
                    token,
                    amount,
                    destination
                );
                fundRequestIntentId[jobId] = intentId;
            }
        }
    }

    /// @dev Creates a provider escrow intent on submit.
    ///      optParams: abi.encode(address token, uint256 amount)
    ///      Reverts if no evaluator and no escrow provided.
    function _postSubmit(
        uint256 jobId,
        address caller,
        bytes32,
        bytes memory optParams
    ) internal override {
        AgenticCommerceV3.Job memory job = _core().getJob(jobId);
        if (job.evaluator == address(0) && optParams.length == 0) revert EscrowRequiredWithoutEvaluator();
        if (optParams.length > 0) {
            (address token, uint256 amount) = abi.decode(
                optParams,
                (address, uint256)
            );

            uint256 oldEscrowIntentId = providerEscrowIntentId[jobId];
            if (oldEscrowIntentId != 0 && !intents[oldEscrowIntentId].isSigned) {
                _autoSignIntent(oldEscrowIntentId, caller, false);
            }

            _storeIntent(jobId, caller, true, caller, token, amount, job.client);
        }
    }

    /// @dev Releases provider escrow on job completion by approving the escrow intent.
    function _postComplete(
        uint256 jobId,
        address caller,
        bytes32,
        bytes memory
    ) internal override {
        uint256 escrowIntentId = providerEscrowIntentId[jobId];
        if (escrowIntentId != 0) {
            _autoSignIntent(escrowIntentId, caller, true);
        }
    }

    /// @dev Refunds provider escrow on job rejection by rejecting the escrow intent.
    function _postReject(
        uint256 jobId,
        address caller,
        bytes32,
        bytes memory
    ) internal override {
        uint256 escrowIntentId = providerEscrowIntentId[jobId];
        if (escrowIntentId != 0) {
            _autoSignIntent(escrowIntentId, caller, false);
        }
    }

    // ──────────────────── Escrow Refund (not hookable — called directly) ──

    /// @notice Refunds escrowed provider tokens (e.g. cbBTC) after the job reaches
    ///         a terminal state (Expired, Completed, or Rejected).
    /// @dev    Anyone can call this — the only guard is that the core job is terminal.
    ///         Covers two scenarios:
    ///         1. Normal expiry — claimRefund on core is NOT hookable, so the hook
    ///            cannot auto-refund escrowed tokens via afterAction.
    ///         2. Hook detach — if admin detaches the hook via batchDetachHook while
    ///            provider escrow is held, complete/reject no longer trigger afterAction,
    ///            so the provider needs a direct recovery path.
    function claimEscrowRefund(uint256 jobId) external {
        AgenticCommerceV3.Job memory job = _core().getJob(jobId);
        AgenticCommerceV3.JobStatus s = job.status;
        if (
            s != AgenticCommerceV3.JobStatus.Expired &&
            s != AgenticCommerceV3.JobStatus.Completed &&
            s != AgenticCommerceV3.JobStatus.Rejected
        ) revert WrongStatus();

        uint256 escrowIntentId = providerEscrowIntentId[jobId];
        if (escrowIntentId > 0) {
            _autoSignIntent(escrowIntentId, job.provider, false);
        }
    }

    // ──────────────────── ERC165 ────────────────────

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(BaseACPHook) returns (bool) {
        return
            interfaceId == type(IACPHookMetadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // ──────────────────── IACPHookMetadata ────────────────────

    /// @notice Returns the selectors FundTransferHook requires: fund, submit, complete, reject.
    /// @dev setBudget is NOT required -- _postSetBudget only does optional cleanup.
    function requiredSelectors() external pure override returns (bytes4[] memory) {
        bytes4[] memory sels = new bytes4[](4);
        sels[0] = bytes4(keccak256("fund(uint256,uint256,bytes)"));
        sels[1] = bytes4(keccak256("submit(uint256,bytes32,bytes)"));
        sels[2] = bytes4(keccak256("complete(uint256,bytes32,bytes)"));
        sels[3] = bytes4(keccak256("reject(uint256,bytes32,bytes)"));
        return sels;
    }

    // ──────────────────── View ────────────────────

    /// @notice Returns the intent details for a given intent ID
    /// @param intentId The intent ID to look up
    /// @return The Intent struct
    function getIntent(uint256 intentId) external view returns (Intent memory) {
        return intents[intentId];
    }

    // ──────────────────── Internal ────────────────────

    /// @dev Unified auto-sign handler. Records signature, executes payable intent if any, emits IntentSigned.
    function _autoSignIntent(
        uint256 intentId,
        address signer,
        bool isApproved
    ) internal nonReentrant {
        if (intents[intentId].isSigned) revert AlreadySigned();
        Intent storage intent = intents[intentId];
        intent.isSigned = true;

        if (isApproved) {
            _executePayableIntent(intentId, intent);
        } else {
            if (intent.isEscrow) {
                _refundEscrowedFunds(intentId, intent);
            }
        }

        emit IntentSigned(intentId, signer, isApproved);
    }

    /// @dev Creates and stores a new intent. If escrow, pulls tokens from `from` into this contract.
    function _storeIntent(
        uint256 jobId,
        address actor,
        bool isEscrow,
        address from,
        address token,
        uint256 amount,
        address recipient
    ) internal returns (uint256 intentId) {
        intentId = ++intentCounter;
        intents[intentId] = Intent({
            jobId: jobId,
            amount: amount,
            actor: actor,
            isEscrow: isEscrow,
            isSigned: false,
            from: from,
            token: token,
            recipient: recipient
        });
        emit NewIntent(jobId, actor, intentId);

        if (isEscrow && amount > 0) {
            IERC20(token).safeTransferFrom(from, address(this), amount);
            providerEscrowIntentId[jobId] = intentId;
        }
    }

    /// @dev Transfers tokens to the recipient. Uses safeTransfer for escrow, safeTransferFrom for direct.
    function _executePayableIntent(uint256 intentId, Intent storage intent) internal {
        address token = intent.token;
        uint256 amount = intent.amount;
        address recipient = intent.recipient;

        if (amount > 0) {
            if (intent.isEscrow) {
                IERC20(token).safeTransfer(recipient, amount);
            } else {
                IERC20(token).safeTransferFrom(intent.from, recipient, amount);
            }
            emit PayableTransferExecuted(
                intent.jobId,
                intentId,
                intent.from,
                recipient,
                token,
                amount
            );
        }
    }

    /// @dev Returns escrowed tokens to the original depositor.
    function _refundEscrowedFunds(uint256 intentId, Intent storage intent) internal {
        if (intent.amount > 0) {
            IERC20(intent.token).safeTransfer(intent.from, intent.amount);
        }

        emit PayableFundsRefunded(
            intent.jobId,
            intentId,
            intent.from,
            intent.token,
            intent.amount
        );
    }
}
