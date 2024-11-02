// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../SwapHooks/BaseSwapHooksTest.t.sol";

contract TestSwapHooks is BaseSwapHooksTest {
    function testSwapWithDiscount() public {
        uint256 amountIn = 30; // Amount of TokenA the buyer wants to swap
        uint256 amountOut = 50; // Amount of TokenB the buyer should receive without discount

        // Log the initial state before approval
        console.log("Buyer before approval:", buyer);
        console.log("Token A balance before approval:", tokenA.balanceOf(buyer));

        // Approve SwapHooks to spend amountIn TokenA
        vm.prank(buyer);
        tokenA.approve(address(swapHooks), amountIn);
        console.log("Allowance of SwapHooks to spend TokenA:", tokenA.allowance(buyer, address(swapHooks)));

        // Log balances
        console.log("Initial Token A balance of buyer:", tokenA.balanceOf(buyer));
        console.log("Initial Token B balance of buyer:", tokenB.balanceOf(buyer));
        console.log("Initial Token A balance of seller:", tokenA.balanceOf(address(swapHooks)));
        console.log("Initial Token B balance of seller:", tokenB.balanceOf(address(swapHooks)));

        // Execute the swap
        console.log("Executing swap with amountIn:", amountIn, "and amountOut:", amountOut);
        swapHooks.beforeSwap(buyer, 0, amountIn, amountOut);
        console.log("Swap executed");

        // Validate the final balances
        uint256 finalBuyerBalanceA = tokenA.balanceOf(buyer);
        uint256 finalBuyerBalanceB = tokenB.balanceOf(buyer);
        uint256 finalSellerBalanceA = tokenA.balanceOf(address(swapHooks));
        uint256 finalSellerBalanceB = tokenB.balanceOf(address(swapHooks));

        console.log("Final Token A balance of buyer:", finalBuyerBalanceA);
        console.log("Final Token B balance of buyer:", finalBuyerBalanceB);
        console.log("Final Token A balance of seller:", finalSellerBalanceA);
        console.log("Final Token B balance of seller:", finalSellerBalanceB);

        assertEq(finalBuyerBalanceA, 74);
        assertEq(finalBuyerBalanceB, 50);
        assertEq(finalSellerBalanceA, 26);
        assertEq(finalSellerBalanceB, 50);
    }
}
