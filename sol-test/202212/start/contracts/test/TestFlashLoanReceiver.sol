// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "../interfaces/FlashLoanReceiverInterface.sol";
import "../interfaces/FlashLoanInterface.sol";

contract TestFlashLoanReceiver is FlashLoanReceiverInterface {
    address flashLoanContract;

    event LoanInformation(uint256 _amount, uint256 _fee, uint256 _action);

    constructor(address _flashLoanContract) payable {
        flashLoanContract = _flashLoanContract;
    }

    function flashLoanReceiver(uint256 _fee, bytes calldata _params) external payable {
        address loaner = flashLoanContract;
        require(loaner == msg.sender, "Not called from flash loan contract");
        uint256 loanAmount = msg.value;

        (uint256 action, uint256 check) = abi.decode(_params, (uint256, uint256));
        // As part of the testing, check that the _params is passed through correctly.
        require(check == 13, "Param not expected value");

        emit LoanInformation(loanAmount, _fee, action);

        bool success;
        bytes memory result;
        if (action == 0) { // Return the correct amount
            (success, result) = loaner.call{value: loanAmount + _fee}("");
        }
        else if (action == 1) { // Return less than the required
            (success, result) = loaner.call{value: loanAmount + _fee - 1}("");
        }
        else if (action == 2) { // Return more than required
            (success, result) = loaner.call{value: loanAmount + _fee + 1}("");
        }
        else if (action == 3) { // Revert during loan
            revert("Fail call");
        }
        else if (action == 4) { // Call deposit. Should revert during deposit.
            FlashLoanInterface flashLoaner = FlashLoanInterface(loaner);
            uint256 depositId;
            address beneficiary;
            (,, depositId, beneficiary) = abi.decode(_params, (uint256, uint256, uint256, address));
            flashLoaner.deposit{value: loanAmount}(depositId, beneficiary);
            (success, result) = loaner.call{value: _fee}("");
        }


    }
}
