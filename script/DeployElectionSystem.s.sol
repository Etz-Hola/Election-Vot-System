// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/VoterRegistration.sol";
import "../src/ElectionFactory.sol";
import "../src/StateElection.sol";

contract DeployNigeriaElectionSystem is Script {
    function run() external returns (ElectionFactory, VoterRegistration) {
        // Start broadcast with the deployer's private key
        vm.startBroadcast();

        // Deploy the Election Factory (which also deploys Voter Registration)
        ElectionFactory electionFactory = new ElectionFactory();
        
        // Get the Voter Registration address from the factory
        VoterRegistration voterRegistry = VoterRegistration(electionFactory.getVoterRegistryAddress());

        vm.stopBroadcast();

        // Log addresses for verification
        console.log("Election Factory deployed at:", address(electionFactory));
        console.log("Voter Registration deployed at:", address(voterRegistry));

        return (electionFactory, voterRegistry);
    }
}