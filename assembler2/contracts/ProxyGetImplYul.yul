// Copyright (c) Peter Robinson 2023
// SPDX-License-Identifier: MIT

// The following in Yul code that creates a minimalist transparent proxy.

object "ProxyGetImplYul" {
    // This is the initcode of the contract.
    code {
        // Copy the runtime code plus the address of the implementation 
        // parameter (32 bytes) which is appended to the end to memory.
        // copy s bytes from code at position f to mem at position t
        // codecopy(t, f, s)
        // This will turn into a memory->memory copy for Ewasm and
        // a codecopy for EVM
        // TODO the add() of two constants could be pre-calculated
        datacopy(returndatasize(), dataoffset("runtime"), add(datasize("runtime"), 32))

        // Store the implementation address at the storage slot which is 
        // equivalent to the deployed address of this contract.
        let implAddress := mload(datasize("runtime"))
        sstore(address(), implAddress)

        // now return the runtime object (the currently
        // executing code is the constructor code)
        return(returndatasize(), datasize("runtime"))
    }


    // Code for deployed contract
    object "runtime" {
        code {
            // The code below for loading the function selector is taken from the ERC 20 
            // example in the Yul documentation.
            // https://docs.soliditylang.org/en/v0.8.17/yul.html#complete-erc20-example
            let selector := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)

            if eq(selector, 0x90611127) /* "PROXY_getImplementation()" */ {
                let impl := sload(address())
                mstore(0, impl)
                return(0, 0x20)
            }

            // Use returndatasize to load zero.
            let zero := returndatasize()

            // Load calldata to memory location 0.
            // Copy s bytes from calldata at position f to mem at position t
            // calldatacopy(t, f, s)
            calldatacopy(zero, zero, calldatasize())

            // Load the implemntation address. This is stored at a storage
            // location defined by the address of this contract.
//            let implAddress := sload(address())

            // Execute delegate call. Have outsize set to zero, to indicate
            // don't return any data automatically.
            // Call contract at address a with input mem[in…(in+insize)) 
            // providing g gas and v wei and output area 
            // mem[out…(out+outsize)) returning 0 on error 
            // (eg. out of gas) and 1 on success
            // delegatecall(g, a, in, insize, out, outsize)
//            let success := delegatecall(gas(), implAddress, returndatasize(), calldatasize(), returndatasize(), returndatasize())
            let success := delegatecall(gas(), sload(address()), returndatasize(), calldatasize(), returndatasize(), returndatasize())

            // Copy the return result to memory location 0.
            // Copy s bytes from returndata at position f to mem at position t
            // returndatacopy(t, f, s)
            returndatacopy(zero, zero, returndatasize())

            // Return or revert: memory location 0 contains either the return value
            // or the revert information.
            if iszero(success) {
                revert (zero,returndatasize())
            }
            return (zero,returndatasize())
        }
    }
}