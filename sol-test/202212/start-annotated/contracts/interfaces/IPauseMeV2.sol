// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "./IPauseMe.sol";

/**
 * Pause the non-configuration flows of the contract
 */
interface IPauseMeV2 is IPauseMe {
    /**
     * Change pauser account.
     *
     * @param _newPauser Account that now can set pause / unpause.
     */
    function transferPauserRole(address _newPauser) external;


    /**
     * Which account has the pauser role.
     *
     * @return The address of the account with pauser role.
     */
    function pauser() external view returns (address);
}