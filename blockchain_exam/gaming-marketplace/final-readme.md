# Simple Gaming Item Marketplace

A basic NFT marketplace for gaming items, designed for a 1-hour coding interview implementation.

## Project Structure
```
gaming-marketplace/
├── contracts/
│   └── GameMarketplace.sol     # Main smart contract
├── scripts/
│   └── deploy.ts               # Deployment script
├── src/
│   ├── abi.ts                  # Contract ABI
│   └── marketplace.ts          # TypeScript integration
├── hardhat.config.ts           # Hardhat configuration
└── index.html                  # Testing interface
```

## Core Features
1. Create gaming items (weapons/armors) as NFTs
2. List items for sale
3. Buy items with ETH

## Quick Setup

1. Create project and install dependencies:
```bash
mkdir gaming-marketplace
cd gaming-marketplace
npm init -y
npm install hardhat @nomicfoundation/hardhat-toolbox ethers dotenv
npx hardhat init
```

2. Copy contract, script, and config files into their respective folders

3. Create .env file:
```
PRIVATE_KEY=your_wallet_private_key
GOERLI_URL=your_goerli_rpc_url  # Optional, for testnet
```

4. Deploy contract:
```bash
# Start local node
npx hardhat node

# In new terminal, deploy
npx hardhat run scripts/deploy.ts --network localhost
```

5. Update contract address in your code

## Smart Contract Functions

```solidity
// Create new game item
function createItem(string name, uint8 itemType, uint256 power)

// List item for sale
function listItem(uint256 tokenId, uint256 price)

// Buy listed item
function buyItem(uint256 tokenId) payable
```

## TypeScript Integration

```typescript
class GameMarketplace {
    // Connect wallet
    async connect()

    // Create new item
    async createItem(name: string, itemType: number, power: number)

    // List item for sale
    async listItem(tokenId: string, priceInEth: string)

    // Buy item
    async buyItem(tokenId: string, priceInEth: string)
}
```

## Testing Flow
1. Deploy contract
2. Connect MetaMask
3. Create item:
   ```typescript
   const tokenId = await marketplace.createItem("Sword", 0, 100);
   ```
4. List item:
   ```typescript
   await marketplace.listItem(tokenId, "0.1");
   ```
5. Buy item:
   ```typescript
   await marketplace.buyItem(tokenId, "0.1");
   ```

## Common Interview Questions

1. Security:
   - Why use ReentrancyGuard for buyItem?
   - How to handle ETH transfers safely?
   - Importance of input validation

2. Features:
   - How to add batch minting?
   - How to implement cancel listing?
   - How to add item metadata/URI?

3. Gas Optimization:
   - Struct packing in Item struct
   - Event usage efficiency
   - Storage vs Memory usage

## Tips for Interview
- Start with contract implementation
- Add basic TypeScript integration
- Test core functions first
- Add extra features if time permits
- Focus on security best practices

## Code Example

Basic item creation and listing:
```typescript
const provider = new ethers.providers.Web3Provider(window.ethereum);
const marketplace = new GameMarketplace(CONTRACT_ADDRESS, provider);

// Connect wallet
await marketplace.connect();

// Create item
const tokenId = await marketplace.createItem("Excalibur", 0, 100);
console.log("Created item:", tokenId);

// List item
await marketplace.listItem(tokenId, "0.1");
console.log("Listed for 0.1 ETH");
```

## Files Needed
Make sure you have:
1. GameMarketplace.sol
2. hardhat.config.ts
3. deploy.ts
4. marketplace.ts
5. abi.ts
6. index.html