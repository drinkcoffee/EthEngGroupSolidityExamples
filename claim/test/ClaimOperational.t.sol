// Copyright Whatgame Studios 2024 - 2025
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// solhint-disable-next-line no-global-import
import "forge-std/Test.sol";
import {ClaimBaseTest} from "./ClaimBase.t.sol";
import {Claim} from "../src/Claim.sol";
import {Checkin} from "../src/Checkin.sol";
import {IERC1155} from "@openzeppelin/contracts/token/erc1155/IERC1155.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ImmutableERC1155} from "../src/immutable/ImmutableERC1155.sol";


contract FakeClaim is Claim {
    uint256 rand;

    function setRand(uint256 _rand) public {
        rand = _rand;
    }

    function _generateRandom(uint256 /* _salt */) internal override view returns (uint256) {
        return rand;
    }

    function random(uint256 _blockNum) external view returns (uint256) {
        return super._generateRandom(_blockNum);
    }
}

contract FakeCheckin is Checkin {
    function setDaysPlayed(uint256 _daysPlayed) public {
        Stats storage playerStats = stats[msg.sender];
        playerStats.daysPlayed = _daysPlayed;
    }
}


contract ClaimOperationalTest is ClaimBaseTest {
    // error AddMoreTokensBalanceMustBeNonZero();
    // error AddMoreTokensPercentageTooLarge();

    // error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);
    // error ERC1155MissingApprovalForAll(address target, address sender);
    // error ERC1155InvalidReceiver(address receiver);
    // error AccessControlUnauthorizedAccount(address account, bytes32 role);
    event TokensAdded(uint256 _slot, address _erc1155Contract, uint256 _tokenId, uint256 _amount, uint256 _percentage);

    event Claimed(address _gamePlayer, address _erc1155Contract, uint256 _tokenId, uint256 _daysPlayed, uint256 _claimedSoFar);
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);


    FakeClaim fakeClaim;
    FakeCheckin fakeCheckin;

    function setUp() public virtual override {
        super.setUp();
        setUpFakeCheckin();
        setUpFakeClaim();
        configureOperatorAllowlist();
    }

    function setUpFakeCheckin() private {
        address upgradeAdmin = makeAddr("UpgradeAdmin");
        FakeCheckin impl = new FakeCheckin();
        bytes memory initData = abi.encodeWithSelector(
            Checkin.initialize.selector, address(0), address(0), upgradeAdmin);
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        fakeCheckin = FakeCheckin(address(proxy));
    }

    function setUpFakeClaim() private {
        FakeClaim impl = new FakeClaim();
        bytes memory initData = abi.encodeWithSelector(
            Claim.initialize.selector, 
            roleAdmin, owner, configAdmin, tokenAdmin, passportWallet, fakeCheckin);
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        fakeClaim = FakeClaim(address(proxy));
    }

    function configureOperatorAllowlist() private {
        // Add fake claim contract to the allowlist
        address[] memory contracts = new address[](1);
        contracts[0] = address(fakeClaim);
        vm.prank(operatorRegistrarAdmin);
        allowList.addAddressesToAllowlist(contracts);
    }


    function testGetClaimableNfts() public {
        addTokens();
        Claim.ClaimableToken[] memory claimableTokens = fakeClaim.getClaimableNfts();

        assertEq(claimableTokens.length, 5, "Length");
        assertEq(claimableTokens[0].erc1155Contract, address(mockERC1155), "ERC1155[0]");
        assertEq(claimableTokens[0].tokenId, TOK1_TOKEN_ID, "Token ID[0]");
        assertEq(claimableTokens[0].balance, TOK1_AMOUNT, "Balance[0]");
        assertEq(claimableTokens[0].percentage, TOK1_PERCENTAGE, "Percentage[0]");

        assertEq(claimableTokens[1].erc1155Contract, address(mockERC1155), "ERC1155[1]");
        assertEq(claimableTokens[1].tokenId, TOK2_TOKEN_ID, "Token ID[1]");
        assertEq(claimableTokens[1].balance, TOK2_AMOUNT, "Balance[1]");
        assertEq(claimableTokens[1].percentage, TOK2_PERCENTAGE, "Percentage[1]");

        assertEq(claimableTokens[2].erc1155Contract, address(mockERC1155), "ERC1155[2]");
        assertEq(claimableTokens[2].tokenId, TOK3_TOKEN_ID, "Token ID[2]");
        assertEq(claimableTokens[2].balance, TOK3_AMOUNT, "Balance[2]");
        assertEq(claimableTokens[2].percentage, TOK3_PERCENTAGE, "Percentage[2]");

        assertEq(claimableTokens[3].erc1155Contract, address(mockERC1155), "ERC1155[3]");
        assertEq(claimableTokens[3].tokenId, TOK4_TOKEN_ID, "Token ID[3]");
        assertEq(claimableTokens[3].balance, TOK4_AMOUNT, "Balance[3]");
        assertEq(claimableTokens[3].percentage, TOK4_PERCENTAGE, "Percentage[3]");

        assertEq(claimableTokens[4].erc1155Contract, address(mockERC1155), "ERC1155[4]");
        assertEq(claimableTokens[4].tokenId, TOK5_TOKEN_ID, "Token ID[4]");
        assertEq(claimableTokens[4].balance, TOK5_AMOUNT, "Balance[4]");
        assertEq(claimableTokens[4].percentage, TOK5_PERCENTAGE, "Percentage[4]");
    }

    function testCheckSlotIds() public {
        addTokens();

        assertEq(fakeClaim.firstInUseClaimableTokenSlot(), 1, "First");
        assertEq(fakeClaim.nextSpareClaimableTokenSlot(), 6, "Next");
    }

    function testClaimableNfts() public {
        addTokens();

        (address erc1155Contract, uint256 tokenId, uint256 balance, uint256 percentage) = fakeClaim.claimableTokens(1);
        assertEq(erc1155Contract, address(mockERC1155), "ERC1155[0]");
        assertEq(tokenId, TOK1_TOKEN_ID, "Token ID[0]");
        assertEq(balance, TOK1_AMOUNT, "Balance[0]");
        assertEq(percentage, TOK1_PERCENTAGE, "Percentage[0]");

        (erc1155Contract, tokenId, balance, percentage) = fakeClaim.claimableTokens(2);
        assertEq(erc1155Contract, address(mockERC1155), "ERC1155[1]");
        assertEq(tokenId, TOK2_TOKEN_ID, "Token ID[1]");
        assertEq(balance, TOK2_AMOUNT, "Balance[1]");
        assertEq(percentage, TOK2_PERCENTAGE, "Percentage[1]");

        (erc1155Contract, tokenId, balance, percentage) = fakeClaim.claimableTokens(3);
        assertEq(erc1155Contract, address(mockERC1155), "ERC1155[2]");
        assertEq(tokenId, TOK3_TOKEN_ID, "Token ID[2]");
        assertEq(balance, TOK3_AMOUNT, "Balance[2]");
        assertEq(percentage, TOK3_PERCENTAGE, "Percentage[2]");
    }

    function testClaim() public {
        addTokens();

        uint256 daysPlayedToClaim = fakeClaim.daysPlayedToClaim();
        uint256 daysPlayed = daysPlayedToClaim + 3;
        vm.prank(passportWalletAddress);
        fakeCheckin.setDaysPlayed(daysPlayed);

        fakeClaim.setRand(1);

        (, , uint256 balance1, ) = fakeClaim.claimableTokens(1);
        assertEq(balance1, TOK1_AMOUNT, "Balance start should match");

        vm.prank(passportWalletAddress);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(address(fakeClaim), address(fakeClaim), 
            passportWalletAddress, TOK1_TOKEN_ID, 1);
        vm.expectEmit(true, true, true, true);
        emit Claimed(passportWalletAddress, address(mockERC1155), TOK1_TOKEN_ID, daysPlayed, 0);
        fakeClaim.claim();

        (, , uint256 balance, ) = fakeClaim.claimableTokens(1);
        assertEq(balance, TOK1_AMOUNT - 1, "Balance should match");
        assertEq(mockERC1155.balanceOf(passportWalletAddress, TOK1_TOKEN_ID), 1, "Player balance wrong");
        assertEq(mockERC1155.balanceOf(address(fakeClaim), TOK1_TOKEN_ID), TOK1_AMOUNT - 1, "Contract balance wrong");

        assertEq(fakeClaim.claimedDay(passportWalletAddress), daysPlayedToClaim, "Claimed day after claim");
    }

    function testClaimTok1a() public {
        checkClaim(0, TOK1_TOKEN_ID);
    }

    function testClaimTok1b() public {
        checkClaim(TOK1_PERCENTAGE-1, TOK1_TOKEN_ID);
    }

    function testClaimTok2a() public {
        checkClaim(TOK1_PERCENTAGE, TOK2_TOKEN_ID);
    }

    function testClaimTok2b() public {
        checkClaim(TOK1_PERCENTAGE + TOK2_PERCENTAGE - 1, TOK2_TOKEN_ID);
    }

    function testClaimTok4a() public {
        checkClaim(TOK1_PERCENTAGE + TOK2_PERCENTAGE, TOK4_TOKEN_ID);
    }

    function testClaimTok4b() public {
        checkClaim(TOK1_PERCENTAGE + TOK2_PERCENTAGE + TOK4_PERCENTAGE - 1, TOK4_TOKEN_ID);
    }

    function testClaimTok5a() public {
        checkClaim(TOK1_PERCENTAGE + TOK2_PERCENTAGE + TOK4_PERCENTAGE, TOK3_TOKEN_ID);
    }

    function testClaimTok5b() public {
        uint256 ONE_HUNDRED_PERCENT = 10000;
        checkClaim(ONE_HUNDRED_PERCENT, TOK3_TOKEN_ID);
    }

    function testClaimMultiple() public {
        addTokens();

        uint256 daysPlayedToClaim = fakeClaim.daysPlayedToClaim();
        uint256 daysPlayed = 10 * daysPlayedToClaim;
        vm.prank(passportWalletAddress);
        fakeCheckin.setDaysPlayed(daysPlayed);

        fakeClaim.setRand(0);

        vm.prank(passportWalletAddress);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(address(fakeClaim), address(fakeClaim), 
            passportWalletAddress, TOK1_TOKEN_ID, 1);
        vm.expectEmit(true, true, true, true);
        emit Claimed(passportWalletAddress, address(mockERC1155), TOK1_TOKEN_ID, daysPlayed, 0);
        fakeClaim.claim();

        vm.prank(passportWalletAddress);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(address(fakeClaim), address(fakeClaim), 
            passportWalletAddress, TOK1_TOKEN_ID, 1);
        vm.expectEmit(true, true, true, true);
        emit Claimed(passportWalletAddress, address(mockERC1155), TOK1_TOKEN_ID, daysPlayed, daysPlayedToClaim);
        fakeClaim.claim();

        vm.prank(passportWalletAddress);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(address(fakeClaim), address(fakeClaim), 
            passportWalletAddress, TOK1_TOKEN_ID, 1);
        vm.expectEmit(true, true, true, true);
        emit Claimed(passportWalletAddress, address(mockERC1155), TOK1_TOKEN_ID, daysPlayed, 2 * daysPlayedToClaim);
        fakeClaim.claim();

        vm.prank(passportWalletAddress);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(address(fakeClaim), address(fakeClaim), 
            passportWalletAddress, TOK2_TOKEN_ID, 1);
        vm.expectEmit(true, true, true, true);
        emit Claimed(passportWalletAddress, address(mockERC1155), TOK2_TOKEN_ID, daysPlayed, 3 * daysPlayedToClaim);
        fakeClaim.claim();

        assertEq(fakeClaim.firstInUseClaimableTokenSlot(), 2, "First");
    }

    function testClaimMultipleInfinite() public {
        addTokens();

        uint256 daysPlayedToClaim = fakeClaim.daysPlayedToClaim();
        uint256 daysPlayed = 10 * daysPlayedToClaim;
        vm.prank(passportWalletAddress);
        fakeCheckin.setDaysPlayed(daysPlayed);

        uint256 ONE_HUNDRED_PERCENT = 10000;
        fakeClaim.setRand(ONE_HUNDRED_PERCENT);

        vm.prank(passportWalletAddress);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(address(fakeClaim), address(fakeClaim), 
            passportWalletAddress, TOK3_TOKEN_ID, 1);
        vm.expectEmit(true, true, true, true);
        emit Claimed(passportWalletAddress, address(mockERC1155), TOK3_TOKEN_ID, daysPlayed, 0);
        fakeClaim.claim();

        vm.prank(passportWalletAddress);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(address(fakeClaim), address(fakeClaim), 
            passportWalletAddress, TOK3_TOKEN_ID, 1);
        vm.expectEmit(true, true, true, true);
        emit Claimed(passportWalletAddress, address(mockERC1155), TOK3_TOKEN_ID, daysPlayed, daysPlayedToClaim);
        fakeClaim.claim();

        vm.prank(passportWalletAddress);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(address(fakeClaim), address(fakeClaim), 
            passportWalletAddress, TOK5_TOKEN_ID, 1);
        vm.expectEmit(true, true, true, true);
        emit Claimed(passportWalletAddress, address(mockERC1155), TOK5_TOKEN_ID, daysPlayed, 2 * daysPlayedToClaim);
        fakeClaim.claim();

        assertEq(fakeClaim.firstInUseClaimableTokenSlot(), 1, "First");
    }

    function testClaimNotPassport() public {
        vm.prank(player1);
        vm.expectRevert(abi.encodeWithSelector(
            Claim.ClaimNonPassportAccount.selector, player1));
        fakeClaim.claim();
    }

    function testRand() public {
        vm.prank(player1);
        uint256 rand1 = fakeClaim.random(0);
        uint256 rand2 = fakeClaim.random(1);
        vm.roll(block.number + 1);
        uint256 rand3 = fakeClaim.random(0);
        uint256 rand4 = fakeClaim.random(1);
        assertNotEq(rand1, rand2);
        assertNotEq(rand1, rand3);
        assertNotEq(rand1, rand4);
        uint256 ONE_HUNDRED_PERCENT = 10000;
        assertTrue(rand1 < ONE_HUNDRED_PERCENT);
        assertTrue(rand2 < ONE_HUNDRED_PERCENT);
        assertTrue(rand3 < ONE_HUNDRED_PERCENT);
        assertTrue(rand4 < ONE_HUNDRED_PERCENT);
    }

    function testNothingToClaim() public {
        uint256 daysPlayedToClaim = fakeClaim.daysPlayedToClaim();
        uint256 daysPlayed = daysPlayedToClaim + 3;
        vm.prank(passportWalletAddress);
        fakeCheckin.setDaysPlayed(daysPlayed);

        fakeClaim.setRand(1);

        vm.prank(passportWalletAddress);
        vm.expectRevert(abi.encodeWithSelector(
            Claim.NoTokensAvailableForClaim.selector));
        fakeClaim.claim();
    }

    function testClaimEarly() public {
        addTokens();

        uint256 daysPlayedToClaim = fakeClaim.daysPlayedToClaim();
        uint256 daysPlayed = daysPlayedToClaim - 1;
        vm.prank(passportWalletAddress);
        fakeCheckin.setDaysPlayed(daysPlayed);

        fakeClaim.setRand(1);

        vm.prank(passportWalletAddress);
        vm.expectRevert(abi.encodeWithSelector(
            Claim.ClaimTooEarly.selector, daysPlayed, 0));
        fakeClaim.claim();
    }

    function addTokens() public {
        vm.prank(tokenAdmin);
        mockERC1155.setApprovalForAll(address(fakeClaim), true);

        Claim.ClaimableToken memory token;
        token = Claim.ClaimableToken({
            erc1155Contract: address(mockERC1155),
            tokenId: TOK1_TOKEN_ID,
            balance: TOK1_AMOUNT,
            percentage: TOK1_PERCENTAGE
        });
        vm.prank(tokenAdmin);
        vm.expectEmit(true, true, true, true);
        emit TokensAdded(1, address(mockERC1155), TOK1_TOKEN_ID, TOK1_AMOUNT, TOK1_PERCENTAGE);
        fakeClaim.addMoreTokens(token);

        token = Claim.ClaimableToken({
            erc1155Contract: address(mockERC1155),
            tokenId: TOK2_TOKEN_ID,
            balance: TOK2_AMOUNT,
            percentage: TOK2_PERCENTAGE
        });
        vm.prank(tokenAdmin);
        vm.expectEmit(true, true, true, true);
        emit TokensAdded(2, address(mockERC1155), TOK2_TOKEN_ID, TOK2_AMOUNT, TOK2_PERCENTAGE);
        fakeClaim.addMoreTokens(token);

        token = Claim.ClaimableToken({
            erc1155Contract: address(mockERC1155),
            tokenId: TOK3_TOKEN_ID,
            balance: TOK3_AMOUNT,
            percentage: TOK3_PERCENTAGE
        });
        vm.prank(tokenAdmin);
        vm.expectEmit(true, true, true, true);
        emit TokensAdded(3, address(mockERC1155), TOK3_TOKEN_ID, TOK3_AMOUNT, TOK3_PERCENTAGE);
        fakeClaim.addMoreTokens(token);

        token = Claim.ClaimableToken({
            erc1155Contract: address(mockERC1155),
            tokenId: TOK4_TOKEN_ID,
            balance: TOK4_AMOUNT,
            percentage: TOK4_PERCENTAGE
        });
        vm.prank(tokenAdmin);
        vm.expectEmit(true, true, true, true);
        emit TokensAdded(4, address(mockERC1155), TOK4_TOKEN_ID, TOK4_AMOUNT, TOK4_PERCENTAGE);
        fakeClaim.addMoreTokens(token);

        token = Claim.ClaimableToken({
            erc1155Contract: address(mockERC1155),
            tokenId: TOK5_TOKEN_ID,
            balance: TOK5_AMOUNT,
            percentage: TOK5_PERCENTAGE
        });
        vm.prank(tokenAdmin);
        vm.expectEmit(true, true, true, true);
        emit TokensAdded(5, address(mockERC1155), TOK5_TOKEN_ID, TOK5_AMOUNT, TOK5_PERCENTAGE);
        fakeClaim.addMoreTokens(token);
    }

    function checkClaim(uint256 _percentage, uint256 _tokenId) public {
        addTokens();

        uint256 daysPlayedToClaim = fakeClaim.daysPlayedToClaim();
        uint256 daysPlayed = daysPlayedToClaim + 3;
        vm.prank(passportWalletAddress);
        fakeCheckin.setDaysPlayed(daysPlayed);

        fakeClaim.setRand(_percentage);

        vm.prank(passportWalletAddress);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(address(fakeClaim), address(fakeClaim), 
            passportWalletAddress, _tokenId, 1);
        vm.expectEmit(true, true, true, true);
        emit Claimed(passportWalletAddress, address(mockERC1155), _tokenId, daysPlayed, 0);
        fakeClaim.claim();
    }
}

