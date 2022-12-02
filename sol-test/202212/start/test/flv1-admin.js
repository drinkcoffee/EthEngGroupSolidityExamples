// SPDX-License-Identifier: MIT

contract('FlashLoanV1, Admin', function(accounts) {
    let common = require('./common');
    let commonAdmin = require('./common-admin')

    it("admin after initialise", async function() {
        let flashLoanContract = await common.getFlashLoanV1();
        await commonAdmin.adminAfterInitialise(flashLoanContract, accounts);
    });

    it("transfer ownership", async function() {
        let flashLoanContract = await common.getFlashLoanV1();
        await commonAdmin.transferOwnership(flashLoanContract, accounts);
    });

    it("transfer ownership access control", async function() {
        let flashLoanContract = await common.getFlashLoanV1();
        await commonAdmin.transferOwnershipAccessControl(flashLoanContract, accounts);
    });

});