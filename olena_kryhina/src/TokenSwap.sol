// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/DiscountNFT.sol";

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {CurrencyLibrary, Currency} from "v4-core/types/Currency.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {BalanceDeltaLibrary, BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {BeforeSwapDeltaLibrary, BeforeSwapDelta} from "v4-core/types/BeforeSwapDelta.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";


contract TokenSwap is BaseHook {

    IPoolManager public immutable manager;
    DiscountNFT public discountNFT;

    constructor(IPoolManager _manager) BaseHook(_manager) {
        manager = _manager;
        discountNFT = new DiscountNFT();
    }

    function beforeSwap(address buyer, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata)
    external returns (int256 amountIn, BeforeSwapDelta delta, uint24)  {
        
        uint256 buyerNFTBalance = discountNFT.balanceOf(buyer);

        if (buyerNFTBalance > 0) {
            uint256 discount = discountNFT.getDiscount(buyer);
            int256 specifiedAmount = params.amountSpecified;
            int256 discountAmount = (specifiedAmount / 100) * int256(discount);
            int256 adjustedAmount = specifiedAmount - discountAmount;

            delta = BeforeSwapDelta.from(-discountAmount, 0);
            amountIn = params.amountSpecified;

            return (amountIn, delta, 0);
        }

        return (amountIn, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    function getHookData(address buyer, address seller) public pure returns (bytes memory) {
        return abi.encode(buyer, seller);
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory){
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
     