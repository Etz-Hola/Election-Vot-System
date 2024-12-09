// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/VoterRegistration.sol";
import "../src/StateElection.sol";


// Election Factory Contract
contract ElectionFactory {
    struct ElectionInfo {
        string stateName;
        address electionAddress; 
    }

    VoterRegistration public voterRegistry;
    ElectionInfo[] public deployedElections;

    event ElectionDeployed(string stateName, address electionAddress);
    event CandidatesAdded(address electionAddress, string[] candidates);

    constructor() {
        voterRegistry = new VoterRegistration();
    }

    function getVoterRegistryAddress() external view returns (address) {
        return address(voterRegistry);
    }

    function deployElection(string memory _stateName) external returns (address) {
        StateElection newElection = new StateElection(_stateName, address(voterRegistry));
        
        ElectionInfo memory electionInfo = ElectionInfo({
            stateName: _stateName,
            electionAddress: address(newElection)
        });
        
        deployedElections.push(electionInfo);
        
        emit ElectionDeployed(_stateName, address(newElection));
        return address(newElection);
    }

    function addCandidatesToElection(
        address _electionAddress, 
        string[] memory _candidates
    ) external {
        StateElection election = StateElection(_electionAddress);
        
        for (uint256 i = 0; i < _candidates.length; i++) {
            election.addCandidate(_candidates[i]);
        }
        
        emit CandidatesAdded(_electionAddress, _candidates);
    }

    function getAllElections() external view returns (ElectionInfo[] memory) {
        return deployedElections;
    }
}