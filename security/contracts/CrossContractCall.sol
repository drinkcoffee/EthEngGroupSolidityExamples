// SPDX-License-Identifier: MIT
pragma solidity >=0.8 <0.9.0;

contract CrossContractCall {
    uint256 a;

    function add() external view returns(uint256) {
        return a + 7;
    }

    function doIt() external {
        a = this.add();

        bool success;
        bytes memory returnEncoded;
        (success, returnEncoded) = address(this).call(abi.encodeWithSelector(this.add.selector));
    }
}

