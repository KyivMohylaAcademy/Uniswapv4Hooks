async function main() {
  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log("Deploying TokenA with the account:", deployer.address);

  // Deploy the TokenA contract
  const TokenA = await ethers.getContractFactory("TokenA");
  const tokenA = await TokenA.deploy();

  // Log the entire contract object for inspection
  console.log("Deployed contract object for TokenA:", tokenA);

  // Check and log the contract address using `target`
  console.log("TokenA deployed to:", tokenA.target ? tokenA.target : "Address not found, check contract object");
}

// Handle errors and exit the process if there is an error
main().catch((error) => {
  console.error("Error during deployment of TokenA:", error);
  process.exitCode = 1;
});
