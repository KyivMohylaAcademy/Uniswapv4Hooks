// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./IDiscountNFT.sol";

contract SwapHooks is Ownable {
    IDiscountNFT public discountNFT;
    IERC20 public tokenA;
    IERC20 public tokenB;

    constructor(address _discountNFT, address _tokenA, address _tokenB) Ownable(msg.sender) {
        discountNFT = IDiscountNFT(_discountNFT);
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function beforeSwap(address buyer, uint256 tokenId, uint256 amountIn, uint256 amountOut) external {
        // Check if the token exists first
        require(discountNFT.exists(tokenId), "Token does not exist");

        // Validate buyer's ownership of the discount NFT
        require(discountNFT.ownerOf(tokenId) == buyer, "Buyer must own the discount NFT");

        // Get the discount percentage
        uint8 discount = discountNFT.getDiscount(tokenId);
        console.log("Buyer:", buyer);
        console.log("Token ID:", tokenId);
        console.log("Original Amount Out:", amountOut);
        console.log("Discount Percentage:", discount);
        console.log("address(this):", address(this));

        // Calculate the discounted amount
        uint256 discountAmount = (amountOut * discount) / 100;
        uint256 finalAmountOut = amountOut - discountAmount;

        // Log calculated amounts
        console.log("Discount Amount:", discountAmount);
        console.log("Final Amount Out after Discount:", finalAmountOut);

        // Check allowances and balances
        checkBuyerBalance(buyer, amountIn);
        checkContractBalance(finalAmountOut);
        checkAllowance(buyer, amountIn);

        // Perform the token transfer
        executeSwap(buyer, amountIn, finalAmountOut);
    }

    function checkAllowance(address buyer, uint256 amountIn) internal view {
        uint256 allowance = tokenA.allowance(buyer, address(this));
        console.log("Allowance of SwapHooks to spend TokenA:", allowance);
        require(allowance >= amountIn, "Insufficient allowance for TokenA");
    }

    function checkBuyerBalance(address buyer, uint256 amountIn) internal view {
        uint256 balance = tokenA.balanceOf(buyer);
        console.log("Token A balance of buyer before transfer:", balance);
        require(balance >= amountIn, "Not enough TokenA");
    }

    function checkContractBalance(uint256 finalAmountOut) internal view {
        uint256 contractBalance = tokenB.balanceOf(address(this));
        console.log("Token B balance in contract before transfer:", contractBalance);
        require(contractBalance >= finalAmountOut, "Not enough TokenB in the contract");
    }

    function executeSwap(address buyer, uint256 amountIn, uint256 finalAmountOut) internal {
        tokenA.transferFrom(buyer, address(this), amountIn); // Transfer Token A from buyer to contract
        console.log("Transferred Token A from buyer to contract. Amount:", amountIn);
        
        tokenB.transfer(buyer, finalAmountOut); // Transfer Token B to buyer
        console.log("Transferred Token B to buyer. Amount:", finalAmountOut);
    }
}
