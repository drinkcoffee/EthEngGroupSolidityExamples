//SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.8.19 <0.8.29;

interface IImmutableERC721Errors {
    /// @dev Caller tried to mint an already burned token
    error IImmutableERC721TokenAlreadyBurned(uint256 tokenId);

    /// @dev Caller tried to mint an already burned token
    error IImmutableERC721SendingToZerothAddress();

    /// @dev Caller tried to mint an already burned token
    error IImmutableERC721MismatchedTransferLengths();

    /// @dev Caller tried to mint a tokenid that is above the hybrid threshold
    error IImmutableERC721IDAboveThreshold(uint256 tokenId);

    /// @dev Caller is not approved or owner
    error IImmutableERC721NotOwnerOrOperator(uint256 tokenId);

    /// @dev Current token owner is not what was expected
    error IImmutableERC721MismatchedTokenOwner(uint256 tokenId, address currentOwner);

    /// @dev Signer is zeroth address
    error SignerCannotBeZerothAddress();

    /// @dev Deadline exceeded for permit
    error PermitExpired();

    /// @dev Derived signature is invalid (EIP721 and EIP1271)
    error InvalidSignature();
}

interface OperatorAllowlistEnforcementErrors {
    /// @dev Error thrown when the operatorAllowlist address does not implement the IOperatorAllowlist interface
    error AllowlistDoesNotImplementIOperatorAllowlist();

    /// @dev Error thrown when calling address is not OperatorAllowlist
    error CallerNotInAllowlist(address caller);

    /// @dev Error thrown when 'from' address is not OperatorAllowlist
    error TransferFromNotInAllowlist(address from);

    /// @dev Error thrown when 'to' address is not OperatorAllowlist
    error TransferToNotInAllowlist(address to);

    /// @dev Error thrown when approve target is not OperatorAllowlist
    error ApproveTargetNotInAllowlist(address target);

    /// @dev Error thrown when approve target is not OperatorAllowlist
    error ApproverNotInAllowlist(address approver);
}

interface IImmutableERC1155Errors {
    /// @dev Deadline exceeded for permit
    error PermitExpired();

    /// @dev Derived signature is invalid (EIP721 and EIP1271)
    error InvalidSignature();
}
