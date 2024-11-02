// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract DiscountNFT is ERC721Enumerable, Ownable {

    uint256 public tokenCounter;

    mapping(uint256 => uint8) private _discounts;

    constructor(address initialOwner) ERC721("DiscountNFT", "DNFT") Ownable(initialOwner) {
        tokenCounter = 0;
    }

    function mintNFT(address to, uint8 discount) public onlyOwner {
        require(discount <= 20, "Discount must be between 0 and 20");

        uint256 tokenId = tokenCounter;
        _discounts[tokenId] = discount;
        _mint(to, tokenId);
        tokenCounter++;
    }

    function getDiscount(uint256 tokenId) public view returns (uint8) {
        return _discounts[tokenId];
    }
}