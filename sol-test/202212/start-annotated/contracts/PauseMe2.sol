// SPDX-License-Identifier: MIT
// Peter Robinson

pragma solidity ^0.8.5;


/**
 * Pause the non-configuration flows of the contract
 */
abstract contract PauseMe2 is PauseMe {
    event Paused(address account);
    event Unpaused(address account);

    address public pauser;

    modifier onlyPauser() {
        require(msg.sender == pauser, "Not pauser!");
        _;
    }


    constructor(address _pauser) {
        pauser = _pauser;
    }


//TODO switch logic
// TODO restrict who can pause / unpause
// TODO forgotten to emit event
    function pause() external onlyPauser {
        notPaused = false;
        emit Paused(msg.sender);
    }
    function unpause() external onlyPauser {
        notPaused = true;
        emit Unpaused(msg.sender);
    }
}