// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICounter {
    function setNumber(uint256 _newNumber) external;
    function increment() external;
    function number() external view returns(uint256);
    function getNumberPlus17() external view returns(uint256);
    function getNumberPlus17a() external view returns(uint256 numPlus17);
}
