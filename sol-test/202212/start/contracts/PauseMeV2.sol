// SPDX-License-Identifier: MIT
// Peter Robinson
pragma solidity ^0.8.11;

import "./Admin.sol";

/**
 * Pause the non-configuration flows of the contract
 */
abstract contract PauseMeV2 is Admin {
    event Paused(address account);
    event Unpaused(address account);

    bool private notPaused;

    address public pauser;


    modifier whenNotPaused() {
        require(notPaused, "Paused!");
        _;
    }

    modifier onlyPauser() {
        require(msg.sender == pauser, "Not pauser!");
        _;
    }

    constructor(address _pauser) {
        pauser = _pauser;
    }


    function pause() external onlyPauser {
        notPaused = false;
    }
    function unpause() external onlyPauser {
        notPaused = true;
        emit Unpaused(msg.sender);
    }
}