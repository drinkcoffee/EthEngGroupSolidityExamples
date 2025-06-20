// Copyright Immutable Pty Ltd 2018 - 2023
// SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.8.19 <0.8.29;

import {ERC1155Burnable, ERC1155} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import {BytesLib} from "solidity-bytes-utils/contracts/BytesLib.sol";
import {IERC1155Permit} from "./IERC1155Permit.sol";
import {IImmutableERC1155Errors} from "../errors/Errors.sol";

abstract contract ERC1155Permit is ERC1155Burnable, EIP712, IERC1155Permit, IImmutableERC1155Errors {
    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,bool approved,uint256 nonce,uint256 deadline)");

    mapping(address account => uint256 nonce) private _nonces;

    constructor(string memory name, string memory uri) ERC1155(uri) EIP712(name, "1") {}

    function permit(address owner, address spender, bool approved, uint256 deadline, bytes memory sig) external {
        // solhint-disable-next-line not-rely-on-time
        if (deadline < block.timestamp) {
            revert PermitExpired();
        }

        bytes32 digest = _buildPermitDigest(spender, owner, approved, deadline);

        // smart contract signature validation
        if (_isValidERC1271Signature(owner, digest, sig)) {
            _setApprovalForAll(owner, spender, approved);
            return;
        }

        address recoveredSigner = address(0);

        // EOA signature validation
        if (sig.length == 64) {
            // ERC2098 Sig
            recoveredSigner = ECDSA.recover(
                digest,
                bytes32(BytesLib.slice(sig, 0, 32)),
                bytes32(BytesLib.slice(sig, 32, 64))
            );
        } else if (sig.length == 65) {
            // typical EDCSA Sig
            recoveredSigner = ECDSA.recover(digest, sig);
        } else {
            revert InvalidSignature();
        }

        if (_isValidEOASignature(recoveredSigner, owner)) {
            _setApprovalForAll(owner, spender, approved);
        } else {
            revert InvalidSignature();
        }
    }

    /**
     * @notice Returns the current nonce of a given token ID.
     * @param owner The address for which to retrieve the nonce.
     * @return Current nonce of the given token.
     */
    function nonces(address owner) external view returns (uint256) {
        return _nonces[owner];
    }

    /**
     * @notice Returns the domain separator used in the encoding of the signature for permits, as defined by EIP-712
     * @return the bytes32 domain separator
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @notice Overrides supportsInterface from IERC165 and ERC721Hybrid to add support for IERC4494.
     * @param interfaceId The interface identifier, which is a 4-byte selector.
     * @return True if the contract implements `interfaceId` and the call doesn't revert, otherwise false.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155) returns (bool) {
        return
            interfaceId == type(IERC1155Permit).interfaceId || // 0x9e3ae8e4
            super.supportsInterface(interfaceId);
    }

    /**
     * @notice Builds the EIP-712 compliant digest for the permit.
     * @param spender The address which is approved to spend the token.
     * @param owner The address that holds the tokens.
     * @param deadline The deadline until which the permit is valid.
     * @return A bytes32 digest, EIP-712 compliant, that serves as a unique identifier for the permit.
     */
    function _buildPermitDigest(
        address spender,
        address owner,
        bool approved,
        uint256 deadline
    ) internal returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, approved, _nonces[owner]++, deadline))
            );
    }

    /**
     * @notice Checks if a given signature is valid according to EIP-1271.
     * @param spender The address which purports to have signed the message.
     * @param digest The EIP-712 compliant digest that was signed.
     * @param sig The actual signature bytes.
     * @return True if the signature is valid according to EIP-1271, otherwise false.
     */
    function _isValidERC1271Signature(address spender, bytes32 digest, bytes memory sig) private view returns (bool) {
        // slither-disable-next-line low-level-calls
        (bool success, bytes memory res) = spender.staticcall(
            abi.encodeWithSelector(IERC1271.isValidSignature.selector, digest, sig)
        );

        if (success && res.length == 32) {
            bytes4 decodedRes = abi.decode(res, (bytes4));
            if (decodedRes == IERC1271.isValidSignature.selector) {
                return true;
            }
        }

        return false;
    }

    /**
     * @notice Checks if a given signature is valid according to EIP-1271.
     * @param recoveredSigner The address which purports to have signed the message.
     * @param owner The owner of the tokens.
     * @return True if the signature is from an approved operator or owner, otherwise false.
     */
    function _isValidEOASignature(address recoveredSigner, address owner) private pure returns (bool) {
        return recoveredSigner != address(0) && recoveredSigner == owner;
    }
}
