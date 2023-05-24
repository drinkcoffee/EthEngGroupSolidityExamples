// Copyright (c) Peter Robinson 2023
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


contract BadLogicNoComments {
    bool private notPaused;

    event Paused(address account);
    event Unpaused(address account);

    modifier whenNotPaused() {
        require(notPaused, "Paused!");
        _;
    }

    function paused() external view returns (bool) {
        return !notPaused;
    }

    function pause() external {
        // TODO: Basic: Logic: switch logic: should be notPaused = false
        notPaused = true;
        emit Paused(msg.sender);
    }

    function unpause() external {
        // TODO: Basic: Logic: switch logic: should be notPaused = true
        notPaused = false;
        emit Unpaused(msg.sender);
    }

}