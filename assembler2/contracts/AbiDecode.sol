// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AbiDecode { 
    uint256 public val;


    function extract1(bytes calldata _stuff) external {
        (, , , , val) = abi.decode(_stuff, (uint256, uint256, uint256, uint256, uint256));
    }

    function extract2(bytes calldata _stuff) external {
        val =  bytesToUint256(_stuff, 32 * 4);
    }

    function create () external pure returns (bytes memory) {
        uint256 a = 1;
        uint256 b = 2;
        uint256 c = 3;
        uint256 d = 4;
        uint256 e = 5;
        return abi.encode(a, b, c, d, e);
    }


        // Starting point was this, but with some modifications.
    // https://ethereum.stackexchange.com/questions/49185/solidity-conversion-bytes-memory-to-uint
    function bytesToUint256(bytes memory _b, uint256 _startOffset)
        internal
        pure
        returns (uint256)
    {
        require(
            _b.length >= _startOffset + 32,
            "slicing out of range (uint256)"
        );
        uint256 x;
        assembly {
            x := mload(add(_b, add(32, _startOffset)))
        }
        return x;
    }

}