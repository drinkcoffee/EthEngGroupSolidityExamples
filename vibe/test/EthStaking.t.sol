// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {EthStaking} from "../src/EthStaking.sol";

interface Vm {
    function prank(address) external;
    function warp(uint256) external;
    function deal(address, uint256) external;
    function expectRevert(bytes calldata) external;
}

contract EthStakingTest {
    error AssertionFailed();

    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    EthStaking private staking;

    address private governor1 = address(0x101);
    address private governor2 = address(0x102);
    address private governor3 = address(0x103);
    address private staker = address(0xBEEF);
    address private slashReceiver = address(0xCAFE);

    function setUp() public {
        address[] memory governors = new address[](3);
        governors[0] = governor1;
        governors[1] = governor2;
        governors[2] = governor3;
        staking = new EthStaking(governors, 2, slashReceiver);
        vm.deal(staker, 10 ether);
    }

    function testDepositAndWithdrawAfterDelay() public {
        uint256 depositAmount = 1 ether;

        vm.prank(staker);
        staking.deposit{value: depositAmount}();

        uint256 readyAt = block.timestamp + staking.WITHDRAWAL_DELAY();
        vm.prank(staker);
        staking.requestWithdrawal(depositAmount);

        vm.expectRevert(abi.encodeWithSelector(EthStaking.WithdrawalNotReady.selector, readyAt));
        vm.prank(staker);
        staking.withdraw();

        vm.warp(readyAt);
        vm.prank(staker);
        staking.withdraw();

        assertEq(staking.stakeBalance(staker), 0);
    }

    function testSlashDuringWithdrawalDelay() public {
        uint256 depositAmount = 2 ether;

        vm.prank(staker);
        staking.deposit{value: depositAmount}();
        vm.prank(staker);
        staking.requestWithdrawal(depositAmount);

        vm.prank(governor1);
        staking.signalSlash(staker);
        vm.prank(governor2);
        staking.signalSlash(staker);

        assertEq(staking.stakeBalance(staker), 0);
        assertEq(address(slashReceiver).balance, depositAmount);

        vm.expectRevert(abi.encodeWithSelector(EthStaking.NoWithdrawal.selector));
        vm.prank(staker);
        staking.withdraw();
    }

    function testSlashAfterWithdrawalPeriodEndsReverts() public {
        uint256 depositAmount = 3 ether;

        vm.prank(staker);
        staking.deposit{value: depositAmount}();

        uint256 endAt = block.timestamp + staking.WITHDRAWAL_DELAY();
        vm.prank(staker);
        staking.requestWithdrawal(depositAmount);

        vm.warp(endAt + 1);
        vm.expectRevert(abi.encodeWithSelector(EthStaking.WithdrawalPeriodEnded.selector, endAt));
        vm.prank(governor1);
        staking.signalSlash(staker);
    }

    function testThresholdRequiresMultipleVotes() public {
        uint256 depositAmount = 1 ether;

        vm.prank(staker);
        staking.deposit{value: depositAmount}();

        vm.prank(governor1);
        staking.signalSlash(staker);

        assertEq(staking.stakeBalance(staker), depositAmount);

        vm.prank(governor2);
        staking.signalSlash(staker);

        assertEq(staking.stakeBalance(staker), 0);
        assertEq(address(slashReceiver).balance, depositAmount);
    }

    function assertEq(uint256 left, uint256 right) internal pure {
        if (left != right) {
            revert AssertionFailed();
        }
    }

    function assertEq(address left, address right) internal pure {
        if (left != right) {
            revert AssertionFailed();
        }
    }
}
