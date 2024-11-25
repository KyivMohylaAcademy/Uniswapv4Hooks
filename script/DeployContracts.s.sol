// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {Constants} from "../base/Constants.sol";
import {HookMiner} from "../test/utils/HookMiner.sol";
import "forge-std/Script.sol";
import "../src/FalloutToken.sol";
import "../src/SilentHillToken.sol";
import "../src/DiscountNFT.sol";
import "../src/DiscountSwapHook.sol";
import "../src/LiquidityPool.sol";

contract DeployContracts is Script, Constants {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        address poolManagerAddress = vm.envAddress("POOL_MANAGER_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy Tokens
        FalloutToken flt = new FalloutToken(deployerAddress);
        SilentHillToken sht = new SilentHillToken(deployerAddress);
        console.log("FLT deployed to:", address(flt));
        console.log("SHT deployed to:", address(sht));
        
        // Deploy NFT
        DiscountNFT nft = new DiscountNFT();
        console.log("DiscountNFT deployed to:", address(nft));

        // Deploy Pool contract
        LiquidityPool liquidityPool = new LiquidityPool(IPoolManager(poolManagerAddress));
        console.log("LiquidityPool deployed to:", address(liquidityPool));
        
        // Deploy Hook

        // hook contracts must have specific flags encoded in the address
        uint160 flags = uint160(Hooks.BEFORE_SWAP_FLAG);

        // Mine a salt that will produce a hook address with the correct flags
        bytes memory constructorArgs = abi.encode(
            IPoolManager(poolManagerAddress),
            DiscountNFT(address(nft)),
            address(liquidityPool)
        );
        (address hookAddress, bytes32 salt) =
            HookMiner.find(CREATE2_DEPLOYER, flags, type(DiscountSwapHook).creationCode, constructorArgs);

            console.log(hookAddress);

        // Deploy the hook using CREATE2
        DiscountSwapHook hook = new DiscountSwapHook{salt: salt}(
            IPoolManager(poolManagerAddress),
            DiscountNFT(address(nft)),
            address(liquidityPool)
        );
        require(address(hook) == hookAddress, "HookDeployScript: hook address mismatch");

        console.log("DiscountSwapHook deployed to:", address(hook));
        
        // Create Pool
        liquidityPool.createPool(
            address(flt),
            address(sht),
            address(hook),
            0 // 0% fee
        );
        
        // Mint test NFT with 15% discount
        nft.mint(deployerAddress, 1, 15);
        
        vm.stopBroadcast();
    }
}
