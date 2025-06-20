// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity >=0.8.19 <0.8.29;

interface IERC1155Permit {
    function permit(address owner, address spender, bool approved, uint256 deadline, bytes memory sig) external;
    function nonces(address owner) external view returns (uint256);

    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
