var BlankToken = artifacts.require('BlankToken.sol');
var BlankCrowdsale = artifacts.require('BlankCrowdsale.sol');
var cap = 21*10**6


module.exports = function (deployer) {
  deployer.then(async () => {

    await deployer.deploy(BlankToken,cap);
    const instanceBlankToken = await BlankToken.deployed();

    await deployer.deploy(BlankCrowdsale, instanceBlankToken.address, '0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359');
    const instanceBlankCrowdsale = await BlankCrowdsale.deployed();

    await instanceBlankToken.transferOwnership(instanceBlankCrowdsale.address);
  })
}
