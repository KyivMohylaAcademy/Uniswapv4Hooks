// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DiscountNFT is ERC721URIStorage, Ownable {

    uint256 public tokenCounter;

    mapping(uint256 => uint8) private discounts;
    mapping(address => uint256) private ownerToToken;

    constructor() Ownable(msg.sender) ERC721("DiscountNFT", "DNFT") {
        tokenCounter = 1;
    }

    function mintNFT(address _recipient, uint8 _discount) public onlyOwner returns (uint256) {
        require(_discount <= 20, "Discount must be between 0 and 20");

        uint256 newTokenId = tokenCounter;
        _safeMint(_recipient, newTokenId);
        ownerToToken[_recipient] = newTokenId;
        discounts[newTokenId] = _discount;

        tokenCounter += 1;
        return newTokenId;
    }

    function getDiscount(address owner) public view returns (uint8) {
        uint256 tokenId = ownerToToken[owner];
        return discounts[tokenId];
    }

}