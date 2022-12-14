// SPDX-License-Identifier: MIT
// Peter Robinson
pragma solidity ^0.8.11;

import "./PauseMeBase.sol";
import "./interfaces/IPauseMeV2.sol";
import "./Admin.sol";

/**
 * Pause the non-configuration flows of the contract
 */
abstract contract PauseMeV2 is Admin, PauseMeBase, IPauseMeV2 {
    address public pauser;

    // Add dummy variable buffer to allow for upgrade.
    uint256[99] private __gapPauseMeV2;

    modifier onlyPauser() {
        require(msg.sender == pauser, "Not pauser!");
        _;
    }

    function initialisePause() internal {
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