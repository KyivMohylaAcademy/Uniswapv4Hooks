// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DiscountNFT is ERC721, Ownable {

    uint public nextTokenId;

    mapping(uint => uint8) private discount;
    mapping(address => uint) public ownerToTokens;

    constructor() Ownable(msg.sender) ERC721("DiscountedNFT", "DNFT") {}

    function mint(address to, uint8 _discount) external onlyOwner {
        require(_discount >= 0 && _discount <= 20);

        uint tokenId = nextTokenId;
        discount[tokenId] = _discount;

        _safeMint(to, tokenId);

        ownerToTokens[to] = tokenId;
        nextTokenId++;
    }

    function getDiscount(address owner) external view returns (uint8) {
        return discount[ownerToTokens[owner]];
    }

     function setDiscount(address owner, uint8 _discount) external {
        require(_discount > 0 && _discount <= 20);
        
        discount[ownerToTokens[owner]] =  _discount;
    }
}