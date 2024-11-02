// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DiscountNFT.sol";

contract DiscountNFTTest is Test {
    DiscountNFT discountNFT;
    address owner = address(this); // Власник контракту
    address recipient = address(1); // Тестова EOA адреса для отримання NFT

    function setUp() public {
        discountNFT = new DiscountNFT();
    }

    function testMintWithDiscount() public {
        // Імітуємо, що власник викликає функцію mint
        hoax(owner);
        discountNFT.mint(recipient, 15);

        // Перевіряємо, що знижка для токена встановлена коректно
        assertEq(discountNFT.getDiscount(0), 15);
    }
}
