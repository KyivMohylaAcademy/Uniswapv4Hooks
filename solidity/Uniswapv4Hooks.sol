pragma solidity ^0.8.20;

import "./HomeworkNFT.sol";
import "./BuyerToken.sol";
import "./SellerToken.sol";

contract Uniswapv4Hooks {

   HomeworkNFT public immutable homeworkNft;
   BuyerToken public immutable buyerToken;
   SellerToken public immutable sellerToken;

   constructor(address _homeworkNft, address _buyerToken, address _sellerToken) {
    homeworkNft = HomeworkNFT(_homeworkNft);
    buyerToken = BuyerToken(_buyerToken);
    sellerToken = SellerToken(_sellerToken);
   }

    function _beforeSwap(address buyer, uint256 tokenId) private view returns (bool) {
       return buyer == homeworkNft.ownerOf(tokenId);
    }

    function swap(address buyer, address seller, uint256 tokenId, uint256 amount) external {
        require(_beforeSwap(buyer, tokenId), "HomeworkNFT must be owned by the buyer to be able to swap");

        uint8 discount = homeworkNft.getDiscount(tokenId);
        uint256 amountWithDiscount = amount * ((100 - discount) / 100);

        require(buyerToken.transferFrom(buyer, seller, amount), "Failed to transfer BuyerToken from buyer to seller");
        require(sellerToken.transferFrom(seller, buyer, amountWithDiscount), "Failed to transfer SellerToken from seller to buyer");
    }
}