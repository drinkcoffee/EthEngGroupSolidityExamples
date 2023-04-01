// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Create { 
    event Deployed(address _deployed);


    function deploy(bytes calldata _code, address _param) external payable {
        bytes memory codeParams = abi.encode(_code, _param);
        address _deployedAddress;
       assembly {
            // create new contract with code mem[p…(p+n)) and send v wei and return the 
            // new address; returns 0 on error
            // create(v, p, n)
            _deployedAddress := create(callvalue(), add(codeParams, 32), mload(codeParams))
        }
        require(_deployedAddress != address(0), 'Deploy failed');
        emit Deployed(_deployedAddress);
    }
}
