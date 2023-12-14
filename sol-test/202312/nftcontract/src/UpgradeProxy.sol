// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeProxy.sol";


contract UpgradeProxy is TransparentUpgradeProxy {
    constructor(address _logic, address initialOwner) {
        bytes memory data = bytes();
        super(_logic, initialOwner, data);
    }

    function __proxyAdmin() external view {
        return _proxyAdmin();
    }
}
