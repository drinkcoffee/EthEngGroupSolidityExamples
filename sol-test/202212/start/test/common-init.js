// SPDX-License-Identifier: MIT

module.exports = {

    initTwice: async function(flashLoanContract) {
        // Interest rate is 100, which is 0.01%
        interestRateParam = web3.eth.abi.encodeParameter('uint256', '0x0000000000000000000000000000000000000000000000000000000000000064');

        let didNotTriggerError = false;
        try {
            await flashLoanContract.initialise(interestRateParam);
            didNotTriggerError = true;
        } catch(err) {
            // Expect that a revert will be called: see assert below.
            // console.log("ERROR! " + err.message);
        }
        assert.equal(didNotTriggerError, false, "Unexpectedly, calling initialise twice didn't revert");
    },
};




