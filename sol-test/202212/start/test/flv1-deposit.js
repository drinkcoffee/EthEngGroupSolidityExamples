// SPDX-License-Identifier: MIT

contract('FlashLoanV1, Deposit', function(accounts) {
    let common = require('./common');
    let commonDeposit = require('./common-deposit')

    beforeEach(async function () {
        flashLoanContract = await common.getFlashLoanV1();
    })

    it("deposit", async function() {
        await commonDeposit.deposit(flashLoanContract, accounts);
    });

    it("multiDepositPayout", async function() {
        flashLoanContract = await common.getTestFlashLoanV1();
        await commonDeposit.multiDepositPayout(flashLoanContract, accounts);
    });

    it("depositWhilePaused", async function() {
        await commonDeposit.depositWhilePaused(flashLoanContract, accounts);
    });

});