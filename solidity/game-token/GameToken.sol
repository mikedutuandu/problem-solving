// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Simple game token
contract GameToken is ERC20, Ownable {
    constructor() ERC20("Game Token", "GTK") {
        _mint(msg.sender, 1000000 * 10**18);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

// Simplified vault for deposits and withdrawals
contract TokenVault is Ownable {
    GameToken public immutable token;
    uint256 public constant MAX_WITHDRAW = 1000 * 10**18;

    mapping(address => uint256) public balances;
    mapping(bytes32 => bool) public usedSignatures;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address _token) {
        token = GameToken(_token);
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Zero amount");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        balances[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount, bytes calldata signature) external {
        require(amount <= MAX_WITHDRAW, "Exceeds max");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        bytes32 ethSignedHash = verify(msg.sender, amount, signature);
        usedSignatures[ethSignedHash] = true;

        balances[msg.sender] -= amount;
        require(token.transfer(msg.sender, amount), "Transfer failed");
        emit Withdrawn(msg.sender, amount);
    }

    function verify(
        address sender,
        uint256 amount,
        bytes calldata signature
    ) public view returns (bytes32) {
        bytes32 messageHash = keccak256(abi.encodePacked(sender, amount));
        bytes32 ethSignedHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        require(!usedSignatures[ethSignedHash], "Used signature");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 32))
            v := byte(0, calldataload(add(signature.offset, 64)))
        }

        /*
        User wants to withdraw their tokens
        User must ask the owner to sign their withdrawal request
        Owner must sign it
        User can then submit the withdrawal with owner's signature
        */
        require(ecrecover(ethSignedHash, v, r, s) == owner(), "Invalid signature");

        // Verify the signer is the same as msg.sender (the withdrawer)
        // require(ecrecover(ethSignedHash, v, r, s) == msg.sender, "Invalid signature");
        return ethSignedHash;
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(owner(), balance), "Transfer failed");
    }
}