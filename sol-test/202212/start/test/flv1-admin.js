// SPDX-License-Identifier: MIT
const FlashLoanV1 = artifacts.require("./FlashLoanV1.sol");
const truffleAssert = require('truffle-assertions');

contract('FlashLoanV1, Admin', function(accounts) {
    let flashLoanContract;

    beforeEach(async function () {
        // Interest rate is 1000, which is 0.1%
        flashLoanContract = await FlashLoanV1.new(1000);
    });
    
    it("admin after initialise", async function() {
        const admin = await flashLoanContract.admin.call();
        assert.equal(admin, accounts[0], "Unexpectedly, deployer not owner");
    });

    it("transfer ownership", async function() {
        // Admin should now be accounts[0]
        await flashLoanContract.transferOwnership(accounts[1]); // Note: default transaction signer is accounts[0]

        const admin = await flashLoanContract.admin.call();
        assert.equal(admin, accounts[1], "Unexpectedly, ownership not changed");        
    });

    it("transfer ownership access control", async function() {
        await truffleAssert.fails(
            flashLoanContract.transferOwnership(accounts[1],  {from: accounts[1]}),
            truffleAssert.ErrorType.REVERT,
            "Not admin!"
        );
    });

});