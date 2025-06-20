// Copyright Whatgame Studios 2024 - 2025
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

// solhint-disable-next-line no-global-import
import "forge-std/Test.sol";
import {ClaimBaseTest} from "./ClaimBase.t.sol";
import {Claim} from "../src/Claim.sol";
import {PassportCheck} from "../src/PassportCheck.sol";
import {IERC1155} from "@openzeppelin/contracts/token/erc1155/IERC1155.sol";

contract ClaimV2a is Claim {
    function upgradeStorage(bytes memory /* _data */) external override virtual {
        // Note real version of V2 contract would need to check for downgrades.
        version = 2;
    }
}


contract ClaimConfigTest is ClaimBaseTest {
    error AddMoreTokensBalanceMustBeNonZero();
    error AddMoreTokensPercentageTooLarge();

    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);
    error ERC1155MissingApprovalForAll(address target, address sender);
    error ERC1155InvalidReceiver(address receiver);
    error AccessControlUnauthorizedAccount(address account, bytes32 role);

    error EnforcedPause();

    event SettingDaysPlayedToClaim(uint256 _newDaysPlayedToClaim);
    event TokensAdded(uint256 _slot, address _erc1155Contract, uint256 _tokenId, uint256 _amount, uint256 _percentage);
    event TokensRemoved(uint256 _slot, address _erc1155Contract, uint256 _tokenId, uint256 _amount);
    event Claimed(address _gamePlayer, address _erc1155Contract, uint256 _tokenId, uint256 _daysPlayed, uint256 _claimedSoFar);


    function setUp() public virtual override {
        super.setUp();
    }

    function testUpgradeToV2() public {
        ClaimV2a v2Impl = new ClaimV2a();
        bytes memory initData = abi.encodeWithSelector(Claim.upgradeStorage.selector, bytes(""));
        vm.prank(configAdmin);
        claim.upgradeToAndCall(address(v2Impl), initData);

        uint256 ver = claim.version();
        assertEq(ver, 2, "Upgrade did not upgrade version");
    }

    function testUpgradeToV1() public {
        Claim v1Impl = new Claim();
        bytes memory initData = abi.encodeWithSelector(Claim.upgradeStorage.selector, bytes(""));
        vm.expectRevert(abi.encodeWithSelector(Claim.CanNotUpgradeToLowerOrSameVersion.selector, 1));
        vm.prank(configAdmin);
        claim.upgradeToAndCall(address(v1Impl), initData);
    }

    function testDowngradeV1ToV0() public {
        // Upgrade from V0 to V1
        ClaimV2a v2Impl = new ClaimV2a();
        bytes memory initData = abi.encodeWithSelector(Claim.upgradeStorage.selector, bytes(""));
        vm.prank(configAdmin);
        claim.upgradeToAndCall(address(v2Impl), initData);

        // Attempt to downgrade from V1 to V0.
        Claim v1Impl = new Claim();
        vm.expectRevert(abi.encodeWithSelector(Claim.CanNotUpgradeToLowerOrSameVersion.selector, 2));
        vm.prank(configAdmin);
        claim.upgradeToAndCall(address(v1Impl), initData);
    }

    function testSetDaysPlayedToClaim() public {
        uint256 newDays = 45;
        vm.prank(configAdmin);
        vm.expectEmit(true, true, true, true);
        emit SettingDaysPlayedToClaim(newDays);
        claim.setDaysPlayedToClaim(newDays);
        assertEq(claim.daysPlayedToClaim(), newDays, "Days played to claim should be updated");
    }

    function testSetDaysPlayedToClaimTooSmall() public {
        uint256 newDays = 6;
        vm.prank(configAdmin);
        vm.expectRevert(abi.encodeWithSelector(
            Claim.ProposedNewDaysPlayedToClaimTooSmall.selector, newDays));
        claim.setDaysPlayedToClaim(newDays);
    }

    function testAddMoreTokens() public {
        vm.prank(tokenAdmin);
        mockERC1155.setApprovalForAll(address(claim), true);

        Claim.ClaimableToken memory token = Claim.ClaimableToken({
            erc1155Contract: address(mockERC1155),
            tokenId: TOK1_TOKEN_ID,
            balance: TOK1_AMOUNT,
            percentage: TOK1_PERCENTAGE
        });
        vm.prank(tokenAdmin);
        vm.expectEmit(true, true, true, true);
        emit TokensAdded(1, address(mockERC1155), TOK1_TOKEN_ID, TOK1_AMOUNT, TOK1_PERCENTAGE);
        claim.addMoreTokens(token);

        (address erc1155Contract, uint256 tokenId, uint256 balance, uint256 percentage) = claim.claimableTokens(1);
        assertEq(erc1155Contract, address(mockERC1155), "ERC1155 contract should match");
        assertEq(tokenId, TOK1_TOKEN_ID, "Token ID should match");
        assertEq(balance, TOK1_AMOUNT, "Balance should match");
        assertEq(percentage, TOK1_PERCENTAGE, "Percentage should match");

        assertEq(mockERC1155.balanceOf(tokenAdmin, TOK1_TOKEN_ID), 0, "Token admin balance wrong");
        assertEq(mockERC1155.balanceOf(address(claim), TOK1_TOKEN_ID), TOK1_AMOUNT, "Contract balance wrong");
    }

    function testAddMoreTokensBadAccess() public {
        vm.prank(tokenAdmin);
        mockERC1155.setApprovalForAll(address(claim), true);

        Claim.ClaimableToken memory token = Claim.ClaimableToken({
            erc1155Contract: address(mockERC1155),
            tokenId: TOK1_TOKEN_ID,
            balance: TOK1_AMOUNT,
            percentage: TOK1_PERCENTAGE
        });
        vm.prank(player1);
        vm.expectRevert(abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, player1, tokenRole));
        claim.addMoreTokens(token);
    }

    function testAddMoreTokensWithZeroBalance() public {
        vm.prank(tokenAdmin);
        mockERC1155.setApprovalForAll(address(claim), true);

        Claim.ClaimableToken memory token = Claim.ClaimableToken({
            erc1155Contract: address(mockERC1155),
            tokenId: TOK1_TOKEN_ID,
            balance: 0,
            percentage: TOK1_PERCENTAGE
        });
        vm.prank(tokenAdmin);
        vm.expectRevert(abi.encodeWithSelector(AddMoreTokensBalanceMustBeNonZero.selector));
        claim.addMoreTokens(token);
    }

    function testAddMoreTokensWithERC1155ZeroBalance() public {
        vm.prank(tokenAdmin);
        mockERC1155.setApprovalForAll(address(claim), true);

        Claim.ClaimableToken memory token = Claim.ClaimableToken({
            erc1155Contract: address(mockERC1155),
            tokenId: 1000,
            balance: TOK1_AMOUNT,
            percentage: TOK1_PERCENTAGE
        });
        vm.prank(tokenAdmin);
        vm.expectRevert(abi.encodeWithSelector(ERC1155InsufficientBalance.selector, tokenAdmin, 0, TOK1_AMOUNT, 1000));
        claim.addMoreTokens(token);
    }

    function testAddMoreTokensERC1155NotApproved() public {
        Claim.ClaimableToken memory token = Claim.ClaimableToken({
            erc1155Contract: address(mockERC1155),
            tokenId: 1000,
            balance: TOK1_AMOUNT,
            percentage: TOK1_PERCENTAGE
        });
        vm.prank(tokenAdmin);
        vm.expectRevert(abi.encodeWithSelector(ERC1155MissingApprovalForAll.selector, address(claim), tokenAdmin));
        claim.addMoreTokens(token);
    }

    function testAddMoreTokensWithInvalidPercentage() public {
        vm.prank(tokenAdmin);
        mockERC1155.setApprovalForAll(address(claim), true);

        Claim.ClaimableToken memory token = Claim.ClaimableToken({
            erc1155Contract: address(mockERC1155),
            tokenId: DEFAULT_TOKEN_ID,
            balance: DEFAULT_AMOUNT,
            percentage: 10001 // More than 100%
        });
        vm.prank(tokenAdmin);
        vm.expectRevert(abi.encodeWithSelector(AddMoreTokensPercentageTooLarge.selector));
        claim.addMoreTokens(token);
    }

    function testDirectTransferFail() public {
        // Fake add token admin, which is perceived as a contract by the code, this so that the test will work.
        address[] memory contracts = new address[](1);
        contracts[0] = address(tokenAdmin);
        vm.prank(operatorRegistrarAdmin);
        allowList.addAddressesToAllowlist(contracts);

        // Now check that a direct transfer will fail.
        vm.prank(tokenAdmin);
        vm.expectRevert(abi.encodeWithSelector(ERC1155InvalidReceiver.selector, address(claim)));
        mockERC1155.safeTransferFrom(tokenAdmin, address(claim), TOK1_TOKEN_ID, TOK1_AMOUNT, new bytes(0));
    }

    function testBatchDirectTransferFail() public {
        // Fake add token admin, which is perceived as a contract by the code, this so that the test will work.
        address[] memory contracts = new address[](1);
        contracts[0] = address(tokenAdmin);
        vm.prank(operatorRegistrarAdmin);
        allowList.addAddressesToAllowlist(contracts);

        // Now check that a direct batch transfer will fail.
        uint256[] memory ids = new uint256[](1);
        ids[0] = TOK1_TOKEN_ID;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = TOK1_AMOUNT;

        vm.prank(tokenAdmin);
        vm.expectRevert(abi.encodeWithSelector(ERC1155InvalidReceiver.selector, address(claim)));
        mockERC1155.safeBatchTransferFrom(tokenAdmin, address(claim), ids, amounts, new bytes(0));
    }


    function testRemoveTokens() public {
        // First add tokens
        testAddMoreTokens();

        // Then remove some tokens
        uint256 removeAmount = TOK1_AMOUNT / 3;
        vm.prank(tokenAdmin);
        vm.expectEmit(true, true, true, true);
        emit TokensRemoved(1, address(mockERC1155), TOK1_TOKEN_ID, removeAmount);
        claim.removeTokens(1, removeAmount);

        // Check transfer.
        (, , uint256 balance, ) = claim.claimableTokens(1);
        assertEq(balance, TOK1_AMOUNT - removeAmount, "Balance should match");
        assertEq(mockERC1155.balanceOf(tokenAdmin, TOK1_TOKEN_ID), removeAmount, "Token admin balance wrong");
        assertEq(mockERC1155.balanceOf(address(claim), TOK1_TOKEN_ID), TOK1_AMOUNT - removeAmount, "Contract balance wrong");
    }

    function testRemoveTokensBadAccessControl() public {
        // First add tokens
        testAddMoreTokens();

        // Then remove some tokens
        uint256 removeAmount = 0;
        vm.prank(player1);
        vm.expectRevert(abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, player1, tokenRole));
        claim.removeTokens(1, removeAmount);
    }

    function testRemoveTokensWithZeroAmount() public {
        // First add tokens
        testAddMoreTokens();

        // Then remove some tokens
        uint256 removeAmount = 0;
        vm.prank(tokenAdmin);
        vm.expectRevert(abi.encodeWithSelector(Claim.CantRemoveNoTokens.selector));
        claim.removeTokens(1, removeAmount);
    }

    function testRemoveTokensExceedingBalance() public {
        // First add tokens
        testAddMoreTokens();

        // Then remove some tokens
        uint256 removeAmount = TOK1_AMOUNT + 1;
        vm.prank(tokenAdmin);
        vm.expectRevert(abi.encodeWithSelector(Claim.BalanceTooLow.selector, 1, TOK1_AMOUNT+1, TOK1_AMOUNT));
        claim.removeTokens(1, removeAmount);
    }

    function testRemoveAllTokens() public {
        // First add tokens
        testAddMoreTokens();

        // Then remove all tokens
        vm.prank(tokenAdmin);
        vm.expectEmit(true, true, true, true);
        emit TokensRemoved(1, address(mockERC1155), TOK1_TOKEN_ID, TOK1_AMOUNT);
        claim.removeAllTokens(1);

        // Check transfer.
        (, , uint256 balance, ) = claim.claimableTokens(1);
        assertEq(balance, 0, "Balance should match");
        assertEq(mockERC1155.balanceOf(tokenAdmin, TOK1_TOKEN_ID), TOK1_AMOUNT, "Token admin balance wrong");
        assertEq(mockERC1155.balanceOf(address(claim), TOK1_TOKEN_ID), 0, "Contract balance wrong");
    }

    function testRemoveAllTokensBadAuth() public {
        // First add tokens
        testAddMoreTokens();

        // Then remove all tokens
        vm.prank(player1);
        vm.expectRevert(abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, player1, tokenRole));
        claim.removeAllTokens(1);
    }

    function testPassportCheck() public view {
        assertTrue(claim.isPassport(address(passportWallet)), "Passport wallet");
        assertFalse(claim.isPassport(address(claim)), "claim");
    }

    function testRemovePassportWallet() public {
        vm.prank(configAdmin);
        claim.removePassportWallet(address(passportWallet));
        assertFalse(claim.isPassport(address(passportWallet)), "Passport wallet");
    }

    function testAddPassportWallet() public {
        testRemovePassportWallet();
        vm.prank(configAdmin);
        claim.addPassportWallet(address(passportWallet));
        assertTrue(claim.isPassport(address(passportWallet)), "Passport wallet");
    }

    function testAddPassportWalletBadAuth() public {
        testRemovePassportWallet();
        vm.prank(player1);
        vm.expectRevert(abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, player1, configRole));
        claim.addPassportWallet(address(passportWallet));
    }

    function testRemovePassportWalletBadAuth() public {
        vm.prank(player1);
        vm.expectRevert(abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, player1, configRole));
        claim.removePassportWallet(address(passportWallet));
    }

    function testPause() public {
        vm.prank(configAdmin);
        claim.pause();
        assertTrue(claim.paused(), "Contract should be paused");
    }

    function testPauseBadAuth() public {
        vm.prank(player1);
        vm.expectRevert();
        claim.pause();
    }

    function testUnpause() public {
        vm.prank(configAdmin);
        claim.pause();
        vm.prank(configAdmin);
        claim.unpause();
        assertFalse(claim.paused(), "Contract should be unpaused");
    }

    function testUnpauseBadAuth() public {
        vm.prank(configAdmin);
        claim.pause();
        vm.prank(player1);
        vm.expectRevert();
        claim.unpause();
    }

    function testClaimWhilePaused() public {
        vm.prank(configAdmin);
        claim.pause();
        vm.prank(player1);
        vm.expectRevert(abi.encodeWithSelector(EnforcedPause.selector));
        claim.claim();
    }
}
