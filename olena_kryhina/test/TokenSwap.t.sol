pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Deployers} from "@uniswap/v4-core/test/utils/Deployers.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";

import {PoolManager} from "v4-core/PoolManager.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolSwapTest} from "v4-core/test/PoolSwapTest.sol";

import {CurrencyLibrary, Currency} from "v4-core/types/Currency.sol";

import {Hooks} from "v4-core/libraries/Hooks.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {SqrtPriceMath} from "v4-core/libraries/SqrtPriceMath.sol";
import {LiquidityAmounts} from "@uniswap/v4-core/test/utils/LiquidityAmounts.sol";

import "forge-std/console.sol";

import {TokenSwap} from "../src/TokenSwap.sol";
import "../src/CatcoinToken.sol";
import "../src/DiscountNFT.sol";
import "../src/PokecoinToken.sol";

contract TestSwapWithDiscount is Test, Deployers {
    using CurrencyLibrary for Currency;

    CatcoinToken public tokenCatcoin;
    PokecoinToken public tokenPokecoin;
    DiscountNFT public discountNFT;

    address public seller;
    address public buyer;

    Currency discountNFTCurrency;
    Currency tokenCatcoinCurrency;
    Currency tokenPokecoinCurrency;

    TokenSwap hook;

    function setUp() public {
        deployFreshManagerAndRouters();

        (buyer, ) = makeAddrAndKey("buyer");
        (seller, ) = makeAddrAndKey("seller");

        discountNFT = new DiscountNFT();
        tokenCatcoin = new CatcoinToken();
        tokenPokecoin = new PokecoinToken();

        discountNFTCurrency = Currency.wrap(address(discountNFT));
        tokenCatcoinCurrency = Currency.wrap(address(tokenCatcoin));
        tokenPokecoinCurrency = Currency.wrap(address(tokenPokecoin));

        discountNFT.mint(buyer, 15);
        tokenCatcoin.mint(buyer, 30);
        tokenPokecoin.mint(seller, 50);

        uint160 flags = uint160(Hooks.BEFORE_SWAP_FLAG);

        deployCodeTo(
            "TokenSwap.sol",
            abi.encode(manager),
            address(flags)
        );

        hook = TokenSwap(address(flags));
        tokenCatcoinCurrency.approve(address(swapRouter), type(uint256).max);
        tokenPokecoinCurrency.approve(address(swapRouter), type(uint256).max);
        
        (key, ) = initPool(
            tokenCatcoin,
            tokenPokecoin,
            hook,
            3000,
            SQRT_PRICE_1_1
        );
    }


    function testBeforeSwap() public {
        bytes memory hookData = hook.getHookData(buyer, seller);

        uint256 buyerBalance = tokenCatcoin.balanceOf(buyer);
        uint256 sellerBalance = tokenPokecoin.balanceOf(seller);

          swapRouter.swap{value: 30}(
            key,
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: -30,
                sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
            }),
            PoolSwapTest.TestSettings({
                takeClaims: false,
                settleUsingBurn: false
            }),
            hookData
        );

        uint256 buyerBalanceAfterSwap = tokenPokecoin.balanceOf(buyer);
        uint256 sellerBalanceAfterSwap = tokenCatcoin.balanceOf(seller);

        uint256 amountIn = 30;
        uint256 expectedResult = amountIn - ((amountIn * 15) / 100);
        assertEq(sellerBalanceAfterSwap, expectedResult, "Seller Balance is incorrect");

        assertEq(buyerBalanceAfterSwap, sellerBalance,  "Buyer Balance is incorrect"
        );
    }
}
