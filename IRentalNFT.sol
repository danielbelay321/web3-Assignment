```

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "node_modules/@openzeppelin/contracts/utils/Context.sol";


contract RentalNFT is ERC721, Ownable {

  // Moved variable declarations outside the constructor
  mapping(uint256 => address) private _users;
  mapping(uint256 => uint256) private _userExpires;

  event UpdateUser(uint256 indexed tokenId, address indexed user, uint256 expires);

  // Provide arguments to base constructors (your NFT name and symbol)
  constructor(string memory name_, string memory symbol_, address initialOwner) ERC721(name_, symbol_) Ownable(initialOwner) {}

  // Function to check if caller is approved or owner
  function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
    return ownerOf(tokenId) == spender || ERC721.isApprovedForAll(ownerOf(tokenId), spender);
  }

  // Function to set user for a token (only the owner can call this)
  function setUser(uint256 tokenId, address user, uint256 expires) external onlyOwner {
    require(_isApprovedOrOwner(msg.sender, tokenId), "Caller is not owner nor approved");
    _users[tokenId] = user;
    _userExpires[tokenId] = expires;
    emit UpdateUser(tokenId, user, expires);
  }

  // Function to get user for a token
  function userOf(uint256 tokenId) external view returns (address) {
    return _users[tokenId];
  }

  // Function to get expiration time for a token
  function userExpires(uint256 tokenId) external view returns (uint256) {
    return _userExpires[tokenId];
  }

  // Function to clear expired rentals
  function clearExpired(uint256 tokenId) external {
    require(_isApprovedOrOwner(msg.sender, tokenId), "Caller is not owner nor approved");
    if (_userExpires[tokenId] < block.timestamp) {
      _users[tokenId] = address(0);
      _userExpires[tokenId] = 0;
      emit UpdateUser(tokenId, address(0), 0);
    }
  }
}





```
