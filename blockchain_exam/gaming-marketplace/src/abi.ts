export const MARKETPLACE_ABI = [
    "function createItem(string name, uint8 itemType, uint256 power) external returns (uint256)",
    "function listItem(uint256 tokenId, uint256 price) external",
    "function buyItem(uint256 tokenId) external payable",
    "function items(uint256 tokenId) external view returns (tuple(string name, uint8 itemType, uint256 power, uint256 price))",
    "event ItemCreated(uint256 indexed tokenId, string name, uint8 itemType, uint256 power)",
    "event ItemListed(uint256 indexed tokenId, uint256 price)",
    "event ItemSold(uint256 indexed tokenId, address seller, address buyer, uint256 price)"
];