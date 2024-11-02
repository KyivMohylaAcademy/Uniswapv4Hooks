pragma solidity ^0.8.0;

import {ERC721} from "solmate/src/tokens/ERC721.sol";

    contract DiscountNFT is ERC721 {
    mapping(uint256 => uint24) private _discounts;

    constructor() ERC721("DiscountNFT", "DNFT") {}

    function mint(address to, uint24 discount) external {
        uint256 tokenId = uint256(uint160(to));
        _discounts[tokenId] = discount;
        _mint(to, tokenId);
    }

    function setDiscount(uint256 _id, uint24 _discount) external {
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