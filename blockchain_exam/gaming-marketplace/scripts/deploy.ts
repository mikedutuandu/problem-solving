import { ethers } from "hardhat";

async function main() {
    // Get the contract factory
    const GameMarketplace = await ethers.getContractFactory("GameMarketplace");

    // Deploy the contract
    const marketplace = await GameMarketplace.deploy();
    await marketplace.deployed();

    console.log("GameMarketplace deployed to:", marketplace.address);
}

// Handle errors
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
