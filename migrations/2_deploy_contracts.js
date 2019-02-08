var BlankToken = artifacts.require('BlankToken.sol');
var BlankMinter = artifacts.require('BlankMinter.sol');
var BlankCrowdsale = artifacts.require('BlankCrowdsale.sol');
var cap = 21*10**24


module.exports = function (deployer) {
  deployer.then(async () => {

    await deployer.deploy(BlankToken,cap);
    const instanceBlankToken = await BlankToken.deployed();

    await deployer.deploy(BlankMinter, instanceBlankToken.address);
    const instanceBlankMinter = await BlankMinter.deployed();

    await instanceBlankToken.transferOwnership(instanceBlankMinter.address);

    await deployer.deploy(BlankCrowdsale, instanceBlankToken.address, 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
    const instanceBlankCrowdsale = await BlankCrowdsale.deployed();
  })
}
