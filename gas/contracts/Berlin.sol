// SPDX-License-Identifier: MIT
pragma solidity >=0.8 <0.9.0;

contract Berlin {
  uint256 public a1;
  uint256 public a2;
  uint256 public a3;


  constructor() {
    a1 = 1;
  }

  function singleLoad() external {
    if (a1 == 2) {
      // Will never happen. Forces this to be a transaction function.
      a1 = 3;
    }
    dummy1();
  }
  function dummy1() internal {
    if (block.timestamp == 2) {
      // Will never happen. Forces this to be a transaction function.
      a1 = 3;
    }
  }



  function twoLoad() external {
    if (a1 == 2) {
      // Will never happen. Forces this to be a transaction function.
      a1 = 3;
    }
    dummy2();
  }
  function dummy2() internal {
    if (a1 == 2) {
      // Will never happen. Forces this to be a transaction function.
      a1 = 3;
     }
  }

}
