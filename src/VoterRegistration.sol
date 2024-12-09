// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Voter Registration Contract
contract VoterRegistration {
    address public electoralBoard;
    mapping(address => bool) private registeredVoters;

    event VoterRegistered(address voter);
    event VoterDeregistered(address voter);

    constructor() {
        electoralBoard = msg.sender;
    }

    modifier onlyElectoralBoard() {
        require(msg.sender == electoralBoard, "Only electoral board can perform this action");
        _;
    }

    function registerVoter(address _voter) external onlyElectoralBoard {
        require(!registeredVoters[_voter], "Voter already registered");
        registeredVoters[_voter] = true;
        emit VoterRegistered(_voter);
    }

    function deregisterVoter(address _voter) external onlyElectoralBoard {
        require(registeredVoters[_voter], "Voter not registered");
        registeredVoters[_voter] = false;
        emit VoterDeregistered(_voter);
    }

    function isVoterRegistered(address _voter) external view returns (bool) {
        return registeredVoters[_voter];
    }
}
