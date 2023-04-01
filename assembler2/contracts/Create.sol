// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Deploy contracts and check contract code deployed
contract Create { 
    event Deployed(address _deployed);
    event GasUsed(uint256 _gasUsed);

    // Deploy a contract with bytecode _code with a paramter _param. 
    // Emit Deployed event to indicate the deployed address.
    function deploy(bytes calldata _code, address _param) external payable {
        bytes memory params = abi.encode(_param);
        bytes memory codeParams = bytes.concat(_code, params);
        address deployedAddress;
        assembly {
            // create new contract with code mem[p…(p+n)) and send v wei and return the 
            // new address; returns 0 on error
            // create(v, p, n)
            // mload(codeParams) loads up the first word of the codeParams bytes, which is the length.
            // add(codeParams, 32) returns the offset of the start of the contents of the bytes.
            deployedAddress := create(callvalue(), add(codeParams, 32), mload(codeParams))
        }
        emit Deployed(deployedAddress);
    }


    function deployCheckGas(bytes calldata _code, address _param) external payable {
        bytes memory params = abi.encode(_param);
        bytes memory codeParams = bytes.concat(_code, params);
        address deployedAddress;
        uint256 gasStart;
        uint256 gasEnd;
        assembly {
            gasStart := gas()
            // create new contract with code mem[p…(p+n)) and send v wei and return the 
            // new address; returns 0 on error
            // create(v, p, n)
            // mload(codeParams) loads up the first word of the codeParams bytes, which is the length.
            // add(codeParams, 32) returns the offset of the start of the contents of the bytes.
            deployedAddress := create(callvalue(), add(codeParams, 32), mload(codeParams))

            gasEnd := gas()
        }
        emit Deployed(deployedAddress);

        emit GasUsed(gasStart - gasEnd);
    }

    // Return the code of a contract at a specific address.
    function codeAt(address _addr) public view returns (bytes memory o_code) {
        assembly {
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(_addr)
            // allocate output byte array - this could also be done without assembly
            // by using o_code = new bytes(size)
            o_code := mload(0x40)
            // new "memory end" including padding
            mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // store length in memory
            mstore(o_code, size)
            // actually retrieve the code, this needs assembly
            extcodecopy(_addr, add(o_code, 0x20), 0, size)
        }
    }

}
