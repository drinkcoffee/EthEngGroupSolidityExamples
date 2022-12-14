// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "./PauseMeV1.sol";
import "./FlashLoanBase.sol";

/**
 * Provide Ether flash loans.
 *
 * The borrowing interest rate is configurable. It is not automatically set.
 *
 * Depositors can withdraw their deposit along with their portion of the profit from
 * interest paid. The formula for the proportion to pay each depositor is a combination
 * of how long their deposit has been held and how much they have invested.
 *
 */
contract FlashLoanV1 is PauseMeV1, FlashLoanBase {

    function initialise(bytes calldata _params) external override ifNotInitialised {
        version = VERSION1;
        Admin.initialiseAdmin();
        PauseMeV1.initialisePause();
        FlashLoanBase.initialiseFlashLoanBase(_params);
        initialised = true;
    }

    function upgrade(bytes calldata /* _params */) external pure override {
        revert("Version 1 contract");
    }
}

