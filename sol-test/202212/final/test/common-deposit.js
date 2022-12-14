// SPDX-License-Identifier: MIT
const truffleAssert = require("truffle-assertions");

module.exports = {

    deposit: async function(flashLoanContract, accounts) {
        const depositId = "0x01";
        const amount = 10000;
        const beneficiary = accounts[2];
        const interestRatePerBlock = await flashLoanContract.interestRatePerBlock.call();
        let result = await flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount});
        const receipt = result.receipt
        // console.log(receipt);
        const depositBlockNumber = receipt.blockNumber;

        // The following is equivalent to:
        //   keccak256(abi.encodePacked(_beneficiary, _amount, _interestRate, _blockNumber));
        const javaScriptdepositHash = web3.utils.soliditySha3(
            {t: 'address', v: beneficiary},
            {t: 'uint256', v: amount},
            {t: 'uint256', v: interestRatePerBlock},
            {t: 'uint256', v: depositBlockNumber},
        );

        const solidityDepositHash = await flashLoanContract.accounts(depositId);
        assert.equal(javaScriptdepositHash, solidityDepositHash, "Unexpectedly, deposit hashes didn't match");

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

    },

    // flashLoanContract must be a test version of the contract that allows the block number to be set.
    multiDepositPayout: async function(flashLoanContract, accounts) {
        // First deposit
        const depositId1 = "0x01";
        const amount1 = 10000;
        const beneficiary1 = accounts[2];
        const depositBlockNumber1 = 1000;
        const interestRatePerBlock = await flashLoanContract.interestRatePerBlock.call();

        await flashLoanContract.setFakeBlockNumber(depositBlockNumber1);
        await flashLoanContract.deposit(depositId1, beneficiary1, {from: accounts[1], value: amount1});

        // Check that the block number faking is working.
        // The following is equivalent to:
        //   keccak256(abi.encodePacked(_beneficiary, _amount, _interestRate, _blockNumber));
        const javaScriptdepositHash = web3.utils.soliditySha3(
            {t: 'address', v: beneficiary1},
            {t: 'uint256', v: amount1},
            {t: 'uint256', v: interestRatePerBlock},
            {t: 'uint256', v: depositBlockNumber1},
        );
        const solidityDepositHash = await flashLoanContract.accounts(depositId1);
        assert.equal(javaScriptdepositHash, solidityDepositHash, "Unexpectedly, deposit hashes didn't match");

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
    },


    depositWhilePaused: async function(flashLoanContract, accounts) {
        await flashLoanContract.pause();

        const depositId = "0x01";
        const amount = 10000;
        const beneficiary = accounts[2];
        await truffleAssert.fails(
            flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount}),
            truffleAssert.ErrorType.REVERT,
            "Paused!"
        );
    },

};




