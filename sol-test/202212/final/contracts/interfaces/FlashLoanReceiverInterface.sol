// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

/**
 * Receive a flash loan.
 */
interface FlashLoanReceiverInterface {

    /**
     * Receive some loaned tokens.
     *
     * @param _fee Fee to be paid, in addition to amount loaned.
     * @param _params ABI encoded parameters.
     */
    function flashLoanReceiver(uint256 _fee, bytes calldata _params) external payable;
}

