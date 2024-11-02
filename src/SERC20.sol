// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solmate/src/tokens/ERC20.sol";
import {Ownable} from "v4-core/lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract SERC20 is ERC20, Ownable {
    constructor() ERC20("SellerERC20", "SERC20", 18) Ownable(msg.sender){}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}