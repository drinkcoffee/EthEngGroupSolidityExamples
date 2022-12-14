// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "./interfaces/IAdmin.sol";

/**
 * Single owner
 */
abstract contract Admin is IAdmin {
    address public admin;

    // TODO: Intermediate: Upgrade issue: add dummy variable buffer: uint256[100] private __gap;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin!");
        _;
    }

    // TODO: Intermediate: Upgrade: This will not be called during upgrade as it is not callable by initialise. It will not execute in the context of the proxy contract.
    constructor() {
        admin = msg.sender;
    }

    function transferOwnership(address _newOwner) external onlyAdmin {
        admin = _newOwner;
    }
} 