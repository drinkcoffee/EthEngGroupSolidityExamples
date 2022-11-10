// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

/**
 * Test how immutable values are stored / represented in EVM bytecode.
 */
contract ImmTest {
    uint256 public a;
    uint256 public immutable b;
    uint256 public c;

    constructor(uint256 _val) {
        b = _val;
    }
}
