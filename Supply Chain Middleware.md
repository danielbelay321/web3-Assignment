### Overview
InteractionContract is a contract that interacts with RentalNFT and Voting contracts.

### Variables
### RentalNFTAddress: address of the RentalNFT contract
### VotingAddress: address of the Voting contract
### nftToProposal: mapping of NFTs to proposals

### Events
### LinkNFTToProposal: emitted when an NFT is linked to a proposal
### UnlinkNFTFromProposal: emitted when an NFT is unlinked from a proposal

### Constructor
### Initializes the contract with the addresses of the RentalNFT and Voting contracts

### Functions
### linkNFTToProposal: links an NFT to a proposal
### unlinkNFTFromProposal: unlinks an NFT from a proposal
### voteOnProposal: votes on a proposal using an NFT
### getProposalId: returns the proposal ID linked to an NFT

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "node_modules/@openzeppelin/contracts/utils/Context.sol";
import "./RentalNFT.sol";
import "./votingContract.sol";

contract InteractionContract is Ownable {
    address public RentalNFTAddress;
    address public VotingAddress;

    // Mapping to store the relationship between NFTs and proposals
    mapping(uint256 => uint256) public nftToProposal;

    // Event emitted when an NFT is linked to a proposal
    event LinkNFTToProposal(uint256 indexed tokenId, uint256 indexed proposalId);

    // Event emitted when an NFT is unlinked from a proposal
    event UnlinkNFTFromProposal(uint256 indexed tokenId, uint256 indexed proposalId);

    constructor(address initialOwner) Ownable(initialOwner) {
        RentalNFTAddress = address(new RentalNFT("RentalNFT", "RNFT", address(this)));
        VotingAddress = address(new Voting());
    }

    // Function to link an NFT to a proposal
    function linkNFTToProposal(uint256 tokenId, uint256 proposalId) public onlyOwner {
        require(RentalNFT(RentalNFTAddress).ownerOf(tokenId) == address(this), "Only the owner of the NFT can link it to a proposal");
        require(Voting(VotingAddress).isVoterRegistered(msg.sender), "Only registered voters can link NFTs to proposals");
        nftToProposal[tokenId] = proposalId;
        emit LinkNFTToProposal(tokenId, proposalId);
    }

    // Function to unlink an NFT from a proposal
    function unlinkNFTFromProposal(uint256 tokenId) public onlyOwner {
        require(RentalNFT(RentalNFTAddress).ownerOf(tokenId) == address(this), "Only the owner of the NFT can unlink it from a proposal");
        uint256 proposalId = nftToProposal[tokenId];
        delete nftToProposal[tokenId];
        emit UnlinkNFTFromProposal(tokenId, proposalId);
    }

    // Function to vote on a proposal using an NFT
    function voteOnProposal(uint256 tokenId) public {
        require(RentalNFT(RentalNFTAddress).userOf(tokenId) == msg.sender, "Only the user of the NFT can vote on a proposal");
        uint256 proposalId = nftToProposal[tokenId];
        Voting(VotingAddress).vote(proposalId);
    }

    // Function to get the proposal ID linked to an NFT
    function getProposalId(uint256 tokenId) public view returns (uint256) {
        return nftToProposal[tokenId];
    }
}



```
