// SPDX-License-Identifier: MIT
const FlashLoanV1 = artifacts.require("./FlashLoanV1.sol");
const FakeBlockNumberFlashLoanV1 = artifacts.require("./test/TestFlashLoanV1.sol");
const truffleAssert = require('truffle-assertions');

contract('FlashLoanV1, Deposit', function(accounts) {
    it("deposit", async function() {
        let flashLoanContract =await FlashLoanV1.new(1000);
        await flashLoanContract.pause();

        const depositId = "0x01";
        const amount = 10000;
        const beneficiary = accounts[2];
        const interestRatePerBlock = await flashLoanContract.interestRatePerBlock.call();
        let result = await flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount});
        const receipt = result.receipt
        // console.log(receipt);
        const depositBlockNumber = receipt.blockNumber;

        const profit = await flashLoanContract.profit.call();
        assert.equal(0, profit, "Profit should be zero");

        const depositVolume = await flashLoanContract.depositVolume.call();
        assert.equal(0, depositVolume, "depositVolume doesn't match volume");

        const totalDepositValue = await flashLoanContract.totalDepositValue.call();
        assert.equal(amount, totalDepositValue, "totalDepositValue doesn't match deposit amount");

        const lastDepositWithdrawalBlock = await flashLoanContract.lastDepositWithdrawalBlock.call();
        assert.equal(depositBlockNumber, lastDepositWithdrawalBlock, "lastDepositWithdrawalBlock was not updated for deposit");

        let balance = await web3.eth.getBalance(flashLoanContract.address);
        assert.equal(amount, balance, "Contract balance does not equal amount");        
    });

    it("multiDepositPayout", async function() {
        let flashLoanContract =await FakeBlockNumberFlashLoanV1.new(1000);
        await flashLoanContract.pause();

        // First deposit
        const depositId1 = "0x01";
        const amount1 = 10000;
        const beneficiary1 = accounts[2];
        const depositBlockNumber1 = 1000;
        const interestRatePerBlock = await flashLoanContract.interestRatePerBlock.call();

        await flashLoanContract.setFakeBlockNumber(depositBlockNumber1);
        await flashLoanContract.deposit(depositId1, beneficiary1, {from: accounts[1], value: amount1});

        // Second deposit
        const depositId2 = "0x02";
        const amount2 = 100;
        const beneficiary2 = accounts[3];
        const depositBlockNumber2 = 1020;

        await flashLoanContract.setFakeBlockNumber(depositBlockNumber2);
        await flashLoanContract.deposit(depositId2, beneficiary2, {from: accounts[1], value: amount2});

        let depositVolume = await flashLoanContract.depositVolume.call();
        let vol = amount1 * (depositBlockNumber2 - depositBlockNumber1);
        assert.equal(vol, depositVolume, "depositVolume doesn't match volume");

        let totalDepositValue = await flashLoanContract.totalDepositValue.call();
        let total = amount1 + amount2;
        assert.equal(total, totalDepositValue, "totalDepositValue doesn't match total");

        let lastDepositWithdrawalBlock = await flashLoanContract.lastDepositWithdrawalBlock.call();
        assert.equal(depositBlockNumber2, lastDepositWithdrawalBlock, "lastDepositWithdrawalBlock was not updated for deposit");

        // Third deposit
        const depositId3 = "0x03";
        const amount3 = 1000000;
        const beneficiary3 = accounts[3];
        const depositBlockNumber3 = 1050;

        await flashLoanContract.setFakeBlockNumber(depositBlockNumber3);
        await flashLoanContract.deposit(depositId3, beneficiary3, {from: accounts[1], value: amount3});

        depositVolume = await flashLoanContract.depositVolume.call();
        vol = vol + total * (depositBlockNumber3 - depositBlockNumber2);
        assert.equal(vol, depositVolume, "depositVolume doesn't match volume");

        totalDepositValue = await flashLoanContract.totalDepositValue.call();
        total += amount3;
        assert.equal(total, totalDepositValue, "totalDepositValue doesn't match total");

        lastDepositWithdrawalBlock = await flashLoanContract.lastDepositWithdrawalBlock.call();
        assert.equal(depositBlockNumber3, lastDepositWithdrawalBlock, "lastDepositWithdrawalBlock was not updated for deposit");

    });

    it("depositWhilePaused", async function() {
        let flashLoanContract =await FlashLoanV1.new(1000);
        const depositId = "0x01";
        const amount = 10000;
        const beneficiary = accounts[2];

        await truffleAssert.fails(
            flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount}),
            truffleAssert.ErrorType.REVERT,
            'Paused!'
        );
    });
});