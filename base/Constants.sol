// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IAllowanceTransfer} from "permit2/src/interfaces/IAllowanceTransfer.sol";

/// @notice Shared constants used in scripts
contract Constants {
    address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);

    /// @dev populated with default anvil addresses
    IPoolManager constant POOLMANAGER = IPoolManager(address(0x8C4BcBE6b9eF47855f97E675296FA3F6fafa5F1A));
}
