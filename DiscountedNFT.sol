pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DiscountedNFT is ERC721, Ownable {

    mapping(uint256 => uint8) private _discounts;

constructor(address initialOwner) ERC721("DiscountedNFT", "DNFT") Ownable(initialOwner) {}

    function mint(address to, uint256 tokenId, uint8 discount) public onlyOwner {
        require(discount >= 0 && discount <= 20, "Discount must be between 0 and 20");
        _mint(to, tokenId);
        _discounts[tokenId] = discount;
    }

    function getDiscount(uint256 tokenId) public view returns (uint8) {
        return _discounts[tokenId];
    }
}
