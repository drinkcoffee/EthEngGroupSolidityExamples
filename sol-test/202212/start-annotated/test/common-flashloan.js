// SPDX-License-Identifier: MIT
let common = require('./common');
const truffleAssert = require("truffle-assertions");

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

        await truffleAssert.fails(
            flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount),
            truffleAssert.ErrorType.REVERT,
            "Not enough interest paid."
        );
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

        await truffleAssert.fails(
            flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount),
            truffleAssert.ErrorType.REVERT,
            "Fail call."
        );
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

        await truffleAssert.fails(
            flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount),
            truffleAssert.ErrorType.REVERT,
            ""
        );
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

        await truffleAssert.fails(
            flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount),
            truffleAssert.ErrorType.REVERT,
            "Paused!"
        );
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

        await truffleAssert.fails(
            flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount),
            truffleAssert.ErrorType.REVERT,
            "Can't deposit during flash loan."
        );
    },
};




