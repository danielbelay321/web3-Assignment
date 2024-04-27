```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "node_modules/@openzeppelin/contracts/utils/Context.sol";
import "../src/RentalNFT.sol";

contract RentalNFTTest is Test {
    RentalNFT private rentalNFT;
    address private owner;
    address private user;
    uint256 private tokenId;

    function setUp() public {
        // Set the owner and user addresses
        owner = address(1);
        user = address(2);
        tokenId = 1;

        // Deploy the contract with the correct owner
        rentalNFT = new RentalNFT("RentalNFT", "RNFT", owner);

        // Mint the token before setting the user
        vm.prank(owner); // Set the msg.sender to the owner of the contract
        rentalNFT.mint(owner, tokenId);
    }



    function testSetUserWithFutureExpiration() public {
    uint256 expires = block.timestamp + 1 hours;
    vm.prank(owner); // Set the msg.sender to the owner of the contract
    rentalNFT.setUser(tokenId, user, expires);
    assertEq(rentalNFT.userOf(tokenId), user);
    assertEq(rentalNFT.userExpires(tokenId), expires);
    }

    function testUpdateExpiration() public {
        uint256 expires = block.timestamp + 1 hours;
        vm.prank(owner); // Set the msg.sender to the owner of the contract
        rentalNFT.setUser(tokenId, user, expires);
        uint256 newExpires = block.timestamp + 2 hours;
        vm.prank(owner); // Set the msg.sender to the owner of the contract
        rentalNFT.setUser(tokenId, user, newExpires);
        assertEq(rentalNFT.userOf(tokenId), user);
        assertEq(rentalNFT.userExpires(tokenId), newExpires);
    }

    function testSetUserWithPastExpiration() public {
        vm.warp(block.timestamp + 1 hours); // Move the block timestamp to at least 1 hour
        uint256 expires = block.timestamp - 1 hours;
        vm.prank(owner); 
        vm.expectRevert("Expiration date must be in the future");
        rentalNFT.setUser(tokenId, user, expires);
    }

    function testSetUserWithInvalidExpiration() public {
        uint256 expires = 0;
        vm.prank(owner); // Set the msg.sender to the owner of the contract
        vm.expectRevert("Expiration date must be in the future");
        rentalNFT.setUser(tokenId, user, expires);
    }

    function testClearExpired() public {
        uint256 expires = block.timestamp + 1 hours;
        vm.prank(owner); 
        rentalNFT.setUser(tokenId, user, expires);
        vm.warp(expires); // Move the block timestamp to the expiration time
        vm.prank(owner); 
        rentalNFT.clearExpired(tokenId);
        assertEq(rentalNFT.userOf(tokenId), address(0));
        assertEq(rentalNFT.userExpires(tokenId), 0);
    }

}




```
