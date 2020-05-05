const EtherlessSmart = artifacts.require("./EtherlessSmart");
const Migrations = artifacts.require("./Migrations");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(EtherlessSmart);
};