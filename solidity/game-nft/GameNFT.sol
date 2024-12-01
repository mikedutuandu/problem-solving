// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameNFT is ERC721, Ownable {
    uint256 private _nextTokenId = 1;
    uint256 public constant MINT_PRICE = 0.01 ether;

    struct Character {
        string name;
        uint8 level;
        uint8 power;
        bool isForSale;
        uint256 price;
    }

    mapping(uint256 => Character) public characters;

    event CharacterMinted(uint256 indexed tokenId, string name);
    event CharacterListed(uint256 indexed tokenId, uint256 price);
    event CharacterSold(uint256 indexed tokenId, address from, address to, uint256 price);
    event CharacterLevelUp(uint256 indexed tokenId, uint8 newLevel);

    constructor() ERC721("Game Character", "GCHAR") {}

    function mintCharacter(string calldata name) external payable returns (uint256) {
        require(msg.value >= MINT_PRICE, "Insufficient payment");
        require(bytes(name).length > 0, "Name required");

        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);

        // Start at level 1 with power 10
        characters[tokenId] = Character(name, 1, 10, false, 0);

        emit CharacterMinted(tokenId, name);
        return tokenId;
    }

    function listCharacter(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(price > 0, "Invalid price");

        characters[tokenId].isForSale = true;
        characters[tokenId].price = price;

        emit CharacterListed(tokenId, price);
    }

    function buyCharacter(uint256 tokenId) external payable {
        Character storage character = characters[tokenId];
        address seller = ownerOf(tokenId);

        require(character.isForSale, "Not for sale");
        require(msg.value >= character.price, "Low payment");
        require(seller != msg.sender, "Can't self buy");

        character.isForSale = false;
        character.price = 0;

        _transfer(seller, msg.sender, tokenId);
        payable(seller).transfer(msg.value);

        emit CharacterSold(tokenId, seller, msg.sender, msg.value);
    }

    function levelUp(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not owner");

        Character storage character = characters[tokenId];
        require(character.level < 100, "Max level");

        character.level++;
        character.power += 5;

        emit CharacterLevelUp(tokenId, character.level);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}