// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {PoolManager} from "v4-core/src/PoolManager.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolModifyLiquidityTest} from "v4-core/src/test/PoolModifyLiquidityTest.sol";
import {PoolSwapTest} from "v4-core/src/test/PoolSwapTest.sol";
import {PoolDonateTest} from "v4-core/src/test/PoolDonateTest.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {BERC20} from "../src/BERC20.sol";
import {SERC20} from "../src/SERC20.sol";
import {Discount} from "../src/Discount.sol";
import {Constants} from "v4-core/src/../test/utils/Constants.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {CurrencyLibrary, Currency} from "v4-core/src/types/Currency.sol";
import {Counter} from "../src/Counter.sol";
import {HookMiner} from "../test/utils/HookMiner.sol";
import {IPositionManager} from "v4-periphery/src/interfaces/IPositionManager.sol";
import {PositionManager} from "v4-periphery/src/PositionManager.sol";
import {EasyPosm} from "../test/utils/EasyPosm.sol";
import {IAllowanceTransfer} from "permit2/src/interfaces/IAllowanceTransfer.sol";
import {DeployPermit2} from "../test/utils/forks/DeployPermit2.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IPositionDescriptor} from "v4-periphery/src/interfaces/IPositionDescriptor.sol";
import {console} from "forge-std/console.sol";

/// @notice Forge script for deploying v4 & hooks to **anvil**
/// @dev This script only works on an anvil RPC because v4 exceeds bytecode limits
contract CounterScript is Script, DeployPermit2 {
    using EasyPosm for IPositionManager;

    address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);

    function setUp() public {}

    function run() public {
        vm.broadcast();
        IPoolManager manager = deployPoolManager();

        // hook contracts must have specific flags encoded in the address
        uint160 permissions = uint160(Hooks.BEFORE_SWAP_FLAG);

        // Mine a salt that will produce a hook address with the correct permissions
        (address hookAddress, bytes32 salt) =
            HookMiner.find(CREATE2_DEPLOYER, permissions, type(Counter).creationCode, abi.encode(address(manager)));

        // ----------------------------- //
        // Deploy the hook using CREATE2 //
        // ----------------------------- //
        vm.broadcast();
        Counter counter = new Counter{salt: salt}(manager);
        require(address(counter) == hookAddress, "CounterScript: hook address mismatch");

        // Additional helpers for interacting with the pool
        vm.startBroadcast();
        IPositionManager posm = deployPosm(manager);
        (PoolModifyLiquidityTest lpRouter, PoolSwapTest swapRouter,) = deployRouters(manager);
        vm.stopBroadcast();

        // test the lifecycle (create pool, add liquidity, swap)
        vm.startBroadcast();
        testLifecycle(manager, address(counter), posm, lpRouter, swapRouter);
        vm.stopBroadcast();
    }

    // -----------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------
    function deployPoolManager() internal returns (IPoolManager) {
        return IPoolManager(address(new PoolManager()));
    }

    function deployRouters(IPoolManager manager)
        internal
        returns (PoolModifyLiquidityTest lpRouter, PoolSwapTest swapRouter, PoolDonateTest donateRouter)
    {
        lpRouter = new PoolModifyLiquidityTest(manager);
        swapRouter = new PoolSwapTest(manager);
        donateRouter = new PoolDonateTest(manager);
    }

    function deployPosm(IPoolManager poolManager) public returns (IPositionManager) {
        anvilPermit2();
        return IPositionManager(new PositionManager(poolManager, permit2, 300_000, IPositionDescriptor(address(0))));
    }

    function approvePosmCurrency(IPositionManager posm, Currency currency) internal {
        // Because POSM uses permit2, we must execute 2 permits/approvals.
        // 1. First, the caller must approve permit2 on the token.
        IERC20(Currency.unwrap(currency)).approve(address(permit2), type(uint256).max);
        // 2. Then, the caller must approve POSM as a spender of permit2
        permit2.approve(Currency.unwrap(currency), address(posm), type(uint160).max, type(uint48).max);
    }

    function deployTokens() internal returns (BERC20 token0, SERC20 token1) {
        token0 = new BERC20();
        token1 = new SERC20();
    }

    function testLifecycle(
        IPoolManager manager,
        address hook,
        IPositionManager posm,
        PoolModifyLiquidityTest lpRouter,
        PoolSwapTest swapRouter
    ) internal {
        (BERC20 token0, SERC20 token1) = deployTokens();
        token0.mint(msg.sender, 100_000 ether);
        token1.mint(msg.sender, 100_000 ether);
        Discount discount = Counter(hook).discountContract();
        discount.mint(msg.sender, 5);

        bytes memory ZERO_BYTES = new bytes(0);

        // initialize the pool
        int24 tickSpacing = 60;
        PoolKey memory poolKey =
            PoolKey(Currency.wrap(address(token0)), Currency.wrap(address(token1)), 3000, tickSpacing, IHooks(hook));
        manager.initialize(poolKey, Constants.SQRT_PRICE_1_1);

        // approve the tokens to the routers
        token0.approve(address(lpRouter), type(uint256).max);
        token1.approve(address(lpRouter), type(uint256).max);
        token0.approve(address(swapRouter), type(uint256).max);
        token1.approve(address(swapRouter), type(uint256).max);

        approvePosmCurrency(posm, Currency.wrap(address(token0)));
        approvePosmCurrency(posm, Currency.wrap(address(token1)));

        // add full range liquidity to the pool
        lpRouter.modifyLiquidity(
            poolKey,
            IPoolManager.ModifyLiquidityParams(
                TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing), 100 ether, 0
            ),
            ZERO_BYTES
        );

        posm.mint(
            poolKey,
            TickMath.minUsableTick(tickSpacing),
            TickMath.maxUsableTick(tickSpacing),
            100e18,
            10_000e18,
            10_000e18,
            msg.sender,
            block.timestamp + 300,
            ZERO_BYTES
        );

        // swap some tokens
        bool zeroForOne = false;
        int256 amountSpecified = 1 ether;
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOne,
            amountSpecified: amountSpecified,
            sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1 // unlimited impact
        });
        PoolSwapTest.TestSettings memory testSettings =
            PoolSwapTest.TestSettings({takeClaims: false, settleUsingBurn: false});
        swapRouter.swap(poolKey, params, testSettings, ZERO_BYTES);
	uint256 serc20Balance = token1.balanceOf(msg.sender);
	uint256 berc20Balance = token0.balanceOf(msg.sender);
	console.log("SERC20 balance: %s BERC20 balance: %s", serc20Balance, berc20Balance);
    }
}