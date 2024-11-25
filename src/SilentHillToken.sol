// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SilentHillToken is ERC20 {
    constructor(address initialHolder) ERC20("SILENT-HILL", "SHT") {
        _mint(initialHolder, 1000000 * 10**decimals());
    }
}
