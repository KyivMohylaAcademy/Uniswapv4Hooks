async function main() {
  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log("Deploying TokenB with the account:", deployer.address);

  // Deploy the TokenB contract
  const TokenB = await ethers.getContractFactory("TokenB");
  const tokenB = await TokenB.deploy();

  // Log the entire contract object for inspection
  console.log("Deployed contract object for TokenB:", tokenB);

  // Check and log the contract address using `target`
  console.log("TokenB deployed to:", tokenB.target ? tokenB.target : "Address not found, check contract object");
}

// Handle errors and exit the process if there is an error
main().catch((error) => {
  console.error("Error during deployment of TokenB:", error);
  process.exitCode = 1;
});
