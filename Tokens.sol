pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract ClaimableERC201 is ERC20{
    constructor() ERC20("Ko1ERC20", "Ko1ERC20") {}
    
    function claim() external {
        _mint(msg.sender, 1000e18);
    }
}

contract ClaimableERC202 is ERC20{
    constructor() ERC20("Ko2ERC20", "Ko2ERC20") {}
    
    function claim() external {
        _mint(msg.sender, 1000e18);
    }
}

struct ERC721Metadata {
    uint256 discount;
}

contract ClaimableERC721 is ERC721{
    mapping(uint => ERC721Metadata) private metadatas;
    mapping(address => uint[]) private discountTokens;
    uint _totalCount = 0;
    constructor() ERC721("KoERC721", "KoERC721") {}
    
    function claim(uint discount) external {
        require(discount <= 20, "discount should be smaller the 20");
        uint newId = _totalCount++;
        discountTokens[msg.sender].push(newId);
        metadatas[newId] = ERC721Metadata(discount);
        _mint(msg.sender, newId);
    }

    function getDiscout(address owner) public view returns(uint){
        uint[] memory discounts = discountTokens[owner];
        if(discounts.length == 0) return 0;
        return metadatas[discounts[0]].discount;
    }
}