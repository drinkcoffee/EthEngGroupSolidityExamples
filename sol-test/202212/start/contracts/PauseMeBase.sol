// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "./interfaces/IPauseMe.sol";

/**
 * Pause the non-configuration flows of the contract
 */
abstract contract PauseMeBase is IPauseMe {
    // True when contract paused.
    bool private notPaused;

    modifier whenNotPaused() {
        require(notPaused, "Paused!");
        _;
    }

    function paused() external view returns (bool) {
        return !notPaused;
    }

    // ************** Private and Internal *****************
    function pauseInternal() internal {
        notPaused = true;
        emit Paused(msg.sender);
    }

    function unpauseInternal() internal {
        notPaused = false;
        emit Unpaused(msg.sender);
    }

}