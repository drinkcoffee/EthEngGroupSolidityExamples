// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.9;

import "./PauseMe.sol"

/**
 *
 */
contract PayMe is PauseMe {
    constant uint256 INTEREST_DIVISOR = 1000000;

    uint256 interestRatePerBlock;

    struct Account {
        address beneficiary;
        uint256 balance;
        uint256 investmentBlock;
    }
    mapping (address -> uint256) accounts;


    function register(address _beneficiary, uint256 _amount) payable {
        accounts[msg.sender].balance = _amount;
        accounts[msg.sender].beneficiary = _beneficiary;
        accounts[msg.sender].investmentBlock = block.number;
    }

    function payout(address _investor, uint256 _amount) {
        uint256 amount = 
    }




}


// TODO idea
// register account, amount
// or withdrawl if blocknumber % 13 == 0
