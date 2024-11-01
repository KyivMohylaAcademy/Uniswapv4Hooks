
pragma solidity ^0.8.0;

import "./DiscountedNFT.sol"; 

contract UniswapHook {

    DiscountedNFT private nftContract;

    constructor(address _nftContract) {
        nftContract = DiscountedNFT(_nftContract);
    }

    function beforeSwap(address buyer, uint256 nftId) external view returns (uint256) {
        require(nftContract.ownerOf(nftId) == buyer, "Buyer does not own the NFT");

        uint8 discount = nftContract.getDiscount(nftId);
        
        uint256 discountedFee = calculateFeeWithDiscount(discount);
        return discountedFee;
    }

    function calculateFeeWithDiscount(uint8 discount) private pure returns (uint256) {
        uint256 baseFee = 100; 
        uint256 discountAmount = (baseFee * discount) / 100; 
        return baseFee - discountAmount; 
    }
}
