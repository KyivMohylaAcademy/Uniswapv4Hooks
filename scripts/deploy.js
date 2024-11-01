const { ethers } = require("hardhat");

async function main() {
    // Отримуємо акаунти
    const [deployer, buyer, seller] = await ethers.getSigners();

    // Розгортаємо NFT контракт
    const DiscountNFT = await ethers.getContractFactory("DiscountNFT");
    const discountNFT = await DiscountNFT.deploy();
    await discountNFT.waitForDeployment();

    // Мінтимо NFT для Buyer зі знижкою 15%
    await discountNFT.mint(buyer.address, 15);

    // Розгортаємо токени
    const ACDC = await ethers.getContractFactory("ACDC");
    const acdc = await ACDC.deploy();
    await acdc.waitForDeployment();

    const Slayer = await ethers.getContractFactory("Slayer");
    const slayer = await Slayer.deploy();
    await slayer.waitForDeployment();

    // Мінтимо токени
    await acdc.mint(buyer.address, ethers.parseEther("30"));
    await slayer.mint(seller.address, ethers.parseEther("50"));

    // Розгортаємо Hook з обома токенами
    const DiscountHook = await ethers.getContractFactory("DiscountHook");
    const discountHook = await DiscountHook.deploy(
        await discountNFT.getAddress(),
        await acdc.getAddress(),
        await slayer.getAddress(),
        seller.address
    );
    await discountHook.waitForDeployment();

    console.log("Контракти розгорнуто:");
    console.log("DiscountNFT:", await discountNFT.getAddress());
    console.log("ACDC:", await acdc.getAddress());
    console.log("Slayer:", await slayer.getAddress());
    console.log("DiscountHook:", await discountHook.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    }); 