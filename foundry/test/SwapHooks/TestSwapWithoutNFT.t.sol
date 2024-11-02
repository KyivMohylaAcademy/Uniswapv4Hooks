// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../SwapHooks/BaseSwapHooksTest.t.sol";

contract TestSwapWithoutNFT is BaseSwapHooksTest {
    function testSwapWithoutNFT() public {
        uint256 amountIn = 30;
        uint256 amountOut = 50;

        // Approve SwapHooks to spend amountIn TokenA
        vm.prank(buyer); // Set the context to the buyer's address
        tokenA.approve(address(swapHooks), amountIn); 
        console.log("Buyer:", buyer);
        console.log("Approved", amountIn, "TokenA for SwapHooks at:", address(swapHooks));

        // First, perform the swap
        console.log("Attempting to swap TokenA for TokenB. Amount In:", amountIn, "Amount Out:", amountOut);
        swapHooks.beforeSwap(buyer, 0, amountIn, amountOut); // Call beforeSwap
        console.log("Swap successful. Buyer now has TokenB.");

        // Now, burn the NFT for the buyer
        discountNFT.burn(0); // Burn the token with ID 0
        console.log("Burned NFT with ID 0 for buyer:", buyer);

        // Now that the buyer has no NFT, check that the swap fails
        vm.expectRevert("Token does not exist"); // Expect an error
        console.log("Expecting revert due to NFT ownership. Buyer:", buyer, "attempting to swap TokenA again.");
        swapHooks.beforeSwap(buyer, 0, amountIn, amountOut); // Call beforeSwap again
    }
}
