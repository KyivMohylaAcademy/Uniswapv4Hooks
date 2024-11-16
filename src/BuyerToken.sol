// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract BuyerToken is ERC20, Ownable {

    constructor() ERC20("BuyerToken", "BTKN") Ownable(msg.sender) {}

    function mint(address account, uint256 amount) public onlyOwner returns (uint256) {
        _mint(account, amount);
        return balanceOf(account);
    }
}