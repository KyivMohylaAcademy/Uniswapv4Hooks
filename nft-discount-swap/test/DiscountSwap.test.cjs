// test/DiscountSwap.test.cjs

const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFT Discount Swap", function () {
    let DiscountNFT, ACDCToken, SlayerToken, DiscountSwapHook;
    let discountNFT, acdcToken, slayerToken, discountSwapHook;
    let owner, buyer, seller, otherUser;

    beforeEach(async function () {
        [owner, buyer, seller, otherUser] = await ethers.getSigners();

        // Deploy NFT contract
        const DiscountNFTFactory = await ethers.getContractFactory("DiscountNFT");
        discountNFT = await DiscountNFTFactory.deploy();
        await discountNFT.waitForDeployment();

        // Deploy ERC20 tokens
        const ACDCTokenFactory = await ethers.getContractFactory("ACDCToken");
        acdcToken = await ACDCTokenFactory.deploy();
        await acdcToken.waitForDeployment();

        const SlayerTokenFactory = await ethers.getContractFactory("SlayerToken");
        slayerToken = await SlayerTokenFactory.deploy();
        await slayerToken.waitForDeployment();

        // Deploy Swap Hook
        const DiscountSwapHookFactory = await ethers.getContractFactory("DiscountSwapHook");
        discountSwapHook = await DiscountSwapHookFactory.deploy(
            await discountNFT.getAddress(),
            await acdcToken.getAddress(),
            await slayerToken.getAddress()
        );
        await discountSwapHook.waitForDeployment();

        // Mint initial tokens
        const INITIAL_ACDC_AMOUNT = ethers.parseEther("30");
        const INITIAL_SLAYER_AMOUNT = ethers.parseEther("50");

        await acdcToken.mint(buyer.address, INITIAL_ACDC_AMOUNT);
        await slayerToken.mint(seller.address, INITIAL_SLAYER_AMOUNT);

        // Mint NFT to buyer with 15% discount
        await discountNFT.mint(buyer.address, 15);

        // Approve tokens for swap
        await acdcToken.connect(buyer).approve(await discountSwapHook.getAddress(), INITIAL_ACDC_AMOUNT);
        await slayerToken.connect(seller).approve(await discountSwapHook.getAddress(), INITIAL_SLAYER_AMOUNT);
    });

    describe("NFT Contract", function () {
        it("Should not allow minting NFT with discount > 20%", async function () {
            await expect(
                discountNFT.mint(buyer.address, 21)
            ).to.be.revertedWith("Discount must be <= 20%");
        });

        it("Should allow minting multiple NFTs with different discounts", async function () {
            await discountNFT.mint(buyer.address, 10);
            await discountNFT.mint(buyer.address, 20);

            expect(await discountNFT.getDiscount(2n)).to.equal(10);
            expect(await discountNFT.getDiscount(3n)).to.equal(20);
        });

        it("Should not allow getting discount for non-existent token", async function () {
            await expect(
                discountNFT.getDiscount(999n)
            ).to.be.revertedWith("Token does not exist");
        });
    });

    describe("Token Contracts", function () {
        it("Should only allow owner to mint tokens", async function () {
            // We expect the transaction to be reverted with OwnableUnauthorizedAccount error
            await expect(
                acdcToken.connect(otherUser).mint(otherUser.address, ethers.parseEther("100"))
            ).to.be.revertedWithCustomError(acdcToken, "OwnableUnauthorizedAccount");

            await expect(
                slayerToken.connect(otherUser).mint(otherUser.address, ethers.parseEther("100"))
            ).to.be.revertedWithCustomError(slayerToken, "OwnableUnauthorizedAccount");
        });

        it("Should track token balances correctly after multiple mints", async function () {
            const amount1 = ethers.parseEther("100");
            const amount2 = ethers.parseEther("50");

            await acdcToken.mint(otherUser.address, amount1);
            await acdcToken.mint(otherUser.address, amount2);

            expect(await acdcToken.balanceOf(otherUser.address)).to.equal(amount1 + amount2);
        });
    });

    describe("Swap Functionality", function () {
        it("Should execute swap with 0% discount correctly", async function () {
            // Mint new NFT with 0% discount
            await discountNFT.mint(buyer.address, 0);
            const tokenId = 2n;
            const swapAmount = ethers.parseEther("10");

            // Calculate expected amount with 0% discount
            const fee = (swapAmount * 2n) / 100n; // 2% base fee
            const expectedFinalAmount = swapAmount - fee;

            await acdcToken.connect(buyer).approve(await discountSwapHook.getAddress(), swapAmount);
            await slayerToken.connect(seller).approve(await discountSwapHook.getAddress(), expectedFinalAmount);

            await discountSwapHook.executeSwap(
                buyer.address,
                seller.address,
                tokenId,
                swapAmount
            );

            expect(await slayerToken.balanceOf(buyer.address)).to.equal(expectedFinalAmount);
        });

        it("Should execute swap with 20% discount correctly", async function () {
            // Mint new NFT with 20% discount
            await discountNFT.mint(buyer.address, 20);
            const tokenId = 2n;
            const swapAmount = ethers.parseEther("10");

            // Calculate expected amount with 20% discount
            const baseFee = (swapAmount * 2n) / 100n; // 2% base fee
            const discountedFee = baseFee - (baseFee * 20n) / 100n;
            const expectedFinalAmount = swapAmount - discountedFee;

            await acdcToken.connect(buyer).approve(await discountSwapHook.getAddress(), swapAmount);
            await slayerToken.connect(seller).approve(await discountSwapHook.getAddress(), expectedFinalAmount);

            await discountSwapHook.executeSwap(
                buyer.address,
                seller.address,
                tokenId,
                swapAmount
            );

            expect(await slayerToken.balanceOf(buyer.address)).to.equal(expectedFinalAmount);
        });

        it("Should fail if tokens are not approved", async function () {
            const tokenId = 1n;
            const swapAmount = ethers.parseEther("10");

            // Reset approvals
            await acdcToken.connect(buyer).approve(await discountSwapHook.getAddress(), 0);

            await expect(
                discountSwapHook.executeSwap(
                    buyer.address,
                    seller.address,
                    tokenId,
                    swapAmount
                )
            ).to.be.reverted;
        });

        it("Should fail if insufficient balance", async function () {
            const tokenId = 1n;
            const swapAmount = ethers.parseEther("1000"); // More than available

            await expect(
                discountSwapHook.executeSwap(
                    buyer.address,
                    seller.address,
                    tokenId,
                    swapAmount
                )
            ).to.be.reverted;
        });

        it("Should validate addresses are not zero", async function () {
            const tokenId = 1n;
            const swapAmount = ethers.parseEther("10");
            const zeroAddress = "0x0000000000000000000000000000000000000000";

            await expect(
                discountSwapHook.executeSwap(
                    zeroAddress,
                    seller.address,
                    tokenId,
                    swapAmount
                )
            ).to.be.reverted;

            await expect(
                discountSwapHook.executeSwap(
                    buyer.address,
                    zeroAddress,
                    tokenId,
                    swapAmount
                )
            ).to.be.reverted;
        });
    });

    describe("Integration Tests", function () {
        it("Should handle multiple swaps with same NFT", async function () {
            const tokenId = 1n;
            const swapAmount = ethers.parseEther("10");

            // First swap
            await discountSwapHook.executeSwap(
                buyer.address,
                seller.address,
                tokenId,
                swapAmount
            );

            // Second swap
            await discountSwapHook.executeSwap(
                buyer.address,
                seller.address,
                tokenId,
                swapAmount
            );

            // Verify final balances
            const baseFee = (swapAmount * 2n) / 100n;
            const discountedFee = baseFee - (baseFee * 15n) / 100n;
            const expectedAmount = (swapAmount - discountedFee) * 2n;

            expect(await slayerToken.balanceOf(buyer.address)).to.equal(expectedAmount);
        });

        it("Should work with different NFT discounts for same user", async function () {
            // Mint second NFT with different discount
            await discountNFT.mint(buyer.address, 10);
            const swapAmount = ethers.parseEther("10");

            // Swap with first NFT (15% discount)
            await discountSwapHook.executeSwap(
                buyer.address,
                seller.address,
                1n,
                swapAmount
            );

            // Swap with second NFT (10% discount)
            await discountSwapHook.executeSwap(
                buyer.address,
                seller.address,
                2n,
                swapAmount
            );

            // Balances should reflect different discount rates
            const expectedAmount1 = swapAmount - (swapAmount * 2n) / 100n * (85n) / 100n;
            const expectedAmount2 = swapAmount - (swapAmount * 2n) / 100n * (90n) / 100n;

            expect(await slayerToken.balanceOf(buyer.address)).to.equal(expectedAmount1 + expectedAmount2);
        });
    });
});