// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FixedSupplyERC20 is ERC20 {
    constructor(address _bank, uint256 _supply, string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _mint(_bank, _supply);
    }
}
