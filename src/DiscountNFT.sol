// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract DiscountNFT is ERC721Enumerable, Ownable {
    mapping(uint256 => uint8) public discounts;
    
    constructor() ERC721("DiscountNFT", "DNFT") Ownable(msg.sender) {}
    
    function mint(address to, uint256 tokenId, uint8 discount) public onlyOwner {
        require(discount <= 20, "Discount must be between 0 and 20");
        _mint(to, tokenId);
        discounts[tokenId] = discount;
    }
    
    function getDiscount(uint256 tokenId) public view returns (uint8) {
        return discounts[tokenId];
    }
}
