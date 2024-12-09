// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/VoterRegistration.sol";
import "../src/ElectionFactory.sol";
import "../src/StateElection.sol";

contract ElectionTest is Test {
    ElectionFactory public electionFactory;
    VoterRegistration public voterRegistry;
    StateElection public stateElection;

    // Test accounts
    address public electoralBoard;
    address public voter1;
    address public voter2;
    address public voter3;

    // function setUp() public {
    //     // Set up test accounts
    //     electoralBoard = address(this);
    //     voter1 = address(0x1);
    //     voter2 = address(0x2);
    //     voter3 = address(0x3);

    //     // Deploy the Election Factory (which also deploys Voter Registration)
    //     electionFactory = new ElectionFactory();
    //     voterRegistry = VoterRegistration(electionFactory.getVoterRegistryAddress());

    //     // Deploy a state election
    //     address electionAddress = electionFactory.deployElection("");
    //     stateElection = StateElection(electionAddress);
    // }



    function setUp() public {
    electoralBoard = address(this);

    // Deploy the Election Factory (which also deploys Voter Registration)
    electionFactory = new ElectionFactory();
    voterRegistry = VoterRegistration(electionFactory.getVoterRegistryAddress());
}









    // function testVoterRegistration() public {
    //     // Register voters
    //     voterRegistry.registerVoter(voter1);
    //     voterRegistry.registerVoter(voter2);

    //     // Check registration status
    //     assertTrue(voterRegistry.isVoterRegistered(voter1), "Voter1 should be registered");
    //     assertTrue(voterRegistry.isVoterRegistered(voter2), "Voter2 should be registered");
    //     assertFalse(voterRegistry.isVoterRegistered(voter3), "Voter3 should not be registered");
    // }

    function testVoterRegistration() public {
    // Prank as the electoral board
    vm.prank(electoralBoard);
    voterRegistry.registerVoter(voter1);
    vm.prank(electoralBoard);
    voterRegistry.registerVoter(voter2);

    // Check registration status
    assertTrue(voterRegistry.isVoterRegistered(voter1), "Voter1 should be registered");
    assertTrue(voterRegistry.isVoterRegistered(voter2), "Voter2 should be registered");
    assertFalse(voterRegistry.isVoterRegistered(voter3), "Voter3 should not be registered");
}


    function testCandidateAddition() public {
        // Add candidates to the election
        string[] memory candidates = new string[](3);
        candidates[0] = "Candidate A";
        candidates[1] = "Candidate B";
        candidates[2] = "Candidate C";

        electionFactory.addCandidatesToElection(address(stateElection), candidates);

        // Verify candidate count
        assertEq(stateElection.getCandidatesCount(), 3, "Should have 3 candidates");
    }

    // function testVotingAndDelegation() public {
    //     // Register voters
    //     voterRegistry.registerVoter(voter1);
    //     voterRegistry.registerVoter(voter2);
    //     voterRegistry.registerVoter(voter3);

    //     // Add candidates
    //     string[] memory candidates = new string[](2);
    //     candidates[0] = "Candidate A";
    //     candidates[1] = "Candidate B";
    //     electionFactory.addCandidatesToElection(address(stateElection), candidates);

    //     // Simulate voter1 delegating to voter2
    //     vm.prank(voter1);
    //     stateElection.delegateVote(voter2);

    //     // Simulate voter2 voting
    //     vm.prank(voter2);
    //     stateElection.vote(0);  // Vote for first candidate

    //     // End the election
    //     stateElection.endElection();

    //     // Get the winner
    //     string memory winner = stateElection.getWinner();
    //     assertEq(winner, "Candidate A", "Candidate A should win");
    // }


    function testVotingAndDelegation() public {
    // Register voters
    vm.prank(electoralBoard);
    voterRegistry.registerVoter(voter1);
    vm.prank(electoralBoard);
    voterRegistry.registerVoter(voter2);
    vm.prank(electoralBoard);
    voterRegistry.registerVoter(voter3);

    // Add candidates
    string;
    candidates[0] = "Candidate A";
    candidates[1] = "Candidate B";
    electionFactory.addCandidatesToElection(address(stateElection), candidates);

    // Simulate voter1 delegating to voter2
    vm.prank(voter1);
    stateElection.delegateVote(voter2);

    // Simulate voter2 voting
    vm.prank(voter2);
    stateElection.vote(0);  // Vote for first candidate

    // End the election
    stateElection.endElection();

    // Get the winner
    string memory winner = stateElection.getWinner();
    assertEq(winner, "Candidate A", "Candidate A should win");
}



    

    // function testElectionDeployment() public {
    //     // Deploy multiple state elections
    //     address lagosElection = electionFactory.deployElection("Lagos");
    //     address abujaElection = electionFactory.deployElection("Abuja");

    //     // Verify elections are tracked
    //     ElectionFactory.ElectionInfo[] memory elections = electionFactory.getAllElections();
        
    //     assertEq(elections.length, 2, "Should have 2 deployed elections");
    //     assertEq(elections[0].stateName, "Lagos", "First election should be Lagos");
    //     assertEq(elections[1].stateName, "Abuja", "Second election should be Abuja");
    // }

    function testElectionDeployment() public {
    // Deploy multiple state elections
    electionFactory.deployElection("Lagos");
    electionFactory.deployElection("Abuja");

    // Verify elections are tracked
    ElectionFactory.ElectionInfo[] memory elections = electionFactory.getAllElections();

    assertEq(elections.length, 2, "Should have 2 deployed elections");
    assertEq(elections[0].stateName, "Lagos", "First election should be Lagos");
    assertEq(elections[1].stateName, "Abuja", "Second election should be Abuja");
}


    function testVotingRestrictions() public {
        // Register voter
        voterRegistry.registerVoter(voter1);

        // Add candidates
        string[] memory candidates = new string[](2);
        candidates[0] = "Candidate A";
        candidates[1] = "Candidate B";
        electionFactory.addCandidatesToElection(address(stateElection), candidates);

        // Attempt voting
        vm.prank(voter1);
        stateElection.vote(0);

        // Try voting again (should revert)
        vm.expectRevert("Voter has already voted");
        vm.prank(voter1);
        stateElection.vote(0);
    }

    // Test negative scenarios
    function testUnregisteredVoterCantVote() public {
        // Add candidates
        string[] memory candidates = new string[](2);
        candidates[0] = "Candidate A";
        candidates[1] = "Candidate B";
        electionFactory.addCandidatesToElection(address(stateElection), candidates);

        // Attempt to vote with unregistered voter
        vm.expectRevert("Voter not registered");
        vm.prank(voter1);
        stateElection.vote(0);
    }
}