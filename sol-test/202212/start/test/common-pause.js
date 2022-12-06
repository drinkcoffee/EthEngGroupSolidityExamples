// SPDX-License-Identifier: MIT

module.exports = {

    pauseAfterInitialise: async function(flashLoanContract) {
        const paused = await flashLoanContract.paused.call();
        assert.equal(paused, false, "Unexpectedly, paused after initialise");
    },

    pauseRequest: async function(flashLoanContract) {
        await flashLoanContract.pause();
        const paused = await flashLoanContract.paused.call();
        assert.equal(paused, true, "Unexpectedly, paused after initialise");
    },

    unpauseRequest: async function(flashLoanContract) {
        await flashLoanContract.pause();
        await flashLoanContract.unpause();
        const paused = await flashLoanContract.paused.call();
        assert.equal(paused, false, "Unexpectedly, paused after initialise");
    },
};




