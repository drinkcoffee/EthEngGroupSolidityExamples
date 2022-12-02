// SPDX-License-Identifier: MIT

module.exports = {

    upgradeToSelf: async function(flashLoanContract) {
        let notUsed = web3.eth.abi.encodeParameter('bytes', '0x616263');

        let didNotTriggerError = false;
        try {
            await flashLoanContract.upgrade(notUsed);
            didNotTriggerError = true;
        } catch(err) {
            // Expect that a revert will be called: see assert below.
            // console.log("ERROR! " + err.message);
        }
        assert.equal(didNotTriggerError, false, "Unexpectedly, calling upgrade on deployed version didn't revert");
    },

};




