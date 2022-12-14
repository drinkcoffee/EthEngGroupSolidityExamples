// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "./interfaces/IPauseMe.sol";

/**
 * Pause the non-configuration flows of the contract
 */
abstract contract PauseMeBase is IPauseMe {
    // True when contract not paused.
    bool internal notPaused;

    // Add dummy variable buffer to allow for upgrade.
    uint256[100] private __gapPauseMeBase;

    modifier whenNotPaused() {
        require(notPaused, "Paused!");
        _;
    }

    function paused() external view returns (bool) {
        return !notPaused;
    }

    // ************** Private and Internal *****************
    function pauseInternal() internal {
        notPaused = false;
        emit Paused(msg.sender);
    }

    function unpauseInternal() internal {
        notPaused = true;
        emit Unpaused(msg.sender);
    }

}