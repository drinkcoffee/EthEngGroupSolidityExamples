// SPDX-License-Identifier: MIT
// Peter Robinson: Dec 2022 Solidity Recruitment Test
pragma solidity ^0.8.11;

import "./interfaces/IAdmin.sol";

contract UpgradeProxy {
    bytes32 internal constant _ADMIN_SLOT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE;

    error ConstructorFailed(bytes _error);
    event Upgraded(address indexed implementation);
    event UpgradeFailed(bytes _revertData);
    event OwnershipChanged(address _newOwner);

    modifier onlyAdmin {
        require(msg.sender == admin(), "Not admin");
        _;
    }

    /**
     * Initialise the implementation contract in the context of this contract.
     *
     * @param _implementation Address of implementation contract.
     * @param _data ABI encoded parameters to pass to implementation contract's initialise function.
     */
    constructor(address _implementation, bytes memory _data) payable {
        setAdmin(msg.sender);

        (bool success, bytes memory error) =
            _implementation.delegatecall(abi.encodeWithSignature("initialise(bytes)", (_data)));
        if (success) {
            setImpl(_implementation);
        }
        else {
            revert ConstructorFailed(error);
        }
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
    function PROXY_upgrade(address _newImplementation, bytes calldata _data) external payable onlyAdmin {
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
     * Transfer ownership of contract to the a new admin account.
     *
     * Only the current admin can call this function.
     *
     * @param _newOwner The new administrator.
     */
    function PROXY_transferOwnership(address _newOwner) external onlyAdmin {
        setAdmin(_newOwner);
    }


    /**
     * @return Address of the implementation contract.
     */
    function PROXY_implementation() external view returns (address) {
        return impl();
    }

    /**
     * @return Admin authorised to upgrade the implementation contract.
     */
    function PROXY_admin() external view returns (address){
        return admin();
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

    function setAdmin(address _newAdmin) private {
        assembly {
            sstore(_ADMIN_SLOT, _newAdmin)
        }
    }

    function impl() private view returns (address) {
        address implementation;
        assembly {
            implementation := sload(_IMPLEMENTATION_SLOT)
        }
        return implementation;
    }

    function admin() private view returns (address) {
        address implementation;
        assembly {
            implementation := sload(_ADMIN_SLOT)
        }
        return implementation;
    }
}
