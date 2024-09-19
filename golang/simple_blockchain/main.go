package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"time"
)

/*
Transaction Hash (Tx Hash)
A transaction hash (or tx hash) is a unique code created by combining all the details of a blockchain transaction (like who sent it, who received it, the amount, and the time).
It's like a fingerprint for the transaction. This hash helps keep track of the transaction in the blockchain.
It's important because it makes each transaction easy to find, verify, and refer to later.

Block in a Blockchain
A block is a collection of transactions in a blockchain. Each block has two main parts:

A header with information about the block, including a link to the previous block.
The actual list of transactions.
New blocks are added to the blockchain through mining (in Proof of Work systems) or validation (in Proof of Stake systems).
In mining, computers solve difficult problems to add a new block, and the one that solves it first gets a reward.
In Proof of Stake, validators confirm the block by staking tokens, and they get rewarded for doing so.
This process ensures the blockchain grows securely, one block at a time.
*/

// Transaction represents a single transaction in the blockchain
type Transaction struct {
	Sender    string
	Receiver  string
	Amount    float64
	Timestamp string // Timestamp to make each transaction unique
	TxHash    string // Unique transaction hash
}

// Block represents a single block in the blockchain
type Block struct {
	Index        int           // Position of the block in the blockchain
	Timestamp    string        // Timestamp of when the block is created
	Transactions []Transaction // List of transactions contained in the block
	PreviousHash string        // Hash of the previous block
	Hash         string        // Hash of the current block
}

// Blockchain is a slice of Blocks
var Blockchain []Block

// CreateTransaction creates a new transaction and returns it with a transaction hash
func CreateTransaction(sender, receiver string, amount float64) Transaction {
	tx := Transaction{
		Sender:    sender,
		Receiver:  receiver,
		Amount:    amount,
		Timestamp: time.Now().String(), // Add a timestamp to make the transaction unique
		TxHash:    "",
	}

	// Create a unique hash for the transaction
	tx.TxHash = CalculateTxHash(tx)
	return tx
}

// CalculateTxHash generates a unique hash for a transaction based on its details
func CalculateTxHash(tx Transaction) string {
	record := fmt.Sprintf("%s%s%f%s", tx.Sender, tx.Receiver, tx.Amount, tx.Timestamp)
	hash := sha256.Sum256([]byte(record))
	return hex.EncodeToString(hash[:])
}

// CreateBlock creates a new block with a list of transactions
func CreateBlock(previousBlock Block, transactions []Transaction) Block {
	newBlock := Block{
		Index:        previousBlock.Index + 1,
		Timestamp:    time.Now().String(),
		Transactions: transactions,       // Add transactions to the block
		PreviousHash: previousBlock.Hash, // Link to the previous block
		Hash:         "",
	}
	newBlock.Hash = CalculateHash(newBlock)
	return newBlock
}

// CalculateHash generates a hash for a block's data (including transactions)
func CalculateHash(block Block) string {
	record := fmt.Sprintf("%d%s%s", block.Index, block.Timestamp, block.PreviousHash)
	for _, tx := range block.Transactions {
		record += tx.TxHash // Include transaction hashes in block hash
	}
	hash := sha256.Sum256([]byte(record))
	return hex.EncodeToString(hash[:])
}

// MintBlock creates a new block every 2 seconds with dummy transactions
func MintBlock() {
	for {
		time.Sleep(2 * time.Second)

		// Create dummy transactions for the new block
		transactions := []Transaction{
			CreateTransaction("Alice", "Bob", 10),
			CreateTransaction("Charlie", "Dave", 5),
		}

		// Create a new block using the latest block in the blockchain
		previousBlock := Blockchain[len(Blockchain)-1]
		newBlock := CreateBlock(previousBlock, transactions)

		// Add the new block to the blockchain
		Blockchain = append(Blockchain, newBlock)

		// Print the newly minted block with transactions
		fmt.Printf("New Block Mined:\n")
		fmt.Printf("Index: %d\n", newBlock.Index)
		fmt.Printf("Timestamp: %s\n", newBlock.Timestamp)
		fmt.Printf("Previous Hash: %s\n", newBlock.PreviousHash)
		fmt.Printf("Hash: %s\n", newBlock.Hash)
		fmt.Println("Transactions:")
		for _, tx := range newBlock.Transactions {
			fmt.Printf("  Sender: %s, Receiver: %s, Amount: %.2f, TxHash: %s\n", tx.Sender, tx.Receiver, tx.Amount, tx.TxHash)
		}
		fmt.Println()
	}
}

func main() {
	// Create the genesis block (the first block in the blockchain)
	genesisBlock := Block{
		Index:        0,
		Timestamp:    time.Now().String(),
		Transactions: []Transaction{}, // No transactions in the genesis block
		PreviousHash: "",              // No previous block, so empty
		Hash:         "",              // Will be calculated below
	}
	genesisBlock.Hash = CalculateHash(genesisBlock) // Generate hash for genesis block

	// Initialize the blockchain with the genesis block
	Blockchain = append(Blockchain, genesisBlock)

	// Start minting new blocks with transactions every 2 seconds
	go MintBlock()

	// Let the minting process continue indefinitely
	select {}
}
