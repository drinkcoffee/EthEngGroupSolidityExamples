// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^8.9


abstract contract Admin {
    address public admin;

    modifier isOwner() {
        require(msg.sender == admin, "Not admin!");
        _;
    }

    constructor() {
        admin = msg.sender;
    }
} 