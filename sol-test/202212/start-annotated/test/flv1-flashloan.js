// SPDX-License-Identifier: MIT

contract('FlashLoanV1, Flashloan', function(accounts) {
    let common = require('./common');
    let commonFlashloan = require('./common-flashloan')

    beforeEach(async function () {
        flashLoanContract = await common.getTestFlashLoanV1();
    })

    it("fulfilled flashloan", async function() {
        await commonFlashloan.flashloan(flashLoanContract, accounts);
    });

    it("flashloan pay more than needed", async function() {
        await commonFlashloan.flashloanReturnMoreThanNeeded(flashLoanContract, accounts);
    });

    it("flashloan paid too little", async function() {
        await commonFlashloan.flashloanReturnTooLittle(flashLoanContract, accounts);
    });

    it("flashloan application revert", async function() {
        await commonFlashloan.flashloanApplicationRevert(flashLoanContract, accounts);
    });

    it("flashloan attempt to loan more than available", async function() {
        await commonFlashloan.flashloanMoreMoneyThanAvailable(flashLoanContract, accounts);
    });

});