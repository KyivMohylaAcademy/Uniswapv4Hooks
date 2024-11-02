// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import necessary contracts and libraries
import "forge-std/Test.sol"; // Importing the Forge testing library
import "../SwapHooks/BaseSwapHooksTest.t.sol"; // Importing the base test contract

contract TestSwapHooks is BaseSwapHooksTest {
    function testSwapWithDiscount() public {
        uint256 amountIn = 30; // Amount of TokenA the buyer wants to swap
        uint256 amountOut = 50; // Amount of TokenB the buyer should receive without discount

        // Log the initial state before approval
        logInitialState();

        // Approve SwapHooks to spend amountIn TokenA
        approveSwapHooks(amountIn);

        // Execute the swap
        executeSwap(amountIn, amountOut);

        // Validate the final balances
        validateFinalBalances();
    }

    function logInitialState() internal view {
        console.log("Buyer before approval:", buyer);
        console.log("Token A balance before approval:", tokenA.balanceOf(buyer));
    }

    function approveSwapHooks(uint256 amountIn) internal {
        vm.prank(buyer); // Set the context to the buyer's address
        tokenA.approve(address(swapHooks), amountIn);
        console.log("Allowance of SwapHooks to spend TokenA:", tokenA.allowance(buyer, address(swapHooks)));
    }

    function executeSwap(uint256 amountIn, uint256 amountOut) internal {
        console.log("Executing swap with amountIn:", amountIn, "and amountOut:", amountOut);
        swapHooks.beforeSwap(buyer, 0, amountIn, amountOut); // Call beforeSwap
        console.log("Swap executed");
    }

    function validateFinalBalances() internal view{
        uint256 finalBalanceA = tokenA.balanceOf(buyer);
        uint256 finalBalanceB = tokenB.balanceOf(buyer);

        console.log("Final Token A balance of buyer:", finalBalanceA); // Check remaining TokenA
        console.log("Final Token B balance of buyer:", finalBalanceB); // Check received TokenB

        assertEq(finalBalanceA, 70); // 100 - 30 = 70 TokenA
        assertEq(finalBalanceB, 43); // 50 - 15% = 43
    }
}
