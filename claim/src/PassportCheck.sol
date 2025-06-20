// Copyright (c) Whatgame Studios 2024 - 2025
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


// Interface to retrieve the implementation stored inside the Proxy contract
/// Interface for Passport Wallet's proxy contract.
interface IWalletProxy {
    // Returns the current implementation address used by the proxy contract
    // solhint-disable-next-line func-name-mixedcase
    function PROXY_getImplementation() external view returns (address);
}


/**
 * @notice Determine if an address is a Passport Wallet.
 *
 * This contract is designed to be upgradeable.
 */
contract PassportCheck is Initializable, AccessControlEnumerableUpgradeable {
    /// @notice Emitted when a target smart contract wallet is added or removed from the Allowlist
    event WalletAllowlistChanged(bytes32 indexed targetBytes, address indexed targetAddress, bool added);

    /// @notice Mapping of Allowlisted implementation addresses
    mapping(address impl => bool allowed) private addressImplementationAllowlist;

    /// @notice Mapping of Allowlisted bytecodes
    mapping(bytes32 bytecodeHash => bool allowed) private bytecodeAllowlist;


    /**
     * @notice Initialise Passport Wallet checker. 
     * @dev At present there is only one Passport implementation. Hence, passing in the address of 
     *  any Passport wallet will be enough to configure this contract.
     */
    function __PassportCheck_init(address _aPassportWallet) internal onlyInitializing {
         _addWalletToAllowlist(_aPassportWallet);
    }

    /**
     * @notice Returns true if an address is Allowlisted, false otherwise
     * @param target the address that will be checked for presence in the allowlist
     */
    function isPassport(address target) public view returns (bool) {
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
     * @notice Add a smart contract wallet to the Allowlist.
     * This will allowlist the proxy and implementation contract pair.
     * First, the bytecode of the proxy is added to the bytecode allowlist.
     * Second, the implementation address stored in the proxy is stored in the
     * implementation address allowlist.
     * @param walletAddr the wallet address to be added to the allowlist
     */
    function _addWalletToAllowlist(address walletAddr) internal {
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
    function _removeWalletFromAllowlist(address walletAddr) internal {
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






    /// @notice storage gap for additional variables for upgrades
    // slither-disable-start unused-state
    // solhint-disable-next-line var-name-mixedcase
    uint256[50] private __PassportCheckGap;
    // slither-disable-end unused-state
}
