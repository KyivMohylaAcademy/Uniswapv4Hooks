// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DiscountNFT.sol";

contract DiscountNFTTest is Test {
    DiscountNFT discountNFT;
    address owner = address(this);
    address recipient = address(1);

    function setUp() public {
        discountNFT = new DiscountNFT();
    }

    function testMintWithDiscount() public {
        hoax(owner);
        discountNFT.mint(recipient, 15);

        assertEq(discountNFT.getDiscount(0), 15);
    }
}
