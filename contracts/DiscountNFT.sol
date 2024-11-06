// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DiscountNFT is ERC721 {
    struct NFTMetadata {
        uint8 discount;
    }

    mapping(uint256 => NFTMetadata) public nftMetadata;
    uint256 public tokenCounter;

    constructor() ERC721("DiscountNFT", "DNFT") {
        tokenCounter = 1;
    }

    function mintNFT(address to, uint8 discount) public {
        require(discount <= 20, "Discount must be between 0 and 20");
        uint256 tokenId = tokenCounter;
        _safeMint(to, tokenId);
        nftMetadata[tokenId] = NFTMetadata(discount);
        tokenCounter += 1;
    }

    function getDiscount(uint256 tokenId) public view returns (uint8) {
        return nftMetadata[tokenId].discount;
    }
}