// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/CoolNFT.sol";
import "../src/UpgradeProxy.sol";

contract CoolNFTTest is Test {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UNPAUSER_ROLE = keccak256("UNPAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string private constant NAME = "Just Cool!";
    string private constant SYMBOL = "JCL";

    CoolNFT public coolNFT;
    CoolNFT public coolNFTImpl;
    UpgradeProxy public upgradeProxy;
    address public admin;
    address public tokenHolder;


    function setUp() public {
        admin = makeAddr("admin");
        tokenHolder = makeAddr("tokenHolder");
        coolNFTImpl = new CoolNFT();
        upgradeProxy = new UpgradeProxy(address(coolNFTImpl), admin);
        coolNFT = CoolNFT(address(upgradeProxy));
    }

    function testInit() public {
        assertEq(coolNFT.name(), NAME);
        assertEq(coolNFT.symbol(), SYMBOL);
        assertTrue(coolNFT.hasRole(DEFAULT_ADMIN_ROLE, admin));
        assertTrue(coolNFT.hasRole(PAUSER_ROLE, admin));
        assertTrue(coolNFT.hasRole(UNPAUSER_ROLE, admin));
        assertTrue(coolNFT.hasRole(MINTER_ROLE, admin));
        assertEq(coolNFT.balanceOf(tokenHolder), 0);
    }

    function testMint() public {
        uint256 tokenId = 167788;
        vm.prank(admin);
        coolNFT.mint(tokenHolder, tokenId);
        assertEq(coolNFT.balanceOf(tokenHolder), 1);
        assertEq(coolNFT.ownerOf(tokenId), tokenHolder);
    }

    function testPause() public {
        uint256 tokenId = 167788;
        vm.startPrank(admin);
        coolNFT.pause();
        vm.expectRevert();
        coolNFT.mint(tokenHolder, tokenId);
    }

    function testUnpause() public {
        uint256 tokenId = 167788;
        vm.startPrank(admin);
        coolNFT.pause();
        coolNFT.unpause();
        coolNFT.mint(tokenHolder, tokenId);
    }
}
