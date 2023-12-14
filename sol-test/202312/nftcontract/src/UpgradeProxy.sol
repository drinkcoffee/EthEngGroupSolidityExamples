// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";


contract UpgradeProxy is TransparentUpgradeableProxy {
    constructor(address _logic, address initialOwner) TransparentUpgradeableProxy(_logic, initialOwner, bytes("")) {
    }
}
