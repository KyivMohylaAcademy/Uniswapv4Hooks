async function main() {
  // Отримання акаунтів з локальної мережі Hardhat
  const [deployer, buyer] = await ethers.getSigners();
  console.log("Checking NFT ownership for Buyer at address:", buyer.address);

  // Підключення до контракту DiscountNFT
  const discountNFTAddress = "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853"; // Address of the deployed DiscountNFT contract
  const DiscountNFT = await ethers.getContractFactory("DiscountNFT");
  const discountNFT = DiscountNFT.attach(discountNFTAddress);

  // Перевірка володіння NFT
  const balance = await discountNFT.balanceOf(buyer.address);
  console.log(`Buyer owns ${balance.toString()} NFT(s).`);

  if (balance > 0) {
      console.log("Buyer successfully owns an NFT with a discount.");
  } else {
      console.log("Buyer does not own any NFTs. Check minting or contract address.");
  }
}

main().catch((error) => {
  console.error("Error during NFT ownership check:", error);
  process.exitCode = 1;
});
