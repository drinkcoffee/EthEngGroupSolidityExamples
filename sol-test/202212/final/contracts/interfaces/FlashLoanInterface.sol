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

    event Deposit(uint256 _depositId, bytes32 _depositHash);

    event Payout(uint256 _depositId, uint256 _payoutValue);

    event FlashLoan(uint256 _balBefore, uint256 _fee,  uint256 _profit);

    /**
     * Code to initialise the contract in the context of the proxy.
     * Note: Can only be called once.
     *
     * @param _params ABI Encoded parameters to be used to initialise the contract.
     */
    function initialise(bytes calldata _params) external;

    /**
     * Code to upgrade from one version of the contract to the next, in the context of the proxy.
     *
     * @param _params ABI Encoded parameters to be used to upgrade the contract.
     */
    function upgrade(bytes calldata _params) external;

    /**
     * Set the interest rate. The interest only takes effect when changeInterestRate is called.
     * Note that there is a time period between when this interest rate change is set with
     * this function, and when the interest rate change can be actioned with the chainInterestRate
     * function.
     *
     * @param _rate The interest rate, scaled based on FlashLoanBase.INTEREST_DIVISOR.
     */
    function setInterestRate(uint256 _rate) external;

    /**
     * Affect the interest rate change.
     */
    function changeInterestRate() external;


    /**
     * Deposit some value into the contract.
     *
     * @param _depositId The identifier used to specify this deposit. This can not have been used
     *        in a previous deposit.
     * @param _beneficiary The party that will be able to call payout.
     *
     */
    function deposit(uint256 _depositId, address _beneficiary) payable external;


    /*
     * Close a deposit and pay to the beneficiary. The benficiary must be the entity
     * calling this function. The amount deposited plus a proportion of the profit is
     * paid out.
     *
     * @param _depostId The deposit to close.
     * @param _amount The amount of the deposit.
     * @param _interestRate Interest rate at the time of the deposit.
     * @param _investmentBlock The block number when the deposit occurred.
     */
    function payout(uint256 _depositId, uint256 _amount, uint256 _interestRate, uint256 _investmentBlock) external;

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

