// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


// Subject to attack by an attacker front running as there is no time
// period check between register and transfer
contract CommitReveal2 {
   mapping (address => bytes32) commitments;

   receive() external payable {}

   function register(bytes32 _commitment) external {
       commitments[msg.sender] = _commitment;
   }


  function transfer(bytes32 _secret) external {
      require(commitments[msg.sender] == 
                                       keccak256(abi.encodePacked(_secret, msg.sender)), "Mismatch");

      uint256 bal = address(this).balance;
      (bool success, ) = payable(msg.sender).call{value: bal}("");
      require(success, "Transfer failed");
  }
}
