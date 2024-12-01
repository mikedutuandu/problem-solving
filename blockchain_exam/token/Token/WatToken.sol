// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract WatToken is ERC20Burnable, AccessControl {
    using SafeMath for uint256;

//    address constant PANCAKE_FACTORY_ADDRESS =
//        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;//main net
//    address constant WBNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;//main net

    address constant PANCAKE_FACTORY_ADDRESS =
    0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;//test net
    address constant WBNB_ADDRESS = 0x9c127F37c39E2009EdB7085FA65B3B2dDAD682Ff;//test net

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public constant MAX_FEE_RATE = 1000; // 10%: MAX_FEE_RATE / FULL_RANGE
    uint256 constant FULL_RANGE = 10000;

    uint256 buyFeeRate = 0;
    uint256 sellFeeRate = 0;
    address teamWallet;
    uint256 public antiBotTime = 3 seconds;
    mapping(address => bool) public blacklist;
    mapping(address => bool) lpAddresses;
    mapping(address => uint256) lastSwapTimestamp;

    modifier antiFrontRunning(address sender, address receipient) {
        if (lpAddresses[sender] == true) {
            require(
                lastSwapTimestamp[receipient] + antiBotTime < block.timestamp,
                "Anti front running bot"
            );
            lastSwapTimestamp[receipient] = block.timestamp;
        }
        if (lpAddresses[receipient] == true) {
            require(
                lastSwapTimestamp[sender] + antiBotTime < block.timestamp,
                "Anti front running bot"
            );
            lastSwapTimestamp[sender] = block.timestamp;
        }

        _;
    }

    constructor() ERC20("WAT Token", "WAT") {
        _setupRole(DEFAULT_ADMIN_ROLE, tx.origin);
        _setupRole(MINTER_ROLE, tx.origin);
        teamWallet = tx.origin;
        //create FIT/WBNB pair in Pancake swap
        address pair = IPancakeFactory(PANCAKE_FACTORY_ADDRESS).createPair(
            address(this),
            WBNB_ADDRESS
        );
        //setup lp address
        lpAddresses[pair] = true;
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override(ERC20) antiFrontRunning(sender, recipient) {
        require(
            !blacklist[sender] && !blacklist[recipient],
            "the address is blacklisted"
        );
        require(
            balanceOf(sender) >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        uint256 feeRate = 0;
        if (lpAddresses[sender]) {
            //buy
            feeRate = buyFeeRate;
        } else if (lpAddresses[recipient]) {
            //sell
            feeRate = sellFeeRate;
        }
        if (feeRate > 0 && recipient != teamWallet && sender != teamWallet) {
            uint256 fee = amount.mul(feeRate).div(FULL_RANGE);
            amount = amount.sub(fee);
            ERC20._transfer(sender, recipient, amount);
            ERC20._transfer(sender, teamWallet, fee);
        } else {
            ERC20._transfer(sender, recipient, amount);
        }
    }

    function setFee(uint256 _buyFeeRate, uint256 _sellFeeRate)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            _buyFeeRate <= MAX_FEE_RATE && _sellFeeRate <= MAX_FEE_RATE,
            "Fee must be less than MAX_FEE_RATE"
        );
        buyFeeRate = _buyFeeRate;
        sellFeeRate = _sellFeeRate;
    }

    function setLPAddresses(address[] memory addresses)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        for (uint256 i = 0; i < addresses.length; i++) {
            lpAddresses[addresses[i]] = true;
        }
    }

    function setMultiBlacklist(address[] memory addresses, bool isBlacklist)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        for (uint256 i = 0; i < addresses.length; i++) {
            blacklist[addresses[i]] = isBlacklist;
        }
    }

    function setTeamWallet(address _teamWallet)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        teamWallet = _teamWallet;
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

    function setAntiBotTime(uint256 _antiBotTime)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        antiBotTime = _antiBotTime;
    }
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}
