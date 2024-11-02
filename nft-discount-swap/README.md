# NFT Discount Swap

A smart contract system that implements NFT-based discounts for token swaps. The project includes ERC-721 NFTs with discount metadata, ERC-20 tokens for swapping, and a Uniswap v4 Hook implementation for discount-based swaps.

## Install dependencies:
```bash
npm install
```

## Smart Contracts

The project contains four main contracts:

- `DiscountNFT.sol`: ERC-721 token with discount metadata
- `ACDCToken.sol`: First ERC-20 token for swapping
- `SlayerToken.sol`: Second ERC-20 token for swapping
- `DiscountSwapHook.sol`: Uniswap v4 Hook implementation

## Testing

Run the test suite:
```bash
npx hardhat test
```

The tests cover:
- NFT minting and discount validation
- Token operations and permissions
- Swap functionality with different discount rates
- Integration scenarios

## Example Swap Scenario

1. Buyer has NFT with 15% discount and 30 ACDC tokens
2. Seller has 50 Slayer tokens
3. After swap with 15% discount on fee:
   - Seller receives 25.5 ACDC tokens
   - Buyer receives 50 Slayer tokens