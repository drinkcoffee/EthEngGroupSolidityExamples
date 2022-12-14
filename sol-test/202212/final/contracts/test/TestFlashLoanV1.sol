// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "../FlashLoanV1.sol";

contract TestFlashLoanV1 is FlashLoanV1 {

    uint256 private fakeBlockNumber;

    function setFakeBlockNumber(uint256 _blockNumber) external {
        fakeBlockNumber = _blockNumber;
    }

    function blockNumber() internal view override returns (uint256) {
        if (fakeBlockNumber == 0) {
            return block.number;
        }
        return fakeBlockNumber;
    }
}
