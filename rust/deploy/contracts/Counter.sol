// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ICounter} from "./ICounter.sol";

contract Counter is ICounter {
    uint256 public number;

    constructor(uint256 _initialValue) {
        number = _initialValue;
    }

    function setNumber(uint256 _newNumber) external {
        number = _newNumber;
    }

    function increment() public {
        number++;
    }

    function getNumberPlus17() external view returns(uint256) {
        return number + 17;
    }

    function getNumberPlus17a() external view returns(uint256 numPlus17) {
        numPlus17 = number + 17;
    }

}
