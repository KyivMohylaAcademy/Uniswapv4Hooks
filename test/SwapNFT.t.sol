// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/DiscountNFT.sol";
import "src/ACDCToken.sol";
import "src/SlayerToken.sol";
import "src/SwapNFT.sol";
import {IPoolManager} from "lib/v4-periphery/lib/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "lib/v4-periphery/lib/v4-core/src/types/PoolKey.sol";
import {IHooks} from "lib/v4-periphery/lib/v4-core/src/interfaces/IHooks.sol";
import {Currency} from "lib/v4-periphery/lib/v4-core/src/types/Currency.sol";



contract SwapNFTTest is Test {
    DiscountNFT public discountNFT;
    ACDCToken public acdcToken;
    SlayerToken public slayerToken;
    SwapNFT public swapNFT;
    IPoolManager public manager;
    address buyer;
    address seller;

    event BalanceCast(uint256 buyerBalance, uint256 sellerBalance);


    function setUp() public {
        manager = IPoolManager(address(0x1234321312412));
        discountNFT = new DiscountNFT(msg.sender);
        acdcToken = new ACDCToken();
        slayerToken = new SlayerToken();
        
        buyer = vm.addr(1);
        seller = vm.addr(2);

        swapNFT = new SwapNFT(manager, discountNFT, acdcToken, slayerToken);

        acdcToken.transfer(buyer, 100 * 10**acdcToken.decimals());
        slayerToken.transfer(seller, 100 * 10**slayerToken.decimals());

        uint256 buyerBalance = slayerToken.balanceOf(buyer);
        uint256 sellerBalance = acdcToken.balanceOf(seller);
        emit BalanceCast(buyerBalance, sellerBalance);

        discountNFT.mintNFT(buyer, 15);
    }

    function testSwapWithDiscount() public {
        vm.prank(buyer);
        acdcToken.approve(address(swapNFT), 50 * 10**acdcToken.decimals());

        vm.prank(seller);
        slayerToken.approve(address(swapNFT), 50 * 10**slayerToken.decimals());

        uint256 amountIn = 30 * 10**acdcToken.decimals();
        uint256 expectedAmountOut = (amountIn * 85) / 100;

        PoolKey memory poolKey = PoolKey(Currency.wrap(address(acdcToken)), Currency.wrap(address(slayerToken)), 3000, 60, IHooks(swapNFT));

        vm.prank(buyer);
        swapNFT.swapWithDiscount(buyer, seller, amountIn, expectedAmountOut, poolKey);

        uint256 buyerBalance = slayerToken.balanceOf(buyer);
        uint256 sellerBalance = acdcToken.balanceOf(seller);

        emit BalanceCast(buyerBalance, sellerBalance);

        assertEq(buyerBalance, expectedAmountOut, "Incorrect balance for buyer after swap");
        assertEq(sellerBalance, amountIn, "Incorrect balance for seller after swap");
    }

}
