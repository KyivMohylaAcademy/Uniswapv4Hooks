async function main() {
  // Get the deployer and Buyer accounts from the local Hardhat network
  const [deployer, buyer] = await ethers.getSigners();
  console.log("Minting NFT with the deployer account:", deployer.address);
  console.log("Using existing Buyer account:", buyer.address);

  // Define the address of the deployed DiscountNFT contract
  const discountNFTAddress = "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853"; // Replace with your actual deployed contract address

  // Attach the deployed contract
  const DiscountNFT = await ethers.getContractFactory("DiscountNFT");
  const discountNFT = DiscountNFT.attach(discountNFTAddress);

  // Mint a new NFT for the Buyer
  const discountValue = 15; // Set the discount value between 0 and 20
  const tokenURI = "https://example.com/metadata/1"; // Replace with your actual metadata URI

  console.log(`Minting NFT for Buyer at address ${buyer.address} with a discount of ${discountValue}%...`);
  const tx = await discountNFT.connect(deployer).mintNFT(buyer.address, tokenURI, discountValue); // Deployer mints for Buyer
  await tx.wait();

  // Check the balance of the Buyer to confirm the NFT minting
  const balance = await discountNFT.balanceOf(buyer.address);
  console.log(`Buyer now owns ${balance.toString()} NFT(s).`);

  console.log(`NFT minted successfully for Buyer at address: ${buyer.address}`);
}

main().catch((error) => {
  console.error("Error during NFT minting:", error);
  process.exitCode = 1;
});
