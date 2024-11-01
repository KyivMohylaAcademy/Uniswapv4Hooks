// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import {ERC721 as SolmateERC721} from "solmate/src/tokens/ERC721.sol";

// this could implement ownable, but honestly, very hard to pass msg.sender to pool hook creation.
contract Discount is SolmateERC721 {
    /// Maps tokenid to its discount.
    mapping(uint256 => uint24) public discounts;

    constructor() SolmateERC721("Discount", "DSC") {}

    function mint(address to, uint24 discount) external {
        uint256 tokenId = uint256(uint160(to));
        discounts[tokenId] = discount;
        _mint(to, tokenId);
    }

    function setDiscount(uint256 _id, uint24 _discount) external {
        require(_discount > 0 && _discount <= 20, "DISCOUNT_RANGE");
        discounts[_id] = _discount;
    }

    function getDiscount(address who) public view returns (uint24) {
        return discounts[uint256(uint160(who))];
    }

    // ERC721 implementations.
    function tokenURI(uint256 id) public view override returns (string memory) {
        return "ukma.edu.ua";
    }
}
