// SPDX-License-Identifier: MIT

contract('FlashLoanV1, Pause', function(accounts) {
    let common = require('./common');
    let commonPause = require('./common-pause');

    // it("pause after initialise", async function() {
    //     let flashLoanContract = await common.getFlashLoanV1();
    //     await commonPause.pauseAfterInitialise(flashLoanContract);
    // });

    // it("pause request", async function() {
    //     let flashLoanContract = await common.getFlashLoanV1();
    //     await commonPause.pauseRequest(flashLoanContract);
    // });

    // it("unpause request", async function() {
    //     let flashLoanContract = await common.getFlashLoanV1();
    //     await commonPause.unpauseRequest(flashLoanContract);
    // });

    it("pause request access control", async function() {
        let flashLoanContract = await common.getFlashLoanV1();
        await commonPause.pauseRequestAccessControl(flashLoanContract);
    });

    it("unpause request access control", async function() {
        let flashLoanContract = await common.getFlashLoanV1();
        await commonPause.unpauseRequestAccessControl(flashLoanContract);
    });
});