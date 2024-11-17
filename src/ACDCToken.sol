// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ACDCToken is ERC20, Ownable {
    constructor() ERC20("ACDC Token", "ACDC") Ownable(msg.sender) {}

    /**
     * @dev Mints `amount` tokens to the `to` address.
     * Can only be called by the contract owner.
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
