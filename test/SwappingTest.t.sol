// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "../src/BuyerToken.sol";
import "../src/SellerToken.sol";
import "../src/DiscountCouponNFT.sol";
import "../src/DiscountSwapHook.sol";

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-periphery/lib/v4-core/src/types/PoolKey.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {Deployers} from "v4-periphery/lib/v4-core/test/utils/Deployers.sol";
import {TickMath} from "v4-periphery/lib/v4-core/src/libraries/TickMath.sol";
import {PoolSwapTest} from "v4-periphery/lib/v4-core/src/test/PoolSwapTest.sol";

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract SwappingTest is Test, Deployers {
    DiscountCouponNFT private couponContract;
    BuyerToken private buyerTokenContract;
    SellerToken private sellerTokenContract;
    DiscountSwapHook private discountSwapHook;

    address private buyer;
    address private seller;

    function setUp() public {
        deployFreshManagerAndRouters();

        buyerTokenContract = new BuyerToken();
        sellerTokenContract = new SellerToken();

        Currency buyerCurrency = Currency.wrap(address(buyerTokenContract));
        Currency sellerCurrency = Currency.wrap(address(sellerTokenContract));

        address flags = address(
            uint160(
                Hooks.BEFORE_SWAP_FLAG
            ) ^ (0x4444 << 144)
        );

        deployCodeTo(
            "DiscountSwapHook.sol",
            abi.encode(manager, "Discount Swap Hook", "SWAP_HOOK"),
            flags
        );

        discountSwapHook = DiscountSwapHook(flags);
        couponContract = discountSwapHook.couponContract();

        buyerTokenContract.approve(address(swapRouter), type(uint256).max);
        buyerTokenContract.approve(address(modifyLiquidityRouter), type(uint256).max);
        sellerTokenContract.approve(address(modifyLiquidityRouter), type(uint256).max);

        buyerTokenContract.mint(address(swapRouter), 100);
        buyerTokenContract.mint(address(modifyLiquidityRouter), 2000);
        sellerTokenContract.mint(address(swapRouter), 200);
        sellerTokenContract.mint(address(modifyLiquidityRouter), 2000);

        buyerTokenContract.mint(address(this), 530);
        sellerTokenContract.mint(address(this), 500);

        (key, ) = initPool(
            buyerCurrency,
            sellerCurrency,
            discountSwapHook,
            3000,
            SQRT_PRICE_1_1
        );

        modifyLiquidityRouter.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams(
                TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 500, 0
            ),
            ZERO_BYTES
        );

        couponContract.mint(address(swapRouter), 15);

    }

    function testBeforeSwap() public {
        bytes memory hookData = new bytes(0);

        Currency curr0 = Currency.wrap(address(buyerTokenContract));
        Currency curr1 = Currency.wrap(address(sellerTokenContract));

        console.log("Balance buy:", curr0.balanceOfSelf());
        console.log("Balance sell:", curr1.balanceOfSelf());

        swapRouter.swap{value: 30}(
            key,
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: -30,
                sqrtPriceLimitX96: MIN_PRICE_LIMIT
            }),
            PoolSwapTest.TestSettings({
                takeClaims: false,
                settleUsingBurn: false
            }),
            hookData
        );

        console.log("Balance buy:", curr0.balanceOfSelf());
        console.log("Balance sell:", curr1.balanceOfSelf());
    }


}