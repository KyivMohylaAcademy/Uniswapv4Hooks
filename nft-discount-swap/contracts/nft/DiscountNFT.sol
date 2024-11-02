pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DiscountNFT is ERC721, Ownable {
    mapping(uint256 => uint8) public discounts;
    uint256 private _tokenIds;

    constructor() ERC721("DiscountNFT", "DNFT") Ownable(msg.sender) {}

    function mint(address to, uint8 discount) external returns (uint256) {
        require(discount <= 20, "Discount must be <= 20%");
        _tokenIds++;
        _safeMint(to, _tokenIds);
        discounts[_tokenIds] = discount;
        return _tokenIds;
    }

    function getDiscount(uint256 tokenId) external view returns (uint8) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return discounts[tokenId];
    }
}