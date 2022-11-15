// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/** 
 * Examples of ABI Encoding
 */
contract AbiEncoding {
    address public a;
    uint256 public b;

    function doStuff(address _a, uint256 _b) external {
        a = _a;
        b = _b;
    }

    function returnStuff() external view returns (address, uint256) {
        return (a, b);
    }

    event ResultInfo(bool, bytes);
    function causePanic() external {
        b = 10 / b;  // Divide by zero panic if b=0
    }
    function catchPanic() external {
        (bool success, bytes memory returnEncoded) = address(this).call(abi.encodeWithSelector(this.causePanic.selector));
        emit ResultInfo(success, returnEncoded);
    }

    struct Stuff{
        uint256 c;
        bool d;
    }

    event ArrayStuff(Stuff[]);
    function emitStuff() external {
        Stuff[] memory strs = new Stuff[](3);
        strs[0] = Stuff(0x12, true);
        strs[1] = Stuff(0x13, true);
        strs[2] = Stuff(0x14, true);
        emit ArrayStuff(strs);
    }

    struct Stuff1{
        uint256 c;
        string d;
    }

    event ArrayStuff1(Stuff1[]);
    function emitStuff1() external {
        Stuff1[] memory strs = new Stuff1[](2);
        strs[0] = Stuff1(0x12, "ab");
        strs[1] = Stuff1(0x13, "cde");
        emit ArrayStuff1(strs);
    }


    event ArrayString(string[]);
    function emitArrayString() external {
        string[] memory strs = new string[](3);
        strs[0] = "abc";
        strs[1] = "def";
        strs[2] = "ghij";
        emit ArrayString(strs);
    }


    struct Lots {
        address a;
        bytes b;
        uint256 c;
    }


    function func(Lots calldata _lots, bool _go) external {
        if (_go) {
            b = _lots.c;
        }
    }

    event LotsEvent(Lots l);
    function func1() external {

        Lots memory l = Lots(address(this), bytes("abcde"), 0x123);
        emit LotsEvent(l);
    }

    function transfer(address _to, uint256 _amount) public {
        // Do stuff
    }

    function checkEncodeCall() external {
        address to = address(msg.sender);
        uint256 amount = 1234;
        (bool success, bytes memory returnEncoded) =
        address(this).call(abi.encodeCall(this.transfer, (to, amount)));
        emit ResultInfo(success, returnEncoded);
    }

}