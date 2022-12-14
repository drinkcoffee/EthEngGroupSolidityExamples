// SPDX-License-Identifier: MIT

contract('FlashLoanV2, init', function(accounts) {
    let common = require('./common');
    let commonInit = require('./common-init')

    it("init twice", async function() {
        let flashLoanContract = await common.getFlashLoanV2();
        await commonInit.initTwice(flashLoanContract);
    });

});