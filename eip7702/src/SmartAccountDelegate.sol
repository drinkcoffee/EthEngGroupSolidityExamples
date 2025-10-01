// Copyright (c) 2025 Peter Robinson
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

/**
 * An example smart account template that can be used for having transactions 
 * from a bundler or submitted by the account itself.
 *
 * NOTE: This contract has NOT been audited.
 */
contract SmartAccountDelegate layout at 2**0x8A + 0xFACE0FACE {
    using ECDSA for bytes32;

    /// @notice A call in a batch has been executed.
    event Executed(address indexed _sender, address indexed _to, uint256 _value, bytes _data);

    /// @notice Nonce of batch just executed.
    event BatchExecuted(uint256 indexed _nonce);

    /// @notice Authority signature of owner is invalid.
    error InvalidSignature();

    // An EOA that isn't the owner is trying to execute transactions.
    error InvalidAuthority(address _invalidAuthority);

    /// @notice A single call within a batch.
    struct Call {
        address to;
        uint256 value;
        bytes data;
    }

    /// @notice Nonce for replay protection plus ensures in-order transaction execution.
    uint256 public nonce;

    /**
     * @notice Executes a batch of calls using an off–chain signature.
     * @param calls An array of Call structs containing destination, value, and call data.
     * @param signature The ECDSA signature over the current nonce and the call data, 
     *         created using the owners private key.
     */
    function execute(Call[] calldata calls, bytes calldata signature) external payable {
        // Compute the digest that should have been signed.
        bytes memory encodedCalls;
        for (uint256 i = 0; i < calls.length; i++) {
            encodedCalls = abi.encodePacked(encodedCalls, calls[i].to, calls[i].value, calls[i].data);
        }
        bytes32 digest = keccak256(abi.encodePacked(nonce, encodedCalls));

        bytes32 candidateEthSignature = MessageHashUtils.toEthSignedMessageHash(digest);

        // Recover the signer from the provided signature.
        address recovered = ECDSA.recover(candidateEthSignature, signature);
        require(recovered == address(this), InvalidSignature());

        _executeBatch(calls);
    }

    /**
     * @notice Executes a batch of calls directly.
     * @dev This function is intended for use when the smart account itself (i.e. address(this))
     * calls the contract. It checks that msg.sender is the contract itself.
     * @param calls An array of Call structs containing destination, ETH value, and calldata.
     */
    function execute(Call[] calldata calls) external payable {
        require(msg.sender == address(this), InvalidAuthority(msg.sender));
        _executeBatch(calls);
    }

    /**
     * @dev Internal function that handles batch execution and nonce incrementation.
     * @param calls An array of Call structs.
     */
    function _executeBatch(Call[] calldata calls) internal {
        uint256 currentNonce = nonce;
        nonce++;

        for (uint256 i = 0; i < calls.length; i++) {
            _executeCall(calls[i]);
        }

        emit BatchExecuted(currentNonce);
    }

    /**
     * @dev Execute a single call.
     * @param _call The Call struct containing target, value, and call data.
     */
    function _executeCall(Call calldata _call) private {
       address target = _call.to;
       uint256 value = _call.value;
       bytes memory data = _call.data;
       uint256 len = data.length;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            // out and outsize are 0 because we don't know the size yet.
            let result := call(gas(), target, value, add(data, 0x20), len, 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // Call returns 0 on error. Return the revert to the caller.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                // Do not return from the transaction here. 
                // return(0, returndatasize())
            }
        }

        emit Executed(msg.sender, target, value, data);
    }

    // Allow anyone to send Eth to this account.
    receive() external payable {}
}