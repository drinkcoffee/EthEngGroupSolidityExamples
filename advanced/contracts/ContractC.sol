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
pragma solidity >=0.8;

contract ContractC {
    uint256 public val1;
    uint256 public val2;
    uint256 public val3;
    uint256 private dummyVal0;
    uint256 private dummyVal1;
    uint256 private dummyVal2;
    uint256 private dummyVal3;
    uint256 private dummyVal4;
    uint256 private dummyVal5;

    constructor () {
        val1 = 11;
        val2 = 12;
        val3 = 13;
    }
}