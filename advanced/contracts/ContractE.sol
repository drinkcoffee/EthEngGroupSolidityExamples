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

import "./ContractC.sol";
import "./ContractD.sol";

/**
 * Implementation of greeting contract which has a voting capability.
 */
contract ContractE is ContractC, ContractD {
    uint256 public val7;
    uint256 public val8;
    uint256 public val9;

    constructor () {
        val7 = 31;
        val8 = 32;
        val9 = 33;
    }





}