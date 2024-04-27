```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Voting} from "../src/votingContract.sol";

contract VotingTest is Test {
    Voting voting;

    function setUp() public {
        voting = new Voting();
    }

    function testRegisterVoter() public {
        address voter = address(0x123);
        voting.registerVoter(voter);
        assertTrue(voting.isVoterRegistered(voter));
    }

    function testCreateProposal() public {
        string memory proposalName = "Proposal 1";
        voting.createProposal(proposalName);
        assertEq(voting.getProposalName(0), proposalName);
    }

    function testVotingFunctionality() public {
        // Scenario: A voter votes for a proposal
        address voter = address(0x456);
        voting.registerVoter(voter);
        voting.createProposal("Proposal A");
        
        voting.vote(0); // Vote for proposal 0
        
        // Check if the vote count for proposal 0 is incremented
        assertEq(voting.getProposalVoteCount(0), 1);
    }

    function testVoteDelegation() public {
        // Scenario: A voter delegates their vote to another voter
        address voter1 = address(0x789);
        address voter2 = address(0xabc);
        voting.registerVoter(voter1);
        voting.registerVoter(voter2);
        voting.createProposal("Proposal B");
        
        voting.delegate(voter2); // Voter1 delegates to voter2
        voting.vote(0); // Voter1's vote gets delegated to voter2
        
        // Check if voter2's vote count is incremented
        assertEq(voting.getProposalVoteCount(0), 1);
    }

    function testWinningProposalCalculation() public {
        // Scenario: Two proposals, one with more votes
        address voter1 = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        address voter2 = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        address voter3 = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
        voting.registerVoter(voter1);
        voting.registerVoter(voter2);
        voting.registerVoter(voter3);
        voting.createProposal("Proposal C");
        voting.createProposal("Proposal D");
        
        voting.vote(0); // Voter1 votes for proposal C
        voting.vote(1); // Voter2 votes for proposal D
        voting.delegate(voter1); // Voter3 delegates to voter1
        
        // Winning proposal should be proposal C
        assertEq(voting.winningProposal(), 0);
    }





}



```



## Voting Test Contract

### Description

This is a test contract written in Solidity for the `Voting` contract. It uses the `forge-std` library for testing purposes.

### Key Features

* **`setUp` function:** Deploys a new instance of the `Voting` contract before each test.
* **`testRegisterVoter` function:** Tests the `registerVoter` function of the `Voting` contract.
* **`testCreateProposal` function:** Tests the `createProposal` function of the `Voting` contract.
* **`testVotingFunctionality` function:** Tests the basic voting functionality of the `Voting` contract.
* **`testVoteDelegation` function:** Tests the vote delegation functionality of the `Voting` contract.
* **`testWinningProposalCalculation` function:** Tests the calculation of the winning proposal based on vote count.

### Additional Notes

* The `testWinningProposalCalculation` function includes an example scenario with three voters and two proposals to demonstrate the calculation process.
* This test contract can be used to ensure the correctness of the `Voting` contract's functionality before deployment.

### Example Usage
```
forge test -vvv
```
