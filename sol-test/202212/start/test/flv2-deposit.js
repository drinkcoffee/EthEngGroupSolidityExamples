// SPDX-License-Identifier: MIT

contract('FlashLoanV2, Deposit', function(accounts) {
    let common = require('./common');
    let commonDeposit = require('./common-deposit')

    it("deposit", async function() {
        let flashLoanContract = await common.getFlashLoanV2();
        await commonDeposit.deposit(flashLoanContract, accounts);
    });

    it("multiDepositPayout", async function() {
        let flashLoanContract = await common.getTestFlashLoanV2();
        await commonDeposit.multiDepositPayout(flashLoanContract, accounts);
    });

    it("depositWhilePaused", async function() {
        let flashLoanContract = await common.getFlashLoanV2();
        await commonDeposit.depositWhilePaused(flashLoanContract, accounts);
    });

});