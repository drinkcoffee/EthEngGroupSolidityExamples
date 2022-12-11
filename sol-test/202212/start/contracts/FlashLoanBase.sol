// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.16;

import "./Admin.sol";
import "./PauseMeBase.sol";
import "./VersionInit.sol";
import "./interfaces/FlashLoanInterface.sol";
import "./interfaces/FlashLoanReceiverInterface.sol";

/**
 */
abstract contract FlashLoanBase is FlashLoanInterface, VersionInit, Admin, PauseMeBase {
    uint256 constant INTEREST_DIVISOR = 1000000;

    // Minimum period a deposit must be held, in blocks.
    uint256 constant MIN_HOLD_PERIOD = 1000;

    // Minimum number of blocks between calling setInterestRate and changeInterestRate.
    uint256 constant MIN_INTEREST_RATE_CHANGE_PERIOD = 1000;

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

    // Reentrancy check
    bool inFlashLoan;

    // Be able to receive Eth from the flash loan receiver contract
    fallback() external payable {
    }
    receive() external payable {
    }

    constructor(uint256 _interestRatePerBlock) {
        lastDepositWithdrawalBlock = blockNumber();
        interestRatePerBlock = _interestRatePerBlock;
        nextInterestRatePerBlock = _interestRatePerBlock;
    }


    function setInterestRate(uint256 _rate) external override onlyAdmin {
        nextInterestRatePerBlock = _rate;
        interestRateChangeBlock = blockNumber() + MIN_INTEREST_RATE_CHANGE_PERIOD;
    }

    function changeInterestRate() external override {
        require(interestRateChangeBlock < blockNumber(), "Can't change interest rate yet");
        interestRatePerBlock = nextInterestRatePerBlock;
    }


    function deposit(uint256 _depositId, address _beneficiary) payable external override whenNotPaused {


        uint256 amount = msg.value;
        require(msg.value != 0, "Deposit must be greater than zero");


        accounts[_depositId].beneficiary = _beneficiary;
        accounts[_depositId].amount = amount;
        accounts[_depositId].interestRate = interestRatePerBlock;
        uint256 blockNum = blockNumber();
        accounts[_depositId].depositBlockNumber = blockNum;

        uint256 total = totalDepositValue;
        depositVolume += total * (blockNum - lastDepositWithdrawalBlock);
        totalDepositValue = total + amount;
        lastDepositWithdrawalBlock = blockNum;

        emit Deposit(_depositId);
    }

    function payout(uint256 _depositId) external override whenNotPaused {
        require(accounts[_depositId].beneficiary == msg.sender, "Deposit does not exist");

        uint256 blockNum = blockNumber();
        require(blockNum > MIN_HOLD_PERIOD + accounts[_depositId].depositBlockNumber, "Too early to withdraw");

        uint256 numBlocks = blockNum - accounts[_depositId].depositBlockNumber;
        uint256 myDepositVolume = numBlocks * accounts[_depositId].amount;

        uint256 tempDepositVolume = depositVolume + totalDepositValue * (blockNum - lastDepositWithdrawalBlock);
        lastDepositWithdrawalBlock = blockNum;
        totalDepositValue -= accounts[_depositId].amount;

        uint256 myProfit = profit * myDepositVolume / tempDepositVolume;
        profit = profit - myProfit;
        uint256 payoutValue = myProfit + accounts[_depositId].amount;

        depositVolume = tempDepositVolume - myDepositVolume;

        {
            (bool sent, bytes memory data) = accounts[_depositId].beneficiary.call{value: payoutValue}("");
            if (!sent) {
                revert TransferError("Send failed", data);
            }
        }

        // Indicate payout has occurred.
        accounts[_depositId].beneficiary = address(0);

        emit Payout(_depositId, payoutValue);
    }

    function flashLoan(address _receiver, bytes calldata _params, uint256 _loanAmount) external override {
        // Prevent recursive calls. An attacker could all flashLoan, and then recursively call it
        // so that inFlashLoan gets set to false, and then call deposit using flash loaned funds.
        require(!inFlashLoan, "Can't recursively call flash loan");
        inFlashLoan = true;

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

        inFlashLoan = false;
    }

    /**
     * Calls to blockNumber should call this function. This allows test code to
     * override the block number.
     *
     * @return The block number.
     */
    function blockNumber() internal virtual view returns (uint256) {
        return block.number;
    }
}
