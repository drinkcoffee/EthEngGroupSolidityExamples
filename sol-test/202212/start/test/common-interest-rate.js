// SPDX-License-Identifier: MIT
let common = require('./common');

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

        let didNotTriggerError = false;
        try {
            await testFlashLoanContract.changeInterestRate();
            didNotTriggerError = true;
        } catch(err) {
            // Expect that a revert will be called: see assert below.
            // console.log("ERROR! " + err.message);
        }
        assert.equal(didNotTriggerError, false, "Unexpectedly, changeInterestRate prior to wait did not trigger revert");

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
        let didNotTriggerError = false;
        try {
            await testFlashLoanContract.setInterestRate(10, accounts[1]);
            didNotTriggerError = true;
        } catch(err) {
            // Expect that a revert will be called: see assert below.
            // console.log("ERROR! " + err.message);
        }
        assert.equal(didNotTriggerError, false, "Unexpectedly, changeInterestRate prior to wait did not trigger revert");
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




