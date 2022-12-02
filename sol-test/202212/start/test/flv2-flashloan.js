// SPDX-License-Identifier: MIT

contract('FlashLoanV2, Flashloan', function(accounts) {
    let common = require('./common');
    let commonFlashloan = require('./common-flashloan')

    it("fulfilled flashloan", async function() {
        let flashLoanContract = await common.getTestFlashLoanV2();
        await commonFlashloan.flashloan(flashLoanContract, accounts);
    });

    it("flashloan pay more than needed", async function() {
        let flashLoanContract = await common.getTestFlashLoanV2();
        await commonFlashloan.flashloanReturnMoreThanNeeded(flashLoanContract, accounts);
    });

    it("flashloan paid too little", async function() {
        let flashLoanContract = await common.getTestFlashLoanV2();
        await commonFlashloan.flashloanReturnTooLittle(flashLoanContract, accounts);
    });

    it("flashloan application revert", async function() {
        let flashLoanContract = await common.getTestFlashLoanV2();
        await commonFlashloan.flashloanApplicationRevert(flashLoanContract, accounts);
    });

    it("flashloan attempt to loan more than available", async function() {
        let flashLoanContract = await common.getTestFlashLoanV2();
        await commonFlashloan.flashloanMoreMoneyThanAvailable(flashLoanContract, accounts);
    });

    // it("flashloan while paused", async function() {
    //     let flashLoanContract = await common.getTestFlashLoanV2();
    //     await commonFlashloan.flashloanPause(flashLoanContract, accounts);
    // });
    //
    // it("call deposit during flashloan", async function() {
    //     let flashLoanContract = await common.getTestFlashLoanV2();
    //     await commonFlashloan.flashloanCallDeposit(flashLoanContract, accounts);
    // });

});