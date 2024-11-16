// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "./BuyerToken.sol";
import "./SellerToken.sol";
import "./DiscountCouponNFT.sol";

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {BalanceDeltaLibrary, BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import "v4-core/types/BeforeSwapDelta.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {SafeCast} from "v4-core/libraries/SafeCast.sol";
import {LPFeeLibrary} from "v4-periphery/lib/v4-core/src/libraries/LPFeeLibrary.sol";

import {console} from "forge-std/console.sol";

using SafeCast for uint256;

contract DiscountSwapHook is BaseHook {
    DiscountCouponNFT public couponContract;

    constructor(
        IPoolManager _manager
    ) BaseHook(_manager) {
        couponContract = new DiscountCouponNFT();
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

    function beforeSwap(
        address buyer,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata swapParams,
        bytes calldata
    )
        external
        override
        onlyPoolManager
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        if (swapParams.amountSpecified < 0 && couponContract.balanceOf(buyer) >= 1) {
            console.log("Has coupon!");

            uint256 couponId = couponContract.getCouponId(buyer);
            uint24 discountAmount = (LPFeeLibrary.MAX_LP_FEE / 100) * couponContract.discountOf(couponId);
            return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, discountAmount | LPFeeLibrary.OVERRIDE_FEE_FLAG);
        }
        else {
            console.log("No coupon :(");
            return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
        }
    }

}