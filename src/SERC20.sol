// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solmate/src/tokens/ERC20.sol";
import "solmate/src/auth/Owned.sol";

contract SERC20 is ERC20, Owned {
    constructor() ERC20("SellerERC20", "SERC20", 18) Owned(msg.sender) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}