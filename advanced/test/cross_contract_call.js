/*
 * Copyright 2022 ConsenSys Software Inc.
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

/**
 * Examples showing calls from EOA -> ContractA -> Contract B.
 */
const Web3 = require('web3');
 
const ContractA = artifacts.require("./ContractA.sol");
const ContractB = artifacts.require("./ContractB.sol");

const web3 = new Web3(new Web3.providers.HttpProvider("127.0.0.1:9545"));
web3.eth.handleRevert = true;

contract('Cross-Contract Call', function(accounts) {
    it("callStuff1 with no revert", async function() {
        let conB = await ContractB.deployed();
        let conA = await ContractA.deployed(conB.address);

        await conA.callStuff1(false);
    });


    it("callStuff1 with revert", async function() {
        let conB = await ContractB.deployed();
        let conA = await ContractA.deployed(conB.address);

        let didNotTriggerError = false;
        try { 
            await conA.callStuff1(true);
            didNotTriggerError = true;
        } catch (err) {
                 console.log("Revert Reason: " + err.reason);
                  // this logs the expected revert message
        }
        assert.equal(didNotTriggerError, false, "***Revert was not triggered");
    });


    it("callStuff2 with no revert", async function() {
        let conB = await ContractB.deployed();
        let conA = await ContractA.deployed(conB.address);

        let oldVal = await conB.bVal.call();

        await conA.callStuff2(false);

        let val = await conB.bVal.call();
        assert.equal(val, parseInt(oldVal) + 1, "Value not correctly set");
    });

    it("callStuff2 with revert", async function() {
        let conB = await ContractB.deployed();
        let conA = await ContractA.deployed(conB.address);

        let oldVal = await conB.bVal.call();

        let didNotTriggerError = false;
        try { 
            await conA.callStuff2(true);
            didNotTriggerError = true;
        } catch (err) {
            console.log("Revert Reason: " + err.reason);
            // this logs the expected revert message
        }
        assert.equal(didNotTriggerError, false, "***Revert was not triggered");

        let val = await conB.bVal.call();
        assert.equal(parseInt(val), parseInt(oldVal), "Value unexpectedly set");
    });



    it("callStuff3 with no revert", async function() {
        let conB = await ContractB.deployed();
        let conA = await ContractA.deployed(conB.address);

        let oldVal = await conB.bVal.call();

        await conA.callStuff3(false);

        let val = await conB.bVal.call();
        assert.equal(val, parseInt(oldVal) + 1, "Value not correctly set");
    });

    it("callStuff3 with revert", async function() {
        let conB = await ContractB.deployed();
        let conA = await ContractA.deployed(conB.address);

        let oldVal = await conB.bVal.call();

        let didNotTriggerError = false;
        try { 
            await conA.callStuff3(true);
            didNotTriggerError = true;
        } catch (err) {
            console.log("Revert Reason: " + err.reason);
            // this logs the expected revert message
        }
        assert.equal(didNotTriggerError, false, "***Revert was not triggered");

        let val = await conB.bVal.call();
        assert.equal(parseInt(val), parseInt(oldVal), "Value unexpectedly set");
    });


});
