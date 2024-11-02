pragma solidity ^0.8.13;

import "./../lib/forge-std/src/Test.sol";

import {BaseHook} from "./../lib/uniswap-v4-periphery/src/base/hooks/BaseHook.sol";
import {Hooks} from "./../lib/uniswap-v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "./../lib/uniswap-v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "./../lib/uniswap-v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "./../lib/uniswap-v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "./../lib/uniswap-v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, toBeforeSwapDelta} from "./../lib/uniswap-v4-core/src/types/BeforeSwapDelta.sol";


interface IDiscount {
    function getDiscount(address user) external view returns (int256);
}

contract DiscountSwapHook is BaseHook {
    using PoolIdLibrary for PoolKey;

    IDiscount public discount;

    constructor(IPoolManager _poolManager, IDiscount _discount) BaseHook(_poolManager) {
        discount = _discount;
    }
    

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
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
            beforeSwapReturnDelta: true,
            afterSwapReturnDelta: false, 
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }


  function beforeSwap(
        address caller,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata
    ) external override returns (bytes4, BeforeSwapDelta, uint24) {
        console.log("before SWAP");
        int256 discountPercent = discount.getDiscount(caller);
        
        int256 discountedAmount = (params.amountSpecified * (int256(100) - int256(discountPercent))) / 100;
    
        return (BaseHook.beforeSwap.selector, toBeforeSwapDelta(int128(discountedAmount), 0), 0);
    }
}