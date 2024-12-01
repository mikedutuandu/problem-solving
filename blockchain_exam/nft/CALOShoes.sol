// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

contract CALOShoes is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721URIStorageUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    ERC721BurnableUpgradeable
{
    using SafeMathUpgradeable for uint256;

    bytes32 public MINTER_ROLE;

    address public caloManager;

    mapping(address => bool) public addressBlacklist;
    mapping(uint256 => bool) public idBlacklist;

    function initialize(address _caloManager) public initializer {
        __ERC721_init("CALO Shoe", "CLS");
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __Pausable_init();
        __AccessControl_init();
        __ERC721Burnable_init();

        caloManager = _caloManager;
        MINTER_ROLE = keccak256("MINTER_ROLE");

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function setCaloManager(address _newCaloManager)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        caloManager = _newCaloManager;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://api.calo.run/shoe/";
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function mint(address _to, uint256 tokenId)
        public
        onlyRole(MINTER_ROLE)
        whenNotPaused
    {
        _safeMint(_to, tokenId);
    }

    function isExist(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    )
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        whenNotPaused
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.
    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            AccessControlUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function withdrawERC20Token(address _tokenAddress, uint256 amount)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        IERC20(_tokenAddress).transfer(_msgSender(), amount);
    }

    function setAddressBlacklist(address[] memory addresses, bool isBlacklist)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        for (uint256 i = 0; i < addresses.length; i++) {
            addressBlacklist[addresses[i]] = isBlacklist;
        }
    }

    function setIdBlacklist(uint256[] memory ids, bool isBlacklist)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        for (uint256 i = 0; i < ids.length; i++) {
            idBlacklist[ids[i]] = isBlacklist;
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 tokenID
    ) internal override(ERC721Upgradeable) {
        require(
            !addressBlacklist[sender] && !addressBlacklist[recipient],
            "the address is blacklisted"
        );
        require(!idBlacklist[tokenID], "the token id is blacklisted");

        ERC721Upgradeable._transfer(sender, recipient, tokenID);
    }
}

interface IManageContract {
    function getContract(string memory contract_)
        external
        view
        returns (address);
}

interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);
}
