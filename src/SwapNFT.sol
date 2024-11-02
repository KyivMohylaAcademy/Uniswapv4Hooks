// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DiscountNFT.sol";
import "./ACDCToken.sol";
import "./SlayerToken.sol";
import {BaseHook} from 'lib/v4-periphery/src/base/hooks/BaseHook.sol';
import {Hooks} from "lib/v4-periphery/lib/v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "lib/v4-periphery/lib/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "lib/v4-periphery/lib/v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "lib/v4-periphery/lib/v4-core/src/types/BalanceDelta.sol";


contract SwapNFT is BaseHook {
    DiscountNFT public discountNFT;
    ACDCToken public acdcToken;
    SlayerToken public slayerToken;

    constructor(
        IPoolManager _manager,
        DiscountNFT _discountNFT,
        ACDCToken _acdcToken,
        SlayerToken _slayerToken
    ) BaseHook(_manager) {
        discountNFT = _discountNFT;
        acdcToken = _acdcToken;
        slayerToken = _slayerToken;
    }
    
    struct SwapParams {
        /// Whether to swap token0 for token1 or vice versa
        bool zeroForOne;
        /// The desired input amount if negative (exactIn), or the desired output amount if positive (exactOut)
        int256 amountSpecified;
        /// The sqrt price at which, if reached, the swap will stop executing
        uint160 sqrtPriceLimitX96;
    }

    function swapWithDiscount(
        address buyer,
        address seller,
        uint256 amountIn,
        uint256 expectedAmountOut,
        PoolKey memory poolKey
    ) external {
        uint256 buyerNFTCount = discountNFT.balanceOf(buyer);
        require(buyerNFTCount > 0, "Buyer must own a Discount NFT");

        uint256 totalDiscount = 0;
        for (uint256 i = 0; i < buyerNFTCount; i++) {
            uint256 tokenId = discountNFT.tokenOfOwnerByIndex(buyer, i);
            uint256 discount = discountNFT.getDiscount(tokenId);
            totalDiscount = totalDiscount > discount ? totalDiscount : discount;
        }

        uint256 discountAmount = (expectedAmountOut * totalDiscount) / 100;
        uint256 finalAmountOut = expectedAmountOut - discountAmount;

        require(acdcToken.balanceOf(buyer) >= amountIn, "Insufficient ACDC balance");
        require(slayerToken.balanceOf(seller) >= finalAmountOut, "Insufficient SLAY balance");

        IPoolManager.SwapParams memory swapParams = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(amountIn),
            sqrtPriceLimitX96: 0 
        });

        BalanceDelta swapDelta = poolManager.swap(poolKey, swapParams, "");

        acdcToken.transferFrom(buyer, seller, amountIn);
        slayerToken.transferFrom(seller, buyer, finalAmountOut); 
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }


}
