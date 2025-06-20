// Copyright Whatgame Studios 2024 - 2025
// SPDX-License-Identifier: MIT
// solhint-disable not-rely-on-time

pragma solidity ^0.8.24;

// solhint-disable-next-line no-global-import
import "forge-std/Test.sol";
import {GameDayCheck} from "../src/GameDayCheck.sol";

contract GameDayCheckImpl is GameDayCheck {

}

contract GameDayCheckTest is Test {
    error GameDayInvalid(uint32 _requestedGameDay, uint32 _minGameDay, uint32 _maxGameDay);

    // GMT	Sun Dec 01 2024 00:00:00 GMT+0000
    uint256 public constant UNIX_TIME_GAME_START = 1733011200;
    // To convert to days: 24 x 60 x 60
    uint256 public constant SECONDS_PER_DAY = 86400;

    GameDayCheckImpl impl;

    function setUp() public {
        impl = new GameDayCheckImpl();
    }

    function testDetermineCurrentGameDaysAcrossThree() public {
        // 	Sat Jan 04 2025 11:00:00 GMT+0000
        vm.warp(1735988400);
        uint32 gmt0GameDay = uint32((block.timestamp - UNIX_TIME_GAME_START) / SECONDS_PER_DAY);
        (uint32 minGameDay, uint32 maxGameDay) = impl.determineCurrentGameDays();
        assertEq(minGameDay, 33, "Min game day1");
        assertEq(gmt0GameDay, 34, "GMT+0 game day1");
        assertEq(maxGameDay, 35, "Max game day1");
    }

    function testDetermineCurrentGameDaysPreviousDay() public {
        // 	Sat Jan 04 2025 09:00:00 GMT+0000
        vm.warp(1735981200);
        uint32 gmt0GameDay = uint32((block.timestamp - UNIX_TIME_GAME_START) / SECONDS_PER_DAY);
        (uint32 minGameDay, uint32 maxGameDay) = impl.determineCurrentGameDays();
        assertEq(minGameDay, 33, "Min game day2");
        assertEq(gmt0GameDay, 34, "GMT+0 game day2");
        assertEq(maxGameDay, 34, "Max game day2");
    }

    function testDetermineCurrentGameDaysNextDay() public {
        // 	Sat Jan 04 2025 13:00:00 GMT+0000
        vm.warp(1735995600);
        uint32 gmt0GameDay = uint32((block.timestamp - UNIX_TIME_GAME_START) / SECONDS_PER_DAY);
        (uint32 minGameDay, uint32 maxGameDay) = impl.determineCurrentGameDays();
        assertEq(minGameDay, 34, "Min game day3");
        assertEq(gmt0GameDay, 34, "GMT+0 game day3");
        assertEq(maxGameDay, 35, "Max game day3");
    }

    function testCheckGameDay() public {
        // 	Sat Jan 04 2025 13:00:00 GMT+0000
        vm.warp(1735995600);
        // Min game day is 34, max is 35

        impl.checkGameDay(34);
        impl.checkGameDay(35);
        vm.expectRevert(abi.encodeWithSelector(GameDayInvalid.selector, 33, 34, 35));
        impl.checkGameDay(33);
        vm.expectRevert(abi.encodeWithSelector(GameDayInvalid.selector, 36, 34, 35));
        impl.checkGameDay(36);
    }
}
