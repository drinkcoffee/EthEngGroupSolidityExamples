// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

/**
 * Single owner administrator of contract.
 */
interface IAdmin {
    /**
     * Transfer ownership of contract to the a new admin account.
     *
     * Only the current admin can call this function.
     *
     * @param _newOwner The new administrator.
     */
    function transferOwnership(address _newOwner) external;

    /**
     * @return Address of contract administrator.
     */
    function admin() external view returns (address);
}