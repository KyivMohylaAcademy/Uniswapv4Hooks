// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";

contract LiquidityPool {
    using PoolIdLibrary for PoolKey;
    
    IPoolManager public immutable poolManager;
    
    struct PoolInfo {
        PoolKey poolKey;
        PoolId poolId;
    }
    
    mapping(address => mapping(address => PoolInfo)) public pools;
    
    constructor(IPoolManager _poolManager) {
        poolManager = _poolManager;
    }
    
    function createPool(
        address tokenA,
        address tokenB,
        address hookAddress,
        uint24 swapFee
    ) external returns (PoolKey memory poolKey, PoolId poolId) {
        // Ensure tokenA < tokenB for consistent pool key creation
        if (tokenA > tokenB) {
            (tokenA, tokenB) = (tokenB, tokenA);
        }
        
        poolKey = PoolKey({
            currency0: Currency.wrap(tokenA),
            currency1: Currency.wrap(tokenB),
            fee: swapFee,
            tickSpacing: 60, // Standard tick spacing
            hooks: IHooks(hookAddress)
        });
        
        poolId = poolKey.toId();
        
        pools[tokenA][tokenB] = PoolInfo({
            poolKey: poolKey,
            poolId: poolId
        });
        
        // Initialize the pool
        poolManager.initialize(poolKey, 79228162514264337593543950336);
        
        return (poolKey, poolId);
    }
    
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amount0,
        uint256 amount1
    ) external {
        PoolInfo memory poolInfo = pools[tokenA][tokenB];
        
        require(PoolId.unwrap(poolInfo.poolId) != bytes32(0), "Pool does not exist");
        
        // Transfer tokens to this contract
        IERC20(tokenA).transferFrom(msg.sender, address(this), amount0);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amount1);
        
        // Approve tokens to pool manager
        IERC20(tokenA).approve(address(poolManager), amount0);
        IERC20(tokenB).approve(address(poolManager), amount1);
        
        // Add liquidity
        poolManager.modifyLiquidity(poolInfo.poolKey, IPoolManager.ModifyLiquidityParams(
                -60,    // tickLower
                60,     // tickUpper
                int256(amount0),
                0 // liquidityDelta
            ), "");
    }
}
