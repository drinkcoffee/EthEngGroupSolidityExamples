// SPDX-License-Identifier: MIT
let common = require('./common');

module.exports = {

    flashloan: async function(flashLoanContract, accounts) {
        await flashLoanContract.pause();

        const depositId = "0x01";
        const amount = 100000;
        const beneficiary = accounts[2];
        await flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount});

        const params = web3.eth.abi.encodeParameters(
            ['uint256', 'uint256'],
            [0, 13]
        );
        const loanAmount = 10000;
        const flashLoanReceiver = await common.getTestFlashLoanReceiver(flashLoanContract);
        await flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount)

        const profit = await flashLoanContract.profit.call();
        assert.equal(11, profit, "Unexpected profit");
    },

    flashloanReturnMoreThanNeeded: async function(flashLoanContract, accounts) {
        await flashLoanContract.pause();

        const depositId = "0x01";
        const amount = 100000;
        const beneficiary = accounts[2];
        await flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount});

        const params = web3.eth.abi.encodeParameters(
            ['uint256', 'uint256'],
            [2, 13]
        );
        const loanAmount = 10000;
        const flashLoanReceiver = await common.getTestFlashLoanReceiver(flashLoanContract);
        await flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount)

        const profit = await flashLoanContract.profit.call();
        assert.equal(12, profit, "Unexpected profit");
    },

    flashloanReturnTooLittle: async function(flashLoanContract, accounts) {
        await flashLoanContract.pause();

        const depositId = "0x01";
        const amount = 100000;
        const beneficiary = accounts[2];
        await flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount});

        const params = web3.eth.abi.encodeParameters(
            ['uint256', 'uint256'],
            [1, 13]
        );
        const loanAmount = 10000;
        const flashLoanReceiver = await common.getTestFlashLoanReceiver(flashLoanContract);

        let didNotTriggerError = false;
        try {
            await flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount)
            didNotTriggerError = true;
        } catch(err) {
            // Expect that a revert will be called: see assert below.
            // console.log("ERROR! " + err.message);
        }
        assert.equal(didNotTriggerError, false, "Unexpectedly, loan receiver not paying enough didn't cause a revert");
    },

    flashloanApplicationRevert: async function(flashLoanContract, accounts) {
        await flashLoanContract.pause();

        const depositId = "0x01";
        const amount = 100000;
        const beneficiary = accounts[2];
        await flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount});

        const params = web3.eth.abi.encodeParameters(
            ['uint256', 'uint256'],
            [3, 13]
        );
        const loanAmount = 10000;
        const flashLoanReceiver = await common.getTestFlashLoanReceiver(flashLoanContract);

        let didNotTriggerError = false;
        try {
            await flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount)
            didNotTriggerError = true;
        } catch(err) {
            // Expect that a revert will be called: see assert below.
            // console.log("ERROR! " + err.message);
        }
        assert.equal(didNotTriggerError, false, "Unexpectedly, loan receiver reverting didn't cause a revert");
    },

    flashloanMoreMoneyThanAvailable: async function(flashLoanContract, accounts) {
        await flashLoanContract.pause();

        const depositId = "0x01";
        const amount = 100000;
        const beneficiary = accounts[2];
        await flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount});

        const params = web3.eth.abi.encodeParameters(
            ['uint256', 'uint256'],
            [0, 13]
        );
        const loanAmount = 99999999;
        const flashLoanReceiver = await common.getTestFlashLoanReceiver(flashLoanContract);

        let didNotTriggerError = false;
        try {
            await flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount)
            didNotTriggerError = true;
        } catch(err) {
            // Expect that a revert will be called: see assert below.
            // console.log("ERROR! " + err.message);
        }
        assert.equal(didNotTriggerError, false, "Unexpectedly, didn't revert when not enough funds for loan");
    },

    flashloanPause: async function(flashLoanContract, accounts) {
        const depositId = "0x01";
        const amount = 100000;
        const beneficiary = accounts[2];
        await flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount});

        const params = web3.eth.abi.encodeParameters(
            ['uint256', 'uint256'],
            [0, 13]
        );
        const loanAmount = 10000;
        const flashLoanReceiver = await common.getTestFlashLoanReceiver(flashLoanContract);

        await flashLoanContract.pause();

        let didNotTriggerError = false;
        try {
            await flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount)
            didNotTriggerError = true;
        } catch(err) {
            // Expect that a revert will be called: see assert below.
            // console.log("ERROR! " + err.message);
        }
        assert.equal(didNotTriggerError, false, "Unexpectedly, didn't revert when paused");
    },

    flashloanCallDeposit: async function(flashLoanContract, accounts) {
        await flashLoanContract.pause();

        const depositId = "0x01";
        const amount = 100000;
        const beneficiary = accounts[2];
        await flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount});

        const params = web3.eth.abi.encodeParameters(
            ['uint256', 'uint256', 'uint256', 'address'],
            [4, 13, 100, accounts[3]]
        );
        const loanAmount = 10000;
        const flashLoanReceiver = await common.getTestFlashLoanReceiver(flashLoanContract);

        let didNotTriggerError = false;
        try {
            await flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount)
            didNotTriggerError = true;
        } catch(err) {
            // Expect that a revert will be called: see assert below.
            // console.log("ERROR! " + err.message);
        }
        assert.equal(didNotTriggerError, false, "Unexpectedly, didn't revert when deposit called");
    },
};




