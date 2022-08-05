
// SPDX-License-Identifier: BSD
pragma solidity ^0.8.0;

library SomeOtherLibrary  {
    function add(uint self, uint b) external pure returns (uint) {
        return self+b;
    }
    function checkCondition(bool value) external pure returns (bool)  {
        return value;
    }
}
contract BuiltIn {
    using SomeOtherLibrary for *;
    function add3(uint number) external pure returns (uint) {
        return number.add(3);
    }

    function checkForTruthy(bool checker) external pure returns (bool) {
        return checker.checkCondition();
    }
}