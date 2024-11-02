// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "solmate/src/tokens/ERC721.sol";
import {Ownable} from "v4-core/lib/openzeppelin-contracts/contracts/access/Ownable.sol";

    contract DiscountNFT is ERC721, Ownable {
    mapping(uint256 => uint24) private _discounts;

    constructor() ERC721("DiscountNFT", "DNFT") Ownable(msg.sender){}

    function mint(address to, uint24 discount) external onlyOwner {
        uint256 tokenId = uint256(uint160(to));
        _discounts[tokenId] = discount;
        _mint(to, tokenId);
    }

    function setDiscount(uint256 _id, uint24 _discount) external onlyOwner {
        require(_discount > 0 && _discount <= 20, "DISCOUNT_RANGE");
        _discounts[_id] = _discount;
    }

    function getDiscount(address who) public view returns (uint24) {
        return _discounts[uint256(uint160(who))];
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "ukma.edu.ua";
    }
}