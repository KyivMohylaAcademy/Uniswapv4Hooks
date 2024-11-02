pragma solidity ^0.8.0;

import "./../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ACDCToken is ERC20 {
    constructor() ERC20("ACDC token", "ACDC") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
}
