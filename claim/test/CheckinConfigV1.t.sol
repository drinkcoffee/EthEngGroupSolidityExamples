// Copyright Whatgame Studios 2024 - 2025
// SPDX-License-Identifier: MIT
// solhint-disable not-rely-on-time

pragma solidity ^0.8.24;

// solhint-disable-next-line no-global-import
import "forge-std/Test.sol";
import {CheckinConfigTest} from "./CheckinConfig.t.sol";
import {Checkin} from "../src/Checkin.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";



contract CheckinConfigV2Test is CheckinConfigTest {
    function setUp() public virtual override {
        super.setUp();

        Checkin impl = new Checkin();
        bytes memory initData = abi.encodeWithSelector(
            Checkin.initialize.selector, roleAdmin, owner, upgradeAdmin);
        proxy = new ERC1967Proxy(address(impl), initData);
        checkin = Checkin(address(proxy));

        uint256 ver = checkin.version();
        assertEq(ver, 1, "Wrong version");
    }
}
