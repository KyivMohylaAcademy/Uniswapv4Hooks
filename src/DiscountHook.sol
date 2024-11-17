// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/types/BeforeSwapDelta.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import "./DiscountNFT.sol";

contract DiscountHook is BaseHook {
    DiscountNFT public discountNFT;

    uint24 public constant DEFAULT_FEE = 3000;

    constructor(IPoolManager _manager, address _discountNFT)
        BaseHook(_manager)
    {
        discountNFT = DiscountNFT(_discountNFT);
    }

    /**
     * @notice Returns the hook permissions required for this contract.
     * @dev Specifies which actions the hook is allowed to perform in the Uniswap V4 lifecycle.
     * @return A Hooks.Permissions struct defining allowed operations.
     */
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
                beforeSwap: true, // Hook enabled for beforeSwap
                afterSwap: false,
                beforeDonate: false,
                afterDonate: false,
                beforeSwapReturnDelta: false,
                afterSwapReturnDelta: false,
                afterAddLiquidityReturnDelta: false,
                afterRemoveLiquidityReturnDelta: false
            });
    }

    /**
     * @notice Hook triggered before a swap to calculate the dynamic fee based on DiscountNFT ownership.
     * @param sender The address initiating the swap.
     * @param key The pool key of the swap.
     * @param params Parameters for the swap (amounts, directions, etc.).
     * @param hookData Additional data passed to the hook.
     * @return The hook selector, a BeforeSwapDelta struct, and the calculated fee.
     */
    function beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    )
        external
        view
        override
        onlyPoolManager
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        if (discountNFT.balanceOf(sender) == 0) {
            return (
                this.beforeSwap.selector,
                BeforeSwapDeltaLibrary.ZERO_DELTA,
                DEFAULT_FEE
            );
        }

        uint8 discount = discountNFT.getDiscount(sender);

        uint24 newFee = uint24(DEFAULT_FEE * (100 - discount) / 100);

        return (
            this.beforeSwap.selector,
            BeforeSwapDeltaLibrary.ZERO_DELTA,
            newFee
        );
    }
}
