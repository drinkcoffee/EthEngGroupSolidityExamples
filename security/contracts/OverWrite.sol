// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Choice.sol";


contract OverWrite {
    function create(address _loader, bool _choice) external {
        bytes32 salt = bytes32(uint256(0x01));
        Choice d = new Choice{salt: salt}(_loader, _choice);
        require(address(d) == predictAddr(_loader, _choice), "Not at predicted address");
    }

    function predictAddr(address _loader, bool _choice) public view returns (address) {
        bytes32 salt = bytes32(uint256(0x01));
        address predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(abi.encodePacked(
                    type(Choice).creationCode, _loader, _choice
                ))
            )))));
        return predictedAddress;
    }
}
