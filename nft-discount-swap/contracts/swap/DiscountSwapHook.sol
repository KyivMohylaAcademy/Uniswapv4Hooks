pragma solidity ^0.8.20;

import "../nft/DiscountNFT.sol";
import "../tokens/ACDCToken.sol";
import "../tokens/SlayerToken.sol";

contract DiscountSwapHook {
    DiscountNFT public immutable nft;
    ACDCToken public immutable acdcToken;
    SlayerToken public immutable slayerToken;

    constructor(address _nft, address _acdcToken, address _slayerToken) {
        nft = DiscountNFT(_nft);
        acdcToken = ACDCToken(_acdcToken);
        slayerToken = SlayerToken(_slayerToken);
    }

    function _checkNFTOwnership(address buyer, uint256 tokenId) internal view returns (bool) {
        require(nft.ownerOf(tokenId) == buyer, "Buyer must own the NFT");
        return true;
    }

    function beforeSwap(address buyer, uint256 tokenId) external view returns (bool) {
        return _checkNFTOwnership(buyer, tokenId);
    }

    function executeSwap(
        address buyer,
        address seller,
        uint256 tokenId,
        uint256 amount
    ) external returns (bool) {
        require(_checkNFTOwnership(buyer, tokenId), "Before swap check failed");

        uint8 discount = nft.getDiscount(tokenId);
        uint256 fee = (amount * 2) / 100; // 2% base fee
        uint256 discountedFee = fee - (fee * discount / 100);

        uint256 finalAmount = amount - discountedFee;

        require(acdcToken.transferFrom(buyer, seller, amount), "ACDC transfer failed");
        require(slayerToken.transferFrom(seller, buyer, finalAmount), "Slayer transfer failed");

        return true;
    }
}