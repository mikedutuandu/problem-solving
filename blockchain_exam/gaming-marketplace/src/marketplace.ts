import { ethers } from 'ethers';
import { MARKETPLACE_ABI } from './abi';

export class GameMarketplace {
    private contract: ethers.Contract;
    private signer?: ethers.providers.JsonRpcSigner;

    constructor(contractAddress: string, provider: ethers.providers.Web3Provider) {
        this.contract = new ethers.Contract(contractAddress, MARKETPLACE_ABI, provider);
    }

    async connect() {
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        this.signer = this.contract.provider.getSigner();
        this.contract = this.contract.connect(this.signer);
    }

    async createItem(name: string, itemType: number, power: number) {
        const tx = await this.contract.createItem(name, itemType, power);
        const receipt = await tx.wait();
        return receipt.events[0].args.tokenId.toString();
    }

    async listItem(tokenId: string, priceInEth: string) {
        const tx = await this.contract.listItem(tokenId, ethers.utils.parseEther(priceInEth));
        await tx.wait();
    }

    async buyItem(tokenId: string, priceInEth: string) {
        const tx = await this.contract.buyItem(tokenId, {
            value: ethers.utils.parseEther(priceInEth)
        });
        await tx.wait();
    }
}