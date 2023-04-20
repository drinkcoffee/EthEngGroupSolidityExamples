// Copyright (c) Peter Robinson 2023
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface FlashLoanReceiverInterface {
   function flashLoanReceiver(uint256 _fee, bytes calldata _params) external payable;
}

/**
 */
abstract contract Reentrancy {
    uint256 constant INTEREST_DIVISOR = 1000000;

    // Minimum period a deposit must be held, in blocks.
    uint256 constant MIN_HOLD_PERIOD = 1000;

    // Minimum number of blocks between calling setInterestRate and changeInterestRate.
    uint256 constant MIN_INTEREST_RATE_CHANGE_PERIOD = 1000;

    event FlashLoan(uint256 _balBefore, uint256 _fee,  uint256 _profit);

    // TODO: Advanced: Gas Saving: To save gas, only store a hash, and pass in params as calldata
    struct DepositStruct {
        address beneficiary;
        uint256 amount;
        uint256 interestRate;
        uint256 depositBlockNumber;
    }
    mapping (uint256 => DepositStruct) public accounts;

    // Current interest rate per block.
    uint256 public interestRatePerBlock;
    // The forthcoming interest rate.
    uint256 public nextInterestRatePerBlock;
    // Block number when nextInterestRate will take effect.
    uint256 public interestRateChangeBlock;

    // Interest earned that hasn't been distributed
    uint256 public profit;

    // A combination of time (number of blocks) and amount deposited, for all deposits.
    // Used to work out how much to pay out.
    // The deposit volume is as at the lastDepositWithdrawalBlock. It is recalculated
    // when deposit or payout are called.
    uint256 public depositVolume;

    // The amount of Eth deposited in the contract.
    uint256 public totalDepositValue;

    // The last block that the deposit volume has been recalculated for.
    uint256 public lastDepositWithdrawalBlock;

    // TODO  Reentrancy check
    // TODO bool inFlashLoan;


    address private owner;

    constructor() {
        owner = msg.sender;
    }


    // TODO Basic: should have authentication
    function setInterestRate(uint256 _rate) external {
        require(owner == msg.sender, "Not authorised");
        interestRatePerBlock = _rate;
    }



    function flashLoan(address _receiver, bytes calldata _params, uint256 _loanAmount) external {
        // TODO  Prevent recursive calls. An attacker could all flashLoan, and then recursively call it
        // TODO  so that inFlashLoan gets set to false, and then call deposit using flash loaned funds.
        // TODO require(!inFlashLoan, "Can't recursively call flash loan");
        // TODO inFlashLoan = true;

        uint256 originalBal = address(this).balance;
        require(_loanAmount <= originalBal, "Not enough funds");
        // Add one, so that if the loan amount is very small, there will be some interest paid.
        uint256 fee = _loanAmount * interestRatePerBlock / INTEREST_DIVISOR + 1;

        FlashLoanReceiverInterface receiver = FlashLoanReceiverInterface(_receiver);
        receiver.flashLoanReceiver{value: _loanAmount}(fee, _params);

        uint256 finalBal = address(this).balance;
        require(originalBal + fee <= finalBal, "Not enough interest paid");
        profit += finalBal - originalBal;
        emit FlashLoan(originalBal, fee, profit);

        // TODO inFlashLoan = false;
    }
}
