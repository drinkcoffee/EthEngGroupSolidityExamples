const Migrations = artifacts.require("Migrations");
const Loader = artifacts.require("Loader");
const Overwrite = artifacts.require("Overwrite");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Loader);
  deployer.deploy(Overwrite)

};
