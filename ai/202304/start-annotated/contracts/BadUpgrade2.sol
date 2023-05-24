// Copyright (c) Peter Robinson 2023
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

// TODO should import from contracts-upgradeable and import AccessControlUpgradable.sol
import "@openzeppelin/contracts/access/AccessControl.sol";


// TODO should import from AccessControlUpgradable
abstract contract BadUpgrade2 is AccessControl {
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

    function pause() internal {
        notPaused = false;
        emit Paused(msg.sender);
    }

    function unpause() internal {
        notPaused = true;
        emit Unpaused(msg.sender);
    }

}