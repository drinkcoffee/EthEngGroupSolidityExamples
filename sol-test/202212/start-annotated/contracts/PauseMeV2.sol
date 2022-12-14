// SPDX-License-Identifier: MIT
// Peter Robinson
pragma solidity ^0.8.11;

import "./PauseMeBase.sol";
import "./interfaces/IPauseMeV2.sol";
import "./Admin.sol";

/**
 * Pause the non-configuration flows of the contract
 */
abstract contract PauseMeV2 is Admin, PauseMeBase { //}, IPauseMeV2 {
    address public pauser;

    // TODO: Intermediate: Upgrade issue: add dummy variable buffer: uint256[98] private __gap;

    modifier onlyPauser() {
        require(msg.sender == pauser, "Not pauser!");
        _;
    }

    constructor() {
        unpauseInternal();
        pauser = msg.sender;
    }

    function pause() external override onlyPauser {
        pauseInternal();
    }

    function unpause() external override onlyPauser {
        unpauseInternal();
    }

    function transferPauserRole(address _newPauser) external onlyAdmin {
        pauser = _newPauser;
    }
}