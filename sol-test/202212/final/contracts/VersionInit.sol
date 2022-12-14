// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

contract VersionInit {
    uint256 constant VERSION1 = 1;
    uint256 constant VERSION2 = 2;
    uint256 constant VERSION3 = 3;

    bool public initialised;
    uint256 public version;

    // Add dummy variable buffer to allow for upgrade.
    uint256[100] private __gapVersionInit;


    modifier ifNotInitialised {
        require(initialised == false, "Already initialised");
        _;
    }

    modifier ifInitialised {
        require(initialised, "Not yet initialised");
        _;
    }
}
