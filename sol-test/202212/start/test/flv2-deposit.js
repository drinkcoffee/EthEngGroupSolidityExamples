// SPDX-License-Identifier: MIT

contract('FlashLoanV2, Deposit', function(accounts) {
    let common = require('./common');
    let commonDeposit = require('./common-deposit')

    beforeEach(async function () {
        flashLoanContract = await common.getFlashLoanV2();
    })

    it("deposit", async function() {
        await commonDeposit.deposit(flashLoanContract, accounts);
    });

    it("multiDepositPayout", async function() {
        flashLoanContract = await common.getTestFlashLoanV2();
        await commonDeposit.multiDepositPayout(flashLoanContract, accounts);
    });

    it("depositWhilePaused", async function() {
        await commonDeposit.depositWhilePaused(flashLoanContract, accounts);
    });

});