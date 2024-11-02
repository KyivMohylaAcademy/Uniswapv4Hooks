// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract DiscountNFT is ERC721, Ownable {
    uint256 public tokenIdCounter;
    mapping(uint256 => uint8) public discount;

    constructor() ERC721("DiscountNFT", "DNFT") Ownable(msg.sender) {}

    function mint(address to, uint8 _discount) external onlyOwner {
        require(_discount <= 20, "Discount should be between 0 and 20");
        
        uint256 tokenId = tokenIdCounter;
        _safeMint(to, tokenId);
        discount[tokenId] = _discount;
        
        tokenIdCounter++;
    }

    function getDiscount(uint256 tokenId) external view returns (uint8) {
        return discount[tokenId];
    }

    function burn(uint256 tokenId) public onlyOwner {
        _burn(tokenId);
        delete discount[tokenId];
    }

    function exists(uint256 tokenId) external view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}