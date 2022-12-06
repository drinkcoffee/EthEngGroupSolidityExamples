// SPDX-License-Identifier: MIT

contract('FlashLoanV2, interest rate', function(accounts) {
    let common = require('./common');
    let commonInterest = require('./common-interest-rate');

    beforeEach(async function () {
        flashLoanContract = await common.getTestFlashLoanV2();
    })

    it("interest rates after initialise", async function() {
         await commonInterest.interestRateAfterInitialise(flashLoanContract);
    });

    it("change interest rates", async function() {
        await commonInterest.changeInterestRate(flashLoanContract);
    });

    it("set interest rate access control", async function() {
        await commonInterest.setInterestRateAccessControl(flashLoanContract, accounts);
    });

    it("change interest rate access control", async function() {
        await commonInterest.changeInterestRateAccessControl(flashLoanContract, accounts);
    });
});