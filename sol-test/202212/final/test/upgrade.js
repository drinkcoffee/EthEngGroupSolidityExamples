// SPDX-License-Identifier: MIT

const truffleAssert = require('truffle-assertions');
const FlashLoanV2 = artifacts.require("./FlashLoanV2.sol");
const UpgradeProxy = artifacts.require("./UpgradeProxy.sol");



contract('Upgrade', function(accounts) {
    let common = require('./common');

    it("upgrade to self V1", async function() {
        let flashLoanContract = await common.getFlashLoanV1();

        let notUsed = web3.eth.abi.encodeParameter('bytes', '0x616263');
        await truffleAssert.fails(
            flashLoanContract.upgrade(notUsed),
            truffleAssert.ErrorType.REVERT,
            "Version 1 contract"
        );
    });

    it("upgrade to self V2", async function() {
        let flashLoanContract = await common.getFlashLoanV2();

        let notUsed = web3.eth.abi.encodeParameter('bytes', '0x616263');
        await truffleAssert.fails(
            flashLoanContract.upgrade(notUsed),
            truffleAssert.ErrorType.REVERT,
            "Already upgraded"
        );
    });

    it("upgrade v1 to v2", async function() {
        let flashLoanContract = await common.getFlashLoanV1();
        let upgradeProxy = await UpgradeProxy.at(flashLoanContract.address);

        // Store application variables that shouldn't changed.
        await flashLoanContract.transferOwnership(accounts[1]); // Note: default transaction signer is accounts[0]
        const adminBefore = await flashLoanContract.admin.call();
        const pausedBefore = await flashLoanContract.paused.call();

        await flashLoanContract.setInterestRate(10, {from: adminBefore});
        const interestRatePerBlockBefore = await flashLoanContract.interestRatePerBlock.call();
        const nextInterestRatePerBlockBefore = await flashLoanContract.nextInterestRatePerBlock.call();
        const interestRateChangeBlockBefore = await flashLoanContract.interestRateChangeBlock.call();


        // TODO check all state variables

        // Store proxy variables that shouldn't change.
        const proxyAdminBefore = await upgradeProxy.PROXY_admin.call();

        // Upgrade the contract
        let flashLoanContractV2Direct = await FlashLoanV2.new();
        let notUsed = web3.eth.abi.encodeParameter('bytes', '0x616263');
        await upgradeProxy.PROXY_upgrade(flashLoanContractV2Direct.address, notUsed);
        let flashLoanContractV2 = await FlashLoanV2.at(flashLoanContract.address);

        // Check that application variables haven't changed.
        const adminAfter = await flashLoanContract.admin.call();
        assert.equal(adminBefore, adminAfter, "Unexpectedly, admin changed");
        const pausedAfter = await flashLoanContract.paused.call();
        assert.equal(pausedBefore, pausedAfter, "Unexpectedly, paused changed");
        const pauser = await flashLoanContractV2.pauser.call();
        assert.equal(pauser, adminAfter, "Unexpectedly, pauser not set to admin");

        const interestRatePerBlockAfter = await flashLoanContract.interestRatePerBlock.call();
        const nextInterestRatePerBlockAfter = await flashLoanContract.nextInterestRatePerBlock.call();
        const interestRateChangeBlockAfter = await flashLoanContract.interestRateChangeBlock.call();

        assert.equal(interestRatePerBlockBefore.toString(), interestRatePerBlockAfter.toString(), "Unexpectedly, interestRatePerBlock changed");
        assert.equal(nextInterestRatePerBlockBefore.toString(), nextInterestRatePerBlockAfter.toString(), "Unexpectedly, nextInterestRatePerBlock changed");
        assert.equal(interestRateChangeBlockBefore.toString(), interestRateChangeBlockAfter.toString(), "Unexpectedly, interestRateChangeBlock changed");


        // TODO check all state variables

        // Check that proxy variables
        const implementationAfter = await upgradeProxy.PROXY_implementation.call();
        assert.equal(implementationAfter, flashLoanContractV2Direct.address, "Unexpectedly, PROXY_implementation returned the incorrect value");

        const proxyAdminAfter = await upgradeProxy.PROXY_admin.call();
        assert.equal(proxyAdminBefore, proxyAdminAfter, "Unexpectedly, proxy admin changed");
    });


    // TODO Add a test to check that the PROXY upgrade function feeds the parameters through to a dummy V3 implementation contract
});