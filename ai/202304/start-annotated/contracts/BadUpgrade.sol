// Copyright (c) Peter Robinson 2023
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


abstract contract BadUpgrade {
    bool private notPaused;

    // TODO: Likely to be upgradable as: abstract, no constructor, initialize
    // TODO: Add in uint256 private __gap[100] 


    event Paused(address account);
    event Unpaused(address account);

    modifier whenNotPaused() {
        require(notPaused, "Paused!");
        _;
    }

    function initialize() external virtual {
        notPaused = true;
    }

    function paused() external view returns (bool) {
        return !notPaused;
    }

    function pause() external {
        notPaused = false;
        emit Paused(msg.sender);
    }

    function unpause() external {
        notPaused = true;
        emit Unpaused(msg.sender);
    }

}