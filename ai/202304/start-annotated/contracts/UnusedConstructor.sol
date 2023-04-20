// Copyright (c) Peter Robinson 2023
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

abstract contract UnusedConstructorAdmin {
    address public admin;

    // TODO: Likely to be upgradable as included by UnusedConstrctor
    // TODO: Add in uint256 private __gap[100] 


    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin!");
        _;
    }

    // TODO: Likely to be upgradable as included by UnusedConstrctor
    // TODO: constructor will never be called.
    constructor() {
        admin = msg.sender;
    }

    function transferOwnership(address _newOwner) external onlyAdmin {
        admin = _newOwner;
    }
} 

abstract contract UnusedConstructor is UnusedConstructorAdmin {
    bool private notPaused;

    // TODO: Likely to be upgradable as: abstract, no constructor, initialize
    // TODO: Add in uint256 private __gap[100] 


    event Paused(address account);
    event Unpaused(address account);

    modifier whenNotPaused() {
        require(notPaused, "Paused!");
        _;
    }

    function initialize() internal virtual {
        notPaused = true;
    }

    function paused() external view returns (bool) {
        return !notPaused;
    }

    function pause() external onlyAdmin {
        notPaused = false;
        emit Paused(msg.sender);
    }

    function unpause() external onlyAdmin {
        notPaused = true;
        emit Unpaused(msg.sender);
    }

}