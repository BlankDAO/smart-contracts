var BlankToken = artifacts.require('BlankToken.sol');
var BlankMinter = artifacts.require('BlankMinter.sol');
var BlankCrowdsale = artifacts.require('BlankCrowdsale.sol');
var cap = 21*10**24;
var financeAddr = '';
var stableTokenAddr = '';

module.exports = function (deployer) {
  deployer.then(async () => {

    await deployer.deploy(BlankToken,cap);
    const instanceBlankToken = await BlankToken.deployed();

    await deployer.deploy(BlankMinter, instanceBlankToken.address, financeAddr);
    const instanceBlankMinter = await BlankMinter.deployed();

    await instanceBlankToken.transferOwnership(instanceBlankMinter.address);

    await deployer.deploy(BlankCrowdsale, instanceBlankToken.address, stableTokenAddr, financeAddr);
    const instanceBlankCrowdsale = await BlankCrowdsale.deployed();

  })
}
