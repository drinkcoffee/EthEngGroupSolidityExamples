// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

/**
 * Single owner
 */
abstract contract Admin {
    address public admin;


    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin!");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function transferOwnership(address _newOwner) external onlyAdmin {
        admin = _newOwner;
    }
} 