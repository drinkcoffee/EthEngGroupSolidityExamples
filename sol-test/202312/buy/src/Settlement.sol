// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/utils/Address.sol";


contract Settlement {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UNPAUSER_ROLE = keccak256("UNPAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public salePrice;
    address public seller;
    address public proxyAdmin;
    AccessControlEnumerableUpgradeable public contractForSale;

    constructor(uint256 _salePrice, address _proxyAdmin, address _contractForSale) {
        salePrice = _salePrice;
        seller = msg.sender;
        proxyAdmin = _proxyAdmin;
        contractForSale = AccessControlEnumerableUpgradeable(_contractForSale);
    }

    function buy(address _newAdmin) external payable {
        require(msg.value >= salePrice, "Not enough");

        // Switch admin of proxy admin.
//        ProxyAdmin(proxyAdmin).transferOwnership(_newAdmin);

        // Grant admin access.
        contractForSale.grantRole(DEFAULT_ADMIN_ROLE, _newAdmin);
        contractForSale.grantRole(PAUSER_ROLE, _newAdmin);
        contractForSale.grantRole(UNPAUSER_ROLE, _newAdmin);
        contractForSale.grantRole(MINTER_ROLE, _newAdmin);

        // Revoke existing admin access.
        revoke(DEFAULT_ADMIN_ROLE, _newAdmin);
        revoke(PAUSER_ROLE, _newAdmin);
        revoke(UNPAUSER_ROLE, _newAdmin);
        revoke(MINTER_ROLE, _newAdmin);

        // Send purchase amount to seller.
        Address.sendValue(payable(seller), msg.value);
    }

    function regainOwnership() external {
        require(msg.sender == seller, "Not seller");

        ProxyAdmin(proxyAdmin).transferOwnership(seller);
        contractForSale.grantRole(DEFAULT_ADMIN_ROLE, seller);
    }


    function revoke(bytes32 _role, address _newAdmin) private {
        uint256 numDefaultAdmin = contractForSale.getRoleMemberCount(_role);
        uint256 ofs = 0;
        for (uint256 i = 0; i < numDefaultAdmin; i++) {
            address admin = contractForSale.getRoleMember(_role, ofs);
            if (admin == _newAdmin) {
                ofs++;
                continue;
            }
            contractForSale.revokeRole(_role, admin);
        }

    }
}
