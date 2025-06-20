// Copyright Immutable Pty Ltd 2018 - 2023
// SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.8.19 <0.8.29;

// Interface to retrieve the implementation stored inside the Proxy contract
/// Interface for Passport Wallet's proxy contract.
interface IWalletProxy {
    // Returns the current implementation address used by the proxy contract
    // solhint-disable-next-line func-name-mixedcase
    function PROXY_getImplementation() external view returns (address);
}
