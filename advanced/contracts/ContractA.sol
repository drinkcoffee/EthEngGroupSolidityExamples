/*
 * Copyright 2022 ConsenSys Software Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
pragma solidity >=0.8.11;

import "./ContractB.sol";

/**
 * Implementation of greeting contract which has a voting capability.
 */
contract ContractA {
    ContractB immutable public conB;

    uint256 public val;

    constructor (address _conB) {
        conB = ContractB(_conB);
    }

    function callStuff1(bool _fail) external {
        val = conB.stuff1(_fail);
    }

    function callStuff2(bool _fail) external {
        bool success;
        bytes memory returnValueEncoded;
        bytes memory funcParams = abi.encodeWithSelector(conB.stuff1.selector, _fail);
        (success, returnValueEncoded) = address(conB).call(funcParams);
        if (success) {
            val = abi.decode(returnValueEncoded, (uint256));
        }
        else {
            // Assume revert and not a panic
            assembly {
                // Remove the function selector / sighash.
                returnValueEncoded := add(returnValueEncoded, 0x04)
            }
            string memory revertReason = abi.decode(returnValueEncoded, (string));
            revert(revertReason);
        }
    }

    error MyPanic(uint256 _error);
    error UnknownError(bytes _error);

    function callStuff3(bool _fail) external {
        try conB.stuff1(_fail) returns (uint256 v) {
            val = v;
            return;
        } catch Error(string memory reason) {
            revert(reason);
        } catch Panic(uint256 errorCode) {
            revert MyPanic(errorCode);
        } catch (bytes memory lowLevelData) {
            revert UnknownError(lowLevelData);
        }        
    }


    error MyError(uint256 _errorCode, uint256 _balance);

    function throwMyError(bool _fail) external {
        if (_fail) {
            revert MyError(23, val);
        }
        val = 29;
    }

    function callStuff4(bool _fail) external {
        try conB.stuff1(_fail) returns (uint256 v) {
            val = v;
            return;
        } catch MyError(uint256 _errorCode, uint256 _balance) {
            revert("My error thrown");
        } catch Panic(uint256 errorCode) {
            revert MyPanic(errorCode);
        } catch (bytes memory lowLevelData) {
            revert UnknownError(lowLevelData);
        }        
    }

}