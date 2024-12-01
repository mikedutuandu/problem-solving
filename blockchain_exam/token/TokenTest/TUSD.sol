// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TUSD is ERC20Capped, ERC20Burnable, AccessControl {
    using SafeMath for uint256;

    uint256 constant PREMINT = 500 * 10**6 * 10**18;
    uint256 constant MAX_SUPPLY = 500 * 10**6 * 10**18;

    address teamWallet;

    constructor() ERC20Capped(MAX_SUPPLY) ERC20("TUSD", "TUSD") {

        teamWallet = 0x0c2c5496bd43E6892386C7f3997b97101099F806;
        ERC20._mint(teamWallet, PREMINT);
    }

    function _mint(address account, uint256 amount)
    internal
    virtual
    override(ERC20, ERC20Capped)
    {
        ERC20Capped._mint(account, amount);
    }

}
