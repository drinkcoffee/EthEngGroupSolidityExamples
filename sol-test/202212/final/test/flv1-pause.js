// SPDX-License-Identifier: MIT

const truffleAssert = require("truffle-assertions");
contract('FlashLoanV1, Pause', function(accounts) {
    let common = require('./common');
    let commonPause = require('./common-pause');

    beforeEach(async function () {
        flashLoanContract = await common.getFlashLoanV1();
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
            "Not admin!"
        );
    });

    it("unpause request access control", async function() {
        await truffleAssert.fails(
            flashLoanContract.unpause({from: accounts[1]}),
            truffleAssert.ErrorType.REVERT,
            "Not admin!"
        );
    });
});