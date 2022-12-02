// SPDX-License-Identifier: MIT

contract('FlashLoanV2, interest rate', function(accounts) {
    let common = require('./common');
    let commonInterest = require('./common-interest-rate');

     it("interest rates after initialise", async function() {
         let flashLoanContract = await common.getFlashLoanV2();
         await commonInterest.interestRateAfterInitialise(flashLoanContract);
    });

    it("change interest rates", async function() {
        let flashLoanContract = await common.getTestFlashLoanV2();
        await commonInterest.changeInterestRate(flashLoanContract);
    });

    it("set interest rate access control", async function() {
        let flashLoanContract = await common.getTestFlashLoanV2();
        await commonInterest.setInterestRateAccessControl(flashLoanContract, accounts);
    });

    it("change interest rate access control", async function() {
        let flashLoanContract = await common.getTestFlashLoanV2();
        await commonInterest.changeInterestRateAccessControl(flashLoanContract, accounts);
    });
});