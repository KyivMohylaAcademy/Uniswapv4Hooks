// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DiscountNFT is ERC721, Ownable {
    struct TokenMetadata {
        uint8 discount;
    }
    
    mapping(uint256 => TokenMetadata) public tokenMetadata;
    mapping(address => uint256[]) private _userTokens;
    uint256 private _nextTokenId;

    constructor() ERC721("DiscountNFT", "DNFT") Ownable(msg.sender) {}

    function mint(address to, uint8 discount) public onlyOwner {
        require(discount <= 20, "Discount must be between 0 and 20");
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        tokenMetadata[tokenId] = TokenMetadata(discount);
        _userTokens[to].push(tokenId);
    }

    function getDiscount(uint256 tokenId) public view returns (uint8) {
        require(_exists(tokenId), "Token does not exist");
        return tokenMetadata[tokenId].discount;
    }

    function getUserFirstToken(address user) public view returns (uint256) {
        require(_userTokens[user].length > 0, "User has no tokens");
        return _userTokens[user][0];
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return tokenId < _nextTokenId && tokenId >= 0;
    }

    function _update(address to, uint256 tokenId, address auth) 
        internal 
        override 
        returns (address)
    {
        address from = super._update(to, tokenId, auth);
        
        if (from != address(0)) {
            // Remove token from previous owner's array
            uint256[] storage fromTokens = _userTokens[from];
            for (uint i = 0; i < fromTokens.length; i++) {
                if (fromTokens[i] == tokenId) {
                    fromTokens[i] = fromTokens[fromTokens.length - 1];
                    fromTokens.pop();
                    break;
                }
            }
        }
        
        if (to != address(0)) {
            // Add token to new owner's array
            _userTokens[to].push(tokenId);
        }
        
        return from;
    }
} 