// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "./Admin.sol";
import "./PauseMeBase.sol";

/**
 * Pause the non-configuration flows of the contract
 */
abstract contract PauseMeV1 is Admin, PauseMeBase {
    // TODO: Intermediate: Upgrade issue: add dummy variable buffer: uint256[99] private __gap;


    function initialisePause() internal {
        unpauseInternal();
    }


    // TODO: Basic: No access control
    function pause() external override {
        pauseInternal();
    }

    function unpause() external override onlyAdmin {
        unpauseInternal();
    }
}