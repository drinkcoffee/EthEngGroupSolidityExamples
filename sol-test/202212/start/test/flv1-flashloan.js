// SPDX-License-Identifier: MIT
const FakeBlockNumberFlashLoanV1 = artifacts.require("./test/TestFlashLoanV1.sol");
const TestFlashLoanReceiver = artifacts.require("./TestFlashLoanReceiver.sol");
const truffleAssert = require('truffle-assertions');

contract('FlashLoanV1, Flashloan', function(accounts) {
    let flashLoanContract;

    beforeEach(async function () {
        flashLoanContract = await FakeBlockNumberFlashLoanV1.new(1000);        
        await flashLoanContract.pause();
    })

    it("fulfilled flashloan", async function() {

        const depositId = "0x01";
        const amount = 100000;
        const beneficiary = accounts[2];
        await flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount});

        const params = web3.eth.abi.encodeParameters(
            ['uint256', 'uint256'],
            [0, 13]
        );
        const loanAmount = 10000;
        const flashLoanReceiver = await TestFlashLoanReceiver.new(flashLoanContract.address, {value: 100000000});

        await flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount)

        const profit = await flashLoanContract.profit.call();
        assert.equal(11, profit, "Unexpected profit");        
    });

    it("flashloan pay more than needed", async function() {
        const depositId = "0x01";
        const amount = 100000;
        const beneficiary = accounts[2];
        await flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount});

        const params = web3.eth.abi.encodeParameters(
            ['uint256', 'uint256'],
            [2, 13]
        );
        const loanAmount = 10000;
        const flashLoanReceiver = await TestFlashLoanReceiver.new(flashLoanContract.address, {value: 100000000});
        await flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount)

        const profit = await flashLoanContract.profit.call();
        assert.equal(12, profit, "Unexpected profit");

    });

    it("flashloan paid too little", async function() {
        const depositId = "0x01";
        const amount = 100000;
        const beneficiary = accounts[2];
        await flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount});

        const params = web3.eth.abi.encodeParameters(
            ['uint256', 'uint256'],
            [1, 13]
        );
        const loanAmount = 10000;
        const flashLoanReceiver = await TestFlashLoanReceiver.new(flashLoanContract.address, {value: 100000000});

        await truffleAssert.fails(
            flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount),
            truffleAssert.ErrorType.REVERT,
            'Not enough interest paid'
        );
    });

    it("flashloan application revert", async function() {
        const depositId = "0x01";
        const amount = 100000;
        const beneficiary = accounts[2];
        await flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount});

        const params = web3.eth.abi.encodeParameters(
            ['uint256', 'uint256'],
            [3, 13]
        );
        const loanAmount = 10000;
        const flashLoanReceiver = await TestFlashLoanReceiver.new(flashLoanContract.address, {value: 100000000});

        await truffleAssert.fails(
            flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount),
            truffleAssert.ErrorType.REVERT,
            'Fail call'
        );
    });

    it("flashloan attempt to loan more than available", async function() {
        const depositId = "0x01";
        const amount = 100000;
        const beneficiary = accounts[2];
        await flashLoanContract.deposit(depositId, beneficiary, {from: accounts[1], value: amount});

        const params = web3.eth.abi.encodeParameters(
            ['uint256', 'uint256'],
            [0, 13]
        );
        const loanAmount = 99999999;
        const flashLoanReceiver = await TestFlashLoanReceiver.new(flashLoanContract.address, {value: 100000000});

        let didNotTriggerError = false;

        await truffleAssert.fails(
            flashLoanContract.flashLoan(flashLoanReceiver.address, params, loanAmount),
            truffleAssert.ErrorType.REVERT,
            //TODO: can specify error string to match
        );

    });

    // it("flashloan while paused", async function() {
    //     let flashLoanContract = await common.getTestFlashLoanV1();
    //     await commonFlashloan.flashloanPause(flashLoanContract, accounts);
    // });

    // it("call deposit during flashloan", async function() {
    //     let flashLoanContract = await common.getTestFlashLoanV1();
    //     await commonFlashloan.flashloanCallDeposit(flashLoanContract, accounts);
    // });

});