// SPDX-License-Identifier: BSD
pragma solidity ^0.8.0;

contract AbiDecode {


    function getUint256(bytes calldata _b) external pure returns (uint256) {
        uint256 val = abi.decode(_b, (uint256));
        return val;
    }

    function getUint256_2(bytes calldata _b) external pure returns (uint256) {
        return bytesToUint256(_b, 0);
    }

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

