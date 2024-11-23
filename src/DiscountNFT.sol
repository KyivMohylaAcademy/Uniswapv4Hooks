// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DiscountNFT is ERC721Enumerable, Ownable {
    mapping(uint256 => uint8) private _tokenDiscounts;

    constructor() ERC721("DiscountNFT", "DNFT") {}

    function mint(address to, uint8 discount) external onlyOwner returns (uint256) {
        require(discount > 0 && discount <= 20, "Discount must be between 1 and 20");
        uint256 tokenId = totalSupply() + 1;
        _safeMint(to, tokenId);
        _tokenDiscounts[tokenId] = discount;
        return tokenId;
    }

    function getDiscount(address owner) external view returns (uint8) {
        uint256 balance = balanceOf(owner);
        require(balance > 0, "Owner has no Discount NFT");
        uint256 tokenId = tokenOfOwnerByIndex(owner, 0); // Assuming first NFT
        return _tokenDiscounts[tokenId];
    }

    function discountOf(uint256 tokenId) external view returns (uint8) {
        require(_exists(tokenId), "Token does not exist");
        return _tokenDiscounts[tokenId];
    }
}