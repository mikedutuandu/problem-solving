// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract GameMarketplace is ERC721, ReentrancyGuard {
    struct Item {
        string name;
        uint8 itemType;  // 0: Weapon, 1: Armor
        uint256 power;
        uint256 price;   // in wei
    }

    mapping(uint256 => Item) public items;
    uint256 private _tokenIds;

    event ItemCreated(uint256 indexed tokenId, string name, uint8 itemType, uint256 power);
    event ItemListed(uint256 indexed tokenId, uint256 price);
    event ItemSold(uint256 indexed tokenId, address seller, address buyer, uint256 price);

    constructor() ERC721("Game Items", "GITM") {}

    // Core functions
    function createItem(string memory name, uint8 itemType, uint256 power) external returns (uint256) {
        _tokenIds++;
        _safeMint(msg.sender, _tokenIds);
        items[_tokenIds] = Item(name, itemType, power, 0);
        emit ItemCreated(_tokenIds, name, itemType, power);
        return _tokenIds;
    }

    function listItem(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        items[tokenId].price = price;
        emit ItemListed(tokenId, price);
    }

    function buyItem(uint256 tokenId) external payable nonReentrant {
        require(items[tokenId].price > 0, "Not for sale");
        require(msg.value >= items[tokenId].price, "Insufficient payment");

        address seller = ownerOf(tokenId);
        _transfer(seller, msg.sender, tokenId);
        payable(seller).transfer(msg.value);

        items[tokenId].price = 0;
        emit ItemSold(tokenId, seller, msg.sender, msg.value);
    }
}

