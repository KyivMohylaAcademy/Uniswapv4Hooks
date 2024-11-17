// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/DiscountNFT.sol";
import "../src/ACDCToken.sol";
import "../src/SLYRToken.sol";
import "../src/DiscountHook.sol";
import {PoolManager} from "v4-core/PoolManager.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";

contract DiscountHookTest is Test {
    DiscountNFT public discountNFT;
    ACDCToken public tokenACDC;
    SLYRToken public tokenSLYR;
    DiscountHook public hook;
    PoolManager public manager;

    address public buyer = address(1);
    address public seller = address(2);

    function setUp() public {
        address factory = address(0x123); 
        manager = new PoolManager(factory);

        discountNFT = new DiscountNFT();
        tokenACDC = new ACDCToken();
        tokenSLYR = new SLYRToken();

        discountNFT.mint(buyer, 15);
        tokenACDC.mint(buyer, 30);
        tokenSLYR.mint(seller, 50);

        hook = new DiscountHook(manager, address(discountNFT));
    }


    function testBeforeSwap() public {
        uint8 discount = discountNFT.getDiscount(buyer);
        uint24 adjustedFee = uint24(3000 * (100 - discount) / 100);

        assertEq(adjustedFee, 2550, "Incorrect fee after discount");
    }
}
