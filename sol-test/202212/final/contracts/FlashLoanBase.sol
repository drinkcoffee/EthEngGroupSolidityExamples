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

    // Map between deposit id and hash of deposit information:
    //  keccak256(abi.encodePacked(_beneficiary, _amount, _interestRate, _depositBlockNumber))
    mapping (uint256 => bytes32) public accounts;

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

    // Add dummy variable buffer to allow for upgrade.
    uint256[100] private __gapFlashLoanBase;

    // Be able to receive Eth from the flash loan receiver contract
    fallback() external payable {
    }
    receive() external payable {
    }

    function initialiseFlashLoanBase(bytes calldata _params) internal {
        lastDepositWithdrawalBlock = blockNumber();
        interestRatePerBlock = abi.decode(_params, (uint256));
        nextInterestRatePerBlock = interestRatePerBlock;
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
        // An attacker could try to use a flash loan to fund a deposit.
        require(!inFlashLoan, "Can't deposit during flash loan");

        bytes32 depositHash = accounts[_depositId];
        require(depositHash == bytes32(0), "Deposit already exists");

        require(msg.value != 0, "Deposit must be greater than zero");
        uint256 amount = msg.value;


        uint256 blockNum = blockNumber();
        depositHash = calcDepositHash(_beneficiary, amount, interestRatePerBlock, blockNum);
        accounts[_depositId] = depositHash;

        uint256 total = totalDepositValue;
        depositVolume += total * (blockNum - lastDepositWithdrawalBlock);
        totalDepositValue = total + amount;
        lastDepositWithdrawalBlock = blockNum;

        emit Deposit(_depositId, depositHash);
    }

    function payout(uint256 _depositId, uint256 _balance, uint256 _interestRate, uint256 _investmentBlock) external override whenNotPaused {
        // An attacker could try to withdraw funds during a flash loan. No specific
        // attack has been identified for this case.
        require(!inFlashLoan, "Can't payout during flash loan");

        address beneficiary = msg.sender;

        uint256 blockNum = blockNumber();
        require(blockNum > MIN_HOLD_PERIOD + _investmentBlock, "Too early to withdraw");

        {
            bytes32 depositHash = calcDepositHash(beneficiary, _balance, _interestRate, _investmentBlock);
            require(accounts[_depositId] == depositHash, "Deposit does not exist");
        }

        uint256 numBlocks = blockNum - _investmentBlock;
        uint256 myDepositVolume = numBlocks * _balance;

        uint256 tempDepositVolume = depositVolume + totalDepositValue * (blockNum - lastDepositWithdrawalBlock);
        lastDepositWithdrawalBlock = blockNum;
        totalDepositValue -= _balance;

        uint256 myProfit = profit * myDepositVolume / tempDepositVolume;
        profit = profit - myProfit;
        uint256 payoutValue = myProfit + _balance;

        depositVolume = tempDepositVolume - myDepositVolume;

        {
            (bool sent, bytes memory data) = beneficiary.call{value: payoutValue}("");
            if (!sent) {
                revert TransferError("Send failed", data);
            }
        }

        // Indicate payout has occurred.
        accounts[_depositId] = bytes32(0);

        emit Payout(_depositId, payoutValue);
    }

    function flashLoan(address _receiver, bytes calldata _params, uint256 _loanAmount) external override whenNotPaused {
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

    function calcDepositHash(address _beneficiary, uint256 _amount, uint256 _interestRate, uint256 _depositBlockNumber) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_beneficiary, _amount, _interestRate, _depositBlockNumber));
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
