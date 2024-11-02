// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract DiscountNFT is ERC721 {
  
  struct Discount {
      uint8 discount;
  }

  Discount[] public discounts;

  mapping (uint256 => address) public discountToOwner;
  mapping (address => uint) ownerDiscountCount;

  constructor() ERC721("DiscountNFT", "DNFT") {}

  function mint(address _recipient, uint8 _discount) public returns (uint256) {
    require(_discount <= 20, "Discount must be from 0 to 20%");
    discounts.push(Discount(_discount));
    uint256 newTokenId = discounts.length - 1;
    _safeMint(_recipient, newTokenId);
    discountToOwner[newTokenId] = _recipient;
    ownerDiscountCount[_recipient] = ownerDiscountCount[_recipient]++;
    return newTokenId;
  }

    
  function getDiscount(uint256 _tokenId) public view returns (uint8) {
    require(_tokenId <= (discounts.length - 1), "Token does not exist");
    return discounts[_tokenId].discount;
  }

  function getDiscountByOwner(address _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerDiscountCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < discounts.length; i++) {
      if (discountToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }
}