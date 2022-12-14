// SPDX-License-Identifier: MIT
const truffleAssert = require('truffle-assertions');

module.exports = {

    adminAfterInitialise: async function(flashLoanContract, accounts) {
        const admin = await flashLoanContract.admin.call();
        assert.equal(admin, accounts[0], "Unexpectedly, deployer not owner");
    },

    transferOwnership: async function(flashLoanContract, accounts) {
        // Admin should now be accounts[0]
        await flashLoanContract.transferOwnership(accounts[1]); // Note: default transaction signer is accounts[0]

        const admin = await flashLoanContract.admin.call();
        assert.equal(admin, accounts[1], "Unexpectedly, ownership not changed");
    },

    transferOwnershipAccessControl: async function(flashLoanContract, accounts) {
        // transferOwnership from the wrong account
        await truffleAssert.fails(
            flashLoanContract.transferOwnership(accounts[1],  {from: accounts[1]}),
            truffleAssert.ErrorType.REVERT,
            "Not admin!"
        );
    },

};




