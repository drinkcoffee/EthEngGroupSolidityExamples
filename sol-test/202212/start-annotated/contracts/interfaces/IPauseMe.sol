// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

/**
 * Pause the non-configuration flows of the contract
 */
interface IPauseMe {
    event Paused(address account);
    event Unpaused(address account);

    function pause() external;

    function unpause() external;

    function paused() external view returns (bool);
}