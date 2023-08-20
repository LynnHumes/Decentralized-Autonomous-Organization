// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
#rg
contract DAO {
    address public owner;
    uint256 public proposalCount;
    uint256 public votingPeriod;
    uint256 public minVotesRequired;

    enum ProposalStatus { Pending, Approved, Rejected }

    struct Proposal {
        uint256 proposalId;
        address proposer;
        string proposalDescription;
        uint256 creationTime;
        uint256 votesFor;
        uint256 votesAgainst;
        ProposalStatus status;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 proposalId, address proposer, string proposalDescription);
    event Voted(uint256 proposalId, address voter, bool inFavor);
    event ProposalResult(uint256 proposalId, ProposalStatus status);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    constructor(uint256 _votingPeriod, uint256 _minVotesRequired) {
        owner = msg.sender;
        votingPeriod = _votingPeriod;
        minVotesRequired = _minVotesRequired;
    }

    function createProposal(string memory _proposalDescription) public {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            proposalId: proposalCount,
            proposer: msg.sender,
            proposalDescription: _proposalDescription,
            creationTime: block.timestamp,
            votesFor: 0,
            votesAgainst: 0,
            status: ProposalStatus.Pending
        });
        emit ProposalCreated(proposalCount, msg.sender, _proposalDescription);
    }

    function vote(uint256 _proposalId, bool _inFavor) public {
        require(proposals[_proposalId].status == ProposalStatus.Pending, "Proposal is not pending");
        require(!proposals[_proposalId].hasVoted[msg.sender], "You have already voted");

        proposals[_proposalId].hasVoted[msg.sender] = true;

        if (_inFavor) {
            proposals[_proposalId].votesFor++;
        } else {
            proposals[_proposalId].votesAgainst++;
        }

        emit Voted(_proposalId, msg.sender, _inFavor);

        if (block.timestamp >= proposals[_proposalId].creationTime + votingPeriod) {
            _finalizeProposal(_proposalId);
        }
    }

    function _finalizeProposal(uint256 _proposalId) private {
        Proposal storage proposal = proposals[_proposalId];

        if (proposal.votesFor >= minVotesRequired) {
            proposal.status = ProposalStatus.Approved;
            // Implement fund management logic based on approved proposals
            // (e.g., transfer funds or execute other actions)
        } else {
            proposal.status = ProposalStatus.Rejected;
        }

        emit ProposalResult(_proposalId, proposal.status);
    }

    function setVotingPeriod(uint256 _votingPeriod) public onlyOwner {
        votingPeriod = _votingPeriod;
    }

    function setMinVotesRequired(uint256 _minVotesRequired) public onlyOwner {
        minVotesRequired = _minVotesRequired;
    }
}

