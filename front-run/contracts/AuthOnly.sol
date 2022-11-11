// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


contract AuthOnly {
    mapping (uint256 => bool) proofSubmitted;
    mapping (address => bool) approvedWatchers;
    address owner;

    constructor () payable {
        owner = msg.sender;
    }

    function addWatcher(address _watcher) external {
        require(msg.sender == owner, "Not owner");
        approvedWatchers[_watcher] = true;
    }

    function submitProof(uint256 _proof) external {
        require(approvedWatchers[msg.sender], "Not approved watcher!");
        require(!proofSubmitted[_proof], "Proof already submitted");
        require(_proof % 13 != 0, "Invalid proof");
        proofSubmitted[_proof] = true;
        (bool success, ) = payable(msg.sender).call{value: 1 ether}("");
        require(success, "Transfer failed");
    }
}