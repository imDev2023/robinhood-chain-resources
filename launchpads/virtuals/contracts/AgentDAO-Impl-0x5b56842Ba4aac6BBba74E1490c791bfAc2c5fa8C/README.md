# AgentDAO-Impl - 0x5b56842Ba4aac6BBba74E1490c791bfAc2c5fa8C

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x5b56842Ba4aac6BBba74E1490c791bfAc2c5fa8C
Role: AgentDAO-Impl.
Contract name: AgentDAO.
Verified: True (verified at 2026-07-02T06:59:55.305378Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/virtualPersona/AgentDAO.sol.
Source files written: 40 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0xcd708d25d6772e80a2098b4e6893cfb8f98b5e340359bbd0f4f54c09aa09657f.
Proxy type: None; implementations: [].

Implementation cloned for every graduated agent's governor.

## Constructor arguments

None decoded.

## Events

- `EIP712DomainChanged()`
- `Initialized(uint64)`
- `ProposalCanceled(uint256)`
- `ProposalCreated(uint256,address,address[],uint256[],string[],bytes[],uint256,uint256,string)`
- `ProposalExecuted(uint256)`
- `ProposalQueued(uint256,uint256)`
- `ProposalThresholdSet(uint256,uint256)`
- `QuorumNumeratorUpdated(uint256,uint256)`
- `ValidatorEloRating(uint256,address,uint256,uint8[])`
- `VoteCast(address,uint256,uint8,uint256,string)`
- `VoteCastWithParams(address,uint256,uint8,uint256,string,bytes)`
- `VotingDelaySet(uint256,uint256)`
- `VotingPeriodSet(uint256,uint256)`

## State-changing functions

- `cancel(address[],uint256[],bytes[],bytes32)`
- `cancel(uint256)`
- `castVote(uint256,uint8)`
- `castVoteBySig(uint256,uint8,address,bytes)`
- `castVoteWithReason(uint256,uint8,string)`
- `castVoteWithReasonAndParams(uint256,uint8,string,bytes)`
- `castVoteWithReasonAndParamsBySig(uint256,uint8,address,string,bytes,bytes)`
- `execute(address[],uint256[],bytes[],bytes32)`
- `execute(uint256)`
- `initialize(string,address,address,uint256,uint32)`
- `onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)`
- `onERC1155Received(address,address,uint256,uint256,bytes)`
- `onERC721Received(address,address,uint256,bytes)`
- `propose(address[],uint256[],bytes[],string)`
- `queue(address[],uint256[],bytes[],bytes32)`
- `queue(uint256)`
- `relay(address,uint256,bytes)`
- `setProposalThreshold(uint256)`
- `setVotingDelay(uint48)`
- `setVotingPeriod(uint32)`
- `updateQuorumNumerator(uint256)`

## View functions

- `BALLOT_TYPEHASH()`
- `CLOCK_MODE()`
- `COUNTING_MODE()`
- `EXTENDED_BALLOT_TYPEHASH()`
- `clock()`
- `eip712Domain()`
- `getMaturity(uint256)`
- `getPastScore(address,uint256)`
- `getVotes(address,uint256)`
- `getVotesWithParams(address,uint256,bytes)`
- `hasVoted(uint256,address)`
- `hashProposal(address[],uint256[],bytes[],bytes32)`
- `name()`
- `nonces(address)`
- `proposalCount()`
- `proposalDeadline(uint256)`
- `proposalDetails(uint256)`
- `proposalDetailsAt(uint256)`
- `proposalEta(uint256)`
- `proposalNeedsQueuing(uint256)`
- `proposalProposer(uint256)`
- `proposalSnapshot(uint256)`
- `proposalThreshold()`
- `proposalVotes(uint256)`
- `quorum(uint256)`
- `quorumDenominator()`
- `quorumNumerator()`
- `quorumNumerator(uint256)`
- `scoreOf(address)`
- `state(uint256)`
- `supportsInterface(bytes4)`
- `token()`
- `totalScore()`
- `version()`
- `votingDelay()`
- `votingPeriod()`
