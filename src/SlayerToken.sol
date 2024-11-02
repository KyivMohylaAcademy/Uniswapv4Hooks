pragma solidity ^0.8.0;

import "./../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract SlayerToken is ERC20 {
    constructor() ERC20("Slayer token", "SLR") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
}
