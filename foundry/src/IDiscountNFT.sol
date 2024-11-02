// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDiscountNFT {
    function getDiscount(uint256 tokenId) external view returns (uint8);
    function ownerOf(uint256 tokenId) external view returns (address);
    function exists(uint256 tokenId) external view returns (bool);
}
