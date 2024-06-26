## Specifies functions for voter registration, proposal creation, voting, elegation, and retrieving the winning proposal ID (solidity
function registerVoter(address voter) external;
function createProposal(string memory name) external;
function vote(uint256 proposalId) external;
function delegate(address to) external;
function winningProposal() external view returns (uint256 winningProposalId);
)

## Contract (Voting):

* Inherits from the `IVoting` interface, implementing its functions.
* Uses mappings to store voter information (`voters`) and a list of proposals (`proposals`).
* Defines an `admin` address to control privileged actions (olidity
mapping(address => Voter) public voters;
Proposal[] public proposals;
address public admin;
).

## Functions:

* registerVoter(address voter)` (admin only): Registers a new voter, setting initial values (solidity
function registerVoter(address voter) public override onlyAdmin { ... }
).
* createProposal(string memory name) (admin only): Creates a new proposal with the specified name (solidity
function createProposal(string memory name) public override onlyAdmin { ... }
).
* vote(uint256 proposalId)`: Allows a voter to cast a vote for a proposal (checks for eligibility and delegation) (solidity
function vote(uint256 proposalId) public override { ... }
).
* delegate(address to)`: Enables a voter to delegate their vote to another registered voter (solidity
function delegate(address to) public override { ... }
).
* winningProposal() view`: Publicly retrieves the ID of the proposal with the most votes (doesn't modify contract state) (```solidity
function winningProposal() public view override returns (uint256 winningProposalId) { ... }
).

### Additional Notes:

* The code utilizes modifiers (`onlyAdmin`) to restrict specific actions to the contract administrator.
* The `vote` function handles both direct voting and delegated voting scenarios.
* The `winningProposal` function iterates through all proposals to find the one with the highest vote count.

Overall, this contract provides a foundational framework for a decentralized voting system on the Ethereum blockchain. It offers functionalities for user registration, proposal creation, voting, delegation, and determining the winning proposal.



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
import {Voting}  from "../src/votingContract.sol";

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
}



----------------------





```


