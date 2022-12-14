// SPDX-License-Identifier: MIT

contract('FlashLoanV2, Admin', function(accounts) {
    let common = require('./common');
    let commonAdmin = require('./common-admin')

    beforeEach(async function () {
        flashLoanContract = await common.getFlashLoanV2();
    })

    it("admin after initialise", async function() {
        await commonAdmin.adminAfterInitialise(flashLoanContract, accounts);
    });

    it("transfer ownership", async function() {
        await commonAdmin.transferOwnership(flashLoanContract, accounts);
    });

    it("transfer ownership access control", async function() {
        await commonAdmin.transferOwnershipAccessControl(flashLoanContract, accounts);
    });

});