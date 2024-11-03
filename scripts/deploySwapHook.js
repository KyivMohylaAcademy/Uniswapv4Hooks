async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying SwapHook with the deployer account:", deployer.address);

  // Define the address of the deployed DiscountNFT contract
  const discountNFTAddress = "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853"; // Address of the deployed DiscountNFT contract

  // Deploy the SwapHook contract
  const SwapHook = await ethers.getContractFactory("SwapHook");
  const swapHook = await SwapHook.deploy(discountNFTAddress);

  // Log the address of the deployed contract
  console.log("SwapHook deployed to:", swapHook.address);
}

main().catch((error) => {
  console.error("Error during deployment of SwapHook:", error);
  process.exitCode = 1;
});
