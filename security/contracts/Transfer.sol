// SPDX-License-Identifier: BSD
pragma solidity ^0.8.0;
contract Transfer {


    function sendValue1(address payable _to) external payable {
        _to.transfer(msg.value);
    }

    function sendValue2(address payable _to) external payable {
        require(_to.send(msg.value), "Send failed");
    }

    error AnError(string _msg, bytes _revertInfo);

    function sendValue3(address payable _to) external payable {
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        if (!sent) {
            revert AnError("Send failed", data);
        }
    }
}