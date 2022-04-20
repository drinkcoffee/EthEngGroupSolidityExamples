pragma solidity ^0.8.0;

contract StoreCompact {
    uint16 a;
    uint16 b;
    uint16 c;

    function add() external view returns(uint16) {
        return a + b + c;
    }

    function set(uint16 _a, uint16 _b, uint16 _c) external {
        a = _a;
        b = _b;
        c = _c;
    }

}
