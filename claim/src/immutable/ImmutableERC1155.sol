// Copyright Immutable Pty Ltd 2018 - 2023
// SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.8.19 <0.8.29;

import {ImmutableERC1155Base} from "./abstract/ImmutableERC1155Base.sol";

/**
 * @title ImmutableERC1155
 * @author @jasonzwli, Immutable
 */
contract ImmutableERC1155 is ImmutableERC1155Base {
    ///     =====   Constructor  =====

    /**
     * @notice Grants `DEFAULT_ADMIN_ROLE` to the supplied `owner` address
     *
     * Sets the name and symbol for the collection
     * Sets the default admin to `owner`
     * Sets the `baseURI`
     * Sets the royalty receiver and amount (this can not be changed once set)
     * @param owner The address that will be granted the `DEFAULT_ADMIN_ROLE`
     * @param name_ The name of the collection
     * @param baseURI_ The base URI for the collection
     * @param contractURI_ The contract URI for the collection
     * @param _operatorAllowlist The address of the OAL
     * @param _receiver The address that will receive the royalty payments
     * @param _feeNumerator The percentage of the sale price that will be paid as a royalty
     */
    constructor(
        address owner,
        string memory name_,
        string memory baseURI_,
        string memory contractURI_,
        address _operatorAllowlist,
        address _receiver,
        uint96 _feeNumerator
    ) ImmutableERC1155Base(owner, name_, baseURI_, contractURI_, _operatorAllowlist, _receiver, _feeNumerator) {}

    ///     =====   External functions  =====

    /**
     * @notice Mints a new token
     * @param to The address that will receive the minted tokens
     * @param id The id of the token to mint
     * @param value The amount of tokens to mint
     * @param data Additional data
     */
    function safeMint(address to, uint256 id, uint256 value, bytes memory data) external onlyRole(MINTER_ROLE) {
        super._mint(to, id, value, data);
    }

    /**
     * @notice Mints a batch of new tokens with different ids to the same recipient
     * @param to The address that will receive the minted tokens
     * @param ids The ids of the tokens to mint
     * @param values The amounts of tokens to mint
     * @param data Additional data
     */
    function safeMintBatch(
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes memory data
    ) external onlyRole(MINTER_ROLE) {
        super._mintBatch(to, ids, values, data);
    }
}
