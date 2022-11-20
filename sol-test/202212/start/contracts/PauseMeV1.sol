// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "./Admin.sol";

/**
 * Pause the non-configuration flows of the contract
 */
abstract contract PauseMeV1 is Admin {
    event Paused(address account);
    event Unpaused(address account);

    bool private notPaused;


    modifier whenNotPaused() {
        require(notPaused, "Paused!");
        _;
    }

    function pause() external {
        notPaused = true;
    }

    function unpause() external {
        notPaused = false;
        emit Unpaused(msg.sender);
    }
}