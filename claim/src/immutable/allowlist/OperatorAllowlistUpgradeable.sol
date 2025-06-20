// Copyright Immutable Pty Ltd 2018 - 2024
// SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.8.19 <0.8.29;

import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlEnumerableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/extensions/AccessControlEnumerableUpgradeable.sol";

// Introspection
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

// Interfaces
import {IOperatorAllowlist} from "./IOperatorAllowlist.sol";
import {IWalletProxy} from "./IWalletProxy.sol";

/*
    OperatorAllowlist is an implementation of a Allowlist registry, storing addresses and bytecode
    which are allowed to be approved operators and execute transfers of interfacing token contracts (e.g. ERC721/ERC1155).
    The registry will be a deployed contract that tokens may interface with and point to.
*/

contract OperatorAllowlistUpgradeable is
    ERC165,
    AccessControlEnumerableUpgradeable,
    UUPSUpgradeable,
    IOperatorAllowlist
{
    ///     =====       Events       =====

    /// @notice Emitted when a target address is added or removed from the Allowlist
    event AddressAllowlistChanged(address indexed target, bool added);

    /// @notice Emitted when a target smart contract wallet is added or removed from the Allowlist
    event WalletAllowlistChanged(bytes32 indexed targetBytes, address indexed targetAddress, bool added);
    ///     =====   State Variables  =====

    /// @notice Only REGISTRAR_ROLE can invoke white listing registration and removal
    bytes32 public constant REGISTRAR_ROLE = bytes32("REGISTRAR_ROLE");

    /// @notice Only UPGRADE_ROLE can upgrade the contract
    bytes32 public constant UPGRADE_ROLE = bytes32("UPGRADE_ROLE");

    /// @notice Mapping of Allowlisted addresses
    mapping(address aContract => bool allowed) private addressAllowlist;

    /// @notice Mapping of Allowlisted implementation addresses
    mapping(address impl => bool allowed) private addressImplementationAllowlist;

    /// @notice Mapping of Allowlisted bytecodes
    mapping(bytes32 bytecodeHash => bool allowed) private bytecodeAllowlist;

    ///     =====   Initializer  =====

    /**
     * @notice Grants `DEFAULT_ADMIN_ROLE` to the supplied `admin` address
     * @param _roleAdmin the address to grant `DEFAULT_ADMIN_ROLE` to
     * @param _upgradeAdmin the address to grant `UPGRADE_ROLE` to
     */
    function initialize(address _roleAdmin, address _upgradeAdmin, address _registerarAdmin) public initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _roleAdmin);
        _grantRole(UPGRADE_ROLE, _upgradeAdmin);
        _grantRole(REGISTRAR_ROLE, _registerarAdmin);
    }

    ///     =====  External functions  =====

    /**
     * @notice Adds a list of multiple addresses to Allowlist
     * @param addressTargets the addresses to be added to the allowlist
     */
    function addAddressesToAllowlist(address[] calldata addressTargets) external onlyRole(REGISTRAR_ROLE) {
        for (uint256 i; i < addressTargets.length; i++) {
            addressAllowlist[addressTargets[i]] = true;
            emit AddressAllowlistChanged(addressTargets[i], true);
        }
    }

    /**
     * @notice Removes a list target address from Allowlist
     * @param addressTargets the addresses to be removed from the allowlist
     */
    function removeAddressesFromAllowlist(address[] calldata addressTargets) external onlyRole(REGISTRAR_ROLE) {
        for (uint256 i; i < addressTargets.length; i++) {
            // slither-disable-next-line costly-loop
            delete addressAllowlist[addressTargets[i]];
            emit AddressAllowlistChanged(addressTargets[i], false);
        }
    }

    /**
     * @notice Add a smart contract wallet to the Allowlist.
     * This will allowlist the proxy and implementation contract pair.
     * First, the bytecode of the proxy is added to the bytecode allowlist.
     * Second, the implementation address stored in the proxy is stored in the
     * implementation address allowlist.
     * @param walletAddr the wallet address to be added to the allowlist
     */
    function addWalletToAllowlist(address walletAddr) external onlyRole(REGISTRAR_ROLE) {
        // get bytecode of wallet
        bytes32 codeHash;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codeHash := extcodehash(walletAddr)
        }
        bytecodeAllowlist[codeHash] = true;
        // get address of wallet module
        address impl = IWalletProxy(walletAddr).PROXY_getImplementation();
        addressImplementationAllowlist[impl] = true;

        emit WalletAllowlistChanged(codeHash, walletAddr, true);
    }

    /**
     * @notice Remove  a smart contract wallet from the Allowlist
     * This will remove the proxy bytecode hash and implementation contract address pair from the allowlist
     * @param walletAddr the wallet address to be removed from the allowlist
     */
    function removeWalletFromAllowlist(address walletAddr) external onlyRole(REGISTRAR_ROLE) {
        // get bytecode of wallet
        bytes32 codeHash;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codeHash := extcodehash(walletAddr)
        }
        delete bytecodeAllowlist[codeHash];
        // get address of wallet module
        address impl = IWalletProxy(walletAddr).PROXY_getImplementation();
        delete addressImplementationAllowlist[impl];

        emit WalletAllowlistChanged(codeHash, walletAddr, false);
    }

    ///     =====   View functions  =====

    /**
     * @notice Returns true if an address is Allowlisted, false otherwise
     * @param target the address that will be checked for presence in the allowlist
     */
    function isAllowlisted(address target) external view override returns (bool) {
        if (addressAllowlist[target]) {
            return true;
        }

        // Check if caller is a Allowlisted smart contract wallet
        bytes32 codeHash;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codeHash := extcodehash(target)
        }
        if (bytecodeAllowlist[codeHash]) {
            // If wallet proxy bytecode is approved, check addr of implementation contract
            address impl = IWalletProxy(target).PROXY_getImplementation();

            return addressImplementationAllowlist[impl];
        }

        return false;
    }

    /**
     * @notice ERC-165 interface support
     * @param interfaceId The interface identifier, which is a 4-byte selector.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165, AccessControlEnumerableUpgradeable) returns (bool) {
        return interfaceId == type(IOperatorAllowlist).interfaceId || super.supportsInterface(interfaceId);
    }

    // Override the _authorizeUpgrade function
    // solhint-disable-next-line no-empty-blocks
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADE_ROLE) {}

    /// @notice storage gap for additional variables for upgrades
    // slither-disable-start unused-state
    // solhint-disable-next-line var-name-mixedcase
    uint256[20] private __OperatorAllowlistUpgradeableGap;
    // slither-disable-end unused-state
}
