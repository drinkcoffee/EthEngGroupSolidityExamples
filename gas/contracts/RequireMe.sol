pragma solidity ^0.8.0;

contract RequireMe {
    function test() external view {

        require(msg.sender == address(0), "00123");


        require(block.timestamp > 0, "01234567890123456789012345678901234");
        require(block.timestamp > 3, "22123");




    }
}


