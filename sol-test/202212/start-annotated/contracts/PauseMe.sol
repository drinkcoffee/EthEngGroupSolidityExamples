// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.9;

import "./Admin.sol"

/**
 * Pause the non-configuration flows of the contract
 */
abstract contract PauseMe is Admin {
    event Paused(address account);
    event Unpaused(address account);

    // TODO: Should be public so the pause state can be determined off-chain
    bool private notPaused;

    modifier whenNotPaused() {
        require(notPaused, "Paused!");
        _;
    }

    function pause() external onlyAdmin {
        // TODO restrict who can pause / unpause
        //TODO switch logic: should be notPaused = false, or paused = true
        notPaused = true;
        // TODO forgotten to emit event indicating contract now paused.
    }

    function unpause() external onlyAdmin {
        // TODO restrict who can pause / unpause
        //TODO switch logic: should be notPaused = true, or paused = false
        notPaused = false;
        emit Unpaused(msg.sender);
    }
}