## `VotingApi`






### `constructor(address _voting, address _votingToken)` (public)





### `getProposals(uint256 start, uint256 end, address user) → struct VotingApi.GetProposalsResponse` (external)

Returns proposals queried by range and user



### `nonNull(address _address) → address` (internal)







### `GetProposalsResponse`


struct VotingApi.Proposal[] proposals


uint256 totalProposalCount


### `Proposal`


uint256 id


address proposer


uint256 votingEnds


uint256 resolveTime


uint256 fstSnapshotId


uint256 yesVotes


uint256 noVotes


bool isVoteResolved


address[] to


bytes[] callData


bool didUserVote


uint256 userBalance


uint256 totalSupply


address votingExecutor



