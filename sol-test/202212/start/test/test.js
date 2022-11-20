// SPDX-License-Identifier: MIT

const FlashLoanV1 = artifacts.require("./FlashLoanV1.sol");
const UpgradeProxy = artifacts.require("./UpgradeProxy.sol");

contract('UpgradeTest', function(accounts) {
    it("payme1", async function() {
        let flashloanv1Contract = await FlashLoanV1.deployed();
        console.log("FlashLoanV1 contract address: " + flashloanv1Contract.address);
        console.log("Interest: " + flashloanv1Contract.interestRatePerBlock().call);

//        let getContract1 = await overwrite.create(loader.address, true);
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
