1. Voting Contract

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for Voting functionality (used for potential future upgrades)
interface IVoting {
    struct Voter {
        bool registered; // Tracks if voter is registered
        bool voted;       // Indicates if voter has already voted
        uint256 vote;     // Stores the voter's vote (can be extended for multiple choices)
        uint256 weight;   // Optional: weight associated with the voter's vote (e.g., for tokenized voting)
        address delegate; // Address to which vote is delegated (if any)
    }

    struct Proposal {
        string name;
        uint256 voteCount; // Total number of votes for this proposal
    }

    function registerVoter(address voter) external;

    function createProposal(string memory name) external;

    function vote(uint256 proposalId) external;

    function delegate(address to) external;

    function winningProposal() external view returns (uint256 winningProposalId);

    function getProposalName(uint256 proposalId) external view returns (string memory);

    function getProposalVoteCount(uint256 proposalId) external view returns (uint256);

    function isVoterRegistered(address voter) external view returns (bool);
}

contract Voting is IVoting {

    // Mapping to store voter information
    mapping(address => Voter) public voters;

    // List of proposals
    Proposal[] public proposals;

    // Address of the contract administrator
    address public admin;

    // Modifier to restrict functions to admin only
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this operation");
        _;
    }

    // Constructor (sets the admin address)
    constructor() {
        admin = msg.sender;
    }

    // Function to register a voter (only admin)
    function registerVoter(address voter) public override onlyAdmin {
        require(voters[voter].registered == false, "Voter already registered");
        voters[voter] = Voter(true, false, 0, 1, address(0)); // Set initial weight to 1 (can be modified)
    }

    // Function to create a proposal (only admin)
    function createProposal(string memory name) public override onlyAdmin {
        proposals.push(Proposal(name, 0));
    }

    // Function to vote on a proposal
    function vote(uint256 proposalId) public override {
        require(!voters[msg.sender].voted, "Already voted");
        require(proposalId < proposals.length, "Invalid proposal ID");

        // Check for vote delegation
        if (voters[msg.sender].delegate != address(0)) {
            voters[voters[msg.sender].delegate].voted = true; // Mark delegate as voted
            voters[voters[msg.sender].delegate].vote++;
        } else {
            voters[msg.sender].voted = true;
            voters[msg.sender].vote++;
        }
        proposals[proposalId].voteCount++;
    }

    // Function to delegate vote to another voter
    function delegate(address to) public override {
        require(to != msg.sender, "Cannot delegate to yourself");
        require(voters[to].registered == true, "Delegate not registered");
        voters[msg.sender].delegate = to;
    }

    // Function to tally votes and get winning proposal ID (view function for access without modifying state)
    function winningProposal() public view override returns (uint256 winningProposalId) {
        uint256 winningVoteCount = 0;
        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalId = i;
            }
        }
        return winningProposalId;
    }

    // Getter function to access proposal name
    function getProposalName(uint256 proposalId) public view override returns (string memory) {
        require(proposalId < proposals.length, "Invalid proposal ID");
        return proposals[proposalId].name;
    }

    // Getter function to access proposal vote count
    function getProposalVoteCount(uint256 proposalId) public view override returns (uint256) {
        require(proposalId < proposals.length, "Invalid proposal ID");
        return proposals[proposalId].voteCount;
    }

    // Getter function to check if a voter is registered
    function isVoterRegistered(address voter) public view override returns (bool) {
        return voters[voter].registered;
    }
}



votingContract.t.sol
------------------------------------

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
        address voter = address(0xdef);
        voting.registerVoter(voter);
        voting.createProposal("Proposal C");
        voting.createProposal("Proposal D");
        
        voting.vote(0); // Voter votes for proposal C
        voting.vote(0); // Voter votes again for proposal C
        
        // Winning proposal should be proposal C
        assertEq(voting.winningProposal(), 0);
    }
}


----------------------





```


