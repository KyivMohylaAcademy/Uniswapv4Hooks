// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPoolManager} from "lib/v4-periphery/lib/v4-core/src/interfaces/IPoolManager.sol";

struct Currency {
    address tokenAddress;
}

struct PoolKey {
    Currency currency0;
    Currency currency1;
    uint24 fee;
    int24 tickSpacing;
    address hooks;
}

struct BalanceDelta {
    int128 amount0;
    int128 amount1;
}

struct SwapParams {
    bool zeroForOne;
    int256 amountSpecified;
    uint160 sqrtPriceLimitX96;
}

/// @dev Not working properly
contract MockPoolManager is IPoolManager {
    bool public unlocked = false;

    mapping(address => uint256) public tokenBalances;

    function unlock(bytes calldata data) external override returns (bytes memory) {
        unlocked = true;
        return data; 
    }

    function swap(PoolKey memory key, SwapParams memory params, bytes calldata hookData)
        external override
        returns (BalanceDelta memory swapDelta)
    {
        swapDelta = BalanceDelta({
            amount0: int128(params.amountSpecified),
            amount1: int128(params.amountSpecified) / 2
        });
    }

    function initialize(PoolKey memory key, uint160 sqrtPriceX96) external override returns (int24 tick) {
        tick = 0; 
    }

    function modifyLiquidity(PoolKey memory, ModifyLiquidityParams memory, bytes calldata) external pure override 
        returns (BalanceDelta memory, BalanceDelta memory) {
            return (BalanceDelta(0, 0), BalanceDelta(0, 0));
    }

    function donate(PoolKey memory, uint256, uint256, bytes calldata) external pure override 
        returns (BalanceDelta memory) {
            return BalanceDelta(0, 0);
    }

    function sync(Currency memory) external pure override {}
    function take(Currency memory, address, uint256) external pure override {}
    function settle() external payable override returns (uint256) { return 0; }
    function settleFor(address) external payable override returns (uint256) { return 0; }
    function clear(Currency memory, uint256) external pure override {}
    function mint(address, uint256, uint256) external pure override {}
    function burn(address, uint256, uint256) external pure override {}
    function updateDynamicLPFee(PoolKey memory, uint24) external pure override {}
}