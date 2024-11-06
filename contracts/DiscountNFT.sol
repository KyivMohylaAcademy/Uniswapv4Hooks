pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DiscountNFT is ERC721 {
    struct NFTMetadata {
        uint8 discount;
    }

    mapping(uint256 => NFTMetadata) public nftMetadata;

    constructor() ERC721("DiscountNFT", "DNFT") {}

    function mint(address to, uint256 tokenId, uint8 discount) public {
        _safeMint(to, tokenId);
        nftMetadata[tokenId] = NFTMetadata(discount);
    }
}
