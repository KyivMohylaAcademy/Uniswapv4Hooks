pragma solidity ^0.8.26;

import "./../lib/forge-std/src/Test.sol";
import {IPoolManager} from "./../lib/uniswap-v4-core/src/interfaces/IPoolManager.sol";
import {PoolManager} from "./../lib/uniswap-v4-core/src/PoolManager.sol";
import {Deployers} from "./../lib/uniswap-v4-core/test/utils/Deployers.sol";
import {PoolSwapTest} from "./../lib/uniswap-v4-core/src/test/PoolSwapTest.sol";
import {PoolKey} from "./../lib/uniswap-v4-core/src/types/PoolKey.sol";
import {Currency} from "./../lib/uniswap-v4-core/src/types/Currency.sol";
import {TickMath} from "./../lib/uniswap-v4-core/src/libraries/TickMath.sol";
import {IHooks} from "./../lib/uniswap-v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "./../lib/uniswap-v4-core/src/libraries/Hooks.sol";   


import "./../src/Discount.sol"; 
import "./../src/ACDCToken.sol"; 
import "./../src/SlayerToken.sol";
import "./../src/DiscountSwapHook.sol";
import {HookMiner} from "./../test/utils/HookMiner.sol";

contract SwapTest is Test, Deployers {
    DiscountERC721 public discount; 
    ACDCToken public acdcToken;
    SlayerToken public slayerToken;
    DiscountSwapHook public hook;

    address public buyer;
    address public seller;

    uint24 constant FEE = 3000;
    int24 constant TICK_SPACING = 60;
    uint160 constant SQRT_RATIO_1_1 = 79228162514264337593543950336;

    function deployCreate2(bytes memory creationCode, bytes32 salt) internal returns (address deployed) {
        assembly {
            deployed := create2(0, add(creationCode, 0x20), mload(creationCode), salt)
        }
        require(deployed != address(0), "Deploy failed");
    }


    function setUp() public {
        deployFreshManagerAndRouters();
        swapRouter = new PoolSwapTest(IPoolManager(address(manager)));

        buyer = makeAddr("buyer");
        seller = makeAddr("seller");

        discount = new DiscountERC721();
        acdcToken = new ACDCToken();
        slayerToken = new SlayerToken();

        uint160 flags = uint160(Hooks.BEFORE_SWAP_FLAG | Hooks.BEFORE_SWAP_RETURNS_DELTA_FLAG);
        (address hookAddress, bytes32 salt) = HookMiner.find(
            address(this),
            flags,
            type(DiscountSwapHook).creationCode,
            abi.encode(address(manager))
        );

        hook = new DiscountSwapHook{salt: salt}(IPoolManager(address(manager)), IDiscount(address(discount)));
    
        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(address(acdcToken)),
            currency1: Currency.wrap(address(slayerToken)),
            fee: FEE,
            tickSpacing: TICK_SPACING,
            hooks: IHooks(address(hook))
        });

        manager.initialize(poolKey, SQRT_RATIO_1_1);

        discount.mintDiscountNFT(buyer, 15);
        
        vm.startPrank(address(this));
        acdcToken.transfer(buyer, 30 * 1e18);
        slayerToken.transfer(seller, 50 * 1e18);
        vm.stopPrank();

        vm.startPrank(buyer);
        acdcToken.approve(address(manager), type(uint256).max);
        acdcToken.approve(address(swapRouter), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(seller);
        slayerToken.approve(address(manager), type(uint256).max);
        slayerToken.approve(address(swapRouter), type(uint256).max);
        vm.stopPrank();
    }


    function testDiscountedSwap() public {
        uint256 buyerInitialACDC = acdcToken.balanceOf(buyer);
        uint256 buyerInitialSlayer = slayerToken.balanceOf(buyer);
        uint256 sellerInitialACDC = acdcToken.balanceOf(seller);
        uint256 sellerInitialSlayer = slayerToken.balanceOf(seller);

        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(address(acdcToken)),
            currency1: Currency.wrap(address(slayerToken)),
            fee: FEE,
            tickSpacing: TICK_SPACING,
            hooks: IHooks(address(hook))
        });

        vm.startPrank(buyer);
        
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: 30 * 1e18,
            sqrtPriceLimitX96: MIN_PRICE_LIMIT
        });

        swapRouter.swap(
            poolKey,
            params,
            PoolSwapTest.TestSettings({
                takeClaims: true,
                settleUsingBurn: false
            }),
            new bytes(0)
        );
        
        vm.stopPrank();
    }

}