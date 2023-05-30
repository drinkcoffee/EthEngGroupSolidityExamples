// Copyright (c) Peter Robinson 2023
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


contract StuffC {
    bool private stuff1;

    event Stuff1(address account);
    event Stuff2(address account);

    modifier stuff3() {
        require(stuff1, "Paused!");
        _;
    }

    function stuff4() external view returns (bool) {
        return !stuff1;
    }

    function stuff7() external {
        stuff1 = true;
        emit Stuff1(msg.sender);
    }

    function stuff9() external {
        stuff1 = false;
        emit Stuff2(msg.sender);
    }

}