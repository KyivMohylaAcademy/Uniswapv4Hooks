// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@uniswap/v4-periphery/contracts/base/hooks/BaseHook.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/PoolKey.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/contracts/libraries/BeforeSwapDeltaLibrary.sol";
import "./DiscountNFT.sol";

contract TokenSwapHook is BaseHook {
    IPoolManager public immutable manager;
    DiscountNFT public immutable discountNFT;

    constructor(IPoolManager _manager, DiscountNFT _discountNFT) BaseHook(_manager) {
        manager = _manager;
        discountNFT = _discountNFT;
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeModifyPosition: false,
            afterModifyPosition: false,
            beforeSwap: true,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false
        });
    }

    function beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata data
    ) external override returns (int256 amount0Delta, BeforeSwapDelta delta, uint24 feeOverride) {
        if (discountNFT.balanceOf(sender) > 0) {
            uint8 discount = discountNFT.getDiscount(sender);
            uint24 standardFee = key.fee;
            uint24 discountedFee = standardFee - uint24((standardFee * discount) / 100);
            return (0, BeforeSwapDeltaLibrary.ZERO_DELTA, discountedFee);
        }
        return (0, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }
}