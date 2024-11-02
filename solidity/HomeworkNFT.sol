pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HomeworkNFT is ERC721, Ownable {

    // uint256 - token
    // uint8 - discount
    mapping(uint256 => uint8) _tokenToDiscount;

    // To generate unique token ids
    uint256 private _nextTokenId;

    constructor() ERC721("HomeworkNFT", "HNFT") Ownable(msg.sender) {}

    function mint(address to, uint8 discount) external onlyOwner {
        require(discount <= 20, "Discount must be between 0% and 20%");
        ++_nextTokenId;
        _safeMint(to, _nextTokenId);
       _tokenToDiscount[_nextTokenId] = discount;
    }

    function getDiscount(uint256 tokenId) external view returns (uint8) {
        require(_ownerOf(tokenId) != address(0), "Token doesn't exist");
        return _tokenToDiscount[tokenId];
    }
}