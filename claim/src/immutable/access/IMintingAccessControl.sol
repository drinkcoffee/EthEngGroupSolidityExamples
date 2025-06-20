// Copyright Immutable Pty Ltd 2018 - 2023
// SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.8.19 <0.8.29;

import {IAccessControlEnumerable} from "@openzeppelin/contracts/access/extensions/IAccessControlEnumerable.sol";

interface IMintingAccessControl is IAccessControlEnumerable {
    /**
     * @notice Role to mint tokens
     */
    function MINTER_ROLE() external returns (bytes32);

    /**
     * @notice Allows admin grant `user` `MINTER` role
     *  @param user The address to grant the `MINTER` role to
     */
    function grantMinterRole(address user) external;

    /**
     * @notice Allows admin to revoke `MINTER_ROLE` role from `user`
     *  @param user The address to revoke the `MINTER` role from
     */
    function revokeMinterRole(address user) external;

    /**
     * @notice Returns the addresses which have DEFAULT_ADMIN_ROLE
     */
    function getAdmins() external view returns (address[] memory);
}
