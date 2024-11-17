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
        manager = new PoolManager();

        // Mint NFT for the buyer with a 15% discount
        discountNFT.mint(buyer, 15);

        // Mint tokens for the buyer and seller
        tokenACDC.mint(buyer, 30); // Buyer starts with 30 ACDC tokens
        tokenSLYR.mint(seller, 50); // Seller starts with 50 SLYR tokens

        // Deploy the hook
        hook = new DiscountHook(manager, address(discountNFT));
    }

    function testSwapWithDiscount() public {
        // Verify initial balances
        assertEq(tokenACDC.balanceOf(buyer), 30, "Buyer initial ACDC balance incorrect");
        assertEq(tokenSLYR.balanceOf(seller), 50, "Seller initial SLYR balance incorrect");

        // Simulate the swap logic
        uint256 buyerInitialACDC = tokenACDC.balanceOf(buyer);
        uint256 sellerInitialSLYR = tokenSLYR.balanceOf(seller);

        uint8 discount = discountNFT.getDiscount(buyer);
        uint256 amountToSwap = 30;

        // Apply the discount to the swap (15% fee reduction)
        uint256 discountedAmount = (amountToSwap * (100 - discount)) / 100;

        // Adjust balances for the swap
        tokenACDC.transferFrom(buyer, seller, discountedAmount); // Buyer sends 25.5 ACDC (30 - 15% discount)
        tokenSLYR.transferFrom(seller, buyer, sellerInitialSLYR); // Seller sends 50 SLYR

        // Verify final balances
        assertEq(tokenACDC.balanceOf(seller), buyerInitialACDC - discountedAmount, "Seller final ACDC balance incorrect");
        assertEq(tokenSLYR.balanceOf(buyer), sellerInitialSLYR, "Buyer final SLYR balance incorrect");
    }
}
