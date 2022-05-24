module.exports = async function ({ ethers, deployments, getNamedAccounts }) {
  const { deploy } = deployments

  const { deployer } = await getNamedAccounts()

  const PogoTokenAddress = "0x303D22b4cd2A5c811aD95f13787E7f1E71BE1899"
  
  const Pogo = await ethers.getContract("PogoToken")
  
  const { address } = await deploy("MasterChefV2", {
    from: deployer,
    args: [],
    log: true,
    deterministicDeployment: false
  })

//  if (await Pogo.owner() !== address) {
    // Transfer Pogo Ownership to Chef
//    console.log("Transfer Pogo Ownership to Chef")
//    await (await Pogo.transferOwnership(address)).wait()
//  }

//	const masterChef = await ethers.getContract("MasterChefV2")
//  if (await masterChef.owner() !== deployer) {
    // Transfer ownership of MasterChef to dev
  //  console.log("Transfer ownership of MasterChefV2 to dev")
	//    await (await masterChef.transferOwnership(dev)).wait()
//  }
},

module.exports.tags = ["MasterChefV2"]
module.exports.dependencies = ["UniswapV2Factory", "UniswapV2Router02", "PogoToken"]
