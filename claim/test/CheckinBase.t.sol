// Copyright Whatgame Studios 2024 - 2025
// SPDX-License-Identifier: MIT
// solhint-disable not-rely-on-time

pragma solidity ^0.8.24;

// solhint-disable-next-line no-global-import
import "forge-std/Test.sol";
import {Checkin} from "../src/Checkin.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

abstract contract CheckinBaseTest is Test {
    bytes32 public defaultAdminRole;
    bytes32 public upgradeRole;
    bytes32 public ownerRole;

    address public roleAdmin;
    address public upgradeAdmin;
    address public owner;

    address public player1;
    address public player2;

    Checkin checkin;
    ERC1967Proxy public proxy;

    function setUp() public virtual {
        roleAdmin = makeAddr("RoleAdmin");
        upgradeAdmin = makeAddr("UpgradeAdmin");
        owner = makeAddr("Owner");
        player1 = makeAddr("Player1");
        player2 = makeAddr("Player2");

        Checkin temp = new Checkin();
        defaultAdminRole = temp.DEFAULT_ADMIN_ROLE();
        upgradeRole = temp.UPGRADE_ROLE();
        ownerRole = temp.OWNER_ROLE();
    }
}
