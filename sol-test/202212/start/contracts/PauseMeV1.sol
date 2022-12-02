// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "./Admin.sol";
import "./PauseMeBase.sol";

/**
 * Pause the non-configuration flows of the contract
 */
abstract contract PauseMeV1 is Admin, PauseMeBase {


    function initialisePause() internal {
        unpauseInternal();
    }


    function pause() external override onlyAdmin {
        pauseInternal();
    }

    function unpause() external override onlyAdmin {
        unpauseInternal();
    }
}