// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "./Admin.sol";

contract UpgradeProxy is Admin {
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    event Upgraded(address indexed implementation);
    event UpgradeFailed(bytes _revertData);



    constructor(address _implementation, bytes memory _data) payable {
        upgrade(_implementation, _data);
    }

    fallback() external payable {
        delegate();
    }
    receive() external payable {
        delegate();
    }

    function PROXY_implementation() external view returns (address) {
        return impl();
    }

    function PROXY_upgrade(address _newImplementation, bytes calldata _data) public payable onlyAdmin {
        upgrade(_newImplementation, _data);
    }

    // *********************** PRIVATE BELOW HERE **************************
    function delegate() private {
        address implementation = impl();
        assembly {
        // Copy msg.data. We take full control of memory in this inline assembly
        // block because it will not return to Solidity code. We overwrite the
        // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

        // Call the implementation.
        // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

        // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function impl() private view returns (address) {
        address implementation;
        assembly {
            implementation := sload(_IMPLEMENTATION_SLOT)
        }
        return implementation;
    }


    function upgrade(address _newImplementation, bytes memory _data) private {
        // Initialise the new contract in the context of this contract.
        (bool success, bytes memory data) =
            _newImplementation.delegatecall(abi.encodeWithSignature("initialise(bytes)", (_data)));
        if (success) {
            assembly {
                sstore(_IMPLEMENTATION_SLOT, _newImplementation)
            }
            emit Upgraded(_newImplementation);
        }
        else {
            emit UpgradeFailed(data);
        }
    }
}
