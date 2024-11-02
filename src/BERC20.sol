pragma solidity ^0.8.13;

import "solmate/src/tokens/ERC20.sol";
import "solmate/src/auth/Owned.sol";

contract BERC20 is ERC20, Owned {
    constructor() ERC20("BuyerERC20", "BERC20", 18) Owned(msg.sender) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}