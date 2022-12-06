// SPDX-License-Identifier: MIT
const truffleAssert = require("truffle-assertions");

module.exports = {

    initTwice: async function(flashLoanContract) {
        // Interest rate is 100, which is 0.01%
        interestRateParam = web3.eth.abi.encodeParameter('uint256', '0x0000000000000000000000000000000000000000000000000000000000000064');

        await truffleAssert.fails(
            flashLoanContract.initialise(interestRateParam),
            truffleAssert.ErrorType.REVERT,
            "Already initialised."
        );
    },
};




