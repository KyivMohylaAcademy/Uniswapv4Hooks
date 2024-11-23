// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "./ACDCToken.sol";
import "./SlayerToken.sol";
import "./DiscountNFT.sol";
import "./Swap.sol";
import "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import "@uniswap/v4-core/contracts/PoolManager.sol";
import "@uniswap/v4-core/contracts/PoolKey.sol";
import "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import "@uniswap/v4-core/contracts/libraries/Hooks.sol";

contract TestTokenSwap is Test {
    ACDCToken public acdcToken;
    SlayerToken public slayerToken;
    DiscountNFT public discountNFT;
    TokenSwapHook public tokenSwapHook;
    IPoolManager public poolManager;
    IPoolManager.PoolKey public poolKey;

    address public buyer;
    address public seller;

    function setUp() public {
        // Deploy tokens and NFT
        acdcToken = new ACDCToken();
        slayerToken = new SlayerToken();
        discountNFT = new DiscountNFT();

        // Create buyer and seller addresses
        buyer = address(0xBEEF);
        seller = address(0xCAFE);

        // Mint tokens
        acdcToken.mint(buyer, 30 ether);
        slayerToken.mint(seller, 50 ether);

        // Mint Discount NFT to buyer with 15% discount
        discountNFT.mint(buyer, 15);

        // Deploy PoolManager and Hook
        poolManager = new PoolManager();
        tokenSwapHook = new TokenSwapHook(poolManager, discountNFT);

        // Approve tokens
        vm.prank(buyer);
        acdcToken.approve(address(poolManager), type(uint256).max);

        vm.prank(seller);
        slayerToken.approve(address(poolManager), type(uint256).max);

        // Initialize pool
        poolKey = IPoolManager.PoolKey({
            currency0: Currency.wrap(address(acdcToken)),
            currency1: Currency.wrap(address(slayerToken)),
            fee: 3000,
            hook: Hooks.validateHookAddress(address(tokenSwapHook))
        });

        uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(0);
        poolManager.initialize(poolKey, sqrtPriceX96);

        // Add initial liquidity (for testing)
        vm.prank(seller);
        poolManager.modifyLiquidity(
            poolKey,
            IPoolManager.ModifyLiquidityParams({
                tickLower: TickMath.MIN_TICK,
                tickUpper: TickMath.MAX_TICK,
                liquidityDelta: 100 ether
            }),
            abi.encode(seller)
        );
    }

    function testSwapWithDiscount() public {
        // Buyer swaps 30 ACDC for Slayer tokens
        vm.prank(buyer);
        poolManager.swap(
            poolKey,
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: int256(30 ether),
                sqrtPriceLimitX96: TickMath.MIN_SQRT_RATIO + 1
            }),
            abi.encode(buyer)
        );

        // Check balances
        uint256 buyerSlayerBalance = slayerToken.balanceOf(buyer);
        uint256 sellerACDCBalance = acdcToken.balanceOf(seller);

        // Expected results considering 15% discount on fee
        // Calculate expected fee
        uint256 amountIn = 30 ether;
        uint256 standardFee = (amountIn * 3000) / 1e6; // 0.3% standard fee
        uint256 discount = (standardFee * 15) / 100; // 15% discount
        uint256 discountedFee = standardFee - discount;
        uint256 expectedSellerACDC = amountIn - discountedFee; // Seller receives amountIn minus fee
        uint256 expectedBuyerSlayer = 50 ether; // Buyer should receive 50 Slayer tokens

        assertEq(sellerACDCBalance, expectedSellerACDC, "Seller ACDC balance incorrect");
        assertEq(buyerSlayerBalance, expectedBuyerSlayer, "Buyer Slayer balance incorrect");
    }
}
