// Copyright (c) Peter Robinson 2023
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


/**
 * Pause capability to be integrated into other contracts.
 * Initially, starts contract in not paused state.
 */
contract Pause {
    // True when contract not paused.
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
        notPaused = true;
        emit Paused(msg.sender);
    }

    function unpause() external {
        notPaused = false;
        emit Unpaused(msg.sender);
    }

}