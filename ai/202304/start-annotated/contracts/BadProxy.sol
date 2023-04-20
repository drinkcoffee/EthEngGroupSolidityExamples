// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
  Proxy contract which is used as the proxy contract for smart contract wallet instances.
 */
contract BadProxy {
    // TODO storage slot collision
    // TODO function name / signature collision
    address public implementation;


    constructor(address _implementation) {
        implementation = _implementation;
    }

    /// @dev Fallback function to forward calls to implementation contract
    fallback() external payable {
        address target = implementation;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), target, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {revert(0, returndatasize())}
            default {return (0, returndatasize())}
        }
    }
}
