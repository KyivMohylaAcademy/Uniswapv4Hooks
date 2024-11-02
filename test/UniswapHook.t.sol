// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";

import {LPFeeLibrary} from "v4-core/libraries/LPFeeLibrary.sol";

import {PoolKey} from "v4-core/types/PoolKey.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";

import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/types/BeforeSwapDelta.sol";

import {UniswapHook} from "../src/UniswapHook.sol";
import {BuyerERC20} from "../src/BuyerERC20.sol";
import {SellerERC20} from "../src/SellerERC20.sol";
import {DiscountNFT} from "../src/DiscountNFT.sol";

contract UniswapHookTest is Test {
    DiscountNFT public nft;
    UniswapHook public uniswapHook;
    IPoolManager public poolManager;

    address public buyer = address(0x1);
    address public seller = address(0x2);

    function setUp() public {
        nft = new DiscountNFT();
        nft.mint(buyer, 15);

        poolManager = IPoolManager(address(this));

        uniswapHook = new UniswapHook(poolManager, address(nft));
    }

     function testBeforeSwapWithDiscount() public {
        PoolKey memory poolKey;
        IPoolManager.SwapParams memory params;

        bytes memory hookData = "";

        (bytes4 selector, BeforeSwapDelta delta, uint24 fee) = uniswapHook.beforeSwap(buyer, poolKey, params, hookData);

        assertEq(selector, uniswapHook.beforeSwap.selector, "Unexpected selector returned");
        assertEq(fee, uint24(1500 | LPFeeLibrary.OVERRIDE_FEE_FLAG), "Fee does not match 15% discount expectation");
    }

    function testBeforeSwapWithoutNFT() public {
        PoolKey memory poolKey;
        IPoolManager.SwapParams memory params;
        bytes memory hookData = "";

        (bytes4 selector, BeforeSwapDelta delta, uint24 fee) = uniswapHook.beforeSwap(seller, poolKey, params, hookData);

        assertEq(selector, uniswapHook.beforeSwap.selector, "Unexpected selector returned");
        assertEq(fee, 0, "Fee should be zero as Seller has no NFT");
    }
}
