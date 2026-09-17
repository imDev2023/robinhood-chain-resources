Title: Governance

URL Source: https://docs.openzeppelin.com/contracts/4.x/api/governance

Markdown Content:
This directory includes primitives for on-chain governance.

This modular system of Governor contracts allows the deployment on-chain voting protocols similar to [Compound’s Governor Alpha & Bravo](https://compound.finance/docs/governance) and beyond, through the ability to easily customize multiple aspects of the protocol.

*   [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor): The core contract that contains all the logic and primitives. It is abstract and requires choosing one of each of the modules below, or custom ones.

Votes modules determine the source of voting power, and sometimes quorum number.

*   [`GovernorVotes`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotes): Extracts voting weight from an [`ERC20Votes`](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC20#ERC20Votes), or since v4.5 an [`ERC721Votes`](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC721#ERC721Votes) token.
*   [`GovernorVotesComp`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesComp): Extracts voting weight from a COMP-like or [`ERC20VotesComp`](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC20#ERC20VotesComp) token.
*   [`GovernorVotesQuorumFraction`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction): Combines with `GovernorVotes` to set the quorum as a fraction of the total token supply.

Counting modules determine valid voting options.

*   [`GovernorCountingSimple`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCountingSimple): Simple voting mechanism with 3 voting options: Against, For and Abstain.

Timelock extensions add a delay for governance decisions to be executed. The workflow is extended to require a `queue` step before execution. With these modules, proposals are executed by the external timelock contract, thus it is the timelock that has to hold the assets that are being governed.

*   [`GovernorTimelockControl`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl): Connects with an instance of [`TimelockController`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController). Allows multiple proposers and executors, in addition to the Governor itself.
*   [`GovernorTimelockCompound`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound): Connects with an instance of Compound’s [`Timelock`](https://github.com/compound-finance/compound-protocol/blob/master/contracts/Timelock.sol) contract.

Other extensions can customize the behavior or interface in multiple ways.

*   [`GovernorCompatibilityBravo`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo): Extends the interface to be fully `GovernorBravo`-compatible. Note that events are compatible regardless of whether this extension is included or not.
*   [`GovernorSettings`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings): Manages some of the settings (voting delay, voting period duration, and proposal threshold) in a way that can be updated through a governance proposal, without requiring an upgrade.
*   [`GovernorPreventLateQuorum`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum): Ensures there is a minimum voting period after quorum is reached as a security protection against large voters.

In addition to modules and extensions, the core contract requires a few virtual functions to be implemented to your particular specifications:

*   [`votingDelay()`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-votingDelay-): Delay (in EIP-6372 clock) since the proposal is submitted until voting power is fixed and voting starts. This can be used to enforce a delay after a proposal is published for users to buy tokens, or delegate their votes.
*   [`votingPeriod()`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-votingPeriod-): Delay (in EIP-6372 clock) since the proposal starts until voting ends.
*   [`quorum(uint256 timepoint)`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-quorum-uint256-): Quorum required for a proposal to be successful. This function includes a `timepoint` argument (see EIP-6372) so the quorum can adapt through time, for example, to follow a token’s `totalSupply`.

Functions of the `Governor` contract do not include access control. If you want to restrict access, you should add these checks by overloading the particular functions. Among these, [`Governor._cancel`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_cancel-address---uint256---bytes---bytes32-) is internal by default, and you will have to expose it (with the right access control mechanism) yourself if this function is needed.

### [Core](https://docs.openzeppelin.com/contracts/4.x/api/governance#core)

[`IGovernor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor)

[`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor)

### [Modules](https://docs.openzeppelin.com/contracts/4.x/api/governance#modules)

[`GovernorCountingSimple`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCountingSimple)

[`GovernorVotes`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotes)

[`GovernorVotesQuorumFraction`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction)

[`GovernorVotesComp`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesComp)

### [Extensions](https://docs.openzeppelin.com/contracts/4.x/api/governance#extensions)

[`GovernorTimelockControl`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl)

[`GovernorTimelockCompound`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound)

[`GovernorSettings`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings)

[`GovernorPreventLateQuorum`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum)

[`GovernorCompatibilityBravo`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo)

### [Deprecated](https://docs.openzeppelin.com/contracts/4.x/api/governance#deprecated)

[`GovernorProposalThreshold`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorProposalThreshold)

[`Votes`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes)

In a governance system, the [`TimelockController`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController) contract is in charge of introducing a delay between a proposal and its execution. It can be used with or without a [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor).

[`TimelockController`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController)

#### [Terminology](https://docs.openzeppelin.com/contracts/4.x/api/governance#terminology)

*   **Operation:** A transaction (or a set of transactions) that is the subject of the timelock. It has to be scheduled by a proposer and executed by an executor. The timelock enforces a minimum delay between the proposition and the execution (see [operation lifecycle](https://docs.openzeppelin.com/contracts/4.x/access-control#operation_lifecycle)). If the operation contains multiple transactions (batch mode), they are executed atomically. Operations are identified by the hash of their content.
*   **Operation status:**
    *   **Unset:** An operation that is not part of the timelock mechanism.
    *   **Pending:** An operation that has been scheduled, before the timer expires.
    *   **Ready:** An operation that has been scheduled, after the timer expires.
    *   **Done:** An operation that has been executed.

*   **Predecessor**: An (optional) dependency between operations. An operation can depend on another operation (its predecessor), forcing the execution order of these two operations.
*   **Role**:
    *   **Admin:** An address (smart contract or EOA) that is in charge of granting the roles of Proposer and Executor.
    *   **Proposer:** An address (smart contract or EOA) that is in charge of scheduling (and cancelling) operations.
    *   **Executor:** An address (smart contract or EOA) that is in charge of executing operations once the timelock has expired. This role can be given to the zero address to allow anyone to execute operations.

#### [Operation structure](https://docs.openzeppelin.com/contracts/4.x/api/governance#operation-structure)

Operation executed by the [`TimelockController`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController) can contain one or multiple subsequent calls. Depending on whether you need to multiple calls to be executed atomically, you can either use simple or batched operations.

Both operations contain:

*   **Target**, the address of the smart contract that the timelock should operate on.
*   **Value**, in wei, that should be sent with the transaction. Most of the time this will be 0. Ether can be deposited before-end or passed along when executing the transaction.
*   **Data**, containing the encoded function selector and parameters of the call. This can be produced using a number of tools. For example, a maintenance operation granting role `ROLE` to `ACCOUNT` can be encoded using web3js as follows:

`const data = timelock.contract.methods.grantRole(ROLE, ACCOUNT).encodeABI()`

*   **Predecessor**, that specifies a dependency between operations. This dependency is optional. Use `bytes32(0)` if the operation does not have any dependency.
*   **Salt**, used to disambiguate two otherwise identical operations. This can be any random value.

In the case of batched operations, `target`, `value` and `data` are specified as arrays, which must be of the same length.

#### [Operation lifecycle](https://docs.openzeppelin.com/contracts/4.x/api/governance#operation-lifecycle)

Timelocked operations are identified by a unique id (their hash) and follow a specific lifecycle:

`Unset` ->`Pending` ->`Pending` + `Ready` ->`Done`

*   By calling [`schedule`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-schedule-address-uint256-bytes-bytes32-bytes32-uint256-) (or [`scheduleBatch`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-scheduleBatch-address---uint256---bytes---bytes32-bytes32-uint256-)), a proposer moves the operation from the `Unset` to the `Pending` state. This starts a timer that must be longer than the minimum delay. The timer expires at a timestamp accessible through the [`getTimestamp`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-getTimestamp-bytes32-) method.
*   Once the timer expires, the operation automatically gets the `Ready` state. At this point, it can be executed.
*   By calling [`execute`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-TimelockController-execute-address-uint256-bytes-bytes32-bytes32-) (or [`executeBatch`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-executeBatch-address---uint256---bytes---bytes32-bytes32-)), an executor triggers the operation’s underlying transactions and moves it to the `Done` state. If the operation has a predecessor, it has to be in the `Done` state for this transition to succeed.
*   [`cancel`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-TimelockController-cancel-bytes32-) allows proposers to cancel any `Pending` operation. This resets the operation to the `Unset` state. It is thus possible for a proposer to re-schedule an operation that has been cancelled. In this case, the timer restarts when the operation is re-scheduled.

Operations status can be queried using the functions:

*   [`isOperationPending(bytes32)`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-isOperationPending-bytes32-)
*   [`isOperationReady(bytes32)`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-isOperationReady-bytes32-)
*   [`isOperationDone(bytes32)`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-isOperationDone-bytes32-)

#### [Roles](https://docs.openzeppelin.com/contracts/4.x/api/governance#roles)

##### [Admin](https://docs.openzeppelin.com/contracts/4.x/api/governance#admin)

The admins are in charge of managing proposers and executors. For the timelock to be self-governed, this role should only be given to the timelock itself. Upon deployment, the admin role can be granted to any address (in addition to the timelock itself). After further configuration and testing, this optional admin should renounce its role such that all further maintenance operations have to go through the timelock process.

This role is identified by the **TIMELOCK_ADMIN_ROLE** value: `0x5f58e3a2316349923ce3780f8d587db2d72378aed66a8261c916544fa6846ca5`

##### [Proposer](https://docs.openzeppelin.com/contracts/4.x/api/governance#proposer)

The proposers are in charge of scheduling (and cancelling) operations. This is a critical role, that should be given to governing entities. This could be an EOA, a multisig, or a DAO.

**Proposer fight:** Having multiple proposers, while providing redundancy in case one becomes unavailable, can be dangerous. As proposer have their say on all operations, they could cancel operations they disagree with, including operations to remove them for the proposers.

This role is identified by the **PROPOSER_ROLE** value: `0xb09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc1`

##### [Executor](https://docs.openzeppelin.com/contracts/4.x/api/governance#executor)

The executors are in charge of executing the operations scheduled by the proposers once the timelock expires. Logic dictates that multisig or DAO that are proposers should also be executors in order to guarantee operations that have been scheduled will eventually be executed. However, having additional executors can reduce the cost (the executing transaction does not require validation by the multisig or DAO that proposed it), while ensuring whoever is in charge of execution cannot trigger actions that have not been scheduled by the proposers. Alternatively, it is possible to allow _any_ address to execute a proposal once the timelock has expired by granting the executor role to the zero address.

This role is identified by the **EXECUTOR_ROLE** value: `0xd8aa0f3194971a2a116679f7c2090f6939c8d4e01a2a8d7e41d55e5351469e63`

A live contract without at least one proposer and one executor is locked. Make sure these roles are filled by reliable entities before the deployer renounces its administrative rights in favour of the timelock contract itself. See the [`AccessControl`](https://docs.openzeppelin.com/contracts/4.x/api/access#AccessControl) documentation to learn more about role management.

`import "@openzeppelin/contracts/governance/Governor.sol";`

Core of the governance system, designed to be extended though various modules.

This contract is abstract and requires several functions to be implemented in various modules:

*   A counting module must implement [`IGovernor.quorum`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-quorum-uint256-), [`Governor._quorumReached`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_quorumReached-uint256-), [`Governor._voteSucceeded`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_voteSucceeded-uint256-) and [`Governor._countVote`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_countVote-uint256-address-uint8-uint256-bytes-)
*   A voting module must implement [`Governor._getVotes`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_getVotes-address-uint256-bytes-)
*   Additionally, [`IGovernor.votingPeriod`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--) must also be implemented

_Available since v4.3._

### Modifiers

*   [onlyGovernance()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onlyGovernance--)

### Functions

*   [constructor(name_)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-constructor-string-)
*   [receive()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-receive--)
*   [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-supportsInterface-bytes4-)
*   [name()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-name--)
*   [version()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-version--)
*   [hashProposal(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-hashProposal-address---uint256---bytes---bytes32-)
*   [state(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-state-uint256-)
*   [proposalThreshold()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalThreshold--)
*   [proposalSnapshot(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalSnapshot-uint256-)
*   [proposalDeadline(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalDeadline-uint256-)
*   [proposalProposer(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalProposer-uint256-)
*   [_quorumReached(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_quorumReached-uint256-)
*   [_voteSucceeded(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_voteSucceeded-uint256-)
*   [_getVotes(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_getVotes-address-uint256-bytes-)
*   [_countVote(proposalId, account, support, weight, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_countVote-uint256-address-uint8-uint256-bytes-)
*   [_defaultParams()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_defaultParams--)
*   [propose(targets, values, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-propose-address---uint256---bytes---string-)
*   [execute(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-execute-address---uint256---bytes---bytes32-)
*   [cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-cancel-address---uint256---bytes---bytes32-)
*   [_execute(, targets, values, calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_execute-uint256-address---uint256---bytes---bytes32-)
*   [_beforeExecute(, targets, , calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_beforeExecute-uint256-address---uint256---bytes---bytes32-)
*   [_afterExecute(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_afterExecute-uint256-address---uint256---bytes---bytes32-)
*   [_cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_cancel-address---uint256---bytes---bytes32-)
*   [getVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotes-address-uint256-)
*   [getVotesWithParams(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotesWithParams-address-uint256-bytes-)
*   [castVote(proposalId, support)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVote-uint256-uint8-)
*   [castVoteWithReason(proposalId, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReason-uint256-uint8-string-)
*   [castVoteWithReasonAndParams(proposalId, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
*   [castVoteBySig(proposalId, support, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
*   [castVoteWithReasonAndParamsBySig(proposalId, support, reason, params, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)
*   [_castVote(proposalId, account, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-)
*   [_castVote(proposalId, account, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-bytes-)
*   [relay(target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-relay-address-uint256-bytes-)
*   [_executor()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_executor--)
*   [onERC721Received(, , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC721Received-address-address-uint256-bytes-)
*   [onERC1155Received(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155Received-address-address-uint256-uint256-bytes-)
*   [onERC1155BatchReceived(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155BatchReceived-address-address-uint256---uint256---bytes-)
*   [_isValidDescriptionForProposer(proposer, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_isValidDescriptionForProposer-address-string-)
*   [BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-BALLOT_TYPEHASH-bytes32)
*   [EXTENDED_BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-EXTENDED_BALLOT_TYPEHASH-bytes32)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor)

*   [clock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-clock--)
*   [CLOCK_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-CLOCK_MODE--)
*   [COUNTING_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-COUNTING_MODE--)
*   [votingDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--)
*   [votingPeriod()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--)
*   [quorum(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-quorum-uint256-)
*   [hasVoted(proposalId, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hasVoted-uint256-address-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712)

*   [_domainSeparatorV4()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_domainSeparatorV4--)
*   [_hashTypedDataV4(structHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_hashTypedDataV4-bytes32-)
*   [eip712Domain()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-eip712Domain--)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165)

### Events

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-1)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-1)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-1)

*   [ProposalCreated(proposalId, proposer, targets, values, signatures, calldatas, voteStart, voteEnd, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-)
*   [ProposalCanceled(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-)
*   [ProposalExecuted(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-)
*   [VoteCast(voter, proposalId, support, weight, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-)
*   [VoteCastWithParams(voter, proposalId, support, weight, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-1)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-1)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-1)

*   [EIP712DomainChanged()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IERC5267-EIP712DomainChanged--)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-1)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-1)

onlyGovernance()

Restricts a function so it can only be executed through governance proposals. For example, governance parameter setters in [`GovernorSettings`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings) are protected using this modifier.

The governance executing address may be different from the Governor's own address, for example it could be a timelock. This can be customized by modules by overriding [`Governor._executor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_executor--). The executor is only able to invoke these functions during the execution of the governor's [`Governor.execute`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-execute-address---uint256---bytes---bytes32-) function, and not under any other circumstances. Thus, for example, additional timelock proposers are not able to change governance parameters without going through the governance protocol (since v4.6).

constructor(string name_)

Sets the value for [`Governor.name`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-name--) and [`Governor.version`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-version--)

receive()

Function to receive ETH that will be handled by the governor (disabled if executor is a third party contract)

supportsInterface(bytes4 interfaceId) → bool

name() → string

See [`IGovernor.name`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-name--).

version() → string

See [`IGovernor.version`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-version--).

hashProposal(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) → uint256

See [`IGovernor.hashProposal`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hashProposal-address---uint256---bytes---bytes32-).

The proposal id is produced by hashing the ABI encoded `targets` array, the `values` array, the `calldatas` array and the descriptionHash (bytes32 which itself is the keccak256 hash of the description string). This proposal id can be produced from the proposal data which is part of the [`IGovernor.ProposalCreated`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-) event. It can even be computed in advance, before the proposal is submitted.

Note that the chainId and the governor address are not part of the proposal id computation. Consequently, the same proposal (with same operation and same description) will have the same id if submitted on multiple governors across multiple networks. This also means that in order to execute the same operation twice (on the same governor) the proposer will have to change the description in order to avoid proposal id conflicts.

state(uint256 proposalId) → enum IGovernor.ProposalState

See [`IGovernor.state`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-state-uint256-).

proposalThreshold() → uint256

Part of the Governor Bravo's interface: _"The number of votes required in order for a voter to become a proposer"_.

proposalSnapshot(uint256 proposalId) → uint256

proposalDeadline(uint256 proposalId) → uint256

proposalProposer(uint256 proposalId) → address

Returns the account that created a given proposal.

_quorumReached(uint256 proposalId) → bool

Amount of votes already cast passes the threshold limit.

_voteSucceeded(uint256 proposalId) → bool

Is the proposal successful or not.

_getVotes(address account, uint256 timepoint, bytes params) → uint256

Get the voting weight of `account` at a specific `timepoint`, for a vote as described by `params`.

_countVote(uint256 proposalId, address account, uint8 support, uint256 weight, bytes params)

Register a vote for `proposalId` by `account` with a given `support`, voting `weight` and voting `params`.

Note: Support is generic and can represent various things depending on the voting system used.

_defaultParams() → bytes

Default additional encoded parameters used by castVote methods that don't include them

Note: Should be overridden by specific implementations to use an appropriate value, the meaning of the additional params, in the context of that implementation

propose(address[] targets, uint256[] values, bytes[] calldatas, string description) → uint256

See [`IGovernor.propose`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-propose-address---uint256---bytes---string-). This function has opt-in frontrunning protection, described in [`Governor._isValidDescriptionForProposer`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_isValidDescriptionForProposer-address-string-).

execute(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) → uint256

See [`IGovernor.execute`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-execute-address---uint256---bytes---bytes32-).

cancel(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) → uint256

See [`IGovernor.cancel`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-cancel-address---uint256---bytes---bytes32-).

_execute(uint256, address[] targets, uint256[] values, bytes[] calldatas, bytes32)

Internal execution mechanism. Can be overridden to implement different execution mechanism

_beforeExecute(uint256, address[] targets, uint256[], bytes[] calldatas, bytes32)

Hook before execution is triggered.

_afterExecute(uint256, address[], uint256[], bytes[], bytes32)

Hook after execution is triggered.

_cancel(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) → uint256

Internal cancel mechanism: locks up the proposal timer, preventing it from being re-submitted. Marks it as canceled to allow distinguishing it from executed proposals.

Emits a [`IGovernor.ProposalCanceled`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-) event.

getVotes(address account, uint256 timepoint) → uint256

See [`IGovernor.getVotes`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-getVotes-address-uint256-).

getVotesWithParams(address account, uint256 timepoint, bytes params) → uint256

castVote(uint256 proposalId, uint8 support) → uint256

See [`IGovernor.castVote`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVote-uint256-uint8-).

castVoteWithReason(uint256 proposalId, uint8 support, string reason) → uint256

castVoteWithReasonAndParams(uint256 proposalId, uint8 support, string reason, bytes params) → uint256

castVoteBySig(uint256 proposalId, uint8 support, uint8 v, bytes32 r, bytes32 s) → uint256

See [`IGovernor.castVoteBySig`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-).

castVoteWithReasonAndParamsBySig(uint256 proposalId, uint8 support, string reason, bytes params, uint8 v, bytes32 r, bytes32 s) → uint256

_castVote(uint256 proposalId, address account, uint8 support, string reason) → uint256

Internal vote casting mechanism: Check that the vote is pending, that it has not been cast yet, retrieve voting weight using [`IGovernor.getVotes`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-getVotes-address-uint256-) and call the [`Governor._countVote`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_countVote-uint256-address-uint8-uint256-bytes-) internal function. Uses the _defaultParams().

Emits a [`IGovernor.VoteCast`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-) event.

_castVote(uint256 proposalId, address account, uint8 support, string reason, bytes params) → uint256

Internal vote casting mechanism: Check that the vote is pending, that it has not been cast yet, retrieve voting weight using [`IGovernor.getVotes`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-getVotes-address-uint256-) and call the [`Governor._countVote`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_countVote-uint256-address-uint8-uint256-bytes-) internal function.

Emits a [`IGovernor.VoteCast`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-) event.

relay(address target, uint256 value, bytes data)

Relays a transaction or function call to an arbitrary target. In cases where the governance executor is some contract other than the governor itself, like when using a timelock, this function can be invoked in a governance proposal to recover tokens or Ether that was sent to the governor contract by mistake. Note that if the executor is simply the governor itself, use of `relay` is redundant.

_executor() → address

Address through which the governor executes action. Will be overloaded by module that execute actions through another contract such as a timelock.

onERC721Received(address, address, uint256, bytes) → bytes4

onERC1155Received(address, address, uint256, uint256, bytes) → bytes4

onERC1155BatchReceived(address, address, uint256[], uint256[], bytes) → bytes4

_isValidDescriptionForProposer(address proposer, string description) → bool

Check if the proposer is authorized to submit a proposal with the given description.

If the proposal description ends with `#proposer=0x???`, where `0x???` is an address written as a hex string (case insensitive), then the submission of this proposal will only be authorized to said address.

This is used for frontrunning protection. By adding this pattern at the end of their proposal, one can ensure that no other address can submit the same proposal. An attacker would have to either remove or change that part, which would result in a different proposal id.

If the description does not match this pattern, it is unrestricted and anyone can submit it. This includes:

*   If the `0x???` part is not a valid hex string.
*   If the `0x???` part is a valid hex string, but does not contain exactly 40 hex digits.
*   If it ends with the expected suffix followed by newlines or other whitespace.
*   If it ends with some other similar suffix, e.g. `#other=abc`.
*   If it does not end with any such suffix.

BALLOT_TYPEHASH() → bytes32

EXTENDED_BALLOT_TYPEHASH() → bytes32

`import "@openzeppelin/contracts/governance/IGovernor.sol";`

Interface of the [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor) core.

_Available since v4.3._

### Functions

*   [name()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-name--)
*   [version()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-version--)
*   [clock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-clock--)
*   [CLOCK_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-CLOCK_MODE--)
*   [COUNTING_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-COUNTING_MODE--)
*   [hashProposal(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hashProposal-address---uint256---bytes---bytes32-)
*   [state(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-state-uint256-)
*   [proposalSnapshot(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-proposalSnapshot-uint256-)
*   [proposalDeadline(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-proposalDeadline-uint256-)
*   [proposalProposer(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-proposalProposer-uint256-)
*   [votingDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--)
*   [votingPeriod()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--)
*   [quorum(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-quorum-uint256-)
*   [getVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-getVotes-address-uint256-)
*   [getVotesWithParams(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-getVotesWithParams-address-uint256-bytes-)
*   [hasVoted(proposalId, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hasVoted-uint256-address-)
*   [propose(targets, values, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-propose-address---uint256---bytes---string-)
*   [execute(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-execute-address---uint256---bytes---bytes32-)
*   [cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-cancel-address---uint256---bytes---bytes32-)
*   [castVote(proposalId, support)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVote-uint256-uint8-)
*   [castVoteWithReason(proposalId, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteWithReason-uint256-uint8-string-)
*   [castVoteWithReasonAndParams(proposalId, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
*   [castVoteBySig(proposalId, support, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
*   [castVoteWithReasonAndParamsBySig(proposalId, support, reason, params, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-2)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-2)

*   [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IERC165-supportsInterface-bytes4-)

### Events

*   [ProposalCreated(proposalId, proposer, targets, values, signatures, calldatas, voteStart, voteEnd, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-)
*   [ProposalCanceled(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-)
*   [ProposalExecuted(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-)
*   [VoteCast(voter, proposalId, support, weight, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-)
*   [VoteCastWithParams(voter, proposalId, support, weight, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-3)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-3)

name() → string

Name of the governor instance (used in building the ERC712 domain separator).

version() → string

Version of the governor instance (used in building the ERC712 domain separator). Default: "1"

clock() → uint48

CLOCK_MODE() → string

See EIP-6372.

COUNTING_MODE() → string

A description of the possible `support` values for [`Governor.castVote`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVote-uint256-uint8-) and the way these votes are counted, meant to be consumed by UIs to show correct vote options and interpret the results. The string is a URL-encoded sequence of key-value pairs that each describe one aspect, for example `support=bravo&quorum=for,abstain`.

There are 2 standard keys: `support` and `quorum`.

*   `support=bravo` refers to the vote options 0 = Against, 1 = For, 2 = Abstain, as in `GovernorBravo`.
*   `quorum=bravo` means that only For votes are counted towards quorum.
*   `quorum=for,abstain` means that both For and Abstain votes are counted towards quorum.

If a counting module makes use of encoded `params`, it should include this under a `params` key with a unique name that describes the behavior. For example:

*   `params=fractional` might refer to a scheme where votes are divided fractionally between for/against/abstain.
*   `params=erc721` might refer to a scheme where specific NFTs are delegated to vote.

NOTE: The string can be decoded by the standard [`URLSearchParams`](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams) JavaScript class.

hashProposal(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) → uint256

Hashing function used to (re)build the proposal id from the proposal details..

state(uint256 proposalId) → enum IGovernor.ProposalState

Current state of a proposal, following Compound's convention

proposalSnapshot(uint256 proposalId) → uint256

Timepoint used to retrieve user's votes and quorum. If using block number (as per Compound's Comp), the snapshot is performed at the end of this block. Hence, voting for this proposal starts at the beginning of the following block.

proposalDeadline(uint256 proposalId) → uint256

Timepoint at which votes close. If using block number, votes close at the end of this block, so it is possible to cast a vote during this block.

proposalProposer(uint256 proposalId) → address

The account that created a proposal.

votingDelay() → uint256

Delay, between the proposal is created and the vote starts. The unit this duration is expressed in depends on the clock (see EIP-6372) this contract uses.

This can be increased to leave time for users to buy voting power, or delegate it, before the voting of a proposal starts.

votingPeriod() → uint256

Delay between the vote start and vote end. The unit this duration is expressed in depends on the clock (see EIP-6372) this contract uses.

NOTE: The [`IGovernor.votingDelay`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--) can delay the start of the vote. This must be considered when setting the voting duration compared to the voting delay.

quorum(uint256 timepoint) → uint256

Minimum number of cast voted required for a proposal to be successful.

NOTE: The `timepoint` parameter corresponds to the snapshot used for counting vote. This allows to scale the quorum depending on values such as the totalSupply of a token at this timepoint (see [`ERC20Votes`](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC20#ERC20Votes)).

getVotes(address account, uint256 timepoint) → uint256

Voting power of an `account` at a specific `timepoint`.

Note: this can be implemented in a number of ways, for example by reading the delegated balance from one (or multiple), [`ERC20Votes`](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC20#ERC20Votes) tokens.

getVotesWithParams(address account, uint256 timepoint, bytes params) → uint256

Voting power of an `account` at a specific `timepoint` given additional encoded parameters.

hasVoted(uint256 proposalId, address account) → bool

Returns whether `account` has cast a vote on `proposalId`.

propose(address[] targets, uint256[] values, bytes[] calldatas, string description) → uint256 proposalId

Create a new proposal. Vote start after a delay specified by [`IGovernor.votingDelay`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--) and lasts for a duration specified by [`IGovernor.votingPeriod`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--).

Emits a [`IGovernor.ProposalCreated`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-) event.

execute(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) → uint256 proposalId

Execute a successful proposal. This requires the quorum to be reached, the vote to be successful, and the deadline to be reached.

Emits a [`IGovernor.ProposalExecuted`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-) event.

Note: some module can modify the requirements for execution, for example by adding an additional timelock.

cancel(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) → uint256 proposalId

Cancel a proposal. A proposal is cancellable by the proposer, but only while it is Pending state, i.e. before the vote starts.

Emits a [`IGovernor.ProposalCanceled`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-) event.

castVote(uint256 proposalId, uint8 support) → uint256 balance

Cast a vote

Emits a [`IGovernor.VoteCast`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-) event.

castVoteWithReason(uint256 proposalId, uint8 support, string reason) → uint256 balance

Cast a vote with a reason

Emits a [`IGovernor.VoteCast`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-) event.

castVoteWithReasonAndParams(uint256 proposalId, uint8 support, string reason, bytes params) → uint256 balance

Cast a vote with a reason and additional encoded parameters

Emits a [`IGovernor.VoteCast`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-) or [`IGovernor.VoteCastWithParams`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-) event depending on the length of params.

castVoteBySig(uint256 proposalId, uint8 support, uint8 v, bytes32 r, bytes32 s) → uint256 balance

Cast a vote using the user's cryptographic signature.

Emits a [`IGovernor.VoteCast`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-) event.

castVoteWithReasonAndParamsBySig(uint256 proposalId, uint8 support, string reason, bytes params, uint8 v, bytes32 r, bytes32 s) → uint256 balance

Cast a vote with a reason and additional encoded parameters using the user's cryptographic signature.

Emits a [`IGovernor.VoteCast`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-) or [`IGovernor.VoteCastWithParams`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-) event depending on the length of params.

ProposalCreated(uint256 proposalId, address proposer, address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, uint256 voteStart, uint256 voteEnd, string description)

Emitted when a proposal is created.

ProposalCanceled(uint256 proposalId)

Emitted when a proposal is canceled.

ProposalExecuted(uint256 proposalId)

Emitted when a proposal is executed.

VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 weight, string reason)

Emitted when a vote is cast without params.

Note: `support` values should be seen as buckets. Their interpretation depends on the voting module used.

VoteCastWithParams(address indexed voter, uint256 proposalId, uint8 support, uint256 weight, string reason, bytes params)

Emitted when a vote is cast with params.

Note: `support` values should be seen as buckets. Their interpretation depends on the voting module used. `params` are additional encoded parameters. Their interpepretation also depends on the voting module used.

`import "@openzeppelin/contracts/governance/TimelockController.sol";`

Contract module which acts as a timelocked controller. When set as the owner of an `Ownable` smart contract, it enforces a timelock on all `onlyOwner` maintenance operations. This gives time for users of the controlled contract to exit before a potentially dangerous maintenance operation is applied.

By default, this contract is self administered, meaning administration tasks have to go through the timelock process. The proposer (resp executor) role is in charge of proposing (resp executing) operations. A common use case is to position this [`TimelockController`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController) as the owner of a smart contract, with a multisig or a DAO as the sole proposer.

_Available since v3.3._

### Functions

*   [constructor(minDelay, proposers, executors, admin)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-constructor-uint256-address---address---address-)
*   [receive()](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-receive--)
*   [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-supportsInterface-bytes4-)
*   [isOperation(id)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-isOperation-bytes32-)
*   [isOperationPending(id)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-isOperationPending-bytes32-)
*   [isOperationReady(id)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-isOperationReady-bytes32-)
*   [isOperationDone(id)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-isOperationDone-bytes32-)
*   [getTimestamp(id)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-getTimestamp-bytes32-)
*   [getMinDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-getMinDelay--)
*   [hashOperation(target, value, data, predecessor, salt)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-hashOperation-address-uint256-bytes-bytes32-bytes32-)
*   [hashOperationBatch(targets, values, payloads, predecessor, salt)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-hashOperationBatch-address---uint256---bytes---bytes32-bytes32-)
*   [schedule(target, value, data, predecessor, salt, delay)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-schedule-address-uint256-bytes-bytes32-bytes32-uint256-)
*   [scheduleBatch(targets, values, payloads, predecessor, salt, delay)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-scheduleBatch-address---uint256---bytes---bytes32-bytes32-uint256-)
*   [cancel(id)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-cancel-bytes32-)
*   [execute(target, value, payload, predecessor, salt)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-execute-address-uint256-bytes-bytes32-bytes32-)
*   [executeBatch(targets, values, payloads, predecessor, salt)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-executeBatch-address---uint256---bytes---bytes32-bytes32-)
*   [_execute(target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-_execute-address-uint256-bytes-)
*   [updateDelay(newDelay)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-updateDelay-uint256-)
*   [onERC721Received(, , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-onERC721Received-address-address-uint256-bytes-)
*   [onERC1155Received(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-onERC1155Received-address-address-uint256-uint256-bytes-)
*   [onERC1155BatchReceived(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-onERC1155BatchReceived-address-address-uint256---uint256---bytes-)
*   [TIMELOCK_ADMIN_ROLE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-TIMELOCK_ADMIN_ROLE-bytes32)
*   [PROPOSER_ROLE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-PROPOSER_ROLE-bytes32)
*   [EXECUTOR_ROLE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-EXECUTOR_ROLE-bytes32)
*   [CANCELLER_ROLE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-CANCELLER_ROLE-bytes32)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-2)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-2)

#### [AccessControl](https://docs.openzeppelin.com/contracts/4.x/api/governance#accesscontrol)

*   [hasRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-hasRole-bytes32-address-)
*   [_checkRole(role)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-_checkRole-bytes32-)
*   [_checkRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-_checkRole-bytes32-address-)
*   [getRoleAdmin(role)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-getRoleAdmin-bytes32-)
*   [grantRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-grantRole-bytes32-address-)
*   [revokeRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-revokeRole-bytes32-address-)
*   [renounceRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-renounceRole-bytes32-address-)
*   [_setupRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-_setupRole-bytes32-address-)
*   [_setRoleAdmin(role, adminRole)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-_setRoleAdmin-bytes32-bytes32-)
*   [_grantRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-_grantRole-bytes32-address-)
*   [_revokeRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-_revokeRole-bytes32-address-)
*   [DEFAULT_ADMIN_ROLE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-DEFAULT_ADMIN_ROLE-bytes32)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-2)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-4)

#### [IAccessControl](https://docs.openzeppelin.com/contracts/4.x/api/governance#iaccesscontrol)

### Events

*   [CallScheduled(id, index, target, value, data, predecessor, delay)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-CallScheduled-bytes32-uint256-address-uint256-bytes-bytes32-uint256-)
*   [CallExecuted(id, index, target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-CallExecuted-bytes32-uint256-address-uint256-bytes-)
*   [CallSalt(id, salt)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-CallSalt-bytes32-bytes32-)
*   [Cancelled(id)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-Cancelled-bytes32-)
*   [MinDelayChange(oldDuration, newDuration)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-MinDelayChange-uint256-uint256-)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-3)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-3)

#### [AccessControl](https://docs.openzeppelin.com/contracts/4.x/api/governance#accesscontrol-1)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-3)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-5)

#### [IAccessControl](https://docs.openzeppelin.com/contracts/4.x/api/governance#iaccesscontrol-1)

*   [RoleAdminChanged(role, previousAdminRole, newAdminRole)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IAccessControl-RoleAdminChanged-bytes32-bytes32-bytes32-)
*   [RoleGranted(role, account, sender)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IAccessControl-RoleGranted-bytes32-address-address-)
*   [RoleRevoked(role, account, sender)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IAccessControl-RoleRevoked-bytes32-address-address-)

onlyRoleOrOpenRole(bytes32 role)

Modifier to make a function callable only by a certain role. In addition to checking the sender's role, `address(0)` 's role is also considered. Granting a role to `address(0)` is equivalent to enabling this role for everyone.

constructor(uint256 minDelay, address[] proposers, address[] executors, address admin)

Initializes the contract with the following parameters:

*   `minDelay`: initial minimum delay for operations
*   `proposers`: accounts to be granted proposer and canceller roles
*   `executors`: accounts to be granted executor role
*   `admin`: optional account to be granted admin role; disable with zero address

The optional admin can aid with initial configuration of roles after deployment without being subject to delay, but this role should be subsequently renounced in favor of administration through timelocked proposals. Previous versions of this contract would assign this admin to the deployer automatically and should be renounced as well.

receive()

Contract might receive/hold ETH as part of the maintenance process.

supportsInterface(bytes4 interfaceId) → bool

isOperation(bytes32 id) → bool

Returns whether an id correspond to a registered operation. This includes both Pending, Ready and Done operations.

isOperationPending(bytes32 id) → bool

Returns whether an operation is pending or not. Note that a "pending" operation may also be "ready".

isOperationReady(bytes32 id) → bool

Returns whether an operation is ready for execution. Note that a "ready" operation is also "pending".

isOperationDone(bytes32 id) → bool

Returns whether an operation is done or not.

getTimestamp(bytes32 id) → uint256

Returns the timestamp at which an operation becomes ready (0 for unset operations, 1 for done operations).

getMinDelay() → uint256

Returns the minimum delay for an operation to become valid.

This value can be changed by executing an operation that calls `updateDelay`.

hashOperation(address target, uint256 value, bytes data, bytes32 predecessor, bytes32 salt) → bytes32

Returns the identifier of an operation containing a single transaction.

hashOperationBatch(address[] targets, uint256[] values, bytes[] payloads, bytes32 predecessor, bytes32 salt) → bytes32

Returns the identifier of an operation containing a batch of transactions.

schedule(address target, uint256 value, bytes data, bytes32 predecessor, bytes32 salt, uint256 delay)

Schedule an operation containing a single transaction.

Emits [`TimelockController.CallSalt`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-CallSalt-bytes32-bytes32-) if salt is nonzero, and [`TimelockController.CallScheduled`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-CallScheduled-bytes32-uint256-address-uint256-bytes-bytes32-uint256-).

Requirements:

*   the caller must have the 'proposer' role.

scheduleBatch(address[] targets, uint256[] values, bytes[] payloads, bytes32 predecessor, bytes32 salt, uint256 delay)

Schedule an operation containing a batch of transactions.

Emits [`TimelockController.CallSalt`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-CallSalt-bytes32-bytes32-) if salt is nonzero, and one [`TimelockController.CallScheduled`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-CallScheduled-bytes32-uint256-address-uint256-bytes-bytes32-uint256-) event per transaction in the batch.

Requirements:

*   the caller must have the 'proposer' role.

cancel(bytes32 id)

Cancel an operation.

Requirements:

*   the caller must have the 'canceller' role.

execute(address target, uint256 value, bytes payload, bytes32 predecessor, bytes32 salt)

Execute an (ready) operation containing a single transaction.

Emits a [`TimelockController.CallExecuted`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-CallExecuted-bytes32-uint256-address-uint256-bytes-) event.

Requirements:

*   the caller must have the 'executor' role.

executeBatch(address[] targets, uint256[] values, bytes[] payloads, bytes32 predecessor, bytes32 salt)

Execute an (ready) operation containing a batch of transactions.

Emits one [`TimelockController.CallExecuted`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-CallExecuted-bytes32-uint256-address-uint256-bytes-) event per transaction in the batch.

Requirements:

*   the caller must have the 'executor' role.

_execute(address target, uint256 value, bytes data)

Execute an operation's call.

updateDelay(uint256 newDelay)

Changes the minimum timelock duration for future operations.

Emits a [`TimelockController.MinDelayChange`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-MinDelayChange-uint256-uint256-) event.

Requirements:

*   the caller must be the timelock itself. This can only be achieved by scheduling and later executing an operation where the timelock is the target and the data is the ABI-encoded call to this function.

onERC721Received(address, address, uint256, bytes) → bytes4

onERC1155Received(address, address, uint256, uint256, bytes) → bytes4

onERC1155BatchReceived(address, address, uint256[], uint256[], bytes) → bytes4

TIMELOCK_ADMIN_ROLE() → bytes32

PROPOSER_ROLE() → bytes32

EXECUTOR_ROLE() → bytes32

CANCELLER_ROLE() → bytes32

CallScheduled(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data, bytes32 predecessor, uint256 delay)

Emitted when a call is scheduled as part of operation `id`.

CallExecuted(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data)

Emitted when a call is performed as part of operation `id`.

CallSalt(bytes32 indexed id, bytes32 salt)

Emitted when new proposal is scheduled with non-zero salt.

Cancelled(bytes32 indexed id)

Emitted when operation `id` is cancelled.

MinDelayChange(uint256 oldDuration, uint256 newDuration)

Emitted when the minimum delay for future operations is modified.

`import "@openzeppelin/contracts/governance/compatibility/GovernorCompatibilityBravo.sol";`

Compatibility layer that implements GovernorBravo compatibility on top of [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor).

This compatibility layer includes a voting system and requires a [`IGovernorTimelock`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorTimelock) compatible module to be added through inheritance. It does not include token bindings, nor does it include any variable upgrade patterns.

NOTE: When using this module, you may need to enable the Solidity optimizer to avoid hitting the contract size limit.

_Available since v4.3._

### Functions

*   [COUNTING_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-COUNTING_MODE--)
*   [propose(targets, values, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-propose-address---uint256---bytes---string-)
*   [propose(targets, values, signatures, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-propose-address---uint256---string---bytes---string-)
*   [queue(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-queue-uint256-)
*   [execute(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-execute-uint256-)
*   [cancel(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-cancel-uint256-)
*   [cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-cancel-address---uint256---bytes---bytes32-)
*   [proposals(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-proposals-uint256-)
*   [getActions(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-getActions-uint256-)
*   [getReceipt(proposalId, voter)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-getReceipt-uint256-address-)
*   [quorumVotes()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-quorumVotes--)
*   [hasVoted(proposalId, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-hasVoted-uint256-address-)
*   [_quorumReached(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-_quorumReached-uint256-)
*   [_voteSucceeded(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-_voteSucceeded-uint256-)
*   [_countVote(proposalId, account, support, weight, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-_countVote-uint256-address-uint8-uint256-bytes-)

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-2)

*   [receive()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-receive--)
*   [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-supportsInterface-bytes4-)
*   [name()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-name--)
*   [version()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-version--)
*   [hashProposal(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-hashProposal-address---uint256---bytes---bytes32-)
*   [state(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-state-uint256-)
*   [proposalThreshold()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalThreshold--)
*   [proposalSnapshot(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalSnapshot-uint256-)
*   [proposalDeadline(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalDeadline-uint256-)
*   [proposalProposer(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalProposer-uint256-)
*   [_getVotes(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_getVotes-address-uint256-bytes-)
*   [_defaultParams()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_defaultParams--)
*   [execute(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-execute-address---uint256---bytes---bytes32-)
*   [_execute(, targets, values, calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_execute-uint256-address---uint256---bytes---bytes32-)
*   [_beforeExecute(, targets, , calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_beforeExecute-uint256-address---uint256---bytes---bytes32-)
*   [_afterExecute(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_afterExecute-uint256-address---uint256---bytes---bytes32-)
*   [_cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_cancel-address---uint256---bytes---bytes32-)
*   [getVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotes-address-uint256-)
*   [getVotesWithParams(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotesWithParams-address-uint256-bytes-)
*   [castVote(proposalId, support)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVote-uint256-uint8-)
*   [castVoteWithReason(proposalId, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReason-uint256-uint8-string-)
*   [castVoteWithReasonAndParams(proposalId, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
*   [castVoteBySig(proposalId, support, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
*   [castVoteWithReasonAndParamsBySig(proposalId, support, reason, params, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)
*   [_castVote(proposalId, account, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-)
*   [_castVote(proposalId, account, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-bytes-)
*   [relay(target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-relay-address-uint256-bytes-)
*   [_executor()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_executor--)
*   [onERC721Received(, , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC721Received-address-address-uint256-bytes-)
*   [onERC1155Received(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155Received-address-address-uint256-uint256-bytes-)
*   [onERC1155BatchReceived(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155BatchReceived-address-address-uint256---uint256---bytes-)
*   [_isValidDescriptionForProposer(proposer, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_isValidDescriptionForProposer-address-string-)
*   [BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-BALLOT_TYPEHASH-bytes32)
*   [EXTENDED_BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-EXTENDED_BALLOT_TYPEHASH-bytes32)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-4)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-4)

#### [IGovernorCompatibilityBravo](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernorcompatibilitybravo)

#### [IGovernorTimelock](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernortimelock)

*   [timelock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorTimelock-timelock--)
*   [proposalEta(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorTimelock-proposalEta-uint256-)
*   [queue(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorTimelock-queue-address---uint256---bytes---bytes32-)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-3)

*   [clock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-clock--)
*   [CLOCK_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-CLOCK_MODE--)
*   [votingDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--)
*   [votingPeriod()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--)
*   [quorum(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-quorum-uint256-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-4)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-2)

*   [_domainSeparatorV4()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_domainSeparatorV4--)
*   [_hashTypedDataV4(structHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_hashTypedDataV4-bytes32-)
*   [eip712Domain()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-eip712Domain--)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-2)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-4)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-6)

### Events

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-3)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-5)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-5)

#### [IGovernorCompatibilityBravo](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernorcompatibilitybravo-1)

#### [IGovernorTimelock](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernortimelock-1)

*   [ProposalQueued(proposalId, eta)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorTimelock-ProposalQueued-uint256-uint256-)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-4)

*   [ProposalCreated(proposalId, proposer, targets, values, signatures, calldatas, voteStart, voteEnd, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-)
*   [ProposalCanceled(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-)
*   [ProposalExecuted(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-)
*   [VoteCast(voter, proposalId, support, weight, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-)
*   [VoteCastWithParams(voter, proposalId, support, weight, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-5)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-3)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-3)

*   [EIP712DomainChanged()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IERC5267-EIP712DomainChanged--)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-5)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-7)

COUNTING_MODE() → string

A description of the possible `support` values for [`Governor.castVote`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVote-uint256-uint8-) and the way these votes are counted, meant to be consumed by UIs to show correct vote options and interpret the results. The string is a URL-encoded sequence of key-value pairs that each describe one aspect, for example `support=bravo&quorum=for,abstain`.

There are 2 standard keys: `support` and `quorum`.

*   `support=bravo` refers to the vote options 0 = Against, 1 = For, 2 = Abstain, as in `GovernorBravo`.
*   `quorum=bravo` means that only For votes are counted towards quorum.
*   `quorum=for,abstain` means that both For and Abstain votes are counted towards quorum.

If a counting module makes use of encoded `params`, it should include this under a `params` key with a unique name that describes the behavior. For example:

*   `params=fractional` might refer to a scheme where votes are divided fractionally between for/against/abstain.
*   `params=erc721` might refer to a scheme where specific NFTs are delegated to vote.

NOTE: The string can be decoded by the standard [`URLSearchParams`](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams) JavaScript class.

propose(address[] targets, uint256[] values, bytes[] calldatas, string description) → uint256

See [`IGovernor.propose`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-propose-address---uint256---bytes---string-).

propose(address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, string description) → uint256

queue(uint256 proposalId)

execute(uint256 proposalId)

cancel(uint256 proposalId)

Cancel a proposal with GovernorBravo logic.

cancel(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) → uint256

Cancel a proposal with GovernorBravo logic. At any moment a proposal can be cancelled, either by the proposer, or by third parties if the proposer's voting power has dropped below the proposal threshold.

proposals(uint256 proposalId) → uint256 id, address proposer, uint256 eta, uint256 startBlock, uint256 endBlock, uint256 forVotes, uint256 againstVotes, uint256 abstainVotes, bool canceled, bool executed

getActions(uint256 proposalId) → address[] targets, uint256[] values, string[] signatures, bytes[] calldatas

getReceipt(uint256 proposalId, address voter) → struct IGovernorCompatibilityBravo.Receipt

quorumVotes() → uint256

hasVoted(uint256 proposalId, address account) → bool

See [`IGovernor.hasVoted`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hasVoted-uint256-address-).

_quorumReached(uint256 proposalId) → bool

See [`Governor._quorumReached`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_quorumReached-uint256-). In this module, only forVotes count toward the quorum.

_voteSucceeded(uint256 proposalId) → bool

See [`Governor._voteSucceeded`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_voteSucceeded-uint256-). In this module, the forVotes must be strictly over the againstVotes.

_countVote(uint256 proposalId, address account, uint8 support, uint256 weight, bytes)

See [`Governor._countVote`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_countVote-uint256-address-uint8-uint256-bytes-). In this module, the support follows Governor Bravo.

`import "@openzeppelin/contracts/governance/compatibility/IGovernorCompatibilityBravo.sol";`

Interface extension that adds missing functions to the [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor) core to provide `GovernorBravo` compatibility.

_Available since v4.3._

### Functions

*   [quorumVotes()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-quorumVotes--)
*   [proposals()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-proposals-uint256-)
*   [propose(targets, values, signatures, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-propose-address---uint256---string---bytes---string-)
*   [queue(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-queue-uint256-)
*   [execute(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-execute-uint256-)
*   [cancel(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-cancel-uint256-)
*   [getActions(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-getActions-uint256-)
*   [getReceipt(proposalId, voter)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-getReceipt-uint256-address-)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-5)

*   [name()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-name--)
*   [version()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-version--)
*   [clock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-clock--)
*   [CLOCK_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-CLOCK_MODE--)
*   [COUNTING_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-COUNTING_MODE--)
*   [hashProposal(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hashProposal-address---uint256---bytes---bytes32-)
*   [state(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-state-uint256-)
*   [proposalSnapshot(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-proposalSnapshot-uint256-)
*   [proposalDeadline(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-proposalDeadline-uint256-)
*   [proposalProposer(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-proposalProposer-uint256-)
*   [votingDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--)
*   [votingPeriod()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--)
*   [quorum(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-quorum-uint256-)
*   [getVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-getVotes-address-uint256-)
*   [getVotesWithParams(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-getVotesWithParams-address-uint256-bytes-)
*   [hasVoted(proposalId, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hasVoted-uint256-address-)
*   [propose(targets, values, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-propose-address---uint256---bytes---string-)
*   [execute(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-execute-address---uint256---bytes---bytes32-)
*   [cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-cancel-address---uint256---bytes---bytes32-)
*   [castVote(proposalId, support)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVote-uint256-uint8-)
*   [castVoteWithReason(proposalId, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteWithReason-uint256-uint8-string-)
*   [castVoteWithReasonAndParams(proposalId, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
*   [castVoteBySig(proposalId, support, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
*   [castVoteWithReasonAndParamsBySig(proposalId, support, reason, params, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-6)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-8)

*   [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IERC165-supportsInterface-bytes4-)

### Events

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-6)

*   [ProposalCreated(proposalId, proposer, targets, values, signatures, calldatas, voteStart, voteEnd, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-)
*   [ProposalCanceled(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-)
*   [ProposalExecuted(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-)
*   [VoteCast(voter, proposalId, support, weight, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-)
*   [VoteCastWithParams(voter, proposalId, support, weight, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-7)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-9)

quorumVotes() → uint256

Part of the Governor Bravo's interface.

proposals(uint256) → uint256 id, address proposer, uint256 eta, uint256 startBlock, uint256 endBlock, uint256 forVotes, uint256 againstVotes, uint256 abstainVotes, bool canceled, bool executed

Part of the Governor Bravo's interface: _"The official record of all proposals ever proposed"_.

propose(address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, string description) → uint256

Part of the Governor Bravo's interface: _"Function used to propose a new proposal"_.

queue(uint256 proposalId)

Part of the Governor Bravo's interface: _"Queues a proposal of state succeeded"_.

execute(uint256 proposalId)

Part of the Governor Bravo's interface: _"Executes a queued proposal if eta has passed"_.

cancel(uint256 proposalId)

Cancels a proposal only if the sender is the proposer or the proposer delegates' voting power dropped below the proposal threshold.

getActions(uint256 proposalId) → address[] targets, uint256[] values, string[] signatures, bytes[] calldatas

Part of the Governor Bravo's interface: _"Gets actions of a proposal"_.

getReceipt(uint256 proposalId, address voter) → struct IGovernorCompatibilityBravo.Receipt

Part of the Governor Bravo's interface: _"Gets the receipt for a voter on a given proposal"_.

`import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";`

Extension of [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor) for simple, 3 options, vote counting.

_Available since v4.3._

### Functions

*   [COUNTING_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCountingSimple-COUNTING_MODE--)
*   [hasVoted(proposalId, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCountingSimple-hasVoted-uint256-address-)
*   [proposalVotes(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCountingSimple-proposalVotes-uint256-)
*   [_quorumReached(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCountingSimple-_quorumReached-uint256-)
*   [_voteSucceeded(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCountingSimple-_voteSucceeded-uint256-)
*   [_countVote(proposalId, account, support, weight, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCountingSimple-_countVote-uint256-address-uint8-uint256-bytes-)

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-4)

*   [receive()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-receive--)
*   [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-supportsInterface-bytes4-)
*   [name()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-name--)
*   [version()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-version--)
*   [hashProposal(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-hashProposal-address---uint256---bytes---bytes32-)
*   [state(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-state-uint256-)
*   [proposalThreshold()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalThreshold--)
*   [proposalSnapshot(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalSnapshot-uint256-)
*   [proposalDeadline(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalDeadline-uint256-)
*   [proposalProposer(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalProposer-uint256-)
*   [_getVotes(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_getVotes-address-uint256-bytes-)
*   [_defaultParams()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_defaultParams--)
*   [propose(targets, values, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-propose-address---uint256---bytes---string-)
*   [execute(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-execute-address---uint256---bytes---bytes32-)
*   [cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-cancel-address---uint256---bytes---bytes32-)
*   [_execute(, targets, values, calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_execute-uint256-address---uint256---bytes---bytes32-)
*   [_beforeExecute(, targets, , calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_beforeExecute-uint256-address---uint256---bytes---bytes32-)
*   [_afterExecute(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_afterExecute-uint256-address---uint256---bytes---bytes32-)
*   [_cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_cancel-address---uint256---bytes---bytes32-)
*   [getVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotes-address-uint256-)
*   [getVotesWithParams(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotesWithParams-address-uint256-bytes-)
*   [castVote(proposalId, support)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVote-uint256-uint8-)
*   [castVoteWithReason(proposalId, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReason-uint256-uint8-string-)
*   [castVoteWithReasonAndParams(proposalId, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
*   [castVoteBySig(proposalId, support, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
*   [castVoteWithReasonAndParamsBySig(proposalId, support, reason, params, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)
*   [_castVote(proposalId, account, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-)
*   [_castVote(proposalId, account, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-bytes-)
*   [relay(target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-relay-address-uint256-bytes-)
*   [_executor()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_executor--)
*   [onERC721Received(, , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC721Received-address-address-uint256-bytes-)
*   [onERC1155Received(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155Received-address-address-uint256-uint256-bytes-)
*   [onERC1155BatchReceived(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155BatchReceived-address-address-uint256---uint256---bytes-)
*   [_isValidDescriptionForProposer(proposer, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_isValidDescriptionForProposer-address-string-)
*   [BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-BALLOT_TYPEHASH-bytes32)
*   [EXTENDED_BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-EXTENDED_BALLOT_TYPEHASH-bytes32)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-6)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-6)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-7)

*   [clock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-clock--)
*   [CLOCK_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-CLOCK_MODE--)
*   [votingDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--)
*   [votingPeriod()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--)
*   [quorum(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-quorum-uint256-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-8)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-4)

*   [_domainSeparatorV4()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_domainSeparatorV4--)
*   [_hashTypedDataV4(structHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_hashTypedDataV4-bytes32-)
*   [eip712Domain()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-eip712Domain--)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-4)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-6)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-10)

### Events

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-5)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-7)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-7)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-8)

*   [ProposalCreated(proposalId, proposer, targets, values, signatures, calldatas, voteStart, voteEnd, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-)
*   [ProposalCanceled(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-)
*   [ProposalExecuted(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-)
*   [VoteCast(voter, proposalId, support, weight, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-)
*   [VoteCastWithParams(voter, proposalId, support, weight, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-9)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-5)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-5)

*   [EIP712DomainChanged()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IERC5267-EIP712DomainChanged--)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-7)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-11)

COUNTING_MODE() → string

See [`IGovernor.COUNTING_MODE`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-COUNTING_MODE--).

hasVoted(uint256 proposalId, address account) → bool

See [`IGovernor.hasVoted`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hasVoted-uint256-address-).

proposalVotes(uint256 proposalId) → uint256 againstVotes, uint256 forVotes, uint256 abstainVotes

Accessor to the internal vote counts.

_quorumReached(uint256 proposalId) → bool

See [`Governor._quorumReached`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_quorumReached-uint256-).

_voteSucceeded(uint256 proposalId) → bool

See [`Governor._voteSucceeded`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_voteSucceeded-uint256-). In this module, the forVotes must be strictly over the againstVotes.

_countVote(uint256 proposalId, address account, uint8 support, uint256 weight, bytes)

See [`Governor._countVote`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_countVote-uint256-address-uint8-uint256-bytes-). In this module, the support follows the `VoteType` enum (from Governor Bravo).

`import "@openzeppelin/contracts/governance/extensions/GovernorPreventLateQuorum.sol";`

A module that ensures there is a minimum voting period after quorum is reached. This prevents a large voter from swaying a vote and triggering quorum at the last minute, by ensuring there is always time for other voters to react and try to oppose the decision.

If a vote causes quorum to be reached, the proposal's voting period may be extended so that it does not end before at least a specified time has passed (the "vote extension" parameter). This parameter can be set through a governance proposal.

_Available since v4.5._

### Functions

*   [constructor(initialVoteExtension)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-constructor-uint64-)
*   [proposalDeadline(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-proposalDeadline-uint256-)
*   [_castVote(proposalId, account, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-_castVote-uint256-address-uint8-string-bytes-)
*   [lateQuorumVoteExtension()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-lateQuorumVoteExtension--)
*   [setLateQuorumVoteExtension(newVoteExtension)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-setLateQuorumVoteExtension-uint64-)
*   [_setLateQuorumVoteExtension(newVoteExtension)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-_setLateQuorumVoteExtension-uint64-)

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-6)

*   [receive()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-receive--)
*   [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-supportsInterface-bytes4-)
*   [name()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-name--)
*   [version()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-version--)
*   [hashProposal(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-hashProposal-address---uint256---bytes---bytes32-)
*   [state(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-state-uint256-)
*   [proposalThreshold()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalThreshold--)
*   [proposalSnapshot(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalSnapshot-uint256-)
*   [proposalProposer(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalProposer-uint256-)
*   [_quorumReached(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_quorumReached-uint256-)
*   [_voteSucceeded(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_voteSucceeded-uint256-)
*   [_getVotes(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_getVotes-address-uint256-bytes-)
*   [_countVote(proposalId, account, support, weight, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_countVote-uint256-address-uint8-uint256-bytes-)
*   [_defaultParams()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_defaultParams--)
*   [propose(targets, values, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-propose-address---uint256---bytes---string-)
*   [execute(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-execute-address---uint256---bytes---bytes32-)
*   [cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-cancel-address---uint256---bytes---bytes32-)
*   [_execute(, targets, values, calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_execute-uint256-address---uint256---bytes---bytes32-)
*   [_beforeExecute(, targets, , calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_beforeExecute-uint256-address---uint256---bytes---bytes32-)
*   [_afterExecute(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_afterExecute-uint256-address---uint256---bytes---bytes32-)
*   [_cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_cancel-address---uint256---bytes---bytes32-)
*   [getVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotes-address-uint256-)
*   [getVotesWithParams(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotesWithParams-address-uint256-bytes-)
*   [castVote(proposalId, support)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVote-uint256-uint8-)
*   [castVoteWithReason(proposalId, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReason-uint256-uint8-string-)
*   [castVoteWithReasonAndParams(proposalId, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
*   [castVoteBySig(proposalId, support, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
*   [castVoteWithReasonAndParamsBySig(proposalId, support, reason, params, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)
*   [_castVote(proposalId, account, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-)
*   [relay(target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-relay-address-uint256-bytes-)
*   [_executor()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_executor--)
*   [onERC721Received(, , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC721Received-address-address-uint256-bytes-)
*   [onERC1155Received(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155Received-address-address-uint256-uint256-bytes-)
*   [onERC1155BatchReceived(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155BatchReceived-address-address-uint256---uint256---bytes-)
*   [_isValidDescriptionForProposer(proposer, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_isValidDescriptionForProposer-address-string-)
*   [BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-BALLOT_TYPEHASH-bytes32)
*   [EXTENDED_BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-EXTENDED_BALLOT_TYPEHASH-bytes32)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-8)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-8)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-9)

*   [clock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-clock--)
*   [CLOCK_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-CLOCK_MODE--)
*   [COUNTING_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-COUNTING_MODE--)
*   [votingDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--)
*   [votingPeriod()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--)
*   [quorum(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-quorum-uint256-)
*   [hasVoted(proposalId, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hasVoted-uint256-address-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-10)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-6)

*   [_domainSeparatorV4()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_domainSeparatorV4--)
*   [_hashTypedDataV4(structHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_hashTypedDataV4-bytes32-)
*   [eip712Domain()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-eip712Domain--)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-6)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-8)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-12)

### Events

*   [ProposalExtended(proposalId, extendedDeadline)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-ProposalExtended-uint256-uint64-)
*   [LateQuorumVoteExtensionSet(oldVoteExtension, newVoteExtension)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-LateQuorumVoteExtensionSet-uint64-uint64-)

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-7)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-9)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-9)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-10)

*   [ProposalCreated(proposalId, proposer, targets, values, signatures, calldatas, voteStart, voteEnd, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-)
*   [ProposalCanceled(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-)
*   [ProposalExecuted(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-)
*   [VoteCast(voter, proposalId, support, weight, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-)
*   [VoteCastWithParams(voter, proposalId, support, weight, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-11)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-7)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-7)

*   [EIP712DomainChanged()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IERC5267-EIP712DomainChanged--)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-9)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-13)

constructor(uint64 initialVoteExtension)

Initializes the vote extension parameter: the time in either number of blocks or seconds (depending on the governor clock mode) that is required to pass since the moment a proposal reaches quorum until its voting period ends. If necessary the voting period will be extended beyond the one set during proposal creation.

proposalDeadline(uint256 proposalId) → uint256

Returns the proposal deadline, which may have been extended beyond that set at proposal creation, if the proposal reached quorum late in the voting period. See [`Governor.proposalDeadline`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalDeadline-uint256-).

_castVote(uint256 proposalId, address account, uint8 support, string reason, bytes params) → uint256

Casts a vote and detects if it caused quorum to be reached, potentially extending the voting period. See [`Governor._castVote`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-bytes-).

May emit a [`GovernorPreventLateQuorum.ProposalExtended`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-ProposalExtended-uint256-uint64-) event.

lateQuorumVoteExtension() → uint64

Returns the current value of the vote extension parameter: the number of blocks that are required to pass from the time a proposal reaches quorum until its voting period ends.

setLateQuorumVoteExtension(uint64 newVoteExtension)

Changes the [`GovernorPreventLateQuorum.lateQuorumVoteExtension`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-lateQuorumVoteExtension--). This operation can only be performed by the governance executor, generally through a governance proposal.

Emits a [`GovernorPreventLateQuorum.LateQuorumVoteExtensionSet`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-LateQuorumVoteExtensionSet-uint64-uint64-) event.

_setLateQuorumVoteExtension(uint64 newVoteExtension)

Changes the [`GovernorPreventLateQuorum.lateQuorumVoteExtension`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-lateQuorumVoteExtension--). This is an internal function that can be exposed in a public function like [`GovernorPreventLateQuorum.setLateQuorumVoteExtension`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-setLateQuorumVoteExtension-uint64-) if another access control mechanism is needed.

Emits a [`GovernorPreventLateQuorum.LateQuorumVoteExtensionSet`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-LateQuorumVoteExtensionSet-uint64-uint64-) event.

ProposalExtended(uint256 indexed proposalId, uint64 extendedDeadline)

Emitted when a proposal deadline is pushed back due to reaching quorum late in its voting period.

LateQuorumVoteExtensionSet(uint64 oldVoteExtension, uint64 newVoteExtension)

Emitted when the [`GovernorPreventLateQuorum.lateQuorumVoteExtension`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-lateQuorumVoteExtension--) parameter is changed.

`import "@openzeppelin/contracts/governance/extensions/GovernorProposalThreshold.sol";`

Extension of [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor) for proposal restriction to token holders with a minimum balance.

_Available since v4.3._ _Deprecated since v4.4._

### Functions

*   [propose(targets, values, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorProposalThreshold-propose-address---uint256---bytes---string-)

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-8)

*   [receive()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-receive--)
*   [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-supportsInterface-bytes4-)
*   [name()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-name--)
*   [version()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-version--)
*   [hashProposal(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-hashProposal-address---uint256---bytes---bytes32-)
*   [state(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-state-uint256-)
*   [proposalThreshold()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalThreshold--)
*   [proposalSnapshot(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalSnapshot-uint256-)
*   [proposalDeadline(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalDeadline-uint256-)
*   [proposalProposer(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalProposer-uint256-)
*   [_quorumReached(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_quorumReached-uint256-)
*   [_voteSucceeded(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_voteSucceeded-uint256-)
*   [_getVotes(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_getVotes-address-uint256-bytes-)
*   [_countVote(proposalId, account, support, weight, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_countVote-uint256-address-uint8-uint256-bytes-)
*   [_defaultParams()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_defaultParams--)
*   [execute(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-execute-address---uint256---bytes---bytes32-)
*   [cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-cancel-address---uint256---bytes---bytes32-)
*   [_execute(, targets, values, calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_execute-uint256-address---uint256---bytes---bytes32-)
*   [_beforeExecute(, targets, , calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_beforeExecute-uint256-address---uint256---bytes---bytes32-)
*   [_afterExecute(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_afterExecute-uint256-address---uint256---bytes---bytes32-)
*   [_cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_cancel-address---uint256---bytes---bytes32-)
*   [getVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotes-address-uint256-)
*   [getVotesWithParams(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotesWithParams-address-uint256-bytes-)
*   [castVote(proposalId, support)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVote-uint256-uint8-)
*   [castVoteWithReason(proposalId, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReason-uint256-uint8-string-)
*   [castVoteWithReasonAndParams(proposalId, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
*   [castVoteBySig(proposalId, support, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
*   [castVoteWithReasonAndParamsBySig(proposalId, support, reason, params, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)
*   [_castVote(proposalId, account, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-)
*   [_castVote(proposalId, account, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-bytes-)
*   [relay(target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-relay-address-uint256-bytes-)
*   [_executor()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_executor--)
*   [onERC721Received(, , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC721Received-address-address-uint256-bytes-)
*   [onERC1155Received(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155Received-address-address-uint256-uint256-bytes-)
*   [onERC1155BatchReceived(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155BatchReceived-address-address-uint256---uint256---bytes-)
*   [_isValidDescriptionForProposer(proposer, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_isValidDescriptionForProposer-address-string-)
*   [BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-BALLOT_TYPEHASH-bytes32)
*   [EXTENDED_BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-EXTENDED_BALLOT_TYPEHASH-bytes32)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-10)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-10)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-11)

*   [clock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-clock--)
*   [CLOCK_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-CLOCK_MODE--)
*   [COUNTING_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-COUNTING_MODE--)
*   [votingDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--)
*   [votingPeriod()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--)
*   [quorum(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-quorum-uint256-)
*   [hasVoted(proposalId, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hasVoted-uint256-address-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-12)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-8)

*   [_domainSeparatorV4()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_domainSeparatorV4--)
*   [_hashTypedDataV4(structHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_hashTypedDataV4-bytes32-)
*   [eip712Domain()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-eip712Domain--)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-8)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-10)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-14)

### Events

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-9)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-11)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-11)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-12)

*   [ProposalCreated(proposalId, proposer, targets, values, signatures, calldatas, voteStart, voteEnd, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-)
*   [ProposalCanceled(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-)
*   [ProposalExecuted(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-)
*   [VoteCast(voter, proposalId, support, weight, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-)
*   [VoteCastWithParams(voter, proposalId, support, weight, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-13)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-9)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-9)

*   [EIP712DomainChanged()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IERC5267-EIP712DomainChanged--)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-11)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-15)

propose(address[] targets, uint256[] values, bytes[] calldatas, string description) → uint256

See [`IGovernor.propose`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-propose-address---uint256---bytes---string-). This function has opt-in frontrunning protection, described in [`Governor._isValidDescriptionForProposer`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_isValidDescriptionForProposer-address-string-).

`import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";`

Extension of [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor) for settings updatable through governance.

_Available since v4.4._

### Functions

*   [constructor(initialVotingDelay, initialVotingPeriod, initialProposalThreshold)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-constructor-uint256-uint256-uint256-)
*   [votingDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-votingDelay--)
*   [votingPeriod()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-votingPeriod--)
*   [proposalThreshold()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-proposalThreshold--)
*   [setVotingDelay(newVotingDelay)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-setVotingDelay-uint256-)
*   [setVotingPeriod(newVotingPeriod)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-setVotingPeriod-uint256-)
*   [setProposalThreshold(newProposalThreshold)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-setProposalThreshold-uint256-)
*   [_setVotingDelay(newVotingDelay)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-_setVotingDelay-uint256-)
*   [_setVotingPeriod(newVotingPeriod)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-_setVotingPeriod-uint256-)
*   [_setProposalThreshold(newProposalThreshold)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-_setProposalThreshold-uint256-)

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-10)

*   [receive()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-receive--)
*   [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-supportsInterface-bytes4-)
*   [name()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-name--)
*   [version()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-version--)
*   [hashProposal(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-hashProposal-address---uint256---bytes---bytes32-)
*   [state(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-state-uint256-)
*   [proposalSnapshot(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalSnapshot-uint256-)
*   [proposalDeadline(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalDeadline-uint256-)
*   [proposalProposer(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalProposer-uint256-)
*   [_quorumReached(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_quorumReached-uint256-)
*   [_voteSucceeded(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_voteSucceeded-uint256-)
*   [_getVotes(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_getVotes-address-uint256-bytes-)
*   [_countVote(proposalId, account, support, weight, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_countVote-uint256-address-uint8-uint256-bytes-)
*   [_defaultParams()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_defaultParams--)
*   [propose(targets, values, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-propose-address---uint256---bytes---string-)
*   [execute(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-execute-address---uint256---bytes---bytes32-)
*   [cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-cancel-address---uint256---bytes---bytes32-)
*   [_execute(, targets, values, calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_execute-uint256-address---uint256---bytes---bytes32-)
*   [_beforeExecute(, targets, , calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_beforeExecute-uint256-address---uint256---bytes---bytes32-)
*   [_afterExecute(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_afterExecute-uint256-address---uint256---bytes---bytes32-)
*   [_cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_cancel-address---uint256---bytes---bytes32-)
*   [getVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotes-address-uint256-)
*   [getVotesWithParams(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotesWithParams-address-uint256-bytes-)
*   [castVote(proposalId, support)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVote-uint256-uint8-)
*   [castVoteWithReason(proposalId, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReason-uint256-uint8-string-)
*   [castVoteWithReasonAndParams(proposalId, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
*   [castVoteBySig(proposalId, support, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
*   [castVoteWithReasonAndParamsBySig(proposalId, support, reason, params, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)
*   [_castVote(proposalId, account, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-)
*   [_castVote(proposalId, account, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-bytes-)
*   [relay(target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-relay-address-uint256-bytes-)
*   [_executor()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_executor--)
*   [onERC721Received(, , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC721Received-address-address-uint256-bytes-)
*   [onERC1155Received(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155Received-address-address-uint256-uint256-bytes-)
*   [onERC1155BatchReceived(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155BatchReceived-address-address-uint256---uint256---bytes-)
*   [_isValidDescriptionForProposer(proposer, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_isValidDescriptionForProposer-address-string-)
*   [BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-BALLOT_TYPEHASH-bytes32)
*   [EXTENDED_BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-EXTENDED_BALLOT_TYPEHASH-bytes32)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-12)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-12)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-13)

*   [clock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-clock--)
*   [CLOCK_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-CLOCK_MODE--)
*   [COUNTING_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-COUNTING_MODE--)
*   [quorum(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-quorum-uint256-)
*   [hasVoted(proposalId, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hasVoted-uint256-address-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-14)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-10)

*   [_domainSeparatorV4()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_domainSeparatorV4--)
*   [_hashTypedDataV4(structHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_hashTypedDataV4-bytes32-)
*   [eip712Domain()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-eip712Domain--)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-10)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-12)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-16)

### Events

*   [VotingDelaySet(oldVotingDelay, newVotingDelay)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-VotingDelaySet-uint256-uint256-)
*   [VotingPeriodSet(oldVotingPeriod, newVotingPeriod)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-VotingPeriodSet-uint256-uint256-)
*   [ProposalThresholdSet(oldProposalThreshold, newProposalThreshold)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-ProposalThresholdSet-uint256-uint256-)

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-11)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-13)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-13)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-14)

*   [ProposalCreated(proposalId, proposer, targets, values, signatures, calldatas, voteStart, voteEnd, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-)
*   [ProposalCanceled(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-)
*   [ProposalExecuted(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-)
*   [VoteCast(voter, proposalId, support, weight, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-)
*   [VoteCastWithParams(voter, proposalId, support, weight, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-15)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-11)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-11)

*   [EIP712DomainChanged()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IERC5267-EIP712DomainChanged--)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-13)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-17)

constructor(uint256 initialVotingDelay, uint256 initialVotingPeriod, uint256 initialProposalThreshold)

Initialize the governance parameters.

votingDelay() → uint256

See [`IGovernor.votingDelay`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--).

votingPeriod() → uint256

See [`IGovernor.votingPeriod`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--).

proposalThreshold() → uint256

setVotingDelay(uint256 newVotingDelay)

Update the voting delay. This operation can only be performed through a governance proposal.

Emits a [`GovernorSettings.VotingDelaySet`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-VotingDelaySet-uint256-uint256-) event.

setVotingPeriod(uint256 newVotingPeriod)

Update the voting period. This operation can only be performed through a governance proposal.

Emits a [`GovernorSettings.VotingPeriodSet`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-VotingPeriodSet-uint256-uint256-) event.

setProposalThreshold(uint256 newProposalThreshold)

Update the proposal threshold. This operation can only be performed through a governance proposal.

Emits a [`GovernorSettings.ProposalThresholdSet`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-ProposalThresholdSet-uint256-uint256-) event.

_setVotingDelay(uint256 newVotingDelay)

Internal setter for the voting delay.

Emits a [`GovernorSettings.VotingDelaySet`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-VotingDelaySet-uint256-uint256-) event.

_setVotingPeriod(uint256 newVotingPeriod)

Internal setter for the voting period.

Emits a [`GovernorSettings.VotingPeriodSet`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-VotingPeriodSet-uint256-uint256-) event.

_setProposalThreshold(uint256 newProposalThreshold)

Internal setter for the proposal threshold.

Emits a [`GovernorSettings.ProposalThresholdSet`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-ProposalThresholdSet-uint256-uint256-) event.

VotingDelaySet(uint256 oldVotingDelay, uint256 newVotingDelay)

VotingPeriodSet(uint256 oldVotingPeriod, uint256 newVotingPeriod)

ProposalThresholdSet(uint256 oldProposalThreshold, uint256 newProposalThreshold)

`import "@openzeppelin/contracts/governance/extensions/GovernorTimelockCompound.sol";`

Extension of [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor) that binds the execution process to a Compound Timelock. This adds a delay, enforced by the external timelock to all successful proposal (in addition to the voting duration). The [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor) needs to be the admin of the timelock for any operation to be performed. A public, unrestricted, [`GovernorTimelockCompound.__acceptAdmin`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound-__acceptAdmin--) is available to accept ownership of the timelock.

Using this model means the proposal will be operated by the [`TimelockController`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController) and not by the [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor). Thus, the assets and permissions must be attached to the [`TimelockController`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController). Any asset sent to the [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor) will be inaccessible.

_Available since v4.3._

### Functions

*   [constructor(timelockAddress)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound-constructor-contract-ICompoundTimelock-)
*   [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound-supportsInterface-bytes4-)
*   [state(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound-state-uint256-)
*   [timelock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound-timelock--)
*   [proposalEta(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound-proposalEta-uint256-)
*   [queue(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound-queue-address---uint256---bytes---bytes32-)
*   [_execute(proposalId, targets, values, calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound-_execute-uint256-address---uint256---bytes---bytes32-)
*   [_cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound-_cancel-address---uint256---bytes---bytes32-)
*   [_executor()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound-_executor--)
*   [__acceptAdmin()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound-__acceptAdmin--)
*   [updateTimelock(newTimelock)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound-updateTimelock-contract-ICompoundTimelock-)

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-12)

*   [receive()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-receive--)
*   [name()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-name--)
*   [version()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-version--)
*   [hashProposal(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-hashProposal-address---uint256---bytes---bytes32-)
*   [proposalThreshold()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalThreshold--)
*   [proposalSnapshot(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalSnapshot-uint256-)
*   [proposalDeadline(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalDeadline-uint256-)
*   [proposalProposer(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalProposer-uint256-)
*   [_quorumReached(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_quorumReached-uint256-)
*   [_voteSucceeded(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_voteSucceeded-uint256-)
*   [_getVotes(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_getVotes-address-uint256-bytes-)
*   [_countVote(proposalId, account, support, weight, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_countVote-uint256-address-uint8-uint256-bytes-)
*   [_defaultParams()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_defaultParams--)
*   [propose(targets, values, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-propose-address---uint256---bytes---string-)
*   [execute(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-execute-address---uint256---bytes---bytes32-)
*   [cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-cancel-address---uint256---bytes---bytes32-)
*   [_beforeExecute(, targets, , calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_beforeExecute-uint256-address---uint256---bytes---bytes32-)
*   [_afterExecute(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_afterExecute-uint256-address---uint256---bytes---bytes32-)
*   [getVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotes-address-uint256-)
*   [getVotesWithParams(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotesWithParams-address-uint256-bytes-)
*   [castVote(proposalId, support)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVote-uint256-uint8-)
*   [castVoteWithReason(proposalId, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReason-uint256-uint8-string-)
*   [castVoteWithReasonAndParams(proposalId, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
*   [castVoteBySig(proposalId, support, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
*   [castVoteWithReasonAndParamsBySig(proposalId, support, reason, params, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)
*   [_castVote(proposalId, account, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-)
*   [_castVote(proposalId, account, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-bytes-)
*   [relay(target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-relay-address-uint256-bytes-)
*   [onERC721Received(, , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC721Received-address-address-uint256-bytes-)
*   [onERC1155Received(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155Received-address-address-uint256-uint256-bytes-)
*   [onERC1155BatchReceived(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155BatchReceived-address-address-uint256---uint256---bytes-)
*   [_isValidDescriptionForProposer(proposer, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_isValidDescriptionForProposer-address-string-)
*   [BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-BALLOT_TYPEHASH-bytes32)
*   [EXTENDED_BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-EXTENDED_BALLOT_TYPEHASH-bytes32)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-14)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-14)

#### [IGovernorTimelock](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernortimelock-2)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-15)

*   [clock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-clock--)
*   [CLOCK_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-CLOCK_MODE--)
*   [COUNTING_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-COUNTING_MODE--)
*   [votingDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--)
*   [votingPeriod()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--)
*   [quorum(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-quorum-uint256-)
*   [hasVoted(proposalId, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hasVoted-uint256-address-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-16)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-12)

*   [_domainSeparatorV4()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_domainSeparatorV4--)
*   [_hashTypedDataV4(structHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_hashTypedDataV4-bytes32-)
*   [eip712Domain()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-eip712Domain--)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-12)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-14)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-18)

### Events

*   [TimelockChange(oldTimelock, newTimelock)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound-TimelockChange-address-address-)

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-13)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-15)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-15)

#### [IGovernorTimelock](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernortimelock-3)

*   [ProposalQueued(proposalId, eta)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorTimelock-ProposalQueued-uint256-uint256-)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-16)

*   [ProposalCreated(proposalId, proposer, targets, values, signatures, calldatas, voteStart, voteEnd, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-)
*   [ProposalCanceled(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-)
*   [ProposalExecuted(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-)
*   [VoteCast(voter, proposalId, support, weight, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-)
*   [VoteCastWithParams(voter, proposalId, support, weight, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-17)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-13)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-13)

*   [EIP712DomainChanged()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IERC5267-EIP712DomainChanged--)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-15)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-19)

constructor(contract ICompoundTimelock timelockAddress)

Set the timelock.

supportsInterface(bytes4 interfaceId) → bool

state(uint256 proposalId) → enum IGovernor.ProposalState

Overridden version of the [`Governor.state`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-state-uint256-) function with added support for the `Queued` and `Expired` state.

timelock() → address

Public accessor to check the address of the timelock

proposalEta(uint256 proposalId) → uint256

Public accessor to check the eta of a queued proposal

queue(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) → uint256

Function to queue a proposal to the timelock.

_execute(uint256 proposalId, address[] targets, uint256[] values, bytes[] calldatas, bytes32)

Overridden execute function that run the already queued proposal through the timelock.

_cancel(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) → uint256

Overridden version of the [`Governor._cancel`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_cancel-address---uint256---bytes---bytes32-) function to cancel the timelocked proposal if it as already been queued.

_executor() → address

Address through which the governor executes action. In this case, the timelock.

__acceptAdmin()

Accept admin right over the timelock.

updateTimelock(contract ICompoundTimelock newTimelock)

Public endpoint to update the underlying timelock instance. Restricted to the timelock itself, so updates must be proposed, scheduled, and executed through governance proposals.

For security reasons, the timelock must be handed over to another admin before setting up a new one. The two operations (hand over the timelock) and do the update can be batched in a single proposal.

Note that if the timelock admin has been handed over in a previous operation, we refuse updates made through the timelock if admin of the timelock has already been accepted and the operation is executed outside the scope of governance.

CAUTION: It is not recommended to change the timelock while there are other queued governance proposals.

TimelockChange(address oldTimelock, address newTimelock)

Emitted when the timelock controller used for proposal execution is modified.

`import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";`

Extension of [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor) that binds the execution process to an instance of [`TimelockController`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController). This adds a delay, enforced by the [`TimelockController`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController) to all successful proposal (in addition to the voting duration). The [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor) needs the proposer (and ideally the executor) roles for the [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor) to work properly.

Using this model means the proposal will be operated by the [`TimelockController`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController) and not by the [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor). Thus, the assets and permissions must be attached to the [`TimelockController`](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController). Any asset sent to the [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor) will be inaccessible.

Setting up the TimelockController to have additional proposers besides the governor is very risky, as it grants them powers that they must be trusted or known not to use: 1) [`Governor.onlyGovernance`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onlyGovernance--) functions like [`Governor.relay`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-relay-address-uint256-bytes-) are available to them through the timelock, and 2) approved governance proposals can be blocked by them, effectively executing a Denial of Service attack. This risk will be mitigated in a future release.

_Available since v4.3._

### Functions

*   [constructor(timelockAddress)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-constructor-contract-TimelockController-)
*   [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-supportsInterface-bytes4-)
*   [state(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-state-uint256-)
*   [timelock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-timelock--)
*   [proposalEta(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-proposalEta-uint256-)
*   [queue(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-queue-address---uint256---bytes---bytes32-)
*   [_execute(, targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-_execute-uint256-address---uint256---bytes---bytes32-)
*   [_cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-_cancel-address---uint256---bytes---bytes32-)
*   [_executor()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-_executor--)
*   [updateTimelock(newTimelock)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-updateTimelock-contract-TimelockController-)

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-14)

*   [receive()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-receive--)
*   [name()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-name--)
*   [version()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-version--)
*   [hashProposal(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-hashProposal-address---uint256---bytes---bytes32-)
*   [proposalThreshold()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalThreshold--)
*   [proposalSnapshot(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalSnapshot-uint256-)
*   [proposalDeadline(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalDeadline-uint256-)
*   [proposalProposer(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalProposer-uint256-)
*   [_quorumReached(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_quorumReached-uint256-)
*   [_voteSucceeded(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_voteSucceeded-uint256-)
*   [_getVotes(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_getVotes-address-uint256-bytes-)
*   [_countVote(proposalId, account, support, weight, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_countVote-uint256-address-uint8-uint256-bytes-)
*   [_defaultParams()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_defaultParams--)
*   [propose(targets, values, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-propose-address---uint256---bytes---string-)
*   [execute(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-execute-address---uint256---bytes---bytes32-)
*   [cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-cancel-address---uint256---bytes---bytes32-)
*   [_beforeExecute(, targets, , calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_beforeExecute-uint256-address---uint256---bytes---bytes32-)
*   [_afterExecute(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_afterExecute-uint256-address---uint256---bytes---bytes32-)
*   [getVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotes-address-uint256-)
*   [getVotesWithParams(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotesWithParams-address-uint256-bytes-)
*   [castVote(proposalId, support)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVote-uint256-uint8-)
*   [castVoteWithReason(proposalId, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReason-uint256-uint8-string-)
*   [castVoteWithReasonAndParams(proposalId, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
*   [castVoteBySig(proposalId, support, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
*   [castVoteWithReasonAndParamsBySig(proposalId, support, reason, params, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)
*   [_castVote(proposalId, account, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-)
*   [_castVote(proposalId, account, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-bytes-)
*   [relay(target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-relay-address-uint256-bytes-)
*   [onERC721Received(, , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC721Received-address-address-uint256-bytes-)
*   [onERC1155Received(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155Received-address-address-uint256-uint256-bytes-)
*   [onERC1155BatchReceived(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155BatchReceived-address-address-uint256---uint256---bytes-)
*   [_isValidDescriptionForProposer(proposer, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_isValidDescriptionForProposer-address-string-)
*   [BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-BALLOT_TYPEHASH-bytes32)
*   [EXTENDED_BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-EXTENDED_BALLOT_TYPEHASH-bytes32)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-16)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-16)

#### [IGovernorTimelock](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernortimelock-4)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-17)

*   [clock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-clock--)
*   [CLOCK_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-CLOCK_MODE--)
*   [COUNTING_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-COUNTING_MODE--)
*   [votingDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--)
*   [votingPeriod()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--)
*   [quorum(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-quorum-uint256-)
*   [hasVoted(proposalId, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hasVoted-uint256-address-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-18)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-14)

*   [_domainSeparatorV4()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_domainSeparatorV4--)
*   [_hashTypedDataV4(structHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_hashTypedDataV4-bytes32-)
*   [eip712Domain()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-eip712Domain--)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-14)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-16)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-20)

### Events

*   [TimelockChange(oldTimelock, newTimelock)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-TimelockChange-address-address-)

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-15)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-17)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-17)

#### [IGovernorTimelock](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernortimelock-5)

*   [ProposalQueued(proposalId, eta)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorTimelock-ProposalQueued-uint256-uint256-)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-18)

*   [ProposalCreated(proposalId, proposer, targets, values, signatures, calldatas, voteStart, voteEnd, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-)
*   [ProposalCanceled(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-)
*   [ProposalExecuted(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-)
*   [VoteCast(voter, proposalId, support, weight, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-)
*   [VoteCastWithParams(voter, proposalId, support, weight, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-19)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-15)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-15)

*   [EIP712DomainChanged()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IERC5267-EIP712DomainChanged--)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-17)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-21)

constructor(contract TimelockController timelockAddress)

Set the timelock.

supportsInterface(bytes4 interfaceId) → bool

state(uint256 proposalId) → enum IGovernor.ProposalState

Overridden version of the [`Governor.state`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-state-uint256-) function with added support for the `Queued` state.

timelock() → address

Public accessor to check the address of the timelock

proposalEta(uint256 proposalId) → uint256

Public accessor to check the eta of a queued proposal

queue(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) → uint256

Function to queue a proposal to the timelock.

_execute(uint256, address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash)

Overridden execute function that run the already queued proposal through the timelock.

_cancel(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) → uint256

Overridden version of the [`Governor._cancel`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_cancel-address---uint256---bytes---bytes32-) function to cancel the timelocked proposal if it as already been queued.

_executor() → address

Address through which the governor executes action. In this case, the timelock.

updateTimelock(contract TimelockController newTimelock)

Public endpoint to update the underlying timelock instance. Restricted to the timelock itself, so updates must be proposed, scheduled, and executed through governance proposals.

CAUTION: It is not recommended to change the timelock while there are other queued governance proposals.

TimelockChange(address oldTimelock, address newTimelock)

Emitted when the timelock controller used for proposal execution is modified.

`import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";`

Extension of [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor) for voting weight extraction from an [`ERC20Votes`](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC20#ERC20Votes) token, or since v4.5 an [`ERC721Votes`](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC721#ERC721Votes) token.

_Available since v4.3._

### Functions

*   [constructor(tokenAddress)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotes-constructor-contract-IVotes-)
*   [clock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotes-clock--)
*   [CLOCK_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotes-CLOCK_MODE--)
*   [_getVotes(account, timepoint, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotes-_getVotes-address-uint256-bytes-)
*   [token()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotes-token-contract-IERC5805)

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-16)

*   [receive()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-receive--)
*   [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-supportsInterface-bytes4-)
*   [name()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-name--)
*   [version()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-version--)
*   [hashProposal(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-hashProposal-address---uint256---bytes---bytes32-)
*   [state(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-state-uint256-)
*   [proposalThreshold()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalThreshold--)
*   [proposalSnapshot(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalSnapshot-uint256-)
*   [proposalDeadline(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalDeadline-uint256-)
*   [proposalProposer(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalProposer-uint256-)
*   [_quorumReached(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_quorumReached-uint256-)
*   [_voteSucceeded(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_voteSucceeded-uint256-)
*   [_countVote(proposalId, account, support, weight, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_countVote-uint256-address-uint8-uint256-bytes-)
*   [_defaultParams()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_defaultParams--)
*   [propose(targets, values, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-propose-address---uint256---bytes---string-)
*   [execute(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-execute-address---uint256---bytes---bytes32-)
*   [cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-cancel-address---uint256---bytes---bytes32-)
*   [_execute(, targets, values, calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_execute-uint256-address---uint256---bytes---bytes32-)
*   [_beforeExecute(, targets, , calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_beforeExecute-uint256-address---uint256---bytes---bytes32-)
*   [_afterExecute(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_afterExecute-uint256-address---uint256---bytes---bytes32-)
*   [_cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_cancel-address---uint256---bytes---bytes32-)
*   [getVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotes-address-uint256-)
*   [getVotesWithParams(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotesWithParams-address-uint256-bytes-)
*   [castVote(proposalId, support)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVote-uint256-uint8-)
*   [castVoteWithReason(proposalId, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReason-uint256-uint8-string-)
*   [castVoteWithReasonAndParams(proposalId, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
*   [castVoteBySig(proposalId, support, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
*   [castVoteWithReasonAndParamsBySig(proposalId, support, reason, params, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)
*   [_castVote(proposalId, account, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-)
*   [_castVote(proposalId, account, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-bytes-)
*   [relay(target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-relay-address-uint256-bytes-)
*   [_executor()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_executor--)
*   [onERC721Received(, , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC721Received-address-address-uint256-bytes-)
*   [onERC1155Received(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155Received-address-address-uint256-uint256-bytes-)
*   [onERC1155BatchReceived(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155BatchReceived-address-address-uint256---uint256---bytes-)
*   [_isValidDescriptionForProposer(proposer, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_isValidDescriptionForProposer-address-string-)
*   [BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-BALLOT_TYPEHASH-bytes32)
*   [EXTENDED_BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-EXTENDED_BALLOT_TYPEHASH-bytes32)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-18)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-18)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-19)

*   [COUNTING_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-COUNTING_MODE--)
*   [votingDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--)
*   [votingPeriod()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--)
*   [quorum(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-quorum-uint256-)
*   [hasVoted(proposalId, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hasVoted-uint256-address-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-20)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-16)

*   [_domainSeparatorV4()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_domainSeparatorV4--)
*   [_hashTypedDataV4(structHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_hashTypedDataV4-bytes32-)
*   [eip712Domain()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-eip712Domain--)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-16)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-18)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-22)

### Events

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-17)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-19)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-19)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-20)

*   [ProposalCreated(proposalId, proposer, targets, values, signatures, calldatas, voteStart, voteEnd, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-)
*   [ProposalCanceled(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-)
*   [ProposalExecuted(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-)
*   [VoteCast(voter, proposalId, support, weight, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-)
*   [VoteCastWithParams(voter, proposalId, support, weight, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-21)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-17)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-17)

*   [EIP712DomainChanged()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IERC5267-EIP712DomainChanged--)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-19)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-23)

constructor(contract IVotes tokenAddress)

clock() → uint48

Clock (as specified in EIP-6372) is set to match the token's clock. Fallback to block numbers if the token does not implement EIP-6372.

CLOCK_MODE() → string

Machine-readable description of the clock as specified in EIP-6372.

_getVotes(address account, uint256 timepoint, bytes) → uint256

token() → contract IERC5805

`import "@openzeppelin/contracts/governance/extensions/GovernorVotesComp.sol";`

Extension of [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor) for voting weight extraction from a Comp token.

_Available since v4.3._

### Functions

*   [constructor(token_)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesComp-constructor-contract-ERC20VotesComp-)
*   [clock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesComp-clock--)
*   [CLOCK_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesComp-CLOCK_MODE--)
*   [_getVotes(account, timepoint, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesComp-_getVotes-address-uint256-bytes-)
*   [token()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesComp-token-contract-ERC20VotesComp)

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-18)

*   [receive()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-receive--)
*   [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-supportsInterface-bytes4-)
*   [name()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-name--)
*   [version()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-version--)
*   [hashProposal(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-hashProposal-address---uint256---bytes---bytes32-)
*   [state(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-state-uint256-)
*   [proposalThreshold()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalThreshold--)
*   [proposalSnapshot(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalSnapshot-uint256-)
*   [proposalDeadline(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalDeadline-uint256-)
*   [proposalProposer(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalProposer-uint256-)
*   [_quorumReached(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_quorumReached-uint256-)
*   [_voteSucceeded(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_voteSucceeded-uint256-)
*   [_countVote(proposalId, account, support, weight, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_countVote-uint256-address-uint8-uint256-bytes-)
*   [_defaultParams()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_defaultParams--)
*   [propose(targets, values, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-propose-address---uint256---bytes---string-)
*   [execute(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-execute-address---uint256---bytes---bytes32-)
*   [cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-cancel-address---uint256---bytes---bytes32-)
*   [_execute(, targets, values, calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_execute-uint256-address---uint256---bytes---bytes32-)
*   [_beforeExecute(, targets, , calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_beforeExecute-uint256-address---uint256---bytes---bytes32-)
*   [_afterExecute(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_afterExecute-uint256-address---uint256---bytes---bytes32-)
*   [_cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_cancel-address---uint256---bytes---bytes32-)
*   [getVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotes-address-uint256-)
*   [getVotesWithParams(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotesWithParams-address-uint256-bytes-)
*   [castVote(proposalId, support)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVote-uint256-uint8-)
*   [castVoteWithReason(proposalId, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReason-uint256-uint8-string-)
*   [castVoteWithReasonAndParams(proposalId, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
*   [castVoteBySig(proposalId, support, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
*   [castVoteWithReasonAndParamsBySig(proposalId, support, reason, params, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)
*   [_castVote(proposalId, account, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-)
*   [_castVote(proposalId, account, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-bytes-)
*   [relay(target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-relay-address-uint256-bytes-)
*   [_executor()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_executor--)
*   [onERC721Received(, , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC721Received-address-address-uint256-bytes-)
*   [onERC1155Received(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155Received-address-address-uint256-uint256-bytes-)
*   [onERC1155BatchReceived(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155BatchReceived-address-address-uint256---uint256---bytes-)
*   [_isValidDescriptionForProposer(proposer, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_isValidDescriptionForProposer-address-string-)
*   [BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-BALLOT_TYPEHASH-bytes32)
*   [EXTENDED_BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-EXTENDED_BALLOT_TYPEHASH-bytes32)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-20)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-20)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-21)

*   [COUNTING_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-COUNTING_MODE--)
*   [votingDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--)
*   [votingPeriod()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--)
*   [quorum(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-quorum-uint256-)
*   [hasVoted(proposalId, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hasVoted-uint256-address-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-22)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-18)

*   [_domainSeparatorV4()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_domainSeparatorV4--)
*   [_hashTypedDataV4(structHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_hashTypedDataV4-bytes32-)
*   [eip712Domain()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-eip712Domain--)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-18)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-20)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-24)

### Events

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-19)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-21)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-21)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-22)

*   [ProposalCreated(proposalId, proposer, targets, values, signatures, calldatas, voteStart, voteEnd, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-)
*   [ProposalCanceled(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-)
*   [ProposalExecuted(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-)
*   [VoteCast(voter, proposalId, support, weight, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-)
*   [VoteCastWithParams(voter, proposalId, support, weight, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-23)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-19)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-19)

*   [EIP712DomainChanged()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IERC5267-EIP712DomainChanged--)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-21)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-25)

constructor(contract ERC20VotesComp token_)

clock() → uint48

Clock (as specified in EIP-6372) is set to match the token's clock. Fallback to block numbers if the token does not implement EIP-6372.

CLOCK_MODE() → string

Machine-readable description of the clock as specified in EIP-6372.

_getVotes(address account, uint256 timepoint, bytes) → uint256

token() → contract ERC20VotesComp

`import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";`

Extension of [`Governor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor) for voting weight extraction from an [`ERC20Votes`](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC20#ERC20Votes) token and a quorum expressed as a fraction of the total supply.

_Available since v4.3._

### Functions

*   [constructor(quorumNumeratorValue)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-constructor-uint256-)
*   [quorumNumerator()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-quorumNumerator--)
*   [quorumNumerator(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-quorumNumerator-uint256-)
*   [quorumDenominator()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-quorumDenominator--)
*   [quorum(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-quorum-uint256-)
*   [updateQuorumNumerator(newQuorumNumerator)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-updateQuorumNumerator-uint256-)
*   [_updateQuorumNumerator(newQuorumNumerator)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-_updateQuorumNumerator-uint256-)

#### [GovernorVotes](https://docs.openzeppelin.com/contracts/4.x/api/governance#governorvotes-1)

*   [clock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotes-clock--)
*   [CLOCK_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotes-CLOCK_MODE--)
*   [_getVotes(account, timepoint, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotes-_getVotes-address-uint256-bytes-)
*   [token()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotes-token-contract-IERC5805)

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-20)

*   [receive()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-receive--)
*   [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-supportsInterface-bytes4-)
*   [name()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-name--)
*   [version()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-version--)
*   [hashProposal(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-hashProposal-address---uint256---bytes---bytes32-)
*   [state(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-state-uint256-)
*   [proposalThreshold()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalThreshold--)
*   [proposalSnapshot(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalSnapshot-uint256-)
*   [proposalDeadline(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalDeadline-uint256-)
*   [proposalProposer(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalProposer-uint256-)
*   [_quorumReached(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_quorumReached-uint256-)
*   [_voteSucceeded(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_voteSucceeded-uint256-)
*   [_countVote(proposalId, account, support, weight, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_countVote-uint256-address-uint8-uint256-bytes-)
*   [_defaultParams()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_defaultParams--)
*   [propose(targets, values, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-propose-address---uint256---bytes---string-)
*   [execute(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-execute-address---uint256---bytes---bytes32-)
*   [cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-cancel-address---uint256---bytes---bytes32-)
*   [_execute(, targets, values, calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_execute-uint256-address---uint256---bytes---bytes32-)
*   [_beforeExecute(, targets, , calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_beforeExecute-uint256-address---uint256---bytes---bytes32-)
*   [_afterExecute(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_afterExecute-uint256-address---uint256---bytes---bytes32-)
*   [_cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_cancel-address---uint256---bytes---bytes32-)
*   [getVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotes-address-uint256-)
*   [getVotesWithParams(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotesWithParams-address-uint256-bytes-)
*   [castVote(proposalId, support)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVote-uint256-uint8-)
*   [castVoteWithReason(proposalId, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReason-uint256-uint8-string-)
*   [castVoteWithReasonAndParams(proposalId, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
*   [castVoteBySig(proposalId, support, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
*   [castVoteWithReasonAndParamsBySig(proposalId, support, reason, params, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)
*   [_castVote(proposalId, account, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-)
*   [_castVote(proposalId, account, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-bytes-)
*   [relay(target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-relay-address-uint256-bytes-)
*   [_executor()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_executor--)
*   [onERC721Received(, , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC721Received-address-address-uint256-bytes-)
*   [onERC1155Received(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155Received-address-address-uint256-uint256-bytes-)
*   [onERC1155BatchReceived(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onERC1155BatchReceived-address-address-uint256---uint256---bytes-)
*   [_isValidDescriptionForProposer(proposer, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_isValidDescriptionForProposer-address-string-)
*   [BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-BALLOT_TYPEHASH-bytes32)
*   [EXTENDED_BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-EXTENDED_BALLOT_TYPEHASH-bytes32)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-22)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-22)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-23)

*   [COUNTING_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-COUNTING_MODE--)
*   [votingDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--)
*   [votingPeriod()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--)
*   [hasVoted(proposalId, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hasVoted-uint256-address-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-24)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-20)

*   [_domainSeparatorV4()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_domainSeparatorV4--)
*   [_hashTypedDataV4(structHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_hashTypedDataV4-bytes32-)
*   [eip712Domain()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-eip712Domain--)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-20)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-22)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-26)

### Events

*   [QuorumNumeratorUpdated(oldQuorumNumerator, newQuorumNumerator)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-QuorumNumeratorUpdated-uint256-uint256-)

#### [GovernorVotes](https://docs.openzeppelin.com/contracts/4.x/api/governance#governorvotes-2)

#### [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-21)

#### [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-23)

#### [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-23)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-24)

*   [ProposalCreated(proposalId, proposer, targets, values, signatures, calldatas, voteStart, voteEnd, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-)
*   [ProposalCanceled(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-)
*   [ProposalExecuted(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-)
*   [VoteCast(voter, proposalId, support, weight, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-)
*   [VoteCastWithParams(voter, proposalId, support, weight, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-25)

#### [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/governance#eip712-21)

#### [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-21)

*   [EIP712DomainChanged()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IERC5267-EIP712DomainChanged--)

#### [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-23)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-27)

constructor(uint256 quorumNumeratorValue)

Initialize quorum as a fraction of the token's total supply.

The fraction is specified as `numerator / denominator`. By default the denominator is 100, so quorum is specified as a percent: a numerator of 10 corresponds to quorum being 10% of total supply. The denominator can be customized by overriding [`GovernorVotesQuorumFraction.quorumDenominator`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-quorumDenominator--).

quorumNumerator() → uint256

Returns the current quorum numerator. See [`GovernorVotesQuorumFraction.quorumDenominator`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-quorumDenominator--).

quorumNumerator(uint256 timepoint) → uint256

Returns the quorum numerator at a specific timepoint. See [`GovernorVotesQuorumFraction.quorumDenominator`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-quorumDenominator--).

quorumDenominator() → uint256

Returns the quorum denominator. Defaults to 100, but may be overridden.

quorum(uint256 timepoint) → uint256

Returns the quorum for a timepoint, in terms of number of votes: `supply * numerator / denominator`.

updateQuorumNumerator(uint256 newQuorumNumerator)

Changes the quorum numerator.

Emits a [`GovernorVotesQuorumFraction.QuorumNumeratorUpdated`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-QuorumNumeratorUpdated-uint256-uint256-) event.

Requirements:

*   Must be called through a governance proposal.
*   New numerator must be smaller or equal to the denominator.

_updateQuorumNumerator(uint256 newQuorumNumerator)

Changes the quorum numerator.

Emits a [`GovernorVotesQuorumFraction.QuorumNumeratorUpdated`](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-QuorumNumeratorUpdated-uint256-uint256-) event.

Requirements:

*   New numerator must be smaller or equal to the denominator.

QuorumNumeratorUpdated(uint256 oldQuorumNumerator, uint256 newQuorumNumerator)

`import "@openzeppelin/contracts/governance/extensions/IGovernorTimelock.sol";`

Extension of the [`IGovernor`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor) for timelock supporting modules.

_Available since v4.3._

### Functions

*   [timelock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorTimelock-timelock--)
*   [proposalEta(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorTimelock-proposalEta-uint256-)
*   [queue(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorTimelock-queue-address---uint256---bytes---bytes32-)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-25)

*   [name()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-name--)
*   [version()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-version--)
*   [clock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-clock--)
*   [CLOCK_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-CLOCK_MODE--)
*   [COUNTING_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-COUNTING_MODE--)
*   [hashProposal(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hashProposal-address---uint256---bytes---bytes32-)
*   [state(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-state-uint256-)
*   [proposalSnapshot(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-proposalSnapshot-uint256-)
*   [proposalDeadline(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-proposalDeadline-uint256-)
*   [proposalProposer(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-proposalProposer-uint256-)
*   [votingDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingDelay--)
*   [votingPeriod()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--)
*   [quorum(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-quorum-uint256-)
*   [getVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-getVotes-address-uint256-)
*   [getVotesWithParams(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-getVotesWithParams-address-uint256-bytes-)
*   [hasVoted(proposalId, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hasVoted-uint256-address-)
*   [propose(targets, values, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-propose-address---uint256---bytes---string-)
*   [execute(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-execute-address---uint256---bytes---bytes32-)
*   [cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-cancel-address---uint256---bytes---bytes32-)
*   [castVote(proposalId, support)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVote-uint256-uint8-)
*   [castVoteWithReason(proposalId, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteWithReason-uint256-uint8-string-)
*   [castVoteWithReasonAndParams(proposalId, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
*   [castVoteBySig(proposalId, support, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
*   [castVoteWithReasonAndParamsBySig(proposalId, support, reason, params, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-26)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-28)

*   [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IERC165-supportsInterface-bytes4-)

### Events

*   [ProposalQueued(proposalId, eta)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorTimelock-ProposalQueued-uint256-uint256-)

#### [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-26)

*   [ProposalCreated(proposalId, proposer, targets, values, signatures, calldatas, voteStart, voteEnd, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-)
*   [ProposalCanceled(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-)
*   [ProposalExecuted(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-)
*   [VoteCast(voter, proposalId, support, weight, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-)
*   [VoteCastWithParams(voter, proposalId, support, weight, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-)

#### [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-27)

#### [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-29)

timelock() → address

proposalEta(uint256 proposalId) → uint256

queue(address[] targets, uint256[] values, bytes[] calldatas, bytes32 descriptionHash) → uint256 proposalId

ProposalQueued(uint256 proposalId, uint256 eta)

`import "@openzeppelin/contracts/governance/utils/IVotes.sol";`

Common interface for [`ERC20Votes`](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC20#ERC20Votes), [`ERC721Votes`](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC721#ERC721Votes), and other [`Votes`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes)-enabled contracts.

_Available since v4.5._

### Functions

*   [getVotes(account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IVotes-getVotes-address-)
*   [getPastVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IVotes-getPastVotes-address-uint256-)
*   [getPastTotalSupply(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IVotes-getPastTotalSupply-uint256-)
*   [delegates(account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IVotes-delegates-address-)
*   [delegate(delegatee)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IVotes-delegate-address-)
*   [delegateBySig(delegatee, nonce, expiry, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IVotes-delegateBySig-address-uint256-uint256-uint8-bytes32-bytes32-)

### Events

*   [DelegateChanged(delegator, fromDelegate, toDelegate)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IVotes-DelegateChanged-address-address-address-)
*   [DelegateVotesChanged(delegate, previousBalance, newBalance)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IVotes-DelegateVotesChanged-address-uint256-uint256-)

getVotes(address account) → uint256

Returns the current amount of votes that `account` has.

getPastVotes(address account, uint256 timepoint) → uint256

Returns the amount of votes that `account` had at a specific moment in the past. If the `clock()` is configured to use block numbers, this will return the value at the end of the corresponding block.

getPastTotalSupply(uint256 timepoint) → uint256

Returns the total supply of votes available at a specific moment in the past. If the `clock()` is configured to use block numbers, this will return the value at the end of the corresponding block.

NOTE: This value is the sum of all available votes, which is not necessarily the sum of all delegated votes. Votes that have not been delegated are still part of total supply, even though they would not participate in a vote.

delegates(address account) → address

Returns the delegate that `account` has chosen.

delegate(address delegatee)

Delegates votes from the sender to `delegatee`.

delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s)

Delegates votes from signer to `delegatee`.

DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate)

Emitted when an account changes their delegate.

DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance)

Emitted when a token transfer or delegate change results in changes to a delegate's number of votes.

`import "@openzeppelin/contracts/governance/utils/Votes.sol";`

This is a base abstract contract that tracks voting units, which are a measure of voting power that can be transferred, and provides a system of vote delegation, where an account can delegate its voting units to a sort of "representative" that will pool delegated voting units from different accounts and can then use it to vote in decisions. In fact, voting units _must_ be delegated in order to count as actual votes, and an account has to delegate those votes to itself if it wishes to participate in decisions and does not have a trusted representative.

This contract is often combined with a token contract such that voting units correspond to token units. For an example, see [`ERC721Votes`](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC721#ERC721Votes).

The full history of delegate votes is tracked on-chain so that governance protocols can consider votes as distributed at a particular block number to protect against flash loans and double voting. The opt-in delegate system makes the cost of this history tracking optional.

When using this module the derived contract must implement [`Votes._getVotingUnits`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-_getVotingUnits-address-) (for example, make it return [`ERC721.balanceOf`](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC721#ERC721-balanceOf-address-)), and can use [`Votes._transferVotingUnits`](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-_transferVotingUnits-address-address-uint256-) to track a change in the distribution of those units (in the previous example, it would be included in [`ERC721._beforeTokenTransfer`](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC721#ERC721-_beforeTokenTransfer-address-address-uint256-uint256-)).

_Available since v4.5._

clock() → uint48

Clock used for flagging checkpoints. Can be overridden to implement timestamp based checkpoints (and voting), in which case [`IGovernor.CLOCK_MODE`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-CLOCK_MODE--) should be overridden as well to match.

CLOCK_MODE() → string

Machine-readable description of the clock as specified in EIP-6372.

getVotes(address account) → uint256

Returns the current amount of votes that `account` has.

getPastVotes(address account, uint256 timepoint) → uint256

Returns the amount of votes that `account` had at a specific moment in the past. If the `clock()` is configured to use block numbers, this will return the value at the end of the corresponding block.

Requirements:

*   `timepoint` must be in the past. If operating using block numbers, the block must be already mined.

getPastTotalSupply(uint256 timepoint) → uint256

Returns the total supply of votes available at a specific moment in the past. If the `clock()` is configured to use block numbers, this will return the value at the end of the corresponding block.

NOTE: This value is the sum of all available votes, which is not necessarily the sum of all delegated votes. Votes that have not been delegated are still part of total supply, even though they would not participate in a vote.

Requirements:

*   `timepoint` must be in the past. If operating using block numbers, the block must be already mined.

_getTotalSupply() → uint256

Returns the current total supply of votes.

delegates(address account) → address

Returns the delegate that `account` has chosen.

delegate(address delegatee)

Delegates votes from the sender to `delegatee`.

delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s)

Delegates votes from signer to `delegatee`.

_delegate(address account, address delegatee)

Delegate all of `account`'s voting units to `delegatee`.

Emits events [`IVotes.DelegateChanged`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IVotes-DelegateChanged-address-address-address-) and [`IVotes.DelegateVotesChanged`](https://docs.openzeppelin.com/contracts/4.x/api/governance#IVotes-DelegateVotesChanged-address-uint256-uint256-).

_transferVotingUnits(address from, address to, uint256 amount)

Transfers, mints, or burns voting units. To register a mint, `from` should be zero. To register a burn, `to` should be zero. Total supply of voting units will be adjusted with mints and burns.

_useNonce(address owner) → uint256 current

Consumes a nonce.

Returns the current value and increments nonce.

nonces(address owner) → uint256

Returns an address nonce.

DOMAIN_SEPARATOR() → bytes32

Returns the contract's [`EIP712`](https://docs.openzeppelin.com/contracts/4.x/api/utils#EIP712) domain separator.

_getVotingUnits(address) → uint256

Must return the voting units held by an account.

Links/Buttons:
- [](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.6/contracts/governance/utils/Votes.sol)
- [Forum](https://forum.openzeppelin.com/)
- [Website](https://openzeppelin.com/)
- [Impact](https://docs.openzeppelin.com/impact)
- [Getting Started](https://docs.openzeppelin.com/contracts)
- [Overview](https://docs.openzeppelin.com/contracts/4.x)
- [Contracts Wizard](https://wizard.openzeppelin.com/#governor)
- [Extending Contracts](https://docs.openzeppelin.com/contracts/4.x/extending-contracts)
- [Using with Upgrades](https://docs.openzeppelin.com/contracts/4.x/upgradeable)
- [Backwards Compatibility](https://docs.openzeppelin.com/contracts/5.x/backwards-compatibility)
- [Access Control](https://docs.openzeppelin.com/contracts/4.x/access-control)
- [Account Abstraction](https://docs.openzeppelin.com/contracts/5.x/account-abstraction)
- [Tokens](https://docs.openzeppelin.com/contracts/4.x/tokens)
- [Governance](https://docs.openzeppelin.com/contracts/4.x/api/governance)
- [Utilities](https://docs.openzeppelin.com/contracts/4.x/utilities)
- [Subgraphs](https://docs.openzeppelin.com/contracts/5.x/subgraphs)
- [FAQ](https://docs.openzeppelin.com/contracts/5.x/faq)
- [Changelog](https://docs.openzeppelin.com/contracts/5.x/changelog)
- [API Reference](https://docs.openzeppelin.com/contracts/4.x/api)
- [Releases & Stability](https://docs.openzeppelin.com/contracts/4.x/releases-stability)
- [Crosschain](https://docs.openzeppelin.com/contracts/4.x/api/crosschain)
- [Drafts](https://docs.openzeppelin.com/contracts/4.x/drafts)
- [Crowdsales (Legacy)](https://docs.openzeppelin.com/contracts/4.x/crowdsales)
- [Access](https://docs.openzeppelin.com/contracts/4.x/api/access)
- [Finance](https://docs.openzeppelin.com/contracts/4.x/api/finance)
- [Interfaces](https://docs.openzeppelin.com/contracts/4.x/api/interfaces)
- [Meta Transactions](https://docs.openzeppelin.com/contracts/4.x/api/metatx)
- [Proxy](https://docs.openzeppelin.com/contracts/4.x/api/proxy)
- [Security](https://docs.openzeppelin.com/contracts/4.x/api/security)
- [Utils](https://docs.openzeppelin.com/contracts/4.x/api/governance#utils)
- [Community Contracts](https://docs.openzeppelin.com/community-contracts)
- [Upgrades Plugins](https://docs.openzeppelin.com/upgrades-plugins)
- [Ecosystem Adapters](https://docs.openzeppelin.com/ecosystem-adapters)
- [UIKit](https://docs.openzeppelin.com/tools/uikit)
- [Symbiotic Templates](https://docs.openzeppelin.com/symbiotic)
- [Relayer](https://docs.openzeppelin.com/relayer/1.5.x)
- [Monitor](https://docs.openzeppelin.com/monitor/1.3.x)
- [Role Manager](https://docs.openzeppelin.com/role-manager)
- [Outdated VersionYou're viewing an older version (v4.x) The latest documentation is available for the current version. Click here to visit latest version.](https://docs.openzeppelin.com/contracts/5.x/api/governance)
- [Open in Claude](https://claude.ai/new?q=Read+https%3A%2F%2Fraw.githubusercontent.com%2FOpenZeppelin%2Fdocs%2Frefs%2Fheads%2Fmain%2Fcontent%2Fcontracts%2F4.x%2Fapi%2Fgovernance.mdx%2C+I+want+to+ask+questions+about+it.)
- [Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor-21)
- [Compound’s Governor Alpha & Bravo](https://compound.finance/docs/governance)
- [GovernorVotes](https://docs.openzeppelin.com/contracts/4.x/api/governance#governorvotes-2)
- [ERC20Votes](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC20#ERC20Votes)
- [ERC721Votes](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC721#ERC721Votes)
- [GovernorVotesComp](https://docs.openzeppelin.com/contracts/4.x/api/governance#governorvotescomp)
- [ERC20VotesComp](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC20#ERC20VotesComp)
- [GovernorVotesQuorumFraction](https://docs.openzeppelin.com/contracts/4.x/api/governance#governorvotesquorumfraction)
- [GovernorCountingSimple](https://docs.openzeppelin.com/contracts/4.x/api/governance#governorcountingsimple)
- [GovernorTimelockControl](https://docs.openzeppelin.com/contracts/4.x/api/governance#governortimelockcontrol)
- [TimelockController](https://docs.openzeppelin.com/contracts/4.x/api/governance#timelockcontroller)
- [GovernorTimelockCompound](https://docs.openzeppelin.com/contracts/4.x/api/governance#governortimelockcompound)
- [Timelock](https://docs.openzeppelin.com/contracts/4.x/api/governance#timelock)
- [GovernorCompatibilityBravo](https://docs.openzeppelin.com/contracts/4.x/api/governance#governorcompatibilitybravo)
- [GovernorSettings](https://docs.openzeppelin.com/contracts/4.x/api/governance#governorsettings)
- [GovernorPreventLateQuorum](https://docs.openzeppelin.com/contracts/4.x/api/governance#governorpreventlatequorum)
- [votingDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-votingDelay--)
- [votingPeriod()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-votingPeriod--)
- [quorum(uint256 timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-quorum-uint256-)
- [Governor._cancel](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_cancel-address---uint256---bytes---bytes32-)
- [Core](https://docs.openzeppelin.com/contracts/4.x/api/governance#core)
- [IGovernor](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernor-26)
- [Modules](https://docs.openzeppelin.com/contracts/4.x/api/governance#modules)
- [Extensions](https://docs.openzeppelin.com/contracts/4.x/api/governance#extensions)
- [Deprecated](https://docs.openzeppelin.com/contracts/4.x/api/governance#deprecated)
- [GovernorProposalThreshold](https://docs.openzeppelin.com/contracts/4.x/api/governance#governorproposalthreshold)
- [Votes](https://docs.openzeppelin.com/contracts/4.x/api/governance#votes)
- [Terminology](https://docs.openzeppelin.com/contracts/4.x/api/governance#terminology)
- [operation lifecycle](https://docs.openzeppelin.com/contracts/4.x/access-control#operation_lifecycle)
- [Operation structure](https://docs.openzeppelin.com/contracts/4.x/api/governance#operation-structure)
- [Operation lifecycle](https://docs.openzeppelin.com/contracts/4.x/api/governance#operation-lifecycle)
- [schedule](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-schedule-address-uint256-bytes-bytes32-bytes32-uint256-)
- [scheduleBatch](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-scheduleBatch-address---uint256---bytes---bytes32-bytes32-uint256-)
- [getTimestamp](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-getTimestamp-bytes32-)
- [execute](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-TimelockController-execute-address-uint256-bytes-bytes32-bytes32-)
- [executeBatch](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-executeBatch-address---uint256---bytes---bytes32-bytes32-)
- [cancel](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-TimelockController-cancel-bytes32-)
- [isOperationPending(bytes32)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-isOperationPending-bytes32-)
- [isOperationReady(bytes32)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-isOperationReady-bytes32-)
- [isOperationDone(bytes32)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-isOperationDone-bytes32-)
- [Roles](https://docs.openzeppelin.com/contracts/4.x/api/governance#roles)
- [Admin](https://docs.openzeppelin.com/contracts/4.x/api/governance#admin)
- [Proposer](https://docs.openzeppelin.com/contracts/4.x/api/governance#proposer)
- [Executor](https://docs.openzeppelin.com/contracts/4.x/api/governance#executor)
- [AccessControl](https://docs.openzeppelin.com/contracts/4.x/api/governance#accesscontrol-1)
- [IGovernor.quorum](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-quorum-uint256-)
- [Governor._quorumReached](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_quorumReached-uint256-)
- [Governor._voteSucceeded](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_voteSucceeded-uint256-)
- [Governor._countVote](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_countVote-uint256-address-uint8-uint256-bytes-)
- [Governor._getVotes](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_getVotes-address-uint256-bytes-)
- [IGovernor.votingPeriod](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-votingPeriod--)
- [onlyGovernance()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-onlyGovernance--)
- [constructor(name_)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-constructor-string-)
- [receive()](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-receive--)
- [supportsInterface(interfaceId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-supportsInterface-bytes4-)
- [name()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-name--)
- [version()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-version--)
- [hashProposal(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-hashProposal-address---uint256---bytes---bytes32-)
- [state(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-state-uint256-)
- [proposalThreshold()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-proposalThreshold--)
- [proposalSnapshot(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-proposalSnapshot-uint256-)
- [proposalDeadline(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-proposalDeadline-uint256-)
- [proposalProposer(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-proposalProposer-uint256-)
- [_defaultParams()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_defaultParams--)
- [propose(targets, values, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorProposalThreshold-propose-address---uint256---bytes---string-)
- [execute(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-execute-address---uint256---bytes---bytes32-)
- [cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-cancel-address---uint256---bytes---bytes32-)
- [_execute(, targets, values, calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_execute-uint256-address---uint256---bytes---bytes32-)
- [_beforeExecute(, targets, , calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_beforeExecute-uint256-address---uint256---bytes---bytes32-)
- [_afterExecute(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_afterExecute-uint256-address---uint256---bytes---bytes32-)
- [getVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotes-address-uint256-)
- [getVotesWithParams(account, timepoint, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-getVotesWithParams-address-uint256-bytes-)
- [castVote(proposalId, support)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVote-uint256-uint8-)
- [castVoteWithReason(proposalId, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReason-uint256-uint8-string-)
- [castVoteWithReasonAndParams(proposalId, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
- [castVoteBySig(proposalId, support, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
- [castVoteWithReasonAndParamsBySig(proposalId, support, reason, params, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)
- [_castVote(proposalId, account, support, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_castVote-uint256-address-uint8-string-)
- [_castVote(proposalId, account, support, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-_castVote-uint256-address-uint8-string-bytes-)
- [relay(target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-relay-address-uint256-bytes-)
- [_executor()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-_executor--)
- [onERC721Received(, , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-onERC721Received-address-address-uint256-bytes-)
- [onERC1155Received(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-onERC1155Received-address-address-uint256-uint256-bytes-)
- [onERC1155BatchReceived(, , , , )](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-onERC1155BatchReceived-address-address-uint256---uint256---bytes-)
- [_isValidDescriptionForProposer(proposer, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-_isValidDescriptionForProposer-address-string-)
- [BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-BALLOT_TYPEHASH-bytes32)
- [EXTENDED_BALLOT_TYPEHASH()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Governor-EXTENDED_BALLOT_TYPEHASH-bytes32)
- [IERC1155Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc1155receiver-23)
- [IERC721Receiver](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc721receiver-23)
- [clock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-clock--)
- [CLOCK_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-CLOCK_MODE--)
- [COUNTING_MODE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCountingSimple-COUNTING_MODE--)
- [hasVoted(proposalId, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCountingSimple-hasVoted-uint256-address-)
- [IERC6372](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc6372-29)
- [EIP712](https://docs.openzeppelin.com/contracts/4.x/api/utils#EIP712)
- [_domainSeparatorV4()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_domainSeparatorV4--)
- [_hashTypedDataV4(structHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-_hashTypedDataV4-bytes32-)
- [eip712Domain()](https://docs.openzeppelin.com/contracts/4.x/api/governance#EIP712-eip712Domain--)
- [IERC5267](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5267-23)
- [ERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#erc165-23)
- [IERC165](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc165-29)
- [ProposalCreated(proposalId, proposer, targets, values, signatures, calldatas, voteStart, voteEnd, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCreated-uint256-address-address---uint256---string---bytes---uint256-uint256-string-)
- [ProposalCanceled(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalCanceled-uint256-)
- [ProposalExecuted(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-ProposalExecuted-uint256-)
- [VoteCast(voter, proposalId, support, weight, reason)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCast-address-uint256-uint8-uint256-string-)
- [VoteCastWithParams(voter, proposalId, support, weight, reason, params)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-VoteCastWithParams-address-uint256-uint8-uint256-string-bytes-)
- [EIP712DomainChanged()](https://docs.openzeppelin.com/contracts/4.x/api/governance#IERC5267-EIP712DomainChanged--)
- [IERC165.supportsInterface](https://docs.openzeppelin.com/contracts/4.x/api/utils#IERC165-supportsInterface-bytes4-)
- [IGovernor.name](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-name--)
- [IGovernor.version](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-version--)
- [IGovernor.hashProposal](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-hashProposal-address---uint256---bytes---bytes32-)
- [IGovernor.state](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-state-uint256-)
- [IGovernor.proposalSnapshot](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-proposalSnapshot-uint256-)
- [IGovernor.proposalDeadline](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-proposalDeadline-uint256-)
- [IGovernor.propose](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-propose-address---uint256---bytes---string-)
- [IGovernor.execute](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-execute-address---uint256---bytes---bytes32-)
- [IGovernor.cancel](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-cancel-address---uint256---bytes---bytes32-)
- [IGovernor.getVotes](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-getVotes-address-uint256-)
- [IGovernor.getVotesWithParams](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-getVotesWithParams-address-uint256-bytes-)
- [IGovernor.castVote](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVote-uint256-uint8-)
- [IGovernor.castVoteWithReason](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteWithReason-uint256-uint8-string-)
- [IGovernor.castVoteWithReasonAndParams](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteWithReasonAndParams-uint256-uint8-string-bytes-)
- [IGovernor.castVoteBySig](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteBySig-uint256-uint8-uint8-bytes32-bytes32-)
- [IGovernor.castVoteWithReasonAndParamsBySig](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernor-castVoteWithReasonAndParamsBySig-uint256-uint8-string-bytes-uint8-bytes32-bytes32-)
- [IERC721Receiver.onERC721Received](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC721#IERC721Receiver-onERC721Received-address-address-uint256-bytes-)
- [IERC1155Receiver.onERC1155Received](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC1155#IERC1155Receiver-onERC1155Received-address-address-uint256-uint256-bytes-)
- [IERC1155Receiver.onERC1155BatchReceived](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC1155#IERC1155Receiver-onERC1155BatchReceived-address-address-uint256---uint256---bytes-)
- [URLSearchParams](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams)
- [onlyRoleOrOpenRole(role)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-onlyRoleOrOpenRole-bytes32-)
- [constructor(minDelay, proposers, executors, admin)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-constructor-uint256-address---address---address-)
- [isOperation(id)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-isOperation-bytes32-)
- [getMinDelay()](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-getMinDelay--)
- [hashOperation(target, value, data, predecessor, salt)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-hashOperation-address-uint256-bytes-bytes32-bytes32-)
- [hashOperationBatch(targets, values, payloads, predecessor, salt)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-hashOperationBatch-address---uint256---bytes---bytes32-bytes32-)
- [cancel(id)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-cancel-bytes32-)
- [execute(target, value, payload, predecessor, salt)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-execute-address-uint256-bytes-bytes32-bytes32-)
- [_execute(target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-_execute-address-uint256-bytes-)
- [updateDelay(newDelay)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-updateDelay-uint256-)
- [TIMELOCK_ADMIN_ROLE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-TIMELOCK_ADMIN_ROLE-bytes32)
- [PROPOSER_ROLE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-PROPOSER_ROLE-bytes32)
- [EXECUTOR_ROLE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-EXECUTOR_ROLE-bytes32)
- [CANCELLER_ROLE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-CANCELLER_ROLE-bytes32)
- [hasRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-hasRole-bytes32-address-)
- [_checkRole(role)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-_checkRole-bytes32-)
- [_checkRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-_checkRole-bytes32-address-)
- [getRoleAdmin(role)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-getRoleAdmin-bytes32-)
- [grantRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-grantRole-bytes32-address-)
- [revokeRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-revokeRole-bytes32-address-)
- [renounceRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-renounceRole-bytes32-address-)
- [_setupRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-_setupRole-bytes32-address-)
- [_setRoleAdmin(role, adminRole)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-_setRoleAdmin-bytes32-bytes32-)
- [_grantRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-_grantRole-bytes32-address-)
- [_revokeRole(role, account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-_revokeRole-bytes32-address-)
- [DEFAULT_ADMIN_ROLE()](https://docs.openzeppelin.com/contracts/4.x/api/governance#AccessControl-DEFAULT_ADMIN_ROLE-bytes32)
- [IAccessControl](https://docs.openzeppelin.com/contracts/4.x/api/governance#iaccesscontrol-1)
- [CallScheduled(id, index, target, value, data, predecessor, delay)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-CallScheduled-bytes32-uint256-address-uint256-bytes-bytes32-uint256-)
- [CallExecuted(id, index, target, value, data)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-CallExecuted-bytes32-uint256-address-uint256-bytes-)
- [CallSalt(id, salt)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-CallSalt-bytes32-bytes32-)
- [Cancelled(id)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-Cancelled-bytes32-)
- [MinDelayChange(oldDuration, newDuration)](https://docs.openzeppelin.com/contracts/4.x/api/governance#TimelockController-MinDelayChange-uint256-uint256-)
- [RoleAdminChanged(role, previousAdminRole, newAdminRole)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IAccessControl-RoleAdminChanged-bytes32-bytes32-bytes32-)
- [RoleGranted(role, account, sender)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IAccessControl-RoleGranted-bytes32-address-address-)
- [RoleRevoked(role, account, sender)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IAccessControl-RoleRevoked-bytes32-address-address-)
- [IGovernorTimelock](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernortimelock-6)
- [propose(targets, values, signatures, calldatas, description)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-propose-address---uint256---string---bytes---string-)
- [queue(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-queue-uint256-)
- [execute(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-execute-uint256-)
- [cancel(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-cancel-uint256-)
- [proposals(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-proposals-uint256-)
- [getActions(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-getActions-uint256-)
- [getReceipt(proposalId, voter)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-getReceipt-uint256-address-)
- [quorumVotes()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCompatibilityBravo-quorumVotes--)
- [_quorumReached(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCountingSimple-_quorumReached-uint256-)
- [_voteSucceeded(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCountingSimple-_voteSucceeded-uint256-)
- [_countVote(proposalId, account, support, weight, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCountingSimple-_countVote-uint256-address-uint8-uint256-bytes-)
- [IGovernorCompatibilityBravo](https://docs.openzeppelin.com/contracts/4.x/api/governance#igovernorcompatibilitybravo-2)
- [timelock()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-timelock--)
- [proposalEta(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-proposalEta-uint256-)
- [queue(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-queue-address---uint256---bytes---bytes32-)
- [ProposalQueued(proposalId, eta)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorTimelock-ProposalQueued-uint256-uint256-)
- [IGovernorCompatibilityBravo.propose](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-propose-address---uint256---string---bytes---string-)
- [IGovernorCompatibilityBravo.queue](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-queue-uint256-)
- [IGovernorCompatibilityBravo.execute](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-execute-uint256-)
- [IGovernorCompatibilityBravo.proposals](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-proposals-uint256-)
- [IGovernorCompatibilityBravo.getActions](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-getActions-uint256-)
- [IGovernorCompatibilityBravo.getReceipt](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-getReceipt-uint256-address-)
- [IGovernorCompatibilityBravo.quorumVotes](https://docs.openzeppelin.com/contracts/4.x/api/governance#IGovernorCompatibilityBravo-quorumVotes--)
- [proposalVotes(proposalId)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorCountingSimple-proposalVotes-uint256-)
- [constructor(initialVoteExtension)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-constructor-uint64-)
- [lateQuorumVoteExtension()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-lateQuorumVoteExtension--)
- [setLateQuorumVoteExtension(newVoteExtension)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-setLateQuorumVoteExtension-uint64-)
- [_setLateQuorumVoteExtension(newVoteExtension)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-_setLateQuorumVoteExtension-uint64-)
- [ProposalExtended(proposalId, extendedDeadline)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-ProposalExtended-uint256-uint64-)
- [LateQuorumVoteExtensionSet(oldVoteExtension, newVoteExtension)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorPreventLateQuorum-LateQuorumVoteExtensionSet-uint64-uint64-)
- [constructor(initialVotingDelay, initialVotingPeriod, initialProposalThreshold)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-constructor-uint256-uint256-uint256-)
- [setVotingDelay(newVotingDelay)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-setVotingDelay-uint256-)
- [setVotingPeriod(newVotingPeriod)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-setVotingPeriod-uint256-)
- [setProposalThreshold(newProposalThreshold)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-setProposalThreshold-uint256-)
- [_setVotingDelay(newVotingDelay)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-_setVotingDelay-uint256-)
- [_setVotingPeriod(newVotingPeriod)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-_setVotingPeriod-uint256-)
- [_setProposalThreshold(newProposalThreshold)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-_setProposalThreshold-uint256-)
- [VotingDelaySet(oldVotingDelay, newVotingDelay)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-VotingDelaySet-uint256-uint256-)
- [VotingPeriodSet(oldVotingPeriod, newVotingPeriod)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-VotingPeriodSet-uint256-uint256-)
- [ProposalThresholdSet(oldProposalThreshold, newProposalThreshold)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorSettings-ProposalThresholdSet-uint256-uint256-)
- [GovernorTimelockCompound.__acceptAdmin](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound-__acceptAdmin--)
- [constructor(timelockAddress)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-constructor-contract-TimelockController-)
- [_execute(proposalId, targets, values, calldatas, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockCompound-_execute-uint256-address---uint256---bytes---bytes32-)
- [_cancel(targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-_cancel-address---uint256---bytes---bytes32-)
- [updateTimelock(newTimelock)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-updateTimelock-contract-TimelockController-)
- [TimelockChange(oldTimelock, newTimelock)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-TimelockChange-address-address-)
- [_execute(, targets, values, calldatas, descriptionHash)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorTimelockControl-_execute-uint256-address---uint256---bytes---bytes32-)
- [constructor(tokenAddress)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotes-constructor-contract-IVotes-)
- [_getVotes(account, timepoint, )](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesComp-_getVotes-address-uint256-bytes-)
- [token()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesComp-token-contract-ERC20VotesComp)
- [constructor(token_)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesComp-constructor-contract-ERC20VotesComp-)
- [constructor(quorumNumeratorValue)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-constructor-uint256-)
- [quorumNumerator()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-quorumNumerator--)
- [quorumNumerator(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-quorumNumerator-uint256-)
- [quorumDenominator()](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-quorumDenominator--)
- [quorum(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-quorum-uint256-)
- [updateQuorumNumerator(newQuorumNumerator)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-updateQuorumNumerator-uint256-)
- [_updateQuorumNumerator(newQuorumNumerator)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-_updateQuorumNumerator-uint256-)
- [QuorumNumeratorUpdated(oldQuorumNumerator, newQuorumNumerator)](https://docs.openzeppelin.com/contracts/4.x/api/governance#GovernorVotesQuorumFraction-QuorumNumeratorUpdated-uint256-uint256-)
- [IVotes](https://docs.openzeppelin.com/contracts/4.x/api/governance#ivotes-2)
- [getVotes(account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-getVotes-address-)
- [getPastVotes(account, timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-getPastVotes-address-uint256-)
- [getPastTotalSupply(timepoint)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-getPastTotalSupply-uint256-)
- [delegates(account)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-delegates-address-)
- [delegate(delegatee)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-delegate-address-)
- [delegateBySig(delegatee, nonce, expiry, v, r, s)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-delegateBySig-address-uint256-uint256-uint8-bytes32-bytes32-)
- [DelegateChanged(delegator, fromDelegate, toDelegate)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IVotes-DelegateChanged-address-address-address-)
- [DelegateVotesChanged(delegate, previousBalance, newBalance)](https://docs.openzeppelin.com/contracts/4.x/api/governance#IVotes-DelegateVotesChanged-address-uint256-uint256-)
- [Votes._getVotingUnits](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-_getVotingUnits-address-)
- [ERC721.balanceOf](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC721#ERC721-balanceOf-address-)
- [Votes._transferVotingUnits](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-_transferVotingUnits-address-address-uint256-)
- [ERC721._beforeTokenTransfer](https://docs.openzeppelin.com/contracts/4.x/api/token/ERC721#ERC721-_beforeTokenTransfer-address-address-uint256-uint256-)
- [_getTotalSupply()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-_getTotalSupply--)
- [_delegate(account, delegatee)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-_delegate-address-address-)
- [_useNonce(owner)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-_useNonce-address-)
- [nonces(owner)](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-nonces-address-)
- [DOMAIN_SEPARATOR()](https://docs.openzeppelin.com/contracts/4.x/api/governance#Votes-DOMAIN_SEPARATOR--)
- [IERC5805](https://docs.openzeppelin.com/contracts/4.x/api/governance#ierc5805-1)
