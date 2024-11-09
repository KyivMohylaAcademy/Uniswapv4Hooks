// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DiscountNFT is ERC721 {
  
  struct Discount {
      uint8 discount;
  }

  Discount[] public discounts;

  mapping (uint => address) public nftToOwner;
  mapping (address => uint) ownerNFTCount;

  constructor() ERC721("DiscountNFT", "DNFT") {}

  function mint(address _recipient, uint8 _discount) public returns (uint256) {
    require(_discount > 0 && _discount <= 20, "Discount must be from 0 to 20%");
    discounts.push(Discount(_discount));
    uint256 newTokenId = discounts.length - 1;
    nftToOwner[newTokenId] =  _recipient;
    ownerNFTCount[_recipient] = ownerNFTCount[ _recipient]++;
    _safeMint(_recipient, newTokenId);

  }

    
  function getDiscount(address _recipient) public view returns (uint8) {
    require(ownerNFTCount[_recipient] > 0, "Recipient doesn't have NFT");
    uint amount = ownerNFTCount[_recipient];
    for (uint i = 0; i < discounts.length; i++) {
      if (nftToOwner[i] == _recipient) {
        return discounts[i].discount;
      }
    }
  }
}
