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

        // Get the hash and verify signature
        bytes32 ethSignedHash = verify(msg.sender, amount, signature);

        // Save withdrawal state
        usedSignatures[ethSignedHash] = true;
        lastWithdrawTime[msg.sender] = block.timestamp;

        require(token.transfer(msg.sender, amount), "Transfer failed");
        emit Withdrawn(msg.sender, amount);
    }

    // Handle all signature verification logic
    function verify(
        address sender,
        uint256 amount,
        bytes calldata signature
    ) public view returns (bytes32) {
        // Create hash from input params
        bytes32 messageHash = keccak256(abi.encodePacked(sender, amount));

        // Create Ethereum signed message hash
        bytes32 ethSignedHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        // Check if signature was used
        require(!usedSignatures[ethSignedHash], "Used signature");

        // Extract signature components
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 32))
            v := byte(0, calldataload(add(signature.offset, 64)))
        }

        // Verify signer is owner
        require(ecrecover(ethSignedHash, v, r, s) == owner(), "Invalid signature");

        return ethSignedHash;
    }

    // Emergency withdraw
    function emergencyWithdraw() external onlyOwner {
        require(token.transfer(owner(), token.balanceOf(address(this))));
    }
}