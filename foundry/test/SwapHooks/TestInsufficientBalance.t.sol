// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import necessary contracts and libraries
import "forge-std/Test.sol"; // Importing the Forge testing library
import "../SwapHooks/BaseSwapHooksTest.t.sol"; // Importing the base test contract

contract TestInsufficientBalance is BaseSwapHooksTest {

    function testInsufficientTokenABalance() public {
        uint256 amountIn = 200; // More than what the buyer has
        uint256 amountOut = 50;

        // Log the buyer's current Token A balance
        uint256 currentBalanceA = tokenA.balanceOf(buyer);
        console.log("Buyer Token A balance before swap:", currentBalanceA);
        
        // Expect the revert with the specified message
        vm.expectRevert("Not enough TokenA");
        swapHooks.beforeSwap(buyer, 0, amountIn, amountOut); // Call beforeSwap
        
        // Log that the function was called
        console.log("Called beforeSwap with amountIn:", amountIn, "and amountOut:", amountOut);
    }

    function testInsufficientTokenBBalance() public {
        uint256 amountIn = 30;
        uint256 amountOut = 200; // More than what the contract has

        // Log the contract's current Token B balance
        uint256 currentBalanceB = tokenB.balanceOf(address(swapHooks));
        console.log("Contract Token B balance before swap:", currentBalanceB);
        
        // Expect the revert with the specified message
        vm.expectRevert("Not enough TokenB in the contract");
        swapHooks.beforeSwap(buyer, 0, amountIn, amountOut); // Call beforeSwap
        
        // Log that the function was called
        console.log("Called beforeSwap with amountIn:", amountIn, "and amountOut:", amountOut);
    }
}
