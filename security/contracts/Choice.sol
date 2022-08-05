// SPDX-License-Identifier: MIT
pragma solidity >=0.8 <0.9.0;

import "./Loader.sol";

contract Choice {
    constructor(address _loader, bool _choice) {
        Loader loader = Loader(_loader);
        bytes memory code = loader.getCode(_choice);

        uint256 memOfs = dataPtr(code);
        uint256 len = code.length;
        copy(memOfs, 0, len);

        assembly {
            return(0, len)
        }
    }


    // From https://github.com/ethereum/solidity-examples/blob/master/src/unsafe/Memory.sol
    // Size of a word, in bytes.
    uint internal constant WORD_SIZE = 32;

    // Copy 'len' bytes from memory address 'src', to address 'dest'.
    // This function does not check the or destination, it only copies
    // the bytes.
    function copy(uint src, uint dest, uint len) internal pure {
        // Copy word-length chunks while possible
        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += WORD_SIZE;
            src += WORD_SIZE;
        }

        // Copy remaining bytes
        uint mask = 256 ** (WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function dataPtr(bytes memory bts) internal pure returns (uint addr) {
        assembly {
            addr := add(bts, /*BYTES_HEADER_SIZE*/32)
        }
    }

}

