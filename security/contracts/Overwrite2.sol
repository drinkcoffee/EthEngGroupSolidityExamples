// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Choice.sol";
import "./Get.sol";

contract Overwrite2 {
    address public choiceContract;

    function create2() public {
        bytes32 salt = bytes32(uint256(0x01));
        Choice d = new Choice{salt: salt}();
        choiceContract = address(d);
    }

    function predictAddr() public view returns (address) {
        bytes32 salt = bytes32(uint256(0x01));
        address predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(abi.encodePacked(
                    type(Choice).creationCode
                ))
            )))));
        return predictedAddress;
    }

    uint256 public gas1;
    uint256 public gas2;
    uint256 public gas3;

    function replace() external {
        address addr = predictAddr();
        Get g = Get(addr);
        // g.withdrawal{gas: 100000}();
        // create2();

        gas1 = gasleft();
        gas2 = gasleft();
        g.get();
        gas3 = gasleft();

    }


    mapping(address => bool) public registered;
    mapping(uint256 => bool) public proposalActive;

    modifier isEligible() {
        require(registered[msg.sender], "Not registered to vote!");
        _;
    }
    modifier isValid(uint256 _proposal) {
        require(proposalActive[_proposal], "Proposal not active!");
        _;
    }

    function vote(uint256 _proposal) isEligible isValid(_proposal) public {
        // Code
    }


}