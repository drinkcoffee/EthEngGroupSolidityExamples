// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


contract FrontRunMe {
    mapping (uint256 => bool) proofSubmitted;

    constructor () payable {}

    function submitProof(uint256 _proof) external {
        require(!proofSubmitted[_proof], "Proof already submitted");
        require(_proof % 13 != 0, "Invalid proof");
        proofSubmitted[_proof] = true;
        (bool success, ) = payable(msg.sender).call{value: 1 ether}("");
        require(success, "Transfer failed");
    }
}