// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "../../IVIDEOManager.sol";

contract DepositWithdrawToken is
Initializable,
PausableUpgradeable,
AccessControlUpgradeable
{
    using SafeMathUpgradeable for uint256;
    uint256 public maxWithdrawVidAmount;
    uint256 public maxWithdrawWatAmount;
    uint256 public vidWithdrawCountdown; //second
    uint256 public watWithdrawCountdown; //second
    string public VID_TOKEN_UNIQUE;
    string public WAT_TOKEN_UNIQUE;

    mapping(address => mapping(uint256 => bool)) isUsedNonce;
    mapping(string => bool) isUsedTxid;
    mapping(string => uint256) lastVidWithdrawTime;
    mapping(string => uint256) lastWatWithdrawTime;

    address public videoManager;

    event VidDeposited(
        address indexed sender,
        string userId,
        uint256 amount,
        string txid,
        uint256 poolRemain
    );
    event WatDeposited(
        address indexed sender,
        string userId,
        uint256 amount,
        string txid,
        uint256 poolRemain
    );

    event VidWithdrawn(
        address indexed receiver,
        string userId,
        uint256 nonce,
        uint256 amount,
        uint256 poolRemain
    );
    event WatWithdrawn(
        address indexed receiver,
        string userId,
        uint256 nonce,
        uint256 amount,
        uint256 poolRemain
    );

    //2022-06-09 add wat balance control logic
    uint256 public maxWatBalance;
    uint256 public alertWatBalance;

    event WatBalanceAlert(uint256 amount);

    //2022-06-25 add Vid/Wat withdraw whitelist logic
    uint256 public maxWhiteListWithdrawVidAmount;
    uint256 public maxWhiteListWithdrawWatAmount;
    uint256 public vidWhiteListWithdrawCountdown; //second
    uint256 public watWhiteListWithdrawCountdown;
    mapping(string => bool) public whiteListWithdrawUser;

    ////////////////////
    //Add new var here when update contract
    ////////////////////

    constructor() {}

    function initialize(
        uint256 _maxWithdrawVidAmount,
        uint256 _maxWithdrawWatAmount,
        uint256 _vidWithdrawCountdown,
        uint256 _watWithdrawCountdown,
        address _videoManager
    ) public initializer {
        __Pausable_init();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        maxWithdrawVidAmount = _maxWithdrawVidAmount;
        maxWithdrawWatAmount = _maxWithdrawWatAmount;
        vidWithdrawCountdown = _vidWithdrawCountdown;
        watWithdrawCountdown = _watWithdrawCountdown;
        videoManager = _videoManager;
        WAT_TOKEN_UNIQUE = "WAT";
        VID_TOKEN_UNIQUE = "VID";
    }

    function setMaxWithdrawVidAmount(uint256 _maxWithdrawVidAmount)
    public
    onlyRole(DEFAULT_ADMIN_ROLE)
    {
        maxWithdrawVidAmount = _maxWithdrawVidAmount;
    }

    function setMaxWithdrawWatAmount(uint256 _maxWithdrawWatAmount)
    public
    onlyRole(DEFAULT_ADMIN_ROLE)
    {
        maxWithdrawWatAmount = _maxWithdrawWatAmount;
    }

    function setVidWithdrawCountdown(uint256 _vidWithdrawCountdown)
    public
    onlyRole(DEFAULT_ADMIN_ROLE)
    {
        vidWithdrawCountdown = _vidWithdrawCountdown;
    }

    function setWatWithdrawCountdown(uint256 _watWithdrawCountdown)
    public
    onlyRole(DEFAULT_ADMIN_ROLE)
    {
        watWithdrawCountdown = _watWithdrawCountdown;
    }

    //USED
    function depositVid(
        string calldata _userId,
        uint256 _amount,
        string calldata _txid
    ) public whenNotPaused {
        require(!isUsedTxid[_txid], "Transaction ID is used");
        IERC20(IVIDEOManager(videoManager).getContract("VIDToken")).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        isUsedTxid[_txid] = true;
        uint256 remainAmount = IERC20(
            IVIDEOManager(videoManager).getContract("VIDToken")
        ).balanceOf(address(this));
        emit VidDeposited(msg.sender, _userId, _amount, _txid, remainAmount);
    }

    //USED
    function withdrawVid(
        address _receiver,
        string calldata _userId,
        uint256 _amount,
        uint256 _nonce,
        bytes calldata _signature
    ) public whenNotPaused {
        require(!isUsedNonce[_receiver][_nonce], "Nonce has been used");
        uint256 nextWithdrawTime;
        if (whiteListWithdrawUser[_userId]) {
            require(
                _amount < maxWhiteListWithdrawVidAmount,
                "Withdraw amount over WhiteList withdraw limit !"
            );
            nextWithdrawTime = lastVidWithdrawTime[_userId].add(
                vidWhiteListWithdrawCountdown
            );
        } else {
            require(
                _amount < maxWithdrawVidAmount,
                "Withdraw amount over withdraw limit !"
            );
            nextWithdrawTime = lastVidWithdrawTime[_userId].add(
                vidWithdrawCountdown
            );
        }

        require(
            nextWithdrawTime < block.timestamp,
            "Wait until the next withdraw time"
        );
        address messageSigner = IVIDEOManager(videoManager).getMessageSigner();
        bytes32 messageHash = getMessageHash(
            VID_TOKEN_UNIQUE,
            _receiver,
            _userId,
            _amount,
            _nonce
        );
        require(
            _isSignatureValid(messageHash, _signature, messageSigner),
            "Signature is invalid"
        );
        isUsedNonce[_receiver][_nonce] = true;
        IERC20(IVIDEOManager(videoManager).getContract("VIDToken")).transfer(
            _receiver,
            _amount
        );
        lastVidWithdrawTime[_userId] = block.timestamp;
        uint256 remainAmount = IERC20(
            IVIDEOManager(videoManager).getContract("VIDToken")
        ).balanceOf(address(this));
        emit VidWithdrawn(_receiver, _userId, _nonce, _amount, remainAmount);
    }

    //USED
    function depositWatToContract(
        string calldata _userId,
        uint256 _amount,
        string calldata _txid
    ) public whenNotPaused {
        require(!isUsedTxid[_txid], "Transaction ID is used");

        uint256 currentBalance = IERC20(
            IVIDEOManager(videoManager).getContract("WATToken")
        ).balanceOf(address(this));
        uint256 balanceAfterDeposit = currentBalance.add(_amount);
        if (balanceAfterDeposit > maxWatBalance) {
            // burn WAT if current contract balance over maxWatBalance
            ERC20Burnable(IVIDEOManager(videoManager).getContract("WATToken"))
            .burnFrom(msg.sender, _amount);
        } else {
            IERC20(IVIDEOManager(videoManager).getContract("WATToken"))
            .transferFrom(msg.sender, address(this), _amount);
        }

        isUsedTxid[_txid] = true;
        uint256 remainAmount = IERC20(
            IVIDEOManager(videoManager).getContract("WATToken")
        ).balanceOf(address(this));
        emit WatDeposited(msg.sender, _userId, _amount, _txid, remainAmount);
    }

    //USED
    function withdrawWatFromContract(
        address _receiver,
        string calldata _userId,
        uint256 _amount,
        uint256 _nonce,
        bytes calldata _signature
    ) public whenNotPaused {
        require(!isUsedNonce[_receiver][_nonce], "Nonce has been used");

        uint256 nextWithdrawTime;

        if (whiteListWithdrawUser[_userId]) {
            require(
                _amount < maxWhiteListWithdrawWatAmount,
                "Withdraw amount over whitelist withdraw limit !"
            );
            nextWithdrawTime = lastWatWithdrawTime[_userId].add(
                watWhiteListWithdrawCountdown
            );
        } else {
            require(
                _amount < maxWithdrawWatAmount,
                "Withdraw amount over withdraw limit !"
            );
            nextWithdrawTime = lastWatWithdrawTime[_userId].add(
                watWithdrawCountdown
            );
        }

        require(
            nextWithdrawTime < block.timestamp,
            "Wait until the next withdraw time"
        );
        address messageSigner = IVIDEOManager(videoManager).getMessageSigner();
        bytes32 messageHash = getMessageHash(
            WAT_TOKEN_UNIQUE,
            _receiver,
            _userId,
            _amount,
            _nonce
        );
        require(
            _isSignatureValid(messageHash, _signature, messageSigner),
            "Signature is invalid"
        );
        isUsedNonce[_receiver][_nonce] = true;
        IERC20(IVIDEOManager(videoManager).getContract("WATToken")).transfer(
            _receiver,
            _amount
        );
        lastWatWithdrawTime[_userId] = block.timestamp;
        uint256 remainAmount = IERC20(
            IVIDEOManager(videoManager).getContract("WATToken")
        ).balanceOf(address(this));
        emit WatWithdrawn(_receiver, _userId, _nonce, _amount, remainAmount);

        // alert event if current contract balance less than alertWatBalance
        uint256 currentBalance = IERC20(
            IVIDEOManager(videoManager).getContract("WATToken")
        ).balanceOf(address(this));
        if (currentBalance < alertWatBalance) {
            emit WatBalanceAlert(currentBalance);
        }
    }

//
//    function depositWAT(
//        string calldata _userId,
//        uint256 _amount,
//        string calldata _txid
//    ) public whenNotPaused {
//        require(!isUsedTxid[_txid], "Transaction ID is used");
//        ERC20Burnable(IVIDEOManager(videoManager).getContract("WATToken"))
//        .burnFrom(msg.sender, _amount);
//        isUsedTxid[_txid] = true;
//        uint256 remainAmount = IERC20(
//            IVIDEOManager(videoManager).getContract("WATToken")
//        ).balanceOf(address(this));
//        emit WatDeposited(msg.sender, _userId, _amount, _txid, remainAmount);
//    }
//
//    function withdrawWat(
//        address _receiver,
//        string calldata _userId,
//        uint256 _amount,
//        uint256 _nonce,
//        uint256 _isMint,
//        bytes calldata _signature
//    ) public whenNotPaused {
//        require(!isUsedNonce[_receiver][_nonce], "Nonce has been used");
//
//        require(
//            _amount < maxWithdrawWatAmount,
//            "Withdraw amount over withdraw limit !"
//        );
//        uint256 nextWithdrawTime = lastWatWithdrawTime[_userId].add(
//            watWithdrawCountdown
//        );
//        require(
//            nextWithdrawTime < block.timestamp,
//            "Wait until the next withdraw time"
//        );
//        address messageSigner = IVIDEOManager(videoManager).getMessageSigner();
//        bytes32 messageHash = getMintWATMessageHash(
//            WAT_TOKEN_UNIQUE,
//            _receiver,
//            _userId,
//            _amount,
//            _nonce,
//            _isMint
//        );
//        require(
//            _isSignatureValid(messageHash, _signature, messageSigner),
//            "Signature is invalid"
//        );
//        isUsedNonce[_receiver][_nonce] = true;
//        WATToken(IVIDEOManager(videoManager).getContract("WATToken")).mint(
//            _receiver,
//            _amount
//        );
//        lastWatWithdrawTime[_userId] = block.timestamp;
//        uint256 remainAmount = IERC20(
//            IVIDEOManager(videoManager).getContract("WATToken")
//        ).balanceOf(address(this));
//        emit WatWithdrawn(_receiver, _userId, _nonce, _amount, remainAmount);
//
//        // alert event if current contract balance less than alertWatBalance
//        uint256 currentBalance = IERC20(
//            IVIDEOManager(videoManager).getContract("WATToken")
//        ).balanceOf(address(this));
//        if (currentBalance < alertWatBalance) {
//            emit WatBalanceAlert(currentBalance);
//        }
//    }
//

    function emergencyWithdraw() public onlyRole(DEFAULT_ADMIN_ROLE) {
        address vidToken = IVIDEOManager(videoManager).getContract("VIDToken");
        address watToken = IVIDEOManager(videoManager).getContract("WATToken");
        IERC20(vidToken).transfer(
            msg.sender,
            IERC20(vidToken).balanceOf(address(this))
        );
        IERC20(watToken).transfer(
            msg.sender,
            IERC20(watToken).balanceOf(address(this))
        );
    }

    function getNextWatWithdrawTime(string calldata _userId)
    public
    view
    returns (uint256 nextWithdrawTime)
    {
        if (whiteListWithdrawUser[_userId]) {
            nextWithdrawTime = lastWatWithdrawTime[_userId].add(
                watWhiteListWithdrawCountdown
            );
        } else {
            nextWithdrawTime = lastWatWithdrawTime[_userId].add(
                watWithdrawCountdown
            );
        }

        return nextWithdrawTime;
    }

    function getNextVidWithdrawTime(string calldata _userId)
    public
    view
    returns (uint256 nextWithdrawTime)
    {
        if (whiteListWithdrawUser[_userId]) {
            nextWithdrawTime = lastVidWithdrawTime[_userId].add(
                vidWhiteListWithdrawCountdown
            );
        } else {
            nextWithdrawTime = lastVidWithdrawTime[_userId].add(
                vidWithdrawCountdown
            );
        }

        return nextWithdrawTime;
    }

    function setVideoManager(address _videoManager)
    public
    onlyRole(DEFAULT_ADMIN_ROLE)
    {
        videoManager = _videoManager;
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
        string memory tokenType,
        address _receiver,
        string calldata _userId,
        uint256 _amount,
        uint256 _nonce
    ) public view returns (bytes32) {
        return
        keccak256(
            abi.encodePacked(
                address(this),
                tokenType,
                _receiver,
                _userId,
                _amount,
                _nonce
            )
        );
    }

    function getMintWATMessageHash(
        string memory tokenType,
        address _receiver,
        string calldata _userId,
        uint256 _amount,
        uint256 _nonce,
        uint256 _isMint
    ) public pure returns (bytes32) {
        return
        keccak256(
            abi.encodePacked(
                tokenType,
                _receiver,
                _userId,
                _amount,
                _nonce,
                _isMint
            )
        );
    }

    function withdrawERC20Token(address _tokenAddress, uint256 amount)
    public
    onlyRole(DEFAULT_ADMIN_ROLE)
    {
        IERC20(_tokenAddress).transfer(_msgSender(), amount);
    }

    function withdrawERC721Token(address tokenAddress, uint256 tokenId)
    public
    onlyRole(DEFAULT_ADMIN_ROLE)
    {
        IERC721(tokenAddress).transferFrom(address(this), msg.sender, tokenId);
    }


    function setWatBalanceControl(
        uint256 _maxWatBalance,
        uint256 _alertWatBalance
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        maxWatBalance = _maxWatBalance;
        alertWatBalance = _alertWatBalance;
    }

    //2022-06-25 add Vid/Wat withdraw whitelist logic
    function setMaxWhiteListWithdrawVidAmount(
        uint256 _maxWhiteListWithdrawVidAmount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        maxWhiteListWithdrawVidAmount = _maxWhiteListWithdrawVidAmount;
    }

    function setMaxWhiteListWithdrawWatAmount(
        uint256 _maxWhiteListWithdrawWatAmount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        maxWhiteListWithdrawWatAmount = _maxWhiteListWithdrawWatAmount;
    }

    function setWhiteListVidWithdrawCountdown(
        uint256 _vidWhiteListWithdrawCountdown
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        vidWhiteListWithdrawCountdown = _vidWhiteListWithdrawCountdown;
    }

    function setWhiteListWatWithdrawCountdown(
        uint256 _watWhiteListWithdrawCountdown
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        watWhiteListWithdrawCountdown = _watWhiteListWithdrawCountdown;
    }

    function setWhiteListWithdrawUser(
        string[] memory _userIds,
        bool isWhitelist
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < _userIds.length; i++) {
            whiteListWithdrawUser[_userIds[i]] = isWhitelist;
        }
    }

    //2022-07-07 add check max withdraw amount by user
    function maxWithdrawWatAmountByUser(string calldata _userId)
    public
    view
    returns (uint256 _maxWithdrawWatAmount)
    {
        if (whiteListWithdrawUser[_userId]) {
            _maxWithdrawWatAmount = maxWhiteListWithdrawWatAmount;
        } else {
            _maxWithdrawWatAmount = maxWithdrawWatAmount;
        }
        return _maxWithdrawWatAmount;
    }

    function maxWithdrawVidAmountByUser(string calldata _userId)
    public
    view
    returns (uint256 _maxWithdrawVidAmount)
    {
        if (whiteListWithdrawUser[_userId]) {
            _maxWithdrawVidAmount = maxWhiteListWithdrawVidAmount;
        } else {
            _maxWithdrawVidAmount = maxWithdrawVidAmount;
        }
        return _maxWithdrawVidAmount;
    }
}

pragma solidity ^0.8.0;

interface WATToken {
    function mint(address to, uint256 amount) external;
}
