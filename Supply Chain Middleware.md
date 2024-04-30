# SupplyChainRentalNFT Contract
=============================

## Overview
This contract is a decentralized application (dApp) that enables the creation, voting, and execution of proposals for renting NFTs. It interacts with two other contracts: `RentalNFT` and `Voting`.

## Variables and Mappings
### RentalInfo Struct
```solidity
struct RentalInfo {
  uint256 price;
  uint256 duration;
  address businessUnit;
}

```
pragma solidity ^0.8.24;

import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "node_modules/@openzeppelin/contracts/utils/Context.sol";
import "./RentalNFT.sol";
import "./votingContract.sol";

contract SupplyChainRentalNFT {
    // Define the RentalInfo struct
    struct RentalInfo {
        uint256 price;
        uint256 duration;
        address businessUnit;
    }

    // Mapping of NFT IDs to their corresponding rental information
    mapping(uint256 => RentalInfo) public rentalInfos;

    // Mapping of business units to their corresponding prices
    mapping(address => uint256) public businessUnitPrices;

    // Array of current supply order
    address[] public currentSupplyOrder;

    // Mapping of addresses to their circulating NFTs
    mapping(address => address[]) public CirculatingNFTs;

    // Proposal struct
    struct Proposal {
        uint256 nftId;
        uint256 price;
        uint256 duration;
        address businessUnit;
        uint256 votes;
    }

    // Mapping of proposal IDs to their corresponding proposals
    mapping(uint256 => Proposal) public proposals;

    // Next proposal ID
    uint256 public nextProposalId;

    // Rental NFT contract
    RentalNFT public rentalNFT;

    // Voting contract
    Voting public voting;

    // Event emitted when a proposal is created
    event ProposalCreated(uint256 proposalId, uint256 nftId, uint256 price, uint256 duration, address businessUnit);

    // Event emitted when a proposal is voted
    event ProposalVoted(uint256 proposalId, address voter);

    // Event emitted when a rental is started
    event RentalStarted(uint256 nftId, uint256 price, uint256 duration, address businessUnit);

    // Event emitted when a rental is ended
    event RentalEnded(uint256 nftId, address businessUnit);

    // Event emitted when a business unit price is updated
    event BusinessUnitPriceUpdated(address businessUnit, uint256 price);

    /**
     * @dev Initializes the contract with the Rental NFT and Voting contracts
     * @param _rentalNFT The Rental NFT contract
     * @param _voting The Voting contract
     */
    constructor(RentalNFT _rentalNFT, Voting _voting) {
        rentalNFT = _rentalNFT;
        voting = _voting;
    }

    /**
     * @dev Creates a new proposal
     * @param _nftId The ID of the NFT
     * @param _price The proposed price
     * @param _duration The proposed duration
     * @param _businessUnit The business unit proposing the rental
     */
    function createProposal(uint256 _nftId, uint256 _price, uint256 _duration, address _businessUnit) external {
        Proposal memory proposal = Proposal(_nftId, _price, _duration, _businessUnit, 0);
        proposals[nextProposalId] = proposal;
        emit ProposalCreated(nextProposalId, _nftId, _price, _duration, _businessUnit);
        nextProposalId++;
    }

    /**
     * @dev Votes on a proposal
     * @param _proposalId The ID of the proposal
     */
    function vote(uint256 _proposalId) external {
        Proposal storage proposal = proposals[_proposalId];
        voting.vote(_proposalId);
        proposal.votes++;
        emit ProposalVoted(_proposalId, msg.sender);
    }

    /**
     * @dev Executes a proposal
     * @param _proposalId The ID of the proposal
     */
    function executeProposal(uint256 _proposalId) external {
        Proposal storage proposal = proposals[_proposalId];
        if (proposal.votes > 0) {
            rentalInfos[proposal.nftId] = RentalInfo(proposal.price, proposal.duration, proposal.businessUnit);
            emit RentalStarted(proposal.nftId, proposal.price, proposal.duration, proposal.businessUnit);
        }
    }

    /**
     * @dev Ends a rental
     * @param _nftId The ID of the NFT
     */
    function endRental(uint256 _nftId) external {
        RentalInfo storage rentalInfo = rentalInfos[_nftId];
        rentalNFT.clearExpired(_nftId);
        emit RentalEnded(_nftId, rentalInfo.businessUnit);
    }

    /**
     * @dev Updates the price of a business unit
     * @param _businessUnit The business unit
     * @param _price The new price
     */
    function setBusinessUnitPrice(address _businessUnit, uint256 _price) external {
        businessUnitPrices[_businessUnit] = _price;
        emit BusinessUnitPriceUpdated(_businessUnit, _price);
    }

    /**
     * @dev Specifies the supply chain
     * @param _supplyChain The supply chain
     */
    function specifySupplyChain(address[] memory _supplyChain) external {
        currentSupplyOrder = _supplyChain;
    }
}



```
