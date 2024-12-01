// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameNFT is ERC721, ReentrancyGuard, Ownable {
    uint256 private _nextTokenId = 1;
    uint256 public constant MINT_PRICE = 0.01 ether;  // Made constant

    struct Character {
        string name;
        uint8 level;
        uint8 power;
        bool isForSale;
        uint256 price;
    }

    mapping(uint256 => Character) public characters;

    event CharacterMinted(uint256 indexed tokenId, string name, uint8 level, uint8 power);
    event CharacterListed(uint256 indexed tokenId, uint256 price);
    event CharacterSold(uint256 indexed tokenId, address from, address to, uint256 price);
    event CharacterUnlisted(uint256 indexed tokenId);  // Added event
    event CharacterLevelUp(uint256 indexed tokenId, uint8 newLevel, uint8 newPower);  // Added event

    constructor() ERC721("Game Character", "GCHAR") {}

    function mintCharacter(string calldata name, uint8 level, uint8 power) external payable returns (uint256) {
        require(msg.value >= MINT_PRICE, "Insufficient payment");
        require(bytes(name).length > 0, "Name cannot be empty");  // Added validation

        uint256 tokenId = _nextTokenId++;

        _safeMint(msg.sender, tokenId);
        characters[tokenId] = Character(name, level, power, false, 0);

        emit CharacterMinted(tokenId, name, level, power);
        return tokenId;
    }

    function listCharacter(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(price > 0, "Price must be positive");

        characters[tokenId].isForSale = true;
        characters[tokenId].price = price;

        emit CharacterListed(tokenId, price);
    }

    function buyCharacter(uint256 tokenId) external payable nonReentrant {
        Character storage character = characters[tokenId];
        require(character.isForSale, "Not for sale");
        require(msg.value >= character.price, "Insufficient payment");

        address seller = ownerOf(tokenId);
        require(seller != msg.sender, "Can't buy your own character");

        character.isForSale = false;
        character.price = 0;

        _transfer(seller, msg.sender, tokenId);
        payable(seller).transfer(msg.value);  // Consider using pull pattern for large scale

        emit CharacterSold(tokenId, seller, msg.sender, msg.value);
    }

    function cancelListing(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(characters[tokenId].isForSale, "Not listed");  // Added check

        characters[tokenId].isForSale = false;
        characters[tokenId].price = 0;

        emit CharacterUnlisted(tokenId);
    }

    function levelUp(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");

        Character storage character = characters[tokenId];
        require(character.level < 100, "Max level reached");  // Added max level

        character.level += 1;
        character.power += 5;

        emit CharacterLevelUp(tokenId, character.level, character.power);
    }

    function getCharacter(uint256 tokenId) external view returns (Character memory) {
        return characters[tokenId];
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");  // Added check
        payable(owner()).transfer(balance);
    }
}