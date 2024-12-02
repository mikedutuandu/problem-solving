// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";

import "./Base.sol";

contract GameNFT is ERC721, Base {
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

    function mintCharacter(string calldata name) external payable noReentrancy returns (uint256) {
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

    function buyCharacter(uint256 tokenId) external payable noReentrancy {
        Character storage character = characters[tokenId];
        address seller = ownerOf(tokenId);
        uint256 price = character.price;

        require(character.isForSale, "Not for sale");
        require(msg.value >= price, "Low payment");
        require(seller != msg.sender, "Can't self buy");

        // 1. Update state
        character.isForSale = false;
        character.price = 0;

        // 2. Transfer payment first
        (bool success,) = payable(seller).call{value: msg.value}("");
        require(success, "ETH transfer failed");

        //old way 2300 gas limit
        //payable(seller).transfer(msg.value);

        // 3. Only transfer NFT after payment success
        _transfer(seller, msg.sender, tokenId);


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

    // Function to withdraw all Ether from this contract.
    // Most recommended way
    function withdraw() public {
        // get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;

        // send all Ether to owner
        (bool success,) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    // Function to withdraw all Ether from this contract.
    // Limited to 2300 gas, and problems with 2300 gas limit:
    // + Can break when receiving contract is complex
    // + Future Ethereum upgrades might change gas costs
    // + Not flexible for modern DeFi interactions
    /*
    function withdraw() external noReentrancy isOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance");
        payable(owner).transfer(balance);
    }
    */

}