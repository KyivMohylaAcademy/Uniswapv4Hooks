// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenB is ERC20 {
    constructor() ERC20("Slayer Token", "SLYR") {
        _mint(msg.sender, 1000 * 10**decimals()); // Mint 1000 tokens to the contract deployer
    }
}
