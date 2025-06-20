// Copyright Immutable Pty Ltd 2018 - 2023
// SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.8.19 <0.8.29;

import {AccessControlEnumerable} from "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";

abstract contract MintingAccessControl is AccessControlEnumerable {
    /// @notice Role to mint tokens
    bytes32 public constant MINTER_ROLE = bytes32("MINTER_ROLE");

    /**
     * @notice Allows admin grant `user` `MINTER` role
     *  @param user The address to grant the `MINTER` role to
     */
    function grantMinterRole(address user) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, user);
    }

    /**
     * @notice Allows admin to revoke `MINTER_ROLE` role from `user`
     *  @param user The address to revoke the `MINTER` role from
     */
    function revokeMinterRole(address user) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, user);
    }

    /**
     * @notice Returns the addresses which have DEFAULT_ADMIN_ROLE
     */
    function getAdmins() public view returns (address[] memory) {
        uint256 adminCount = getRoleMemberCount(DEFAULT_ADMIN_ROLE);
        address[] memory admins = new address[](adminCount);
        for (uint256 i; i < adminCount; i++) {
            admins[i] = getRoleMember(DEFAULT_ADMIN_ROLE, i);
        }
        return admins;
    }
}
