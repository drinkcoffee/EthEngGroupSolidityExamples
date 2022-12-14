// SPDX-License-Identifier: MIT
let common = require('./common');
const truffleAssert = require("truffle-assertions");

module.exports = {

    interestRateAfterInitialise: async function(flashLoanContract) {
        const interestRatePerBlock = await flashLoanContract.interestRatePerBlock.call();
        assert.equal(interestRatePerBlock, 1000, "Unexpectedly, initial interestRatePerBlock not 1000");
        const nextInterestRatePerBlock = await flashLoanContract.nextInterestRatePerBlock.call();
        assert.equal(nextInterestRatePerBlock, 1000, "Unexpectedly, initial nextInterestRatePerBlock not 1000");
        const interestRateChangeBlock = await flashLoanContract.interestRateChangeBlock.call();
        assert.equal(interestRateChangeBlock, 0, "Unexpectedly, initial nextInterestChangeBlock not 0");
    },

    changeInterestRate: async function(testFlashLoanContract) {
        await testFlashLoanContract.setInterestRate(10);
        let interestRatePerBlock = await testFlashLoanContract.interestRatePerBlock.call();
        assert.equal(interestRatePerBlock, 1000, "Unexpectedly, initial interestRatePerBlock not 1000");
        let nextInterestRatePerBlock = await testFlashLoanContract.nextInterestRatePerBlock.call();
        assert.equal(nextInterestRatePerBlock, 10, "Unexpectedly, initial nextInterestRatePerBlock not 10");
        let interestRateChangeBlock = await testFlashLoanContract.interestRateChangeBlock.call();
        let block = await web3.eth.getBlock("latest")
        let expectedInterestRateChangeBlock = block.number + common.MIN_INTEREST_RATE_CHANGE_PERIOD;
        assert.equal(interestRateChangeBlock, expectedInterestRateChangeBlock, "Unexpectedly, nextInterestChangeBlock incorrect");

        await testFlashLoanContract.setFakeBlockNumber(expectedInterestRateChangeBlock);

        await truffleAssert.fails(
            flashLoanContract.changeInterestRate(),
            truffleAssert.ErrorType.REVERT,
            "Can't change interest rate yet."
        );

        // One block later, it should work.
        await testFlashLoanContract.setFakeBlockNumber(expectedInterestRateChangeBlock + 1);
        await testFlashLoanContract.changeInterestRate();
        await testFlashLoanContract.setFakeBlockNumber(0);

        interestRatePerBlock = await testFlashLoanContract.interestRatePerBlock.call();
        assert.equal(interestRatePerBlock, 10, "Unexpectedly, interestRatePerBlock has not changed");
        nextInterestRatePerBlock = await testFlashLoanContract.nextInterestRatePerBlock.call();
        assert.equal(nextInterestRatePerBlock, 10, "Unexpectedly, nextInterestRatePerBlock has changed");
        interestRateChangeBlock = await testFlashLoanContract.interestRateChangeBlock.call();
        assert.equal(interestRateChangeBlock, expectedInterestRateChangeBlock, "Unexpectedly, nextInterestChangeBlock has changed");
    },

    setInterestRateAccessControl: async function(flashLoanContract, accounts) {
        await truffleAssert.fails(
            flashLoanContract.setInterestRate(10, {from: accounts[1]}),
            truffleAssert.ErrorType.REVERT,
            "Not admin!"
        );
    },

    changeInterestRateAccessControl: async function(testFlashLoanContract, accounts) {
        await testFlashLoanContract.setInterestRate(10);
        let block = await web3.eth.getBlock("latest")
        let expectedInterestRateChangeBlock = block.number + common.MIN_INTEREST_RATE_CHANGE_PERIOD;
        await testFlashLoanContract.setFakeBlockNumber(expectedInterestRateChangeBlock + 1);
        // Call to changeInterestRate allowed by any account
        await testFlashLoanContract.changeInterestRate(({from: accounts[1]}));
        await testFlashLoanContract.setFakeBlockNumber(0);
    },

};




