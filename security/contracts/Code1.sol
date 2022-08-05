// SPDX-License-Identifier: MIT
pragma solidity >=0.8 <0.9.0;

import "./Get.sol";

contract Code1 is Get {
    function get() external pure returns (uint256) {
        return 1;
    }

    function withdrawal() external {
        selfdestruct(payable(address(0)));
    }
}

