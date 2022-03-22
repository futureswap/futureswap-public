//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "../voting/Voting.sol";

/// @title The API for Futureswap's governance.
/// This contract enables frontend applications to make a single request to the blockchain and obtain several values at
/// once.
contract VotingApi {
    /// @dev The response to a getPropsals call
    struct GetProposalsResponse {
        Proposal[] proposals;
        uint256 totalProposalCount;
    }

    // See Voting.sol for field descriptions
    struct Proposal {
        uint256 id;
        address proposer;
        uint256 votingEnds;
        uint256 resolveTime;
        uint256 fstSnapshotId;
        uint256 yesVotes;
        uint256 noVotes;
        bool isVoteResolved;
        address[] to;
        bytes[] callData;
        bool didUserVote;
        // FST balance of the queried user at the snapshot of the vote
        uint256 userBalance;
        // Total FST supply at the given snapshot of the vote
        uint256 totalSupply;
        address votingExecutor;
    }

    Voting public voting;
    IVotingToken public votingToken;

    constructor(address _voting, address _votingToken) {
        voting = Voting(nonNull(_voting));
        votingToken = IVotingToken(nonNull(_votingToken));
    }

    /// @notice Returns proposals queried by range and user
    function getProposals(
        uint256 start,
        uint256 end,
        address user
    ) external view returns (GetProposalsResponse memory) {
        if (end > voting.proposalCount()) {
            end = voting.proposalCount();
        }

        require(start <= end, "invalid start / end value");

        // slither-disable-next-line uninitialized-local
        GetProposalsResponse memory response;
        response.totalProposalCount = voting.proposalCount();
        response.proposals = new Proposal[](end - start);

        for (uint256 i = start; i < end; i++) {
            Proposal memory p = response.proposals[i];
            p.id = i;
            // Slither is unhappy about the loop here, but it is caller controlled.
            // slither-disable-next-line calls-loop
            (
                address proposer,
                uint256 votingEnds,
                uint256 resolveTime,
                uint256 fstSnapshotId,
                uint256 yesVotes,
                uint256 noVotes,
                bool isVoteResolved,
                address votingExecutor
            ) = voting.proposals(i);

            p.proposer = proposer;
            p.votingEnds = votingEnds;
            p.resolveTime = resolveTime;
            p.fstSnapshotId = fstSnapshotId;
            p.yesVotes = yesVotes;
            p.noVotes = noVotes;
            p.isVoteResolved = isVoteResolved;
            p.votingExecutor = votingExecutor;

            // Slither is unhappy about the loop here, but it is caller controlled.
            // slither-disable-next-line calls-loop
            p.to = voting.getProposalTo(i);

            // Slither is unhappy about the loop here, but it is caller controlled.
            // slither-disable-next-line calls-loop
            p.callData = voting.getProposalCallData(i);

            // Slither is unhappy about the loop here, but it is caller controlled.
            // slither-disable-next-line calls-loop
            p.didUserVote = voting.didAddressVote(i, user);

            // Slither is unhappy about the loop here, but it is caller controlled.
            // slither-disable-next-line calls-loop
            p.userBalance = votingToken.balanceOfAt(user, fstSnapshotId);
            // Slither is unhappy about the loop here, but it is caller controlled.
            // slither-disable-next-line calls-loop
            p.totalSupply = votingToken.totalSupplyAt(fstSnapshotId);
        }

        return response;
    }

    function nonNull(address _address) internal pure returns (address) {
        require(_address != address(0), "Zero address");
        return _address;
    }
}
