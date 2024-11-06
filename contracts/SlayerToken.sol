pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SlayerToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Slayer", "SLYR") {
        _mint(msg.sender, initialSupply);
    }
}
