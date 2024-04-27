## RentalNFTTest Contract Overview

This Solidity code represents a test suite for the `RentalNFT` contract, which implements the ERC-4907 standard for rental NFTs. The test suite is written in the Forge testing framework and aims to ensure the correct functionality of the `RentalNFT` contract.

### Key Functions:

* **setUp()**: Sets up the test environment.
* **testSetUserWithFutureExpiration()**: Tests setting a user with a future expiration date.
* **testUpdateExpiration()**: Tests updating the expiration date of a user.
* **testSetUserWithPastExpiration()**: Tests setting a user with a past expiration date.
* **testSetUserWithInvalidExpiration()**: Tests setting a user with an invalid expiration date.
* **testClearExpired()**: Tests clearing an expired user.

### Additional Notes:

* The code uses the `vm` object from the Forge testing framework to manipulate the blockchain state.
* The `expectRevert` function is used to verify that a transaction reverts with a specific error message.
* The `assertEq` function is used to verify that two values are equal.
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
