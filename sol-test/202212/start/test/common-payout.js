// SPDX-License-Identifier: MIT
let common = require('./common');

module.exports = {
    // flashLoanContract must be a test version of the contract that allows the block number to be set.
    payoutNoProfit: async function(flashLoanContract, accounts) {
        flashLoanContract.pause();

        // First deposit
        const depositId1 = "0x01";
        const amount1 = web3.utils.toWei('1', 'ether');
        const beneficiary1 = accounts[2];
        const depositBlockNumber1 = 1000;
        const interestRatePerBlock = await flashLoanContract.interestRatePerBlock.call();

        await flashLoanContract.setFakeBlockNumber(depositBlockNumber1);
        await flashLoanContract.deposit(depositId1, beneficiary1, {from: accounts[1], value: amount1});

        // Second deposit
        const depositId2 = "0x02";
        const amount2 = web3.utils.toWei('2', 'ether');
        const beneficiary2 = accounts[3];
        const depositBlockNumber2 = 1020;

        await flashLoanContract.setFakeBlockNumber(depositBlockNumber2);
        await flashLoanContract.deposit(depositId2, beneficiary2, {from: accounts[1], value: amount2});

        let vol = BigInt(amount1) * (BigInt(depositBlockNumber2) - BigInt(depositBlockNumber1));
        let depositVolume = await flashLoanContract.depositVolume.call();
        assert.equal(vol, depositVolume, "depositVolume doesn't match volume");

        let total = BigInt(amount1) + BigInt(amount2);

        let lastDepositWithdrawalBlock = await flashLoanContract.lastDepositWithdrawalBlock.call();
        assert.equal(depositBlockNumber2, lastDepositWithdrawalBlock, "lastDepositWithdrawalBlock was not updated for deposit");

        // Third deposit
        const depositId3 = "0x03";
        const amount3 = web3.utils.toWei('10', 'ether');
        const beneficiary3 = accounts[3];
        const depositBlockNumber3 = 1050;

        await flashLoanContract.setFakeBlockNumber(depositBlockNumber3);
        await flashLoanContract.deposit(depositId3, beneficiary3, {from: accounts[1], value: amount3});

        vol = vol + total * (BigInt(depositBlockNumber3) - BigInt(depositBlockNumber2));
        depositVolume = await flashLoanContract.depositVolume.call();
        assert.equal(vol, BigInt(depositVolume), "depositVolume doesn't match volume");
        total += BigInt(amount3);

        // Withdraw second deposit
        const withdrawalBlockNumber4 = 3000;
        await flashLoanContract.setFakeBlockNumber(withdrawalBlockNumber4);
        const balBenificiary2Before = await web3.eth.getBalance(beneficiary2);
        let result = await flashLoanContract.payout(depositId2, {from: beneficiary2});

        let event = result.receipt.logs[0].event;
        assert.equal("Payout", event, "Wrong event emitted");
        let eventDepId = result.receipt.logs[0].args[0];
        assert.equal(BigInt(depositId2), eventDepId, "Wrong deposit id");
        let eventAmount = result.receipt.logs[0].args[1];
        assert.equal(amount2, eventAmount, "Wrong deposit amount");
        //console.log("effectiveGasPrice: " + result.receipt.effectiveGasPrice);
        //console.log("gas used: " + result.receipt.gasUsed);
        const gasCost = result.receipt.gasUsed * result.receipt.effectiveGasPrice;
        //console.log("gas cost: " + gasCost);

        const balBenificiary2After = await web3.eth.getBalance(beneficiary2);
        //console.log("balBenificiary2Before: " + balBenificiary2Before);
        //console.log("balBenificiary2After: " + balBenificiary2After);
        const payout = BigInt(balBenificiary2After) - BigInt(balBenificiary2Before);
        //console.log("payout: " + payout);
        const payoutPlusGasCost = payout + BigInt(gasCost);
        //console.log("check: " + payoutPlusGasCost);
        assert.equal(amount2, payoutPlusGasCost, "payout didn't match amount deposited (allowing for gas cost)");

        depositVolume = await flashLoanContract.depositVolume.call();
        vol = vol + total * (BigInt(withdrawalBlockNumber4) - BigInt(depositBlockNumber3));
        let withdrawalVol = BigInt(amount2) * (BigInt(withdrawalBlockNumber4) - BigInt(depositBlockNumber2));
        vol = vol - withdrawalVol;
        assert.equal(BigInt(vol), BigInt(depositVolume), "depositVolume doesn't match volume");

        let totalDepositValue = await flashLoanContract.totalDepositValue.call();
        total = total - BigInt(amount2);
        assert.equal(total, totalDepositValue, "totalDepositValue doesn't match total");

        lastDepositWithdrawalBlock = await flashLoanContract.lastDepositWithdrawalBlock.call();
        assert.equal(withdrawalBlockNumber4, lastDepositWithdrawalBlock, "lastDepositWithdrawalBlock was not updated for withdrawal");

        const profit = await flashLoanContract.profit.call();
        assert.equal(0, profit, "Profit should be zero");
    },


    // TODO pause for payout
    // TODO payout too early
    // TODO payout invalid deposit id
    // TODO payout and fail transfer
};




