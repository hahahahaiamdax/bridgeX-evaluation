const Service = artifacts.require("Service");
const Logic1 = artifacts.require("Logic1");
const Logic2 = artifacts.require("Logic2");
const TransparentProxy = artifacts.require("TransparentProxy");


module.exports = async function (deployer, env, accounts) {
    await deployer.deploy(Logic1);
    await deployer.deploy(Logic2);
    await deployer.deploy(Service)
    await deployer.deploy(TransparentProxy, Logic1.address, accounts[0])
};
