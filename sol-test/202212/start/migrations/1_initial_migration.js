const Migrations = artifacts.require("Migrations");
const FlashLoanV1 = artifacts.require("FlashLoanV1");
const FlashLoanV2 = artifacts.require("FlashLoanV2");
const UpgradeProxy = artifacts.require("UpgradeProxy");
const FlashLoanReceiver = artifacts.require("TestFlashLoanReceiver");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(FlashLoanV2, web3.eth.abi.encodeParameter('uint256', '0x00000000000000000000000000000000000000000000000000000000000003E8'));
  deployer.deploy(FlashLoanV1, web3.eth.abi.encodeParameter('uint256', '0x00000000000000000000000000000000000000000000000000000000000003E8')).then(() => {
    let initParams = web3.eth.abi.encodeParameter('bytes', '0x00');
    return deployer.deploy(UpgradeProxy, FlashLoanV1.address, initParams);
  }).then(() => {
    return deployer.deploy(FlashLoanReceiver, FlashLoanV1.address);
  });

};
