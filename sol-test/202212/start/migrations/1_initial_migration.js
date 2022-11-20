const Migrations = artifacts.require("Migrations");
const FlashLoanV1 = artifacts.require("FlashLoanV1");
//const FlashLoanV2 = artifacts.require("FlashLoanV2");
const UpgradeProxy = artifacts.require("UpgradeProxy");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(FlashLoanV1).then(() => {
    let initParams = web3.eth.abi.encodeParameter('bytes', '0x00');
    return deployer.deploy(UpgradeProxy, FlashLoanV1.address, initParams);
  });

};
