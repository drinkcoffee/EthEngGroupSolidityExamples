// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Settlement.sol";
import "../src/UpgradeProxy.sol";
import "../src/CoolNFT.sol";

contract SettlementTest is Test {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UNPAUSER_ROLE = keccak256("UNPAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event AdminChanged(address previousAdmin, address newAdmin);


    Settlement public settlement;

    address buyer;
    address seller;

    string private constant NAME = "Just Cool!";
    string private constant SYMBOL = "JCL";

    CoolNFT public coolNFT;
    CoolNFT public coolNFTImpl;
    UpgradeProxy public upgradeProxy;
    address public tokenHolder;


    function setUp() public {
        seller = makeAddr("seller");
        buyer = makeAddr("buyer");
        tokenHolder = makeAddr("tokenHolder");
        coolNFTImpl = new CoolNFT();

        vm.expectEmit(true, true, false, false);
        emit AdminChanged(address(0), address(0));

        upgradeProxy = new UpgradeProxy(address(coolNFTImpl), seller);
        coolNFT = CoolNFT(address(upgradeProxy));

        vm.deal(buyer, 100 ether);
    }

    function testBuy() public {
        vm.prank(seller);
        settlement = new Settlement(100 ether, address(0), address(coolNFT));

        vm.prank(seller);
        coolNFT.grantRole(DEFAULT_ADMIN_ROLE, address(settlement));

        vm.prank(buyer);
        settlement.buy{value: 100 ether}(buyer);

        assertTrue(coolNFT.hasRole(DEFAULT_ADMIN_ROLE, buyer));


        

    }
}
