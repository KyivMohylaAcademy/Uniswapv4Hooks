async function main() {
  // Get the deployer and Buyer accounts
  const [deployer, buyer] = await ethers.getSigners();
  console.log("Testing swap between Buyer:", buyer.address, "and Seller:", deployer.address);

  // Connect to the deployed SwapHook contract
  const swapHookAddress = "0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6"; // Address of the deployed SwapHook contract
  const SwapHook = await ethers.getContractFactory("SwapHook");
  const swapHook = SwapHook.attach(swapHookAddress);

  // Perform the swap and check the discount application
  try {
    const amountToSwap = ethers.utils.parseUnits("30", 18); // Example amount to swap
    console.log("Attempting swap with amount:", ethers.utils.formatUnits(amountToSwap, 18));

    // Use the buyer address that owns the NFT
    const discountedAmount = await swapHook.beforeSwap(buyer.address, amountToSwap);
    console.log("Discounted amount for swap:", ethers.utils.formatUnits(discountedAmount, 18));
  } catch (error) {
    console.error("Error during swap test:", error);
  }
}

main().catch((error) => {
  console.error("Error during script execution:", error);
  process.exitCode = 1;
});
