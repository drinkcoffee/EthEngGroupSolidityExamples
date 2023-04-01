// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleImpl { 
    uint256 private val;

    function set(uint256 _val) external {
        val = _val;
    }

    function get() external view returns (uint256) {
        return val;
    }
}