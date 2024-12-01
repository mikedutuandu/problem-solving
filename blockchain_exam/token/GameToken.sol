// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Simple game token
contract GameToken is ERC20, Ownable {
    constructor() ERC20("Game Token", "GTK") {
        _mint(msg.sender, 1000000 * 10**decimals());
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

// Simple vault for deposits and withdrawals
contract TokenVault is ReentrancyGuard, Ownable {
    GameToken public immutable token;  // Made immutable
    uint256 public constant MAX_WITHDRAW = 1000 * 10**18;  // Made constant
    uint256 public constant COOLDOWN = 1 hours;  // Reduced and made constant

    mapping(address => uint256) public lastWithdrawTime;
    mapping(bytes32 => bool) public usedSignatures;  // Renamed for clarity

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address _token) {
        token = GameToken(_token);
    }

    // Deposit tokens
    function deposit(uint256 amount) external nonReentrant {
        require(amount > 0, "Zero amount");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        emit Deposited(msg.sender, amount);
    }

    // Withdraw with signature
    function withdraw(uint256 amount, bytes calldata signature) external nonReentrant {
        require(amount <= MAX_WITHDRAW, "Exceeds max");
        require(block.timestamp >= lastWithdrawTime[msg.sender] + COOLDOWN, "Too soon");

        bytes32 sigHash = keccak256(abi.encodePacked(msg.sender, amount));
        require(!usedSignatures[sigHash], "Used signature");
        require(verify(sigHash, signature), "Invalid signature");

        usedSignatures[sigHash] = true;
        lastWithdrawTime[msg.sender] = block.timestamp;

        require(token.transfer(msg.sender, amount), "Transfer failed");
        emit Withdrawn(msg.sender, amount);
    }

    // Verify signature
    function verify(bytes32 hash, bytes calldata signature) public view returns (bool) {
        bytes32 messageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 32))
            v := byte(0, calldataload(add(signature.offset, 64)))
        }

        return ecrecover(messageHash, v, r, s) == owner();
    }

    // Emergency withdraw
    function emergencyWithdraw() external onlyOwner {
        require(token.transfer(owner(), token.balanceOf(address(this))));
    }
}