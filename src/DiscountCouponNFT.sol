// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract DiscountCouponNFT is ERC721 {
    uint256 private couponCounter;

    mapping (uint256 => uint8) private _discounts;
    mapping (address => uint256) public _ownerToCouponId;

    constructor() ERC721("DiscountCouponNFT", "DSCPN") {
        couponCounter = 0;
    }

    function mint(address to, uint8 discount) public returns (uint256) {
        require(discount >= 0 && discount <= 20, "Discount must be between 0% and 20%");
        uint256 couponId = couponCounter;
        _mint(to, couponId);
        _discounts[couponId] = discount;
        _ownerToCouponId[to] = couponId;
        couponCounter++;
        return couponId;
    }

    function getCouponId(address couponOwner) public view returns (uint256) {
        return _ownerToCouponId[couponOwner];
    }

    function discountOf(uint256 couponId) public view returns (uint8) {
        return _discounts[couponId];
    }
}