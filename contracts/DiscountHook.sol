// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IHook {
    function beforeSwap(address sender, bytes calldata data) external;
}

import "./DiscountNFT.sol";

contract DiscountHook is IHook {
    DiscountNFT public nftContract;

    constructor(address _nftContract) {
        nftContract = DiscountNFT(_nftContract);
    }

    function beforeSwap(address sender, bytes calldata data) external override {
        // Перевіряємо, чи має sender NFT з discount
        uint256 maxDiscount = 0;
        uint256 balance = nftContract.balanceOf(sender);
        require(balance > 0, "Sender does not own any NFTs");

        for (uint256 i = 1; i <= nftContract.tokenCounter(); i++) {
            if (nftContract.ownerOf(i) == sender) {
                uint8 discount = nftContract.getDiscount(i);
                if (discount > maxDiscount) {
                    maxDiscount = discount;
                }
            }
        }

        emit DiscountApplied(sender, uint8(maxDiscount));
    }

    event DiscountApplied(address sender, uint8 discount);
}