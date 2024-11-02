// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract CatcoinToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Catcoin", "Catcoin") {
        _mint(msg.sender, initialSupply);
    }
}