// Copyright (c) Peter Robinson 2023
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "./CoolNFT.sol";


contract UpgradeProxy is TransparentUpgradeableProxy {
    constructor(address _logic, address _initialOwner) 
        TransparentUpgradeableProxy(_logic, _initialOwner, 
            abi.encodeWithSelector(CoolNFT.initialize.selector, _initialOwner)) {
    }
}
