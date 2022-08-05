// SPDX-License-Identifier: MIT
pragma solidity >=0.8 <0.9.0;

contract Assert {
  uint256 public val;

  function assertCheck(uint256 _a) external {
    assert(_a != 0x73);
    val = _a;
  }


}