// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
  Proxy contract which is used as the proxy contract for smart contract wallet instances.
  Exposes a view function to retrieve the implementation address stored at the address storage location.
 */
contract Proxy2 {

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bb0;


    /// @dev Sets implementation contract on deployment
    constructor(address _implementation) {
        assembly {
            sstore(_IMPLEMENTATION_SLOT, _implementation)
        } 
    }

    // /// @dev Retrieve current implementation contract used by proxy
    // function PROXY_getImplementation() public view returns (address implementation) {
    //     assembly{
    //         implementation := sload(address())
    //     }
    // }

    /// @dev Fallback function to forward calls to implementation contract
    fallback() external payable {
        address target;// = PROXY_getImplementation();
                assembly{
            target := sload(_IMPLEMENTATION_SLOT)
        }

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
