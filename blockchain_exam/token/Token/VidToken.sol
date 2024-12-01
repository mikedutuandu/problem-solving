// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract VidToken is ERC20Capped, ERC20Burnable, AccessControl {
    using SafeMath for uint256;

//    address constant PANCAKE_FACTORY_ADDRESS =
//        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;//main net
//    address constant USDT_ADDRESS = 0x55d398326f99059fF775485246999027B3197955;//main net

    address constant PANCAKE_FACTORY_ADDRESS =
    0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;//test net
    address constant USDT_ADDRESS = 0xf8C00a0F276249b39919B5C06e2eDdA15eA4Bcb5;//test net

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public constant MAX_FEE_RATE = 1000; // 10%: MAX_FEE_RATE / FULL_RANGE
    uint256 constant FULL_RANGE = 10000;
    uint256 constant PREMINT = 500 * 10**6 * 10**18;
    uint256 constant MAX_SUPPLY = 500 * 10**6 * 10**18;

    uint256 buyFeeRate = 0;
    uint256 sellFeeRate = 0;
    address teamWallet;
    mapping(address => bool) public blacklist;
    mapping(address => bool) lpAddresses;

    constructor() ERC20Capped(MAX_SUPPLY) ERC20("VID Token", "VID") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        teamWallet = 0x0c2c5496bd43E6892386C7f3997b97101099F806;
        ERC20._mint(teamWallet, PREMINT);

        //create CALO/USDT pair in Pancake swap
        address pair = IPancakeFactory(PANCAKE_FACTORY_ADDRESS).createPair(
            address(this),
            USDT_ADDRESS
        );
        lpAddresses[pair] = true;
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override(ERC20) {
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
            feeRate = buyFeeRate;
        } else if (lpAddresses[recipient]) {
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

    function _mint(address account, uint256 amount)
        internal
        virtual
        override(ERC20, ERC20Capped)
    {
        ERC20Capped._mint(account, amount);
    }

    function withdrawERC20Token(address _tokenAddress, uint256 amount)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        IERC20(_tokenAddress).transfer(_msgSender(), amount);
    }
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}
