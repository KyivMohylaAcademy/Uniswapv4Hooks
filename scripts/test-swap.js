const { ethers } = require("hardhat");

async function main() {
    const [deployer, buyer, seller] = await ethers.getSigners();

    // Отримуємо розгорнуті контракти
    const DiscountHook = await ethers.getContractFactory("DiscountHook");
    const ACDC = await ethers.getContractFactory("ACDC");
    const Slayer = await ethers.getContractFactory("Slayer");

    // Використовуємо нові адреси з останнього деплою
    const discountHook = DiscountHook.attach("0x4826533B4897376654Bb4d4AD88B7faFD0C98528");
    const acdc = ACDC.attach("0xf5059a5D33d5853360D16C683c16e67980206f36");
    const slayer = Slayer.attach("0x95401dc811bb5740090279Ba06cfA8fcF6113778");

    // Спочатку передаємо токени Slayer на контракт DiscountHook
    const hookAddress = await discountHook.getAddress();
    console.log("Передаємо Slayer токени на DiscountHook...");
    await slayer.connect(seller).approve(hookAddress, ethers.parseEther("50"));
    await slayer.connect(seller).transfer(hookAddress, ethers.parseEther("50"));

    // Approve токени для свопу
    const amount = ethers.parseEther("30");
    console.log("Апрувимо ACDC токени для свопу...");
    await acdc.connect(buyer).approve(hookAddress, amount);

    console.log("\nБаланси до свопу:");
    console.log("Buyer ACDC:", ethers.formatEther(await acdc.balanceOf(buyer.address)));
    console.log("Buyer Slayer:", ethers.formatEther(await slayer.balanceOf(buyer.address)));
    console.log("Seller ACDC:", ethers.formatEther(await acdc.balanceOf(seller.address)));
    console.log("Seller Slayer:", ethers.formatEther(await slayer.balanceOf(seller.address)));
    console.log("DiscountHook Slayer:", ethers.formatEther(await slayer.balanceOf(hookAddress)));

    // Виконуємо своп
    console.log("\nВиконуємо своп...");
    await discountHook.connect(buyer).swap(amount, true);

    console.log("\nБаланси після свопу:");
    console.log("Buyer ACDC:", ethers.formatEther(await acdc.balanceOf(buyer.address)));
    console.log("Buyer Slayer:", ethers.formatEther(await slayer.balanceOf(buyer.address)));
    console.log("Seller ACDC:", ethers.formatEther(await acdc.balanceOf(seller.address)));
    console.log("Seller Slayer:", ethers.formatEther(await slayer.balanceOf(seller.address)));
    console.log("DiscountHook Slayer:", ethers.formatEther(await slayer.balanceOf(hookAddress)));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    }); 