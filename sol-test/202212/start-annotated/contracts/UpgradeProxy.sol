// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "./Admin.sol";

// TODO: Advanced: Storage slot collision due to use of Admin
contract UpgradeProxy is Admin {
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE;

    event Upgraded(address indexed implementation);
    event UpgradeFailed(bytes _revertData);

    /**
     * Initialise the implementation contract in the context of this contract.
     *
     * @param _implementation Address of implementation contract.
     * @param _data ABI encoded parameters to pass to implementation contract's initialise function.
     */
    constructor(address _implementation, bytes memory _data) payable {
        // TODO: Advanced: Call to upgrade will not allow for first time install. Should be a separate call
        _implementation.delegatecall(abi.encodeWithSignature("upgrade(bytes)", (_data)));

        setImpl(_implementation);
    }

    fallback() external payable {
        delegate();
    }
    receive() external payable {
        delegate();
    }

    /**
     * Upgrade to a new version of the implementation contract.
     *
     * @param _newImplementation Address of new implementation contract.
     * @param _data ABI encoded parameters to pass to implementation contract's upgrade function.
     */
    function PROXY_upgrade(address _newImplementation, bytes calldata _data) public payable onlyAdmin {
        // Upgrade the new contract in the context of this contract.
        (bool success, bytes memory data) =
            _newImplementation.delegatecall(abi.encodeWithSignature("upgrade(bytes)", (_data)));
        if (success) {
            setImpl(_newImplementation);
            emit Upgraded(_newImplementation);
        }
        else {
            emit UpgradeFailed(data);
        }
    }

    /**
     * @return Address of the implementation contract.
     */
    function PROXY_implementation() external view returns (address) {
        return impl();
    }

    // *********************** PRIVATE BELOW HERE **************************
    function delegate() private {
        address implementation = impl();
        assembly {
            // Copy call data. This code doesn't return to Solidity. As such
            // over-writing the Solidity scratch pad at memory position 0 is OK.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { // if error
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }




    function setImpl(address _newImplementation) private {
        assembly {
            sstore(_IMPLEMENTATION_SLOT, _newImplementation)
        }
    }

    function impl() private view returns (address) {
        address implementation;
        assembly {
            implementation := sload(_IMPLEMENTATION_SLOT)
        }
        return implementation;
    }
}
