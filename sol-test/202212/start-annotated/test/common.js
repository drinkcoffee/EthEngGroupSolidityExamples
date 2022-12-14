// SPDX-License-Identifier: MIT

const FlashLoanV1 = artifacts.require("./FlashLoanV1.sol");
const FakeBlockNumberFlashLoanV1 = artifacts.require("./test/TestFlashLoanV1.sol");
const FlashLoanV2 = artifacts.require("./FlashLoanV2.sol");
const FakeBlockNumberFlashLoanV2 = artifacts.require("./test/TestFlashLoanV2.sol");
const UpgradeProxy = artifacts.require("./UpgradeProxy.sol");
const TestFlashLoanReceiver = artifacts.require("./TestFlashLoanReceiver.sol");

// Value must match constant in FlashLoanBase
const MIN_HOLD_PERIOD = 1000;
// Value must match constant in FlashLoanBase
const MIN_INTEREST_RATE_CHANGE_PERIOD = 1000;


function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}


module.exports = {
    MIN_HOLD_PERIOD: MIN_HOLD_PERIOD,
    MIN_INTEREST_RATE_CHANGE_PERIOD: MIN_INTEREST_RATE_CHANGE_PERIOD,

    getFlashLoanV1: async function() {
        // Interest rate is 1000, which is 0.1%
        let interestRateParam = web3.eth.abi.encodeParameter('uint256', '0x00000000000000000000000000000000000000000000000000000000000003E8');
        return await FlashLoanV1.new(interestRateParam);
    },
    getTestFlashLoanV1: async function() {
        // Interest rate is 1000, which is 0.1%
        let interestRateParam = web3.eth.abi.encodeParameter('uint256', '0x00000000000000000000000000000000000000000000000000000000000003E8');
        return await FakeBlockNumberFlashLoanV1.new(interestRateParam);
    },

    getFlashLoanV2: async function() {
        // Interest rate is 1000, which is 0.1%
        let interestRateParam = web3.eth.abi.encodeParameter('uint256', '0x00000000000000000000000000000000000000000000000000000000000003E8');
        return await FlashLoanV2.new(interestRateParam);
    },
    getTestFlashLoanV2: async function() {
        // Interest rate is 1000, which is 0.1%
        let interestRateParam = web3.eth.abi.encodeParameter('uint256', '0x00000000000000000000000000000000000000000000000000000000000003E8');
        return await FakeBlockNumberFlashLoanV2.new(interestRateParam);
    },


    getFlashLoanV1InitViaProxy: async function() {
        // Interest rate is 1000, which is 0.1%
        let interestRateParam = web3.eth.abi.encodeParameter('uint256', '0x00000000000000000000000000000000000000000000000000000000000003E8');
        let flashLoanContract = await FlashLoanV1.new();
        let upgradeProxy = await UpgradeProxy.new(flashLoanContract.address, interestRateParam);
        return await FlashLoanV1.at(upgradeProxy.address);
    },
    getTestFlashLoanV1InitViaProxy: async function() {
        // Interest rate is 1000, which is 0.1%
        let interestRateParam = web3.eth.abi.encodeParameter('uint256', '0x00000000000000000000000000000000000000000000000000000000000003E8');
        let flashLoanContract = await FakeBlockNumberFlashLoanV1.new();
        let upgradeProxy = await UpgradeProxy.new(flashLoanContract.address, interestRateParam);
        return await FakeBlockNumberFlashLoanV1.at(upgradeProxy.address);
    },

    getFlashLoanV2InitViaProxy: async function() {
        // Interest rate is 1000, which is 0.1%
        let interestRateParam = web3.eth.abi.encodeParameter('uint256', '0x00000000000000000000000000000000000000000000000000000000000003E8');
        let flashLoanContract = await FlashLoanV2.new();
        let upgradeProxy = await UpgradeProxy.new(flashLoanContract.address, interestRateParam);
        return await FlashLoanV2.at(upgradeProxy.address);
    },
    getTestFlashLoanV2InitViaProxy: async function() {
        // Interest rate is 1000, which is 0.1%
        let interestRateParam = web3.eth.abi.encodeParameter('uint256', '0x00000000000000000000000000000000000000000000000000000000000003E8');
        let flashLoanContract = await FakeBlockNumberFlashLoanV2.new();
        let upgradeProxy = await UpgradeProxy.new(flashLoanContract.address, interestRateParam);
        return await FakeBlockNumberFlashLoanV2.at(upgradeProxy.address);
    },

    getTestFlashLoanReceiver: async function(flashLoanContract) {
        return await TestFlashLoanReceiver.new(flashLoanContract.address, {value: 100000000});
    },


};




