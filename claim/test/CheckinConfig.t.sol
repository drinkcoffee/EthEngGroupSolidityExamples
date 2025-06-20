// Copyright Whatgame Studios 2024 - 2025
// SPDX-License-Identifier: MIT
// solhint-disable not-rely-on-time

pragma solidity ^0.8.24;

// solhint-disable-next-line no-global-import
import "forge-std/Test.sol";
import {CheckinBaseTest} from "./CheckinBase.t.sol";
import {Checkin} from "../src/Checkin.sol";


contract CheckinV2a is Checkin {
    function upgradeStorage(bytes memory /* _data */) external override {
        version = 2;
    }
}


abstract contract CheckinConfigTest is CheckinBaseTest {

    function testGetOwner() public view {
        assertEq(checkin.owner(), owner);
    }

    function testChangeOwner() public {
        address owner2 = makeAddr("Owner2");
        vm.prank(roleAdmin);
        checkin.grantRole(ownerRole, owner2);
        vm.prank(roleAdmin);
        checkin.revokeRole(ownerRole, owner);
        assertEq(checkin.owner(), owner2);
    }

    function testUpgradeAuthFail() public {
        CheckinV2a v2Impl = new CheckinV2a();
        bytes memory initData = abi.encodeWithSelector(Checkin.upgradeStorage.selector, bytes(""));
        // Error will be of the form: 
        // AccessControl: account 0x7fa9385be102ac3eac297483dd6233d62b3e1496 is missing role 0x555047524144455f524f4c450000000000000000000000000000000000000000
        vm.expectRevert();
        checkin.upgradeToAndCall(address(v2Impl), initData);
    }

    function testAddRevokeRenounceRoleAdmin() public {
        bytes32 role = checkin.DEFAULT_ADMIN_ROLE();
        address newRoleAdmin = makeAddr("NewRoleAdmin");
        vm.prank(roleAdmin);
        checkin.grantRole(role, newRoleAdmin);

        vm.startPrank(newRoleAdmin);
        checkin.revokeRole(role, roleAdmin);
        checkin.grantRole(role, roleAdmin);
        checkin.renounceRole(role, newRoleAdmin);
        vm.stopPrank();
    }

    function testAddRevokeRenounceUpgradeAdmin() public {
        bytes32 role = checkin.UPGRADE_ROLE();
        address newUpgradeAdmin = makeAddr("NewUpgradeAdmin");
        vm.startPrank(roleAdmin);
        checkin.grantRole(role, newUpgradeAdmin);
        assertTrue(checkin.hasRole(role, newUpgradeAdmin), "New upgrade admin should have role");
        checkin.revokeRole(role, newUpgradeAdmin);
        assertFalse(checkin.hasRole(role, newUpgradeAdmin), "New upgrade admin should not have role");
        vm.stopPrank();
        vm.prank(upgradeAdmin);
        checkin.renounceRole(role, upgradeAdmin);
        assertFalse(checkin.hasRole(role, upgradeAdmin), "Upgrade admin should not have role");
    }

    function testRoleAdminAuthFail () public {
        bytes32 role = checkin.DEFAULT_ADMIN_ROLE();
        address newRoleAdmin = makeAddr("NewRoleAdmin");
        // Error will be of the form: 
        // AccessControl: account 0x7fa9385be102ac3eac297483dd6233d62b3e1496 is missing role 0x555047524144455f524f4c450000000000000000000000000000000000000000
        vm.expectRevert();
        checkin.grantRole(role, newRoleAdmin);
    }
}
