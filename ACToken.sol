// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ACToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("ACToken", "AC") {
        _mint(msg.sender, initialSupply);
    }
}
