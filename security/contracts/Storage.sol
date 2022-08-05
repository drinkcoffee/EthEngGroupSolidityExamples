// SPDX-License-Identifier: BSD
pragma solidity ^0.8.0;

contract Storage {
    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
    */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    mapping (uint256 => uint256) public map;

    function setVal(uint256 _key, uint256 _val) external {
        map[_key] = _val;
    }
    function setVal1(uint256 _key, uint256 _val) external {
        uint256 mapSlot = 0;
        bytes32 slot = keccak256(abi.encode(_key, mapSlot));
        getUint256Slot(slot).value = _val;
    }

    function getVal(uint256 _key) external view returns (uint256) {
        uint256 mapSlot = 0;
        bytes32 slot = keccak256(abi.encode(_key, mapSlot));
        return getUint256Slot(slot).value;
    }

}

