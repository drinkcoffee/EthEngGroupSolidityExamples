// SPDX-License-Identifier: MIT

contract('FlashLoanV1, Payout', function(accounts) {
    let common = require('./common');
    let commonPayout = require('./common-payout')

    it("multiDepositPayout", async function() {
        let flashLoanContract = await common.getTestFlashLoanV1();
        await commonPayout.payoutNoProfit(flashLoanContract, accounts);
    });

});