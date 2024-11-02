pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./DiscountSwapHook.sol";


contract DiscountERC721 is ERC721, Ownable, IDiscount {
    int256 public discount;
    uint256 public nextTokenId;

    constructor() ERC721("Discount", "DSCT") Ownable(msg.sender){}

    function setDiscount(int256 _discount) public onlyOwner {
        require(0 <= _discount && _discount <= 20, "discount should be in [0,20] range");
        discount = _discount;
    }

    function mintDiscountNFT(address newOwner, int256 _discount) public onlyOwner {
        _mint(newOwner, nextTokenId);
        nextTokenId++;

        setDiscount(_discount);

        transferOwnership(newOwner);
    }


    function getDiscount(address caller) external view override returns (int256){
        if (caller == owner() ){
            return discount;
        }

        return 0;
    }
}