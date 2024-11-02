// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol"; // Importing the Forge testing library
import "../../src/SwapHooks.sol";  // Importing the SwapHooks contract
import "../../src/DiscountNFT.sol"; // Importing the DiscountNFT contract
import "../../src/TokenA.sol";       // Importing the TokenA contract
import "../../src/TokenB.sol";       // Importing the TokenB contract

contract BaseSwapHooksTest is Test {
    SwapHooks public swapHooks;
    DiscountNFT public discountNFT;
    TokenA public tokenA;
    TokenB public tokenB;

    address buyer = address(makeAddr("buyer"));
    address seller = address(makeAddr("seller"));

    function setUp() public virtual {
        // Deploy the DiscountNFT contract
        discountNFT = new DiscountNFT();
        console.log("Deployed DiscountNFT contract at:", address(discountNFT));
        
        // Mint NFT with 15% discount for the buyer
        discountNFT.mint(buyer, 15);
        console.log("Minted NFT with 15% discount for buyer:", buyer);
        
        // Deploy TokenA and TokenB contracts
        tokenA = new TokenA();
        tokenB = new TokenB();
        console.log("Deployed TokenA contract at:", address(tokenA));
        console.log("Deployed TokenB contract at:", address(tokenB));

        // Deploy the SwapHooks contract
        swapHooks = new SwapHooks(address(discountNFT), address(tokenA), address(tokenB));
        console.log("Deployed SwapHooks contract at:", address(swapHooks));

        // Mint initial token balances for testing
        tokenA.mint(buyer, 100); // Mint 100 TokenA for the buyer
        console.log("Minted 100 TokenA for buyer:", buyer, "Current TokenA balance:", tokenA.balanceOf(buyer));

        tokenB.mint(address(swapHooks), 100); // Mint 100 TokenB for the SwapHooks contract
        console.log("Minted 100 TokenB for SwapHooks contract at:", address(swapHooks), "Current TokenB balance:", tokenB.balanceOf(address(swapHooks)));
    }
}
