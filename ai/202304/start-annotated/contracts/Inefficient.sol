// Copyright (c) Peter Robinson 2023
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


contract Inefficient {
    // TODO significantly more efficient to have this as a map
    address[] public auth;

    // TODO need to add an initial admin in constructor, otherwise authorise will always fail.

    modifier ifAuth() {
        bool authorised = false;
        for (uint256 i = 0; i < auth.length; i++) {
            if (auth[i] == msg.sender) {
                authorised = true;
                break;
            }
        }
        require(authorised, "Not authorised");
        _;
    }

    function authorise(address _newAdmin) external ifAuth {
        addAuth(_newAdmin);
    }

    function addAuth(address _newAdmin) private {
        auth.push(_newAdmin);
    }

}