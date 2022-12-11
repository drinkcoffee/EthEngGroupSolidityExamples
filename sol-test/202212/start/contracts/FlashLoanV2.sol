// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "./PauseMeV2.sol";
import "./FlashLoanBase.sol";

/**
 * NOTE: FlashLoanV2 is the same as FlashLoanV1, with the exception that
 * FlashLoanV2 uses PauseMeV2.
 */
contract FlashLoanV2 is PauseMeV2, FlashLoanBase {
    constructor(uint256 _interestRatePerBlock) FlashLoanBase(_interestRatePerBlock){
        version = VERSION2;
    }

    function upgrade(bytes calldata /* _params */) external override {
        if (version == 0) {
            revert("Upgrade before initialise");
        }
        else if (version == VersionInit.VERSION1) {
            // Upgrade from v1 to v2
            version = VERSION2;
            pauser = admin;
        } else if (version == VersionInit.VERSION2) {
            revert("Already upgraded");
        } else {
            revert("Unknown version");
        }
    }
}
