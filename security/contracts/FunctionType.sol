// SPDX-License-Identifier: BSD
pragma solidity ^0.8.0;

contract FunctionType {
    function(uint256) internal pure returns(uint256)  private funcToUse;

    function change(uint256 _choice) external {
        funcToUse = _choice == 1 ? func1 : func2;
    }

    function callFunc(uint256 _val) external view returns(uint256) {
        return funcToUse(_val);
    }

    function func1(uint256 _val) internal pure returns(uint256) {
        return _val + 1;
    }

    function func2(uint256 _val) internal pure returns(uint256) {
        return _val + 2;
    }
}