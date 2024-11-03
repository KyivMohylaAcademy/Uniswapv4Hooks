// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DiscountNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;
    mapping(uint256 => uint8) public discounts; // Mapping to store discount for each token ID

    // Pass the deployer's address to the Ownable constructor
    constructor() ERC721("DiscountNFT", "DNFT") Ownable(msg.sender) {}

    // Function to mint a new NFT with a discount value
    function mintNFT(address recipient, string memory tokenURI, uint8 discount) public onlyOwner returns (uint256) {
        require(discount >= 0 && discount <= 20, "Discount must be between 0 and 20");

        _tokenIds++;
        uint256 newItemId = _tokenIds;
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);
        discounts[newItemId] = discount; // Store the discount value

        return newItemId;
    }
}
