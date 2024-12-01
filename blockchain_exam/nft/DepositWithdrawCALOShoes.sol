// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "../../ICALOManager.sol";

contract DepositWithdrawCALOShoes is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable
{
    mapping(address => mapping(uint256 => bool)) isUsedNonce;
    mapping(string => bool) isUsedTxid;

    address public caloManager;
    string public NFT_NAME;

    event NFTDeposited(
        address indexed sender,
        string userId,
        uint256 nftId,
        string txid
    );
    event NFTBatchDeposited(
        address indexed sender,
        string userId,
        uint256[] nftIds,
        string txid
    );
    event NFTWithdrawn(
        address indexed receiver,
        string userId,
        uint256 nftId,
        uint256 nonce
    );
    event NFTBatchWithdrawn(
        address indexed receiver,
        string userId,
        uint256[] nftIds,
        uint256 nonce
    );

    constructor() {}

    function initialize(address _caloManager) public initializer {
        __Pausable_init();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        caloManager = _caloManager;
        NFT_NAME = "CALOShoe";
    }

    function depositNFT(
        string calldata _userId,
        uint256 _nftId,
        string calldata _txid
    ) public whenNotPaused {
        require(!isUsedTxid[_txid], "Transaction ID is used");
        IERC721(ICALOManager(caloManager).getContract(NFT_NAME)).transferFrom(
            msg.sender,
            address(this),
            _nftId
        );
        emit NFTDeposited(msg.sender, _userId, _nftId, _txid);
    }

    function batchDepositNFT(
        string calldata _userId,
        uint256[] calldata _nftIds,
        string calldata _txid
    ) public whenNotPaused {
        require(!isUsedTxid[_txid], "Transaction ID is used");
        for (uint256 i; i < _nftIds.length; i++) {
            IERC721(ICALOManager(caloManager).getContract(NFT_NAME))
                .transferFrom(msg.sender, address(this), _nftIds[i]);
        }
        emit NFTBatchDeposited(msg.sender, _userId, _nftIds, _txid);
    }

    function batchWithdrawNFT(
        address _receiver,
        string calldata _userId,
        uint256[] calldata _nftIds,
        uint256 _nonce,
        bytes calldata _signature
    ) public whenNotPaused {
        require(!isUsedNonce[_receiver][_nonce], "Nonce has been used");
        address messageSigner = ICALOManager(caloManager).getMessageSigner();
        bytes32 messageHash = getMessageHash(
            _receiver,
            _userId,
            _nftIds,
            _nonce
        );
        require(
            _isSignatureValid(messageHash, _signature, messageSigner),
            "Signature is invalid"
        );
        for (uint256 i; i < _nftIds.length; i++) {
            address nftContractAddress = ICALOManager(caloManager).getContract(
                NFT_NAME
            );
            if (ICALONFT(nftContractAddress).isExist(_nftIds[i])) {
                IERC721(nftContractAddress).transferFrom(
                    address(this),
                    _receiver,
                    _nftIds[i]
                );
            } else {
                ICALONFT(nftContractAddress).mint(_receiver, _nftIds[i]);
            }
        }
        isUsedNonce[_receiver][_nonce] = true;
        emit NFTBatchWithdrawn(_receiver, _userId, _nftIds, _nonce);
    }

    function withdrawNFT(
        address _receiver,
        string calldata _userId,
        uint256 _nftId,
        uint256 _nonce,
        bytes calldata _signature
    ) public whenNotPaused {
        require(!isUsedNonce[_receiver][_nonce], "Nonce has been used");
        address messageSigner = ICALOManager(caloManager).getMessageSigner();
        bytes32 messageHash = getMessageHash(
            _receiver,
            _userId,
            _nftId,
            _nonce
        );
        require(
            _isSignatureValid(messageHash, _signature, messageSigner),
            "Signature is invalid"
        );
        address nftContractAddress = ICALOManager(caloManager).getContract(
            NFT_NAME
        );
        if (ICALONFT(nftContractAddress).isExist(_nftId)) {
            IERC721(nftContractAddress).transferFrom(
                address(this),
                _receiver,
                _nftId
            );
        } else {
            ICALONFT(nftContractAddress).mint(_receiver, _nftId);
        }
        isUsedNonce[_receiver][_nonce] = true;
        emit NFTWithdrawn(_receiver, _userId, _nftId, _nonce);
    }

    function emergencyWithdraw(uint256 _amount)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        address nftAddress = ICALOManager(caloManager).getContract(NFT_NAME);
        uint256 balance = IERC721(nftAddress).balanceOf(address(this));
        uint256 amount = balance > _amount ? _amount : balance;
        for (uint256 i; i < amount; i++) {
            IERC721(nftAddress).transferFrom(
                address(this),
                msg.sender,
                IERC721Enumerable(nftAddress).tokenOfOwnerByIndex(
                    address(this),
                    i
                )
            );
        }
    }

    function setCaloManager(address _caloManager)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        caloManager = _caloManager;
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function _isSignatureValid(
        bytes32 _messageHash,
        bytes calldata _signature,
        address _signerAddress
    ) internal pure returns (bool) {
        bytes32 ethMessageHash = ECDSAUpgradeable.toEthSignedMessageHash(
            _messageHash
        );
        return
            ECDSAUpgradeable.recover(ethMessageHash, _signature) ==
            _signerAddress;
    }

    function getMessageHash(
        address _receiver,
        string calldata _userId,
        uint256 _nftId,
        uint256 _nonce
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    address(this),
                    _receiver,
                    _userId,
                    _nftId,
                    _nonce,
                    NFT_NAME
                )
            );
    }

    function getMessageHash(
        address _receiver,
        string calldata _userId,
        uint256[] calldata _nftIds,
        uint256 _nonce
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    address(this),
                    _receiver,
                    _userId,
                    _nftIds,
                    _nonce,
                    NFT_NAME
                )
            );
    }

    function withdrawERC20Token(address _tokenAddress, uint256 amount)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        IERC20(_tokenAddress).transfer(_msgSender(), amount);
    }
}

interface ICALONFT {
    function isExist(uint256 tokenId) external view returns (bool);

    function mint(address _to, uint256 tokenId) external;
}
