var BlankToken = artifacts.require('BlankToken.sol');
var Minter = artifacts.require('Minter.sol');
var BlankCrowdsale = artifacts.require('BlankCrowdsale.sol');
var cap = 21*10**24


module.exports = function (deployer) {
  deployer.then(async () => {

    await deployer.deploy(BlankToken,cap);
    const instanceBlankToken = await BlankToken.deployed();

    await deployer.deploy(Minter, instanceBlankToken.address);
    const instanceMinter = await Minter.deployed();

    await instanceBlankToken.transferOwnership(instanceMinter.address);

    await deployer.deploy(BlankCrowdsale, instanceBlankToken.address, 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
    const instanceBlankCrowdsale = await BlankCrowdsale.deployed();
  })
}
