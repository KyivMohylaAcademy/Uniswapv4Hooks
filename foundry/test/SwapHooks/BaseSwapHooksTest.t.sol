// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/SwapHooks.sol";
import "../../src/DiscountNFT.sol";
import "../../src/TokenA.sol";
import "../../src/TokenB.sol";

contract BaseSwapHooksTest is Test {
    SwapHooks public swapHooks;
    DiscountNFT public discountNFT;
    TokenA public tokenA;
    TokenB public tokenB;

    address buyer = address(makeAddr("buyer"));

    function setUp() public virtual {
        // Deploy the DiscountNFT contract
        discountNFT = new DiscountNFT();
        console.log("Deployed DiscountNFT contract at:\t\t", address(discountNFT));
        
        // Mint NFT with 15% discount for the buyer
        discountNFT.mint(buyer, 15);
        console.log("Minted NFT with 15% discount for buyer:\t", buyer);
        
        // Deploy TokenA and TokenB contracts
        tokenA = new TokenA();
        tokenB = new TokenB();
        console.log("Deployed TokenA contract at:\t\t\t", address(tokenA));
        console.log("Deployed TokenB contract at:\t\t\t", address(tokenB));

        // Deploy the SwapHooks contract
        swapHooks = new SwapHooks(address(discountNFT), address(tokenA), address(tokenB));
        console.log("Deployed SwapHooks contract at:\t\t", address(swapHooks));

        // Mint initial token balances for testing
        tokenA.mint(buyer, 100); // Mint 100 TokenA for the buyer
        console.log("Minted 100 TokenA for buyer:\t\t\t", buyer);
        console.log("Current TokenA balance:\t\t\t", tokenA.balanceOf(buyer));

        tokenB.mint(address(swapHooks), 100); // Mint 100 TokenB for the SwapHooks contract
        console.log("Minted 100 TokenB for SwapHooks contract at:\t", address(swapHooks));
        console.log("Current TokenB balance:\t\t\t", tokenB.balanceOf(address(swapHooks)));
        console.log("");
    }
}
