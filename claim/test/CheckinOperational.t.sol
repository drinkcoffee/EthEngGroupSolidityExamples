// Copyright Whatgame Studios 2024 - 2025
// SPDX-License-Identifier: MIT
// solhint-disable not-rely-on-time

pragma solidity ^0.8.24;

// solhint-disable-next-line no-global-import
import "forge-std/Test.sol";
import {CheckinBaseTest} from "./CheckinBase.t.sol";
import {Checkin} from "../src/Checkin.sol";
import {GameDayCheck} from "../src/GameDayCheck.sol";

abstract contract CheckinOperationalTest is CheckinBaseTest {

    function testCheckInDay34() public {
        // 	Sat Jan 04 2025 13:00:00 GMT+0000
        vm.warp(1735995600);
        // Min game day is 34, max is 35

        vm.prank(player1);
        vm.expectEmit(true, true, true, true);
        emit Checkin.CheckIn(34, player1, 1);
        checkin.checkIn(34);

        (uint32 mostRecentGameDay, uint256 daysPlayed) = 
            checkin.stats(player1);
        assertEq(mostRecentGameDay, 34);
        assertEq(daysPlayed, 1);
    }

    function testCheckInDay35() public {
        // 	Sat Jan 04 2025 13:00:00 GMT+0000
        vm.warp(1735995600);
        // Min game day is 34, max is 35

        vm.prank(player1);
        vm.expectEmit(true, true, true, true);
        emit Checkin.CheckIn(34, player1, 1);
        checkin.checkIn(34);
        vm.prank(player1);
        vm.expectEmit(true, true, true, true);
        emit Checkin.CheckIn(35, player1, 2);
        checkin.checkIn(35);

        (uint32 mostRecentGameDay, uint256 daysPlayed) = 
            checkin.stats(player1);
        assertEq(mostRecentGameDay, 35);
        assertEq(daysPlayed, 2);
    }

    function testCheckInSameDayTwice() public {
        // 	Sat Jan 04 2025 13:00:00 GMT+0000
        vm.warp(1735995600);
        // Min game day is 34, max is 35

        vm.prank(player1);
        checkin.checkIn(34);

        // This doesn't revert - just quietly ignores.
        checkin.checkIn(34);

        (uint32 mostRecentGameDay, uint256 daysPlayed) = 
            checkin.stats(player1);
        assertEq(mostRecentGameDay, 34);
        assertEq(daysPlayed, 1);
    }


    function testCheckInInvalidDay() public {
        // 	Sat Jan 04 2025 13:00:00 GMT+0000
        vm.warp(1735995600);
        // Min game day is 34, max is 35

        vm.expectRevert(abi.encodeWithSelector(GameDayCheck.GameDayInvalid.selector, 33, 34, 35));
        vm.prank(player1);
        checkin.checkIn(33);
        vm.expectRevert(abi.encodeWithSelector(GameDayCheck.GameDayInvalid.selector, 36, 34, 35));
        vm.prank(player1);
        checkin.checkIn(36);
    }
}
