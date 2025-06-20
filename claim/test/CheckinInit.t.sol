// Copyright Whatgame Studios 2024 - 2025
// SPDX-License-Identifier: MIT
// solhint-disable not-rely-on-time

pragma solidity ^0.8.24;

// solhint-disable-next-line no-global-import
import "forge-std/Test.sol";
import {CheckinBaseTest} from "./CheckinBase.t.sol";
import {Checkin} from "../src/Checkin.sol";

abstract contract CheckinInitTest is CheckinBaseTest {

    function testInit() public view {
        assertEq(checkin.owner(), owner);
        assertTrue(checkin.hasRole(upgradeRole, upgradeAdmin));
        assertTrue(checkin.hasRole(defaultAdminRole, roleAdmin));

        (uint32 mostRecentGameDay, uint256 daysPlayed) = 
            checkin.stats(player1);
        assertEq(mostRecentGameDay, 0);
        assertEq(daysPlayed, 0);
    }
}
