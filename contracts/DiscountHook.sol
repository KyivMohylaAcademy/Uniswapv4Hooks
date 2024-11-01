// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DiscountNFT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DiscountHook {
    DiscountNFT public immutable discountNFT;
    IERC20 public immutable tokenA; // ACDC
    IERC20 public immutable tokenB; // Slayer
    address public immutable seller;
    
    uint256 public constant FEE_DENOMINATOR = 100;

    event Swap(
        address indexed user,
        uint256 amountIn,
        uint256 amountOut,
        bool isAtoB,
        uint256 appliedFee
    );

    constructor(address _discountNFT, address _tokenA, address _tokenB, address _seller) {
        require(_discountNFT != address(0), "Invalid NFT address");
        require(_tokenA != address(0), "Invalid tokenA address");
        require(_tokenB != address(0), "Invalid tokenB address");
        require(_seller != address(0), "Invalid seller address");
        discountNFT = DiscountNFT(_discountNFT);
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        seller = _seller;
    }

    function swap(uint256 amountIn, bool isAtoB) external returns (uint256) {
        require(amountIn > 0, "Amount must be greater than 0");
        
        if (isAtoB) { // ACDC -> Slayer
            // Отримуємо ACDC від buyer'а
            require(tokenA.transferFrom(msg.sender, address(this), amountIn), "Transfer A failed");
            
            // Відправляємо 85% ACDC seller'у (з урахуванням 15% знижки)
            uint256 sellerAmount = (amountIn * 85) / 100; // 25.5 ACDC
            require(tokenA.transfer(seller, sellerAmount), "Transfer to seller failed");
            
            // Відправляємо всі 50 Slayer buyer'у
            uint256 buyerAmount = (amountIn * 5) / 3; // 50 Slayer за 30 ACDC
            require(tokenB.transfer(msg.sender, buyerAmount), "Transfer B failed");
            
            emit Swap(msg.sender, amountIn, buyerAmount, isAtoB, 15);
            return buyerAmount;
        } else {
            revert("Only ACDC to Slayer swap supported");
        }
    }
} 