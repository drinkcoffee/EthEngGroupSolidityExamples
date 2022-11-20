// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "./PauseMeV1.sol";

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
contract FlashLoanV1 is PauseMeV1 {
    uint256 constant INTEREST_DIVISOR = 1000000;

    // Minimum period a deposit must be held, in blocks.
    uint256 constant MIN_HOLD_PERIOD = 1000;

    error TransferError(string _msg, bytes _revertInfo);

    event FlashCallResult(bool _success, bytes _result);

    struct Deposit {
        address beneficiary;
        uint256 balance;
        uint256 investmentBlock;
    }
    mapping (uint256 => Deposit) public accounts;


    // Current interest rate per block.
    uint256 public interestRatePerBlock;

    // Interest earned that hasn't been distributed
    uint256 public profit;

    // A combination of time (number of blocks) and amount deposited, for all deposits.
    // Used to work out how much to pay out: a fail proportion given how much has been
    // invested and for how long.
    uint256 depositVolume;

    uint256 totalDepositValue;

    uint256 lastDepositWithdrawalBlock;


    // transaction to config the contract.
    function initialiser(bytes calldata /*not used */) external {
        lastDepositWithdrawalBlock = block.number;
    }


    function setInterestRate(uint256 _rate) external onlyAdmin {
        interestRatePerBlock = _rate;
    }

    function deposit(uint256 _depositId, address _beneficiary, uint256 _amount) payable external whenNotPaused {
        require(msg.value == _amount, "Deposit amount incorrect");
        accounts[_depositId].balance = _amount;
        accounts[_depositId].beneficiary = _beneficiary;
        accounts[_depositId].investmentBlock = block.number;

        depositVolume += totalDepositValue * (block.number - lastDepositWithdrawalBlock) + _amount;
        totalDepositValue += _amount;
        lastDepositWithdrawalBlock = block.number;

    }

    /*
     * Close a deposit and pay to the beneficiary.
     *
     * @param _depostId The deposit to close.
     */
    function payout(uint256 _depositId) external whenNotPaused {
        uint256 investmentBlock = accounts[_depositId].investmentBlock;
        require(block.number > MIN_HOLD_PERIOD + investmentBlock, "Too early to withdraw");
        address beneficiary = accounts[_depositId].beneficiary;
        uint256 numBlocks = block.number - investmentBlock;
        uint256 myDepositVolume = numBlocks * accounts[_depositId].balance;

        uint256 tempDepositVolume = depositVolume + totalDepositValue * (block.number - lastDepositWithdrawalBlock);

        uint256 myPercentage = INTEREST_DIVISOR * myDepositVolume / tempDepositVolume;
        uint256 payoutValue = profit * myPercentage / INTEREST_DIVISOR;

        depositVolume = tempDepositVolume - myDepositVolume;
        lastDepositWithdrawalBlock = block.number;

        (bool sent, bytes memory data) = beneficiary.call{value: payoutValue}("");
        if (!sent) {
            revert TransferError("Send failed", data);
        }

    }


    /**
     * Loan some tokens. All tokens must be paid out plus interest by the time the call
     * returns to this function.
     *
     * @param _contract The application contract to call.
     * @param _data The function selector and ABI encoded parameters to call
     * @param _loanAmount The amount of Ether to borrow.
     */
    function flashLoan(address _contract, bytes calldata _data, uint256 _loanAmount) external {
        uint256 originalBal = address(this).balance;
        uint256 expactedBal = originalBal + _loanAmount * interestRatePerBlock / INTEREST_DIVISOR;

        (bool success, bytes memory result) = _contract.call{value: _loanAmount}(_data);
        emit FlashCallResult(success, result);

        finalBal = address(this).balance;
        require(expactedBal >= finalBal, "Not enough interest paid");

        profit += finalBal - originalBal;
    }
}

