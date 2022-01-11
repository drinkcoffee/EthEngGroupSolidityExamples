const Migrations = artifacts.require("Migrations");
const ContractA = artifacts.require("./ContractA.sol");
const ContractB = artifacts.require("./ContractB.sol");


module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(ContractB).then(() => {
    return deployer.deploy(ContractA, ContractB.address);
  });
  
};
