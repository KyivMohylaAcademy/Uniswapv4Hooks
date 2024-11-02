// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseHook} from 'v4-periphery/src/base/hooks/BaseHook.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {LPFeeLibrary} from "v4-core/libraries/LPFeeLibrary.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/types/BeforeSwapDelta.sol";

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";

import {Hooks} from "v4-core/libraries/Hooks.sol";

import "./DiscountNFT.sol"; 

contract UniswapHook is BaseHook {
    
    DiscountNFT private discountNFT;

    constructor(
        IPoolManager _manager,
        address _discountNFT
    ) BaseHook(_manager) {
        discountNFT = DiscountNFT(_discountNFT);
    }

    function getHookPermissions()
        public
        pure
        override
        returns (Hooks.Permissions memory)
    {
        return
            Hooks.Permissions({
                beforeInitialize: false,
                afterInitialize: false,
                beforeAddLiquidity: false,
                beforeRemoveLiquidity: false,
                afterAddLiquidity: false,
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
        address sender,
        PoolKey calldata key, 
        IPoolManager.SwapParams calldata params, 
        bytes calldata hookData
    )
        external
        view
        override onlyPoolManager
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        if (discountNFT.balanceOf(sender) == 0) {
            return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
        }

        uint8 discount = discountNFT.getDiscount(sender);
        uint24 newFee = uint24(discount * 10000 | LPFeeLibrary.OVERRIDE_FEE_FLAG);
        return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, newFee);
    }
}
