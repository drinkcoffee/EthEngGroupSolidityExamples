// SPDX-License-Identifier: MIT

const truffleAssert = require("truffle-assertions");
contract('FlashLoanV2, Pause', function(accounts) {
    let common = require('./common');
    let commonPause = require('./common-pause');

    beforeEach(async function () {
        flashLoanContract = await common.getFlashLoanV2();
    })

    it("pause after initialise", async function() {
        await commonPause.pauseAfterInitialise(flashLoanContract);
    });

    it("pause request", async function() {
        await commonPause.pauseRequest(flashLoanContract);
    });

    it("unpause request", async function() {
        await commonPause.unpauseRequest(flashLoanContract);
    });

    it("pause request access control", async function() {
        await truffleAssert.fails(
            flashLoanContract.pause({from: accounts[1]}),
            truffleAssert.ErrorType.REVERT,
            "Not pauser!"
        );
    });

    it("unpause request access control", async function() {
        await truffleAssert.fails(
            flashLoanContract.unpause({from: accounts[1]}),
            truffleAssert.ErrorType.REVERT,
            "Not pauser!"
        );
    });


    it("pauser after initialise", async function() {
        const pauser = await flashLoanContract.pauser.call();
        assert.equal(pauser, accounts[0], "Unexpectedly, wrong account for pauser");
    });

    it("change pauser role", async function() {
        // Admin should now be accounts[0]
        await flashLoanContract.transferPauserRole(accounts[1]); // Note: default transaction signer is accounts[0]
        const pauser = await flashLoanContract.pauser.call();
        assert.equal(pauser, accounts[1], "Unexpectedly, pauser role not changed");
        const admin = await flashLoanContract.admin.call();
        assert.equal(admin, accounts[0], "Unexpectedly, admin role changed");
    });

    it("change pauser access control", async function() {
        let didNotTriggerError = false;
        try {
            await flashLoanContract.transferPauserRole(accounts[1],  {from: accounts[1]});
            didNotTriggerError = true;
        } catch(err) {
            // Expect that a revert will be called: see assert below.
            // console.log("ERROR! " + err.message);
        }
        assert.equal(didNotTriggerError, false, "Unexpectedly, transferPauserRole from the wrong account didn't cause a revert");
    });
});