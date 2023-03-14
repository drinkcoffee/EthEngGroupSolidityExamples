// Copyright (c) Peter Robinson 2023
// SPDX-License-Identifier: MIT

// The following in Yul code that creates a minimalist transparent proxy.
// The code attempts to create the (what appears to be) hand crafted byte
// code from Sequence's wallet.
// The starting point for this code was https://github.com/0xsequence/wallet-contracts/blob/master/src/contracts/Wallet.sol
//
// The original bytecode (initcode and runtime code) is: 
// 0x603a600e3d39601a805130553df3363d3d373d3d3d363d30545af43d82803e903d91601857fd5bf3

object "TransparentProxy" {
    // This is the initcode of the contract.
    code {
        // Copy the runtime code plus the address of the implementation 
        // parameter (32 bytes) which is appended to the end to memory.
        // copy s bytes from code at position f to mem at position t
        // codecopy(t, f, s)
        // This will turn into a memory->memory copy for Ewasm and
        // a codecopy for EVM
//        datacopy(returndatasize(), dataoffset("runtime"), add(datasize("runtime"), 32))
        datacopy(returndatasize(), dataoffset("runtime"), 0x3d)

        // Store the implementation address at the storage slot which is 
        // equivalent to the deployed address of this contract.
        let implAddress := mload(datasize("runtime"))
        sstore(address(), implAddress)

        // now return the runtime object (the currently
        // executing code is the constructor code)
        return(returndatasize(), datasize("runtime"))
    }

// The initcode documented in Sequence's proxy is:
// Init code
//     0x00    0x60 0x3a    0x603a    PUSH1             0x3a
//        0x02    0x60 0x0e    0x600e    PUSH1             0x0e 0x3a
//        0x04    0x3d         0x3d      RETURNDATASIZE    0 0x0e 0x3a
//        0x05    0x39         0x39      CODECOPY
//        0x06    0x60 0x1a    0x601a    PUSH1             0x1a
//        0x08    0x80         0x80      DUP1              0x1a 0x1a
//        0x09    0x51         0x51      MLOAD             imp 0x1a
//        0x0A    0x30         0x30      ADDRESS           addr imp 0x1a
//        0x0B    0x55         0x55      SSTORE            0x1a
//        0x0C    0x3d         0x3d      RETURNDATASIZE    0 0x1a
//        0x0D    0xf3         0xf3      RETURN

//603a600e3d39601a805130553df3         // original
//603d600f3d39601d805130553df3fe       // Yul with hard coded length
//601d6020810160113d39805130553df3fe   // Yul with add of constant: add(datasize("runtime"), 32)

    // Code for deployed contract
    object "runtime" {
        code {
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

// Original code from Sequence's proxy code:
//        0x00    0x36         0x36      CALLDATASIZE      cds
//        0x01    0x3d         0x3d      RETURNDATASIZE    0 cds
//        0x02    0x3d         0x3d      RETURNDATASIZE    0 0 cds
//        0x03    0x37         0x37      CALLDATACOPY
//        0x04    0x3d         0x3d      RETURNDATASIZE    0
//        0x05    0x3d         0x3d      RETURNDATASIZE    0 0
//        0x06    0x3d         0x3d      RETURNDATASIZE    0 0 0
//        0x07    0x36         0x36      CALLDATASIZE      cds 0 0 0
//        0x08    0x3d         0x3d      RETURNDATASIZE    0 cds 0 0 0
//        0x09    0x30         0x30      ADDRESS           addr 0 cds 0 0 0
//        0x0A    0x54         0x54      SLOAD             imp 0 cds 0 0 0
//        0x0B    0x5a         0x5a      GAS               gas imp 0 cds 0 0 0
//        0x0C    0xf4         0xf4      DELEGATECALL      suc 0
//        0x0D    0x3d         0x3d      RETURNDATASIZE    rds suc 0
//        0x0E    0x82         0x82      DUP3              0 rds suc 0
//        0x0F    0x80         0x80      DUP1              0 0 rds suc 0
//        0x10    0x3e         0x3e      RETURNDATACOPY    suc 0
//        0x11    0x90         0x90      SWAP1             0 suc
//        0x12    0x3d         0x3d      RETURNDATASIZE    rds 0 suc
//        0x13    0x91         0x91      SWAP2             suc 0 rds
//        0x14    0x60 0x18    0x6018    PUSH1             0x18 suc 0 rds
//    /-- 0x16    0x57         0x57      JUMPI             0 rds
//    |   0x17    0xfd         0xfd      REVERT
//    \-> 0x18    0x5b         0x5b      JUMPDEST          0 rds
//        0x19    0xf3         0xf3      RETURN

//363d3d373d3d3d363d30545af43d82803e903d91601857fd5bf3       // Original code
//3d368182373d3d363d30545af43d82833e806018573d82fd5b3d82f3   // Yul with inline sload 
//3d3681823730543d3d363d845af43d83843e806019573d83fd5b3d83f3 // Yul with separate sload
}