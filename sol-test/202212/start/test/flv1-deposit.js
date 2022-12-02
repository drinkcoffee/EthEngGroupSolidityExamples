// SPDX-License-Identifier: MIT

contract('FlashLoanV1, Deposit', function(accounts) {
    let common = require('./common');
    let commonDeposit = require('./common-deposit')

    it("deposit", async function() {
        let flashLoanContract = await common.getFlashLoanV1();
        await commonDeposit.deposit(flashLoanContract, accounts);
    });

    it("multiDepositPayout", async function() {
        let flashLoanContract = await common.getTestFlashLoanV1();
        await commonDeposit.multiDepositPayout(flashLoanContract, accounts);
    });

    it("depositWhilePaused", async function() {
        let flashLoanContract = await common.getFlashLoanV1();
        await commonDeposit.depositWhilePaused(flashLoanContract, accounts);
    });

});