const ERC20 = artifacts.require("ERC20")
const IDO = artifacts.require("IDO")
var tokenABI = require("../build/contracts/ERC20.json").abi

module.exports = async function (deployer, network, addresses) {
    await deployer.deploy(ERC20, "IDO", "TES");
    await deployer.deploy(IDO, ERC20.address, addresses[0]) // token addres + withdrawal address

    var IDOToken = new web3.eth.Contract(tokenABI, ERC20.address)
    await IDOToken.methods.addMinter(IDO.address)
                          .send({ from: addresses[0]})

};