// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IACPHook.sol";
import "../AgenticCommerceV3.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @title BaseACPHook
 * @dev Abstract convenience base for ACP hooks. Routes the generic
 *      beforeAction/afterAction calls to named virtual functions so hook
 *      developers only override what they need.
 *
 *      NOT part of the ERC standard — this is a helper contract that can be
 *      updated independently without changing the IACPHook interface.
 *
 *      All virtual functions include an `address caller` parameter because
 *      AgenticCommerceV3 supports operators, so the actual caller matters.
 *
 *      Data encoding per selector (as produced by AgenticCommerceV3):
 *        setBudget   : abi.encode(caller, amount, optParams)
 *        fund        : abi.encode(caller, optParams)
 *        submit      : abi.encode(caller, deliverable, optParams)
 *        complete    : abi.encode(caller, reason, optParams)
 *        reject      : abi.encode(caller, reason, optParams)
 *
 *      Example:
 *          contract MyHook is BaseACPHook {
 *              constructor(address acp) BaseACPHook(acp) {}
 *              function _postFund(uint256 jobId, address caller, bytes memory optParams) internal override {
 *                  // custom logic after fund
 *              }
 *          }
 */
abstract contract BaseACPHook is ERC165, IACPHook {
    /// @notice The ACP core contract (or MultiHookRouter) that is authorized to call this hook
    address public immutable acpContract;

    /// @notice Thrown when the caller is not the ACP contract
    error OnlyACPContract();

    /// @dev Restricts access to the ACP core contract or the hook registered for the job.
    ///      Standalone: msg.sender must be acpContract (core).
    ///      Behind router: msg.sender must be the hook registered on core for this jobId.
    modifier onlyACP(uint256 jobId) {
        if (msg.sender != acpContract) {
            AgenticCommerceV3.Job memory job = AgenticCommerceV3(acpContract)
                .getJob(jobId);
            if (msg.sender != job.hook) revert OnlyACPContract();
        }
        _;
    }

    /// @param acpContract_ The ACP core contract address
    constructor(address acpContract_) {
        acpContract = acpContract_;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IACPHook).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // --- Selector constants (avoid repeated keccak at runtime) ----------------
    // These match AgenticCommerceV3 function selectors.
    bytes4 private constant SEL_SET_BUDGET =
        bytes4(keccak256("setBudget(uint256,uint256,bytes)"));
    bytes4 private constant SEL_FUND = 
        bytes4(keccak256("fund(uint256,uint256,bytes)"));
    bytes4 private constant SEL_SUBMIT =
        bytes4(keccak256("submit(uint256,bytes32,bytes)"));
    bytes4 private constant SEL_COMPLETE =
        bytes4(keccak256("complete(uint256,bytes32,bytes)"));
    bytes4 private constant SEL_REJECT =
        bytes4(keccak256("reject(uint256,bytes32,bytes)"));

    // --- IACPHook implementation (router) ------------------------------------

    function beforeAction(
        uint256 jobId,
        bytes4 selector,
        bytes calldata data
    ) external override onlyACP(jobId) {
        if (selector == SEL_SET_BUDGET) {
            (address caller, uint256 amount, bytes memory optParams) = abi
                .decode(data, (address, uint256, bytes));
            _preSetBudget(jobId, caller, amount, optParams);
        } else if (selector == SEL_FUND) {
            (address caller, bytes memory optParams) = abi.decode(
                data,
                (address, bytes)
            );
            _preFund(jobId, caller, optParams);
        } else if (selector == SEL_SUBMIT) {
            (address caller, bytes32 deliverable, bytes memory optParams) = abi
                .decode(data, (address, bytes32, bytes));
            _preSubmit(jobId, caller, deliverable, optParams);
        } else if (selector == SEL_COMPLETE) {
            (address caller, bytes32 reason, bytes memory optParams) = abi
                .decode(data, (address, bytes32, bytes));
            _preComplete(jobId, caller, reason, optParams);
        } else if (selector == SEL_REJECT) {
            (address caller, bytes32 reason, bytes memory optParams) = abi
                .decode(data, (address, bytes32, bytes));
            _preReject(jobId, caller, reason, optParams);
        }
    }

    function afterAction(
        uint256 jobId,
        bytes4 selector,
        bytes calldata data
    ) external override onlyACP(jobId) {
        if (selector == SEL_SET_BUDGET) {
            (address caller, uint256 amount, bytes memory optParams) = abi
                .decode(data, (address, uint256, bytes));
            _postSetBudget(jobId, caller, amount, optParams);
        } else if (selector == SEL_FUND) {
            (address caller, bytes memory optParams) = abi.decode(
                data,
                (address, bytes)
            );
            _postFund(jobId, caller, optParams);
        } else if (selector == SEL_SUBMIT) {
            (address caller, bytes32 deliverable, bytes memory optParams) = abi
                .decode(data, (address, bytes32, bytes));
            _postSubmit(jobId, caller, deliverable, optParams);
        } else if (selector == SEL_COMPLETE) {
            (address caller, bytes32 reason, bytes memory optParams) = abi
                .decode(data, (address, bytes32, bytes));
            _postComplete(jobId, caller, reason, optParams);
        } else if (selector == SEL_REJECT) {
            (address caller, bytes32 reason, bytes memory optParams) = abi
                .decode(data, (address, bytes32, bytes));
            _postReject(jobId, caller, reason, optParams);
        }
    }

    // --- Virtual functions (override what you need) --------------------------
    // Each pair corresponds to a core lifecycle function.
    // _pre* is called from beforeAction (can revert to block the transition).
    // _post* is called from afterAction (for bookkeeping / side effects).

    /// @dev Called before setBudget executes on core. Override to gate budget changes.
    function _preSetBudget(
        uint256 jobId,
        address caller,
        uint256 amount,
        bytes memory optParams
    ) internal virtual {}
    /// @dev Called after setBudget executes on core. Override for bookkeeping.
    function _postSetBudget(
        uint256 jobId,
        address caller,
        uint256 amount,
        bytes memory optParams
    ) internal virtual {}

    /// @dev Called before fund executes on core. Override to gate funding.
    function _preFund(
        uint256 jobId,
        address caller,
        bytes memory optParams
    ) internal virtual {}
    /// @dev Called after fund executes on core. Override for bookkeeping.
    function _postFund(
        uint256 jobId,
        address caller,
        bytes memory optParams
    ) internal virtual {}

    /// @dev Called before submit executes on core. Override to gate submissions.
    function _preSubmit(
        uint256 jobId,
        address caller,
        bytes32 deliverable,
        bytes memory optParams
    ) internal virtual {}
    /// @dev Called after submit executes on core. Override for bookkeeping.
    function _postSubmit(
        uint256 jobId,
        address caller,
        bytes32 deliverable,
        bytes memory optParams
    ) internal virtual {}

    /// @dev Called before complete executes on core. Override to gate completion.
    function _preComplete(
        uint256 jobId,
        address caller,
        bytes32 reason,
        bytes memory optParams
    ) internal virtual {}
    /// @dev Called after complete executes on core. Override for bookkeeping.
    ///      NOTE: On auto-complete (no evaluator), caller is address(0) and reason
    ///      contains the deliverable hash. Check caller == address(0) to distinguish
    ///      auto-complete from evaluator-driven completion.
    function _postComplete(
        uint256 jobId,
        address caller,
        bytes32 reason,
        bytes memory optParams
    ) internal virtual {}

    /// @dev Called before reject executes on core. Override to gate rejection.
    function _preReject(
        uint256 jobId,
        address caller,
        bytes32 reason,
        bytes memory optParams
    ) internal virtual {}
    /// @dev Called after reject executes on core. Override for bookkeeping.
    function _postReject(
        uint256 jobId,
        address caller,
        bytes32 reason,
        bytes memory optParams
    ) internal virtual {}
}
