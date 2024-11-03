
# Uniswap V4 Hooks Project

## Overview

This project demonstrates the development of smart contracts for token swaps with custom functionality using Uniswap V4 Hooks. It includes an ERC-721 NFT contract, ERC-20 tokens, and a hook contract that applies discounts based on NFT ownership.

## Project Components

1. **ERC-721 Contract (`DiscountNFT.sol`)**:
   - A non-fungible token (NFT) contract with a metadata field called `discount`, ranging from 0 to 20.
   - Mintable NFTs that grant discounts to the owner during token swaps.

2. **ERC-20 Token Contracts (`TokenA.sol` and `TokenB.sol`)**:
   - Two ERC-20 token contracts representing tokens for swapping.
   - Deployed to provide a test environment for swap transactions between Buyer and Seller.

3. **Uniswap V4 Hook Contract (`SwapHook.sol`)**:
   - A hook contract that verifies the ownership of the `DiscountNFT` by the Buyer and applies the discount during swaps.
   - Example: If a Buyer owns an NFT with a 15% discount and initiates a swap, the swap amount is reduced by the specified percentage.

## Key Features

- **NFT Discount Mechanism**:
  - Checks if the Buyer owns a `DiscountNFT` before a swap.
  - Retrieves the `discount` value from the NFT's metadata and applies it to the transaction.
  
- **ERC-20 Token Management**:
  - Buyer and Seller accounts are set up with ERC-20 tokens to demonstrate swapping.
  
- **Swap Testing**:
  - A script (`testSwap.js`) simulates the swap process and validates the discount application.

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/)
- [Hardhat](https://hardhat.org/)
- [Ethers.js](https://docs.ethers.io/v5/)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/KyivMohylaAcademy/Uniswapv4Hooks
   cd UniswapV4Hooks
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

### Deployment and Testing

1. **Compile Contracts**:
   ```bash
   npx hardhat compile
   ```

2. **Deploy Contracts**:
   Deploy the NFT and hook contracts using the provided deployment scripts:
   ```bash
   npx hardhat run scripts/deployTokenA.js --network localhost
   npx hardhat run scripts/deployTokenB.js --network localhost
   npx hardhat run scripts/deployDiscountNFT.js --network localhost
   npx hardhat run scripts/deploySwapHook.js --network localhost
   ```

3. **Mint NFT**:
   Use the `mintDiscountNFT.js` script to mint an NFT with a discount for the Buyer:
   ```bash
   npx hardhat run scripts/mintDiscountNFT.js --network localhost
   ```

4. **Test the Swap**:
   Run the `testSwap.js` script to simulate a swap and validate the discount:
   ```bash
   npx hardhat run scripts/testSwap.js --network localhost
   ```

### Project Structure

```
.
├── contracts
│   ├── DiscountNFT.sol
│   ├── SwapHook.sol
│   ├── TokenA.sol
│   └── TokenB.sol
├── scripts
│   ├── deployDiscountNFT.js
│   ├── deploySwapHook.js
│   ├── deployTokenA.js
│   ├── deployTokenB.js
│   ├── mintDiscountNFT.js
│   └── testSwap.js
├── README.md
├── hardhat.config.js
└── package.json
```

### Notes

- Ensure the contract addresses in the scripts match the deployed addresses.
- The `testSwap.js` script requires an NFT minted to the Buyer account to simulate the discount mechanism effectively.

## License

This project is licensed under the MIT License.
