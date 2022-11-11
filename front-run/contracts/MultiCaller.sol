// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Call multiple contracts
// Lots of small things to think through with this contract:
// * Could have require that contract and calls array lengths match.
// * Could pass in an array of uint256[] _value, that could be the amount of value to send with each call.
//   Note that the function would need to be payable.
// * The code swallows reverts / failures. An option is to revert on failure.
contract MultiCaller {
    event Result(bytes _call, bool _success, bytes _returnEncoded);
    function multicall(address[] calldata _contracts, bytes[] calldata _calls) external {
        for (uint256 i = 0; i < _contracts.length; i++) {
            (bool success, bytes memory returnEncoded) =
            address(_contracts[i]).call(_calls[i]);
            emit Result(_calls[i], success, returnEncoded);
        }
    }
}
