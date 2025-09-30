// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
 
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";


contract SmartAccountDelegate layout at 2**0x8A + 0xFACE0FACE {
    using ECDSA for bytes32;


    /// @notice Event emitted when call executed.
    event Executed(address indexed _sender, address indexed _to, uint256 _value, bytes _data);
 
    event BatchExecuted(uint256 indexed _nonce);


    error InvalidSignature();
    error InvalidAuthority();

    /// @notice A single call within a batch.
    struct Call {
        address to;
        uint256 value;
        bytes data;
    }

    /// @notice Nonce for replay protection.
    uint256 public nonce;


    // function execute(Call[] calldata calls) external payable {
    //     for (uint256 i = 0; i < calls.length; i++) {
    //         Call calldata call = calls[i];
    //         _executeCall(call);
    //     }
    // }






    /**
     * @notice Executes a batch of calls using an off–chain signature.
     * @param calls An array of Call structs containing destination, value, and call data.
     * @param signature The ECDSA signature over the current nonce and the call data.
     *
     * The signature must be produced off–chain by signing:
     * The signing key should be the account’s key (which becomes the smart account’s own identity after upgrade).
     */
    function execute(Call[] calldata calls, bytes calldata signature) external payable {
        // Compute the digest that the account was expected to sign.
        bytes memory encodedCalls;
        for (uint256 i = 0; i < calls.length; i++) {
            encodedCalls = abi.encodePacked(encodedCalls, calls[i].to, calls[i].value, calls[i].data);
        }
        bytes32 digest = keccak256(abi.encodePacked(nonce, encodedCalls));
        
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(digest);

        // Recover the signer from the provided signature.
        address recovered = ECDSA.recover(ethSignedMessageHash, signature);
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
        require(msg.sender == address(this), InvalidAuthority());
        _executeBatch(calls);
    }

    /**
     * @dev Internal function that handles batch execution and nonce incrementation.
     * @param calls An array of Call structs.
     */
    function _executeBatch(Call[] calldata calls) internal {
        uint256 currentNonce = nonce;
        nonce++; // Increment nonce to protect against replay attacks

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

 
    receive() external payable {}
}



/**
 * @title BatchCallAndSponsor
 * @notice An educational contract that allows batch execution of calls with nonce and signature verification.
 *
 * When an EOA upgrades via EIP‑7702, it delegates to this implementation.
 * Off‑chain, the account signs a message authorizing a batch of calls. The message is the hash of:
 *    keccak256(abi.encodePacked(nonce, calls))
 * The signature must be generated with the EOA’s private key so that, once upgraded, the recovered signer equals the account’s own address (i.e. address(this)).
 *
 * This contract provides two ways to execute a batch:
 * 1. With a signature: Any sponsor can submit the batch if it carries a valid signature.
 * 2. Directly by the smart account: When the account itself (i.e. address(this)) calls the function, no signature is required.
 *
 * Replay protection is achieved by using a nonce that is included in the signed message.
 */
// contract BatchCallAndSponsor {
//     using ECDSA for bytes32;

//     /// @notice A nonce used for replay protection.
//     uint256 public nonce;

//     /// @notice Represents a single call within a batch.
//     struct Call {
//         address to;
//         uint256 value;
//         bytes data;
//     }

//     /// @notice Emitted for every individual call executed.
//     event CallExecuted(address indexed sender, address indexed to, uint256 value, bytes data);
//     /// @notice Emitted when a full batch is executed.
//     event BatchExecuted(uint256 indexed nonce, Call[] calls);

//     /**
//      * @notice Executes a batch of calls using an off–chain signature.
//      * @param calls An array of Call structs containing destination, ETH value, and calldata.
//      * @param signature The ECDSA signature over the current nonce and the call data.
//      *
//      * The signature must be produced off–chain by signing:
//      * The signing key should be the account’s key (which becomes the smart account’s own identity after upgrade).
//      */
//     function execute(Call[] calldata calls, bytes calldata signature) external payable {
//         // Compute the digest that the account was expected to sign.
//         bytes memory encodedCalls;
//         for (uint256 i = 0; i < calls.length; i++) {
//             encodedCalls = abi.encodePacked(encodedCalls, calls[i].to, calls[i].value, calls[i].data);
//         }
//         bytes32 digest = keccak256(abi.encodePacked(nonce, encodedCalls));
        
//         bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(digest);

//         // Recover the signer from the provided signature.
//         address recovered = ECDSA.recover(ethSignedMessageHash, signature);
//         require(recovered == address(this), "Invalid signature");

//         _executeBatch(calls);
//     }

//     /**
//      * @notice Executes a batch of calls directly.
//      * @dev This function is intended for use when the smart account itself (i.e. address(this))
//      * calls the contract. It checks that msg.sender is the contract itself.
//      * @param calls An array of Call structs containing destination, ETH value, and calldata.
//      */
//     function execute(Call[] calldata calls) external payable {
//         require(msg.sender == address(this), "Invalid authority");
//         _executeBatch(calls);
//     }

//     /**
//      * @dev Internal function that handles batch execution and nonce incrementation.
//      * @param calls An array of Call structs.
//      */
//     function _executeBatch(Call[] calldata calls) internal {
//         uint256 currentNonce = nonce;
//         nonce++; // Increment nonce to protect against replay attacks

//         for (uint256 i = 0; i < calls.length; i++) {
//             _executeCall(calls[i]);
//         }

//         emit BatchExecuted(currentNonce, calls);
//     }

//     /**
//      * @dev Internal function to execute a single call.
//      * @param callItem The Call struct containing destination, value, and calldata.
//      */
//     function _executeCall(Call calldata callItem) internal {
//        address target = callItem.to;
//        uint256 value = callItem.value;
//        bytes memory data = callItem.data;

//         // solhint-disable-next-line no-inline-assembly
//         assembly {
//             // out and outsize are 0 because we don't know the size yet.
//             let result := call(gas(), impl, value, add(data, 0x20), data.length, 0, 0)

//             // Copy the returned data.
//             returndatacopy(0, 0, returndatasize())

//             switch result
//             // delegatecall returns 0 on error.
//             case 0 {
//                 revert(0, returndatasize())
//             }
//             default {
//                 return(0, returndatasize())
//             }
//         }

//         emit CallExecuted(msg.sender, callItem.to, callItem.value, callItem.data);
//     }

//     // Allow the contract to receive ETH.
//     receive() external payable {}
// }