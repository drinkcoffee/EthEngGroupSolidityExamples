// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
 
contract ERC20 {
    address public minter;
    mapping(address => uint256) private _balances;
 
    constructor(address _minter) {
        minter = _minter;
    }
 
    function mint(uint256 amount, address to) public {
        _mint(to, amount);
    }
 
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
 
    function _mint(address account, uint256 amount) internal {
        require(msg.sender == minter, "ERC20: msg.sender is not minter");
        require(account != address(0), "ERC20: mint to the zero address");
        unchecked {
            _balances[account] += amount;
        }
    }
}