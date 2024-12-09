// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/VoterRegistration.sol";


// State-Specific Election Contract
contract StateElection {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    address public factory;
    VoterRegistration public voterRegistry;
    Candidate[] public candidates;
    mapping(address => bool) public hasVoted;
    mapping(address => address) public voteDelegations;
    mapping(address => uint256) public voteWeights;
    
    bool public electionClosed;
    string public stateName;

    event CandidateAdded(string name);
    event VoteDelegated(address from, address to);
    event Voted(address voter, uint256 candidateIndex);
    event ElectionEnded(string winnerName);

    constructor(string memory _stateName, address _voterRegistryAddress) {
        factory = msg.sender;
        stateName = _stateName;
        voterRegistry = VoterRegistration(_voterRegistryAddress);
    }

    modifier onlyFactory() {
        require(msg.sender == factory, "Only factory can perform this action");
        _;
    }

    modifier onlyRegisteredVoter() {
        require(voterRegistry.isVoterRegistered(msg.sender), "Voter not registered");
        _;
    }

    modifier electionNotClosed() {
        require(!electionClosed, "Election is closed");
        _;
    }

    function addCandidate(string memory _name) external onlyFactory {
        candidates.push(Candidate(_name, 0));
        emit CandidateAdded(_name);
    }

    function delegateVote(address _to) external onlyRegisteredVoter electionNotClosed {
        require(_to != msg.sender, "Cannot delegate to self");
        require(voteDelegations[msg.sender] == address(0), "Vote already delegated");
        
        address currentDelegate = _to;
        while (currentDelegate != address(0)) {
            require(currentDelegate != msg.sender, "Cannot create circular delegation");
            currentDelegate = voteDelegations[currentDelegate];
        }

        voteDelegations[msg.sender] = _to;
        voteWeights[_to] += 1;

        emit VoteDelegated(msg.sender, _to);
    }

    function vote(uint256 _candidateIndex) external onlyRegisteredVoter electionNotClosed {
        require(!hasVoted[msg.sender], "Voter has already voted");
        require(_candidateIndex < candidates.length, "Invalid candidate index");

        // Determine actual voter (in case of delegation)
        address actualVoter = msg.sender;
        uint256 voterWeight = 1;

        if (voteDelegations[msg.sender] != address(0)) {
            actualVoter = voteDelegations[msg.sender];
            voterWeight = voteWeights[actualVoter];
        }

        candidates[_candidateIndex].voteCount += voterWeight;
        hasVoted[msg.sender] = true;

        emit Voted(actualVoter, _candidateIndex);
    }

    function endElection() external onlyFactory {
        electionClosed = true;
    }

    function getWinner() external view returns (string memory) {
        require(electionClosed, "Election not yet closed");
        
        uint256 winningVoteCount = 0;
        uint256 winningCandidateIndex = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateIndex = i;
            }
        }

        return candidates[winningCandidateIndex].name;
    }

    function getCandidatesCount() external view returns (uint256) {
        return candidates.length;
    }
}
