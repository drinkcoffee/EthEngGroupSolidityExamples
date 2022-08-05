// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract D {
    address public owner;
    constructor() {
        owner = msg.sender;
    }

    function withdrawal() external {
        selfdestruct(payable(owner));
    }
}

contract OverWrite1 {
    function create() external {
        bytes32 salt = bytes32(uint256(0x01));
        D d = new D{salt: salt}();
        require(address(d) == predictAddr(), "Not at predicted address");
    }

    function predictAddr() public view returns (address) {
        bytes32 salt = bytes32(uint256(0x01));
        address predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(abi.encodePacked(
                    type(D).creationCode
                ))
            )))));
        return predictedAddress;
    }
}
