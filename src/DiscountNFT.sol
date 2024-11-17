// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DiscountNFT is ERC721Enumerable, Ownable {
    uint256 public tokenIdCounter;
    mapping(uint256 => uint8) private _discounts;

    constructor() ERC721("DiscountNFT", "DNFT") Ownable(msg.sender) {}

    /**
     * @dev Mints a new NFT with a discount value and assigns it to `to`.
     * @param to The address that will own the minted NFT.
     * @param discount The discount value (0-20%).
     */
    function mint(address to, uint8 discount) external onlyOwner {
        require(discount <= 20, "Discount cannot exceed 20%");
        uint256 tokenId = tokenIdCounter++;
        _mint(to, tokenId);
        _discounts[tokenId] = discount;
    }

    /**
     * @dev Returns the discount value for a given owner.
     * @param owner The address of the NFT owner.
     * @return discount The discount value (0-20%).
     */
    function getDiscount(address owner) public view returns (uint8) {
        require(balanceOf(owner) > 0, "Owner has no NFTs");
        uint256 tokenId = tokenOfOwnerByIndex(owner, 0); // Retrieves the first token owned
        return _discounts[tokenId];
    }
}
