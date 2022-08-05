// SPDX-License-Identifier: MIT

const Choice = artifacts.require("./Choice.sol");
const Loader = artifacts.require("./Loader.sol");
const OverWrite = artifacts.require("./OverWrite.sol");
const Get = artifacts.require("./Get.sol");

contract('Overwrite', function(accounts) {
    it("run test", async function() {
        let loader = await Loader.deployed();
        let overwrite = await OverWrite.deployed();

        console.log("Overwrite predicted address: " + overwrite.predictAddr(loader.address, true));

        let getContract1 = await overwrite.create(loader.address, true);
        // let getContractAddress = getContract1.address;
        // let getContract = await Get.at(getContractAddress)
        //
        // console.log("Get Contract address: " + getContractAddress);
        // console.log("Overwrite predicted address: " + overwrite.predictAddr(loader.address, true));
        // console.log("Get value: " + await getContract.get());
        //
        // await getContract.byte();
        //
        // getContract1 = await overwrite.create(loader.address, true);
        // getContractAddress = getContract1.address;
        // getContract = await Get.at(getContractAddress)
        //
        // console.log("Get Contract address: " + getContractAddress);
        // console.log("Overwrite predicted address: " + overwrite.predictAddr(loader.address, true));
        // console.log("Get value: " + await getContract.get());
    });
});
