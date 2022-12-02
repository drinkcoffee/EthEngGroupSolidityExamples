// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "./IAdmin.sol";
import "./IPauseMe.sol";

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
interface FlashLoanInterface /* Avoid complexities of diamond inheritence by commenting this out: is IAdmin, IPauseMe */ {

    error TransferError(string _msg, bytes _revertInfo);

    event Deposit(uint256 _depositId);

    event Payout(uint256 _depositId, uint256 _payoutValue);

    event FlashLoan(uint256 _balBefore, uint256 _fee,  uint256 _profit);

    /**
     * Code to upgrade from one version of the contract to the next, in the context of the proxy.
     *
     * @param _params ABI Encoded parameters to be used to upgrade the contract.
     */
    function upgrade(bytes calldata _params) external;

    /**
     * Set the interest rate. The interest only takes effect when changeInterestRate is called.
     *
     * @param _rate The interest rate, scaled based on FlashLoanBase.INTEREST_DIVISOR.
     */
    function setInterestRate(uint256 _rate) external;

    /**
     * Affect the interest rate change.
     */
    function changeInterestRate() external;


    function deposit(uint256 _depositId, address _beneficiary) payable external;


    /*
     * Close a deposit and pay to the beneficiary.
     *
     * @param _depostId The deposit to close.
     */
    function payout(uint256 _depositId) external;

    /**
     * Loan some tokens. All tokens must be paid out plus interest by the time the call
     * returns to this function.
     *
     * @param _contract The application contract to call.
     * @param _params ABI encoded parameters to call
     * @param _loanAmount The amount of Ether to borrow.
     */
    function flashLoan(address _contract, bytes calldata _params, uint256 _loanAmount) external;


    // ***** Functions to return storage variables. *****

    function interestRatePerBlock() external view returns (uint256);

    function nextInterestRatePerBlock() external view returns (uint256);

    function interestRateChangeBlock() external view returns (uint256);

    function profit() external view returns (uint256);

    function depositVolume() external view returns (uint256);

    function totalDepositValue() external view returns (uint256);

    function lastDepositWithdrawalBlock() external view returns (uint256);
}

