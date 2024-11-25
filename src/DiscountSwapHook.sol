// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseHook} from "@uniswap/v4-periphery/src/base/hooks/BaseHook.sol";
import {BeforeSwapDelta} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import "./DiscountNFT.sol"; // Assuming the DiscountNFT contract is implemented here

contract DiscountSwapHook is BaseHook {
    DiscountNFT public immutable nft;
    mapping(address => bool) public authorizedPools;
    
    event DiscountApplied(address user, uint256 tokenId, uint8 discount, uint256 originalAmount, uint256 discountedAmount);
    
    constructor(
        IPoolManager poolManager, 
        DiscountNFT _nft, 
        address _authorizedPool
    ) BaseHook(poolManager) {
        nft = _nft;
        authorizedPools[_authorizedPool] = true;
    }
    
    function beforeSwap(
        address sender,
        IPoolManager.SwapParams calldata params,
        bytes calldata
    )
        external
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        require(authorizedPools[msg.sender], "Not authorized pool");
        
        // Initialize the BeforeSwapDelta variable
        BeforeSwapDelta newDelta = BeforeSwapDelta.wrap(0);
        uint24 feeAdjustment = 0;
        
        // Check if sender has NFTs and apply discount if any
        uint256 balance = nft.balanceOf(sender);
        if (balance > 0) {
            // Retrieve the first token owned by the sender (you need to adjust this for production use)
            uint256 tokenId = nft.tokenOfOwnerByIndex(sender, 0);
            uint8 discount = nft.getDiscount(tokenId);
            
            if (discount > 0) {
                // Apply the discount to the swap amount
                uint256 discountedAmount = uint256(params.amountSpecified) - 
                    ((uint256(params.amountSpecified) * discount) / 100);
                
                // Log the discount applied event
                emit DiscountApplied(
                    sender,
                    tokenId,
                    discount,
                    uint256(params.amountSpecified),
                    discountedAmount
                );
                
                // Update the delta with the discounted amount
                // Wrap the calculated delta into BeforeSwapDelta type
                newDelta = BeforeSwapDelta.wrap(
                    int256(discountedAmount) - int256(params.amountSpecified)
                );
            }
        }
        
        // Return the values as required by the base interface
        return (BaseHook.beforeSwap.selector, newDelta, feeAdjustment);
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
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
}
