// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "./interfaces/IAdmin.sol";

/**
 * Single owner
 */
abstract contract Admin is IAdmin {
    address public admin;

    // Add dummy variable buffer to allow for upgrade.
    uint256[100] private __gapAdmin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin!");
        _;
    }

    function initialiseAdmin() internal {
        admin = msg.sender;
    }

    function transferOwnership(address _newOwner) external onlyAdmin {
        admin = _newOwner;
    }
} 