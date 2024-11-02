// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract ACDCToken is ERC20, Ownable  {
    constructor() ERC20("ACDC Token", "ACDC") Ownable(msg.sender) {
        _mint(msg.sender, 1000 * 10**decimals());
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
