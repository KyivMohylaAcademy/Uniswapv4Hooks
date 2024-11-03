async function main() {
  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log("Deploying DiscountNFT with the account:", deployer.address);

  // Deploy the DiscountNFT contract
  const DiscountNFT = await ethers.getContractFactory("DiscountNFT");
  const discountNFT = await DiscountNFT.deploy(); // Wait for deployment to complete

  // Log the full contract object for inspection
  console.log("Deployed contract object for DiscountNFT:", discountNFT);

  // Check and log the contract address
  console.log("DiscountNFT deployed to:", discountNFT.address ? discountNFT.address : discountNFT.target ? discountNFT.target : "Address not found, check contract object");
}

// Error handling
main().catch((error) => {
  console.error("Error during deployment of DiscountNFT:", error);
  process.exitCode = 1;
});
