pragma solidity ^0.8.20;
// SPDX-License-Identifier: MIT
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {BaseHook} from "v4-periphery/BaseHook.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title ERC721OwnershipHook
contract ERC721OwnershipHook is BaseHook {    
   ClaimableERC721 public immutable discountNFT;

   uint immutable POOL_FEE;

   constructor(address _discountNFT , poolFee) {
    discountNFT = ClaimableERC721(_discountNFT);
    POOL_FEE = poolFee;
   }

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return
            Hooks.Calls({
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
        IPoolManager.PoolKey calldata,
        IPoolManager.SwapParams calldata
    ) external override returns (bytes4) {
        uint24 senderDiscount = discountContract.getDiscount(sender);
        uint24 newFee = POOL_FEE * (100 - senderDiscount) / 100;
        return (
            BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, newFee == 0 ? 0 : newFee | LPFeeLibrary.OVERRIDE_FEE_FLAG
        );
    }
}